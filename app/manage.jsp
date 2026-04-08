<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="src.DBConnexion" %>
<%
    // Force l'encodage en UTF-8 pour ne jamais perdre les accents lors de l'ajout/modification
    request.setCharacterEncoding("UTF-8");

    String empSIN = (String) session.getAttribute("empSIN");
    Integer empHotelID = (Integer) session.getAttribute("empHotelID");
    String action = request.getParameter("action");
    String message = "";

    if (empSIN == null) {
        response.sendRedirect("employee_portal");
        return;
    }

    // --- CRUD : AJOUTER UNE CHAMBRE ---
    if ("add_room".equals(action)) {
        try {
            String priceStr = request.getParameter("price");
            String capacity = request.getParameter("capacity");
            String view = request.getParameter("view");
            String extension = request.getParameter("extension");
            
            double price = Double.parseDouble(priceStr);
            String amenities = request.getParameter("amenities");
            if (amenities == null || amenities.trim().isEmpty()) { amenities = "Aucun"; }
            String damage = request.getParameter("damage");
            if (damage == null || damage.trim().isEmpty()) { damage = "Aucun"; }

            if (price < 50.0) {
                message = "<div class='error'>❌ Erreur : Le prix doit être d'au moins 50,00 $.</div>";
            } else {
                try (Connection con = DBConnexion.getConnection()) {
                    con.setAutoCommit(false);
                    
                    String sqlMax = "SELECT COALESCE(MAX(r.room_number % 1000), 0) + 1 FROM public.room r JOIN public.hotelcontains hc ON r.room_number = hc.room_number WHERE hc.hotel_id = ?";
                    PreparedStatement psMax = con.prepareStatement(sqlMax);
                    psMax.setInt(1, empHotelID);
                    ResultSet rsMax = psMax.executeQuery();
                    rsMax.next();
                    int nextLocalNum = rsMax.getInt(1);
                    int nextR = (empHotelID * 1000) + nextLocalNum;

                    String sqlRoom = "INSERT INTO public.room (room_number, price, capacity, amenities, damage, view, extension) VALUES (?, ?, ?, ?, ?, ?, ?)";
                    PreparedStatement psR = con.prepareStatement(sqlRoom);
                    psR.setInt(1, nextR);
                    psR.setDouble(2, price);
                    psR.setString(3, capacity);
                    psR.setString(4, amenities);
                    psR.setString(5, damage);
                    psR.setString(6, view);
                    psR.setString(7, extension);
                    psR.executeUpdate();

                    PreparedStatement psL = con.prepareStatement("INSERT INTO public.hotelcontains (hotel_id, room_number) VALUES (?, ?)");
                    psL.setInt(1, empHotelID);
                    psL.setInt(2, nextR);
                    psL.executeUpdate();

                    PreparedStatement psU = con.prepareStatement("UPDATE public.hotel SET number_of_rooms = (SELECT COUNT(*) FROM public.hotelcontains WHERE hotel_id = ?) WHERE hotel_id = ?");
                    psU.setInt(1, empHotelID);
                    psU.setInt(2, empHotelID);
                    psU.executeUpdate();

                    con.commit();
                    message = "<div class='success'>✅ Chambre N° " + nextLocalNum + " créée avec succès !</div>";
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
                PreparedStatement ps1 = con.prepareStatement("DELETE FROM public.hotelcontains WHERE room_number = ?");
                ps1.setInt(1, rNum); ps1.executeUpdate();
                
                PreparedStatement ps2 = con.prepareStatement("DELETE FROM public.room WHERE room_number = ?");
                ps2.setInt(1, rNum); ps2.executeUpdate();

                PreparedStatement ps3 = con.prepareStatement("UPDATE public.hotel SET number_of_rooms = (SELECT count(*) FROM public.hotelcontains WHERE hotel_id = ?) WHERE hotel_id = ?");
                ps3.setInt(1, empHotelID); ps3.setInt(2, empHotelID);
                ps3.executeUpdate();

                con.commit();
                message = "<div class='success'>🗑️ Chambre supprimée avec succès.</div>";
            } catch (Exception e) { message = "<div class='error'>Erreur : " + e.getMessage() + "</div>"; }
        }
    }

    // --- CRUD : METTRE À JOUR UNE CHAMBRE ---
    if ("update_room".equals(action)) {
        try {
            int rNum = Integer.parseInt(request.getParameter("room_number"));
            double price = Double.parseDouble(request.getParameter("price"));
            String capacity = request.getParameter("capacity");
            String view = request.getParameter("view");
            String extension = request.getParameter("extension");
            
            String amenities = request.getParameter("amenities");
            if (amenities == null || amenities.trim().isEmpty()) { amenities = "Aucun"; }
            
            String damage = request.getParameter("damage");
            if (damage == null || damage.trim().isEmpty()) { damage = "Aucun"; }

            if (price < 50.0) {
                message = "<div class='error'>❌ Erreur : Le prix doit être d'au moins 50,00 $.</div>";
            } else {
                try (Connection con = DBConnexion.getConnection()) {
                    String sqlUpdate = "UPDATE public.room SET price = ?, capacity = ?, view = ?, extension = ?, amenities = ?, damage = ? WHERE room_number = ?";
                    PreparedStatement psU = con.prepareStatement(sqlUpdate);
                    psU.setDouble(1, price);
                    psU.setString(2, capacity);
                    psU.setString(3, view);
                    psU.setString(4, extension);
                    psU.setString(5, amenities);
                    psU.setString(6, damage);
                    psU.setInt(7, rNum);
                    psU.executeUpdate();
                    message = "<div class='success'>✅ Chambre mise à jour avec succès !</div>";
                }
            }
        } catch (Exception e) {
            message = "<div class='error'>⚠️ Erreur de mise à jour : " + e.getMessage() + "</div>";
        }
    }

    // --- PRÉ-REMPLISSAGE POUR LE MODE ÉDITION ---
    boolean isEditMode = "edit_room".equals(action);
    int editRoomNumber = 0;
    double editPrice = 0;
    String editCapacity = "", editView = "", editExtension = "", editAmenities = "", editDamage = "";

    if (isEditMode) {
        String rNumStr = request.getParameter("room_number");
        if (rNumStr != null) {
            editRoomNumber = Integer.parseInt(rNumStr);
            try (Connection con = DBConnexion.getConnection()) {
                PreparedStatement ps = con.prepareStatement("SELECT * FROM public.room WHERE room_number = ?");
                ps.setInt(1, editRoomNumber);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    editPrice = rs.getDouble("price");
                    editCapacity = rs.getString("capacity");
                    editView = rs.getString("view");
                    editExtension = rs.getString("extension");
                    editAmenities = rs.getString("amenities");
                    if ("Aucun".equals(editAmenities)) editAmenities = "";
                    editDamage = rs.getString("damage");
                    if ("Aucun".equals(editDamage)) editDamage = "";
                }
            } catch (Exception e) { message = "<div class='error'>Erreur chargement : " + e.getMessage() + "</div>"; }
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
        .container { max-width: 1100px; margin: auto; }
        .card { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); margin-bottom: 25px; }
        .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-top: 15px; }
        label { font-weight: bold; display: block; margin-bottom: 5px; color: #34495e; }
        input, select, textarea { width: 100%; padding: 12px; border: 1px solid #ced4da; border-radius: 6px; box-sizing: border-box; font-size: 14px; }
        textarea { resize: vertical; }
        th { background: #34495e; color: white; padding: 15px; text-align: left; }
        td { padding: 12px; border-bottom: 1px solid #dee2e6; }
        .btn-add { background: #27ae60; color: white; border: none; padding: 15px; width: 100%; border-radius: 6px; cursor: pointer; font-weight: bold; font-size: 16px; margin-top: 20px; transition: 0.3s; }
        .btn-add:hover { background: #219150; }
        .btn-update { background: #3498db; color: white; border: none; padding: 15px; width: 100%; border-radius: 6px; cursor: pointer; font-weight: bold; font-size: 16px; margin-top: 20px; transition: 0.3s; }
        .btn-update:hover { background: #2980b9; }
        .btn-cancel { background: #95a5a6; color: white; border: none; padding: 15px; width: 100%; border-radius: 6px; cursor: pointer; font-weight: bold; font-size: 16px; margin-top: 10px; display: block; text-align: center; text-decoration: none; box-sizing: border-box; }
        .btn-cancel:hover { background: #7f8c8d; }
        .success { background: #d4edda; color: #155724; padding: 15px; border-radius: 6px; margin-bottom: 20px; border: 1px solid #c3e6cb; }
        .error { background: #f8d7da; color: #721c24; padding: 15px; border-radius: 6px; margin-bottom: 20px; border: 1px solid #f5c6cb; }
        .btn-del { color: #e74c3c; background: none; border: 1px solid #e74c3c; padding: 5px 10px; border-radius: 4px; cursor: pointer; font-weight: bold; }
        .btn-del:hover { background: #e74c3c; color: white; }
        .btn-edit-small { color: #3498db; background: none; border: 1px solid #3498db; padding: 5px 10px; border-radius: 4px; cursor: pointer; font-weight: bold; margin-bottom: 5px; width: 100%; display: block; text-align: center; box-sizing: border-box; }
        .btn-edit-small:hover { background: #3498db; color: white; }
        .action-cell form { margin: 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>⚙️ Administration Hôtel (ID: <%= empHotelID %>)</h1>
        <%= message %>
        <p><a href="employee_portal" style="text-decoration: none; color: #3498db; font-weight: bold;">⬅️ Retour au tableau de bord</a></p>

        <div class="card">
            <% if (isEditMode) { %>
                <h3 style="color: #3498db;">✏️ Modifier la chambre N° <%= editRoomNumber % 1000 %></h3>
                <form method="POST">
                    <input type="hidden" name="action" value="update_room">
                    <input type="hidden" name="room_number" value="<%= editRoomNumber %>">
                    <div class="form-grid">
                        <div>
                            <label>Prix par nuit ($) <span style="color:red">*</span></label>
                            <input type="number" step="0.01" min="50" name="price" value="<%= editPrice %>" required>
                        </div>
                        <div>
                            <label>Capacité</label>
                            <select name="capacity">
                                <option <%= "Simple".equals(editCapacity) ? "selected" : "" %>>Simple</option>
                                <option <%= "Double".equals(editCapacity) ? "selected" : "" %>>Double</option>
                                <option <%= "Triple".equals(editCapacity) ? "selected" : "" %>>Triple</option>
                                <option <%= "King".equals(editCapacity) ? "selected" : "" %>>King</option>
                                <option <%= "Queen".equals(editCapacity) ? "selected" : "" %>>Queen</option>
                            </select>
                        </div>
                        <div>
                            <label>Vue</label>
                            <select name="view">
                                <option value="Vue panoramique sur la ville" <%= "Vue panoramique sur la ville".equals(editView) ? "selected" : "" %>>Vue panoramique sur la ville</option>
                                <option value="Vue sur la cour intérieure" <%= "Vue sur la cour intérieure".equals(editView) ? "selected" : "" %>>Vue sur la cour int&eacute;rieure</option>
                                <option value="Vue dégagée" <%= "Vue dégagée".equals(editView) ? "selected" : "" %>>Vue d&eacute;gag&eacute;e</option>
                                <option value="Vue sur l'océan / rivière" <%= "Vue sur l'océan / rivière".equals(editView) ? "selected" : "" %>>Vue sur l'oc&eacute;an / rivi&egrave;re</option>
                                <option value="Vue standard (stationnement)" <%= "Vue standard (stationnement)".equals(editView) ? "selected" : "" %>>Vue standard (stationnement)</option>
                            </select>
                        </div>
                        <div>
                            <label>Extension possible ?</label>
                            <select name="extension">
                                <option <%= "Non".equals(editExtension) ? "selected" : "" %>>Non</option>
                                <option <%= "Oui".equals(editExtension) ? "selected" : "" %>>Oui</option>
                            </select>
                        </div>
                    </div>
                    <div style="margin-top: 15px;">
                        <label>Commodités (Wifi, TV...)</label>
                        <textarea name="amenities" rows="2" placeholder="Laissez vide pour 'Aucun'"><%= editAmenities %></textarea>
                    </div>
                    <div style="margin-top: 15px;">
                        <label>État / Dommages</label>
                        <textarea name="damage" rows="2" placeholder="Laissez vide pour 'Aucun'"><%= editDamage %></textarea>
                    </div>
                    <button type="submit" class="btn-update">💾 Enregistrer les modifications</button>
                    <a href="manage.jsp" class="btn-cancel">❌ Annuler</a>
                </form>
            <% } else { %>
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
                                <option value="Vue panoramique sur la ville">Vue panoramique sur la ville</option>
                                <option value="Vue sur la cour intérieure">Vue sur la cour int&eacute;rieure</option>
                                <option value="Vue dégagée">Vue d&eacute;gag&eacute;e</option>
                                <option value="Vue sur l'océan / rivière">Vue sur l'oc&eacute;an / rivi&egrave;re</option>
                                <option value="Vue standard (stationnement)">Vue standard (stationnement)</option>
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
                        <label>Commodités (Wifi, TV...)</label>
                        <textarea name="amenities" rows="2" placeholder="Laissez vide pour 'Aucun'"></textarea>
                    </div>
                    <div style="margin-top: 15px;">
                        <label>État / Dommages</label>
                        <textarea name="damage" rows="2" placeholder="Laissez vide pour 'Aucun'"></textarea>
                    </div>
                    <button type="submit" class="btn-add">➕ Enregistrer la chambre</button>
                </form>
            <% } %>
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
                        <th>Extension</th>
                        <th>Commodités</th> 
                        <th>État</th>
                        <th style="width:100px;">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% try (Connection con = DBConnexion.getConnection()) {
                        String sql = "SELECT r.* FROM public.room r JOIN public.hotelcontains hc ON r.room_number = hc.room_number WHERE hc.hotel_id = ? ORDER BY r.room_number DESC";
                        PreparedStatement ps = con.prepareStatement(sql);
                        ps.setInt(1, empHotelID);
                        ResultSet rs = ps.executeQuery();
                        boolean hasRooms = false;
                        while(rs.next()){ 
                            hasRooms = true;
                            int rNum = rs.getInt("room_number");
                    %>
                        <tr>
                            <td>
                                <strong>N° <%= rNum % 1000 %></strong><br>
                                <small style="color:#7f8c8d;">(ID: #<%= rNum %>)</small>
                            </td>
                            <td><%= String.format("%.2f", rs.getDouble("price")) %> $</td>
                            <td><%= rs.getString("capacity") %></td>
                            <td><%= rs.getString("view") %></td>
                            <td><%= rs.getString("extension") %></td>
                            <td><%= rs.getString("amenities") %></td> 
                            <td><small><%= rs.getString("damage") %></small></td>
                            <td class="action-cell">
                                <form method="POST" style="margin-bottom: 5px;">
                                    <input type="hidden" name="action" value="edit_room">
                                    <input type="hidden" name="room_number" value="<%= rNum %>">
                                    <button type="submit" class="btn-edit-small">✏️ Éditer</button>
                                </form>
                                <form method="POST">
                                    <input type="hidden" name="action" value="delete_room">
                                    <input type="hidden" name="room_number" value="<%= rNum %>">
                                    <button type="submit" class="btn-del" style="width:100%; box-sizing:border-box;" onclick="return confirm('Confirmer la suppression de la chambre <%= rNum % 1000 %> ?')">🗑️ Supprimer</button>
                                </form>
                            </td>
                        </tr>
                    <% } 
                        if(!hasRooms) { %> <tr><td colspan="8" style="text-align:center; padding:20px; color:#7f8c8d;">Aucune chambre enregistrée.</td></tr> <% }
                    } catch(Exception e){ out.print("Erreur : " + e.getMessage()); } %>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>