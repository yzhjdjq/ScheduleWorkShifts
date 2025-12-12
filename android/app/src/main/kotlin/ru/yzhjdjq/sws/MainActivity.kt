package ru.yzhjdjq.sws

import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.appwidget.AppWidgetManager
import android.util.Log
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
        val context = applicationContext
        val appWidgetId = ScheduleWidget.getSavedWidgetId(context)

        if (appWidgetId == -1) {
            Log.w("ScheduleWidget", "No saved widget ID found. Cannot update.")
            return
        }

        val intent = Intent(context, ScheduleWidget::class.java).apply {
            action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, intArrayOf(appWidgetId))
        }
        context.sendBroadcast(intent)
        if (BuildConfig.DEBUG) Log.d("ScheduleWidget", "Triggered update for widget ID: $appWidgetId")
    }
}