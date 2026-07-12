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

@WebServlet(name = "RegisterPatientServlet", urlPatterns = {"/RegisterPatientServlet"})
public class RegisterPatientServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String contactNumber = request.getParameter("contactNumber");
        String dob = request.getParameter("dob");
        String gender = request.getParameter("gender");
        String address = request.getParameter("address");
        String source = request.getParameter("source"); // "receptionist" or "self"

        // Determine where to redirect back to on failure, based on who submitted the form
        String failureRedirect = "self".equals(source)
                ? "registerSelf.jsp?error=1"
                : "receptionist/registerPatient.jsp?error=1";

        String insertUser = "INSERT INTO users (full_name, email, password, role, contact_number) VALUES (?, ?, ?, 'patient', ?)";
        String insertPatient = "INSERT INTO patients (user_id, date_of_birth, gender, address) VALUES (?, ?, ?, ?)";

        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // start transaction — both inserts succeed together, or neither does

            // Step 1: Insert into users table
            PreparedStatement userStmt = conn.prepareStatement(insertUser, PreparedStatement.RETURN_GENERATED_KEYS);
            userStmt.setString(1, fullName);
            userStmt.setString(2, email);
            userStmt.setString(3, PasswordUtil.hashPassword(password)); // hash before storing
            userStmt.setString(4, contactNumber);
            userStmt.executeUpdate();

            // Get the auto-generated user_id to link the patients record
            ResultSet generatedKeys = userStmt.getGeneratedKeys();
            int newUserId = -1;
            if (generatedKeys.next()) {
                newUserId = generatedKeys.getInt(1);
            }

            // Step 2: Insert into patients table, linked via user_id
            PreparedStatement patientStmt = conn.prepareStatement(insertPatient);
            patientStmt.setInt(1, newUserId);
            patientStmt.setString(2, dob);
            patientStmt.setString(3, gender);
            patientStmt.setString(4, address);
            patientStmt.executeUpdate();

            conn.commit(); // both inserts succeeded — save permanently

            // Redirect differently depending on who registered the patient
            if ("self".equals(source)) {
                // Patient registered themselves — send them to login with a success flag
                response.sendRedirect("login.jsp?registered=1");
            } else {
                // Receptionist registered the patient — send back to the receptionist form
                response.sendRedirect("receptionist/registerPatient.jsp?success=1");
            }

        } catch (Exception e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback(); // something failed — undo any partial insert
                } catch (Exception rollbackEx) {
                    rollbackEx.printStackTrace();
                }
            }
            response.sendRedirect(failureRedirect);

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