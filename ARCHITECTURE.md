# Civio — App Architecture Complete Guide

## Overview

**Civio** (package `civio`) is an offline-first Android assistant built for **GCD4F 2026** that helps Cameroonian citizens navigate administrative and academic procedures in French/Camfranglais. It follows **Clean Architecture** with 4 layers:

```
lib/
├── domain/       (1 file)   →  Entities (pure data classes)
├── data/         (4 files)  →  Repositories (data access, storage)
├── core/         (8 files)  →  Config, DI, Services, Theme, Utils
└── presentation/ (~38 files)→  Providers, Screens, Widgets
```

---

## Layer 1: Domain Layer (`lib/domain/entities/procedure.dart`)

4 pure Dart classes with `fromJson` factories:

| Entity | Fields | Purpose |
|--------|--------|---------|
| `Procedure` | id, category, title, description, questions[], documents[], steps[], locations[] | A complete administrative procedure (e.g. "CNI First Request") |
| `Question` | id, text, options[] | A multiple-choice question in the dialogue flow |
| `ProcedureStep` | title, description, cost, time | One action step within a procedure |
| `ProcedureLocation` | name, lat, lon, address, phone | An admin office on the map |

No framework dependency, no `flutter` import — pure Dart.

---

## Layer 2: Data Layer (`lib/data/repositories/`)

4 repositories, each wrapping Firebase or SQLite:

### `ProcedureRepository` (implements `IProcedureRepository`)
- **Source**: Firestore `procedures` collection (via `serverAndCache` — works offline)
- **Caches** procedures in memory after first load
- **Methods**: `getProcedures()`, `getProcedureById(id)`, `searchProcedures(query)`
- **Search**: simple case-insensitive substring match on title/category/description

### `AuthRepository`
- Wraps `FirebaseAuth` + Firestore (`citizens` collection)
- **Sign in**: email/password, phone (SMS-based via `verifyPhoneNumber`)
- **Register**: creates Firebase user + writes `citizens/{uid}` profile doc
- **Demo mode**: all methods return no-ops when `AppConfig.isDemoMode == true`
- Error messages are French-localized (`_humanize()` maps Firebase error codes)

### `ChatRepository`
- **Hybrid strategy**: tries OpenRouter (online AI) first, falls back to Firestore procedures (offline)
- Connects three services via DI: `OpenRouterService` + `FallbackAIService` + `ConnectivityService`
- `sendMessage()`: auto-detects service, cascades on failure
- `checkAvailability()`: returns `{mode, isOnline, isAIAvailable, isFallbackAvailable, modelName}`
- Exposes `connectivityStream` for real-time mode changes

### `HistoryRepository`
- Uses **Sqflite** for local persistence (`civio_history.db`)
- Schema: `history(id, title, procedure_id, date, type, data)`
- Methods: `addToHistory()`, `getHistory()`, `clearHistory()`

---

## Layer 3: Core Layer (`lib/core/`)

### Config (`app_config.dart`)

Key decision point for the entire app:

- `firebaseSupported` — true on Android/iOS/Web/Linux/macOS/Windows
- `firebaseEnabled` — set to `true` only after `Firebase.initializeApp()` succeeds
- `isDesktopEmulatorHost` — true on Linux/macOS/Windows → connects to local Firebase Emulator
- `isDemoMode` — true when Firebase couldn't init (no data, auth disabled, UI works)

### DI (`injection.dart`)

Uses **GetIt** singleton container. Registers:

- `ConnectivityService` (lazySingleton)
- `OpenRouterService` (lazySingleton, takes API key)
- `FallbackAIService` (lazySingleton)
- `ChatRepository` (lazySingleton, injected with 3 services above)

### Services

**`AIService`** — abstract interface:

```
sendMessage(messages, userMessage) → String?
isAvailable() → bool
modelName → String
```

**`OpenRouterService`** (online AI):

- Endpoint: `https://openrouter.ai/api/v1/chat/completions`
- Default model: `mistralai/mistral-7b-instruct:free`
- Also supports: Llama 3 8B, Gemma 2 9B, Zephyr 7B (all free tier)
- Headers: API key, HTTP-Referer, X-Title
- Rate limit handling (429 → user-friendly message)
- 30s timeout, SocketException catch

**`FallbackAIService`** (offline AI):

- Loads Firestore `procedures` collection
- Matches user query to procedure by keyword (title, category, description)
- Returns formatted markdown: title + description + documents list + steps with cost/time
- If nothing matches: lists all available procedures
- If empty: returns "no procedures available" message

**`ConnectivityService`**:

- Uses `connectivity_plus` package
- Initial check + stream subscription
- Exposes `isConnected` bool + `onConnectivityChanged` stream

### Theme (`app_theme.dart`)

Airbnb-inspired design token system (235 lines):

