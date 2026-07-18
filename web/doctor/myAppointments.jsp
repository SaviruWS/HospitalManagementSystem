<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="util.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../includes/sidebar.jsp" %>

    <div class="page-header">
        <div>
            <h2>My Appointments</h2>
            <p>All appointments booked with you, upcoming and past</p>
        </div>
        <div class="welcome-badge">Dr. <strong><%= fullName %></strong></div>
    </div>

    <div class="card">
        <table>
            <tr>
                <th>Patient</th>
                <th>Date</th>
                <th>Time</th>
                <th>Channel</th>
                <th>Status</th>
            </tr>
            <%
                Integer userId = (Integer) session.getAttribute("userId");
                Connection conn = null;
                try {
                    conn = DBConnection.getConnection();

                    PreparedStatement doctorLookup = conn.prepareStatement(
                        "SELECT doctor_id FROM doctors WHERE user_id = ?");
                    doctorLookup.setInt(1, userId);
                    ResultSet doctorRs = doctorLookup.executeQuery();
                    int doctorId = -1;
                    if (doctorRs.next()) {
                        doctorId = doctorRs.getInt("doctor_id");
                    }

                    PreparedStatement stmt = conn.prepareStatement(
                        "SELECT u.full_name AS patient_name, a.appointment_date, a.appointment_time, " +
                        "a.channel_type, a.status " +
                        "FROM appointments a " +
                        "JOIN patients p ON a.patient_id = p.patient_id " +
                        "JOIN users u ON p.user_id = u.user_id " +
                        "WHERE a.doctor_id = ? " +
                        "ORDER BY a.appointment_date DESC, a.appointment_time DESC");
                    stmt.setInt(1, doctorId);
                    ResultSet rs = stmt.executeQuery();

                    boolean any = false;
                    while (rs.next()) {
                        any = true;
                        String status = rs.getString("status");
            %>
                <tr>
                    <td><%= rs.getString("patient_name") %></td>
                    <td><%= rs.getDate("appointment_date") %></td>
                    <td><%= rs.getTime("appointment_time") %></td>
                    <td style="text-transform:capitalize;"><%= rs.getString("channel_type") %></td>
                    <td><span class="badge badge-<%= status %>"><%= status %></span></td>
                </tr>
            <%
                    }
                    if (!any) {
            %>
                <tr><td colspan="5">No appointments yet.</td></tr>
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
