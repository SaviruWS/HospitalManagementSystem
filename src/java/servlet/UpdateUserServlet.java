package servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import util.DBConnection;

@WebServlet(name = "UpdateUserServlet", urlPatterns = {"/UpdateUserServlet"})
public class UpdateUserServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String userIdStr = request.getParameter("userId");
        String currentRole = request.getParameter("currentRole");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String contactNumber = request.getParameter("contactNumber");
        String specialization = request.getParameter("specialization");
        String consultationFeeStr = request.getParameter("consultationFee");

        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            int userId = Integer.parseInt(userIdStr);

            // Update the core users table
            PreparedStatement updateUser = conn.prepareStatement(
                "UPDATE users SET full_name = ?, email = ?, contact_number = ? WHERE user_id = ?");
            updateUser.setString(1, fullName);
            updateUser.setString(2, email);
            updateUser.setString(3, contactNumber);
            updateUser.setInt(4, userId);
            updateUser.executeUpdate();

            //If this user is a doctor, also update their doctors table entry
            if ("doctor".equals(currentRole)) {
                PreparedStatement updateDoctor = conn.prepareStatement(
                    "UPDATE doctors SET specialization = ?, consultation_fee = ? WHERE user_id = ?");
                updateDoctor.setString(1, specialization);
                double fee = (consultationFeeStr != null && !consultationFeeStr.isEmpty())
                        ? Double.parseDouble(consultationFeeStr) : 0.0;
                updateDoctor.setDouble(2, fee);
                updateDoctor.setInt(3, userId);
                updateDoctor.executeUpdate();
            }

            conn.commit();

            response.sendRedirect("admin/manageUsers.jsp?success=updated");

        } catch (Exception e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (Exception rollbackEx) {
                    rollbackEx.printStackTrace();
                }
            }
            response.sendRedirect("admin/editUser.jsp?userId=" + userIdStr + "&error=1");

        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (Exception closeEx) {
                    closeEx.printStackTrace();
                }
            }
        }
    }
}