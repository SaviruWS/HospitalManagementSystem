<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>NovaCare Private Hospital - Login</title>
    <link rel="stylesheet" href="css/theme.css">
</head>
<body class="auth-page">
    <div class="auth-box">
        <div class="logo-wrap">
            <img src="images/logo.jpg" alt="NovaCare Private Hospital">
        </div>

        <%
            String error = request.getParameter("error");
            String logout = request.getParameter("logout");
            String registered = request.getParameter("registered");
            if (error != null) {
        %>
            <div class="alert alert-error">Invalid email or password</div>
        <%
            } else if (logout != null) {
        %>
            <div class="alert alert-success">You have been logged out successfully.</div>
        <%
            } else if (registered != null) {
        %>
            <div class="alert alert-success">Registration successful! Please log in.</div>
        <%
            }
        %>

        <form action="LoginServlet" method="post">
            <label>Email</label>
            <input type="email" name="email" required>
            <label>Password</label>
            <input type="password" name="password" required>
            <br><br>
            <button type="submit" class="btn" style="width:100%;">Login</button>
        </form>
        <a href="registerSelf.jsp">New patient? Register here</a>
    </div>
</body>
</html>
