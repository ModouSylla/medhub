# 🏥 MediHub

**MediHub** est une application Flutter conçue pour le suivi médical des patients avec un carnet numérique complet. 
L'application fonctionne **100% hors ligne** pour garantir la confidentialité et la disponibilité des données médicales à tout moment, sans nécessiter de connexion internet.

> **Projet de fin de cycle - UGB L3 Info 2026**
> 👨‍💻 **Auteurs** : Aïssa Thioye, Modou Sylla 

---

## 🌟 Fonctionnalités Principales

- 👥 **Gestion des patients** : Création, modification et suivi des dossiers des patients.
- 📓 **Carnet de santé numérique** : Suivi des consultations, des constantes médicales et des ordonnances.
- 📅 **Agenda et Rendez-vous** : Planification des rendez-vous médicaux avec un calendrier intégré.
- 🔔 **Notifications Locales** : Rappels pour les consultations et la prise de médicaments.
- 🔒 **Confidentialité & Sécurité** : Données stockées localement sur l'appareil via SQLite. Aucun cloud, aucun risque de fuite de données en ligne.

## 🛠 Technologies Utilisées

Ce projet est développé avec le SDK **Flutter** (>=3.0.0 <4.0.0) et s'appuie sur plusieurs packages essentiels :

- **[Provider](https://pub.dev/packages/provider)** : Gestion d'état réactive.
- **[Sqflite](https://pub.dev/packages/sqflite)** : Base de données SQLite locale.
- **[Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)** : Gestion des rappels et alertes système.
- **[Google Fonts](https://pub.dev/packages/google_fonts) & [Font Awesome](https://pub.dev/packages/font_awesome_flutter)** : Typographie et icônes médicales.
- **[Shared Preferences](https://pub.dev/packages/shared_preferences)** : Stockage des préférences et paramètres utilisateurs locaux.

## 🚀 Installation & Exécution

Puisqu'il s'agit d'une application Flutter, assurez-vous d'avoir installé [Flutter](https://flutter.dev/docs/get-started/install) sur votre machine.

1. **Cloner le dépôt :**
   ```bash
   git clone https://github.com/ModouSylla/medhub.git
   cd medhub
   ```

2. **Installer les dépendances :**
   ```bash
   flutter pub get
   ```

3. **Lancer l'application :**
   Connectez un émulateur ou un appareil physique, puis lancez :
   ```bash
   flutter run
   ```

## 🏗 Architecture du Projet

Le projet suit une architecture claire pour séparer les vues, la logique métier et l'accès aux données :

```
lib/
├── constants/    # Variables globales (Couleurs, Dimensions, Thèmes...)
├── database/     # Configuration de la base de données SQLite
├── models/       # Modèles de données (Patient, Consultation, Rendez-vous...)
├── providers/    # Gestion de l'état (State Management via Provider)
├── repositories/ # Accès et requêtes à la base de données (DAO)
├── screens/      # Vues de l'application (Accueil, Agenda, Patients...)
├── services/     # Services transverses (Authentification, Notifications...)
├── utils/        # Fonctions utilitaires (Formatage de dates, Validateurs...)
└── widgets/      # Composants UI réutilisables (Boutons, Cartes, Dialogues...)
```
