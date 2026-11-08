#!/usr/bin/env node

/**
 * Script de limpieza y migración de Firebase Storage para Saver Expense Manager.
 *
 * Funcionalidades:
 * 1. Analiza todos los movimientos en Firestore ('movements') y recopila los archivos adjuntos vinculados.
 * 2. Examina todos los archivos presentes en el bucket de Firebase Storage.
 * 3. Detecta archivos huérfanos (no asociados a ningún movimiento) y permite eliminarlos de forma segura.
 * 4. (Opcional con --migrate): Migra archivos válidos históricos desde la raíz hacia 'users/{userId}/attachments/{fileName}',
 *    actualizando las referencias en Firestore para habilitar reglas estrictas de Storage multitenant.
 *
 * Uso desde la carpeta storage_cleanup:
 *   npm run clean            # Modo simulación (Dry-Run): analiza e informa
 *   npm run clean:delete     # Elimina archivos huérfanos confirmados
 *   npm run clean:migrate    # Migra archivos válidos de la raíz a users/{userId}/attachments/
 *   npm run clean:all        # Limpia huérfanos y migra válidos en una sola pasada
 */

const fs = require('fs');
const path = require('path');

// Intentar cargar firebase-admin
let admin;
try {
  admin = require('firebase-admin');
} catch (e) {
  console.error('\n❌ ERROR: El paquete "firebase-admin" no está instalado en este directorio.');
  console.error('👉 Por favor ejecuta en la terminal dentro de esta carpeta (storage_cleanup):\n');
  console.error('   cd storage_cleanup && npm install\n');
  process.exit(1);
}

// Parámetros por defecto
const DEFAULT_PROJECT_ID = 'saver-expense-manager';
const DEFAULT_STORAGE_BUCKET = 'saver-expense-manager.firebasestorage.app';
const MOVEMENTS_COLLECTION = 'movements';

// Parsear argumentos CLI
const args = process.argv.slice(2);
const isDeleteEnabled = args.includes('--delete');
const isMigrateEnabled = args.includes('--migrate');
const isDryRun = !isDeleteEnabled && !isMigrateEnabled;

const serviceAccountArgIndex = args.indexOf('--service-account');
const customServiceAccountPath = serviceAccountArgIndex !== -1 ? args[serviceAccountArgIndex + 1] : null;

// Inicialización de Firebase Admin
function initializeFirebase() {
  const possiblePaths = [
    customServiceAccountPath,
    path.join(__dirname, 'service-account.json'),
    path.join(__dirname, 'serviceAccountKey.json'),
    path.join(__dirname, '..', 'service-account.json'),
    path.join(__dirname, '..', 'serviceAccountKey.json'),
    process.env.GOOGLE_APPLICATION_CREDENTIALS,
  ].filter(Boolean);

  let serviceAccountFile = possiblePaths.find((p) => fs.existsSync(p));

  if (serviceAccountFile) {
    console.log(`🔑 Usando credencial de cuenta de servicio: ${serviceAccountFile}`);
    const serviceAccount = JSON.parse(fs.readFileSync(serviceAccountFile, 'utf8'));
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      storageBucket: serviceAccount.project_id ? `${serviceAccount.project_id}.firebasestorage.app` : DEFAULT_STORAGE_BUCKET,
    });
  } else {
    console.log('ℹ️  No se encontró service-account.json local. Intentando Application Default Credentials...');
    admin.initializeApp({
      credential: admin.credential.applicationDefault(),
      projectId: DEFAULT_PROJECT_ID,
      storageBucket: DEFAULT_STORAGE_BUCKET,
    });
  }
}

