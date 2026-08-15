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

@WebServlet(name = "UpdateVisitStatusServlet", urlPatterns = {"/UpdateVisitStatusServlet"})
public class UpdateVisitStatusServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String appointmentIdStr = request.getParameter("appointmentId");
        String visitStatus = request.getParameter("visitStatus");

        Connection conn = null;

        try {
            conn = DBConnection.getConnection();

            PreparedStatement stmt = conn.prepareStatement(
                "UPDATE appointments SET visit_status = ? WHERE appointment_id = ?");
            stmt.setString(1, visitStatus);
            stmt.setInt(2, Integer.parseInt(appointmentIdStr));
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