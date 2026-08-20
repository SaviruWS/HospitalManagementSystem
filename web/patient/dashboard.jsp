<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../includes/sidebar.jsp" %>

<div class="patient-dashboard">

    <!-- Patient Welcome Hero -->
    <section class="patient-hero">

        <div class="patient-hero-content">
            <span class="patient-hero-label">PATIENT PORTAL</span>

            <h1>Welcome back, <%= fullName %></h1>

            <p>
                Manage your appointments and access your NovaCare
                healthcare services easily from one place.
            </p>

            <div class="patient-hero-actions">
                <a href="bookAppointment.jsp" class="patient-primary-btn">
                    Book an Appointment
                </a>

                <a href="myAppointments.jsp" class="patient-secondary-btn">
                    View My Appointments
                </a>
            </div>
        </div>

        <div class="patient-hero-image"></div>

    </section>


    <!-- Quick Access -->
    <section class="patient-section">

        <div class="patient-section-heading">
            <div>
                <h2>Quick Access</h2>
                <p>Manage your appointments and visits</p>
            </div>
        </div>


        <div class="patient-action-grid">

            <a href="bookAppointment.jsp" class="patient-action-card">
                <div class="patient-action-icon appointment-icon">
                    +
                </div>

                <div>
                    <h3>Book Appointment</h3>
                    <p>
                        Find an available doctor and schedule your visit.
                    </p>
                </div>

                <span class="patient-arrow">→</span>
            </a>


            <a href="myAppointments.jsp" class="patient-action-card">
                <div class="patient-action-icon history-icon">
                    ✓
                </div>

                <div>
                    <h3>My Appointments</h3>
                    <p>
                        View your booked appointments and appointment history.
                    </p>
                </div>

                <span class="patient-arrow">→</span>
            </a>

        </div>

    </section>


    <!-- Information Banner -->
    <section class="patient-info-banner">

        <div class="patient-info-content">
            <span class="patient-info-label">NOVACARE ONLINE CHANNELING</span>

            <h2>Your healthcare, made easier.</h2>

            <p>
                Book your consultation online and manage your appointments
                without having to visit the hospital just to make a booking.
            </p>
        </div>

        <a href="bookAppointment.jsp" class="patient-info-btn">
            Book Now
        </a>

    </section>

</div>

</div>
</div>

</body>
</html>