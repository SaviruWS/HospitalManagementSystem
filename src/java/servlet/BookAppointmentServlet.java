package servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import util.DBConnection;
import util.EmailUtil;

@WebServlet(name = "BookAppointmentServlet", urlPatterns = {"/BookAppointmentServlet"})
public class BookAppointmentServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String patientIdStr = request.getParameter("patientId");
        String doctorIdStr = request.getParameter("doctorId");
        String scheduleIdStr = request.getParameter("scheduleId");

        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            int patientId = Integer.parseInt(patientIdStr);
            int doctorId = Integer.parseInt(doctorIdStr);
            int scheduleId = Integer.parseInt(scheduleIdStr);

            // Step 1: Lock the schedule row and re-check capacity at the moment of booking.
            // FOR UPDATE prevents two simultaneous bookings from both passing the capacity check
            // for the very last available slot (a classic race condition).
            PreparedStatement capacityCheck = conn.prepareStatement(
                "SELECT ds.max_patients, " +
                "(SELECT COUNT(*) FROM appointments a WHERE a.schedule_id = ds.schedule_id AND a.status != 'cancelled') AS booked_count, " +
                "ds.available_date, ds.start_time " +
                "FROM doctor_schedule ds WHERE ds.schedule_id = ? FOR UPDATE");
            capacityCheck.setInt(1, scheduleId);
            ResultSet rs = capacityCheck.executeQuery();

            if (!rs.next()) {
                throw new Exception("Schedule slot not found.");
            }

            int maxPatients = rs.getInt("max_patients");
            int bookedCount = rs.getInt("booked_count");
            java.sql.Date appointmentDate = rs.getDate("available_date");
            java.sql.Time appointmentTime = rs.getTime("start_time");

            if (bookedCount >= maxPatients) {
                // Slot filled up between page load and submission — reject the booking
                conn.rollback();
                response.sendRedirect("receptionist/bookAppointment.jsp?error=1");
                return;
            }

            // Step 2: Insert the appointment — manual channeling, auto-confirmed
            PreparedStatement insertStmt = conn.prepareStatement(
                "INSERT INTO appointments (patient_id, doctor_id, schedule_id, appointment_date, appointment_time, channel_type, status) " +
                "VALUES (?, ?, ?, ?, ?, 'manual', 'confirmed')");
            insertStmt.setInt(1, patientId);
            insertStmt.setInt(2, doctorId);
            insertStmt.setInt(3, scheduleId);
            insertStmt.setDate(4, appointmentDate);
            insertStmt.setTime(5, appointmentTime);
            insertStmt.executeUpdate();

            // Step 3: Fetch patient email/name + doctor name, needed to build the confirmation email
            PreparedStatement infoStmt = conn.prepareStatement(
                "SELECT u.email, u.full_name AS patient_name, ud.full_name AS doctor_name " +
                "FROM patients p " +
                "JOIN users u ON p.user_id = u.user_id " +
                "JOIN doctors d ON d.doctor_id = ? " +
                "JOIN users ud ON d.user_id = ud.user_id " +
                "WHERE p.patient_id = ?");
            infoStmt.setInt(1, doctorId);
            infoStmt.setInt(2, patientId);
            ResultSet infoRs = infoStmt.executeQuery();

            String patientEmail = null;
            String patientName = null;
            String doctorName = null;

            if (infoRs.next()) {
                patientEmail = infoRs.getString("email");
                patientName = infoRs.getString("patient_name");
                doctorName = infoRs.getString("doctor_name");
            }

            conn.commit(); // booking is finalized here

            // Step 4: Send confirmation email — after commit, so email delivery never risks the booking itself
            if (patientEmail != null) {
                String subject = "Appointment Confirmed";
                String body = "Dear " + patientName + ",\n\n"
                        + "Your appointment with Dr. " + doctorName + " on " + appointmentDate
                        + " at " + appointmentTime + " has been CONFIRMED.\n\n"
                        + "Please arrive 15 minutes early.\n\n"
                        + "Thank you,\nNovaCare Private Hospital Management System";
                EmailUtil.sendEmail(patientEmail, subject, body);
            }

            response.sendRedirect("receptionist/bookAppointment.jsp?success=1");

        } catch (Exception e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (Exception rollbackEx) {
                    rollbackEx.printStackTrace();
                }
            }
            response.sendRedirect("receptionist/bookAppointment.jsp?error=1");

        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (Exception closeEx) {
                    closeEx.printStackTrace();
                }
            }
        }
    }
}