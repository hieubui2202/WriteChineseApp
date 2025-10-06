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

### Importing character data to Firebase

1. **Prepare the Excel sheet** using the template columns described in the script header (`character`, `pinyin`, `meaning`, `audioFileName`, `strokeData.paths`, `strokeData.width`, `strokeData.height`, `unit`). Each row represents a character. The `strokeData.paths` column can contain a JSON array (e.g. `"[\"M 10 10 ...\"]"`).
2. **Gather audio assets** in the same folder as the Excel file (or pass `--audio-dir` when running the script). The filename must match the `audioFileName` column.
3. **Create a Firebase service account key** with Firestore and Storage permissions and download the JSON credentials file.
4. **Run the importer** from the project root:
   ```bash
   python tools/firebase/import_characters.py \
     --excel path/to/characters.xlsx \
     --service-account path/to/serviceAccount.json \
     --bucket your-project-id.appspot.com
   ```
   Add `--audio-dir path/to/audio` if the audio files are not alongside the spreadsheet.
5. The script uploads audio files to `/audio/` in Firebase Storage, creates/updates documents in `/characters`, and ensures the referenced `/units/{unitId}` document lists each character. Review the console output for warnings about missing files.

After importing, the mobile app will sync the Firestore data on launch. Use the bundled [`assets/data/sample_characters.json`](assets/data/sample_characters.json) for offline/local testing before your Firebase project is populated.

### Where to store your source spreadsheet/JSON

- Keep your master spreadsheet or JSON exports inside [`tools/firebase/datasets/`](tools/firebase/datasets/) so they travel with the project (the folder ships with a `.gitkeep` placeholder). See [`docs/data_preparation.md`](docs/data_preparation.md) for a detailed walkthrough.
- Each row can look like the sample you shared (`咖 | 咖啡 | coffee | kāfēi | …`). Map the columns to the importer template and, for stroke paths separated by `|`, the importer will automatically split them into an array.
- If you already have hosted audio, fill the `ttsUrl` column and the importer will reuse it instead of uploading a local file. Otherwise place the audio file alongside the spreadsheet and populate `audioFileName`.
- Duplicate any new characters into [`assets/data/sample_characters.json`](assets/data/sample_characters.json) when you want them available for offline testing in debug builds.

## Offline-ready data

Bundled fallback data lives in [`assets/data/sample_characters.json`](assets/data/sample_characters.json), allowing the app to render content even before Firestore is populated.

## Scripts & previews

- `tools/firebase/import_characters.py`: Imports characters from Excel and uploads audio to Storage.
- `web/preview.html`: Static neon-dark mock of the home experience.

## AI Builder summary

> Tạo ứng dụng học viết chữ Hán kiểu Duolingo bằng Flutter. Người học đăng nhập bằng Google (Firebase Auth), học từng chữ Hán (Firestore), nghe âm thanh từ Firebase Storage, viết chữ theo strokeData, và lưu tiến trình học (XP, streak, progress) lên Firestore. Giao diện dark mode, nút xanh neon, transition mượt, có Lottie animation.
