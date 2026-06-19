package com.nafas.sharoobi

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

object BackgroundFollowUpScheduler {
    private const val prefsName = "nafas_os_background_follow_up"
    private const val keyTitle = "title"
    private const val keyBody = "body"
    private const val keyTriggerAt = "trigger_at_millis"
    private const val keyRequestCode = 4082
    private const val channelId = "nafas_risk_channel"

    fun schedule(
        context: Context,
        title: String,
        body: String,
        triggerAtMillis: Long,
    ): Map<String, Any> {
        persist(context, title, body, triggerAtMillis)
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val pendingIntent = buildPendingIntent(context, title, body)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                triggerAtMillis,
                pendingIntent,
            )
        } else {
            alarmManager.setExact(
                AlarmManager.RTC_WAKEUP,
                triggerAtMillis,
                pendingIntent,
            )
        }
        return status(context)
    }

    fun cancel(context: Context): Map<String, Any> {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val pendingIntent = buildPendingIntent(
            context = context,
            title = "",
            body = "",
            flags = PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        alarmManager.cancel(pendingIntent)
        clear(context)
        return status(context)
    }

    fun status(context: Context): Map<String, Any> {
        val prefs = prefs(context)
        val triggerAtMillis = prefs.getLong(keyTriggerAt, 0L)
        val now = System.currentTimeMillis()
        val pending = triggerAtMillis > now
        return mapOf(
            "pending" to pending,
            "title" to (prefs.getString(keyTitle, "") ?: ""),
            "body" to (prefs.getString(keyBody, "") ?: ""),
            "triggerAtMillis" to triggerAtMillis,
            "remainingSeconds" to if (pending) ((triggerAtMillis - now) / 1000L).toInt() else 0,
        )
    }

    fun rescheduleFromBoot(context: Context) {
        val prefs = prefs(context)
        val title = prefs.getString(keyTitle, null) ?: return
        val body = prefs.getString(keyBody, null) ?: return
        val triggerAtMillis = prefs.getLong(keyTriggerAt, 0L)
        if (triggerAtMillis <= 0L) {
            clear(context)
            return
        }
        if (triggerAtMillis <= System.currentTimeMillis()) {
            showNotification(context, title, body)
            clear(context)
            return
        }
        schedule(context, title, body, triggerAtMillis)
    }

    fun showNotification(context: Context, title: String, body: String) {
        ensureChannel(context)
        val launchIntent =
            Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
        val pendingLaunchIntent =
            PendingIntent.getActivity(
                context,
                9181,
                launchIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )

        val notification =
            NotificationCompat.Builder(context, channelId)
                .setSmallIcon(android.R.drawable.ic_dialog_info)
                .setContentTitle(title)
                .setContentText(body)
                .setStyle(NotificationCompat.BigTextStyle().bigText(body))
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setAutoCancel(true)
                .setContentIntent(pendingLaunchIntent)
                .build()

        NotificationManagerCompat.from(context).notify(9201, notification)
    }

    private fun persist(context: Context, title: String, body: String, triggerAtMillis: Long) {
        prefs(context)
            .edit()
            .putString(keyTitle, title)
            .putString(keyBody, body)
            .putLong(keyTriggerAt, triggerAtMillis)
            .apply()
    }

    private fun clear(context: Context) {
        prefs(context)
            .edit()
            .remove(keyTitle)
            .remove(keyBody)
            .remove(keyTriggerAt)
            .apply()
    }

    private fun prefs(context: Context) =
        storageContext(context).getSharedPreferences(prefsName, Context.MODE_PRIVATE)

    private fun storageContext(context: Context): Context {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N) {
            return context
        }
        return context.createDeviceProtectedStorageContext()
    }

    private fun buildPendingIntent(
        context: Context,
        title: String,
        body: String,
        flags: Int = PendingIntent.FLAG_CANCEL_CURRENT or PendingIntent.FLAG_IMMUTABLE,
    ): PendingIntent {
        val intent =
            Intent(context, FollowUpAlarmReceiver::class.java).apply {
                action = "com.nafas.sharoobi.SHOW_FOLLOW_UP"
                putExtra(keyTitle, title)
                putExtra(keyBody, body)
            }
        return PendingIntent.getBroadcast(context, keyRequestCode, intent, flags)
    }

    private fun ensureChannel(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return
        }
        val manager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val existing = manager.getNotificationChannel(channelId)
        if (existing != null) {
            return
        }
        manager.createNotificationChannel(
            NotificationChannel(
                channelId,
                "تنبيهات نفس",
                NotificationManager.IMPORTANCE_HIGH,
            ).apply {
                description = "تنبيهات التدخل الذكي والمتابعة من تطبيق نفس"
            },
        )
    }
}
