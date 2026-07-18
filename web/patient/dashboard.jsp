<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../includes/sidebar.jsp" %>

    <div class="page-header">
        <div>
            <h2>Patient Dashboard</h2>
            <p>Book appointments and track your visit history</p>
        </div>
        <div class="welcome-badge">Welcome, <strong><%= fullName %></strong></div>
    </div>

    <div class="card">
        <p>Use the sidebar to book a new appointment or view your appointment history.</p>
        <a href="bookAppointment.jsp" class="btn">Book Appointment Online</a>
    </div>

</div></div>
</body>
</html>
