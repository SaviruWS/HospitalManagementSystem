<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../includes/sidebar.jsp" %>

    <div class="page-header">
        <div>
            <h2>Admin Dashboard</h2>
            <p>Manage staff accounts and system settings</p>
        </div>
        <div class="welcome-badge">Welcome, <strong><%= fullName %></strong></div>
    </div>

    <div class="card">
        <p>Use the sidebar to add new staff members (receptionist, nurse, or doctor) or manage other system settings.</p>
        <a href="addStaff.jsp" class="btn">Add Staff Member</a>
    </div>

</div></div>
</body>
</html>
