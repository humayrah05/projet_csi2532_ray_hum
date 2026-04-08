<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="src.DBConnexion" %>
<%
    // 1. DÉCLARATION DES VARIABLES
    String uri = request.getRequestURI();
    String userSIN = (String) session.getAttribute("userSIN");
    String action = request.getParameter("action");
    String bookMessage = "";

    // 3. RÉCUPÉRATION DES FILTRES DE RECHERCHE
    String fCity = request.getParameter("f_city"); 
    String fChain = request.getParameter("f_chain");
    String fRating = request.getParameter("f_rating");
    String fCapacity = request.getParameter("f_capacity");
    String fPrice = request.getParameter("f_price");
    String fSup = request.getParameter("f_sup");
    String fView = request.getParameter("f_view");
    
    // NOUVEAUX FILTRES : Commodités et Extension
    String fAmenities = request.getParameter("f_amenities");
    String fExtension = request.getParameter("f_extension");
    
    // Dates (UI et SQL)
    String fDateArr = request.getParameter("f_datearr");
    String fDateDep = request.getParameter("f_datedep");

    // 2. LOGIQUE DE RÉSERVATION
    if ("book".equals(action) && userSIN != null) {
        String rNumStr = request.getParameter("room_number");
        try (Connection con = DBConnexion.getConnection()) {
            if (con == null) throw new Exception("Connexion DB impossible");
            
            con.setAutoCommit(false);
            int rNum = Integer.parseInt(rNumStr);

            // On utilise les dates du filtre pour créer le booking réel
            String start = (fDateArr == null || fDateArr.isEmpty()) ? "CURRENT_DATE" : "'" + fDateArr + "'";
            String end = (fDateDep == null || fDateDep.isEmpty()) ? "CURRENT_DATE + INTERVAL '7 days'" : "'" + fDateDep + "'";

            String sqlB = "INSERT INTO public.booking (room_number, start_date, end_date) VALUES (?, " + start + ", " + end + ") RETURNING booking_number";
            PreparedStatement ps1 = con.prepareStatement(sqlB);
            ps1.setInt(1, rNum);
            ResultSet rsBook = ps1.executeQuery();
            
            int generatedBookingId = 0;
            if(rsBook.next()){
                generatedBookingId = rsBook.getInt(1);
            }
            
            String sqlC = "INSERT INTO public.customerreserves (customer_sin, room_number, booking_number) VALUES (?, ?, ?)";
            PreparedStatement ps2 = con.prepareStatement(sqlC);
            ps2.setString(1, userSIN);
            ps2.setInt(2, rNum);
            ps2.setInt(3, generatedBookingId);
            ps2.executeUpdate();
            
            con.commit();
            session.setAttribute("flash", "<div class='success'>✅ Super ! Ta chambre a été réservée avec succès.</div>");
            response.sendRedirect("customer_account");
            return;
        } catch (Exception e) { 
            bookMessage = "Erreur de réservation : " + e.getMessage(); 
        }
    }

    // --- NOUVELLE LOGIQUE : LOCATION IMMÉDIATE (WALK-IN) ---
    if ("rent_now".equals(action) && userSIN != null) {
        String rNumStr = request.getParameter("room_number");
        try (Connection con = DBConnexion.getConnection()) {
            if (con == null) throw new Exception("Connexion DB impossible");
            con.setAutoCommit(false);
            int rNum = Integer.parseInt(rNumStr);

            // Étape A : Créer le Booking (Obligatoire pour l'intégrité de la base)
            String sqlB = "INSERT INTO public.booking (room_number, start_date, end_date) VALUES (?, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day') RETURNING booking_number";
            PreparedStatement ps1 = con.prepareStatement(sqlB);
            ps1.setInt(1, rNum);
            ResultSet rsBook = ps1.executeQuery();
            int bId = 0; if(rsBook.next()) bId = rsBook.getInt(1);
            
            // Étape B : Lier le Client à la réservation
            PreparedStatement ps2 = con.prepareStatement("INSERT INTO public.customerreserves (customer_sin, room_number, booking_number) VALUES (?, ?, ?)");
            ps2.setString(1, userSIN); ps2.setInt(2, rNum); ps2.setInt(3, bId);
            ps2.executeUpdate();

            // Étape C : Créer la Location (Renting) instantanément
            String sqlRent = "INSERT INTO public.renting (room_number, start_date, end_date) VALUES (?, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day') RETURNING renting_number";
            PreparedStatement psRent = con.prepareStatement(sqlRent);
            psRent.setInt(1, rNum);
            ResultSet rsRent = psRent.executeQuery();
            int rentId = 0; if(rsRent.next()) rentId = rsRent.getInt(1);

            // Étape D : Lier la Réservation et la Location (RoomHas)
            PreparedStatement psLink = con.prepareStatement("INSERT INTO public.roomhas (booking_number, renting_number) VALUES (?, ?)");
            psLink.setInt(1, bId); psLink.setInt(2, rentId);
            psLink.executeUpdate();
            
            con.commit();
            session.setAttribute("flash", "<div class='success'>🔑 Magique ! Chambre louée immédiatement. Tu as les clés !</div>");
            response.sendRedirect("customer_account");
            return;
        } catch (Exception e) { 
            bookMessage = "Erreur de location : " + e.getMessage(); 
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>e-Hôtels - Chambres Disponibles</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; padding: 20px; background: #f4f7f6; color: #333; }
        .header { display: flex; justify-content: space-between; align-items: center; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); margin-bottom: 20px; border-left: 5px solid #3498db; }
        .search-box { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.08); margin-bottom: 25px; }
        .search-grid { display: flex; flex-wrap: wrap; gap: 15px; align-items: end; }
        .search-group { flex: 1; min-width: 140px; display: flex; flex-direction: column; }
        .search-group label { font-size: 0.85em; font-weight: bold; color: #2c3e50; margin-bottom: 8px; }
        .search-group input, .search-group select { padding: 10px; border: 1px solid #ced4da; border-radius: 5px; font-size: 0.9em; width: 100%; box-sizing: border-box; }
        .date-container { display: flex; gap: 5px; align-items: center; }
        .date-container span { font-size: 0.85em; color: #7f8c8d; font-weight: bold; }
        .btn-filter { background: #3498db; color: white; border: none; padding: 10px 15px; border-radius: 5px; font-weight: bold; cursor: pointer; transition: 0.2s; height: 40px; white-space: nowrap; }
        .btn-filter:hover { background: #2980b9; }
        .btn-clear { background: #95a5a6; color: white; text-align: center; text-decoration: none; padding: 10px 15px; border-radius: 5px; font-weight: bold; height: 20px; line-height: 20px; white-space: nowrap; transition: 0.2s; }
        .btn-clear:hover { background: #7f8c8d; }
        table { width: 100%; border-collapse: collapse; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
        th, td { border-bottom: 1px solid #ecf0f1; padding: 15px; text-align: left; }
        th { background: #2c3e50; color: white; text-transform: uppercase; font-size: 0.85em; letter-spacing: 0.5px; }
        tr:hover { background-color: #f9fbfc; }
        .btn-book { background: #27ae60; color: white; border: none; padding: 8px 15px; border-radius: 4px; cursor: pointer; font-weight: bold; transition: 0.2s; }
        .btn-book:hover { background: #219150; }
        .btn-rent { background: #e67e22; color: white; border: none; padding: 8px 15px; border-radius: 4px; cursor: pointer; font-weight: bold; transition: 0.2s; margin-left: 5px; }
        .btn-rent:hover { background: #d35400; }
        .stars { color: #f39c12; font-size: 1.1em; }
        .filter-banner { background: #e8f4fd; color: #2980b9; padding: 12px; border-radius: 6px; margin-bottom: 20px; font-weight: bold; border: 1px solid #bde0fe; }
    </style>
</head>
<body>

    <div class="header">
        <h1 style="margin:0; font-size: 1.8em;">🏨 Chambres Disponibles</h1>
        <% if (userSIN != null) { %>
            <a href="customer_account" style="text-decoration:none; font-weight:bold; color:#3498db;">🏠 Retour à mon compte</a>
        <% } else { %>
            <a href="customer_account" style="text-decoration:none; font-weight:bold; color:#e67e22;">🔑 Se connecter pour réserver</a>
        <% } %>
    </div>

    <% if (!bookMessage.isEmpty()) { %>
        <p style="color:#c0392b; background:#fadbd8; padding:15px; border-radius:5px; border-left: 5px solid #c0392b;"><%= bookMessage %></p>
    <% } %>

    <div class="search-box">
        <form method="GET" action="rooms">
            <div class="search-grid">
                <div class="search-group" style="flex: 2; min-width: 250px;">
                    <label>Période du séjour</label>
                    <div class="date-container">
                        <span>Du</span>
                        <input type="date" name="f_datearr" value="<%= fDateArr != null ? fDateArr : "" %>">
                        <span>Au</span>
                        <input type="date" name="f_datedep" value="<%= fDateDep != null ? fDateDep : "" %>">
                    </div>
                </div>
                <div class="search-group">
                    <label>Ville (ex: Ottawa)</label>
                    <input type="text" name="f_city" placeholder="Où allez-vous ?" value="<%= fCity != null ? fCity : "" %>">
                </div>
                <div class="search-group">
                    <label>Chaîne</label>
                    <select name="f_chain">
                        <option value="">Toutes</option>
                        <option value="Marriott" <%= "Marriott".equals(fChain) ? "selected" : "" %>>Marriott</option>
                        <option value="Hilton" <%= "Hilton".equals(fChain) ? "selected" : "" %>>Hilton</option>
                        <option value="Hyatt" <%= "Hyatt".equals(fChain) ? "selected" : "" %>>Hyatt</option>
                        <option value="Best Western" <%= "Best Western".equals(fChain) ? "selected" : "" %>>Best Western</option>
                        <option value="Fairmont" <%= "Fairmont".equals(fChain) ? "selected" : "" %>>Fairmont</option>
                    </select>
                </div>
                <div class="search-group">
                    <label>Catégorie (Étoiles)</label>
                    <select name="f_rating">
                        <option value="">Toutes</option>
                        <option value="3" <%= "3".equals(fRating) ? "selected" : "" %>>3 Étoiles</option>
                        <option value="4" <%= "4".equals(fRating) ? "selected" : "" %>>4 Étoiles</option>
                        <option value="5" <%= "5".equals(fRating) ? "selected" : "" %>>5 Étoiles</option>
                    </select>
                </div>
                
                <div class="search-group">
                    <label>Vue</label>
                    <select name="f_view">
                        <option value="">Toutes</option>
                        <option value="Vue panoramique sur la ville" <%= "Vue panoramique sur la ville".equals(fView) ? "selected" : "" %>>Panoramique ville</option>
                        <option value="Vue sur la cour intérieure" <%= "Vue sur la cour intérieure".equals(fView) ? "selected" : "" %>>Cour intérieure</option>
                        <option value="Vue dégagée" <%= "Vue dégagée".equals(fView) ? "selected" : "" %>>Vue dégagée</option>
                        <option value="Vue sur l'océan / rivière" <%= "Vue sur l'océan / rivière".equals(fView) ? "selected" : "" %>>Océan / Rivière</option>
                        <option value="Vue standard (stationnement)" <%= "Vue standard (stationnement)".equals(fView) ? "selected" : "" %>>Standard (parking)</option>
                    </select>
                </div>

                <div class="search-group">
                    <label>Capacité</label>
                    <select name="f_capacity">
                        <option value="">Toutes</option>
                        <option value="Simple" <%= "Simple".equals(fCapacity) ? "selected" : "" %>>Simple</option>
                        <option value="Double" <%= "Double".equals(fCapacity) ? "selected" : "" %>>Double</option>
                        <option value="Triple" <%= "Triple".equals(fCapacity) ? "selected" : "" %>>Triple</option>
                        <option value="Queen" <%= "Queen".equals(fCapacity) ? "selected" : "" %>>Queen</option>
                        <option value="King" <%= "King".equals(fCapacity) ? "selected" : "" %>>King</option>
                    </select>
                </div>
                
                <div class="search-group">
                    <label>Commodités (Mot-clé)</label>
                    <input type="text" name="f_amenities" placeholder="Ex: Wifi, Jacuzzi..." value="<%= fAmenities != null ? fAmenities : "" %>">
                </div>

                <div class="search-group">
                    <label>Extension</label>
                    <select name="f_extension">
                        <option value="">Toutes</option>
                        <option value="Oui" <%= "Oui".equals(fExtension) ? "selected" : "" %>>Oui</option>
                        <option value="Non" <%= "Non".equals(fExtension) ? "selected" : "" %>>Non</option>
                    </select>
                </div>

                <div class="search-group">
                    <label>Prix Max ($)</label>
                    <input type="number" name="f_price" placeholder="Ex: 200" value="<%= fPrice != null ? fPrice : "" %>">
                </div>
                <div class="search-group">
                    <label>Superficie Min (m²)</label>
                    <input type="number" name="f_sup" placeholder="Ex: 30" value="<%= fSup != null ? fSup : "" %>">
                </div>
                <div class="search-group" style="flex: 0; min-width: auto; justify-content: flex-end;">
                    <button type="submit" class="btn-filter">Appliquer</button>
                </div>
                <div class="search-group" style="flex: 0; min-width: auto; justify-content: flex-end;">
                    <a href="rooms" class="btn-clear">Effacer</a>
                </div>
            </div>
        </form>
    </div>

    <% if (fDateArr != null && !fDateArr.isEmpty() && fDateDep != null && !fDateDep.isEmpty()) { %>
        <div class="filter-banner">📅 Chambres disponibles pour la période du <%= fDateArr %> au <%= fDateDep %></div>
    <% } %>

    <table>
        <thead>
            <tr>
                <th>Hôtel & Chaîne</th>
                <th>Catégorie</th>
                <th>Chambre</th>
                <th>Capacité</th>
                <th>Superficie</th>
                <th>Commodités</th> <th>Extension</th> <th>Prix</th>
                <% if (userSIN != null) { %>
                    <th>Action</th>
                <% } %>
            </tr>
        </thead>
        <tbody>
            <%
                try (Connection conTable = DBConnexion.getConnection()) {
                    if (conTable == null) throw new Exception("Connexion DB perdue");
                    
                    ArrayList<Object> params = new ArrayList<>();
                    
                    StringBuilder sql = new StringBuilder(
                        "WITH RN AS (SELECT room_number, ROW_NUMBER() OVER(PARTITION BY hotel_id ORDER BY room_number) as num FROM public.hotelcontains) " +
                        "SELECT r.room_number, r.price, r.capacity, r.view, r.amenities, r.extension, " +
                        "CASE r.capacity WHEN 'Simple' THEN 25 WHEN 'Double' THEN 35 WHEN 'Triple' THEN 40 WHEN 'Queen' THEN 45 WHEN 'King' THEN 60 ELSE 30 END AS fake_superficie, " +
                        "h.address, h.rating, hch.name AS chain_name, RN.num " +
                        "FROM public.room r " +
                        "JOIN public.hotelcontains hc ON r.room_number = hc.room_number " +
                        "JOIN public.hotel h ON hc.hotel_id = h.hotel_id " +
                        "JOIN public.hotelchainhas hch ON h.hotel_id = hch.hotel_id " +
                        "JOIN RN ON r.room_number = RN.room_number " +
                        "WHERE 1=1 "
                    );

                    // --- EXCLURE LES CHAMBRES DÉJÀ OCCUPÉES AUJOURD'HUI ---
                    sql.append(" AND r.room_number NOT IN (SELECT room_number FROM public.booking WHERE CURRENT_DATE >= start_date AND CURRENT_DATE < end_date) ")
                       .append(" AND r.room_number NOT IN (SELECT room_number FROM public.renting WHERE CURRENT_DATE >= start_date AND CURRENT_DATE < end_date) ");

                    if (fCity != null && !fCity.trim().isEmpty()) {
                        sql.append(" AND h.address ILIKE ? ");
                        params.add("%" + fCity.trim() + "%");
                    }
                    if (fChain != null && !fChain.isEmpty()) {
                        sql.append(" AND hch.name = ? ");
                        params.add(fChain);
                    }
                    if (fRating != null && !fRating.isEmpty()) {
                        sql.append(" AND h.rating = ? ");
                        params.add(Integer.parseInt(fRating));
                    }
                    if (fCapacity != null && !fCapacity.isEmpty()) {
                        sql.append(" AND r.capacity = ? ");
                        params.add(fCapacity);
                    }
                    if (fView != null && !fView.isEmpty()) {
                        sql.append(" AND r.view = ? ");
                        params.add(fView);
                    }
                    if (fPrice != null && !fPrice.isEmpty()) {
                        sql.append(" AND r.price <= ? ");
                        params.add(Double.parseDouble(fPrice));
                    }
                    if (fSup != null && !fSup.isEmpty()) {
                        sql.append(" AND (CASE r.capacity WHEN 'Simple' THEN 25 WHEN 'Double' THEN 35 WHEN 'Triple' THEN 40 WHEN 'Queen' THEN 45 WHEN 'King' THEN 60 ELSE 30 END) >= ? ");
                        params.add(Integer.parseInt(fSup));
                    }
                    
                    // --- NOUVELLES CONDITIONS SQL ---
                    if (fAmenities != null && !fAmenities.trim().isEmpty()) {
                        sql.append(" AND r.amenities ILIKE ? ");
                        params.add("%" + fAmenities.trim() + "%");
                    }
                    if (fExtension != null && !fExtension.isEmpty()) {
                        sql.append(" AND r.extension = ? ");
                        params.add(fExtension);
                    }

                    sql.append(" ORDER BY h.rating DESC, r.price ASC");

                    PreparedStatement pstmt = conTable.prepareStatement(sql.toString());
                    for (int i = 0; i < params.size(); i++) {
                        pstmt.setObject(i + 1, params.get(i));
                    }

                    ResultSet rs = pstmt.executeQuery();
                    boolean hasResults = false;

                    while(rs.next()) {
                        hasResults = true;
                        String stars = "";
                        for(int s=0; s<rs.getInt("rating"); s++) stars += "★";
            %>
                <tr>
                    <td>
                        <strong><%= rs.getString("chain_name") %></strong><br>
                        <span style="font-size:0.85em; color:#7f8c8d;"><%= rs.getString("address") %></span><br>
                        <small><i><%= rs.getString("view") %></i></small>
                    </td>
                    <td class="stars"><%= stars %></td>
                    <td><strong>N° <%= rs.getInt("num") %></strong></td>
                    <td><%= rs.getString("capacity") %></td>
                    <td><%= rs.getInt("fake_superficie") %> m²</td>
                    
                    <td><small><%= rs.getString("amenities") %></small></td>
                    <td><%= rs.getString("extension") %></td>

                    <td style="color:#27ae60; font-weight:bold; font-size:1.1em;"><%= String.format("%.2f", rs.getDouble("price")) %> $</td>
                    
                    <% if (userSIN != null) { %>
                        <td style="white-space: nowrap;">
                            <form method="POST" action="" style="display:inline-block; margin:0;">
                                <input type="hidden" name="action" value="book">
                                <input type="hidden" name="room_number" value="<%= rs.getInt("room_number") %>">
                                <input type="hidden" name="f_datearr" value="<%= fDateArr != null ? fDateArr : "" %>">
                                <input type="hidden" name="f_datedep" value="<%= fDateDep != null ? fDateDep : "" %>">
                                <button type="submit" class="btn-book">Réserver</button>
                            </form>
                            <form method="POST" action="" style="display:inline-block; margin:0;">
                                <input type="hidden" name="action" value="rent_now">
                                <input type="hidden" name="room_number" value="<%= rs.getInt("room_number") %>">
                                <button type="submit" class="btn-rent" title="Prendre la chambre tout de suite">Louer</button>
                            </form>
                        </td>
                    <% } %>
                </tr>
            <% 
                    }
                    if (!hasResults) {
                        out.println("<tr><td colspan='9' style='text-align:center; padding:30px; font-size:1.1em; color:#7f8c8d;'>Aucune chambre disponible actuellement.</td></tr>");
                    }
                } catch(Exception e) {
                    out.println("<tr><td colspan='9' style='color:red;'>Erreur SQL : " + e.getMessage() + "</td></tr>");
                }
            %>
        </tbody>
    </table>

</body>
</html>