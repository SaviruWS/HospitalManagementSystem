package servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import util.DBConnection;

@WebServlet(name = "AddScheduleServlet", urlPatterns = {"/AddScheduleServlet"})
public class AddScheduleServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Integer userId = (session != null) ? (Integer) session.getAttribute("userId") : null;

        String availableDate = request.getParameter("availableDate");
        String startTime = request.getParameter("startTime");
        String endTime = request.getParameter("endTime");
        String maxPatientsStr = request.getParameter("maxPatients");

        // Validation : the date itself cannot be in the past
        try {
            Date parsedDate = Date.valueOf(availableDate);
            Date today = new Date(System.currentTimeMillis());
            if (parsedDate.before(today)) {
                response.sendRedirect("doctor/manageSchedule.jsp?error=pastdate");
                return;
            }
        } catch (IllegalArgumentException dateEx) {
            response.sendRedirect("doctor/manageSchedule.jsp?error=1");
            return;
        }

        // Validation end time must be after start time
        if (endTime.compareTo(startTime) <= 0) {
            response.sendRedirect("doctor/manageSchedule.jsp?error=badtime");
            return;
        }

        Connection conn = null;

        try {
            conn = DBConnection.getConnection();

            PreparedStatement doctorLookup = conn.prepareStatement(
                "SELECT doctor_id FROM doctors WHERE user_id = ?");
            doctorLookup.setInt(1, userId);
            ResultSet rs = doctorLookup.executeQuery();

            int doctorId = -1;
            if (rs.next()) {
                doctorId = rs.getInt("doctor_id");
            }

            if (doctorId == -1) {
                response.sendRedirect("doctor/manageSchedule.jsp?error=1");
                return;
            }

            PreparedStatement insertStmt = conn.prepareStatement(
                "INSERT INTO doctor_schedule (doctor_id, available_date, start_time, end_time, max_patients) " +
                "VALUES (?, ?, ?, ?, ?)");
            insertStmt.setInt(1, doctorId);
            insertStmt.setString(2, availableDate);
            insertStmt.setString(3, startTime);
            insertStmt.setString(4, endTime);
            insertStmt.setInt(5, Integer.parseInt(maxPatientsStr));
            insertStmt.executeUpdate();

            response.sendRedirect("doctor/manageSchedule.jsp?success=1");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("doctor/manageSchedule.jsp?error=1");

        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (Exception closeEx) {
                    closeEx.printStackTrace();
                }
            }
        }
    }
}