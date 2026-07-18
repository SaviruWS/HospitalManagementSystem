<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="util.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Pending Appointments</title>
    <style>
        body { font-family: Arial, sans-serif; background: #f2f2f2; }
        .container {
            width: 850px;
            margin: 40px auto;
            padding: 30px;
            background: white;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        h2 { color: #2c3e50; }
        table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        th, td { padding: 10px; border: 1px solid #ddd; text-align: left; }
        th { background: #2c3e50; color: white; }
        .confirm-btn, .cancel-btn {
            padding: 6px 14px;
            border: none;
            border-radius: 4px;
            color: white;
            cursor: pointer;
            margin-right: 5px;
        }
        .confirm-btn { background: #27ae60; }
        .cancel-btn { background: #c0392b; }
        .success { color: green; }
        .error { color: red; }
    </style>
</head>
<body>
<div class="container">
    <h2>Pending Appointments (Online Bookings)</h2>

    <%
        String success = request.getParameter("success");
        String error = request.getParameter("error");
        if (success != null) {
    %>
        <p class="success">Appointment status updated and patient notified.</p>
    <%
        } else if (error != null) {
    %>
        <p class="error">Something went wrong. Please try again.</p>
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
                        <button type="submit" class="confirm-btn">Confirm</button>
                    </form>
                    <form action="../UpdateAppointmentStatusServlet" method="post" style="display:inline;">
                        <input type="hidden" name="appointmentId" value="<%= appointmentId %>">
                        <input type="hidden" name="newStatus" value="cancelled">
                        <button type="submit" class="cancel-btn">Cancel</button>
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
    <br>
    <a href="dashboard.jsp">Back to Dashboard</a>
</div>
</body>
</html>
