const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.setUserRole = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "No autenticado.");
  }

  const callerClaims = context.auth.token || {};
  if (callerClaims.role !== "admin") {
    throw new functions.https.HttpsError(
        "permission-denied",
        "Solo admin puede asignar roles.",
    );
  }

  const {uid, role} = data || {};
  if (!uid || !role) {
    throw new functions.https.HttpsError(
        "invalid-argument",
        "Falta uid o role.",
    );
  }

  const allowed = ["admin", "user", "system"];
  if (allowed.indexOf(role) === -1) {
    throw new functions.https.HttpsError("invalid-argument", "Role inválido.");
  }

  try {
    await admin.auth().setCustomUserClaims(uid, {role});
    return {ok: true, uid, role};
  } catch (err) {
    throw new functions.https.HttpsError("internal", err.message);
  }
});
