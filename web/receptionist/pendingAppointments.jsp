<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="util.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../includes/sidebar.jsp" %>

    <div class="page-header">
        <div>
            <h2>Pending Appointments</h2>
            <p>Online bookings awaiting confirmation</p>
        </div>
        <div class="welcome-badge">Welcome, <strong><%= fullName %></strong></div>
    </div>

    <div class="card">
        <%
            String success = request.getParameter("success");
            String error = request.getParameter("error");
            if (success != null) {
        %>
            <div class="alert alert-success">Appointment status updated and patient notified.</div>
        <%
            } else if (error != null) {
        %>
            <div class="alert alert-error">Something went wrong. Please try again.</div>
        <%
            }
        %>

        <table>
            <tr>
                <th>Patient</th>
                <th>Doctor</th>
                <th>Date</th>
                <th>Time</th>
                <th>Requested On</th>
                <th>Action</th>
            </tr>
            <%
                Connection conn = null;
                try {
                    conn = DBConnection.getConnection();
                    PreparedStatement stmt = conn.prepareStatement(
                        "SELECT a.appointment_id, up.full_name AS patient_name, ud.full_name AS doctor_name, " +
                        "a.appointment_date, a.appointment_time, a.created_at " +
                        "FROM appointments a " +
                        "JOIN patients p ON a.patient_id = p.patient_id " +
                        "JOIN users up ON p.user_id = up.user_id " +
                        "JOIN doctors d ON a.doctor_id = d.doctor_id " +
                        "JOIN users ud ON d.user_id = ud.user_id " +
                        "WHERE a.status = 'pending' " +
                        "ORDER BY a.created_at");
                    ResultSet rs = stmt.executeQuery();

                    boolean anyPending = false;
                    while (rs.next()) {
                        anyPending = true;
                        int appointmentId = rs.getInt("appointment_id");
            %>
                <tr>
                    <td><%= rs.getString("patient_name") %></td>
                    <td>Dr. <%= rs.getString("doctor_name") %></td>
                    <td><%= rs.getDate("appointment_date") %></td>
                    <td><%= rs.getTime("appointment_time") %></td>
                    <td><%= rs.getTimestamp("created_at") %></td>
                    <td>
                        <form action="../UpdateAppointmentStatusServlet" method="post" style="display:inline;">
                            <input type="hidden" name="appointmentId" value="<%= appointmentId %>">
                            <input type="hidden" name="newStatus" value="confirmed">
                            <button type="submit" class="btn btn-success btn-sm">Confirm</button>
                        </form>
                        <form action="../UpdateAppointmentStatusServlet" method="post" style="display:inline;">
                            <input type="hidden" name="appointmentId" value="<%= appointmentId %>">
                            <input type="hidden" name="newStatus" value="cancelled">
                            <button type="submit" class="btn btn-danger btn-sm">Cancel</button>
                        </form>
                    </td>
                </tr>
            <%
                    }
                    if (!anyPending) {
            %>
                <tr><td colspan="6">No pending appointments right now.</td></tr>
            <%
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                } finally {
                    if (conn != null) {
                        try { conn.close(); } catch (Exception e) { e.printStackTrace(); }
                    }
                }
            %>
        </table>
    </div>

</div></div>
</body>
</html>
