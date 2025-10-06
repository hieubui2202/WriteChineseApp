"""Utility script to import Hanzi data from Excel/JSON into Firebase Firestore & Storage.

Setup:
    pip install -r tools/firebase/requirements.txt

Usage:
    python import_characters.py --excel characters.xlsx --service-account serviceAccount.json --bucket hanziapp.appspot.com

The Excel file should contain the columns:
    character | pinyin | meaning | audioFileName | ttsUrl | strokeData.paths | strokeData.width | strokeData.height | unitId

The script will:
  * Upload audio files from the same folder to Firebase Storage under /audio/
  * Create/merge character documents inside the /characters collection
  * Ensure the destination unit document lists the character ID

You must authenticate with Firebase using service account credentials.
"""

from __future__ import annotations

import argparse
import json
import pathlib
from typing import List

import firebase_admin
from firebase_admin import credentials, firestore, storage
import pandas as pd


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Import Hanzi characters into Firestore")
    parser.add_argument("--excel", required=True, type=pathlib.Path, help="Path to the Excel file")
    parser.add_argument(
        "--service-account",
        required=True,
        type=pathlib.Path,
        help="Firebase service account JSON key",
    )
    parser.add_argument("--bucket", required=True, help="Firebase storage bucket id")
    parser.add_argument(
        "--audio-dir",
        type=pathlib.Path,
        default=None,
        help="Directory containing audio files (defaults to Excel parent folder)",
    )
    return parser.parse_args()


def ensure_firebase_creds(service_account: pathlib.Path, bucket: str) -> None:
    cred = credentials.Certificate(service_account)
    firebase_admin.initialize_app(cred, {"storageBucket": bucket})


def upload_audio(bucket: storage.bucket.Bucket, audio_path: pathlib.Path) -> str:
    blob = bucket.blob(f"audio/{audio_path.name}")
    blob.upload_from_filename(audio_path)
    blob.make_public()
    return blob.public_url


def update_unit_characters(db: firestore.Client, unit_id: str, character_id: str) -> None:
    unit_ref = db.collection("units").document(unit_id)
    unit_snapshot = unit_ref.get()
    characters: List[str] = []
    if unit_snapshot.exists:
        data = unit_snapshot.to_dict() or {}
        characters = [str(c) for c in data.get("characters", [])]
    if character_id not in characters:
        characters.append(character_id)
    payload = {
        "characters": characters,
        "updatedAt": firestore.SERVER_TIMESTAMP,
    }
    if not unit_snapshot.exists:
        payload.update(
            {
                "title": "Pending title",
                "description": "",
                "order": 0,
                "xpReward": 10,
                "createdAt": firestore.SERVER_TIMESTAMP,
            }
        )
    unit_ref.set(payload, merge=True)


def main() -> None:
    args = parse_args()
    ensure_firebase_creds(args.service_account, args.bucket)

    excel_path = args.excel
    audio_dir = args.audio_dir or excel_path.parent

    df = pd.read_excel(excel_path)
    db = firestore.client()
    bucket = storage.bucket()

    for _, row in df.iterrows():
        character = str(row["character"]).strip()
        if not character:
            continue
        pinyin = str(row.get("pinyin", "")).strip()
        meaning = str(row.get("meaning", "")).strip()
        unit_id = str(row.get("unitId", row.get("unit", ""))).strip() or "section1_unit1"
        audio_file = str(row.get("audioFileName", "")).strip()
        provided_tts = str(
            row.get("ttsUrl", row.get("audioUrl", ""))
        ).strip()
        width = int(row.get("strokeData.width", 109))
        height = int(row.get("strokeData.height", 109))
        raw_paths = row.get("strokeData.paths", "[]")
        paths: List[str]
        if isinstance(raw_paths, str):
            stripped = raw_paths.strip()
            if not stripped:
                paths = []
            elif stripped.startswith("["):
                paths = json.loads(stripped)
            elif "|" in stripped:
                paths = [segment.strip() for segment in stripped.split("|") if segment.strip()]
            else:
                paths = [line.strip() for line in stripped.splitlines() if line.strip()]
        else:
            paths = [str(p) for p in raw_paths if str(p).strip()]

        tts_url = provided_tts
        if audio_file:
            audio_path = audio_dir / audio_file
            if audio_path.exists():
                tts_url = upload_audio(bucket, audio_path)
            else:
                print(f"[warn] audio file not found for {character}: {audio_path}")
        elif not tts_url:
            print(f"[warn] no audio provided for {character}; leaving ttsUrl empty")

        char_doc = {
            "hanzi": character,
            "character": character,
            "pinyin": pinyin,
            "meaning": meaning,
            "ttsUrl": tts_url,
            "strokeData": {
                "width": width,
                "height": height,
                "paths": paths,
            },
            "unitId": unit_id,
            "createdAt": firestore.SERVER_TIMESTAMP,
            "updatedAt": firestore.SERVER_TIMESTAMP,
        }
        db.collection("characters").document(character).set(char_doc, merge=True)
        update_unit_characters(db, unit_id, character)
        print(f"Imported {character} ({pinyin})")

    print("✅ Import completed!")


if __name__ == "__main__":
    main()
