package com.pmorales.saver.expense.manager

import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.OpenableColumns
import android.webkit.MimeTypeMap
import androidx.activity.enableEdgeToEdge
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.util.Locale
import java.util.UUID

class MainActivity : FlutterFragmentActivity() {
    companion object {
        private const val SHARE_CHANNEL = "com.pmorales.saver.expense.manager/share"
        private const val DOCUMENT_SCANNER_CHANNEL =
            "com.pmorales.saver.expense.manager/document_scanner"
        private const val GMS_SCAN_DOCUMENT_ACTION =
            "com.google.android.gms.mlkit.ACTION_SCAN_DOCUMENT"
        private const val GMS_PACKAGE = "com.google.android.gms"
        private const val SHARE_EXPENSE_ALIAS = ".ShareExpenseActivity"
        private const val SHARE_INCOME_ALIAS = ".ShareIncomeActivity"
        private val ALLOWED_EXTENSIONS = setOf("pdf", "png", "jpg", "jpeg")
    }

    private var shareChannel: MethodChannel? = null
    private var pendingSharedFile: Map<String, String>? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        val incomingShareIntent = takeShareIntentIfPresent(intent)
        super.onCreate(savedInstanceState)
        if (incomingShareIntent != null) {
            handleShareIntent(incomingShareIntent, notifyFlutter = false)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        shareChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SHARE_CHANNEL,
        ).apply {
            setMethodCallHandler { call, result ->
                if (call.method == "getInitialSharedFile") {
                    val data = pendingSharedFile
                    pendingSharedFile = null
                    result.success(data)
                } else {
                    result.notImplemented()
                }
            }
        }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            DOCUMENT_SCANNER_CHANNEL,
        ).setMethodCallHandler { call, result ->
            if (call.method == "isGmsScannerAvailable") {
                result.success(isGmsDocumentScannerAvailable())
            } else {
                result.notImplemented()
            }
        }
    }

    private fun isGmsDocumentScannerAvailable(): Boolean {
        val scanIntent = Intent(GMS_SCAN_DOCUMENT_ACTION).setPackage(GMS_PACKAGE)
        val resolved = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            packageManager.resolveActivity(scanIntent, PackageManager.ResolveInfoFlags.of(0))
        } else {
            @Suppress("DEPRECATION")
            packageManager.resolveActivity(scanIntent, 0)
        }
        return resolved != null
    }

    override fun onNewIntent(intent: Intent) {
        if (isShareIntent(intent)) {
            val cleanIntent = Intent(this, MainActivity::class.java)
            super.onNewIntent(cleanIntent)
            setIntent(cleanIntent)
            handleShareIntent(intent, notifyFlutter = true)
            return
        }
        super.onNewIntent(intent)
        setIntent(intent)
    }

    private fun isShareIntent(intent: Intent?): Boolean {
        if (intent == null || intent.action != Intent.ACTION_SEND) return false
        val componentName = intent.component?.className ?: return false
        return componentName.endsWith(SHARE_EXPENSE_ALIAS) ||
            componentName.endsWith(SHARE_INCOME_ALIAS)
    }

    private fun takeShareIntentIfPresent(intent: Intent?): Intent? {
        if (!isShareIntent(intent)) return null
        val copy = Intent(intent)
        setIntent(Intent(this, MainActivity::class.java))
        return copy
    }

    private fun handleShareIntent(intent: Intent?, notifyFlutter: Boolean) {
        if (intent == null || intent.action != Intent.ACTION_SEND) return

        val componentName = intent.component?.className ?: ""
        val movementType = when {
            componentName.endsWith(SHARE_EXPENSE_ALIAS) -> "EXPENSE"
            componentName.endsWith(SHARE_INCOME_ALIAS) -> "INCOME"
            else -> return
        }

        val uri = extractSharedUri(intent) ?: return
        val payload = copyUriToCache(uri, intent.type, movementType) ?: return

        intent.action = null

        val channel = shareChannel
        if (notifyFlutter && channel != null) {
            channel.invokeMethod("onSharedFile", payload)
        } else {
            pendingSharedFile = payload
        }
    }

    private fun extractSharedUri(intent: Intent): Uri? {
        val streamUri = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent.getParcelableExtra(Intent.EXTRA_STREAM, Uri::class.java)
        } else {
            @Suppress("DEPRECATION")
            intent.getParcelableExtra(Intent.EXTRA_STREAM)
        }
        if (streamUri != null) return streamUri

        val clipData = intent.clipData
        if (clipData != null && clipData.itemCount > 0) {
            return clipData.getItemAt(0).uri
        }
        return null
    }

    private fun copyUriToCache(
        uri: Uri,
        intentMimeType: String?,
        movementType: String,
    ): Map<String, String>? {
        return try {
            val mimeType = contentResolver.getType(uri) ?: intentMimeType
            val rawName = resolveDisplayName(uri)
            val ext = resolveExtension(rawName, mimeType) ?: return null

            val normalizedName = when {
                rawName.isNullOrBlank() -> "shared_${UUID.randomUUID()}.$ext"
                rawName.substringAfterLast('.', "").lowercase(Locale.US) == ext -> rawName
                else -> "$rawName.$ext"
            }

            val sharedDir = File(cacheDir, "shared_files").apply { mkdirs() }
            val destFile = File(sharedDir, "${UUID.randomUUID()}.$ext")

            contentResolver.openInputStream(uri)?.use { input ->
                FileOutputStream(destFile).use { output ->
                    input.copyTo(output)
                }
            } ?: return null

            mapOf(
                "path" to destFile.absolutePath,
                "name" to normalizedName,
                "movementType" to movementType,
            )
        } catch (_: Exception) {
            null
        }
    }

    private fun resolveDisplayName(uri: Uri): String? {
        if (uri.scheme == "content") {
            contentResolver.query(
                uri,
                arrayOf(OpenableColumns.DISPLAY_NAME),
                null,
                null,
                null,
            )?.use { cursor ->
                if (cursor.moveToFirst()) {
                    val idx = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                    if (idx >= 0) {
                        val name = cursor.getString(idx)
                        if (!name.isNullOrBlank()) return name
                    }
                }
            }
        }
        return uri.lastPathSegment?.substringAfterLast('/')
    }

    private fun resolveExtension(displayName: String?, mimeType: String?): String? {
        val fromName = displayName
            ?.takeIf { it.contains('.') }
            ?.substringAfterLast('.')
            ?.lowercase(Locale.US)
        if (fromName != null && fromName in ALLOWED_EXTENSIONS) {
            return fromName
        }

        val normalizedMime = mimeType?.lowercase(Locale.US)?.substringBefore(';')?.trim()
        val fromMime = when (normalizedMime) {
            "application/pdf" -> "pdf"
            "image/png" -> "png"
            "image/jpeg", "image/jpg" -> "jpg"
            else -> normalizedMime?.let {
                MimeTypeMap.getSingleton().getExtensionFromMimeType(it)?.lowercase(Locale.US)
            }
        }
        return fromMime?.takeIf { it in ALLOWED_EXTENSIONS }
    }
}
