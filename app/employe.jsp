<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="src.DBConnexion" %>
<%
    // 1. DÉCLARATION ET VARIABLES
    String empSIN = (String) session.getAttribute("empSIN");
    Integer empHotelID = (Integer) session.getAttribute("empHotelID");
    String action = request.getParameter("action");
    String hotelAddress = "";
    
    // --- GESTION DES MESSAGES FLASH (Pour éviter le bug du F5) ---
    String message = "";
    if (session.getAttribute("flashMessage") != null) {
        message = (String) session.getAttribute("flashMessage");
        session.removeAttribute("flashMessage");
    }

    // DÉCONNEXION
    if ("logout".equals(action)) {
        session.invalidate();
        response.sendRedirect(request.getRequestURI());
        return;
    }

    // 2. LOGIQUE DE CONNEXION
    if ("login".equals(action)) {
        String sin = request.getParameter("loginSIN");
        try (Connection con = DBConnexion.getConnection()) {
            PreparedStatement pstmt = con.prepareStatement("SELECT employee_SIN, hotel_id, full_name FROM \"Employee\" WHERE employee_SIN = ?");
            pstmt.setString(1, sin);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                session.setAttribute("empSIN", rs.getString("employee_SIN"));
                session.setAttribute("empHotelID", rs.getInt("hotel_id"));
                session.setAttribute("empName", rs.getString("full_name"));
                response.sendRedirect(request.getRequestURI());
                return;
            } else {
                message = "<div class='error'>❌ Identifiants employés incorrects.</div>";
            }
        } catch (Exception e) { message = "Erreur login : " + e.getMessage(); }
    }

    // 3. RÉCUPÉRATION ADRESSE HÔTEL
    if (empHotelID != null) {
        try (Connection con = DBConnexion.getConnection()) {
            PreparedStatement pstmt = con.prepareStatement("SELECT address FROM \"Hotel\" WHERE hotel_ID = ?");
            pstmt.setInt(1, empHotelID);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) { hotelAddress = rs.getString("address"); }
        } catch (Exception e) { }
    }

    // 4. LOGIQUE DE CHECK-IN / ANNULATION (AVEC REDIRECTION ANTI-F5)
    if (empSIN != null) {
        if ("checkin".equals(action)) {
            String bNum = request.getParameter("booking_number");
            String rNum = request.getParameter("room_number");
            try (Connection con = DBConnexion.getConnection()) {
                con.setAutoCommit(false);
                String sqlRent = "INSERT INTO \"Renting\" (renting_number, room_number) VALUES ((SELECT COALESCE(MAX(renting_number),0)+1 FROM \"Renting\"), ?)";
                PreparedStatement psRent = con.prepareStatement(sqlRent);
                psRent.setInt(1, Integer.parseInt(rNum));
                psRent.executeUpdate();
                
                Statement stmt = con.createStatement();
                ResultSet rsRent = stmt.executeQuery("SELECT MAX(renting_number) FROM \"Renting\"");
                rsRent.next();
                int newRentingNum = rsRent.getInt(1);

                String sqlLink = "INSERT INTO \"RoomHas\" (booking_number, renting_number) VALUES (?, ?)";
                PreparedStatement psLink = con.prepareStatement(sqlLink);
                psLink.setInt(1, Integer.parseInt(bNum));
                psLink.setInt(2, newRentingNum);
                psLink.executeUpdate();
                con.commit();
                
                session.setAttribute("flashMessage", "<div class='success'>✅ Client enregistré !</div>");
                response.sendRedirect(request.getRequestURI());
                return;
                
            } catch (Exception e) { 
                session.setAttribute("flashMessage", "<div class='error'>Erreur : " + e.getMessage() + "</div>");
                response.sendRedirect(request.getRequestURI());
                return;
            }
        }
        else if ("cancel_checkin".equals(action)) {
            String rentNum = request.getParameter("renting_number");
            try (Connection con = DBConnexion.getConnection()) {
                con.setAutoCommit(false);
                PreparedStatement ps1 = con.prepareStatement("DELETE FROM \"RoomHas\" WHERE renting_number = ?");
                ps1.setInt(1, Integer.parseInt(rentNum)); ps1.executeUpdate();
                PreparedStatement ps2 = con.prepareStatement("DELETE FROM \"Renting\" WHERE renting_number = ?");
                ps2.setInt(1, Integer.parseInt(rentNum)); ps2.executeUpdate();
                con.commit();
                
                session.setAttribute("flashMessage", "<div class='success'>✅ Check-in annulé avec succès.</div>");
                response.sendRedirect(request.getRequestURI());
                return;
                
            } catch (Exception e) { 
                session.setAttribute("flashMessage", "<div class='error'>Erreur : " + e.getMessage() + "</div>");
                response.sendRedirect(request.getRequestURI());
                return;
            }
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Espace Staff - e-Hôtels</title>
    <style>
        :root { --primary: #2c3e50; --secondary: #34495e; --accent: #3498db; --success: #27ae60; --warning: #f1c40f; --danger: #e74c3c; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f8f9fa; margin: 0; display: flex; min-height: 100vh; }
        .sidebar { width: 250px; background: var(--primary); color: white; padding: 20px; display: flex; flex-direction: column; }
        .main-content { flex: 1; padding: 40px; overflow-y: auto; }
        .card { background: white; padding: 25px; border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); margin-bottom: 30px; }
        table { width: 100%; border-collapse: collapse; background: white; border-radius: 8px; overflow: hidden; }
        th, td { padding: 15px; text-align: left; border-bottom: 1px solid #edf2f7; }
        th { background: #f7fafc; color: var(--secondary); text-transform: uppercase; font-size: 0.8rem; letter-spacing: 0.05em; }
        .btn { padding: 10px 18px; border: none; border-radius: 6px; cursor: pointer; font-weight: 600; transition: 0.2s; text-decoration: none; display: inline-block; }
        .btn-checkin { background: var(--warning); color: var(--primary); }
        .btn-cancel { background: transparent; color: var(--danger); border: 1px solid var(--danger); font-size: 0.8em; }
        .btn-manage { background: var(--accent); color: white; width: 100%; text-align: center; margin-top: auto; }
        .badge-todo { background: #fffaf0; color: #9c4221; padding: 5px 10px; border-radius: 20px; font-size: 0.8em; font-weight: bold; }
        .badge-done { background: #f0fff4; color: #22543d; padding: 5px 10px; border-radius: 20px; font-size: 0.8em; font-weight: bold; }
        .success { background: #d4edda; color: #155724; padding: 15px; border-radius: 6px; margin-bottom: 20px; border: 1px solid #c3e6cb; }
        .error { background: #f8d7da; color: #721c24; padding: 15px; border-radius: 6px; margin-bottom: 20px; border: 1px solid #f5c6cb; }
    </style>
</head>
<body>

    <% if (empSIN == null) { %>
        <div style="margin: auto; width: 350px;" class="card">
            <h2 style="text-align:center;">Accès Staff</h2>
            <%= message %>
            <form method="POST">
                <input type="hidden" name="action" value="login">
                <input type="text" name="loginSIN" placeholder="Votre NAS" style="width:100%; padding:12px; margin:15px 0; border:1px solid #ddd; border-radius:6px;" required>
                <button type="submit" class="btn" style="background:var(--primary); color:white; width:100%;">Se connecter</button>
            </form>
        </div>
    <% } else { %>
        
        <div class="sidebar">
            <h2>e-Hôtels</h2>
            <p style="opacity: 0.7;">Dashboard Employé</p>
            <hr style="width:100%; border:0; border-top:1px solid rgba(255,255,255,0.1); margin: 20px 0;">
            <p><strong><%= session.getAttribute("empName") %></strong></p>
            <p style="font-size: 0.8em;"><%= hotelAddress %></p>
            
            <a href="management" class="btn btn-manage">⚙️ Gestion & CRUD</a>
            <form method="POST" style="margin-top:10px;">
                <input type="hidden" name="action" value="logout">
                <button type="submit" style="background:none; border:none; color:white; cursor:pointer; opacity:0.6; width:100%; text-align:left; padding:10px 0;">🚪 Déconnexion</button>
            </form>
        </div>

        <div class="main-content">
            <%= message %>
            
            <div class="card">
                <h3 style="color:var(--secondary);">⏳ Arrivées prévues aujourd'hui</h3>
                <table>
                    <thead><tr><th>Client</th><th>Chambre</th><th>Statut</th><th>Action</th></tr></thead>
                    <tbody>
                        <% try (Connection con = DBConnexion.getConnection()) {
                            // J'AI REMIS TA REQUÊTE AVEC LE ROW_NUMBER ICI
                            String sql = "WITH RN AS (SELECT room_number, ROW_NUMBER() OVER(PARTITION BY hotel_ID ORDER BY room_number) as num FROM \"HotelContains\") " +
                                         "SELECT b.booking_number, b.room_number, c.full_name, RN.num FROM \"Booking\" b " +
                                         "JOIN \"CustomerReserves\" cr ON b.booking_number = cr.booking_number " +
                                         "JOIN \"Customer\" c ON cr.customer_SIN = c.customer_SIN " +
                                         "JOIN \"HotelContains\" hc ON b.room_number = hc.room_number " +
                                         "JOIN RN ON b.room_number = RN.room_number " +
                                         "WHERE hc.hotel_ID = ? AND b.booking_number NOT IN (SELECT booking_number FROM \"RoomHas\")";
                            PreparedStatement ps = con.prepareStatement(sql);
                            ps.setInt(1, empHotelID);
                            ResultSet rs = ps.executeQuery();
                            while(rs.next()) { %>
                            <tr>
                                <td><%= rs.getString("full_name") %></td>
                                <td><strong style="color:var(--accent);">Chambre <%= rs.getInt("num") %></strong></td>
                                <td><span class="badge-todo">À ENREGISTRER</span></td>
                                <td>
                                    <form method="POST" style="margin:0">
                                        <input type="hidden" name="action" value="checkin">
                                        <input type="hidden" name="booking_number" value="<%= rs.getInt("booking_number") %>">
                                        <input type="hidden" name="room_number" value="<%= rs.getInt("room_number") %>">
                                        <button type="submit" class="btn btn-checkin">⚡ Check-in</button>
                                    </form>
                                </td>
                            </tr>
                        <% } } catch(Exception e){} %>
                    </tbody>
                </table>
            </div>

            <div class="card">
                <h3 style="color:var(--secondary);">✅ Locations en cours</h3>
                <table>
                    <thead><tr><th>ID Location</th><th>Client</th><th>Chambre</th><th>Statut</th><th>Action</th></tr></thead>
                    <tbody>
                        <% try (Connection con = DBConnexion.getConnection()) {
                            // ET J'AI REMIS TA REQUÊTE AVEC LE ROW_NUMBER ICI AUSSI
                            String sqlDone = "WITH RN AS (SELECT room_number, ROW_NUMBER() OVER(PARTITION BY hotel_ID ORDER BY room_number) as num FROM \"HotelContains\") " +
                                             "SELECT r.renting_number, r.room_number, c.full_name, RN.num FROM \"Renting\" r " +
                                             "JOIN \"RoomHas\" rh ON r.renting_number = rh.renting_number " +
                                             "JOIN \"CustomerReserves\" cr ON rh.booking_number = cr.booking_number " +
                                             "JOIN \"Customer\" c ON cr.customer_SIN = c.customer_SIN " +
                                             "JOIN \"HotelContains\" hc ON r.room_number = hc.room_number " +
                                             "JOIN RN ON r.room_number = RN.room_number " +
                                             "WHERE hc.hotel_ID = ?";
                            PreparedStatement psD = con.prepareStatement(sqlDone);
                            psD.setInt(1, empHotelID);
                            ResultSet rsD = psD.executeQuery();
                            while(rsD.next()) { %>
                            <tr>
                                <td>#<%= rsD.getInt("renting_number") %></td>
                                <td><%= rsD.getString("full_name") %></td>
                                <td><strong>Chambre <%= rsD.getInt("num") %></strong></td>
                                <td><span class="badge-done">OCCUPÉE</span></td>
                                <td>
                                    <form method="POST" style="margin:0">
                                        <input type="hidden" name="action" value="cancel_checkin">
                                        <input type="hidden" name="renting_number" value="<%= rsD.getInt("renting_number") %>">
                                        <button type="submit" class="btn btn-cancel" onclick="return confirm('Annuler ?')">Annuler</button>
                                    </form>
                                </td>
                            </tr>
                        <% } } catch(Exception e){} %>
                    </tbody>
                </table>
            </div>
        </div>
    <% } %>
</body>
</html>