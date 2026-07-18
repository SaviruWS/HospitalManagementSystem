<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../includes/sidebar.jsp" %>

    <div class="page-header">
        <div>
            <h2>Receptionist Dashboard</h2>
            <p>Register patients, book appointments, and manage confirmations</p>
        </div>
        <div class="welcome-badge">Welcome, <strong><%= fullName %></strong></div>
    </div>

    <div class="card">
        <p>Use the sidebar to register a new patient, book a manual appointment, or review pending online bookings.</p>
        <a href="registerPatient.jsp" class="btn">Register New Patient</a>
        <a href="bookAppointment.jsp" class="btn btn-accent">Book Appointment (Manual)</a>
        <a href="pendingAppointments.jsp" class="btn" style="background: var(--color-navy-light);">Pending Appointments</a>
    </div>

</div></div>
</body>
</html>
