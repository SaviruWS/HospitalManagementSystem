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
import javax.servlet.http.HttpSession;
import util.DBConnection;
import util.EmailUtil;

@WebServlet(name = "BookAppointmentOnlineServlet", urlPatterns = {"/BookAppointmentOnlineServlet"})
public class BookAppointmentOnlineServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Integer userId = (session != null) ? (Integer) session.getAttribute("userId") : null;

        String doctorIdStr = request.getParameter("doctorId");
        String scheduleIdStr = request.getParameter("scheduleId");

        Connection conn = null;
        String patientEmail = null;
        String patientName = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            int doctorId = Integer.parseInt(doctorIdStr);
            int scheduleId = Integer.parseInt(scheduleIdStr);

       
            PreparedStatement patientLookup = conn.prepareStatement(
                "SELECT p.patient_id, u.email, u.full_name FROM patients p " +
                "JOIN users u ON p.user_id = u.user_id WHERE p.user_id = ?");
            patientLookup.setInt(1, userId);
            ResultSet patientRs = patientLookup.executeQuery();

            int patientId = -1;
            if (patientRs.next()) {
                patientId = patientRs.getInt("patient_id");
                patientEmail = patientRs.getString("email");
                patientName = patientRs.getString("full_name");
            }

            if (patientId == -1) {
                response.sendRedirect("patient/bookAppointment.jsp?error=1");
                return;
            }

            
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
                conn.rollback();
                response.sendRedirect("patient/bookAppointment.jsp?error=1");
                return;
            }

           
            PreparedStatement insertStmt = conn.prepareStatement(
                "INSERT INTO appointments (patient_id, doctor_id, schedule_id, appointment_date, appointment_time, channel_type, status) " +
                "VALUES (?, ?, ?, ?, ?, 'online', 'pending')");
            insertStmt.setInt(1, patientId);
            insertStmt.setInt(2, doctorId);
            insertStmt.setInt(3, scheduleId);
            insertStmt.setDate(4, appointmentDate);
            insertStmt.setTime(5, appointmentTime);
            insertStmt.executeUpdate();

            conn.commit();

          
           
            if (patientEmail != null) {
                String subject = "Appointment Request Received";
                String body = "Dear " + patientName + ",\n\n"
                        + "Your appointment request for " + appointmentDate + " at " + appointmentTime
                        + " has been received and is pending confirmation from our staff.\n"
                        + "You will receive another email once it is confirmed.\n\n"
                        + "Thank you,\nNovaCare Private Hospital Management System";
                EmailUtil.sendEmail(patientEmail, subject, body);
            }

            response.sendRedirect("patient/bookAppointment.jsp?success=1");

        } catch (Exception e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (Exception rollbackEx) {
                    rollbackEx.printStackTrace();
                }
            }
            response.sendRedirect("patient/bookAppointment.jsp?error=1");

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