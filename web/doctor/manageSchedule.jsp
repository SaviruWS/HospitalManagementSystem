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
            <div class="alert alert-error">Something went wrong. Please check your inputs.</div>
        <%
            } else if (success != null) {
                if ("deleted".equals(success)) {
        %>
            <div class="alert alert-success">Schedule slot removed successfully.</div>
        <%
                } else if (success.startsWith("cancelled")) {
                    String count = success.substring("cancelled".length());
        %>
            <div class="alert alert-success">Slot removed. <%= count %> affected appointment(s) were cancelled and patients notified by email.</div>
        <%
                } else {
        %>
            <div class="alert alert-success">Schedule slot added successfully!</div>
        <%
                }
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
                <th>Booked / Max</th>
                <th>Action</th>
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
                        "SELECT ds.schedule_id, ds.available_date, ds.start_time, ds.end_time, ds.max_patients, " +
                        "(SELECT COUNT(*) FROM appointments a WHERE a.schedule_id = ds.schedule_id AND a.status != 'cancelled') AS booked_count " +
                        "FROM doctor_schedule ds WHERE ds.doctor_id = ? AND ds.available_date >= CURDATE() AND ds.status = 'active' " +
                        "ORDER BY ds.available_date, ds.start_time");
                    scheduleStmt.setInt(1, doctorId);
                    ResultSet rs = scheduleStmt.executeQuery();

                    boolean any = false;
                    while (rs.next()) {
                        any = true;
                        int scheduleId = rs.getInt("schedule_id");
                        int booked = rs.getInt("booked_count");
                        int max = rs.getInt("max_patients");
                        boolean hasBookings = booked > 0;
            %>
                <tr>
                    <td><%= rs.getDate("available_date") %></td>
                    <td><%= rs.getTime("start_time") %></td>
                    <td><%= rs.getTime("end_time") %></td>
                    <td><%= booked %> / <%= max %></td>
                    <td>
                        <form action="../DeleteScheduleServlet" method="post" style="display:inline;"
                              onsubmit="return confirm('<%= hasBookings
                                  ? "This slot has " + booked + " booked appointment(s). Deleting it will CANCEL those appointments and notify the patients by email. Continue?"
                                  : "Delete this schedule slot?" %>');">
                            <input type="hidden" name="scheduleId" value="<%= scheduleId %>">
                            <button type="submit" class="btn btn-danger btn-sm">
                                <%= hasBookings ? "Cancel Slot" : "Delete" %>
                            </button>
                        </form>
                    </td>
                </tr>
            <%
                    }
                    if (!any) {
            %>
                <tr><td colspan="5">No upcoming schedule slots yet.</td></tr>
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
