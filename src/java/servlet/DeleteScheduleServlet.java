package servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import util.DBConnection;
import util.EmailUtil;

@WebServlet(name = "DeleteScheduleServlet", urlPatterns = {"/DeleteScheduleServlet"})
public class DeleteScheduleServlet extends HttpServlet {

    private static class AffectedPatient {
        String email, name, doctorName;
        AffectedPatient(String email, String name, String doctorName) {
            this.email = email; this.name = name; this.doctorName = doctorName;
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String scheduleIdStr = request.getParameter("scheduleId");
        Connection conn = null;
        List<AffectedPatient> affectedPatients = new ArrayList<>();
        java.sql.Date apptDate = null;
        java.sql.Time apptTime = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            int scheduleId = Integer.parseInt(scheduleIdStr);

            // Find every currently-active (non-cancelled) appointment in this slot
            PreparedStatement findAffected = conn.prepareStatement(
                "SELECT u.email, u.full_name AS patient_name, ud.full_name AS doctor_name, " +
                "a.appointment_date, a.appointment_time " +
                "FROM appointments a " +
                "JOIN patients p ON a.patient_id = p.patient_id " +
                "JOIN users u ON p.user_id = u.user_id " +
                "JOIN doctors d ON a.doctor_id = d.doctor_id " +
                "JOIN users ud ON d.user_id = ud.user_id " +
                "WHERE a.schedule_id = ? AND a.status != 'cancelled'");
            findAffected.setInt(1, scheduleId);
            ResultSet rs = findAffected.executeQuery();

            while (rs.next()) {
                affectedPatients.add(new AffectedPatient(
                    rs.getString("email"), rs.getString("patient_name"), rs.getString("doctor_name")));
                apptDate = rs.getDate("appointment_date");
                apptTime = rs.getTime("appointment_time");
            }

            // Cancel any active appointments tied to this slot
            if (!affectedPatients.isEmpty()) {
                PreparedStatement cancelStmt = conn.prepareStatement(
                    "UPDATE appointments SET status = 'cancelled' WHERE schedule_id = ? AND status != 'cancelled'");
                cancelStmt.setInt(1, scheduleId);
                cancelStmt.executeUpdate();
            }

            // Check if ANY appointment row at all (including already-cancelled ones)
           
            PreparedStatement anyHistoryCheck = conn.prepareStatement(
                "SELECT COUNT(*) AS total FROM appointments WHERE schedule_id = ?");
            anyHistoryCheck.setInt(1, scheduleId);
            ResultSet historyRs = anyHistoryCheck.executeQuery();
            boolean hasAnyHistory = historyRs.next() && historyRs.getInt("total") > 0;

            if (hasAnyHistory) {
                // keep the row just mark it cancelled
                // so it no longer appears in the doctor's active schedule or in patient booking screens.
                PreparedStatement softDelete = conn.prepareStatement(
                    "UPDATE doctor_schedule SET status = 'cancelled' WHERE schedule_id = ?");
                softDelete.setInt(1, scheduleId);
                softDelete.executeUpdate();
            } else {
                // Safe to fully remove 
                PreparedStatement hardDelete = conn.prepareStatement(
                    "DELETE FROM doctor_schedule WHERE schedule_id = ?");
                hardDelete.setInt(1, scheduleId);
                hardDelete.executeUpdate();
            }

            conn.commit();

            for (AffectedPatient ap : affectedPatients) {
                String subject = "Appointment Cancelled — Schedule Change";
                String body = "Dear " + ap.name + ",\n\n"
                        + "We regret to inform you that your appointment with  " + ap.doctorName
                        + " on " + apptDate + " at " + apptTime + " has been CANCELLED "
                        + "due to a change in the doctor's availability.\n\n"
                        + "We apologize for the inconvenience. Please contact us or book another appointment.\n\n"
                        + "Thank you,\nNovaCare Private Hospital Management System";
                EmailUtil.sendEmail(ap.email, subject, body);
            }

            String successParam = affectedPatients.isEmpty() ? "deleted" : "cancelled" + affectedPatients.size();
            response.sendRedirect("doctor/manageSchedule.jsp?success=" + successParam);

        } catch (Exception e) {
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (Exception rollbackEx) { rollbackEx.printStackTrace(); }
            }
            response.sendRedirect("doctor/manageSchedule.jsp?error=1");

        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (Exception closeEx) { closeEx.printStackTrace(); }
            }
        }
    }
}