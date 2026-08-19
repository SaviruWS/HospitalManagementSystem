<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="util.DBConnection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="../includes/sidebar.jsp" %>

    <div class="page-header">
        <div>
            <h2>My Appointments</h2>
            <p>Your appointment history and upcoming bookings</p>
        </div>
        <div class="welcome-badge">Welcome, <strong><%= fullName %></strong></div>
    </div>

    <%
        // Show an arrival banner for the patient's nearest today's confirmed appointment, if any
        Integer bannerUserId = (Integer) session.getAttribute("userId");
        Connection bannerConn = null;
        try {
            bannerConn = DBConnection.getConnection();
            PreparedStatement bannerLookup = bannerConn.prepareStatement(
                "SELECT ud.full_name AS doctor_name, ds.doctor_arrived, a.appointment_time " +
                "FROM appointments a " +
                "JOIN patients p ON a.patient_id = p.patient_id " +
                "JOIN doctors d ON a.doctor_id = d.doctor_id " +
                "JOIN users ud ON d.user_id = ud.user_id " +
                "JOIN doctor_schedule ds ON a.schedule_id = ds.schedule_id " +
                "WHERE p.user_id = ? AND a.appointment_date = CURDATE() AND a.status = 'confirmed' " +
                "ORDER BY a.appointment_time LIMIT 1");
            bannerLookup.setInt(1, bannerUserId);
            ResultSet bannerRs = bannerLookup.executeQuery();

            if (bannerRs.next()) {
                boolean arrived = bannerRs.getBoolean("doctor_arrived");
                String doctorName = bannerRs.getString("doctor_name");
                if (arrived) {
    %>
        <div class="alert alert-success">
            🟢  <%= doctorName %> has arrived — consultations are in progress. Please check the queue below for your position.
        </div>
    <%
                } else {
    %>
        <div class="alert alert-info">
            🕒  <%= doctorName %> has not yet arrived for today's session. We'll update this once they do.
        </div>
    <%
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (bannerConn != null) { try { bannerConn.close(); } catch (Exception e) { e.printStackTrace(); } }
        }
    %>

    <div class="card">
        <table>
            <tr>
                <th>Doctor</th>
                <th>Date</th>
                <th>Time</th>
                <th>Channel</th>
                <th>Status</th>
                <th>Queue</th>
            </tr>
            <%
                Integer userId = (Integer) session.getAttribute("userId");
                Connection conn = null;
                try {
                    conn = DBConnection.getConnection();

                    PreparedStatement patientLookup = conn.prepareStatement(
                        "SELECT patient_id FROM patients WHERE user_id = ?");
                    patientLookup.setInt(1, userId);
                    ResultSet patientRs = patientLookup.executeQuery();
                    int patientId = -1;
                    if (patientRs.next()) {
                        patientId = patientRs.getInt("patient_id");
                    }

                    PreparedStatement stmt = conn.prepareStatement(
                        "SELECT ud.full_name AS doctor_name, a.appointment_date, a.appointment_time, " +
                        "a.channel_type, a.status, a.visit_status, a.doctor_id " +
                        "FROM appointments a " +
                        "JOIN doctors d ON a.doctor_id = d.doctor_id " +
                        "JOIN users ud ON d.user_id = ud.user_id " +
                        "WHERE a.patient_id = ? " +
                        "ORDER BY a.appointment_date DESC, a.appointment_time DESC");
                    stmt.setInt(1, patientId);
                    ResultSet rs = stmt.executeQuery();

                    boolean any = false;
                    while (rs.next()) {
                        any = true;
                        String status = rs.getString("status");
                        String visitStatus = rs.getString("visit_status");
                        java.sql.Date apptDate = rs.getDate("appointment_date");
                        boolean isToday = apptDate.toLocalDate().isEqual(java.time.LocalDate.now());
            %>
                <tr>
                    <td> <%= rs.getString("doctor_name") %></td>
                    <td><%= apptDate %></td>
                    <td><%= rs.getTime("appointment_time") %></td>
                    <td style="text-transform:capitalize;"><%= rs.getString("channel_type") %></td>
                    <td><span class="badge badge-<%= status %>"><%= status %></span></td>
                    <td>
                        <% if (isToday && "confirmed".equals(status)) {
                            if ("waiting".equals(visitStatus)) {
                                PreparedStatement posStmt = conn.prepareStatement(
                                    "SELECT COUNT(*) AS pos FROM appointments " +
                                    "WHERE doctor_id = ? AND appointment_date = CURDATE() " +
                                    "AND visit_status = 'waiting' AND appointment_time <= ?");
                                posStmt.setInt(1, rs.getInt("doctor_id"));
                                posStmt.setTime(2, rs.getTime("appointment_time"));
                                ResultSet posRs = posStmt.executeQuery();
                                int position = posRs.next() ? posRs.getInt("pos") : 0;
                        %>
                            <span class="badge badge-pending">Waiting (#<%= position %>)</span>
                        <%
                            } else if ("with_doctor".equals(visitStatus)) {
                        %>
                            <span class="badge badge-confirmed">With Doctor</span>
                        <%
                            } else if ("completed".equals(visitStatus)) {
                        %>
                            <span class="badge badge-completed">Completed</span>
                        <%
                            } else {
                        %>
                            <span class="badge badge-cancelled">Not Arrived</span>
                        <%
                            }
                        } else { %>
                            <span style="color: var(--color-text-muted);">-</span>
                        <% } %>
                    </td>
                </tr>
            <%
                    }
                    if (!any) {
            %>
                <tr><td colspan="6">You haven't booked any appointments yet.</td></tr>
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
