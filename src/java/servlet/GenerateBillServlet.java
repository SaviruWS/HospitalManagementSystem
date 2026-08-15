package servlet;

import java.io.IOException;
import java.math.BigDecimal;
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
import util.EmailUtil;

@WebServlet(name = "GenerateBillServlet", urlPatterns = {"/GenerateBillServlet"})
public class GenerateBillServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Integer generatedBy = (session != null) ? (Integer) session.getAttribute("userId") : null;

        String appointmentIdStr = request.getParameter("appointmentId");
        String patientIdStr = request.getParameter("patientId");
        String doctorIdStr = request.getParameter("doctorId");
        String consultationFeeStr = request.getParameter("consultationFee");
        String additionalChargesStr = request.getParameter("additionalCharges");
        String chargesDescription = request.getParameter("chargesDescription");

        Connection conn = null;

        try {
            conn = DBConnection.getConnection();

            BigDecimal consultationFee = new BigDecimal(consultationFeeStr);
            BigDecimal additionalCharges = (additionalChargesStr != null && !additionalChargesStr.isEmpty())
                    ? new BigDecimal(additionalChargesStr) : BigDecimal.ZERO;
            BigDecimal total = consultationFee.add(additionalCharges);

            PreparedStatement stmt = conn.prepareStatement(
                "INSERT INTO bills (appointment_id, patient_id, doctor_id, consultation_fee, additional_charges, " +
                "charges_description, total_amount, generated_by) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
                PreparedStatement.RETURN_GENERATED_KEYS);
            stmt.setInt(1, Integer.parseInt(appointmentIdStr));
            stmt.setInt(2, Integer.parseInt(patientIdStr));
            stmt.setInt(3, Integer.parseInt(doctorIdStr));
            stmt.setBigDecimal(4, consultationFee);
            stmt.setBigDecimal(5, additionalCharges);
            stmt.setString(6, (chargesDescription != null && !chargesDescription.isEmpty()) ? chargesDescription : null);
            stmt.setBigDecimal(7, total);
            stmt.setInt(8, generatedBy);
            stmt.executeUpdate();

            ResultSet keys = stmt.getGeneratedKeys();
            int billId = -1;
            if (keys.next()) {
                billId = keys.getInt(1);
            }

            // Fetch patient email/name + doctor name, needed to send the bill by email
            PreparedStatement infoStmt = conn.prepareStatement(
                "SELECT u.email, u.full_name AS patient_name, ud.full_name AS doctor_name " +
                "FROM patients p " +
                "JOIN users u ON p.user_id = u.user_id " +
                "JOIN doctors d ON d.doctor_id = ? " +
                "JOIN users ud ON d.user_id = ud.user_id " +
                "WHERE p.patient_id = ?");
            infoStmt.setInt(1, Integer.parseInt(doctorIdStr));
            infoStmt.setInt(2, Integer.parseInt(patientIdStr));
            ResultSet infoRs = infoStmt.executeQuery();

            if (infoRs.next()) {
                String patientEmail = infoRs.getString("email");
                String patientName = infoRs.getString("patient_name");
                String doctorName = infoRs.getString("doctor_name");

                StringBuilder body = new StringBuilder();
                body.append("Dear ").append(patientName).append(",\n\n");
                body.append("Here is your invoice for your recent consultation.\n\n");
                body.append("Invoice #: ").append(billId).append("\n");
                body.append("Doctor: Dr. ").append(doctorName).append("\n\n");
                body.append("Consultation Fee: Rs. ").append(consultationFee).append("\n");
                if (additionalCharges.compareTo(BigDecimal.ZERO) > 0) {
                    String desc = (chargesDescription != null && !chargesDescription.isEmpty())
                            ? chargesDescription : "Additional Charges";
                    body.append(desc).append(": Rs. ").append(additionalCharges).append("\n");
                }
                body.append("--------------------------------\n");
                body.append("Total: Rs. ").append(total).append("\n\n");
                body.append("Thank you for choosing NovaCare Private Hospital Matara.\n\n");
                body.append("Thank you,\nNovaCare Private Hospital Management System");

                EmailUtil.sendEmail(patientEmail, "Your Invoice from NovaCare Private Hospital", body.toString());
            }

            response.sendRedirect("receptionist/printBill.jsp?billId=" + billId);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("receptionist/generateBill.jsp?error=1");

        } finally {
            if (conn != null) {
                try { conn.close(); } catch (Exception closeEx) { closeEx.printStackTrace(); }
            }
        }
    }
}