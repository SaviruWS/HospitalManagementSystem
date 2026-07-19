<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="util.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../includes/sidebar.jsp" %>

    <div class="page-header">
        <div>
            <h2>Record Patient Vitals</h2>
            <p>Select a patient to record new vitals or view their history</p>
        </div>
        <div class="welcome-badge">Welcome, <strong><%= fullName %></strong></div>
    </div>

    <div class="card">
        <%
            String error = request.getParameter("error");
            String success = request.getParameter("success");
            if (error != null) {
        %>
            <div class="alert alert-error">Failed to save vitals. Please check your inputs.</div>
        <%
            } else if (success != null) {
        %>
            <div class="alert alert-success">Vitals recorded successfully.</div>
        <%
            }
        %>

        <form method="get" action="recordVitals.jsp">
            <label>Select Patient</label>
            <select name="patientId" onchange="this.form.submit()" required>
                <option value="">-- Select Patient --</option>
                <%
                    Connection conn = null;
                    try {
                        conn = DBConnection.getConnection();
                        PreparedStatement patientStmt = conn.prepareStatement(
                            "SELECT p.patient_id, u.full_name, u.email FROM patients p " +
                            "JOIN users u ON p.user_id = u.user_id ORDER BY u.full_name");
                        ResultSet patientRs = patientStmt.executeQuery();
                        String selectedPatientId = request.getParameter("patientId");
                        while (patientRs.next()) {
                            String pid = String.valueOf(patientRs.getInt("patient_id"));
                            String selected = pid.equals(selectedPatientId) ? "selected" : "";
                %>
                    <option value="<%= pid %>" <%= selected %>>
                        <%= patientRs.getString("full_name") %> (<%= patientRs.getString("email") %>)
                    </option>
                <%
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                %>
            </select>
            <noscript><button type="submit" class="btn">Load Patient</button></noscript>
        </form>
    </div>

    <%
        String patientIdParam = request.getParameter("patientId");
        if (patientIdParam != null && !patientIdParam.isEmpty()) {
    %>
        <div class="card" style="max-width: 500px;">
            <h3 style="margin-top:0; color: var(--color-navy);">Record New Vitals</h3>
            <form action="../RecordVitalsServlet" method="post">
                <input type="hidden" name="patientId" value="<%= patientIdParam %>">

                <label>Blood Pressure (e.g. 120/80)</label>
                <input type="text" name="bloodPressure" placeholder="120/80" required>

                <label>Temperature (°C)</label>
                <input type="number" step="0.1" name="temperature" placeholder="36.5" required>

                <label>Pulse Rate (bpm)</label>
                <input type="number" name="pulseRate" placeholder="72" required>

                <label>Weight (kg)</label>
                <input type="number" step="0.1" name="weight" placeholder="65.0">

                <label>Notes (optional)</label>
                <input type="text" name="notes" placeholder="Any observations">

                <br><br>
                <button type="submit" class="btn" style="width:100%;">Save Vitals</button>
            </form>
        </div>

        <div class="card">
            <h3 style="margin-top:0; color: var(--color-navy);">Vitals History</h3>
            <table>
                <tr>
                    <th>Date/Time</th>
                    <th>BP</th>
                    <th>Temp (°C)</th>
                    <th>Pulse</th>
                    <th>Weight (kg)</th>
                    <th>Notes</th>
                    <th>Recorded By</th>
                    <th>Actions</th>
                </tr>
                <%
                    try {
                        PreparedStatement historyStmt = conn.prepareStatement(
                            "SELECT v.vital_id, v.recorded_at, v.blood_pressure, v.temperature, v.pulse_rate, v.weight, v.notes, " +
                            "u.full_name AS nurse_name " +
                            "FROM vitals v JOIN users u ON v.recorded_by = u.user_id " +
                            "WHERE v.patient_id = ? ORDER BY v.recorded_at DESC");
                        historyStmt.setInt(1, Integer.parseInt(patientIdParam));
                        ResultSet historyRs = historyStmt.executeQuery();

                        boolean any = false;
                        while (historyRs.next()) {
                            any = true;
                            int vitalId = historyRs.getInt("vital_id");
                %>
                    <tr>
                        <td><%= historyRs.getTimestamp("recorded_at") %></td>
                        <td><%= historyRs.getString("blood_pressure") %></td>
                        <td><%= historyRs.getBigDecimal("temperature") %></td>
                        <td><%= historyRs.getInt("pulse_rate") %></td>
                        <td><%= historyRs.getBigDecimal("weight") %></td>
                        <td><%= historyRs.getString("notes") != null ? historyRs.getString("notes") : "-" %></td>
                        <td><%= historyRs.getString("nurse_name") %></td>
                        <td>
                            <a href="editVitals.jsp?vitalId=<%= vitalId %>" class="btn btn-sm">Edit</a>
                            <form action="../DeleteVitalsServlet" method="post" style="display:inline;"
                                  onsubmit="return confirm('Delete this vitals record? This cannot be undone.');">
                                <input type="hidden" name="vitalId" value="<%= vitalId %>">
                                <input type="hidden" name="patientId" value="<%= patientIdParam %>">
                                <button type="submit" class="btn btn-danger btn-sm">Delete</button>
                            </form>
                        </td>
                    </tr>
                <%
                        }
                        if (!any) {
                %>
                    <tr><td colspan="8">No vitals recorded for this patient yet.</td></tr>
                <%
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    } finally {
                        if (conn != null) { try { conn.close(); } catch (Exception e) { e.printStackTrace(); } }
                    }
                %>
            </table>
        </div>
    <%
        } else if (conn != null) {
            try { conn.close(); } catch (Exception e) { e.printStackTrace(); }
        }
    %>

</div></div>
</body>
</html>
