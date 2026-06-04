# Civio — Offline-first Intelligent Assistant (Cameroon)

Civio is a production-ready Flutter Android application designed to help Cameroonian citizens navigate administrative and academic procedures. It operates **100% offline**, using a local JSON knowledge base and featuring a voice-first interaction system in French and Camfranglais.

## ✨ Key Features

- **Offline-first AI Dialogue**: A JSON-driven decision tree engine that guides users through complex procedures via a conversational interface.
- **Real Procedures**: Accurate data for CNI (IDCAM), Passports (PASSCAM), ENS Concours, and more (sourced from idcam.cm, passcam.cm, uninet.cm).
- **Official Document Generator**: Automatically generates PDF documents (A4 format) like scholarship requests or letters to the Dean, ready to sign and print.
- **Offline Maps**: Integrated OpenStreetMap for locating administrative offices in Yaoundé and other cities.
- **Voice Interaction**: Speech-to-Text and Text-to-Speech support for enhanced accessibility.
- **Premium Design System**: strictly follows the `ekema.html` design tokens (Poppins/Fraunces typography, custom green palette).
- **History & Favorites**: Uses Sqflite for local storage of past searches and generated documents.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (stable)
- Android Studio / VS Code with Flutter extension
- Android Device/Emulator (Target: 2GB RAM+)

### Setup

1. Clone the repository.
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```

## 🏗️ Architecture

The project follows **Clean Architecture** patterns:

```
lib/
 ├── core/          # Theme, Utils, Common constants
 ├── data/          # Repositories & Local data sources (Sqflite, JSON)
 ├── domain/        # Entities & Repository interfaces
 ├── presentation/  # Providers (State Management) & Screens
 └── widgets/       # Reusable UI components
```

## 🛠️ Tech Stack & Dependencies

- **Framework**: Flutter (Android)
- **State Management**: Provider
- **Storage**: Sqflite
- **Maps**: Flutter Map (OpenStreetMap)
- **Voice**: Speech to Text, Flutter TTS
- **PDF**: PDF & Printing
- **Fonts**: Google Fonts (Poppins, Fraunces)

## 🤖 CI/CD - GitHub Actions

The application is automatically built and released via GitHub Actions.
- **Trigger**: Push to `main` or Tag.
- **Workflow**:
  - Code analysis (`flutter analyze`)
  - Unit tests (`flutter test`)
  - Build Release APK
  - Automatic GitHub Release with APK artifact.

## 📁 Knowledge Base Structure

Procedures are stored in `assets/json/procedures.json`. Example structure:
```json
{
  "id": "cni-cameroon",
  "category": "CNI / Passeport",
  "title": "Carte Nationale d'Identité",
  "questions": [...],
  "steps": [...],
  "documents": [...]
}
```

## 📜 License

Created for **GCD4F 2026 — IA pour la Société (Cameroun)**.
Intended for social impact and administrative transparency.
# ekema
# ekema
# ekema
