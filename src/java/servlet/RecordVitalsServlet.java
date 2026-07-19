package servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import util.DBConnection;

@WebServlet(name = "RecordVitalsServlet", urlPatterns = {"/RecordVitalsServlet"})
public class RecordVitalsServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Integer nurseUserId = (session != null) ? (Integer) session.getAttribute("userId") : null;

        String patientIdStr = request.getParameter("patientId");
        String bloodPressure = request.getParameter("bloodPressure");
        String temperatureStr = request.getParameter("temperature");
        String pulseRateStr = request.getParameter("pulseRate");
        String weightStr = request.getParameter("weight");
        String notes = request.getParameter("notes");

        Connection conn = null;

        try {
            conn = DBConnection.getConnection();

            PreparedStatement stmt = conn.prepareStatement(
                "INSERT INTO vitals (patient_id, recorded_by, blood_pressure, temperature, pulse_rate, weight, notes) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)");
            stmt.setInt(1, Integer.parseInt(patientIdStr));
            stmt.setInt(2, nurseUserId);
            stmt.setString(3, bloodPressure);
            stmt.setDouble(4, Double.parseDouble(temperatureStr));
            stmt.setInt(5, Integer.parseInt(pulseRateStr));

            if (weightStr != null && !weightStr.isEmpty()) {
                stmt.setDouble(6, Double.parseDouble(weightStr));
            } else {
                stmt.setNull(6, java.sql.Types.DECIMAL);
            }

            stmt.setString(7, (notes != null && !notes.isEmpty()) ? notes : null);

            stmt.executeUpdate();

            response.sendRedirect("nurse/recordVitals.jsp?patientId=" + patientIdStr + "&success=1");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("nurse/recordVitals.jsp?patientId=" + patientIdStr + "&error=1");

        } finally {
            if (conn != null) {
                try { conn.close(); } catch (Exception closeEx) { closeEx.printStackTrace(); }
            }
        }
    }
}