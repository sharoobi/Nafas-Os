package com.nafas.sharoobi

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.google.android.gms.location.ActivityTransitionEvent
import com.google.android.gms.location.ActivityTransitionResult

class ActivityTransitionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (!ActivityTransitionResult.hasResult(intent)) {
            return
        }
        val result = ActivityTransitionResult.extractResult(intent) ?: return
        val latest: ActivityTransitionEvent = result.transitionEvents.lastOrNull() ?: return
        ActivityContextMonitor.handleTransition(
            context = context,
            activityType = latest.activityType,
            transitionType = latest.transitionType,
        )
    }
}
