# 🚀 Guide de Configuration - Serveur Tomcat 9.0 (Projet e-Hôtels)

Ce guide explique comment configurer l'environnement de développement local avec Apache Tomcat 9.0 pour le projet de bases de données (CSI 2532). Cette méthode permet de lier le serveur directement au dossier du projet sans avoir à copier-coller les fichiers dans les dossiers internes de Tomcat.

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

<Context docBase="C:\Chemin\Vers\Le\Projet\projet_csi2532_ray_hum\app">
</Context>

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
2. Aller à l'adresse : `http://localhost:8080/ehotel`
3. Si la page d'accueil de notre projet s'affiche, la configuration est réussie !