<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="util.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Book Appointment (Manual Channeling)</title>
    <style>
        body { font-family: Arial, sans-serif; background: #f2f2f2; }
        .container {
            width: 650px;
            margin: 40px auto;
            padding: 30px;
            background: white;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        h2 { color: #2c3e50; }
        label { font-weight: bold; margin-top: 10px; display: block; }
        select { width: 100%; padding: 8px; margin: 5px 0 12px 0; border: 1px solid #ccc; border-radius: 4px; }
        table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        th, td { padding: 8px; border: 1px solid #ddd; text-align: left; }
        th { background: #2c3e50; color: white; }
        input[type=submit] {
            padding: 10px 20px;
            background: #2c3e50;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        .error { color: red; }
        .success { color: green; }
        .full { color: #999; font-style: italic; }
    </style>
</head>
<body>
<div class="container">
    <h2>Book Appointment — Manual Channeling</h2>

    <%
        String error = request.getParameter("error");
        String success = request.getParameter("success");
        if (error != null) {
    %>
        <p class="error">Booking failed. The slot may be full or invalid.</p>
    <%
        } else if (success != null) {
    %>
        <p class="success">Appointment booked successfully!</p>
    <%
        }
    %>

    <!-- Step 1: Select patient and doctor. Doctor selection auto-submits to reload schedule slots below -->
    <form method="get" action="bookAppointment.jsp">
        <label>Select Patient</label>
        <select name="patientId" required>
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

        <label>Select Doctor</label>
        <select name="doctorId" onchange="this.form.submit()" required>
            <option value="">-- Select Doctor --</option>
            <%
                try {
                    PreparedStatement doctorStmt = conn.prepareStatement(
                        "SELECT d.doctor_id, u.full_name, d.specialization FROM doctors d " +
                        "JOIN users u ON d.user_id = u.user_id ORDER BY u.full_name");
                    ResultSet doctorRs = doctorStmt.executeQuery();
                    String selectedDoctorId = request.getParameter("doctorId");
                    while (doctorRs.next()) {
                        String did = String.valueOf(doctorRs.getInt("doctor_id"));
                        String selected = did.equals(selectedDoctorId) ? "selected" : "";
            %>
                <option value="<%= did %>" <%= selected %>>
                    Dr. <%= doctorRs.getString("full_name") %> (<%= doctorRs.getString("specialization") %>)
                </option>
            <%
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            %>
        </select>
        <noscript><input type="submit" value="Load Schedule"></noscript>
    </form>

    <%
        // Step 2: If a doctor is selected, show their available (not-yet-full) upcoming slots
        String doctorIdParam = request.getParameter("doctorId");
        String patientIdParam = request.getParameter("patientId");

        if (doctorIdParam != null && !doctorIdParam.isEmpty()) {
    %>
        <h3>Available Slots</h3>
        <form action="../BookAppointmentServlet" method="post">
            <input type="hidden" name="patientId" value="<%= patientIdParam != null ? patientIdParam : "" %>">
            <input type="hidden" name="doctorId" value="<%= doctorIdParam %>">

            <table>
                <tr>
                    <th>Date</th><th>Start</th><th>End</th><th>Booked / Max</th><th>Select</th>
                </tr>
                
                <%
                    try {
                        PreparedStatement slotStmt = conn.prepareStatement(
                            "SELECT ds.schedule_id, ds.available_date, ds.start_time, ds.end_time, ds.max_patients, " +
                            "(SELECT COUNT(*) FROM appointments a WHERE a.schedule_id = ds.schedule_id AND a.status != 'cancelled') AS booked_count " +
                            "FROM doctor_schedule ds WHERE ds.doctor_id = ? AND ds.available_date >= CURDATE() " +
                            "ORDER BY ds.available_date, ds.start_time");
                        
                        slotStmt.setInt(1, Integer.parseInt(doctorIdParam));
                        ResultSet slotRs = slotStmt.executeQuery();

                        boolean anySlots = false;
                        while (slotRs.next()) {
                            anySlots = true;
                            int scheduleId = slotRs.getInt("schedule_id");
                            int booked = slotRs.getInt("booked_count");
                            int max = slotRs.getInt("max_patients");
                            boolean isFull = booked >= max;
                %>
                    <tr>
                        <td><%= slotRs.getDate("available_date") %></td>
                        <td><%= slotRs.getTime("start_time") %></td>
                        <td><%= slotRs.getTime("end_time") %></td>
                        <td class="<%= isFull ? "full" : "" %>"><%= booked %> / <%= max %><%= isFull ? " (FULL)" : "" %></td>
                        <td>
                            <% if (!isFull) { %>
                                <input type="radio" name="scheduleId" value="<%= scheduleId %>" required>
                            <% } else { %>
                                <span class="full">Unavailable</span>
                            <% } %>
                        </td>
                    </tr>
                <%
                        }
                        if (!anySlots) {
                %>
                    <tr><td colspan="5">No upcoming schedule slots for this doctor.</td></tr>
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
            <input type="submit" value="Confirm Booking">
        </form>
    <%
        } else if (conn != null) {
            try { conn.close(); } catch (Exception e) { e.printStackTrace(); }
        }
    %>
    <br>
    <a href="dashboard.jsp">Back to Dashboard</a>
</div>
</body>
</html>
