<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../includes/sidebar.jsp" %>

    <div class="page-header">
        <div>
            <h2>Add Staff Member</h2>
            <p>Create a new receptionist, nurse, or doctor account</p>
        </div>
        <div class="welcome-badge">Welcome, <strong><%= fullName %></strong></div>
    </div>

    <div class="card" style="max-width: 480px;">
        <%
            String error = request.getParameter("error");
            String success = request.getParameter("success");
            if (error != null) {
        %>
            <div class="alert alert-error">Failed to add staff. Email may already be in use.</div>
        <%
            } else if (success != null) {
        %>
            <div class="alert alert-success">Staff member added successfully!</div>
        <%
            }
        %>

        <form action="../AddStaffServlet" method="post">
            <label>Full Name</label>
            <input type="text" name="fullName" required>

            <label>Email</label>
            <input type="email" name="email" required>

            <label>Temporary Password</label>
            <input type="password" name="password" required>

            <label>Contact Number</label>
            <input type="text" name="contactNumber" required>

            <label>Role</label>
            <select name="role" id="role" onchange="toggleDoctorFields()" required>
                <option value="">-- Select Role --</option>
                <option value="receptionist">Receptionist</option>
                <option value="nurse">Nurse</option>
                <option value="doctor">Doctor</option>
            </select>

            <div id="doctorFields" style="display:none;">
                <label>Specialization</label>
                <input type="text" name="specialization">

                <label>Consultation Fee (Rs.)</label>
                <input type="number" step="0.01" name="consultationFee">
            </div>

            <br>
            <button type="submit" class="btn" style="width:100%;">Add Staff Member</button>
        </form>
    </div>

</div></div>

<script>
    // Show/hide doctor-specific fields depending on selected role
    function toggleDoctorFields() {
        var role = document.getElementById("role").value;
        var doctorFields = document.getElementById("doctorFields");
        doctorFields.style.display = (role === "doctor") ? "block" : "none";
    }
</script>
</body>
</html>
