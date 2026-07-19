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

@WebServlet(name = "DeleteVitalsServlet", urlPatterns = {"/DeleteVitalsServlet"})
public class DeleteVitalsServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String vitalIdStr = request.getParameter("vitalId");
        String patientId = request.getParameter("patientId");

        Connection conn = null;

        try {
            conn = DBConnection.getConnection();

         
            PreparedStatement stmt = conn.prepareStatement("DELETE FROM vitals WHERE vital_id = ?");
            stmt.setInt(1, Integer.parseInt(vitalIdStr));
            stmt.executeUpdate();

            response.sendRedirect("nurse/recordVitals.jsp?patientId=" + patientId + "&success=1");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("nurse/recordVitals.jsp?patientId=" + patientId + "&error=1");

        } finally {
            if (conn != null) {
                try { conn.close(); } catch (Exception closeEx) { closeEx.printStackTrace(); }
            }
        }
    }
}
