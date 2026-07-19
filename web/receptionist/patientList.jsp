<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="util.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../includes/sidebar.jsp" %>

    <div class="page-header">
        <div>
            <h2>Patient List</h2>
            <p>Search and browse all registered patients</p>
        </div>
        <div class="welcome-badge">Welcome, <strong><%= fullName %></strong></div>
    </div>

    <div class="card">
        <form method="get" action="patientList.jsp" style="display:flex; gap:10px; align-items:flex-end;">
            <div style="flex:1;">
                <label>Search by Name or Email</label>
                <input type="text" name="q" placeholder="e.g. Kasun, or kasun@gmail.com"
                       value="<%= request.getParameter("q") != null ? request.getParameter("q") : "" %>">
            </div>
            <button type="submit" class="btn" style="margin-bottom:12px;">Search</button>
            <% if (request.getParameter("q") != null && !request.getParameter("q").isEmpty()) { %>
                <a href="patientList.jsp" class="btn" style="background: var(--color-navy-light); margin-bottom:12px;">Clear</a>
            <% } %>
        </form>
    </div>

    <div class="card">
        <table>
            <tr>
                <th>Full Name</th>
                <th>Email</th>
                <th>Contact</th>
                <th>Date of Birth</th>
                <th>Gender</th>
                <th>Address</th>
            </tr>
            <%
                String searchQuery = request.getParameter("q");
                Connection conn = null;
                try {
                    conn = DBConnection.getConnection();

                    String sql = "SELECT u.full_name, u.email, u.contact_number, " +
                                 "p.date_of_birth, p.gender, p.address " +
                                 "FROM patients p JOIN users u ON p.user_id = u.user_id ";

                    PreparedStatement stmt;
                    if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                        sql += "WHERE u.full_name LIKE ? OR u.email LIKE ? ORDER BY u.full_name";
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
            %>
                <tr>
                    <td><%= rs.getString("full_name") %></td>
                    <td><%= rs.getString("email") %></td>
                    <td><%= rs.getString("contact_number") %></td>
                    <td><%= rs.getDate("date_of_birth") %></td>
                    <td style="text-transform:capitalize;"><%= rs.getString("gender") %></td>
                    <td><%= rs.getString("address") %></td>
                </tr>
            <%
                    }
                    if (!any) {
            %>
                <tr><td colspan="6">
                    <%= (searchQuery != null && !searchQuery.trim().isEmpty())
                        ? "No patients found matching \"" + searchQuery + "\"."
                        : "No patients registered yet." %>
                </td></tr>
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
