<%-- 
    sidebar.jsp - included at the top of every protected dashboard page.
    Expects to be included from within /admin, /doctor, /nurse, /receptionist, or /patient folders.
    Usage: <%@ include file="../includes/sidebar.jsp" %>  then close </div></div> at end of page.
--%>
<%
    String role = (String) session.getAttribute("role");
    String fullName = (String) session.getAttribute("fullName");
    if (role == null) role = "";
%>
<!DOCTYPE html>
<html>
<head>
    <title>NovaCare Hospital Management System</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/theme.css">
</head>
<body>
<div class="app-layout">
    <div class="sidebar">
        <div class="brand">
            <div class="brand-logo-box">
                <img src="<%= request.getContextPath() %>/images/logo.jpg" alt="NovaCare Logo">
            </div>
        </div>
        <nav>
            <% if ("admin".equals(role)) { %>
                <a href="<%= request.getContextPath() %>/admin/dashboard.jsp">Dashboard</a>
                <a href="<%= request.getContextPath() %>/admin/addStaff.jsp">Add Staff</a>
                <a href="<%= request.getContextPath() %>/admin/manageUsers.jsp">Manage Users</a>
                <a href="<%= request.getContextPath() %>/receptionist/patientList.jsp">Patient List</a>
                <a href="<%= request.getContextPath() %>/receptionist/allAppointments.jsp">All Appointments</a>
                <a href="<%= request.getContextPath() %>/receptionist/pendingAppointments.jsp">Pending Appointments</a>
            <% } else if ("doctor".equals(role)) { %>
                <a href="dashboard.jsp">Dashboard</a>
                <a href="manageSchedule.jsp">Manage Schedule</a>
                <a href="myAppointments.jsp">My Appointments</a>
            <% } else if ("nurse".equals(role)) { %>
                <a href="dashboard.jsp">Dashboard</a>
            <% } else if ("receptionist".equals(role)) { %>
                <a href="dashboard.jsp">Dashboard</a>
                <a href="registerPatient.jsp">Register Patient</a>
                <a href="patientList.jsp">Patient List</a>
                <a href="bookAppointment.jsp">Book Appointment</a>
                <a href="pendingAppointments.jsp">Pending Appointments</a>
                <a href="allAppointments.jsp">All Appointments</a>
            <% } else if ("patient".equals(role)) { %>
                <a href="dashboard.jsp">Dashboard</a>
                <a href="bookAppointment.jsp">Book Appointment</a>
                <a href="myAppointments.jsp">My Appointments</a>
            <% } %>
            <div class="logout-link">
                <a href="<%= request.getContextPath() %>/LogoutServlet">Logout</a>
            </div>
        </nav>
    </div>
    <div class="main-content">
