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
import util.DBConnection;
import util.PasswordUtil;

@WebServlet(name = "AddStaffServlet", urlPatterns = {"/AddStaffServlet"})
public class AddStaffServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String contactNumber = request.getParameter("contactNumber");
        String role = request.getParameter("role"); // receptionist, nurse, or doctor
        String specialization = request.getParameter("specialization"); // only used if role = doctor
        String consultationFeeStr = request.getParameter("consultationFee"); // only used if role = doctor

        String insertUser = "INSERT INTO users (full_name, email, password, role, contact_number) VALUES (?, ?, ?, ?, ?)";
        String insertDoctor = "INSERT INTO doctors (user_id, specialization, consultation_fee) VALUES (?, ?, ?)";

        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // transaction — matters most for the doctor case (2 inserts)

            // Step 1: Insert into users table (always happens, regardless of role)
            PreparedStatement userStmt = conn.prepareStatement(insertUser, PreparedStatement.RETURN_GENERATED_KEYS);
            userStmt.setString(1, fullName);
            userStmt.setString(2, email);
            userStmt.setString(3, PasswordUtil.hashPassword(password));
            userStmt.setString(4, role);
            userStmt.setString(5, contactNumber);
            userStmt.executeUpdate();

            ResultSet generatedKeys = userStmt.getGeneratedKeys();
            int newUserId = -1;
            if (generatedKeys.next()) {
                newUserId = generatedKeys.getInt(1);
            }

            // Step 2: If role is doctor, also insert into doctors table
            if ("doctor".equals(role)) {
                PreparedStatement doctorStmt = conn.prepareStatement(insertDoctor);
                doctorStmt.setInt(1, newUserId);
                doctorStmt.setString(2, specialization);

                // Handle empty fee field gracefully (avoid NumberFormatException)
                double fee = (consultationFeeStr != null && !consultationFeeStr.isEmpty())
                        ? Double.parseDouble(consultationFeeStr)
                        : 0.0;
                doctorStmt.setDouble(3, fee);

                doctorStmt.executeUpdate();
            }

            conn.commit(); // all inserts succeeded

            response.sendRedirect("admin/addStaff.jsp?success=1");

        } catch (Exception e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (Exception rollbackEx) {
                    rollbackEx.printStackTrace();
                }
            }
            response.sendRedirect("admin/addStaff.jsp?error=1");

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