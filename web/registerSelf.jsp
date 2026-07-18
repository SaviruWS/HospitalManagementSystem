<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>NovaCare Private Hospital - Patient Registration</title>
    <link rel="stylesheet" href="css/theme.css">
</head>
<body class="auth-page">
    <div class="auth-box" style="width: 460px;">
        <div class="logo-wrap">
            <img src="images/logo.jpg" alt="NovaCare Private Hospital">
        </div>
        <h2 style="margin-top:0;">Patient Registration</h2>

        <%
            String error = request.getParameter("error");
            if (error != null) {
        %>
            <div class="alert alert-error">Registration failed. Email may already be in use.</div>
        <%
            }
        %>

        <form action="RegisterPatientServlet" method="post">
            <input type="hidden" name="source" value="self">

            <label>Full Name</label>
            <input type="text" name="fullName" required>

            <label>Email</label>
            <input type="email" name="email" required>

            <label>Password</label>
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
            <button type="submit" class="btn" style="width:100%;">Register</button>
        </form>
        <a href="login.jsp">Already have an account? Login here</a>
    </div>
</body>
</html>
