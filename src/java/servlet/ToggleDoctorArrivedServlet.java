package servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import util.DBConnection;

@WebServlet(name = "ToggleDoctorArrivedServlet", urlPatterns = {"/ToggleDoctorArrivedServlet"})
public class ToggleDoctorArrivedServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String scheduleIdStr = request.getParameter("scheduleId");
        String newValueStr = request.getParameter("newValue");

        Connection conn = null;

        try {
            conn = DBConnection.getConnection();

            PreparedStatement stmt = conn.prepareStatement(
                "UPDATE doctor_schedule SET doctor_arrived = ? WHERE schedule_id = ?");
            stmt.setBoolean(1, "1".equals(newValueStr));
            stmt.setInt(2, Integer.parseInt(scheduleIdStr));
            stmt.executeUpdate();

            response.sendRedirect("nurse/queueStatus.jsp?success=1");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("nurse/queueStatus.jsp?error=1");

        } finally {
            if (conn != null) {
                try { conn.close(); } catch (Exception closeEx) { closeEx.printStackTrace(); }
            }
        }
    }
}