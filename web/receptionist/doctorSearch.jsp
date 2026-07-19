<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="util.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../includes/sidebar.jsp" %>

    <div class="page-header">
        <div>
            <h2>Find a Doctor</h2>
            <p>Search by name or specialization to check availability</p>
        </div>
        <div class="welcome-badge">Welcome, <strong><%= fullName %></strong></div>
    </div>

    <div class="card">
        <form method="get" action="doctorSearch.jsp">
            <label>Search by Name or Specialization</label>
            <div style="display:flex; gap:10px;">
                <input type="text" name="q" style="flex:1;" placeholder="e.g. Perera, or Cardiology"
                       value="<%= request.getParameter("q") != null ? request.getParameter("q") : "" %>">
                <button type="submit" class="btn">Search</button>
            </div>
        </form>
    </div>

    <div class="card">
        <table>
            <tr>
                <th>Doctor</th>
                <th>Specialization</th>
                <th>Fee (Rs.)</th>
                <th>Next Available Slot</th>
                <th>Action</th>
            </tr>
            <%
                String searchQuery = request.getParameter("q");
                Connection conn = null;
                try {
                    conn = DBConnection.getConnection();

                    String sql = "SELECT d.doctor_id, u.full_name, d.specialization, d.consultation_fee, " +
                                 "(SELECT MIN(CONCAT(ds.available_date, ' ', ds.start_time)) " +
                                 " FROM doctor_schedule ds " +
                                 " WHERE ds.doctor_id = d.doctor_id AND ds.status = 'active' AND ds.available_date >= CURDATE() " +
                                 " AND (SELECT COUNT(*) FROM appointments a WHERE a.schedule_id = ds.schedule_id AND a.status != 'cancelled') < ds.max_patients" +
                                 ") AS next_slot " +
                                 "FROM doctors d JOIN users u ON d.user_id = u.user_id ";

                    PreparedStatement stmt;
                    if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                        sql += "WHERE u.full_name LIKE ? OR d.specialization LIKE ? ORDER BY u.full_name";
                        stmt = conn.prepareStatement(sql);
                        String likeTerm = "%" + searchQuery.trim() + "%";
                        stmt.setString(1, likeTerm);
                        stmt.setString(2, likeTerm);
                    } else {
                        sql += "ORDER BY u.full_name";
                        stmt = conn.prepareStatement(sql);
                    }

                    ResultSet rs = stmt.executeQuery();

                    boolean any = false;
                    while (rs.next()) {
                        any = true;
                        int doctorId = rs.getInt("doctor_id");
                        String nextSlot = rs.getString("next_slot");
            %>
                <tr>
                    <td>Dr. <%= rs.getString("full_name") %></td>
                    <td><%= rs.getString("specialization") %></td>
                    <td><%= rs.getBigDecimal("consultation_fee") %></td>
                    <td>
                        <% if (nextSlot != null) { %>
                            <span class="badge badge-confirmed"><%= nextSlot %></span>
                        <% } else { %>
                            <span class="badge badge-cancelled">No slots available</span>
                        <% } %>
                    </td>
                    <td>
                        <a href="bookAppointment.jsp?doctorId=<%= doctorId %>" class="btn btn-sm">View Schedule &amp; Book</a>
                    </td>
                </tr>
            <%
                    }
                    if (!any) {
            %>
                <tr><td colspan="5">No doctors found<%= (searchQuery != null && !searchQuery.trim().isEmpty()) ? " matching \"" + searchQuery + "\"." : "." %></td></tr>
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

    <div class="alert alert-info">
        Tip: If the patient isn't registered yet, use <a href="registerPatient.jsp">Register New Patient</a> first, then come back here to book.
    </div>

</div></div>
</body>
</html>
