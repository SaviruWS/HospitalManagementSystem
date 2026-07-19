<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="util.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../includes/sidebar.jsp" %>

    <div class="page-header">
        <div>
            <h2>Today's Appointments</h2>
            <p>All confirmed appointments scheduled for today</p>
        </div>
        <div class="welcome-badge">Welcome, <strong><%= fullName %></strong></div>
    </div>

    <div class="card">
        <table>
            <tr>
                <th>Time</th>
                <th>Patient</th>
                <th>Doctor</th>
                <th>Channel</th>
                <th>Status</th>
            </tr>
            <%
                Connection conn = null;
                try {
                    conn = DBConnection.getConnection();
                    PreparedStatement stmt = conn.prepareStatement(
                        "SELECT up.full_name AS patient_name, ud.full_name AS doctor_name, " +
                        "a.appointment_time, a.channel_type, a.status " +
                        "FROM appointments a " +
                        "JOIN patients p ON a.patient_id = p.patient_id " +
                        "JOIN users up ON p.user_id = up.user_id " +
                        "JOIN doctors d ON a.doctor_id = d.doctor_id " +
                        "JOIN users ud ON d.user_id = ud.user_id " +
                        "WHERE a.appointment_date = CURDATE() AND a.status = 'confirmed' " +
                        "ORDER BY a.appointment_time");
                    ResultSet rs = stmt.executeQuery();

                    boolean any = false;
                    while (rs.next()) {
                        any = true;
            %>
                <tr>
                    <td><%= rs.getTime("appointment_time") %></td>
                    <td><%= rs.getString("patient_name") %></td>
                    <td>Dr. <%= rs.getString("doctor_name") %></td>
                    <td style="text-transform:capitalize;"><%= rs.getString("channel_type") %></td>
                    <td><span class="badge badge-confirmed"><%= rs.getString("status") %></span></td>
                </tr>
            <%
                    }
                    if (!any) {
            %>
                <tr><td colspan="5">No confirmed appointments scheduled for today.</td></tr>
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

</div></div>
</body>
</html>
