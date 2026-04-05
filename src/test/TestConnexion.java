package src.test;

import java.sql.Connection;
import java.sql.DriverManager;

public class TestConnexion {
    public static void main(String[] args) {
        // 1. Les infos de connexion
        String url = "jdbc:postgresql://localhost:5432/TEST_database_ehotel";
        String utilisateur = "postgres";
        String motDePasse = "pgadmin1234"; // Ce que tu as choisi à l'install

        try {
            // 2. Charger le petit fichier .jar (le driver)
            Class.forName("org.postgresql.Driver");

            // 3. Tenter de se connecter
            Connection con = DriverManager.getConnection(url, utilisateur, motDePasse);
            
            // 4. Créer une requete
            java.sql.Statement stmt = con.createStatement();

            java.sql.ResultSet rs =  stmt.executeQuery("SELECT * FROM test_hotel");
            
            System.out.println("--- LISTE DES HÔTELS DANS LA DB ---");

            // 5. Boucler sur chaque ligne trouvée
            while (rs.next()) {
                String nom = rs.getString("nom_hotel");
                int id = rs.getInt("id");
                System.out.println("📍 Id: " + id + ", nom: "+nom);
            }
            
            System.out.println("-----------------------------------");
            
            con.close(); // Toujours fermer la porte en sortant !
            
        } catch (Exception e) {
            System.out.println("❌ ERREUR lors de la lecture des tables.");
            e.printStackTrace();
        }
    }
}