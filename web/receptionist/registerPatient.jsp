<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../includes/sidebar.jsp" %>

    <div class="page-header">
        <div>
            <h2>Register New Patient</h2>
            <p>Create a patient account on their behalf</p>
        </div>
        <div class="welcome-badge">Welcome, <strong><%= fullName %></strong></div>
    </div>

    <div class="card" style="max-width: 480px;">
        <%
            String error = request.getParameter("error");
            String success = request.getParameter("success");
            if (error != null) {
        %>
            <div class="alert alert-error">Registration failed. Email may already be in use.</div>
        <%
            } else if (success != null) {
        %>
            <div class="alert alert-success">Patient registered successfully!</div>
        <%
            }
        %>

        <form action="../RegisterPatientServlet" method="post">
            <input type="hidden" name="source" value="receptionist">

            <label>Full Name</label>
            <input type="text" name="fullName" required>

            <label>Email</label>
            <input type="email" name="email" required>

            <label>Password (temporary, patient can change later)</label>
            <input type="password" name="password" required>

            <label>Contact Number</label>
            <input type="text" name="contactNumber" required>

            <label>Date of Birth</label>
            <input type="date" name="dob" required>

            <label>Gender</label>
            <select name="gender" required>
                <option value="male">Male</option>
                <option value="female">Female</option>
                <option value="other">Other</option>
            </select>

            <label>Address</label>
            <input type="text" name="address" required>

            <br><br>
            <button type="submit" class="btn" style="width:100%;">Register Patient</button>
        </form>
    </div>

</div></div>
</body>
</html>
