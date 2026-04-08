package src;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnexion {
    
    // Les informations de ta base de données
    private static final String URL = "jdbc:postgresql://localhost:5432/Database_Ehotel_Project";
    private static final String USER = "postgres";
    private static final String PASS = "pgadmin1234";

    // Méthode statique pour obtenir la connexion n'importe où dans le projet
    public static Connection getConnection() {
        Connection con = null;
        try {
            // Charger le driver
            Class.forName("org.postgresql.Driver");
            // Créer la connexion
            con = DriverManager.getConnection(URL, USER, PASS);
        } catch (ClassNotFoundException e) {
            System.out.println("❌ ERREUR : Driver PostgreSQL introuvable.");
            e.printStackTrace();
        } catch (SQLException e) {
            System.out.println("❌ ERREUR : Impossible de se connecter à la DB.");
            e.printStackTrace();
        }
        return con;
    }
}