- `CivioColors`: brand (#FF385C), canvas, subtle, textPrimary/secondary, category colors, status colors (success/warning/info)
- `CivioSpacing`: xs(4) through xxl(32)
- `CivioRadius`: sm(12), md(16), lg(24), pill(999)
- `CivioShadows`: sm/md/lg with Material Design elevation
- `CivioTheme.lightTheme`: Full Material 3 ThemeData using Google Fonts Plus Jakarta Sans

### Utils (`pdf_generator.dart`)

Stubbed — throws `UnsupportedError` on Linux. Real PDF generation (using `pdf` + `printing` packages) is disabled for desktop builds (PDFium download issue). Document generation works in UI-only preview mode.

---

## Layer 4: Presentation Layer (`lib/presentation/`)

### Providers (state management via `ChangeNotifier`)

**`ProcedureProvider`**:

- Manages procedure list, search, selection, and the dialogue question flow
- States: `ChatState.idle → searching → talking → completed`
- Tracks `currentQuestionIndex`, `userAnswers` (Map<String, String>)
- `selectProcedure()` → sets `state = talking`, resets progress
- `answerQuestion()` → stores answer, advances index; if last question → `state = completed`
- `progress` getter: `currentQuestionIndex / totalQuestions`

**`AuthProvider`**:

- Subscribes to `AuthRepository.authStateChanges` stream
- Exposes `AuthStatus` (unknown/authenticated/unauthenticated)
- Wraps signIn/register/signOut, exposes `isLoading`, `lastError`

**`VoiceProvider`**:

- Wraps `speech_to_text` + `flutter_tts` (French locale, fr-FR)
- `startListening(callback)` → speech-to-text, `stopListening()`
- `speak(text)` → text-to-speech

**`AIChatProvider`**:

- Gets `ChatRepository` via `getIt` DI
- Tracks `ChatMode` (online/offline/unavailable) reactively
- `init()` → checks availability, subscribes to connectivity changes
- `sendMessage()` → appends user message to list, calls repository, appends response
- `getWelcomeMessage()` → contextual welcome text per mode
- `clearChat()` → resets message list

### Screens (11 screens, routing via named routes)

| Route | Screen | Purpose |
|-------|--------|---------|
| `/` | SplashScreen | 2.2s logo animation → auth check |
| `/dialogue` | DialogueScreen | Duolingo-style Q&A flow |
| `/result` | ResultScreen | Personalized step-by-step plan |
| `/document-generator` | DocumentGeneratorScreen | Wizard-style PDF form |
| `/ai-chat` | AIChatScreen | Chat interface with AI |
| `/map` | OfflineMapScreen | OSM map with office locator |
| push | LoginScreen | Email/password or phone sign-in |
| push | RegisterScreen | Account creation form |
| push | HomeScreen | Main scrollable hub |
| push | HistoryScreen | Sqflite history listing |
| push | SettingsScreen | Preferences (lang, city, voice) |

### Navigation Flow

```
App launch
  ↓
SplashScreen (logo animation 2.2s)
  ↓
AuthProvider.status == authenticated?
  ├── YES → HomeScreen
  └── NO  → LoginScreen
              ├── Email/password login
              ├── Phone sign-in (SMS)
              └── Demo mode bypass (Linux dev)
                    ↓
RegisterScreen → HomeScreen
                    ↓
HomeScreen (main hub, scrollable)
  ├── Segmented search bar → DialogueScreen
  ├── Feature spotlight (CNI) → DialogueScreen
  ├── AI Chat card → AIChatScreen
  ├── Filter chips → horizontal scrollable procedures
  ├── Procedure listing cards → DialogueScreen
  ├── Category grid tiles:
  │   ├── CNI & Passeport → DialogueScreen
  │   ├── Actes civils → (stub)
  │   ├── Concours & Études → (stub)
  │   └── Rédiger un document → DocumentGeneratorScreen
  ├── Interactive map card → OfflineMapScreen
  ├── History button → HistoryScreen
  └── Settings (person icon) → SettingsScreen
```

### Dialogue Flow (the core user journey)

```
HomeScreen → select procedure → /dialogue
  → Mascot shows question (SpeechBubble)
  → User picks answer (DuoChoiceCard) OR voice input
  → 15 XP earned (animated toast)
  → Next question loads (if any)
  → All questions answered?
    ├── NO → continue
    └── YES → /result

ResultScreen:
  → Celebration overlay (mascot, 50 XP)
  → Step accordion cards (expandable, checkable)
  → Documents to prepare list
  → Bottom bar: Map | Call | Generate Document
```

### AI Chat Flow

```
AIChatScreen:
  → Welcome message (contextual: online/offline/unavailable)
  → Quick prompt chips (3 pre-written questions)
  → Text input + send button
  → ChatRepository.sendMessage():
      ├── Online? → OpenRouter API (Mistral 7B free)
      └── Offline? → FallbackAIService (Firestore procedures)
  → Response rendered as chat bubble
  → 10 XP per message
  → Progress bar fills as conversation grows
```

### Key Widgets (~23 reusable components)

**Design System** (17 widgets):

| Widget | Purpose |
|--------|---------|
| `FloatingNavBar` | 4-tab pill-shaped bottom nav (Accueil, Chat IA, Carte, Rédiger) |
| `SegmentedSearchBar` | Airbnb-style tripartite search (Démarche/Ville/Mode) |
| `FeatureSpotlightCard` | Full-width hero card with gradient + CTA |
| `ProcedureListingCard` | Vertical Airbnb-style listing card (260px wide) |
| `CategoryGridTile` | 2-column grid category card |
| `DuoChoiceCard` | Duolingo-style answer card (bounce + success animation) |
| `StepAccordionCard` | Expandable step card with completion toggle |
| `FilterChipRow` | Horizontal filter chips |
| `SectionHeader` | Section title for settings |
| `CivioTag` | Cost/time tag badge |
| `CivioBottomNav` | Legacy bottom navigation |
| `CivioSearchPill` | Search chip widget |
| `ChatChoiceCard` | Chat quick-prompt card |
| `ListingRow` | Horizontal listing row layout |
| `OfflinePill` | Offline badge pill |
| `CategoryRail` | Category side rail |
| `CivioTag` | Status/cost/time tag |

**Animations** (6 widgets):

| Widget | Purpose |
|--------|---------|
| `StaggerFadeSlide` | Staggered entry animations (index-based) |
| `BouncyPress` | Duolingo-style tap bounce |
| `DuoMascot` | Animated guide character (happy/thinking/celebrate) |
| `TypingDots` | Loading indicator (bouncing dots) |
| `DuoProgressBar` | Gamified XP progress bar |
| `MascotSpeechBubble` | Mascot + speech bubble combo |

**Other**:
- `DemoModeBanner` — Yellow tappable banner shown when Firebase is unavailable

---

## Data Flow Diagram

```
User
  ↓
Screen (UI Event)
  ↓
Provider (ChangeNotifier)
  ↓
Repository (data layer)
  ├── ProcedureRepository → Firestore (serverAndCache) → Procedure[]
  ├── AuthRepository → FirebaseAuth + Firestore citizens
  ├── ChatRepository:
  │   ├── OpenRouterService → HTTP POST → AI response
  │   └── FallbackAIService → Firestore procedures → formatted text
  ├── HistoryRepository → Sqflite (civio_history.db) → history[]
  └── VoiceProvider → speech_to_text / flutter_tts
  ↓
Provider (notifyListeners)
  ↓
Screen (rebuild)
```

---

## Key Design Decisions

1. **Offline-first**: All core features work without internet. Firestore uses `Source.serverAndCache`. The AI chat degrades gracefully from OpenRouter → local procedure database.

2. **Gamification**: XP system (15 per question, 10 per chat message, 50 for completion), Duolingo-style mascot, progress bars, celebration overlays — designed to make bureaucratic processes less intimidating.

3. **Demo mode**: When Firebase isn't available (Linux desktop dev, no emulator), the entire UI still renders. A yellow banner at the top warns users. Authentication is bypassed.

4. **Platform resilience**: Firebase initialization is wrapped in try/catch at the top of `main()`. If it fails, `AppConfig.firebaseEnabled = false` and `isDemoMode = true` cascades through every layer.

5. **Clean Architecture**: Domain entities are pure Dart. Repositories abstract data sources. Providers bridge data and UI. Screens never touch Firebase or SQLite directly.

6. **Hybrid AI**: The chat system checks connectivity first. If online AND the API key is valid, it sends requests to OpenRouter's free Mistral 7B endpoint. If offline or the API is rate-limited, it falls back to a keyword-matching engine over the local procedure database.

7. **Two auth modes**: Email/password (full Firebase Auth) is the primary method. Phone/SMS auth is scaffolded but not fully wired in the UI. Demo mode on desktop skips auth entirely.

8. **Map displays OSM tiles**: Uses `flutter_map` with OpenStreetMap tile layers. Office locations are either procedure-specific or fall back to hardcoded defaults (DGSN Centrale, PASSCAM Yaoundé).

---

## Tech Stack & Dependencies

| Layer | Technology | Package |
|-------|-----------|---------|
| Framework | Flutter | `flutter` SDK |
| State Mgmt | Provider | `provider: ^6.1.1` |
| DI | GetIt | `get_it: ^7.6.4` |
| Auth | Firebase Auth | `firebase_auth: ^6.5.2` |
| Database | Cloud Firestore | `cloud_firestore: ^6.5.0` |
| Local DB | Sqflite | `sqflite: ^2.3.0` |
| AI API | OpenRouter (HTTP) | `http: ^1.1.0` |
| Maps | Flutter Map (OSM) | `flutter_map: ^6.1.0` |
| Voice | Speech-to-Text | `speech_to_text: ^7.0.0` |
| TTS | Flutter TTS | `flutter_tts: ^3.8.5` |
| Fonts | Google Fonts | `google_fonts: ^6.1.0` |
| Icons | Font Awesome | `font_awesome_flutter: ^10.6.0` |
| SVG | Flutter SVG | `flutter_svg: ^2.0.10` |
| Location | Geolocator | `geolocator: ^10.1.0` |
| Permissions | Permission Handler | `permission_handler: ^11.0.1` |
| Sharing | Share Plus | `share_plus: ^7.2.1` |
| Connectivity | Connectivity Plus | `connectivity_plus: ^5.0.2` |
| Intl | Intl | `intl: ^0.18.1` |

---

## File Inventory (all source files)

```
lib/
├── main.dart                                  # Entry point, Firebase init, MultiProvider, routes
├── firebase_options.dart                      # Generated Firebase config
├── core/
│   ├── config/app_config.dart                 # Firebase flags, emulator settings, demo mode
│   ├── di/injection.dart                      # GetIt dependency registration
│   ├── services/
│   │   ├── ai_service.dart                    # AIService abstract interface
│   │   ├── connectivity_service.dart          # Network monitoring
│   │   ├── fallback_ai_service.dart           # Offline AI (Firestore procedure matcher)
│   │   └── openrouter_service.dart            # Online AI (OpenRouter API client)
│   ├── theme/app_theme.dart                   # Design tokens + Material 3 theme
│   └── utils/pdf_generator.dart               # Stubbed PDF generation
├── domain/
│   └── entities/procedure.dart                # Procedure, Question, ProcedureStep, ProcedureLocation
├── data/
│   └── repositories/
│       ├── auth_repository.dart               # Firebase Auth wrapper
│       ├── chat_repository.dart               # Hybrid AI (online/offline) repository
│       ├── history_repository.dart            # Sqflite history CRUD
│       └── procedure_repository.dart          # Firestore procedure CRUD + search
└── presentation/
    ├── providers/
    │   ├── ai_chat_provider.dart              # Chat state, message list, mode tracking
    │   ├── auth_provider.dart                 # Auth state stream, sign in/out
    │   ├── procedure_provider.dart            # Procedures, search, dialogue state machine
    │   └── voice_provider.dart                # STT + TTS wrapper
    ├── screens/
    │   ├── ai_chat_screen.dart                # AI chat UI (bubbles, input, welcome)
    │   ├── dialogue_screen.dart               # Step-by-step Q&A with mascot
    │   ├── document_generator_screen.dart     # PDF generation form + preview
    │   ├── history_screen.dart                # History listing from Sqflite
    │   ├── home_screen.dart                   # Main scrollable hub
    │   ├── login_screen.dart                  # Email/password + phone sign-in
    │   ├── offline_map_screen.dart            # OSM map with office markers
    │   ├── register_screen.dart               # Account creation form
    │   ├── result_screen.dart                 # Personalized step plan + celebration
    │   ├── settings_screen.dart               # Preferences (lang, city, voice, dark mode)
    │   └── splash_screen.dart                 # Animated logo + auth routing
    ├── widgets/
    │   ├── demo_mode_banner.dart              # Firebase-unavailable warning banner
    │   ├── animations/
    │   │   ├── animations.dart                # Barrel export
    │   │   ├── bouncy_press.dart              # Duolingo-style tap bounce
    │   │   ├── duo_mascot.dart                # Animated guide character + speech bubble
    │   │   ├── duo_progress.dart              # XP progress bar
    │   │   ├── stagger_fade_slide.dart        # Staggered entry animations
    │   │   └── typing_dots.dart               # Loading indicator
    │   └── design_system/
    │       ├── design_system.dart             # Barrel export (15 widgets)
    │       ├── category_grid_tile.dart
    │       ├── category_rail.dart
    │       ├── chat_choice_card.dart
    │       ├── civio_bottom_nav.dart
    │       ├── civio_search_pill.dart
    │       ├── civio_tag.dart
    │       ├── duo_choice_card.dart
    │       ├── feature_spotlight_card.dart
    │       ├── filter_chip_row.dart
    │       ├── floating_nav_bar.dart
    │       ├── listing_row.dart
    │       ├── offline_pill.dart
    │       ├── procedure_listing_card.dart
    │       ├── section_header.dart
    │       ├── segmented_search_bar.dart
    │       └── step_accordion_card.dart
```

## Test Coverage

`test/procedure_test.dart` — currently the only test file. The CI pipeline runs `flutter test` then `flutter build apk --release`.
