# Preparing Hanzi datasets

This guide explains how to organise the raw spreadsheet/JSON rows you collect (for example, `咖 | 咖啡 | coffee | kāfēi | …`) so they can be imported into Firebase and bundled with the app for offline testing.

## 1. Store your source files

* Place Excel/CSV/JSON source files inside [`tools/firebase/datasets/`](../tools/firebase/datasets/). The folder is tracked with a `.gitkeep` file so collaborators know where to add new lessons.
* Keep audio assets beside the spreadsheet. When you run the importer without a hosted URL, the tool uploads the file found in the same directory.

## 2. Map columns to the importer

The importer expects the columns listed below. Columns not listed are ignored, so you can keep helper notes in the sheet.

| Column name          | Description                                                                 | Example                                             |
|----------------------|-----------------------------------------------------------------------------|-----------------------------------------------------|
| `character`          | The Hanzi itself                                                            | `咖`                                                |
| `pinyin`             | Tone-marked pinyin                                                          | `kāfēi`                                             |
| `meaning`            | Localised meaning shown in the UI                                           | `coffee`                                            |
| `audioFileName`      | (Optional) Local audio filename placed next to the spreadsheet              | `kafei.mp3`                                         |
| `ttsUrl`             | (Optional) Remote audio URL. Takes priority when provided.                  | `https://…/kafei.mp3`                               |
| `strokeData.paths`   | Either a JSON array **or** a `|`-separated list of SVG path commands        | `M …|M …|M …`                                       |
| `strokeData.width`   | Canvas width in px                                                          | `109`                                               |
| `strokeData.height`  | Canvas height in px                                                         | `109`                                               |
| `unit`               | ID of the lesson (e.g. `section1_unit1`).                                   | `section1_unit1`                                    |

> 💡 The `strokeData.paths` column accepts the raw format from the sample row you provided. The importer will split the value on `|` and trim each segment into the array required by Firestore.

## 3. Import to Firebase

Run the importer as described in the [README](../README.md#importing-character-data-to-firebase). Hosted audio URLs (`ttsUrl`) are reused directly. When only `audioFileName` is supplied, the script uploads the matching file to `/audio/` in Firebase Storage and stores the resulting public URL in Firestore.

## 4. Keep offline fallbacks in sync

Update [`assets/data/sample_characters.json`](../assets/data/sample_characters.json) with any new characters you want available when Firestore is empty (for example during development or for demo builds). You can copy/paste the row into the JSON structure following the existing schema:

```json
{
  "character": "咖",
  "pinyin": "kāfēi",
  "meaning": "coffee",
  "ttsUrl": "https://…/kafei.mp3",
  "strokeData": {
    "width": 109,
    "height": 109,
    "paths": ["M …", "M …"]
  },
  "unit": "section1_unit1"
}
```

Keeping the spreadsheet, importer, and offline JSON aligned ensures the app shows the same dataset across platforms.
