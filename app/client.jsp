<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // 1. SÉCURITÉ & VARIABLES
    String uri = request.getRequestURI();
    if (uri.endsWith(".jsp") || !uri.endsWith("/customer_account")) {
        response.sendError(404);
        return;
    }

    String action = request.getParameter("action");
    String message = "";
    
    if (session.getAttribute("flash") != null) {
        message = (String) session.getAttribute("flash");
        session.removeAttribute("flash");
    }

    String userSIN = (String) session.getAttribute("userSIN");
    String userName = (String) session.getAttribute("userName");
    
    // --- CONNEXION BLINDÉE DIRECTE (Adieu les bugs de cache Tomcat) ---
    String dbURL = "jdbc:postgresql://localhost:5432/Database_Ehotel_Project";
    String dbUser = "postgres";
    String dbPass = "pgadmin1234";

    try { Class.forName("org.postgresql.Driver"); } catch(Exception ignored) {}

    // 2. LOGIQUE ACTIONS
    if (action != null) {
        try (Connection con = DriverManager.getConnection(dbURL, dbUser, dbPass)) {

            // LOGIN
            if (action.equals("login")) {
                String sin = request.getParameter("loginSIN").replaceAll("[^0-9]", ""); 
                
                PreparedStatement pstmt = con.prepareStatement("SELECT * FROM customer WHERE customer_sin = ?");
                pstmt.setString(1, sin);
                ResultSet rs = pstmt.executeQuery();
                
                if (rs.next()) {
                    session.setAttribute("userSIN", sin); 
                    session.setAttribute("userName", rs.getString("full_name"));
                    response.sendRedirect("customer_account");
                    return;
                } else { 
                    message = "<div class='error'>❌ NAS incorrect ou introuvable : " + sin + "</div>"; 
                }
            } 
            // REGISTER
            else if (action.equals("register")) {
                String sin = request.getParameter("regSIN").replaceAll("[^0-9]", "");
                
                PreparedStatement pstmt = con.prepareStatement("INSERT INTO customer (customer_sin, full_name, address, type_of_id, registration_date) VALUES (?, ?, ?, ?, CURRENT_DATE)");
                pstmt.setString(1, sin);
                pstmt.setString(2, request.getParameter("regName"));
                pstmt.setString(3, request.getParameter("regAddress"));
                pstmt.setString(4, request.getParameter("regIdType"));
                pstmt.executeUpdate();
                
                session.setAttribute("flash", "<div class='success'>✅ Compte créé ! Tu peux te connecter.</div>");
                response.sendRedirect("customer_account");
                return;
            }
            // DELETE BOOKING
            else if (action.equals("delete_booking")) {
                String bNum = request.getParameter("booking_number");
                con.setAutoCommit(false);
                
                PreparedStatement ps1 = con.prepareStatement("DELETE FROM customerreserves WHERE booking_number = ?");
                ps1.setInt(1, Integer.parseInt(bNum));
                ps1.executeUpdate();
                
                PreparedStatement ps2 = con.prepareStatement("DELETE FROM booking WHERE booking_number = ?");
                ps2.setInt(1, Integer.parseInt(bNum));
                ps2.executeUpdate();
                
                con.commit();
                session.setAttribute("flash", "<div class='success'>✅ Réservation annulée.</div>");
                response.sendRedirect("customer_account");
                return;
            }
        } catch (Exception e) { 
            // LE DÉTECTEUR DE PROBLÈME EXTRÊME
            String debugInfo = "<br><br><b>🔍 DIAGNOSTIC SQL :</b><br>";
            try (Connection debugCon = DriverManager.getConnection(dbURL, dbUser, dbPass)) {
                DatabaseMetaData meta = debugCon.getMetaData();
                ResultSet tables = meta.getTables(null, "public", "%", new String[] {"TABLE"});
                debugInfo += "Tables vues par Java dans la DB : ";
                boolean found = false;
                while(tables.next()) {
                    debugInfo += tables.getString("TABLE_NAME") + ", ";
                    found = true;
                }
                if(!found) debugInfo += "<b>AUCUNE TABLE TROUVÉE ! La DB est vide pour Java !</b>";
            } catch(Exception ex) {}
            
            message = "<div class='error'>⚠️ ERREUR FATALE : " + e.getMessage() + debugInfo + "</div>"; 
        }
    }
    
    // LOGOUT
    if ("logout".equals(action)) {
        session.invalidate(); 
        response.sendRedirect("customer_account");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Espace Client - e-Hôtels</title>
    <style>
        body { font-family: sans-serif; background-color: #f4f7f6; margin: 0; padding: 20px; }
        .container { max-width: 900px; margin: auto; display: flex; gap: 20px; }
        .box { background: white; padding: 30px; border-radius: 8px; box-shadow: 0 4px 8px rgba(0,0,0,0.1); flex: 1; }
        input, select { width: 100%; padding: 10px; margin-top: 5px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; }
        button { background-color: #3498db; color: white; border: none; padding: 12px 20px; margin-top: 25px; width: 100%; border-radius: 4px; cursor: pointer; font-weight: bold; }
        button:hover { background-color: #2980b9; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; background: white;}
        th, td { border: 1px solid #ddd; padding: 10px; text-align: left; }
        th { background-color: #2c3e50; color: white; }
        .success { color: #155724; background-color: #d4edda; padding: 15px; border-radius: 4px; margin-bottom: 20px; text-align: center; border: 1px solid #c3e6cb; }
        .error { color: #721c24; background-color: #f8d7da; padding: 15px; border-radius: 4px; margin-bottom: 20px; text-align: left; border: 1px solid #f5c6cb; }
        .dashboard { background: white; padding: 40px; border-radius: 8px; box-shadow: 0 4px 8px rgba(0,0,0,0.1); max-width: 900px; margin: auto; text-align: center;}
    </style>
</head>
<body>
    <h1 style="text-align: center; color: #2c3e50;">👤 Portail Client</h1>
    <%= message %>

    <% if (session.getAttribute("userSIN") != null) { %>
        <div class="dashboard">
            <h2>Bonjour, <%= session.getAttribute("userName") %> ! 👋</h2>
            <p style="color: #7f8c8d;">NAS : <%= session.getAttribute("userSIN") %></p>
            <a href="rooms" style="display:inline-block; background:#27ae60; color:white; padding:12px 24px; text-decoration:none; border-radius:5px; margin-bottom:20px; font-weight:bold;">🔍 Trouver une chambre</a>

            <h3 style="text-align:left; border-bottom: 2px solid #eee; padding-bottom: 10px;">🗓️ Mes Réservations</h3>
            <table>
                <thead>
                    <tr>
                        <th>N°</th>
                        <th>Hôtel</th>
                        <th>Chambre</th>
                        <th>Dates</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try (Connection conRes = DriverManager.getConnection(dbURL, dbUser, dbPass)) {
                            String sqlRes = "SELECT b.booking_number, b.room_number, h.address, b.start_date, b.end_date " +
                                            "FROM booking b " +
                                            "JOIN customerreserves cr ON b.booking_number = cr.booking_number " +
                                            "JOIN hotelcontains hc ON b.room_number = hc.room_number " +
                                            "JOIN hotel h ON hc.hotel_id = h.hotel_id " +
                                            "WHERE cr.customer_sin = ?";
                            PreparedStatement pstmtRes = conRes.prepareStatement(sqlRes);
                            pstmtRes.setString(1, (String)session.getAttribute("userSIN"));
                            ResultSet rsRes = pstmtRes.executeQuery();
                            
                            boolean hasReservations = false;
                            while (rsRes.next()) {
                                hasReservations = true;
                    %>
                            <tr>
                                <td>#<%= rsRes.getInt("booking_number") %></td>
                                <td><%= rsRes.getString("address") %></td>
                                <td><strong><%= rsRes.getInt("room_number") % 1000 %></strong></td>
                                <td><%= rsRes.getDate("start_date") %> au <%= rsRes.getDate("end_date") %></td>
                                <td>
                                    <form method="POST" action="" style="margin:0;">
                                        <input type="hidden" name="action" value="delete_booking">
                                        <input type="hidden" name="booking_number" value="<%= rsRes.getInt("booking_number") %>">
                                        <button type="submit" style="background:#e74c3c; width:auto; margin:0; padding:6px 12px;" onclick="return confirm('Annuler la réservation ?')">Annuler</button>
                                    </form>
                                </td>
                            </tr>
                    <%      } 
                            if (!hasReservations) {
                    %>
                            <tr>
                                <td colspan="5" style="text-align:center; color:#7f8c8d; padding:20px;">Aucune réservation pour le moment.</td>
                            </tr>
                    <%      }
                        } catch(Exception e) { out.println("<tr><td colspan='5'>Erreur d'affichage : " + e.getMessage() + "</td></tr>"); }
                    %>
                </tbody>
            </table>
            <form method="POST" action="" style="margin-top: 30px;">
                <input type="hidden" name="action" value="logout">
                <button type="submit" style="background:#7f8c8d; width:auto; padding: 10px 30px;">Se déconnecter</button>
            </form>
        </div>
    <% } else { %>
        <div class="container">
            <div class="box">
                <h2>Connexion</h2>
                <form method="POST" action="">
                    <input type="hidden" name="action" value="login">
                    <label>NAS (9 chiffres) :</label>
                    <input type="text" name="loginSIN" placeholder="Ex: 900000001" required>
                    <button type="submit">Entrer</button>
                </form>
            </div>
            <div class="box">
                <h2>Inscription</h2>
                <form method="POST" action="">
                    <input type="hidden" name="action" value="register">
                    <label>NAS :</label>
                    <input type="text" name="regSIN" placeholder="Ex: 900000001" required>
                    <label>Nom complet :</label>
                    <input type="text" name="regName" placeholder="Ton nom" required>
                    <label>Adresse :</label>
                    <input type="text" name="regAddress" placeholder="Ton adresse" required>
                    <label>Pièce d'identité :</label>
                    <select name="regIdType"><option>Passeport</option><option>Permis</option><option>SIN</option></select>
                    <button type="submit">S'inscrire</button>
                </form>
            </div>
        </div>
    <% } %>
</body>
</html>