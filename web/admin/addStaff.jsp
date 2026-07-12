<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Add Staff Member</title>
    <style>
        body { font-family: Arial, sans-serif; background: #f2f2f2; }
        .form-box {
            width: 420px;
            margin: 50px auto;
            padding: 30px;
            background: white;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        h2 { text-align: center; color: #2c3e50; }
        label { font-weight: bold; margin-top: 10px; display: block; }
        input[type=text], input[type=email], input[type=password],
        input[type=number], select {
            width: 100%;
            padding: 8px;
            margin: 5px 0 12px 0;
            box-sizing: border-box;
            border: 1px solid #ccc;
            border-radius: 4px;
        }
        input[type=submit] {
            width: 100%;
            padding: 10px;
            background: #2c3e50;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        .error { color: red; text-align: center; }
        .success { color: green; text-align: center; }
        #doctorFields { display: none; }
    </style>
    <script>
        // Show/hide doctor-specific fields depending on selected role
        function toggleDoctorFields() {
            var role = document.getElementById("role").value;
            var doctorFields = document.getElementById("doctorFields");
            doctorFields.style.display = (role === "doctor") ? "block" : "none";
        }
    </script>
</head>
<body>
    <div class="form-box">
        <h2>Add Staff Member</h2>

        <%
            String error = request.getParameter("error");
            String success = request.getParameter("success");
            if (error != null) {
        %>
            <p class="error">Failed to add staff. Email may already be in use.</p>
        <%
            } else if (success != null) {
        %>
            <p class="success">Staff member added successfully!</p>
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

            <div id="doctorFields">
                <label>Specialization</label>
                <input type="text" name="specialization">

                <label>Consultation Fee (Rs.)</label>
                <input type="number" step="0.01" name="consultationFee">
            </div>

            <input type="submit" value="Add Staff Member">
        </form>
        <br>
        <a href="dashboard.jsp">Back to Dashboard</a>
    </div>
</body>
</html>
