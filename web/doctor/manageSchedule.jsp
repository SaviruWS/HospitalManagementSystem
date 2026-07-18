<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="util.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../includes/sidebar.jsp" %>

    <div class="page-header">
        <div>
            <h2>Manage My Schedule</h2>
            <p>Add new availability slots and view your upcoming schedule</p>
        </div>
        <div class="welcome-badge">Dr. <strong><%= fullName %></strong></div>
    </div>

    <div class="card" style="max-width: 500px;">
        <%
            String error = request.getParameter("error");
            String success = request.getParameter("success");
            if (error != null) {
        %>
            <div class="alert alert-error">Failed to add schedule. Please check your inputs.</div>
        <%
            } else if (success != null) {
        %>
            <div class="alert alert-success">Schedule slot added successfully!</div>
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

            <br><br>
            <button type="submit" class="btn" style="width:100%;">Add Schedule Slot</button>
        </form>
    </div>

    <div class="card">
        <h3 style="margin-top:0; color: var(--color-navy);">My Upcoming Schedule</h3>
        <table>
            <tr>
                <th>Date</th>
                <th>Start Time</th>
                <th>End Time</th>
                <th>Max Patients</th>
            </tr>
            <%
                Integer userId = (Integer) session.getAttribute("userId");
                int doctorId = -1;

                Connection conn = null;
                try {
                    conn = DBConnection.getConnection();

                    PreparedStatement doctorLookup = conn.prepareStatement(
                        "SELECT doctor_id FROM doctors WHERE user_id = ?");
                    doctorLookup.setInt(1, userId);
                    ResultSet doctorRs = doctorLookup.executeQuery();
                    if (doctorRs.next()) {
                        doctorId = doctorRs.getInt("doctor_id");
                    }

                    PreparedStatement scheduleStmt = conn.prepareStatement(
                        "SELECT available_date, start_time, end_time, max_patients " +
                        "FROM doctor_schedule WHERE doctor_id = ? AND available_date >= CURDATE() " +
                        "ORDER BY available_date, start_time");
                    scheduleStmt.setInt(1, doctorId);
                    ResultSet rs = scheduleStmt.executeQuery();

                    boolean any = false;
                    while (rs.next()) {
                        any = true;
            %>
                <tr>
                    <td><%= rs.getDate("available_date") %></td>
                    <td><%= rs.getTime("start_time") %></td>
                    <td><%= rs.getTime("end_time") %></td>
                    <td><%= rs.getInt("max_patients") %></td>
                </tr>
            <%
                    }
                    if (!any) {
            %>
                <tr><td colspan="4">No upcoming schedule slots yet.</td></tr>
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
