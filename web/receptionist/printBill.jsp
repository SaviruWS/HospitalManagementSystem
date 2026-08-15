<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="util.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../includes/sidebar.jsp" %>

    <style>
        @media print {
            .sidebar, .page-header, .no-print { display: none !important; }
            .main-content { padding: 0 !important; }
            body { background: #fff !important; }
        }
        .invoice-box {
            max-width: 650px;
            margin: 0 auto;
            background: #fff;
            padding: 40px;
            border: 1px solid var(--color-border);
            border-radius: var(--radius);
        }
        .invoice-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            border-bottom: 2px solid var(--color-primary);
            padding-bottom: 20px;
            margin-bottom: 20px;
        }
        .invoice-header img { max-width: 160px; }
        .invoice-header .invoice-meta { text-align: right; font-size: 13.5px; color: var(--color-text-muted); }
        .invoice-section { margin-bottom: 20px; }
        .invoice-section h4 { margin-bottom: 6px; color: var(--color-navy); }
        .invoice-table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        .invoice-table th, .invoice-table td { padding: 10px; border-bottom: 1px solid var(--color-border); text-align: left; }
        .invoice-total-row td { font-weight: bold; font-size: 16px; border-top: 2px solid var(--color-navy); }
    </style>

    <div class="page-header">
        <div>
            <h2>Invoice</h2>
            <p>Printable bill for the patient</p>
        </div>
        <div class="welcome-badge">Welcome, <strong><%= fullName %></strong></div>
    </div>

    <%
        String billIdParam = request.getParameter("billId");
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            PreparedStatement stmt = conn.prepareStatement(
                "SELECT b.*, up.full_name AS patient_name, up.email AS patient_email, up.contact_number, " +
                "ud.full_name AS doctor_name, d.specialization, ug.full_name AS generated_by_name, " +
                "a.appointment_date, a.appointment_time " +
                "FROM bills b " +
                "JOIN patients p ON b.patient_id = p.patient_id " +
                "JOIN users up ON p.user_id = up.user_id " +
                "JOIN doctors d ON b.doctor_id = d.doctor_id " +
                "JOIN users ud ON d.user_id = ud.user_id " +
                "JOIN users ug ON b.generated_by = ug.user_id " +
                "JOIN appointments a ON b.appointment_id = a.appointment_id " +
                "WHERE b.bill_id = ?");
            stmt.setInt(1, Integer.parseInt(billIdParam));
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
    %>
        <div class="invoice-box">
            <div class="invoice-header">
                <img src="<%= request.getContextPath() %>/images/logo.jpg" alt="NovaCare Private Hospital">
                <div class="invoice-meta">
                    <strong>Invoice #<%= rs.getInt("bill_id") %></strong><br>
                    Date: <%= rs.getTimestamp("generated_at") %><br>
                    Issued by: <%= rs.getString("generated_by_name") %>
                </div>
            </div>

            <div class="invoice-section">
                <h4>Patient Details</h4>
                <p>
                    <%= rs.getString("patient_name") %><br>
                    <%= rs.getString("patient_email") %> | <%= rs.getString("contact_number") %>
                </p>
            </div>

            <div class="invoice-section">
                <h4>Consultation Details</h4>
                <p>
                    Dr. <%= rs.getString("doctor_name") %> (<%= rs.getString("specialization") %>)<br>
                    Appointment: <%= rs.getDate("appointment_date") %> at <%= rs.getTime("appointment_time") %>
                </p>
            </div>

            <table class="invoice-table">
                <tr>
                    <th>Description</th>
                    <th style="text-align:right;">Amount (Rs.)</th>
                </tr>
                <tr>
                    <td>Consultation Fee</td>
                    <td style="text-align:right;"><%= rs.getBigDecimal("consultation_fee") %></td>
                </tr>
                <%
                    java.math.BigDecimal additional = rs.getBigDecimal("additional_charges");
                    if (additional != null && additional.compareTo(java.math.BigDecimal.ZERO) > 0) {
                %>
                <tr>
                    <td><%= rs.getString("charges_description") != null ? rs.getString("charges_description") : "Additional Charges" %></td>
                    <td style="text-align:right;"><%= additional %></td>
                </tr>
                <%
                    }
                %>
                <tr class="invoice-total-row">
                    <td>Total</td>
                    <td style="text-align:right;">Rs. <%= rs.getBigDecimal("total_amount") %></td>
                </tr>
            </table>

            <p style="margin-top:30px; font-size:12.5px; color:var(--color-text-muted); text-align:center;">
                Thank you for choosing NovaCare Private Hospital.
            </p>
        </div>

        <div class="no-print" style="max-width:650px; margin: 20px auto 0 auto; text-align:center;">
            <button onclick="window.print()" class="btn">Print Invoice</button>
            <a href="generateBill.jsp" class="btn" style="background: var(--color-navy-light);">Generate Another Bill</a>
        </div>
    <%
            } else {
    %>
        <div class="card"><p>Bill not found.</p></div>
    <%
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (conn != null) { try { conn.close(); } catch (Exception e) { e.printStackTrace(); } }
        }
    %>

</div></div>
</body>
</html>
