<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="src.DBConnexion" %>
<%
    // 1. DÉCLARATION DES VARIABLES & VIGILE
    String uri = request.getRequestURI();
    
    // Sécurité A : Empêche l'accès direct par le nom du fichier .jsp
    if (uri.endsWith(".jsp")) {
        response.sendError(404);
        return;
    }

    // Sécurité B : Force l'utilisation de l'URL officielle /customer_account
    if (!uri.endsWith("/customer_account")) {
        response.sendError(404);
        return;
    }

    String action = request.getParameter("action");
    String message = "";
    
    // --- GESTION DU MESSAGE APRÈS REDIRECTION ---
    if (session.getAttribute("flash") != null) {
        message = (String) session.getAttribute("flash");
        session.removeAttribute("flash");
    }

    String userSIN = (String) session.getAttribute("userSIN");
    String userName = (String) session.getAttribute("userName");
    
    // 2. LOGIQUE ACTIONS (Login, Register, Delete)
    if (action != null) {
        try (Connection con = DBConnexion.getConnection()) {
            if (con != null) {
                // LOGIN
                if (action.equals("login")) {
                    String sin = request.getParameter("loginSIN");
                    PreparedStatement pstmt = con.prepareStatement("SELECT * FROM \"Customer\" WHERE customer_SIN = ?");
                    pstmt.setString(1, sin);
                    ResultSet rs = pstmt.executeQuery();
                    if (rs.next()) {
                        session.setAttribute("userSIN", sin); 
                        session.setAttribute("userName", rs.getString("full_name"));
                        response.sendRedirect("customer_account"); // REDIRECT POUR FIXER LE F5
                        return;
                    } else { 
                        message = "<div class='error'>❌ NAS incorrect.</div>"; 
                    }
                } 
                // REGISTER
                else if (action.equals("register")) {
                    PreparedStatement pstmt = con.prepareStatement("INSERT INTO \"Customer\" (customer_SIN, full_name, address, type_of_id, registration_date) VALUES (?, ?, ?, ?, CURRENT_DATE)");
                    pstmt.setString(1, request.getParameter("regSIN"));
                    pstmt.setString(2, request.getParameter("regName"));
                    pstmt.setString(3, request.getParameter("regAddress"));
                    pstmt.setString(4, request.getParameter("regIdType"));
                    pstmt.executeUpdate();
                    session.setAttribute("flash", "<div class='success'>✅ Compte créé avec succès !</div>");
                    response.sendRedirect("customer_account");
                    return;
                }
                // DELETE BOOKING
                else if (action.equals("delete_booking")) {
                    String bNum = request.getParameter("booking_number");
                    con.setAutoCommit(false);
                    PreparedStatement ps1 = con.prepareStatement("DELETE FROM \"CustomerReserves\" WHERE booking_number = ?");
                    ps1.setInt(1, Integer.parseInt(bNum));
                    ps1.executeUpdate();
                    PreparedStatement ps2 = con.prepareStatement("DELETE FROM \"Booking\" WHERE booking_number = ?");
                    ps2.setInt(1, Integer.parseInt(bNum));
                    ps2.executeUpdate();
                    con.commit();
                    session.setAttribute("flash", "<div class='success'>✅ Réservation annulée.</div>");
                    response.sendRedirect("customer_account"); // REDIRECT POUR FIXER LE F5
                    return;
                }
            }
        } catch (Exception e) { 
            message = "<div class='error'>⚠️ Erreur : " + e.getMessage() + "</div>"; 
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
        button { background-color: #3498db; color: white; border: none; padding: 12px 20px; margin-top: 25px; width: 100%; border-radius: 4px; cursor: pointer; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { border: 1px solid #ddd; padding: 10px; text-align: left; }
        th { background-color: #2c3e50; color: white; }
        .success { color: #155724; background-color: #d4edda; padding: 15px; border-radius: 4px; margin-bottom: 20px; text-align: center; }
        .error { color: #721c24; background-color: #f8d7da; padding: 15px; border-radius: 4px; margin-bottom: 20px; text-align: center; }
        .dashboard { background: white; padding: 40px; border-radius: 8px; box-shadow: 0 4px 8px rgba(0,0,0,0.1); max-width: 800px; margin: auto; text-align: center;}
    </style>
</head>
<body>
    <h1 style="text-align: center; color: #2c3e50;">👤 Portail Client</h1>
    <%= message %>

    <% if (session.getAttribute("userSIN") != null) { %>
        <div class="dashboard">
            <h2>Bonjour, <%= session.getAttribute("userName") %> ! 👋</h2>
            <a href="rooms" style="display:inline-block; background:#27ae60; color:white; padding:10px 20px; text-decoration:none; border-radius:5px; margin-bottom:20px;">🔍 Trouver une chambre</a>

            <h3>🗓️ Mes Réservations</h3>
            <table>
                <thead>
                    <tr>
                        <th>N° Réservation</th>
                        <th>Hôtel</th>
                        <th>Chambre</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try (Connection conRes = DBConnexion.getConnection()) {
                            String sqlRes = "WITH RN AS (SELECT room_number, ROW_NUMBER() OVER(PARTITION BY hotel_ID ORDER BY room_number) as num FROM \"HotelContains\") " +
                                            "SELECT b.booking_number, b.room_number, h.address, RN.num FROM \"Booking\" b " +
                                            "JOIN \"CustomerReserves\" cr ON b.booking_number = cr.booking_number " +
                                            "JOIN \"HotelContains\" hc ON b.room_number = hc.room_number " +
                                            "JOIN \"Hotel\" h ON hc.hotel_ID = h.hotel_ID " +
                                            "JOIN RN ON b.room_number = RN.room_number " +
                                            "WHERE cr.customer_SIN = ?";
                            PreparedStatement pstmtRes = conRes.prepareStatement(sqlRes);
                            pstmtRes.setString(1, (String)session.getAttribute("userSIN"));
                            ResultSet rsRes = pstmtRes.executeQuery();
                            while (rsRes.next()) {
                    %>
                            <tr>
                                <td>#<%= rsRes.getInt("booking_number") %></td>
                                <td><%= rsRes.getString("address") %></td>
                                <td><strong>Chambre <%= rsRes.getInt("num") %></strong></td>
                                <td>
                                    <form method="POST" action="">
                                        <input type="hidden" name="action" value="delete_booking">
                                        <input type="hidden" name="booking_number" value="<%= rsRes.getInt("booking_number") %>">
                                        <button type="submit" style="background:#e74c3c; width:auto; margin:0; padding:5px 10px;" onclick="return confirm('Annuler ?')">Annuler</button>
                                    </form>
                                </td>
                            </tr>
                    <%      } 
                        } catch(Exception e) { out.println("Erreur reservations : " + e.getMessage()); }
                    %>
                </tbody>
            </table>
            <form method="POST" action=""><input type="hidden" name="action" value="logout"><button type="submit" style="background:#7f8c8d; width:auto;">Se déconnecter</button></form>
        </div>
    <% } else { %>
        <div class="container">
            <div class="box">
                <h2>Connexion</h2>
                <form method="POST" action="">
                    <input type="hidden" name="action" value="login"><label>NAS :</label>
                    <input type="text" name="loginSIN" pattern="\d{3}-\d{3}-\d{3}" required><button type="submit">Entrer</button>
                </form>
            </div>
            <div class="box">
                <h2>Inscription</h2>
                <form method="POST" action="">
                    <input type="hidden" name="action" value="register">
                    <input type="text" name="regSIN" placeholder="NAS" pattern="\d{3}-\d{3}-\d{3}" required>
                    <input type="text" name="regName" placeholder="Nom complet" required>
                    <input type="text" name="regAddress" placeholder="Adresse" required>
                    <select name="regIdType"><option>Passeport</option><option>Permis</option></select>
                    <button type="submit">S'inscrire</button>
                </form>
            </div>
        </div>
    <% } %>
</body>
</html>