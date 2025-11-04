package ru.yzhjdjq.sws

import android.content.Context
import android.content.SharedPreferences
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "ru.yzhjdjq.sws/widget"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            when (call.method) {
                "updateWidget" -> {
                    updateWidget()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun updateWidget() {
        // This will trigger widget update
        val intent = android.content.Intent(this, ScheduleWidget::class.java)
        intent.action = android.appwidget.AppWidgetManager.ACTION_APPWIDGET_UPDATE
        sendBroadcast(intent)
    }
}