package com.nafas.sharoobi

import android.Manifest
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.content.ContextCompat
import com.google.android.gms.location.ActivityRecognition
import com.google.android.gms.location.ActivityTransition
import com.google.android.gms.location.ActivityTransitionRequest
import com.google.android.gms.location.DetectedActivity

object ActivityContextMonitor {
    private const val prefsName = "nafas_activity_context"
    private const val keyLastActivity = "last_activity"
    private const val keyConfidence = "confidence"
    private const val keyUpdatedAt = "updated_at"
    private const val keyMonitoringActive = "monitoring_active"

    fun ensureMonitoring(context: Context): Map<String, Any> {
        if (!hasPermission(context, Manifest.permission.ACTIVITY_RECOGNITION)) {
            return status(context) + mapOf("permissionDenied" to true)
        }

        val transitions =
            listOf(
                transition(DetectedActivity.IN_VEHICLE, ActivityTransition.ACTIVITY_TRANSITION_ENTER),
                transition(DetectedActivity.IN_VEHICLE, ActivityTransition.ACTIVITY_TRANSITION_EXIT),
                transition(DetectedActivity.WALKING, ActivityTransition.ACTIVITY_TRANSITION_ENTER),
                transition(DetectedActivity.WALKING, ActivityTransition.ACTIVITY_TRANSITION_EXIT),
                transition(DetectedActivity.STILL, ActivityTransition.ACTIVITY_TRANSITION_ENTER),
                transition(DetectedActivity.STILL, ActivityTransition.ACTIVITY_TRANSITION_EXIT),
                transition(DetectedActivity.ON_BICYCLE, ActivityTransition.ACTIVITY_TRANSITION_ENTER),
                transition(DetectedActivity.ON_BICYCLE, ActivityTransition.ACTIVITY_TRANSITION_EXIT),
            )

        val request = ActivityTransitionRequest(transitions)
        return try {
            ActivityRecognition
                .getClient(context)
                .requestActivityTransitionUpdates(request, pendingIntent(context))
            markMonitoringActive(context, true)
            status(context)
        } catch (_: Exception) {
            markMonitoringActive(context, false)
            status(context) + mapOf("requestFailed" to true)
        }
    }

    fun rescheduleFromBoot(context: Context) {
        ensureMonitoring(context)
    }

    fun handleTransition(context: Context, activityType: Int, transitionType: Int) {
        val prefs = prefs(context)
        val now = System.currentTimeMillis()
        val activityLabel =
            when (activityType) {
                DetectedActivity.IN_VEHICLE -> "driving"
                DetectedActivity.WALKING -> "walking"
                DetectedActivity.STILL -> "still"
                DetectedActivity.ON_BICYCLE -> "driving"
                else -> "unknown"
            }

        val normalizedLabel =
            if (transitionType == ActivityTransition.ACTIVITY_TRANSITION_EXIT) {
                "unknown"
            } else {
                activityLabel
            }

        val confidence =
            if (transitionType == ActivityTransition.ACTIVITY_TRANSITION_ENTER) {
                0.88
            } else {
                0.45
            }

        prefs
            .edit()
            .putString(keyLastActivity, normalizedLabel)
            .putFloat(keyConfidence, confidence.toFloat())
            .putLong(keyUpdatedAt, now)
            .putBoolean(keyMonitoringActive, true)
            .apply()
    }

    fun status(context: Context): Map<String, Any> {
        val prefs = prefs(context)
        return mapOf(
            "lastActivity" to (prefs.getString(keyLastActivity, "unknown") ?: "unknown"),
            "activityConfidence" to prefs.getFloat(keyConfidence, 0.0f).toDouble(),
            "activityUpdatedAtMillis" to prefs.getLong(keyUpdatedAt, 0L),
            "activityMonitoringActive" to prefs.getBoolean(keyMonitoringActive, false),
        )
    }

    private fun transition(activityType: Int, transitionType: Int): ActivityTransition {
        return ActivityTransition.Builder()
            .setActivityType(activityType)
            .setActivityTransition(transitionType)
            .build()
    }

    private fun pendingIntent(context: Context): PendingIntent {
        val flags =
            PendingIntent.FLAG_UPDATE_CURRENT or
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    PendingIntent.FLAG_IMMUTABLE
                } else {
                    0
                }

        return PendingIntent.getBroadcast(
            context,
            4041,
            Intent(context, ActivityTransitionReceiver::class.java),
            flags,
        )
    }

    private fun markMonitoringActive(context: Context, active: Boolean) {
        prefs(context)
            .edit()
            .putBoolean(keyMonitoringActive, active)
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

    private fun hasPermission(context: Context, permission: String): Boolean {
        return ContextCompat.checkSelfPermission(context, permission) ==
            PackageManager.PERMISSION_GRANTED
    }
}
