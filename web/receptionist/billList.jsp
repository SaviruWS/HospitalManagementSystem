<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="util.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../includes/sidebar.jsp" %>

    <div class="page-header">
        <div>
            <h2>Bill History</h2>
            <p>All generated invoices</p>
        </div>
        <div class="welcome-badge">Welcome, <strong><%= fullName %></strong></div>
    </div>

    <div class="card">
        <table>
            <tr>
                <th>Bill #</th>
                <th>Patient</th>
                <th>Doctor</th>
                <th>Total (Rs.)</th>
                <th>Generated On</th>
                <th>Action</th>
            </tr>
            <%
                Connection conn = null;
                try {
                    conn = DBConnection.getConnection();
                    PreparedStatement stmt = conn.prepareStatement(
                        "SELECT b.bill_id, b.total_amount, b.generated_at, up.full_name AS patient_name, " +
                        "ud.full_name AS doctor_name " +
                        "FROM bills b " +
                        "JOIN patients p ON b.patient_id = p.patient_id " +
                        "JOIN users up ON p.user_id = up.user_id " +
                        "JOIN doctors d ON b.doctor_id = d.doctor_id " +
                        "JOIN users ud ON d.user_id = ud.user_id " +
                        "ORDER BY b.generated_at DESC");
                    ResultSet rs = stmt.executeQuery();

                    boolean any = false;
                    while (rs.next()) {
                        any = true;
            %>
                <tr>
                    <td>#<%= rs.getInt("bill_id") %></td>
                    <td><%= rs.getString("patient_name") %></td>
                    <td>Dr. <%= rs.getString("doctor_name") %></td>
                    <td><%= rs.getBigDecimal("total_amount") %></td>
                    <td><%= rs.getTimestamp("generated_at") %></td>
                    <td><a href="printBill.jsp?billId=<%= rs.getInt("bill_id") %>" class="btn btn-sm">View / Print</a></td>
                </tr>
            <%
                    }
                    if (!any) {
            %>
                <tr><td colspan="6">No bills generated yet.</td></tr>
            <%
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                } finally {
                    if (conn != null) { try { conn.close(); } catch (Exception e) { e.printStackTrace(); } }
                }
            %>
        </table>
    </div>

</div></div>
</body>
</html>
