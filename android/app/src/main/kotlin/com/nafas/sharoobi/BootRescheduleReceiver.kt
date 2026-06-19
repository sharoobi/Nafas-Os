package com.nafas.sharoobi

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class BootRescheduleReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (Intent.ACTION_BOOT_COMPLETED == intent.action) {
            BackgroundFollowUpScheduler.rescheduleFromBoot(context)
            ActivityContextMonitor.rescheduleFromBoot(context)
        }
    }
}
