<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="src.DBConnexion" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>e-Hôtels - Recherche</title>
    <style>
        body { font-family: sans-serif; margin: 20px; }
        .search-box { background: #eef2f7; padding: 20px; border-radius: 8px; border: 1px solid #d1d9e6; }
        table { border-collapse: collapse; width: 100%; margin-top: 20px; }
        th, td { border: 1px solid #ddd; padding: 12px; text-align: left; }
        th { background-color: #2c3e50; color: white; }
        .stars { color: #f1c40f; font-weight: bold; }
    </style>
</head>
<body>

    <h1>🏨 Portail de Recherche e-Hôtels</h1>

    <div class="search-box">
        <form method="GET" action="index.jsp">
            <label>Nom :</label>
            <input type="text" name="nomRecherche" value="<%= request.getParameter("nomRecherche") != null ? request.getParameter("nomRecherche") : "" %>">
            
            <label>Catégorie :</label>
            <select name="etoiles">
                <option value="">Toutes</option>
                <% for(int i=1; i<=5; i++) { %>
                    <option value="<%= i %>" <%= String.valueOf(i).equals(request.getParameter("etoiles")) ? "selected" : "" %>>
                        <%= i %> Étoile<%= i > 1 ? "s" : "" %>
                    </option>
                <% } %>
            </select>

            <button type="submit">🔍 Filtrer</button>
            <a href="index.jsp">Effacer</a>
        </form>
    </div>

    <table>
        <thead>
            <tr>
                <th>ID</th>
                <th>Nom de l'Hôtel</th>
                <th>Catégorie</th>
            </tr>
        </thead>
        <tbody>
            <%
                String nomFiltre = request.getParameter("nomRecherche");
                String etoilesFiltre = request.getParameter("etoiles");
                Connection con = DBConnexion.getConnection();

                if (con != null) {
                    try {
                        // Construction dynamique de la requête
                        String sql = "SELECT * FROM test_hotel WHERE 1=1";
                        if (nomFiltre != null && !nomFiltre.isEmpty()) sql += " AND nom_hotel ILIKE ?";
                        if (etoilesFiltre != null && !etoilesFiltre.isEmpty()) sql += " AND etoiles = ?";

                        PreparedStatement pstmt = con.prepareStatement(sql);
                        int paramIndex = 1;
                        if (nomFiltre != null && !nomFiltre.isEmpty()) pstmt.setString(paramIndex++, "%" + nomFiltre + "%");
                        if (etoilesFiltre != null && !etoilesFiltre.isEmpty()) pstmt.setInt(paramIndex++, Integer.parseInt(etoilesFiltre));

                        ResultSet rs = pstmt.executeQuery();
                        while (rs.next()) {
            %>
                            <tr>
                                <td><%= rs.getInt("id") %></td>
                                <td><%= rs.getString("nom_hotel") %></td>
                                <td class="stars"><%= "⭐".repeat(rs.getInt("etoiles")) %></td>
                            </tr>
            <%
                        }
                        con.close();
                    } catch (Exception e) {
                        out.println("<tr><td colspan='3'>Erreur : " + e.getMessage() + "</td></tr>");
                    }
                }
            %>
        </tbody>
    </table>
</body>
</html>