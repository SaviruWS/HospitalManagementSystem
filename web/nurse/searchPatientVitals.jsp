<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="util.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../includes/sidebar.jsp" %>

    <div class="page-header">
        <div>
            <h2>Search Patient Vitals</h2>
            <p>Find a patient and view their recorded vitals history</p>
        </div>
        <div class="welcome-badge">Welcome, <strong><%= fullName %></strong></div>
    </div>

    <div class="card">
        <form method="get" action="searchPatientVitals.jsp">
            <label>Search by Name or Email</label>
            <div style="display:flex; gap:10px;">
                <input type="text" name="q" style="flex:1;" placeholder="e.g. Kasun, or kasun@gmail.com"
                       value="<%= request.getParameter("q") != null ? request.getParameter("q") : "" %>">
                <button type="submit" class="btn">Search</button>
            </div>
        </form>
    </div>

    <%
        String searchQuery = request.getParameter("q");
        Connection conn = null;

        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
    %>
        <div class="card">
            <h3 style="margin-top:0; color: var(--color-navy);">Matching Patients</h3>
            <table>
                <tr>
                    <th>Full Name</th>
                    <th>Email</th>
                    <th>Contact</th>
                    <th>Action</th>
                </tr>
                <%
                    try {
                        conn = DBConnection.getConnection();
                        PreparedStatement stmt = conn.prepareStatement(
                            "SELECT p.patient_id, u.full_name, u.email, u.contact_number FROM patients p " +
                            "JOIN users u ON p.user_id = u.user_id " +
                            "WHERE u.full_name LIKE ? OR u.email LIKE ? ORDER BY u.full_name");
                        String likeTerm = "%" + searchQuery.trim() + "%";
                        stmt.setString(1, likeTerm);
                        stmt.setString(2, likeTerm);
                        ResultSet rs = stmt.executeQuery();

                        boolean any = false;
                        while (rs.next()) {
                            any = true;
                            int pid = rs.getInt("patient_id");
                %>
                    <tr>
                        <td><%= rs.getString("full_name") %></td>
                        <td><%= rs.getString("email") %></td>
                        <td><%= rs.getString("contact_number") %></td>
                        <td>
                            <a href="searchPatientVitals.jsp?q=<%= java.net.URLEncoder.encode(searchQuery, "UTF-8") %>&viewPatientId=<%= pid %>" class="btn btn-sm">View Vitals</a>
                        </td>
                    </tr>
                <%
                        }
                        if (!any) {
                %>
                    <tr><td colspan="4">No patients found matching "<%= searchQuery %>".</td></tr>
                <%
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                %>
            </table>
        </div>
    <%
        }

        String viewPatientId = request.getParameter("viewPatientId");
        if (viewPatientId != null && !viewPatientId.isEmpty()) {
    %>
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
                </tr>
                <%
                    try {
                        if (conn == null) conn = DBConnection.getConnection();
                        PreparedStatement historyStmt = conn.prepareStatement(
                            "SELECT v.recorded_at, v.blood_pressure, v.temperature, v.pulse_rate, v.weight, v.notes, " +
                            "u.full_name AS nurse_name " +
                            "FROM vitals v JOIN users u ON v.recorded_by = u.user_id " +
                            "WHERE v.patient_id = ? ORDER BY v.recorded_at DESC");
                        historyStmt.setInt(1, Integer.parseInt(viewPatientId));
                        ResultSet historyRs = historyStmt.executeQuery();

                        boolean any = false;
                        while (historyRs.next()) {
                            any = true;
                %>
                    <tr>
                        <td><%= historyRs.getTimestamp("recorded_at") %></td>
                        <td><%= historyRs.getString("blood_pressure") %></td>
                        <td><%= historyRs.getBigDecimal("temperature") %></td>
                        <td><%= historyRs.getInt("pulse_rate") %></td>
                        <td><%= historyRs.getBigDecimal("weight") %></td>
                        <td><%= historyRs.getString("notes") != null ? historyRs.getString("notes") : "-" %></td>
                        <td><%= historyRs.getString("nurse_name") %></td>
                    </tr>
                <%
                        }
                        if (!any) {
                %>
                    <tr><td colspan="7">No vitals recorded for this patient yet.</td></tr>
                <%
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                %>
            </table>
        </div>
    <%
        }

        if (conn != null) {
            try { conn.close(); } catch (Exception e) { e.printStackTrace(); }
        }
    %>

</div></div>
</body>
</html>
