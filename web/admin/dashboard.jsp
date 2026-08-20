<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../includes/sidebar.jsp" %>
<div class="patient-dashboard">

    <section class="patient-hero">
        <div class="patient-hero-content">
            <span class="patient-hero-label">ADMIN PORTAL</span>
            <h1>Welcome back, <%= fullName %></h1>
            <p>
                Manage staff accounts and oversee the full system —
                patients, appointments, and billing — from one place.
            </p>
            <div class="patient-hero-actions">
                <a href="addStaff.jsp" class="patient-primary-btn">Add Staff Member</a>
                <a href="manageUsers.jsp" class="patient-secondary-btn">Manage Users</a>
            </div>
        </div>
        <div class="admin-hero-image"></div>
    </section>

    <section class="patient-section">
        <div class="patient-section-heading">
            <div>
                <h2>Quick Access</h2>
                <p>System management and oversight</p>
            </div>
        </div>
        <div class="patient-action-grid">
            <a href="addStaff.jsp" class="patient-action-card">
                <div class="patient-action-icon appointment-icon">+</div>
                <div>
                    <h3>Add Staff</h3>
                    <p>Create receptionist, nurse, or doctor accounts.</p>
                </div>
                <span class="patient-arrow">→</span>
            </a>
            <a href="manageUsers.jsp" class="patient-action-card">
                <div class="patient-action-icon icon-slate">⚙</div>
                <div>
                    <h3>Manage Users</h3>
                    <p>Edit or remove staff and patient accounts.</p>
                </div>
                <span class="patient-arrow">→</span>
            </a>
            <a href="<%= request.getContextPath() %>/receptionist/patientList.jsp" class="patient-action-card">
                <div class="patient-action-icon icon-purple">▤</div>
                <div>
                    <h3>Patient List</h3>
                    <p>Search and browse all registered patients.</p>
                </div>
                <span class="patient-arrow">→</span>
            </a>
            <a href="<%= request.getContextPath() %>/receptionist/allAppointments.jsp" class="patient-action-card">
                <div class="patient-action-icon history-icon">✓</div>
                <div>
                    <h3>All Appointments</h3>
                    <p>Complete view of every appointment in the system.</p>
                </div>
                <span class="patient-arrow">→</span>
            </a>
            <a href="<%= request.getContextPath() %>/receptionist/pendingAppointments.jsp" class="patient-action-card">
                <div class="patient-action-icon icon-amber">⚑</div>
                <div>
                    <h3>Pending Appointments</h3>
                    <p>Review and confirm online booking requests.</p>
                </div>
                <span class="patient-arrow">→</span>
            </a>
            <a href="<%= request.getContextPath() %>/receptionist/billList.jsp" class="patient-action-card">
                <div class="patient-action-icon icon-green">$</div>
                <div>
                    <h3>Bill History</h3>
                    <p>View all invoices generated across the hospital.</p>
                </div>
                <span class="patient-arrow">→</span>
            </a>
        </div>
    </section>

    <section class="patient-info-banner">
        <div class="patient-info-content">
            <span class="patient-info-label">NOVACARE SYSTEM ADMINISTRATION</span>
            <h2>Full oversight, in one dashboard.</h2>
            <p>
                Manage every account and monitor hospital-wide activity —
                appointments, billing, and staff — without switching systems.
            </p>
        </div>
        <a href="addStaff.jsp" class="patient-info-btn">Add Staff</a>
    </section>

</div>
</div>
</div>
</body>
</html>
