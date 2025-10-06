# Hanzi Writing Trainer

Duolingo-style Flutter application for practising Chinese character handwriting with Firebase as the backend. This repository ships with the Flutter client, Firebase infrastructure artefacts, importer tooling, and an HTML admin console so you can run the entire stack end-to-end.

## Contents

- [Flutter app overview](#flutter-app-overview)
- [Firebase automation](#firebase-automation)
  - [Create projects](#create-projects)
  - [Configure products](#configure-products)
  - [Deploy rules, indexes, hosting, and functions](#deploy-rules-indexes-hosting-and-functions)
  - [Seed baseline data](#seed-baseline-data)
- [Admin console](#admin-console)
- [Data import tooling](#data-import-tooling)
- [App architecture](#app-architecture)
- [Offline data bundle](#offline-data-bundle)
- [Testing checklist](#testing-checklist)
- [Cost notes](#cost-notes)

## Flutter app overview

- 🔐 Google & anonymous authentication with Firebase Auth
- ☁️ Firestore persistence for XP, streak, and per-character progress (offline cache with `SharedPreferences`)
- 🔊 Audio playback from Firebase Storage and bundled fallbacks
- ✍️ Stroke-by-stroke writing practice with a custom animated canvas
- 🧠 Six-step lesson flow: intro → meaning → stroke demo → writing → missing stroke → result
- 📚 Flashcard review of mastered characters
- 🌐 `web/preview.html` for a quick static preview of the Duolingo-inspired layout

> Full Vietnamese documentation covering architecture, event flow, and dataset preparation lives in [`docs/vi/huong_dan_chi_tiet_ung_dung.md`](docs/vi/huong_dan_chi_tiet_ung_dung.md) and [`docs/vi/thiet_ke_du_lieu_firebase.md`](docs/vi/thiet_ke_du_lieu_firebase.md).

To run the Flutter client locally:

```bash
flutter pub get
flutter run
```

## Firebase automation

All Firebase artefacts live at the repository root so they can be applied via the Firebase CLI.
See [`docs/firebase_environments.md`](docs/firebase_environments.md) for environment switching, admin claim management, and reset scripts.

### Create projects

Use the Firebase CLI to spin up production (`hanzi-writing-trainer`) and development (`hanzi-writing-trainer-dev`) projects. If the ID is taken, append a timestamp suffix.

```bash
firebase projects:create hanzi-writing-trainer --region=asia-southeast1
firebase projects:create hanzi-writing-trainer-dev --region=asia-southeast1
```

Link the repository’s targets:

```bash
firebase use hanzi-writing-trainer
firebase target:apply hosting app hanzi-writing-trainer
firebase use hanzi-writing-trainer-dev
firebase target:apply hosting app hanzi-writing-trainer-dev
```

`.firebaserc` already tracks both projects and the shared hosting target (`app`).

### Configure products

Execute these commands for **each** project (dev and prod). Replace `<PROJECT_ID>` accordingly.

1. **Firestore** – provision in production mode in `asia-southeast1` (CLI prompt).
2. **Authentication** – enable Google and Anonymous providers and whitelist the domains:
   - `localhost`
   - `<PROJECT_ID>.web.app`
   - `<PROJECT_ID>.firebaseapp.com`
3. **Storage** – default bucket region must be `asia-southeast1`. Create folders:
   - `/audio/`
   - `/stroke/`
   - `/lottie/`
4. **Hosting** – ensure HTTP/2 and compression (default). The provided `firebase.json` rewrites `/_admin` to the admin console and blocks robots.
5. **App Check** – enable Play Integrity (Android), DeviceCheck (iOS), and reCAPTCHA v3 (managed) for Web.
6. **Functions** – set default region to `asia-southeast1`.

The README cannot toggle those settings automatically, so follow Firebase Console wizards or run:

```bash
firebase appcheck:debug --project <PROJECT_ID> # register debug tokens when testing locally
```

### Deploy rules, indexes, hosting, and functions

From the repository root run:

```bash
# Select the environment (prod shown below)
firebase use hanzi-writing-trainer

# Install Cloud Functions dependencies once per environment
npm --prefix functions install

# Deploy security rules and indexes
firebase deploy --only firestore:indexes,firestore:rules,storage:rules

# Deploy Cloud Functions and Hosting (includes admin console)
firebase deploy --only functions,hosting:app
```

The hosting target runs `node tools/firebase/copy_admin_console.mjs` before deployment so the admin console is copied to `web/_admin/index.html` automatically.

#### Cloud Functions shipped

- `setAdminClaim` *(callable)* – grants the `admin` custom claim to the specified email when invoked by an existing admin.
- `onUserCreate` *(auth trigger)* – provisions the `/users/{uid}` document with default stats.
- `onCharacterWrite` *(Firestore trigger)* – keeps `hanzi`, `character`, `createdAt`, and `updatedAt` fields synchronised.

Development variants of the rules are available as `firestore.dev.rules` and `storage.dev.rules` for local sandboxes. Swap the file paths inside `firebase.json` or pass the `--rules` flag when emulating.

### Seed baseline data

A baseline dataset (`茶、水、饭、汤`) lives at [`tools/firebase/seed/seed_data.json`](tools/firebase/seed/seed_data.json). Seed Firestore via the helper script:

```bash
python tools/firebase/seed/seed_firestore.py \
  --service-account path/to/serviceAccount.json \
  --project hanzi-writing-trainer
```

Run with `--dry-run` to preview the payload without writing to Firestore. Use the same command for the dev project.

## Admin console

`admin/hanzi_admin_console.html` is a single-file Firebase Web SDK console that supports Google sign-in, CRUD for `/characters`, and audio uploads to Storage. Deploying Hosting publishes it at `https://<PROJECT_ID>.web.app/_admin`.

Before deploying, edit the placeholder `firebaseConfig` object inside the HTML file with your project’s web configuration. Restrict access by granting the `admin` custom claim only to authorised accounts (see the callable function below). The console:

- Lists characters with pagination and search
- Allows editing of unitId, pinyin, meaning, TTS URL, and stroke data
- Uploads audio to `/audio/{hanzi}.mp3`, writing the download URL back to the document
- Respects Firestore rules—only users with `admin` claims can write

## Data import tooling

[`tools/firebase/import_characters.py`](tools/firebase/import_characters.py) ingests Excel spreadsheets and handles audio uploads. Columns:

| Column              | Description                                            |
| ------------------- | ------------------------------------------------------ |
| `character`         | Hanzi (document ID)                                    |
| `pinyin`            | Tone-marked pinyin                                     |
| `meaning`           | Localised meaning                                      |
| `audioFileName`     | Optional local MP3 filename                            |
| `ttsUrl`            | Optional pre-hosted audio URL                          |
| `unitId` / `unit`   | Owning unit identifier                                 |
| `strokeData.paths`  | JSON array or `|`-separated SVG path commands          |
| `strokeData.width`  | Stroke canvas width                                    |
| `strokeData.height` | Stroke canvas height                                   |

Setup and execution:

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r tools/firebase/requirements.txt
python tools/firebase/import_characters.py \
  --excel tools/firebase/datasets/characters.xlsx \
  --service-account path/to/serviceAccount.json \
  --bucket hanzi-writing-trainer.appspot.com
```

The script uploads audio into `/audio/`, updates `/characters/{hanzi}` (with `createdAt`/`updatedAt` timestamps), and ensures `/units/{unitId}` contains the character list.

## App architecture

The Flutter app follows a layered GetX clean architecture:

```
lib/
  core/          # theme, audio, offline helpers
  data/          # Firebase/Storage datasources and repository implementations
  domain/        # entities, repositories, and use cases
  presentation/  # GetX bindings, controllers, pages, and widgets
```

Key use cases include authentication (`SignInWithGoogle`, `SignInAnonymously`, `SignOut`), progress sync (`BootstrapProgress`, `SyncProgress`, `RecordLessonResult`), and lesson orchestration. Offline-first behaviour leverages Firestore persistence and SharedPreferences caching.

## Offline data bundle

[`assets/data/sample_characters.json`](assets/data/sample_characters.json) lets the app boot without Firestore. Update this file whenever you add new characters so testers can work offline.

## Testing checklist

- **Auth**: Google and anonymous sign-in succeed; non-admins cannot write to `/characters`
- **Rules**: Firestore/Storage rules match the environment (prod vs dev)
- **Admin Console**: CRUD flows succeed and audio uploads populate `ttsUrl`
- **Flutter App**: Six-step practice flow updates XP/streak/progress; review and profile tabs render
- **Functions**: `setAdminClaim` grants admin rights; `onUserCreate` and `onCharacterWrite` maintain metadata
- **Indexes**: Firestore queries on `(unitId, hanzi)` and `(pinyin, hanzi)` return without composite index errors
- **App Check**: Devices have registered debug tokens or platform attestation passes

## Cost notes

Estimated monthly costs (small pilot cohort):

- Firestore: < USD $1 (few thousand reads/writes)
- Storage: Depends on audio size (~$0.026/GB stored, $0.12/GB egress)
- Hosting: Free tier covers static content
- Functions: Billed per invocation/compute—light usage remains in the free tier

Monitor usage in the Firebase console and set spending alerts if you expect higher traffic.

## AI Builder summary

> Tạo ứng dụng học viết chữ Hán kiểu Duolingo bằng Flutter. Người học đăng nhập bằng Google (Firebase Auth), học từng chữ Hán (Firestore), nghe âm thanh từ Firebase Storage, viết chữ theo strokeData, và lưu tiến trình học (XP, streak, progress) lên Firestore. Giao diện dark mode, nút xanh neon, transition mượt, có Lottie animation.
