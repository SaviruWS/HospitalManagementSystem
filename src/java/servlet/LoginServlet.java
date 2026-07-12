package servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import util.DBConnection;
import util.PasswordUtil;

@WebServlet(name = "LoginServlet", urlPatterns = {"/LoginServlet"})
public class LoginServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        // Only look up by email now — password is checked separately using BCrypt,
        // since the stored value is a hash and can't be matched directly in SQL.
        String query = "SELECT * FROM users WHERE email = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setString(1, email);

            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                String storedHash = rs.getString("password");

                // Verify the entered plain password against the stored BCrypt hash
                if (PasswordUtil.checkPassword(password, storedHash)) {

                    // Login successful — create session
                    HttpSession session = request.getSession();
                    session.setAttribute("userId", rs.getInt("user_id"));
                    session.setAttribute("fullName", rs.getString("full_name"));
                    session.setAttribute("role", rs.getString("role"));

                    String role = rs.getString("role");

                    // Redirect based on role
                    switch (role) {
                        case "admin":
                            response.sendRedirect("admin/dashboard.jsp");
                            break;
                        case "doctor":
                            response.sendRedirect("doctor/dashboard.jsp");
                            break;
                        case "nurse":
                            response.sendRedirect("nurse/dashboard.jsp");
                            break;
                        case "receptionist":
                            response.sendRedirect("receptionist/dashboard.jsp");
                            break;
                        case "patient":
                            response.sendRedirect("patient/dashboard.jsp");
                            break;
                        default:
                            response.sendRedirect("login.jsp?error=1");
                    }

                } else {
                    // Password did not match
                    response.sendRedirect("login.jsp?error=1");
                }

            } else {
                // No user found with that email
                response.sendRedirect("login.jsp?error=1");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("login.jsp?error=1");
        }
    }
}