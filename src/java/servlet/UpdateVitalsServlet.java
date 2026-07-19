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

@WebServlet(name = "UpdateVitalsServlet", urlPatterns = {"/UpdateVitalsServlet"})
public class UpdateVitalsServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String vitalIdStr = request.getParameter("vitalId");
        String patientId = request.getParameter("patientId");
        String bloodPressure = request.getParameter("bloodPressure");
        String temperatureStr = request.getParameter("temperature");
        String pulseRateStr = request.getParameter("pulseRate");
        String weightStr = request.getParameter("weight");
        String notes = request.getParameter("notes");

        Connection conn = null;

        try {
            conn = DBConnection.getConnection();

            PreparedStatement stmt = conn.prepareStatement(
                "UPDATE vitals SET blood_pressure = ?, temperature = ?, pulse_rate = ?, weight = ?, notes = ? " +
                "WHERE vital_id = ?");
            stmt.setString(1, bloodPressure);
            stmt.setDouble(2, Double.parseDouble(temperatureStr));
            stmt.setInt(3, Integer.parseInt(pulseRateStr));

            if (weightStr != null && !weightStr.isEmpty()) {
                stmt.setDouble(4, Double.parseDouble(weightStr));
            } else {
                stmt.setNull(4, java.sql.Types.DECIMAL);
            }

            stmt.setString(5, (notes != null && !notes.isEmpty()) ? notes : null);
            stmt.setInt(6, Integer.parseInt(vitalIdStr));

            stmt.executeUpdate();

            response.sendRedirect("nurse/recordVitals.jsp?patientId=" + patientId + "&success=1");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("nurse/editVitals.jsp?vitalId=" + vitalIdStr + "&error=1");

        } finally {
            if (conn != null) {
                try { conn.close(); } catch (Exception closeEx) { closeEx.printStackTrace(); }
            }
        }
    }
}
