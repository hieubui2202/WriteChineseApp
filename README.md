# Hanzi Writing Trainer

Duolingo-style Flutter application for practicing Chinese character handwriting with Firebase integration.

## Features

- 🔐 Google & anonymous authentication with Firebase Auth
- ☁️ Firestore persistence for XP, streak, and per-character progress (offline cache with `SharedPreferences`)
- 🔊 Audio playback from Firebase Storage and bundled fallbacks
- ✍️ Stroke-by-stroke writing practice powered by [`hanzi_writer`](https://pub.dev/packages/hanzi_writer)
- 🧠 Five-step lesson flow: intro → listen → meaning → writing → missing stroke → result
- 📚 Flashcard review of mastered characters
- 🌐 `web/preview.html` for a quick static preview of the Duolingo-inspired layout

## Getting started

1. Install Flutter 3.19+ and run `flutter pub get`.
2. Configure Firebase using the provided `lib/firebase_options.dart` or regenerate via the FlutterFire CLI.
3. Enable Google and Anonymous providers in the Firebase console.
4. Run the app:
   ```bash
   flutter run
   ```

## Firebase structure

Reference the sample hierarchy in [`tools/firebase/firestore_structure.md`](tools/firebase/firestore_structure.md). Use [`tools/firebase/import_characters.py`](tools/firebase/import_characters.py) to import Excel/JSON data and upload audio files to Firebase Storage.

## Offline-ready data

Bundled fallback data lives in [`assets/data/sample_characters.json`](assets/data/sample_characters.json), allowing the app to render content even before Firestore is populated.

## Scripts & previews

- `tools/firebase/import_characters.py`: Imports characters from Excel and uploads audio to Storage.
- `web/preview.html`: Static neon-dark mock of the home experience.

## AI Builder summary

> Tạo ứng dụng học viết chữ Hán kiểu Duolingo bằng Flutter. Người học đăng nhập bằng Google (Firebase Auth), học từng chữ Hán (Firestore), nghe âm thanh từ Firebase Storage, viết chữ theo strokeData, và lưu tiến trình học (XP, streak, progress) lên Firestore. Giao diện dark mode, nút xanh neon, transition mượt, có Lottie animation.
