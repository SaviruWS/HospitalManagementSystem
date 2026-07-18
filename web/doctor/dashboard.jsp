<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../includes/sidebar.jsp" %>

    <div class="page-header">
        <div>
            <h2>Doctor Dashboard</h2>
            <p>Manage your schedule and view your appointments</p>
        </div>
        <div class="welcome-badge">Welcome, Dr. <strong><%= fullName %></strong></div>
    </div>

    <div class="card">
        <p>Use the sidebar to manage your availability or view your upcoming appointments.</p>
        <a href="manageSchedule.jsp" class="btn">Manage My Schedule</a>
    </div>

</div></div>
</body>
</html>
