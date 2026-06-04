# AGENTS.md

## Cursor Cloud specific instructions

### Product

Single Flutter app (**Civio**, package `civio`) at repo root — offline-first assistant for Cameroon administrative procedures. Primary target is **Android**; **Linux desktop** is supported for local dev/Cloud Agent GUI testing.

### Services

| Service | Required for dev | Notes |
|---------|------------------|-------|
| Flutter app | Yes | `flutter pub get`, `flutter run` |
| Android SDK / emulator | For full Android E2E | Not preinstalled in Cloud VM; use Linux desktop or CI for APK builds |
| OpenRouter API | Optional | Key in `lib/main.dart` or env; offline dialogue works without it |

### Standard commands (see also `README.md`, `.github/workflows/flutter.yml`)

- **Dependencies:** `flutter pub get`
- **Lint:** `flutter analyze`
- **Tests:** `flutter test` (only `test/procedure_test.dart` today)
- **Run (Linux desktop):** `flutter run -d linux` (requires `flutter config --enable-linux-desktop`)
- **Release APK (CI):** `flutter build apk --release` (needs Android SDK + JDK 17)

### Linux desktop build (Cloud VM)

Flutter doctor expects **ninja**, **GTK 3 dev headers**, and a working C++ toolchain. If `flutter build linux` fails with `cannot find -lstdc++` or missing `type_traits`, install system packages once (not in the update script):

```bash
sudo apt-get install -y ninja-build libgtk-3-dev build-essential libstdc++-14-dev g++
```

Build with GCC (Clang default on Ubuntu 24.04 can fail to link):

```bash
export CC=gcc CXX=g++
flutter build linux --debug
./build/linux/x64/debug/bundle/civio
```

`DISPLAY` is typically `:1` in Cloud Agent VMs for GUI tests.

### Gotchas

- **PDF / printing** packages are commented out in `pubspec.yaml` for Linux; document generation is stubbed on desktop — test document flows on Android.
- **Sqflite** does not run on Linux desktop the same as Android; history/favorites E2E is best on device/emulator.
- **No monorepo**, **no Docker/backend** — bundled JSON in `assets/json/` is the knowledge base.
- Flutter SDK is expected at `$HOME/flutter` (stable channel); ensure `$HOME/flutter/bin` is on `PATH`.
