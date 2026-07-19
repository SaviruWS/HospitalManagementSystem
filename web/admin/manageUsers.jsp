<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="util.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../includes/sidebar.jsp" %>

    <div class="page-header">
        <div>
            <h2>Manage Users</h2>
            <p>Edit or remove staff and patient accounts</p>
        </div>
        <div class="welcome-badge">Welcome, <strong><%= fullName %></strong></div>
    </div>

    <div class="card">
        <%
            String success = request.getParameter("success");
            String error = request.getParameter("error");
            if (success != null) {
        %>
            <div class="alert alert-success">
                <% if ("updated".equals(success)) { %>User updated successfully.
                <% } else if ("deleted".equals(success)) { %>User deleted successfully.
                <% } %>
            </div>
        <%
            } else if (error != null) {
        %>
            <div class="alert alert-error">
                <% if ("inuse".equals(error)) { %>
                    Cannot delete this user — they have existing appointments or records linked to their account.
                    Consider keeping the account instead of deleting it.
                <% } else { %>
                    Something went wrong. Please try again.
                <% } %>
            </div>
        <%
            }
        %>

        <table>
            <tr>
                <th>Full Name</th>
                <th>Email</th>
                <th>Role</th>
                <th>Contact</th>
                <th>Actions</th>
            </tr>
            <%
                Connection conn = null;
                try {
                    conn = DBConnection.getConnection();
                    PreparedStatement stmt = conn.prepareStatement(
                        "SELECT user_id, full_name, email, role, contact_number FROM users ORDER BY role, full_name");
                    ResultSet rs = stmt.executeQuery();

while (rs.next()) {
    int uid = rs.getInt("user_id");
    String userRole = rs.getString("role");
%>
    <tr>
        <td><%= rs.getString("full_name") %></td>
        <td><%= rs.getString("email") %></td>
        <td><span class="badge badge-confirmed" style="text-transform:capitalize;"><%= userRole %></span></td>
        <td><%= rs.getString("contact_number") %></td>
        <td>
            <a href="editUser.jsp?userId=<%= uid %>" class="btn btn-sm">Edit</a>
            <form action="../DeleteUserServlet" method="post" style="display:inline;"
                  onsubmit="return confirm('Are you sure you want to delete this user? This cannot be undone.');">
                <input type="hidden" name="userId" value="<%= uid %>">
                <button type="submit" class="btn btn-danger btn-sm">Delete</button>
            </form>
        </td>
    </tr>
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
