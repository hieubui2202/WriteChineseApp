"""Seed Firestore with baseline Hanzi data using a service account."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

import firebase_admin
from firebase_admin import credentials, firestore


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Seed Firestore with baseline documents")
    parser.add_argument("--service-account", required=True, type=Path, help="Path to service account JSON")
    parser.add_argument("--project", required=True, help="Firebase project id")
    parser.add_argument(
        "--data",
        type=Path,
        default=Path(__file__).with_name("seed_data.json"),
        help="Path to the seed JSON payload",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Only print the writes without pushing to Firestore",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    payload = json.loads(args.data.read_text(encoding="utf-8"))

    print(f"Preparing to seed project {args.project} with {len(payload.get('characters', {}))} characters")

    if args.dry_run:
        print(json.dumps(payload, ensure_ascii=False, indent=2))
        return

    cred = credentials.Certificate(args.service_account)
    firebase_admin.initialize_app(cred, {"projectId": args.project})
    client = firestore.client()

    batch = client.batch()

    for hanzi, data in payload.get("characters", {}).items():
        doc_ref = client.collection("characters").document(hanzi)
        batch.set(doc_ref, {**data, "createdAt": firestore.SERVER_TIMESTAMP, "updatedAt": firestore.SERVER_TIMESTAMP}, merge=True)

    for unit_id, data in payload.get("units", {}).items():
        doc_ref = client.collection("units").document(unit_id)
        batch.set(
            doc_ref,
            {
                **data,
                "createdAt": firestore.SERVER_TIMESTAMP,
                "updatedAt": firestore.SERVER_TIMESTAMP,
            },
            merge=True,
        )

    for user_id, data in payload.get("users", {}).items():
        doc_ref = client.collection("users").document(user_id)
        batch.set(
            doc_ref,
            {
                **data,
                "createdAt": firestore.SERVER_TIMESTAMP,
                "updatedAt": firestore.SERVER_TIMESTAMP,
            },
            merge=True,
        )

    batch.commit()
    print("✅ Seed completed")


if __name__ == "__main__":
    main()
