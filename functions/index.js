const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

const REGION = 'asia-southeast1';

exports.setAdminClaim = functions.region(REGION).https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Authentication required.');
  }
  const caller = await admin.auth().getUser(context.auth.uid);
  if (!caller.customClaims || caller.customClaims.admin !== true) {
    throw new functions.https.HttpsError('permission-denied', 'Admin claim required.');
  }
  const email = data?.email;
  if (!email) {
    throw new functions.https.HttpsError('invalid-argument', 'Email is required.');
  }
  const target = await admin.auth().getUserByEmail(email);
  await admin.auth().setCustomUserClaims(target.uid, { ...(target.customClaims || {}), admin: true });
  return { success: true };
});

exports.onUserCreate = functions.region(REGION).auth.user().onCreate(async (user) => {
  const userDoc = {
    displayName: user.displayName || '',
    email: user.email || '',
    avatarUrl: user.photoURL || '',
    xp: 0,
    streakDays: 0,
    lastActive: admin.firestore.FieldValue.serverTimestamp(),
    progress: {},
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };
  await admin.firestore().collection('users').doc(user.uid).set(userDoc, { merge: true });
});

exports.onCharacterWrite = functions
  .region(REGION)
  .firestore.document('characters/{hanzi}')
  .onWrite(async (change, context) => {
    if (!change.after.exists) {
      return null;
    }
    const after = change.after;
    const basePayload = {
      hanzi: after.id,
      character: after.get('character') || after.id,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };
    if (!change.before.exists) {
      basePayload.createdAt = admin.firestore.FieldValue.serverTimestamp();
    }
    await after.ref.set(
      basePayload,
      { merge: true }
    );
    return null;
  });
