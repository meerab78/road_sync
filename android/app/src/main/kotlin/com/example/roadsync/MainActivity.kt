package com.example.roadsync

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import android.telephony.SmsManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "roadsync/sms"
    private val requestCode = 501

    private var pendingResult: MethodChannel.Result? = null
    private var pendingNumber: String = ""
    private var pendingMessage: String = ""

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                if (call.method == "sendSms") {
                    val number = call.argument<String>("number") ?: ""
                    val message = call.argument<String>("message") ?: ""

                    val granted = ContextCompat.checkSelfPermission(
                        this, Manifest.permission.SEND_SMS
                    ) == PackageManager.PERMISSION_GRANTED

                    if (granted) {
                        sendNow(number, message, result)
                    } else {
                        pendingResult = result
                        pendingNumber = number
                        pendingMessage = message
                        ActivityCompat.requestPermissions(
                            this, arrayOf(Manifest.permission.SEND_SMS), requestCode
                        )
                    }
                } else {
                    result.notImplemented()
                }
            }
    }

    override fun onRequestPermissionsResult(
        code: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(code, permissions, grantResults)

        if (code == requestCode) {
            val result = pendingResult
            pendingResult = null
            if (result == null) {
                return
            }

            if (grantResults.isNotEmpty() &&
                grantResults[0] == PackageManager.PERMISSION_GRANTED
            ) {
                sendNow(pendingNumber, pendingMessage, result)
            } else {
                result.error("DENIED", "SMS permission was denied", null)
            }
        }
    }

    private fun sendNow(number: String, message: String, result: MethodChannel.Result) {
        try {
            val smsManager: SmsManager = if (Build.VERSION.SDK_INT >= 31) {
                getSystemService(SmsManager::class.java)
            } else {
                @Suppress("DEPRECATION")
                SmsManager.getDefault()
            }

            val parts = smsManager.divideMessage(message)
            smsManager.sendMultipartTextMessage(number, null, parts, null, null)
            result.success(true)
        } catch (e: Exception) {
            result.error("FAILED", e.message ?: "SMS failed", null)
        }
    }
}