<%@page contentType="text/html" pageEncoding="UTF-8"%>
<html>
    <body>
        <h1>Doctor Dashboard</h1>

    <p>Welcome, <%= session.getAttribute("fullName") %></p>
    <a href="manageSchedule.jsp">Manage My Schedule</a>
    <a href="../LogoutServlet">Logout</a>    
    
    </body>
</html>
