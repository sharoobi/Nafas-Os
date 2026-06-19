package com.nafas.sharoobi

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class FollowUpAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val title = intent.getStringExtra("title") ?: "متابعة من نفس"
        val body = intent.getStringExtra("body") ?: "خذ 45 ثانية الآن قبل القرار التالي."
        BackgroundFollowUpScheduler.showNotification(context, title, body)
        BackgroundFollowUpScheduler.cancel(context)
    }
}
