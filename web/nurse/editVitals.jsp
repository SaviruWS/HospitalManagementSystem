<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="util.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../includes/sidebar.jsp" %>

    <div class="page-header">
        <div>
            <h2>Edit Vitals Record</h2>
            <p>Update a previously recorded vitals entry</p>
        </div>
        <div class="welcome-badge">Welcome, <strong><%= fullName %></strong></div>
    </div>

    <div class="card" style="max-width: 480px;">
        <%
            String error = request.getParameter("error");
            if (error != null) {
        %>
            <div class="alert alert-error">Failed to update vitals. Please check your inputs.</div>
        <%
            }

            String vitalIdParam = request.getParameter("vitalId");
            Connection conn = null;
            String patientId = null;

            try {
                conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement("SELECT * FROM vitals WHERE vital_id = ?");
                stmt.setInt(1, Integer.parseInt(vitalIdParam));
                ResultSet rs = stmt.executeQuery();

                if (rs.next()) {
                    patientId = String.valueOf(rs.getInt("patient_id"));
        %>
            <form action="../UpdateVitalsServlet" method="post">
                <input type="hidden" name="vitalId" value="<%= vitalIdParam %>">
                <input type="hidden" name="patientId" value="<%= patientId %>">

                <label>Blood Pressure</label>
                <input type="text" name="bloodPressure" value="<%= rs.getString("blood_pressure") %>" required>

                <label>Temperature (°C)</label>
                <input type="number" step="0.1" name="temperature" value="<%= rs.getBigDecimal("temperature") %>" required>

                <label>Pulse Rate (bpm)</label>
                <input type="number" name="pulseRate" value="<%= rs.getInt("pulse_rate") %>" required>

                <label>Weight (kg)</label>
                <input type="number" step="0.1" name="weight" value="<%= rs.getBigDecimal("weight") != null ? rs.getBigDecimal("weight") : "" %>">

                <label>Notes</label>
                <input type="text" name="notes" value="<%= rs.getString("notes") != null ? rs.getString("notes") : "" %>">

                <br><br>
                <button type="submit" class="btn" style="width:100%;">Save Changes</button>
            </form>
        <%
                } else {
        %>
            <p>Vitals record not found.</p>
        <%
                }
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                if (conn != null) { try { conn.close(); } catch (Exception e) { e.printStackTrace(); } }
            }
        %>
        <br>
        <a href="recordVitals.jsp<%= patientId != null ? "?patientId=" + patientId : "" %>">Back to Vitals</a>
    </div>

</div></div>
</body>
</html>
