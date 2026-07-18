<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="util.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../includes/sidebar.jsp" %>

    <div class="page-header">
        <div>
            <h2>My Appointments</h2>
            <p>Your appointment history and upcoming bookings</p>
        </div>
        <div class="welcome-badge">Welcome, <strong><%= fullName %></strong></div>
    </div>

    <div class="card">
        <table>
            <tr>
                <th>Doctor</th>
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

                    PreparedStatement patientLookup = conn.prepareStatement(
                        "SELECT patient_id FROM patients WHERE user_id = ?");
                    patientLookup.setInt(1, userId);
                    ResultSet patientRs = patientLookup.executeQuery();
                    int patientId = -1;
                    if (patientRs.next()) {
                        patientId = patientRs.getInt("patient_id");
                    }

                    PreparedStatement stmt = conn.prepareStatement(
                        "SELECT ud.full_name AS doctor_name, a.appointment_date, a.appointment_time, " +
                        "a.channel_type, a.status " +
                        "FROM appointments a " +
                        "JOIN doctors d ON a.doctor_id = d.doctor_id " +
                        "JOIN users ud ON d.user_id = ud.user_id " +
                        "WHERE a.patient_id = ? " +
                        "ORDER BY a.appointment_date DESC, a.appointment_time DESC");
                    stmt.setInt(1, patientId);
                    ResultSet rs = stmt.executeQuery();

                    boolean any = false;
                    while (rs.next()) {
                        any = true;
                        String status = rs.getString("status");
            %>
                <tr>
                    <td>Dr. <%= rs.getString("doctor_name") %></td>
                    <td><%= rs.getDate("appointment_date") %></td>
                    <td><%= rs.getTime("appointment_time") %></td>
                    <td style="text-transform:capitalize;"><%= rs.getString("channel_type") %></td>
                    <td><span class="badge badge-<%= status %>"><%= status %></span></td>
                </tr>
            <%
                    }
                    if (!any) {
            %>
                <tr><td colspan="5">You haven't booked any appointments yet.</td></tr>
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
