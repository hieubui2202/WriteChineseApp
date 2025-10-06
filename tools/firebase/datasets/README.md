# Dataset dropzone

Place your curated spreadsheets or JSON exports for Hanzi lessons in this directory. Recommended filenames:

- `characters.xlsx` — master spreadsheet imported via `../import_characters.py`
- `characters_local.json` — optional JSON export mirroring the Firestore structure

Keep accompanying audio files alongside the spreadsheet (or specify `--audio-dir` when running the importer) so the script can upload them to Firebase Storage automatically.
