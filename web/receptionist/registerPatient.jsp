<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Register New Patient</title>
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
        input[type=date], select {
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
    </style>
</head>
<body>
    <div class="form-box">
        <h2>Register New Patient</h2>

        <%
            String error = request.getParameter("error");
            String success = request.getParameter("success");
            if (error != null) {
        %>
            <p class="error">Registration failed. Email may already be in use.</p>
        <%
            } else if (success != null) {
        %>
            <p class="success">Patient registered successfully!</p>
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

            <input type="submit" value="Register Patient">
        </form>
        <br>
        <a href="dashboard.jsp">Back to Dashboard</a>
    </div>
</body>
</html>