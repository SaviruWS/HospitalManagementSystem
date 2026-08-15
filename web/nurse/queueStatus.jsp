<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="util.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../includes/sidebar.jsp" %>

    <div class="page-header">
        <div>
            <h2>Today's Queue</h2>
            <p>Update patient status as they arrive and move through their visit</p>
        </div>
        <div class="welcome-badge">Welcome, <strong><%= fullName %></strong></div>
    </div>

    <div class="card">
        <%
            String success = request.getParameter("success");
            if (success != null) {
        %>
            <div class="alert alert-success">Status updated.</div>
        <%
            }
        %>
        <table>
            <tr>
                <th>Time</th>
                <th>Patient</th>
                <th>Doctor</th>
                <th>Status</th>
                <th>Update</th>
            </tr>
            <%
                Connection conn = null;
                try {
                    conn = DBConnection.getConnection();
                    PreparedStatement stmt = conn.prepareStatement(
                        "SELECT a.appointment_id, up.full_name AS patient_name, ud.full_name AS doctor_name, " +
                        "a.appointment_time, a.visit_status " +
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
                        int appointmentId = rs.getInt("appointment_id");
                        String visitStatus = rs.getString("visit_status");
            %>
                <tr>
                    <td><%= rs.getTime("appointment_time") %></td>
                    <td><%= rs.getString("patient_name") %></td>
                    <td>Dr. <%= rs.getString("doctor_name") %></td>
                    <td>
                        <%
                            String badgeClass = "badge-pending";
                            String label = visitStatus.replace("_", " ");
                            if ("waiting".equals(visitStatus)) badgeClass = "badge-pending";
                            else if ("with_doctor".equals(visitStatus)) badgeClass = "badge-confirmed";
                            else if ("completed".equals(visitStatus)) badgeClass = "badge-completed";
                            else if ("not_arrived".equals(visitStatus)) badgeClass = "badge-cancelled";
                        %>
                        <span class="badge <%= badgeClass %>" style="text-transform:capitalize;"><%= label %></span>
                    </td>
                    <td>
                        <form action="../UpdateVisitStatusServlet" method="post" style="display:flex; gap:6px;">
                            <input type="hidden" name="appointmentId" value="<%= appointmentId %>">
                            <select name="visitStatus" style="margin:0; padding:6px;">
                                <option value="not_arrived" <%= "not_arrived".equals(visitStatus) ? "selected" : "" %>>Not Arrived</option>
                                <option value="waiting" <%= "waiting".equals(visitStatus) ? "selected" : "" %>>Waiting</option>
                                <option value="with_doctor" <%= "with_doctor".equals(visitStatus) ? "selected" : "" %>>With Doctor</option>
                                <option value="completed" <%= "completed".equals(visitStatus) ? "selected" : "" %>>Completed</option>
                            </select>
                            <button type="submit" class="btn btn-sm">Update</button>
                        </form>
                    </td>
                </tr>
            <%
                    }
                    if (!any) {
            %>
                <tr><td colspan="5">No confirmed appointments for today.</td></tr>
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