function formatBytes(bytes) {
  if (bytes === 0) return '0 B';
  const k = 1024;
  const sizes = ['B', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
}

async function run() {
  console.log('====================================================');
  console.log('   🧹 SAVER EXPENSE MANAGER - STORAGE CLEANUP & MIGRATION');
  console.log('====================================================');
  if (isDryRun) {
    console.log('⚠️  MODO SIMULACIÓN (DRY-RUN): No se modificará ni eliminará nada.');
    console.log('👉 Para borrar huérfanos ejecuta: npm run clean:delete');
    console.log('👉 Para migrar archivos raíz ejecuta: npm run clean:migrate\n');
  }

  try {
    initializeFirebase();
  } catch (err) {
    console.error('❌ Error al inicializar Firebase Admin:', err.message);
    console.error('\nConsejo: Asegúrate de tener una cuenta de servicio válida o haber iniciado sesión con:');
    console.error('   gcloud auth application-default login\n');
    process.exit(1);
  }

  const db = admin.firestore();
  const bucket = admin.storage().bucket();

  console.log(`📦 Bucket configurado: ${bucket.name}`);
  console.log('🔍 Paso 1: Consultando movimientos en Firestore...');

  const movementsSnapshot = await db.collection(MOVEMENTS_COLLECTION).get();
  console.log(`📄 Total de movimientos en Firestore: ${movementsSnapshot.size}`);

  // Mapeos:
  // validAttachmentsSet: contiene todas las rutas o nombres de archivo vinculados
  // attachmentToMovementMap: mapa fileName/path -> { movementId, userId, fullDocRef }
  const validAttachmentsSet = new Set();
  const attachmentToMovementMap = new Map();

  for (const doc of movementsSnapshot.docs) {
    const data = doc.data();
    const attachments = data.attachments || [];
    const userId = data.user || 'unknown_user';

    for (const att of attachments) {
      if (typeof att === 'string' && att.trim().length > 0) {
        const cleanAtt = att.trim();
        validAttachmentsSet.add(cleanAtt);

        // Guardamos también el nombre base por si la ruta está almacenada de forma relativa o absoluta
        const baseName = path.basename(cleanAtt);
        validAttachmentsSet.add(baseName);

        attachmentToMovementMap.set(cleanAtt, {
          docId: doc.id,
          docRef: doc.ref,
          userId: userId,
          currentAttachments: attachments,
        });
        if (cleanAtt !== baseName) {
          attachmentToMovementMap.set(baseName, {
            docId: doc.id,
            docRef: doc.ref,
            userId: userId,
            currentAttachments: attachments,
          });
        }
      }
    }
  }

  console.log(`📎 Total de referencias a adjuntos válidos registradas en Firestore: ${validAttachmentsSet.size}`);
  console.log('\n🔍 Paso 2: Listando archivos en Firebase Storage...');

  const [files] = await bucket.getFiles();
  console.log(`📁 Total de archivos encontrados en Storage: ${files.length}\n`);

  const orphanFiles = [];
  const validFiles = [];
  let totalOrphanBytes = 0;
  let totalValidBytes = 0;

  for (const file of files) {
    const filePath = file.name;
    const baseName = path.basename(filePath);
    const size = parseInt(file.metadata.size || 0, 10);

    // Verificar si está vinculado a un movimiento
    const isValid = validAttachmentsSet.has(filePath) || validAttachmentsSet.has(baseName);

    if (isValid) {
      validFiles.push({ file, filePath, baseName, size });
      totalValidBytes += size;
    } else {
      orphanFiles.push({ file, filePath, baseName, size });
      totalOrphanBytes += size;
    }
  }

  console.log('----------------------------------------------------');
  console.log(`✅ Archivos vinculados válidos: ${validFiles.length} (${formatBytes(totalValidBytes)})`);
  console.log(`🗑️  Archivos huérfanos detectados: ${orphanFiles.length} (${formatBytes(totalOrphanBytes)})`);
  console.log('----------------------------------------------------\n');

  // Detalle de archivos huérfanos
  if (orphanFiles.length > 0) {
    console.log('📋 Lista de archivos huérfanos:');
    orphanFiles.forEach((o, idx) => {
      console.log(`  [${idx + 1}] ${o.filePath} (${formatBytes(o.size)})`);
    });
    console.log('');

    if (isDeleteEnabled) {
      console.log(`🚨 ELIMINANDO ${orphanFiles.length} ARCHIVOS HUÉRFANOS...`);
      let deletedCount = 0;
      for (const orphan of orphanFiles) {
        try {
          await orphan.file.delete();
          deletedCount++;
          process.stdout.write(`\r   Progreso: ${deletedCount}/${orphanFiles.length} eliminados...`);
        } catch (delErr) {
          console.error(`\n   ❌ Error al eliminar ${orphan.filePath}:`, delErr.message);
        }
      }
      console.log(`\n🎉 Limpieza completada: ${deletedCount} archivos eliminados exitosamente.`);
    } else {
      console.log('ℹ️  Ejecuta con "npm run clean:delete" para proceder a eliminar estos archivos huérfanos de Storage.');
    }
  } else {
    console.log('✨ No se encontraron archivos huérfanos en Storage. Tu bucket está limpio.');
  }

  // Migración opcional de archivos de la raíz a users/{userId}/attachments/
  if (isMigrateEnabled) {
    console.log('\n🔄 Paso 3: MIGRACIÓN DE ARCHIVOS RAÍZ A users/{userId}/attachments/...');
    const rootValidFiles = validFiles.filter((v) => !v.filePath.includes('/'));

    console.log(`📦 Archivos en la raíz que requieren migración: ${rootValidFiles.length}`);

    if (rootValidFiles.length === 0) {
      console.log('✨ Todos los archivos válidos ya están en carpetas por usuario o no hay archivos raíz pendientes.');
    } else {
      let migratedCount = 0;
      for (const item of rootValidFiles) {
        const info = attachmentToMovementMap.get(item.filePath) || attachmentToMovementMap.get(item.baseName);
        if (!info || !info.userId) {
          console.warn(`⚠️  No se encontró userId para ${item.filePath}, omitiendo...`);
          continue;
        }

        const newPath = `users/${info.userId}/attachments/${item.baseName}`;
        console.log(`   Moviendo: ${item.filePath} -> ${newPath}`);

        try {
          // Copiar archivo a la nueva ubicación
          const newFile = bucket.file(newPath);
          await item.file.copy(newFile);

          // Eliminar archivo original de la raíz
          await item.file.delete();

          // Actualizar documento en Firestore
          const updatedAttachments = info.currentAttachments.map((att) =>
            att === item.filePath || att === item.baseName ? newPath : att
          );
          await info.docRef.update({ attachments: updatedAttachments });

          migratedCount++;
        } catch (migErr) {
          console.error(`   ❌ Error migrando ${item.filePath}:`, migErr.message);
        }
      }
      console.log(`🎉 Migración completada: ${migratedCount} archivos migrados y actualizados en Firestore.`);
    }
  } else if (validFiles.some((v) => !v.filePath.includes('/'))) {
    const rootCount = validFiles.filter((v) => !v.filePath.includes('/')).length;
    console.log(`\n💡 NOTA: Hay ${rootCount} archivo(s) válido(s) en la raíz.`);
    console.log('   Si deseas moverlos a "users/{userId}/attachments/{fileName}" y actualizar Firestore automáticamente,');
    console.log('   ejecuta este script con:');
    console.log('   npm run clean:migrate');
  }

  console.log('\n🏁 Proceso finalizado con éxito.\n');
}

run().catch((err) => {
  console.error('\n💥 Error fatal durante la ejecución:', err);
  process.exit(1);
});

