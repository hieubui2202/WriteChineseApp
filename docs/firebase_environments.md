# Firebase environment guide

This document describes how to operate the production (`hanzi-writing-trainer`) and development (`hanzi-writing-trainer-dev`) Firebase projects. Use it alongside the repository root README.

## Rule variants

| File                 | Use case                                   |
| -------------------- | ------------------------------------------ |
| `firestore.rules`    | Production: public read for lessons, admin write only |
| `firestore.dev.rules`| Development: signed-in users can write characters/units |
| `storage.rules`      | Production: public read of assets, admin uploads |
| `storage.dev.rules`  | Development: any signed-in user may upload test assets |

Switch between them by editing `firebase.json` before deploying or by running:

```bash
firebase deploy --only firestore:rules --project hanzi-writing-trainer --force --rules firestore.rules
firebase deploy --only firestore:rules --project hanzi-writing-trainer-dev --force --rules firestore.dev.rules
```

Likewise for Storage:

```bash
firebase deploy --only storage --project hanzi-writing-trainer --force --rules storage.rules
firebase deploy --only storage --project hanzi-writing-trainer-dev --force --rules storage.dev.rules
```

## Admin claims workflow

1. Deploy the Cloud Functions.
2. Sign in with a Google account that already has the `admin` claim (seed via Firebase Console using the `setAdminClaim` callable with the service account emulator or temporarily mark the first admin in the Authentication console).
3. Call the callable:

```bash
firebase functions:call setAdminClaim --data '{"email":"admin@example.com"}' --project hanzi-writing-trainer
```

The function enforces that the caller already holds the `admin` claim. Repeat in the dev project as required.

## Resetting seed data

Use the helper script to purge and repopulate the dev project when testing:

```bash
# Delete existing documents (use with caution!)
firebase firestore:delete --project hanzi-writing-trainer-dev --recursive --force characters
firebase firestore:delete --project hanzi-writing-trainer-dev --recursive --force units
firebase firestore:delete --project hanzi-writing-trainer-dev --recursive --force users

# Reseed
python tools/firebase/seed/seed_firestore.py \
  --service-account path/to/serviceAccount.json \
  --project hanzi-writing-trainer-dev
```

## Hosting routes

- `/` – Flutter web build or static preview
- `/_admin` – Admin console (blocked by `X-Robots-Tag: noindex`)

Use Firebase Hosting’s role-based access or Cloud Armor/IP restrictions if you need further hardening around the admin console URL.
