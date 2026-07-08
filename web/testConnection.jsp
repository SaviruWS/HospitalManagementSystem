<%@page import="java.sql.Connection"%>
<%@page import="util.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<body>
<%
    try {
        Connection conn = DBConnection.getConnection();
        out.println("<h2 style='color:green;'>Database connected successfully!</h2>");
        conn.close();
    } catch (Exception e) {
        out.println("<h2 style='color:red;'>Connection failed: " + e.getMessage() + "</h2>");
    }
%>
</body>
</html>