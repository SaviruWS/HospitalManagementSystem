<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../includes/sidebar.jsp" %>
<div class="patient-dashboard">

    <section class="patient-hero">
        <div class="patient-hero-content">
            <span class="patient-hero-label">RECEPTIONIST PORTAL</span>
            <h1>Welcome back, <%= fullName %></h1>
            <p>
                Register patients, book appointments, and manage the
                front desk — all from one place.
            </p>
            <div class="patient-hero-actions">
                <a href="registerPatient.jsp" class="patient-primary-btn">Register Patient</a>
                <a href="bookAppointment.jsp" class="patient-secondary-btn">Book Appointment</a>
            </div>
        </div>
        <div class="receptionist-hero-image"></div>
    </section>

    <section class="patient-section">
        <div class="patient-section-heading">
            <div>
                <h2>Quick Access</h2>
                <p>Front desk and patient services</p>
            </div>
        </div>
        <div class="patient-action-grid">
            <a href="registerPatient.jsp" class="patient-action-card">
                <div class="patient-action-icon appointment-icon">+</div>
                <div>
                    <h3>Register Patient</h3>
                    <p>Create a new patient account on their behalf.</p>
                </div>
                <span class="patient-arrow">→</span>
            </a>
            <a href="patientList.jsp" class="patient-action-card">
                <div class="patient-action-icon icon-slate">▤</div>
                <div>
                    <h3>Patient List</h3>
                    <p>Search and browse all registered patients.</p>
                </div>
                <span class="patient-arrow">→</span>
            </a>
            <a href="doctorSearch.jsp" class="patient-action-card">
                <div class="patient-action-icon icon-purple">⌕</div>
                <div>
                    <h3>Find a Doctor</h3>
                    <p>Check doctor availability by name or specialization.</p>
                </div>
                <span class="patient-arrow">→</span>
            </a>
            <a href="bookAppointment.jsp" class="patient-action-card">
                <div class="patient-action-icon history-icon">✓</div>
                <div>
                    <h3>Book Appointment</h3>
                    <p>Book a manual appointment on behalf of a patient.</p>
                </div>
                <span class="patient-arrow">→</span>
            </a>
            <a href="pendingAppointments.jsp" class="patient-action-card">
                <div class="patient-action-icon icon-amber">⚑</div>
                <div>
                    <h3>Pending Appointments</h3>
                    <p>Review and confirm online booking requests.</p>
                </div>
                <span class="patient-arrow">→</span>
            </a>
            <a href="allAppointments.jsp" class="patient-action-card">
                <div class="patient-action-icon icon-blue">▤</div>
                <div>
                    <h3>All Appointments</h3>
                    <p>Complete view of every appointment in the system.</p>
                </div>
                <span class="patient-arrow">→</span>
            </a>
            <a href="generateBill.jsp" class="patient-action-card">
                <div class="patient-action-icon icon-green">$</div>
                <div>
                    <h3>Generate Bill</h3>
                    <p>Create an invoice for a patient's appointment.</p>
                </div>
                <span class="patient-arrow">→</span>
            </a>
            <a href="billList.jsp" class="patient-action-card">
                <div class="patient-action-icon icon-red">$</div>
                <div>
                    <h3>Bill History</h3>
                    <p>View and reprint previously generated invoices.</p>
                </div>
                <span class="patient-arrow">→</span>
            </a>
        </div>
    </section>

    <section class="patient-info-banner">
        <div class="patient-info-content">
            <span class="patient-info-label">NOVACARE FRONT DESK</span>
            <h2>Every patient, taken care of.</h2>
            <p>
                From walk-ins to phone bookings, manage the full patient
                journey — registration, scheduling, and billing — in one system.
            </p>
        </div>
        <a href="doctorSearch.jsp" class="patient-info-btn">Find a Doctor</a>
    </section>

</div>
</div>
</div>
</body>
</html>
