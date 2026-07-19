<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../includes/sidebar.jsp" %>

    <div class="page-header">
        <div>
            <h2>Nurse Dashboard</h2>
            <p>Record patient vitals and view today's appointments</p>
        </div>
        <div class="welcome-badge">Welcome, <strong><%= fullName %></strong></div>
    </div>

    <div class="card">
        <p>Use the sidebar to record a patient's vitals or view today's confirmed appointments.</p>
        <a href="recordVitals.jsp" class="btn">Record Vitals</a>
        <a href="appointments.jsp" class="btn btn-accent">Today's Appointments</a>
    </div>

</div></div>
</body>
</html>
