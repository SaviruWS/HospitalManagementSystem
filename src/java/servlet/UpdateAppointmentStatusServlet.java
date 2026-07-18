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

@WebServlet(name = "UpdateAppointmentStatusServlet", urlPatterns = {"/UpdateAppointmentStatusServlet"})
public class UpdateAppointmentStatusServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String appointmentIdStr = request.getParameter("appointmentId");
        String newStatus = request.getParameter("newStatus"); // "confirmed" or "cancelled"

        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            int appointmentId = Integer.parseInt(appointmentIdStr);

          
            PreparedStatement updateStmt = conn.prepareStatement(
                "UPDATE appointments SET status = ? WHERE appointment_id = ?");
            updateStmt.setString(1, newStatus);
            updateStmt.setInt(2, appointmentId);
            updateStmt.executeUpdate();

       
            PreparedStatement infoStmt = conn.prepareStatement(
                "SELECT u.email, u.full_name AS patient_name, ud.full_name AS doctor_name, " +
                "a.appointment_date, a.appointment_time " +
                "FROM appointments a " +
                "JOIN patients p ON a.patient_id = p.patient_id " +
                "JOIN users u ON p.user_id = u.user_id " +
                "JOIN doctors d ON a.doctor_id = d.doctor_id " +
                "JOIN users ud ON d.user_id = ud.user_id " +
                "WHERE a.appointment_id = ?");
            infoStmt.setInt(1, appointmentId);
            ResultSet rs = infoStmt.executeQuery();

            String patientEmail = null;
            String patientName = null;
            String doctorName = null;
            java.sql.Date apptDate = null;
            java.sql.Time apptTime = null;

            if (rs.next()) {
                patientEmail = rs.getString("email");
                patientName = rs.getString("patient_name");
                doctorName = rs.getString("doctor_name");
                apptDate = rs.getDate("appointment_date");
                apptTime = rs.getTime("appointment_time");
            }

            conn.commit();

         
            if (patientEmail != null) {
                String subject;
                String body;

                if ("confirmed".equals(newStatus)) {
                    subject = "Appointment Confirmed";
                    body = "Dear " + patientName + ",\n\n"
                            + "Your appointment with Dr. " + doctorName + " on " + apptDate
                            + " at " + apptTime + " has been CONFIRMED.\n\n"
                            + "Please arrive 15 minutes early.\n\n"
                            + "Thank you,\nNovaCare Private Hospital Management System";
                } else {
                    subject = "Appointment Cancelled";
                    body = "Dear " + patientName + ",\n\n"
                            + "We regret to inform you that your appointment with Dr. " + doctorName
                            + " on " + apptDate + " at " + apptTime + " has been CANCELLED.\n\n"
                            + "Please contact us or book another appointment.\n\n"
                            + "Thank you,\nNovaCare Private Hospital Management System";
                }

                EmailUtil.sendEmail(patientEmail, subject, body);
            }

            response.sendRedirect("receptionist/pendingAppointments.jsp?success=1");

        } catch (Exception e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (Exception rollbackEx) {
                    rollbackEx.printStackTrace();
                }
            }
            response.sendRedirect("receptionist/pendingAppointments.jsp?error=1");

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