<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="util.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Manage My Schedule</title>
    <style>
        body { font-family: Arial, sans-serif; background: #f2f2f2; }
        .container {
            width: 600px;
            margin: 40px auto;
            padding: 30px;
            background: white;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        h2 { color: #2c3e50; }
        label { font-weight: bold; margin-top: 10px; display: block; }
        input[type=date], input[type=time], input[type=number] {
            width: 100%;
            padding: 8px;
            margin: 5px 0 12px 0;
            box-sizing: border-box;
            border: 1px solid #ccc;
            border-radius: 4px;
        }
        input[type=submit] {
            width: 100%;
            padding: 10px;
            background: #2c3e50;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { padding: 8px; border: 1px solid #ddd; text-align: left; }
        th { background: #2c3e50; color: white; }
        .error { color: red; }
        .success { color: green; }
    </style>
</head>
<body>
<div class="container">
    <h2>Manage My Schedule</h2>

    <%
        String error = request.getParameter("error");
        String success = request.getParameter("success");
        if (error != null) {
    %>
        <p class="error">Failed to add schedule. Please check your inputs.</p>
    <%
        } else if (success != null) {
    %>
        <p class="success">Schedule slot added successfully!</p>
    <%
        }
    %>

    <form action="../AddScheduleServlet" method="post">
        <label>Available Date</label>
        <input type="date" name="availableDate" required>

        <label>Start Time</label>
        <input type="time" name="startTime" required>

        <label>End Time</label>
        <input type="time" name="endTime" required>

        <label>Max Patients for This Slot</label>
        <input type="number" name="maxPatients" min="1" value="10" required>

        <input type="submit" value="Add Schedule Slot">
    </form>

    <h3>My Upcoming Schedule</h3>
    <table>
        <tr>
            <th>Date</th>
            <th>Start Time</th>
            <th>End Time</th>
            <th>Max Patients</th>
        </tr>
        <%
            // Get the logged-in doctor's doctor_id first (via their user_id from session)
            Integer userId = (Integer) session.getAttribute("userId");
            int doctorId = -1;

            Connection conn = null;
            try {
                conn = DBConnection.getConnection();

                // Look up doctor_id linked to this logged-in user
                PreparedStatement doctorLookup = conn.prepareStatement(
                    "SELECT doctor_id FROM doctors WHERE user_id = ?");
                doctorLookup.setInt(1, userId);
                ResultSet doctorRs = doctorLookup.executeQuery();
                if (doctorRs.next()) {
                    doctorId = doctorRs.getInt("doctor_id");
                }

                // Fetch this doctor's upcoming schedule (future dates only)
                PreparedStatement scheduleStmt = conn.prepareStatement(
                    "SELECT available_date, start_time, end_time, max_patients " +
                    "FROM doctor_schedule WHERE doctor_id = ? AND available_date >= CURDATE() " +
                    "ORDER BY available_date, start_time");
                scheduleStmt.setInt(1, doctorId);
                ResultSet rs = scheduleStmt.executeQuery();

                while (rs.next()) {
        %>
            <tr>
                <td><%= rs.getDate("available_date") %></td>
                <td><%= rs.getTime("start_time") %></td>
                <td><%= rs.getTime("end_time") %></td>
                <td><%= rs.getInt("max_patients") %></td>
            </tr>
        <%
                }
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                if (conn != null) conn.close();
            }
        %>
    </table>
    <br>
    <a href="dashboard.jsp">Back to Dashboard</a>
</div>
</body>
</html>
