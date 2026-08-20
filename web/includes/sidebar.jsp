<%@page contentType="text/html" pageEncoding="UTF-8"%>



<%-- 
    sidebar.jsp - included at the top of every protected dashboard page.
    Light theme redesign: white sidebar, icon+label nav, active-page highlighting.
    Usage: <%@ include file="../includes/sidebar.jsp" %>  then close </div></div></div> at end of page.
--%>
<%
    String role = (String) session.getAttribute("role");
    String fullName = (String) session.getAttribute("fullName");
    if (role == null) role = "";

    // Used to highlight the current page's nav link
    String currentPage = request.getRequestURI();
    if (currentPage == null) currentPage = "";
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
            <img src="<%= request.getContextPath() %>/images/logo.jpg" alt="NovaCare Logo" class="brand-logo">
            <span class="brand-tagline">Your Health, Our Priority</span>
        </div>
        <nav>
            <% if ("admin".equals(role)) { %>
                <a href="<%= request.getContextPath() %>/admin/dashboard.jsp" class="<%= currentPage.contains("admin/dashboard.jsp") ? "active" : "" %>"><span class="nav-icon">🏠</span>Dashboard</a>
                <a href="<%= request.getContextPath() %>/admin/addStaff.jsp" class="<%= currentPage.contains("addStaff.jsp") ? "active" : "" %>"><span class="nav-icon">👥</span>Add Staff</a>
                <a href="<%= request.getContextPath() %>/admin/manageUsers.jsp" class="<%= currentPage.contains("manageUsers.jsp") ? "active" : "" %>"><span class="nav-icon">⚙️</span>Manage Users</a>
                <a href="<%= request.getContextPath() %>/receptionist/patientList.jsp" class="<%= currentPage.contains("patientList.jsp") ? "active" : "" %>"><span class="nav-icon">📋</span>Patient List</a>
                <a href="<%= request.getContextPath() %>/receptionist/allAppointments.jsp" class="<%= currentPage.contains("allAppointments.jsp") ? "active" : "" %>"><span class="nav-icon">📅</span>All Appointments</a>
                <a href="<%= request.getContextPath() %>/receptionist/pendingAppointments.jsp" class="<%= currentPage.contains("pendingAppointments.jsp") ? "active" : "" %>"><span class="nav-icon">⏳</span>Pending Appointments</a>
                <a href="<%= request.getContextPath() %>/receptionist/billList.jsp" class="<%= currentPage.contains("billList.jsp") ? "active" : "" %>"><span class="nav-icon">💳</span>Bill History</a>
            <% } else if ("doctor".equals(role)) { %>
                <a href="dashboard.jsp" class="<%= currentPage.contains("doctor/dashboard.jsp") ? "active" : "" %>"><span class="nav-icon">🏠</span>Dashboard</a>
                <a href="manageSchedule.jsp" class="<%= currentPage.contains("manageSchedule.jsp") ? "active" : "" %>"><span class="nav-icon">🗓️</span>Manage Schedule</a>
                <a href="myAppointments.jsp" class="<%= currentPage.contains("myAppointments.jsp") ? "active" : "" %>"><span class="nav-icon">📅</span>My Appointments</a>
            <% } else if ("nurse".equals(role)) { %>
                <a href="dashboard.jsp" class="<%= currentPage.contains("nurse/dashboard.jsp") ? "active" : "" %>"><span class="nav-icon">🏠</span>Dashboard</a>
                <a href="queueStatus.jsp" class="<%= currentPage.contains("queueStatus.jsp") ? "active" : "" %>"><span class="nav-icon">🚦</span>Today's Queue</a>
                <a href="recordVitals.jsp" class="<%= currentPage.contains("recordVitals.jsp") ? "active" : "" %>"><span class="nav-icon">💉</span>Record Vitals</a>
                <a href="searchPatientVitals.jsp" class="<%= currentPage.contains("searchPatientVitals.jsp") ? "active" : "" %>"><span class="nav-icon">🔍</span>Search Vitals</a>
                <a href="appointments.jsp" class="<%= currentPage.contains("nurse/appointments.jsp") ? "active" : "" %>"><span class="nav-icon">📅</span>Today's Appointments</a>
            <% } else if ("receptionist".equals(role)) { %>
                <a href="dashboard.jsp" class="<%= currentPage.contains("receptionist/dashboard.jsp") ? "active" : "" %>"><span class="nav-icon">🏠</span>Dashboard</a>
                <a href="registerPatient.jsp" class="<%= currentPage.contains("registerPatient.jsp") ? "active" : "" %>"><span class="nav-icon">📝</span>Register Patient</a>
                <a href="patientList.jsp" class="<%= currentPage.contains("patientList.jsp") ? "active" : "" %>"><span class="nav-icon">📋</span>Patient List</a>
                <a href="doctorSearch.jsp" class="<%= currentPage.contains("doctorSearch.jsp") ? "active" : "" %>"><span class="nav-icon">🔎</span>Find a Doctor</a>
                <a href="bookAppointment.jsp" class="<%= currentPage.contains("receptionist/bookAppointment.jsp") ? "active" : "" %>"><span class="nav-icon">📅</span>Book Appointment</a>
                <a href="pendingAppointments.jsp" class="<%= currentPage.contains("pendingAppointments.jsp") ? "active" : "" %>"><span class="nav-icon">⏳</span>Pending Appointments</a>
                <a href="allAppointments.jsp" class="<%= currentPage.contains("allAppointments.jsp") ? "active" : "" %>"><span class="nav-icon">📖</span>All Appointments</a>
                <a href="generateBill.jsp" class="<%= currentPage.contains("generateBill.jsp") ? "active" : "" %>"><span class="nav-icon">🧾</span>Generate Bill</a>
                <a href="billList.jsp" class="<%= currentPage.contains("billList.jsp") ? "active" : "" %>"><span class="nav-icon">💳</span>Bill History</a>
            <% } else if ("patient".equals(role)) { %>
                <a href="dashboard.jsp" class="<%= currentPage.contains("patient/dashboard.jsp") ? "active" : "" %>"><span class="nav-icon">🏠</span>Dashboard</a>
                <a href="bookAppointment.jsp" class="<%= currentPage.contains("patient/bookAppointment.jsp") ? "active" : "" %>"><span class="nav-icon">📅</span>Book Appointment</a>
                <a href="myAppointments.jsp" class="<%= currentPage.contains("myAppointments.jsp") ? "active" : "" %>"><span class="nav-icon">📖</span>My Appointments</a>
            <% } %>
            <div class="logout-link">
                <a href="<%= request.getContextPath() %>/LogoutServlet"><span class="nav-icon">↩️</span>Logout</a>
            </div>
        </nav>
    </div>
    <div class="main-content">