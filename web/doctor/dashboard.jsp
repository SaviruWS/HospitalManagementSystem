<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../includes/sidebar.jsp" %>
<div class="patient-dashboard">

    <section class="patient-hero">
        <div class="patient-hero-content">
            <span class="patient-hero-label">DOCTOR PORTAL</span>
            <h1>Welcome back,  <%= fullName %></h1>
            <p>
                Manage your availability and review your appointments,
                all from one place at NovaCare Private Hospital.
            </p>
            <div class="patient-hero-actions">
                <a href="manageSchedule.jsp" class="patient-primary-btn">Manage My Schedule</a>
                <a href="myAppointments.jsp" class="patient-secondary-btn">View My Appointments</a>
            </div>
        </div>
        <div class="doctor-hero-image"></div>
    </section>

    <section class="patient-section">
        <div class="patient-section-heading">
            <div>
                <h2>Quick Access</h2>
                <p>Manage your schedule and appointments</p>
            </div>
        </div>
        <div class="patient-action-grid">
            <a href="manageSchedule.jsp" class="patient-action-card">
                <div class="patient-action-icon appointment-icon">+</div>
                <div>
                    <h3>Manage Schedule</h3>
                    <p>Add new availability slots or cancel existing ones.</p>
                </div>
                <span class="patient-arrow">→</span>
            </a>
            <a href="myAppointments.jsp" class="patient-action-card">
                <div class="patient-action-icon history-icon">✓</div>
                <div>
                    <h3>My Appointments</h3>
                    <p>View all appointments booked with you.</p>
                </div>
                <span class="patient-arrow">→</span>
            </a>
        </div>
    </section>

    <section class="patient-info-banner">
        <div class="patient-info-content">
            <span class="patient-info-label">NOVACARE FOR DOCTORS</span>
            <h2>Your schedule, always in your hands.</h2>
            <p>
                Set your own availability and let patients book directly —
                no back-and-forth needed to manage your channeling sessions.
            </p>
        </div>
        <a href="manageSchedule.jsp" class="patient-info-btn">Manage Schedule</a>
    </section>

</div>
</div>
</div>
</body>
</html>
