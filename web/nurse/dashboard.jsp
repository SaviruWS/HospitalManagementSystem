<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../includes/sidebar.jsp" %>
<div class="patient-dashboard">

    <section class="patient-hero">
        <div class="patient-hero-content">
            <span class="patient-hero-label">NURSE PORTAL</span>
            <h1>Welcome back, <%= fullName %></h1>
            <p>
                Manage the day's patient queue, record vitals, and keep
                today's care running smoothly.
            </p>
            <div class="patient-hero-actions">
                <a href="queueStatus.jsp" class="patient-primary-btn">Today's Queue</a>
                <a href="recordVitals.jsp" class="patient-secondary-btn">Record Vitals</a>
            </div>
        </div>
        <div class="nurse-hero-image"></div>
    </section>

    <section class="patient-section">
        <div class="patient-section-heading">
            <div>
                <h2>Quick Access</h2>
                <p>Patient care and daily operations</p>
            </div>
        </div>
        <div class="patient-action-grid">
            <a href="queueStatus.jsp" class="patient-action-card">
                <div class="patient-action-icon icon-amber">⚑</div>
                <div>
                    <h3>Today's Queue</h3>
                    <p>Update patient status and track doctor arrivals.</p>
                </div>
                <span class="patient-arrow">→</span>
            </a>
            <a href="recordVitals.jsp" class="patient-action-card">
                <div class="patient-action-icon appointment-icon">+</div>
                <div>
                    <h3>Record Vitals</h3>
                    <p>Log blood pressure, temperature, pulse, and weight.</p>
                </div>
                <span class="patient-arrow">→</span>
            </a>
            <a href="searchPatientVitals.jsp" class="patient-action-card">
                <div class="patient-action-icon icon-purple">⌕</div>
                <div>
                    <h3>Search Patient Vitals</h3>
                    <p>Look up a patient's recorded vitals history.</p>
                </div>
                <span class="patient-arrow">→</span>
            </a>
            <a href="appointments.jsp" class="patient-action-card">
                <div class="patient-action-icon history-icon">✓</div>
                <div>
                    <h3>Today's Appointments</h3>
                    <p>View all confirmed appointments scheduled for today.</p>
                </div>
                <span class="patient-arrow">→</span>
            </a>
        </div>
    </section>

    <section class="patient-info-banner">
        <div class="patient-info-content">
            <span class="patient-info-label">NOVACARE PATIENT CARE</span>
            <h2>Keeping every patient's visit on track.</h2>
            <p>
                From check-in to consultation, stay on top of today's
                patient flow with real-time queue updates.
            </p>
        </div>
        <a href="queueStatus.jsp" class="patient-info-btn">View Queue</a>
    </section>

</div>
</div>
</div>
</body>
</html>
