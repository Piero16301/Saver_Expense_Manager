"""Cloud Function (2nd gen) en Python para Saver Expense Manager.

Esta función se activa automáticamente cuando un usuario es eliminado de Firebase Authentication
(a través de user.delete() en la app móvil o desde la consola de Firebase).

Acciones realizadas:
1. Elimina todos los archivos en Firebase Storage bajo el directorio 'users/{uid}/'.
2. Consulta todos los movimientos en Firestore ('movements') pertenecientes al usuario (user == uid),
   recopila cualquier archivo adjunto legacy que no esté bajo el prefijo 'users/{uid}/' y lo elimina de Storage.
3. Elimina en lotes (batches de Firestore) todos los documentos de movimientos del usuario.
4. Elimina el documento de perfil del usuario en Firestore ('users/{uid}') si existiera.
"""

import os
from typing import Set

from firebase_admin import firestore, initialize_app, storage
from firebase_functions import identity_fn, logger, options

# Inicializar Firebase Admin SDK (toma credenciales por defecto del entorno en Google Cloud)
initialize_app()

DEFAULT_STORAGE_BUCKET = os.environ.get(
    "STORAGE_BUCKET_NAME",
    "saver-expense-manager.firebasestorage.app",
)


def _get_storage_bucket():
    """Obtiene el bucket predeterminado de Storage con fallback seguro."""
    try:
        bucket = storage.bucket()
        if bucket.name:
            return bucket
    except Exception as e:
        logger.warn(f"No se pudo resolver bucket por defecto, usando fallback: {e}")
    return storage.bucket(DEFAULT_STORAGE_BUCKET)


@identity_fn.on_user_deleted(
    timeout_sec=300,
    memory=options.MemoryOption.MB_512,
)
def cleanup_deleted_user_data(event: identity_fn.AuthUserEvent) -> None:
    """Trigger ejecutado al eliminarse un usuario en Firebase Authentication."""
    user = event.data
    uid = user.uid
    email = user.email or "sin-email"

    logger.info(
        f"🧹 Iniciando borrado en cascada para el usuario eliminado: {uid} ({email})"
    )

    bucket = _get_storage_bucket()
    db = firestore.client()

    deleted_storage_files = 0
    deleted_movements_count = 0

    # -------------------------------------------------------------------------
    # 1. Obtener los movimientos del usuario en Firestore y recolectar adjuntos
    # -------------------------------------------------------------------------
    legacy_attachments: Set[str] = set()
    movement_doc_refs = []

    try:
        movements_query = (
            db.collection("movements").where("user", "==", uid).stream()
        )
        for doc in movements_query:
            movement_doc_refs.append(doc.reference)
            data = doc.to_dict() or {}
            attachments = data.get("attachments") or []
            if isinstance(attachments, list):
                for att in attachments:
                    if isinstance(att, str) and att:
                        # Si el adjunto no está dentro de users/{uid}/, guardarlo para borrarlo
                        if not att.startswith(f"users/{uid}/"):
                            legacy_attachments.add(att)
    except Exception as e:
        logger.error(f"❌ Error al consultar movimientos del usuario {uid}: {e}")

    # -------------------------------------------------------------------------
    # 2. Eliminar archivos en Firebase Storage bajo el directorio users/{uid}/
    # -------------------------------------------------------------------------
    user_storage_prefix = f"users/{uid}/"
    try:
        blobs = list(bucket.list_blobs(prefix=user_storage_prefix))
        logger.info(
            f"Encontrados {len(blobs)} archivo(s) en Storage con prefijo '{user_storage_prefix}'"
        )
        for blob in blobs:
            try:
                blob.delete()
                deleted_storage_files += 1
            except Exception as e:
                logger.warn(f"No se pudo eliminar el archivo {blob.name}: {e}")
    except Exception as e:
        logger.error(
            f"❌ Error al listar/eliminar archivos de Storage con prefijo {user_storage_prefix}: {e}"
        )

    # -------------------------------------------------------------------------
    # 3. Eliminar adjuntos históricos fuera del prefijo users/{uid}/
    # -------------------------------------------------------------------------
    if legacy_attachments:
        logger.info(
            f"Eliminando {len(legacy_attachments)} adjuntos legacy fuera del prefijo..."
        )
        for att_path in legacy_attachments:
            try:
                blob = bucket.blob(att_path)
                if blob.exists():
                    blob.delete()
                    deleted_storage_files += 1
            except Exception as e:
                logger.warn(f"No se pudo eliminar adjunto legacy {att_path}: {e}")

    # -------------------------------------------------------------------------
    # 4. Eliminar movimientos en Firestore en lotes (batches de máx 400 docs)
    # -------------------------------------------------------------------------
    try:
        total_movements = len(movement_doc_refs)
        logger.info(
            f"Eliminando {total_movements} documento(s) de movimientos en Firestore..."
        )

        batch = db.batch()
        batch_counter = 0

        for doc_ref in movement_doc_refs:
            batch.delete(doc_ref)
            batch_counter += 1
            deleted_movements_count += 1

            if batch_counter >= 400:
                batch.commit()
                batch = db.batch()
                batch_counter = 0

        if batch_counter > 0:
            batch.commit()
    except Exception as e:
        logger.error(f"❌ Error al eliminar movimientos en Firestore para {uid}: {e}")

    # -------------------------------------------------------------------------
    # 5. Eliminar documento de perfil del usuario en users/{uid} si existe
    # -------------------------------------------------------------------------
    try:
        user_doc_ref = db.collection("users").document(uid)
        if hasattr(db, "recursive_delete"):
            db.recursive_delete(user_doc_ref)
            logger.info(f"Colección/documento users/{uid} eliminado recursivamente.")
        else:
            if user_doc_ref.get().exists:
                user_doc_ref.delete()
                logger.info(f"Documento users/{uid} eliminado.")
    except Exception as e:
        logger.warn(f"No se pudo eliminar el documento users/{uid}: {e}")

    logger.info(
        f"✅ Cascada completada para el usuario {uid}: "
        f"{deleted_movements_count} movimiento(s) en Firestore y "
        f"{deleted_storage_files} archivo(s) en Storage eliminados."
    )

