<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="util.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../includes/sidebar.jsp" %>

    <div class="page-header">
        <div>
            <h2>Generate Bill</h2>
            <p>Create an invoice for a patient's appointment</p>
        </div>
        <div class="welcome-badge">Welcome, <strong><%= fullName %></strong></div>
    </div>

    <div class="card">
        <%
            String error = request.getParameter("error");
            if (error != null) {
        %>
            <div class="alert alert-error">Failed to generate bill. Please check your inputs.</div>
        <%
            }
        %>

        <form method="get" action="generateBill.jsp">
            <label>Select Patient</label>
            <select name="patientId" onchange="this.form.submit()" required>
                <option value="">-- Select Patient --</option>
                <%
                    Connection conn = null;
                    try {
                        conn = DBConnection.getConnection();
                        PreparedStatement patientStmt = conn.prepareStatement(
                            "SELECT p.patient_id, u.full_name, u.email FROM patients p " +
                            "JOIN users u ON p.user_id = u.user_id ORDER BY u.full_name");
                        ResultSet patientRs = patientStmt.executeQuery();
                        String selectedPatientId = request.getParameter("patientId");
                        while (patientRs.next()) {
                            String pid = String.valueOf(patientRs.getInt("patient_id"));
                            String selected = pid.equals(selectedPatientId) ? "selected" : "";
                %>
                    <option value="<%= pid %>" <%= selected %>>
                        <%= patientRs.getString("full_name") %> (<%= patientRs.getString("email") %>)
                    </option>
                <%
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                %>
            </select>
            <noscript><button type="submit" class="btn">Load Patient</button></noscript>
        </form>
    </div>

    <%
        String patientIdParam = request.getParameter("patientId");
        if (patientIdParam != null && !patientIdParam.isEmpty()) {
    %>
        <div class="card">
            <h3 style="margin-top:0; color: var(--color-navy);">Select Appointment to Bill</h3>
            <table>
                <tr>
                    <th>Doctor</th>
                    <th>Date</th>
                    <th>Time</th>
                    <th>Fee (Rs.)</th>
                    <th>Action</th>
                </tr>
                <%
                    try {
                        // Only show confirmed appointments for this patient that don't already have a bill
                        PreparedStatement apptStmt = conn.prepareStatement(
                            "SELECT a.appointment_id, a.doctor_id, ud.full_name AS doctor_name, " +
                            "a.appointment_date, a.appointment_time, d.consultation_fee " +
                            "FROM appointments a " +
                            "JOIN doctors d ON a.doctor_id = d.doctor_id " +
                            "JOIN users ud ON d.user_id = ud.user_id " +
                            "WHERE a.patient_id = ? AND a.status = 'confirmed' " +
                            "AND a.appointment_id NOT IN (SELECT appointment_id FROM bills) " +
                            "ORDER BY a.appointment_date DESC, a.appointment_time DESC");
                        apptStmt.setInt(1, Integer.parseInt(patientIdParam));
                        ResultSet apptRs = apptStmt.executeQuery();

                        boolean any = false;
                        while (apptRs.next()) {
                            any = true;
                            int apptId = apptRs.getInt("appointment_id");
                %>
                    <tr>
                        <td>Dr. <%= apptRs.getString("doctor_name") %></td>
                        <td><%= apptRs.getDate("appointment_date") %></td>
                        <td><%= apptRs.getTime("appointment_time") %></td>
                        <td><%= apptRs.getBigDecimal("consultation_fee") %></td>
                        <td>
                            <a href="generateBill.jsp?patientId=<%= patientIdParam %>&appointmentId=<%= apptId %>" class="btn btn-sm">Create Bill</a>
                        </td>
                    </tr>
                <%
                        }
                        if (!any) {
                %>
                    <tr><td colspan="5">No unbilled confirmed appointments for this patient.</td></tr>
                <%
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                %>
            </table>
        </div>
    <%
        }

        String appointmentIdParam = request.getParameter("appointmentId");
        if (appointmentIdParam != null && !appointmentIdParam.isEmpty()) {
    %>
        <div class="card" style="max-width: 480px;">
            <h3 style="margin-top:0; color: var(--color-navy);">Bill Details</h3>
            <%
                try {
                    if (conn == null) conn = DBConnection.getConnection();
                    PreparedStatement detailStmt = conn.prepareStatement(
                        "SELECT d.doctor_id, d.consultation_fee, up.full_name AS patient_name, ud.full_name AS doctor_name " +
                        "FROM appointments a " +
                        "JOIN doctors d ON a.doctor_id = d.doctor_id " +
                        "JOIN users ud ON d.user_id = ud.user_id " +
                        "JOIN patients p ON a.patient_id = p.patient_id " +
                        "JOIN users up ON p.user_id = up.user_id " +
                        "WHERE a.appointment_id = ?");
                    detailStmt.setInt(1, Integer.parseInt(appointmentIdParam));
                    ResultSet detailRs = detailStmt.executeQuery();

                    if (detailRs.next()) {
                        java.math.BigDecimal fee = detailRs.getBigDecimal("consultation_fee");
            %>
                <p><strong>Patient:</strong> <%= detailRs.getString("patient_name") %></p>
                <p><strong>Doctor:</strong> Dr. <%= detailRs.getString("doctor_name") %></p>

                <form action="../GenerateBillServlet" method="post" id="billForm">
                    <input type="hidden" name="appointmentId" value="<%= appointmentIdParam %>">
                    <input type="hidden" name="patientId" value="<%= patientIdParam %>">
                    <input type="hidden" name="doctorId" value="<%= detailRs.getInt("doctor_id") %>">

                    <label>Consultation Fee (Rs.)</label>
                    <input type="number" step="0.01" id="consultationFee" name="consultationFee" value="<%= fee %>" readonly style="background:#f1f5f9;">

                    <label>Additional Charges (Rs.) — labs, procedures, etc.</label>
                    <input type="number" step="0.01" id="additionalCharges" name="additionalCharges" value="0.00" oninput="updateTotal()">

                    <label>Charges Description (optional)</label>
                    <input type="text" name="chargesDescription" placeholder="e.g. Blood test, X-Ray">

                    <label>Total Amount (Rs.)</label>
                    <input type="text" id="totalDisplay" value="<%= fee %>" readonly style="background:#f1f5f9; font-weight:bold;">

                    <br><br>
                    <button type="submit" class="btn" style="width:100%;">Generate Bill</button>
                </form>

                <script>
                    function updateTotal() {
                        var fee = parseFloat(document.getElementById('consultationFee').value) || 0;
                        var extra = parseFloat(document.getElementById('additionalCharges').value) || 0;
                        document.getElementById('totalDisplay').value = (fee + extra).toFixed(2);
                    }
                </script>
            <%
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                } finally {
                    if (conn != null) { try { conn.close(); } catch (Exception e) { e.printStackTrace(); } }
                }
            %>
        </div>
    <%
        } else if (conn != null) {
            try { conn.close(); } catch (Exception e) { e.printStackTrace(); }
        }
    %>

</div></div>
</body>
</html>
