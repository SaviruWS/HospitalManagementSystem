package servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLIntegrityConstraintViolationException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import util.DBConnection;

@WebServlet(name = "DeleteUserServlet", urlPatterns = {"/DeleteUserServlet"})
public class DeleteUserServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String userIdStr = request.getParameter("userId");

        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            int userId = Integer.parseInt(userIdStr);

            // We attempt the delete directly. If this user has linked records elsewhere
            
            PreparedStatement deleteStmt = conn.prepareStatement("DELETE FROM users WHERE user_id = ?");
            deleteStmt.setInt(1, userId);
            deleteStmt.executeUpdate();

            response.sendRedirect("admin/manageUsers.jsp?success=deleted");

        } catch (SQLIntegrityConstraintViolationException fkEx) {
            
            fkEx.printStackTrace();
            response.sendRedirect("admin/manageUsers.jsp?error=inuse");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin/manageUsers.jsp?error=1");

        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (Exception closeEx) {
                    closeEx.printStackTrace();
                }
            }
        }
    }
}