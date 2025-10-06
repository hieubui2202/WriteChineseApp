# Hanzi Writing Trainer

Duolingo-style Flutter application for practicing Chinese character handwriting with Firebase integration.

## Features

- 🔐 Google & anonymous authentication with Firebase Auth
- ☁️ Firestore persistence for XP, streak, and per-character progress (offline cache with `SharedPreferences`)
- 🔊 Audio playback from Firebase Storage and bundled fallbacks
- ✍️ Stroke-by-stroke writing practice with a custom animated canvas
- 🧠 Five-step lesson flow: intro → listen → meaning → writing → missing stroke → result
- 📚 Flashcard review of mastered characters
- 🌐 `web/preview.html` for a quick static preview of the Duolingo-inspired layout

## Getting started

1. Install Flutter 3.19+ and run `flutter pub get`.
2. Configure Firebase using the provided `lib/firebase_options.dart` or regenerate via the FlutterFire CLI.
3. Enable Google, Anonymous, and App Check providers in the Firebase console. For local testing, register your device or use the
   automatically enabled debug provider (configured in `main.dart`).
4. Run the app:
   ```bash
   flutter run
   ```

## Architecture

The app follows a GetX-powered clean architecture split into layered packages:

- `domain/` — Entities, repository contracts, and use cases describing the business rules.
- `data/` — Firebase/Storage/SharedPreferences implementations that fulfill the domain repositories.
- `presentation/` — GetX controllers, bindings, and UI pages (plus reusable widgets in `presentation/widgets`).
- `core/` — Cross-cutting helpers such as the shared audio service.

Global dependencies are wired through `presentation/bindings/app_binding.dart`, ensuring controllers receive only the
use cases they need while keeping layers decoupled and testable.

## Firebase structure

Reference the sample hierarchy in [`tools/firebase/firestore_structure.md`](tools/firebase/firestore_structure.md). Use [`tools/firebase/import_characters.py`](tools/firebase/import_characters.py) to import Excel/JSON data and upload audio files to Firebase Storage.

## Offline-ready data

Bundled fallback data lives in [`assets/data/sample_characters.json`](assets/data/sample_characters.json), allowing the app to render content even before Firestore is populated.

## Scripts & previews

- `tools/firebase/import_characters.py`: Imports characters from Excel and uploads audio to Storage.
- `web/preview.html`: Static neon-dark mock of the home experience.

## AI Builder summary

> Tạo ứng dụng học viết chữ Hán kiểu Duolingo bằng Flutter. Người học đăng nhập bằng Google (Firebase Auth), học từng chữ Hán (Firestore), nghe âm thanh từ Firebase Storage, viết chữ theo strokeData, và lưu tiến trình học (XP, streak, progress) lên Firestore. Giao diện dark mode, nút xanh neon, transition mượt, có Lottie animation.
