const { onRequest } = require('firebase-functions/v2/https');
const { setGlobalOptions } = require('firebase-functions/v2');
const admin = require('firebase-admin');

// Inicializar Firebase Admin SDK
admin.initializeApp();

// Configuración global para Cloud Functions (2ª Generación)
setGlobalOptions({
  region: 'us-central1',
  maxInstances: 10,
  serviceAccount: 'saver-expense-manager@appspot.gserviceaccount.com',
});

const DEFAULT_STORAGE_BUCKET =
  process.env.STORAGE_BUCKET_NAME || 'saver-expense-manager.firebasestorage.app';

/**
 * Cloud Function (2ª Gen) - deleteUserAccount
 *
 * Endpoint HTTPS seguro (Cloud Run) para eliminar en cascada la cuenta de un usuario:
 * 1. Valida el token JWT de Firebase Authentication (Bearer <idToken>).
 * 2. Elimina todos los archivos del usuario en Cloud Storage (users/{uid}/ y adjuntos legacy).
 * 3. Elimina en Firestore todos los movimientos del usuario (movements donde user == uid).
 * 4. Elimina cualquier registro de perfil o subcolecciones en users/{uid}.
 * 5. Elimina el registro del usuario en Firebase Authentication (admin.auth().deleteUser(uid)).
 */
exports.deleteUserAccount = onRequest(
  {
    timeoutSeconds: 300,
    memory: '512MiB',
    cors: true,
    serviceAccount: 'saver-expense-manager@appspot.gserviceaccount.com',
  },
  async (req, res) => {
    // Manejo de preflight CORS
    if (req.method === 'OPTIONS') {
      res.status(204).send('');
      return;
    }

    if (req.method !== 'POST') {
      res.status(405).json({ error: 'Method Not Allowed. Use POST.' });
      return;
    }

    // Validar cabecera Authorization: Bearer <idToken>
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      res.status(401).json({ error: 'Unauthorized: Missing or invalid token.' });
      return;
    }

    const idToken = authHeader.split('Bearer ')[1];
    let uid;
    let email = 'no-email';

    try {
      const decodedToken = await admin.auth().verifyIdToken(idToken);
      uid = decodedToken.uid;
      email = decodedToken.email || 'no-email';
    } catch (err) {
      res.status(401).json({ error: `Unauthorized: Invalid token (${err.message}).` });
      return;
    }

    console.log(`🧹 [2nd Gen] Starting cascade deletion for user: ${uid} (${email})`);

    const db = admin.firestore();
    const bucket = admin.storage().bucket(DEFAULT_STORAGE_BUCKET);

    let deletedStorageFiles = 0;
    let deletedMovementsCount = 0;

    // -------------------------------------------------------------------------
    // 1. Obtener movimientos en Firestore y detectar adjuntos legacy
    // -------------------------------------------------------------------------
    const legacyAttachments = new Set();
    const movementDocRefs = [];

    try {
      const snapshot = await db
        .collection('movements')
        .where('user', '==', uid)
        .get();

      snapshot.forEach((doc) => {
        movementDocRefs.push(doc.ref);
        const data = doc.data() || {};
        const attachments = data.attachments;
        if (Array.isArray(attachments)) {
          attachments.forEach((att) => {
            if (typeof att === 'string' && att && !att.startsWith(`users/${uid}/`)) {
              legacyAttachments.add(att);
            }
          });
        }
      });
    } catch (err) {
      console.error(`❌ Error querying movements: ${err.message}`);
    }

    // -------------------------------------------------------------------------
    // 2. Eliminar archivos en Cloud Storage bajo users/{uid}/
    // -------------------------------------------------------------------------
    const userStoragePrefix = `users/${uid}/`;
    try {
      const [files] = await bucket.getFiles({ prefix: userStoragePrefix });
      for (const file of files) {
        try {
          await file.delete();
          deletedStorageFiles++;
        } catch (err) {
          console.warn(`Failed to delete storage file ${file.name}: ${err.message}`);
        }
      }
    } catch (err) {
      console.error(`❌ Error deleting storage files: ${err.message}`);
    }

    // -------------------------------------------------------------------------
    // 3. Eliminar adjuntos históricos fuera del prefijo users/{uid}/
    // -------------------------------------------------------------------------
    if (legacyAttachments.size > 0) {
      for (const attPath of legacyAttachments) {
        try {
          const file = bucket.file(attPath);
          const [exists] = await file.exists();
          if (exists) {
            await file.delete();
            deletedStorageFiles++;
          }
        } catch (err) {
          console.warn(`Failed to delete legacy attachment ${attPath}: ${err.message}`);
        }
      }
    }

    // -------------------------------------------------------------------------
    // 4. Eliminar movimientos en Firestore por lotes (batches de 400 docs)
    // -------------------------------------------------------------------------
    try {
      let batch = db.batch();
      let batchCount = 0;

      for (const docRef of movementDocRefs) {
        batch.delete(docRef);
        batchCount++;
        deletedMovementsCount++;

        if (batchCount >= 400) {
          await batch.commit();
          batch = db.batch();
          batchCount = 0;
        }
      }

      if (batchCount > 0) {
        await batch.commit();
      }
    } catch (err) {
      console.error(`❌ Error deleting movements: ${err.message}`);
    }

    // -------------------------------------------------------------------------
    // 5. Eliminar perfil de usuario en users/{uid} si existiera
    // -------------------------------------------------------------------------
    try {
      const userDocRef = db.collection('users').doc(uid);
      await db.recursiveDelete(userDocRef);
    } catch (_) {
      try {
        const userDocRef = db.collection('users').doc(uid);
        const docSnap = await userDocRef.get();
        if (docSnap.exists) {
          await userDocRef.delete();
        }
      } catch (_) {}
    }

    // -------------------------------------------------------------------------
    // 6. Eliminar usuario de Firebase Authentication
    // -------------------------------------------------------------------------
    try {
      await admin.auth().deleteUser(uid);
      console.log(`✅ User ${uid} deleted from Firebase Auth.`);
    } catch (err) {
      console.error(`❌ Error deleting user from Firebase Auth: ${err.message}`);
      res.status(500).json({ error: `Failed to delete auth user: ${err.message}` });
      return;
    }

    console.log(
      `✅ [2nd Gen] Cleanup complete for user ${uid}. Deleted ${deletedMovementsCount} movements and ${deletedStorageFiles} files.`
    );

    res.status(200).json({
      success: true,
      deletedMovements: deletedMovementsCount,
      deletedFiles: deletedStorageFiles,
    });
  }
);
