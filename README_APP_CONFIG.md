# 🚀 Guide de Configuration - Serveur Tomcat 9.0 (Projet e-Hôtels)

Ce guide explique comment configurer l'environnement de développement local avec Apache Tomcat 9.0 pour le projet de bases de données (CSI 2532). Cette méthode permet de lier le serveur directement au dossier du projet sans avoir à copier-coller les fichiers dans les dossiers internes de Tomcat.

# Technologies choisis
Base de données : PostgreSQL
Serveur : Apache Tomcat
Backend : Java
Frontend : jsp (semblable à html mais version dynamique)


## 📋 Prérequis
1. Avoir téléchargé **Apache Tomcat 9.0** (`apache-tomcat-9.0.117-windows-x64.zip`) et l'avoir extrait sur le PC.
2. Avoir installé **Java Development Kit (JDK) 21**.

---

## ⚙️ Étape 1 : Configuration de la variable d'environnement Java
Tomcat a besoin de savoir où Java est installé pour compiler les Servlets.

1. Chercher "Variables d'environnement" dans la barre de recherche Windows.
2. Cliquer sur **Nouvelle** dans les variables système.
3. Nom de la variable : `JAVA_HOME`
4. Valeur de la variable : Chemin absolu vers le dossier JDK (ex: `C:\Program Files\Java\jdk-21`).
5. Sauvegarder et fermer.

---

## 🌉 Étape 2 : Création du "Pont" (Configuration Catalina)
Au lieu de mettre notre code dans le dossier interne `webapps` de Tomcat, nous allons créer un pont vers notre dossier de projet.

1. Naviguer dans le dossier Tomcat extrait : `apache-tomcat-9.0.117\conf\`.
2. Créer un dossier nommé `Catalina`.
3. Entrer dans `Catalina` et créer un sous-dossier nommé `localhost`.
4. Dans `localhost`, créer un fichier texte et le renommer **`ehotel.xml`**.
5. Ouvrir `ehotel.xml` et insérer le code suivant (en ajustant le chemin `docBase` vers l'emplacement exact du dossier `app` de notre projet sur votre PC) :

```xml
<Context docBase="C:\Chemin\Vers\Le\Projet\projet_csi2532_ray_hum\app">
</Context>
```

---

## 🚀 Étape 3 : Démarrage du serveur
Pour lancer le serveur et voir les logs en temps réel :

1. Ouvrir l'Invite de commande (CMD).
2. Naviguer vers le dossier `bin` de Tomcat :
   `cd C:\Chemin\Vers\apache-tomcat-9.0.117\bin`
3. Lancer le moteur Catalina directement :
   `catalina.bat run`

*(Note : On utilise `catalina.bat run` au lieu de `startup.bat` pour garder la console ouverte et pouvoir lire les erreurs en cas de problème).*

---

## ✅ Étape 4 : Test de connexion
1. Ouvrir un navigateur web.
2. Aller à l'adresse : `http://localhost:8080/ehotel/index.html`
3. Si la page d'accueil de notre projet s'affiche, la configuration est réussie !


------------------------------



## 🛠️ PARTIE 2 : Liaison Base de Données (PostgreSQL) & Fichier de Test

Cette section explique comment configurer la base de données locale pour qu'elle puisse communiquer avec l'application Java. Nous utilisons d'abord un fichier de test pour vérifier la liaison dans le terminal.

### Étape 1 : Installation de PostgreSQL
1. Téléchargez **PostgreSQL 16** via le site officiel : [EnterpriseDB Downloads](https://www.enterprisedb.com/downloads/postgres-postgresql-downloads).
2. Installez-le sur votre machine (Windows/Mac) en suivant les instructions par défaut. 
3. Pendant l'installation, choisissez le mot de passe `pgadmin1234` (requis par notre code) et conservez le port par défaut : **5432**.
4. Une fois terminé, lancez l'application **pgAdmin 4**.

### Étape 2 : Création de la Base de Données et des Tables
1. Dans pgAdmin, faites un clic droit sur **Databases** (en dehors de la base par défaut `postgres`) > **Create** > **Database**.
2. Nommez cette nouvelle base exactement : `TEST_database_ehotel`.
3. Ouvrez le **Query Tool** sur cette base et exécutez le script SQL suivant pour créer la table et insérer nos données de test :

```sql
-- 1. Création de la table de test
CREATE TABLE test_hotel (
    id SERIAL PRIMARY KEY,
    nom_hotel VARCHAR(100) NOT NULL
);

-- 2. Insertion des données
INSERT INTO test_hotel (nom_hotel) VALUES 
('Le Grand Palace de Humayrah'),
('Shrek_hotel'),
('Hotel V'),
('The Westin Ottawa');

-- 3. Vérification
SELECT * FROM test_hotel;
```

### Étape 3 : Compilation du code de Test Java
Le code source et les librairies (JDBC) sont déjà inclus dans le projet. Remarquez que notre fichier de test se trouve dans le sous-dossier `src/test/` pour garder le projet propre. 

Ouvrez un terminal à la **racine du projet** et lancez la commande de compilation :

```powershell
javac -d app/WEB-INF/classes -cp "app/WEB-INF/lib/*" src/test/TestConnexion.java
```

### Étape 4 : Exécution et Résultats du Test
Toujours depuis la racine du projet, lancez l'exécution du code test pour vérifier la liaison :

```powershell
java -cp "app/WEB-INF/classes;app/WEB-INF/lib/*" src.test.TestConnexion
```

**✅ Résultat attendu dans le terminal :**
```text
--- LISTE DES HÔTELS DANS LA DB ---
📍 Id: 1, nom: Le Grand Palace de Humayrah
📍 Id: 2, nom: Shrek_hotel
📍 Id: 3, nom: Hotel V
📍 Id: 4, nom: The Westin Ottawa
-----------------------------------
```


------------------------------



## ▶️ Exécution de l'Application Principale

Maintenant que l'environnement et la base de données sont testés et fonctionnels, voici comment compiler et lancer l'application Web qui sera utilisée au quotidien.

### Étape 1 : Compilation du Connecteur Principal (optionel)
L'application utilise un fichier centralisé (`DBConnexion.java`) pour gérer toutes les communications avec PostgreSQL. Ouvrez un terminal à la **racine du projet** et compilez ce fichier source :

```powershell
javac -d app/WEB-INF/classes -cp "app/WEB-INF/lib/*" src/DBConnexion.java
```

### Étape 2 : Lancement du Serveur (Tomcat)
Avant d'accéder au site, le moteur de l'application doit être allumé.

1. Ouvrir l'Invite de commande (CMD) ou PowerShell.
2. Naviguer vers le dossier `bin` de Tomcat :
   `cd C:\Chemin\Vers\apache-tomcat-9.0.117\bin`
3. Lancer le moteur Catalina directement :
   `catalina.bat run`

*(Note : Laissez cette console ouverte. On utilise `catalina.bat run` au lieu de `startup.bat` pour pouvoir lire les logs et les erreurs en direct).*

### Étape 3 : Lancement de l'Interface Web
L'application principale s'exécute via le serveur Tomcat. 

1. Assurez-vous que Tomcat est bien en cours d'exécution (voir Étape 2).
2. Ouvrez votre navigateur Web.
3. Accédez à la page d'accueil dynamique : `http://localhost:8080/ehotel/rooms`

L'interface web lira automatiquement les données depuis PostgreSQL en utilisant le connecteur Java fraîchement compilé !