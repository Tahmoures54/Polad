package ir.polad.polad

import android.Manifest
import android.content.pm.PackageManager
import android.database.Cursor
import android.net.Uri
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channel = "ir.polad.polad/sms"
    private var permissionResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "requestPermission" -> {
                        if (hasSmsPermission()) {
                            result.success(true)
                        } else {
                            permissionResult = result
                            ActivityCompat.requestPermissions(
                                this,
                                arrayOf(Manifest.permission.READ_SMS),
                                42,
                            )
                        }
                    }
                    "readInbox" -> {
                        if (!hasSmsPermission()) {
                            result.success(emptyList<Map<String, Any>>())
                            return@setMethodCallHandler
                        }
                        val since = call.argument<Long>("sinceMs") ?: 0L
                        result.success(readInbox(since))
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun hasSmsPermission(): Boolean {
        return ContextCompat.checkSelfPermission(this, Manifest.permission.READ_SMS) ==
            PackageManager.PERMISSION_GRANTED
    }

    private fun readInbox(sinceMs: Long): List<Map<String, Any?>> {
        val items = mutableListOf<Map<String, Any?>>()
        val uri = Uri.parse("content://sms/inbox")
        val cursor: Cursor? = contentResolver.query(
            uri,
            arrayOf("address", "body", "date"),
            "date >= ?",
            arrayOf(sinceMs.toString()),
            "date DESC",
        )
        cursor?.use {
            val address = it.getColumnIndex("address")
            val body = it.getColumnIndex("body")
            val date = it.getColumnIndex("date")
            var count = 0
            while (it.moveToNext() && count < 80) {
                items.add(
                    mapOf(
                        "sender" to it.getString(address),
                        "body" to it.getString(body),
                        "date" to it.getLong(date),
                    ),
                )
                count++
            }
        }
        return items
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == 42) {
            permissionResult?.success(grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED)
            permissionResult = null
        }
    }
}
