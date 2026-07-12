<%@page contentType="text/html" pageEncoding="UTF-8"%>
<html>
    <body>
        <h1>Admin Dashboard</h1>

    <p>Welcome, <%= session.getAttribute("fullName") %></p>
    <a href="addStaff.jsp">Add Staff Member</a>
    <a href="../LogoutServlet">Logout</a>    
    
    </body>
</html>
