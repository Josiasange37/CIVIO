# Firebase Emulators (Linux / macOS / Windows dev)

Firebase Auth and Firestore ne supportent officiellement pas Linux, macOS, ni Windows
via le SDK Flutter. Pour pouvoir développer l'app sur desktop avec un vrai flux
d'authentification et de la donnée qui persiste, on utilise les **émulateurs
locaux Firebase**. L'émulateur n'a pas besoin de clés API valides, et toutes les
données sont stockées sur la machine.

## Quand l'utiliser ?

| Plateforme  | Stratégie                                                |
|-------------|----------------------------------------------------------|
| Android     | Firestore + Auth prod (via `flutter run -d <android>`)   |
| iOS         | Firestore + Auth prod (via `flutter run -d <ios>`)       |
| Web         | Firestore + Auth prod                                    |
| Linux       | **Émulateurs locaux** (Auth 9099, Firestore 8080, UI 4000) |
| macOS       | **Émulateurs locaux** (idem Linux)                      |
| Windows     | **Émulateurs locaux** (idem Linux)                      |

## Setup (une seule fois)

```bash
# Depuis la racine du repo
npm install            # installe firebase-tools en local
```

## Lancer les émulateurs + l'app (workflow complet)

Dans **deux terminaux** :

```bash
# Terminal 1 — émulateurs (UI dispo sur http://127.0.0.1:4000)
npm run emulators

# Terminal 2 — l'app desktop
flutter run -d linux
```

L'app détecte qu'elle tourne sur Linux (`AppConfig.isDesktopEmulatorHost`) et
appelle automatiquement `useAuthEmulator('127.0.0.1', 9099)` et
`useFirestoreEmulator('127.0.0.1', 8080)` dans `main.dart::_initializeFirebase`.

Tu peux maintenant :

- Créer un compte sur l'écran Register → l'utilisateur vit dans l'émulateur
- Te connecter sur l'écran Login → la session persiste entre les redémarrages
- Lire/écrire dans Firestore → les données sont visibles sur l'UI émulateur
  (http://127.0.0.1:4000)

## Réinitialiser / exporter les données

```bash
# Export de l'état courant vers ./emulator-data
npm run emulators:export

# Démarrer en important automatiquement ./emulator-data
npm run emulators:import
```

## Si l'émulateur n'est pas lancé

L'app va tenter de se connecter à `127.0.0.1:9099` et `127.0.0.1:8080`. Si la
connexion échoue, les méthodes Firebase lèvent des exceptions qui sont
rattrapées par le `try/catch` dans `_initializeFirebase` ; `AppConfig.firebaseEnabled`
reste à `false` et l'app bascule en **Mode démo** (bandeau orange visible).

## Désactiver l'émulateur sur desktop

Si tu veux forcer l'app à parler au projet Firebase prod depuis un desktop
(rare, et seulement pour debug), passe `AppConfig.useEmulatorByDefault` à
`false` dans `lib/core/config/app_config.dart`.

## Ports

| Service       | Port |
|---------------|------|
| Auth          | 9099 |
| Firestore     | 8080 |
| Emulator UI   | 4000 |

Tous les ports sont configurés dans `firebase.json`.
