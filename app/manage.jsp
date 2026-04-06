<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="src.DBConnexion" %>
<%
    String empSIN = (String) session.getAttribute("empSIN");
    Integer empHotelID = (Integer) session.getAttribute("empHotelID");
    String action = request.getParameter("action");
    String message = "";

    // SÉCURITÉ CORRIGÉE : On vire le check d'URL capricieux. 
    // Si l'employé n'est pas connecté, on le redirige vers le login, pas de 404 !
    if (empSIN == null) {
        response.sendRedirect("employee_portal");
        return;
    }

    // --- CRUD : AJOUTER UNE CHAMBRE (Validation Stricte) ---
    if ("add_room".equals(action)) {
        try {
            // 1. Récupération et nettoyage des données
            String priceStr = request.getParameter("price");
            String capacity = request.getParameter("capacity");
            String view = request.getParameter("view");
            String extension = request.getParameter("extension");
            
            // Validation du prix côté serveur : $price \geq 50$
            double price = Double.parseDouble(priceStr);
            
            // Gestion des valeurs par défaut "Aucun"
            String amenities = request.getParameter("amenities");
            if (amenities == null || amenities.trim().isEmpty()) { amenities = "Aucun"; }
            
            String damage = request.getParameter("damage");
            if (damage == null || damage.trim().isEmpty()) { damage = "Aucun"; }

            if (price < 50.0) {
                message = "<div class='error'>❌ Erreur : Le prix doit être d'au moins 50,00 $.</div>";
            } else {
                try (Connection con = DBConnexion.getConnection()) {
                    con.setAutoCommit(false);
                    
                    // Trouver le prochain ID local pour CET hôtel et fabriquer l'ID global (HôtelID * 1000)
                    String sqlMax = "SELECT COALESCE(MAX(r.room_number % 1000), 0) + 1 FROM \"Room\" r JOIN \"HotelContains\" hc ON r.room_number = hc.room_number WHERE hc.hotel_ID = ?";
                    PreparedStatement psMax = con.prepareStatement(sqlMax);
                    psMax.setInt(1, empHotelID);
                    ResultSet rsMax = psMax.executeQuery();
                    rsMax.next();
                    int nextLocalNum = rsMax.getInt(1);
                    int nextR = (empHotelID * 1000) + nextLocalNum;

                    // Insertion dans Room
                    String sqlRoom = "INSERT INTO \"Room\" (room_number, price, capacity, amenities, damage, view, extension) VALUES (?, ?, ?, ?, ?, ?, ?)";
                    PreparedStatement psR = con.prepareStatement(sqlRoom);
                    psR.setInt(1, nextR);
                    psR.setDouble(2, price);
                    psR.setString(3, capacity);
                    psR.setString(4, amenities);
                    psR.setString(5, damage);
                    psR.setString(6, view);
                    psR.setString(7, extension);
                    psR.executeUpdate();

                    // Liaison Hôtel
                    PreparedStatement psL = con.prepareStatement("INSERT INTO \"HotelContains\" (hotel_ID, room_number) VALUES (?, ?)");
                    psL.setInt(1, empHotelID);
                    psL.setInt(2, nextR);
                    psL.executeUpdate();

                    // Mise à jour capacité hôtel
                    PreparedStatement psU = con.prepareStatement("UPDATE \"Hotel\" SET number_of_rooms = (SELECT COUNT(*) FROM \"HotelContains\" WHERE hotel_ID = ?) WHERE hotel_ID = ?");
                    psU.setInt(1, empHotelID);
                    psU.setInt(2, empHotelID);
                    psU.executeUpdate();

                    con.commit();
                    message = "<div class='success'>✅ Chambre N° " + nextLocalNum + " créée ! Les champs vides ont été réglés sur 'Aucun'.</div>";
                }
            }
        } catch (NumberFormatException e) {
            message = "<div class='error'>❌ Erreur : Format de prix invalide.</div>";
        } catch (Exception e) {
            message = "<div class='error'>⚠️ Erreur DB : " + e.getMessage() + "</div>";
        }
    }

    // --- CRUD : SUPPRIMER UNE CHAMBRE ---
    if ("delete_room".equals(action)) {
        String rNumStr = request.getParameter("room_number");
        if (rNumStr != null) {
            int rNum = Integer.parseInt(rNumStr);
            try (Connection con = DBConnexion.getConnection()) {
                con.setAutoCommit(false);
                PreparedStatement ps1 = con.prepareStatement("DELETE FROM \"HotelContains\" WHERE room_number = ?");
                ps1.setInt(1, rNum); ps1.executeUpdate();
                
                PreparedStatement ps2 = con.prepareStatement("DELETE FROM \"Room\" WHERE room_number = ?");
                ps2.setInt(1, rNum); ps2.executeUpdate();

                PreparedStatement ps3 = con.prepareStatement("UPDATE \"Hotel\" SET number_of_rooms = (SELECT count(*) FROM \"HotelContains\" WHERE hotel_ID = ?) WHERE hotel_ID = ?");
                ps3.setInt(1, empHotelID); ps3.setInt(2, empHotelID);
                ps3.executeUpdate();

                con.commit();
                message = "<div class='success'>🗑️ Chambre supprimée avec succès.</div>";
            } catch (Exception e) { message = "<div class='error'>Erreur : " + e.getMessage() + "</div>"; }
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Gestion Hôtel - e-Hôtels</title>
    <style>
        body { font-family: 'Segoe UI', sans-serif; background: #f8f9fa; padding: 20px; }
        .container { max-width: 1000px; margin: auto; }
        .card { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); margin-bottom: 25px; }
        .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-top: 15px; }
        label { font-weight: bold; display: block; margin-bottom: 5px; color: #34495e; }
        input, select, textarea { width: 100%; padding: 12px; border: 1px solid #ced4da; border-radius: 6px; box-sizing: border-box; font-size: 14px; }
        textarea { resize: vertical; }
        th { background: #34495e; color: white; padding: 15px; text-align: left; }
        td { padding: 12px; border-bottom: 1px solid #dee2e6; }
        .btn-add { background: #27ae60; color: white; border: none; padding: 15px; width: 100%; border-radius: 6px; cursor: pointer; font-weight: bold; font-size: 16px; margin-top: 20px; transition: 0.3s; }
        .btn-add:hover { background: #219150; }
        .success { background: #d4edda; color: #155724; padding: 15px; border-radius: 6px; margin-bottom: 20px; border: 1px solid #c3e6cb; }
        .error { background: #f8d7da; color: #721c24; padding: 15px; border-radius: 6px; margin-bottom: 20px; border: 1px solid #f5c6cb; }
        .btn-del { color: #e74c3c; background: none; border: 1px solid #e74c3c; padding: 5px 10px; border-radius: 4px; cursor: pointer; font-weight: bold; }
        .btn-del:hover { background: #e74c3c; color: white; }
    </style>
</head>
<body>
    <div class="container">
        <h1>⚙️ Administration Hôtel (ID: <%= empHotelID %>)</h1>
        <%= message %>
        <p><a href="employee_portal" style="text-decoration: none; color: #3498db; font-weight: bold;">⬅️ Retour au tableau de bord</a></p>

        <div class="card">
            <h3>➕ Ajouter une nouvelle chambre</h3>
            <form method="POST">
                <input type="hidden" name="action" value="add_room">
                <div class="form-grid">
                    <div>
                        <label>Prix par nuit ($) <span style="color:red">*</span></label>
                        <input type="number" step="0.01" min="50" name="price" placeholder="Min 50.00" required>
                    </div>
                    <div>
                        <label>Capacité</label>
                        <select name="capacity">
                            <option>Simple</option><option>Double</option><option>Triple</option><option>King</option><option>Queen</option>
                        </select>
                    </div>
                    <div>
                        <label>Vue</label>
                        <select name="view">
                            <option>Ville</option><option>Mer</option><option>Montagne</option><option>Panoramique</option><option>Cour intérieure</option>
                        </select>
                    </div>
                    <div>
                        <label>Extension possible ?</label>
                        <select name="extension">
                            <option>Non</option><option>Oui</option>
                        </select>
                    </div>
                </div>
                <div style="margin-top: 15px;">
                    <label>Commodités (Wifi, TV, Machine à café...)</label>
                    <textarea name="amenities" rows="2" placeholder="Laissez vide pour mettre 'Aucun'"></textarea>
                </div>
                <div style="margin-top: 15px;">
                    <label>État / Dommages (Taches, réparations à faire...)</label>
                    <textarea name="damage" rows="2" placeholder="Laissez vide pour mettre 'Aucun'"></textarea>
                </div>
                <button type="submit" class="btn-add">Enregistrer la chambre</button>
            </form>
        </div>

        <div class="card">
            <h3>📋 Inventaire des chambres</h3>
            <table style="width: 100%;">
                <thead>
                    <tr>
                        <th>Chambre</th>
                        <th>Prix</th>
                        <th>Capacité</th>
                        <th>Vue</th>
                        <th>Commodités</th> 
                        <th>État</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% try (Connection con = DBConnexion.getConnection()) {
                        String sql = "SELECT r.* FROM \"Room\" r JOIN \"HotelContains\" hc ON r.room_number = hc.room_number WHERE hc.hotel_ID = ? ORDER BY r.room_number DESC";
                        PreparedStatement ps = con.prepareStatement(sql);
                        ps.setInt(1, empHotelID);
                        ResultSet rs = ps.executeQuery();
                        boolean hasRooms = false;
                        while(rs.next()){ 
                            hasRooms = true;
                    %>
                        <tr>
                            <td>
                                <strong>N° <%= rs.getInt("room_number") % 1000 %></strong><br>
                                <small style="color:#7f8c8d;">(ID: #<%= rs.getInt("room_number") %>)</small>
                            </td>
                            <td><%= rs.getDouble("price") %> $</td>
                            <td><%= rs.getString("capacity") %></td>
                            <td><%= rs.getString("view") %></td>
                            <td><%= rs.getString("amenities") %></td> 
                            <td><small><%= rs.getString("damage") %></small></td>
                            <td>
                                <form method="POST" style="margin:0">
                                    <input type="hidden" name="action" value="delete_room">
                                    <input type="hidden" name="room_number" value="<%= rs.getInt("room_number") %>">
                                    <button type="submit" class="btn-del" onclick="return confirm('Confirmer la suppression ?')">Supprimer</button>
                                </form>
                            </td>
                        </tr>
                    <% } 
                        if(!hasRooms) { %> <tr><td colspan="7" style="text-align:center; padding:20px; color:#7f8c8d;">Aucune chambre enregistrée.</td></tr> <% }
                    } catch(Exception e){ out.print("Erreur : " + e.getMessage()); } %>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>