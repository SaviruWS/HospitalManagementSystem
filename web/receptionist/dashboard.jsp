<%@page contentType="text/html" pageEncoding="UTF-8"%>
<html>
    <body>
        <h1>Receptionist Dashboard</h1>

    <p>Welcome, <%= session.getAttribute("fullName") %></p>
    <a href="../LogoutServlet">Logout</a>    
    <a href="registerPatient.jsp">Register New Patient</a>
    <a href="bookAppointment.jsp">Book Appointment (Manual)</a>
    </body>
</html>
