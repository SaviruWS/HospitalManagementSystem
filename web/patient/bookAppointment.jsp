<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="util.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../includes/sidebar.jsp" %>

    <div class="page-header">
        <div>
            <h2>Book Appointment Online</h2>
            <p>Select a doctor and an available time slot</p>
        </div>
        <div class="welcome-badge">Welcome, <strong><%= fullName %></strong></div>
    </div>

    <div class="card">
        <%
            String error = request.getParameter("error");
            String success = request.getParameter("success");
            if (error != null) {
        %>
            <div class="alert alert-error">Booking failed. The slot may be full or invalid.</div>
        <%
            } else if (success != null) {
        %>
            <div class="alert alert-success">Appointment request submitted! It is pending confirmation — you'll receive an email once confirmed.</div>
        <%
            }
        %>

        <form method="get" action="bookAppointment.jsp">
            <label>Select Doctor</label>
            <select name="doctorId" onchange="this.form.submit()" required>
                <option value="">-- Select Doctor --</option>
                <%
                    Connection conn = null;
                    try {
                        conn = DBConnection.getConnection();
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
                         <%= doctorRs.getString("full_name") %> (<%= doctorRs.getString("specialization") %>)
                    </option>
                <%
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                %>
            </select>
            <noscript><button type="submit" class="btn">Load Schedule</button></noscript>
        </form>
    </div>

    <%
        String doctorIdParam = request.getParameter("doctorId");

        if (doctorIdParam != null && !doctorIdParam.isEmpty()) {
    %>
        <div class="card">
            <h3 style="margin-top:0; color: var(--color-navy);">Available Slots</h3>
            <form action="../BookAppointmentOnlineServlet" method="post">
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
                                "FROM doctor_schedule ds WHERE ds.doctor_id = ? AND ds.available_date >= CURDATE() AND ds.status = 'active' " +
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
                            <td>
                                <% if (isFull) { %>
                                    <span class="badge badge-cancelled"><%= booked %> / <%= max %> FULL</span>
                                <% } else { %>
                                    <span class="badge badge-confirmed"><%= booked %> / <%= max %></span>
                                <% } %>
                            </td>
                            <td>
                                <% if (!isFull) { %>
                                    <input type="radio" name="scheduleId" value="<%= scheduleId %>" required>
                                <% } else { %>
                                    <span style="color: var(--color-text-muted); font-style: italic;">Unavailable</span>
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
                <div class="alert alert-info" style="margin-top:15px;">
                    Note: Online bookings require confirmation from hospital staff. You'll receive an email once your appointment is confirmed.
                </div>
                <button type="submit" class="btn">Request Appointment</button>
            </form>
        </div>
    <%
        } else if (conn != null) {
            try { conn.close(); } catch (Exception e) { e.printStackTrace(); }
        }
    %>

</div></div>
</body>
</html>
