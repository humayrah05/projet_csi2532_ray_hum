<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="src.DBConnexion" %>
<%
    // 1. DÉCLARATION DES VARIABLES & LOGIQUE D'URL
    String uri = request.getRequestURI();
    String userSIN = (String) session.getAttribute("userSIN");
    String action = request.getParameter("action");
    String bookMessage = "";

    if (uri.endsWith(".jsp")) {
        response.sendError(404);
        return;
    }

    if (uri.endsWith("/ehotel/")) {
        response.sendRedirect("rooms");
        return;
    }

    if (!uri.endsWith("/rooms")) {
        response.sendError(404);
        return; 
    }

    // 2. LOGIQUE DE RÉSERVATION
    if ("book".equals(action) && userSIN != null) {
        String rNumStr = request.getParameter("room_number");
        try (Connection con = DBConnexion.getConnection()) {
            con.setAutoCommit(false);
            int rNum = Integer.parseInt(rNumStr);

            String sqlB = "INSERT INTO \"Booking\" (booking_number, room_number) VALUES ((SELECT COALESCE(MAX(booking_number),0)+1 FROM \"Booking\"), ?)";
            PreparedStatement ps1 = con.prepareStatement(sqlB);
            ps1.setInt(1, rNum);
            ps1.executeUpdate();
            
            String sqlC = "INSERT INTO \"CustomerReserves\" (customer_SIN, room_number, booking_number) VALUES (?, ?, (SELECT MAX(booking_number) FROM \"Booking\"))";
            PreparedStatement ps2 = con.prepareStatement(sqlC);
            ps2.setString(1, userSIN);
            ps2.setInt(2, rNum);
            ps2.executeUpdate();
            
            con.commit();
            response.sendRedirect("customer_account");
            return;
        } catch (Exception e) { 
            bookMessage = "Erreur : " + e.getMessage(); 
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>e-Hôtels - Chambres Disponibles</title>
    <style>
        body { font-family: sans-serif; padding: 20px; background: #f4f7f6; }
        .header { display: flex; justify-content: space-between; align-items: center; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; background: white; }
        th, td { border: 1px solid #ddd; padding: 12px; text-align: left; }
        th { background: #2c3e50; color: white; }
        .btn-book { background: #27ae60; color: white; border: none; padding: 8px 15px; border-radius: 4px; cursor: pointer; font-weight: bold; }
    </style>
</head>
<body>

    <div class="header">
        <h1>🔍 Chambres Disponibles</h1>
        <% if (userSIN != null) { %>
            <a href="customer_account" style="text-decoration:none; font-weight:bold; color:#3498db;">🏠 Retour à mon compte</a>
        <% } else { %>
            <a href="customer_account" style="text-decoration:none; font-weight:bold; color:#e67e22;">🔑 Se connecter ou S'inscrire</a>
        <% } %>
    </div>

    <% if (!bookMessage.isEmpty()) { %>
        <p style="color:red; background:#ffdada; padding:10px; border-radius:5px;"><%= bookMessage %></p>
    <% } %>

    <table>
        <thead>
            <tr>
                <th>Hôtel</th>
                <th>Chambre</th>
                <th>Prix</th>
                <% if (userSIN != null) { %>
                    <th>Action</th>
                <% } %>
            </tr>
        </thead>
        <tbody>
            <%
                try (Connection conTable = DBConnexion.getConnection()) {
                    String sql = "WITH RN AS (SELECT room_number, ROW_NUMBER() OVER(PARTITION BY hotel_ID ORDER BY room_number) as num FROM \"HotelContains\") " +
                                 "SELECT r.room_number, r.price, h.address, RN.num FROM \"Room\" r " +
                                 "JOIN \"HotelContains\" hc ON r.room_number = hc.room_number " +
                                 "JOIN \"Hotel\" h ON hc.hotel_ID = h.hotel_ID " +
                                 "JOIN RN ON r.room_number = RN.room_number " +
                                 "WHERE r.room_number NOT IN (SELECT room_number FROM \"Booking\") " +
                                 "ORDER BY h.address, RN.num";
                    
                    Statement stmt = conTable.createStatement();
                    ResultSet rs = stmt.executeQuery(sql);
                    while(rs.next()) {
            %>
                <tr>
                    <td><%= rs.getString("address") %></td>
                    <td><strong>Chambre N° <%= rs.getInt("num") %></strong></td>
                    <td><%= rs.getDouble("price") %> $</td>
                    
                    <% if (userSIN != null) { %>
                        <td>
                            <form method="POST" action="">
                                <input type="hidden" name="action" value="book">
                                <input type="hidden" name="room_number" value="<%= rs.getInt("room_number") %>">
                                <button type="submit" class="btn-book">⚡ Réserver</button>
                            </form>
                        </td>
                    <% } %>
                </tr>
            <% 
                    }
                } catch(Exception e) {
                    out.println("Erreur table : " + e.getMessage());
                }
            %>
        </tbody>
    </table>

</body>
</html>