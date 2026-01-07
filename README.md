# Costume Rental App 🎭

Application complète de gestion de location de costumes, composée d'une application mobile **Offline-First** et d'un backend centralisé.

Ce projet démontre une architecture hybride permettant aux vendeurs de travailler sans connexion internet, avec une synchronisation des données dès que le réseau est disponible.

## 🚀 Fonctionnalités Clés

*   **Mode Offline (Mobile)** : Consultation du catalogue et prise de commandes sans internet (via SQLite).
*   **Catalogue Interactif** : Visualisation des costumes avec détails (Taille, Prix, Disponibilité).
*   **Guest Checkout** : Parcours de location rapide sans création de compte obligatoire (Nom, Tél, Adresse).
*   **Synchronisation Intelligente** : Envoi des commandes locales vers le serveur et mise à jour du stock en un clic.
*   **Admin Panel Mobile** : Vue intégrée pour voir les commandes stockées localement.

## 🎥 Démonstration Vidéo

Voici un aperçu de l'application en action :

[**▶️ CLIQUEZ ICI POUR VOIR LA VIDEO**](assets/demoapp.mov)

_(Le fichier se trouve dans `assets/demoapp.mov`)_

## 🛠️ Stack Technique

### 📱 Mobile (Dossier `/mobile`)
*   **Framework** : Flutter (Dart)
*   **Data** : SQLite (`sqflite`) pour la persistance locale.
*   **Network** : Dio pour les échanges API.
*   **Architecture** : Provider pour le State Management + Service Repository pattern.

### 🖥️ Backend (Dossier `/backend_full`)
*   **Framework** : Laravel 11 (PHP)
*   **Database** : MySQL (Compatible SQLite pour dev).
*   **API** : Endpoints REST pour la synchronisation (`/api/guest-rentals`).

## 📦 Installation & Démarrage

### 1. Backend (Laravel)
```bash
cd backend_full
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate --seed # Remplit la BDD avec les costumes de démo
php artisan serve
```
*Le serveur sera accessible sur `http://localhost:8000`.*

### 2. Mobile (Flutter)
```bash
cd mobile
flutter pub get
flutter run
```
*Note : Pour tester sur un émulateur Android, l'adresse de l'API est automatiquement gérée (`10.0.2.2`).*

## 🔄 Comment Tester la Synchro ?
1.  Lancez le Backend (`php artisan serve`).
2.  Lancez l'Application Mobile.
3.  Louez un costume en mode "Guest".
4.  Cliquez sur l'icône **Sync** en haut à droite.
5.  Vérifiez dans le backend ou l'onglet Admin que la commande est bien remontée !

---
*Projet réalisé dans le cadre d'un projet académique/portfolio.*
