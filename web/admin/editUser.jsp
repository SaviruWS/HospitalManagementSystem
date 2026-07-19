<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="util.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../includes/sidebar.jsp" %>

    <div class="page-header">
        <div>
            <h2>Edit User</h2>
            <p>Update account details</p>
        </div>
        <div class="welcome-badge">Welcome, <strong><%= fullName %></strong></div>
    </div>

    <div class="card" style="max-width: 480px;">
        <%
            String error = request.getParameter("error");
            if (error != null) {
        %>
            <div class="alert alert-error">Update failed. Email may already be in use by another account.</div>
        <%
            }

            String userIdParam = request.getParameter("userId");
            Connection conn = null;
            String currentRole = "";

            try {
                conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement("SELECT * FROM users WHERE user_id = ?");
                stmt.setInt(1, Integer.parseInt(userIdParam));
                ResultSet rs = stmt.executeQuery();

                if (rs.next()) {
                    currentRole = rs.getString("role");
        %>
            <form action="../UpdateUserServlet" method="post">
                <input type="hidden" name="userId" value="<%= userIdParam %>">
                <input type="hidden" name="currentRole" value="<%= currentRole %>">

                <label>Full Name</label>
                <input type="text" name="fullName" value="<%= rs.getString("full_name") %>" required>

                <label>Email</label>
                <input type="email" name="email" value="<%= rs.getString("email") %>" required>

                <label>Contact Number</label>
                <input type="text" name="contactNumber" value="<%= rs.getString("contact_number") %>" required>

                <label>Role</label>
                <input type="text" value="<%= currentRole %>" disabled style="background:#f1f5f9; text-transform:capitalize;">
                <p style="font-size:12.5px; color:var(--color-text-muted); margin-top:-8px;">Role cannot be changed after account creation.</p>

                <%
                    if ("doctor".equals(currentRole)) {
                        PreparedStatement doctorStmt = conn.prepareStatement("SELECT * FROM doctors WHERE user_id = ?");
                        doctorStmt.setInt(1, Integer.parseInt(userIdParam));
                        ResultSet doctorRs = doctorStmt.executeQuery();
                        if (doctorRs.next()) {
                %>
                    <label>Specialization</label>
                    <input type="text" name="specialization" value="<%= doctorRs.getString("specialization") %>">

                    <label>Consultation Fee (Rs.)</label>
                    <input type="number" step="0.01" name="consultationFee" value="<%= doctorRs.getDouble("consultation_fee") %>">
                <%
                        }
                    }
                %>

                <br><br>
                <button type="submit" class="btn" style="width:100%;">Save Changes</button>
            </form>
        <%
                } else {
        %>
            <p>User not found.</p>
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
        <br>
        <a href="manageUsers.jsp">Back to Manage Users</a>
    </div>

</div></div>
</body>
</html>
