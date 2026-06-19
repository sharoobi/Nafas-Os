package com.nafas.sharoobi

import android.annotation.SuppressLint
import android.app.AppOpsManager
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothProfile
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.content.ContentValues
import android.location.LocationManager
import android.media.AudioDeviceInfo
import android.media.AudioManager
import android.media.MediaRecorder
import android.os.BatteryManager
import android.os.Build
import android.os.Environment
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import android.os.Process
import android.provider.Settings
import android.net.Uri
import android.provider.MediaStore
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import kotlin.math.abs

class MainActivity : FlutterActivity() {
    private var guardedAudioStartedAtMillis: Long? = null
    private var guardedAudioEndsAtMillis: Long? = null
    private var guardedAudioAverageAmplitude: Int = 0
    private var guardedAudioPeakAmplitude: Int = 0
    private var guardedAudioLighterLikeSpikes: Int = 0
    private var guardedAudioCoughLikeBursts: Int = 0
    private var guardedAudioSteadyBreathCycles: Int = 0
    private var guardedAudioRestlessnessBursts: Int = 0
    private var guardedAudioRiskScore: Int = 0
    private var guardedAudioSamples: Int = 0
    private var guardedAudioAmplitudeSum: Long = 0
    private var guardedAudioLastAmplitude: Int = 0
    private var guardedAudioLastSessionStartedAtMillis: Long? = null
    private var guardedAudioLastSessionEndedAtMillis: Long? = null
    private var audioRecorder: MediaRecorder? = null
    private val guardedAudioHandler = Handler(Looper.getMainLooper())
    private val guardedAudioSampler =
        object : Runnable {
            override fun run() {
                sampleGuardedAudio()
                if ((guardedAudioEndsAtMillis ?: 0L) > System.currentTimeMillis()) {
                    guardedAudioHandler.postDelayed(this, 700L)
                } else {
                    stopGuardedAudioMode()
                }
            }
        }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.nafas.sharoobi/native_context",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getPlatformCapabilities" -> result.success(getPlatformCapabilities())
                "getBluetoothSnapshot" -> result.success(getBluetoothSnapshot())
                "getDeviceState" -> result.success(getDeviceState())
                "getContextEnvelope" -> result.success(getContextEnvelope())
                "getUsageDigest" -> result.success(getUsageDigest())
                "schedulePersistentFollowUp" -> {
                    val title = call.argument<String>("title") ?: "متابعة من نفس"
                    val body = call.argument<String>("body") ?: "خذ 45 ثانية الآن قبل القرار التالي."
                    val triggerAtMillis =
                        call.argument<Long>("triggerAtMillis")
                            ?: (System.currentTimeMillis() + 5 * 60 * 1000L)
                    result.success(
                        BackgroundFollowUpScheduler.schedule(
                            context = this,
                            title = title,
                            body = body,
                            triggerAtMillis = triggerAtMillis,
                        ),
                    )
                }
                "cancelPersistentFollowUp" ->
                    result.success(BackgroundFollowUpScheduler.cancel(this))
                "getPersistentFollowUpStatus" ->
                    result.success(BackgroundFollowUpScheduler.status(this))
                "getBootResilienceStatus" ->
                    result.success(getBootResilienceStatus())
                "openBatteryOptimizationSettings" ->
                    result.success(openBatteryOptimizationSettings())
                "openExactAlarmSettings" ->
                    result.success(openExactAlarmSettings())
                "openUsageAccessSettings" ->
                    result.success(openUsageAccessSettings())
                "exportTextToDownloads" -> {
                    val fileName = call.argument<String>("fileName") ?: "nafas_export.txt"
                    val content = call.argument<String>("content") ?: ""
                    val mimeType = call.argument<String>("mimeType") ?: "text/plain"
                    result.success(exportTextToDownloads(fileName, content, mimeType))
                }
                "startGuardedAudioMode" -> {
                    val durationSeconds = call.argument<Int>("durationSeconds") ?: 600
                    result.success(startGuardedAudioMode(durationSeconds))
                }
                "stopGuardedAudioMode" -> result.success(stopGuardedAudioMode())
                "getGuardedAudioStatus" -> result.success(getGuardedAudioStatus())
                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        stopGuardedAudioMode()
        super.onDestroy()
    }

    private fun getPlatformCapabilities(): Map<String, Any> {
        val activityStatus = ActivityContextMonitor.ensureMonitoring(this)
        val bootResilience = getBootResilienceStatus()
        return mapOf(
            "sdkInt" to Build.VERSION.SDK_INT,
            "supportsLocationPatterning" to true,
            "supportsActivityInference" to true,
            "supportsBluetoothContext" to true,
            "supportsGuardedAudio" to true,
            "supportsMirrorMode" to true,
            "supportsBackgroundAwareNotifications" to true,
            "supportsUsageIntelligence" to true,
            "locationServicesEnabled" to isLocationServicesEnabled(),
            "locationPermissionGranted" to hasAnyPermission(
                android.Manifest.permission.ACCESS_FINE_LOCATION,
                android.Manifest.permission.ACCESS_COARSE_LOCATION,
            ),
            "microphonePermissionGranted" to hasPermission(android.Manifest.permission.RECORD_AUDIO),
            "cameraPermissionGranted" to hasPermission(android.Manifest.permission.CAMERA),
            "bluetoothPermissionGranted" to hasAnyPermission(
                android.Manifest.permission.BLUETOOTH_CONNECT,
                android.Manifest.permission.BLUETOOTH_SCAN,
                android.Manifest.permission.BLUETOOTH,
            ),
            "activityMonitoringActive" to (activityStatus["activityMonitoringActive"] ?: false),
            "ignoringBatteryOptimizations" to (bootResilience["ignoringBatteryOptimizations"] ?: false),
            "exactAlarmAllowed" to (bootResilience["exactAlarmAllowed"] ?: true),
            "usageAccessGranted" to hasUsageAccess(),
        )
    }

    private fun getBootResilienceStatus(): Map<String, Any> {
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as android.app.AlarmManager
        val manufacturer = Build.MANUFACTURER
        val model = Build.MODEL
        val isSamsung = manufacturer.equals("samsung", ignoreCase = true)
        val ignoringBatteryOptimizations =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                powerManager.isIgnoringBatteryOptimizations(packageName)
            } else {
                true
            }
        val exactAlarmAllowed =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                alarmManager.canScheduleExactAlarms()
            } else {
                true
            }
        return mapOf(
            "manufacturer" to manufacturer,
            "model" to model,
            "isSamsung" to isSamsung,
            "ignoringBatteryOptimizations" to ignoringBatteryOptimizations,
            "exactAlarmAllowed" to exactAlarmAllowed,
            "samsungBatteryWarning" to
                (
                    isSamsung &&
                        (!ignoringBatteryOptimizations || !exactAlarmAllowed)
                ),
            "followUpStatus" to BackgroundFollowUpScheduler.status(this),
        )
    }

    private fun openBatteryOptimizationSettings(): Boolean {
        return try {
            val intent =
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                        data = Uri.parse("package:$packageName")
                    }
                } else {
                    Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
                }
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
            true
        } catch (_: Exception) {
            false
        }
    }

    private fun openExactAlarmSettings(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            return true
        }
        return try {
            val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                data = Uri.parse("package:$packageName")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(intent)
            true
        } catch (_: Exception) {
            false
        }
    }

    private fun openUsageAccessSettings(): Boolean {
        return try {
            val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(intent)
            true
        } catch (_: Exception) {
            false
        }
    }

    private fun exportTextToDownloads(
        fileName: String,
        content: String,
        mimeType: String,
    ): String? {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val values =
                    ContentValues().apply {
                        put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
                        put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
                        put(MediaStore.MediaColumns.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS)
                        put(MediaStore.MediaColumns.IS_PENDING, 1)
                    }
                val uri =
                    contentResolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
                        ?: return null
                contentResolver.openOutputStream(uri)?.use { output ->
                    output.write(content.toByteArray(Charsets.UTF_8))
                }
                values.clear()
                values.put(MediaStore.MediaColumns.IS_PENDING, 0)
                contentResolver.update(uri, values, null, null)
                uri.toString()
            } else {
                val downloadDir =
                    getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS) ?: return null
                val file = File(downloadDir, fileName)
                file.writeText(content, Charsets.UTF_8)
                file.absolutePath
            }
        } catch (_: Exception) {
            null
        }
    }

    @SuppressLint("MissingPermission")
    private fun getBluetoothSnapshot(): Map<String, Any> {
        val bluetoothManager = getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        val adapter: BluetoothAdapter? = bluetoothManager.adapter
        val bondedCount =
            try {
                adapter?.bondedDevices?.size ?: 0
            } catch (_: Exception) {
                0
            }

        return mapOf(
            "enabled" to (adapter?.isEnabled ?: false),
            "bondedCount" to bondedCount,
        )
    }

    private fun getDeviceState(): Map<String, Any> {
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        val batteryPercent = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        val charging = isCharging()

        return mapOf(
            "interactive" to powerManager.isInteractive,
            "powerSaveMode" to powerManager.isPowerSaveMode,
            "batteryPercent" to batteryPercent,
            "charging" to charging,
        )
    }

    @SuppressLint("MissingPermission")
    private fun getContextEnvelope(): Map<String, Any> {
        val activityStatus = ActivityContextMonitor.ensureMonitoring(this)
        val usageDigest = getUsageDigest()
        val bluetoothManager = getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        val adapter: BluetoothAdapter? = bluetoothManager.adapter
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        val audioRouteInfo = getAudioRouteInfo(audioManager)

        val bondedCount =
            try {
                adapter?.bondedDevices?.size ?: 0
            } catch (_: Exception) {
                0
            }

        val a2dpConnected =
            try {
                adapter?.getProfileConnectionState(BluetoothProfile.A2DP) ==
                    BluetoothProfile.STATE_CONNECTED
            } catch (_: Exception) {
                false
            }

        val headsetConnected =
            try {
                adapter?.getProfileConnectionState(BluetoothProfile.HEADSET) ==
                    BluetoothProfile.STATE_CONNECTED
            } catch (_: Exception) {
                false
            }

        return mapOf(
            "bluetoothEnabled" to (adapter?.isEnabled ?: false),
            "bondedCount" to bondedCount,
            "bluetoothAudioConnected" to (a2dpConnected || headsetConnected),
            "a2dpConnected" to a2dpConnected,
            "headsetConnected" to headsetConnected,
            "musicActive" to audioManager.isMusicActive,
            "audioMode" to audioManager.mode,
            "audioRouteKind" to (audioRouteInfo["audioRouteKind"] ?: "unknown"),
            "carAudioRouteActive" to (audioRouteInfo["carAudioRouteActive"] ?: false),
            "headsetRouteActive" to (audioRouteInfo["headsetRouteActive"] ?: false),
            "wiredAudioRouteActive" to (audioRouteInfo["wiredAudioRouteActive"] ?: false),
            "vehicleContextScore" to (audioRouteInfo["vehicleContextScore"] ?: 0.0),
            "interactive" to powerManager.isInteractive,
            "powerSaveMode" to powerManager.isPowerSaveMode,
            "batteryPercent" to batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY),
            "charging" to isCharging(),
            "locationServicesEnabled" to isLocationServicesEnabled(),
            "lastActivity" to (activityStatus["lastActivity"] ?: "unknown"),
            "activityConfidence" to (activityStatus["activityConfidence"] ?: 0.0),
            "activityUpdatedAtMillis" to (activityStatus["activityUpdatedAtMillis"] ?: 0L),
            "activityMonitoringActive" to (activityStatus["activityMonitoringActive"] ?: false),
            "usageAccessGranted" to (usageDigest["usageAccessGranted"] ?: false),
            "dominantAppPackage" to (usageDigest["dominantAppPackage"] ?: ""),
            "dominantAppMinutes" to (usageDigest["dominantAppMinutes"] ?: 0),
            "socialMediaMinutes" to (usageDigest["socialMediaMinutes"] ?: 0),
            "shortVideoMinutes" to (usageDigest["shortVideoMinutes"] ?: 0),
            "messagingMinutes" to (usageDigest["messagingMinutes"] ?: 0),
            "appSwitchesLast30m" to (usageDigest["appSwitchesLast30m"] ?: 0),
            "digitalDriftScore" to (usageDigest["digitalDriftScore"] ?: 0.0),
        )
    }

    private fun getAudioRouteInfo(audioManager: AudioManager): Map<String, Any> {
        return try {
            val outputs = audioManager.getDevices(AudioManager.GET_DEVICES_OUTPUTS)
            val hasCarRoute =
                outputs.any { device ->
                    val productName = device.productName?.toString()?.lowercase() ?: ""
                    device.type == AudioDeviceInfo.TYPE_BLUETOOTH_SCO ||
                        productName.contains("car") ||
                        productName.contains("auto") ||
                        productName.contains("vehicle")
                }
            val hasHeadsetRoute =
                outputs.any { device ->
                    device.type == AudioDeviceInfo.TYPE_BLUETOOTH_A2DP ||
                        device.type == AudioDeviceInfo.TYPE_BLUETOOTH_SCO ||
                        device.type == AudioDeviceInfo.TYPE_BLE_HEADSET
                }
            val hasWiredRoute =
                outputs.any { device ->
                    device.type == AudioDeviceInfo.TYPE_WIRED_HEADPHONES ||
                        device.type == AudioDeviceInfo.TYPE_WIRED_HEADSET ||
                        device.type == AudioDeviceInfo.TYPE_USB_HEADSET
                }

            val routeKind =
                when {
                    hasCarRoute -> "car_audio"
                    hasHeadsetRoute -> "bluetooth_headset"
                    hasWiredRoute -> "wired_audio"
                    else -> "speaker_or_none"
                }

            val vehicleContextScore =
                when {
                    hasCarRoute -> 0.92
                    hasHeadsetRoute && audioManager.isMusicActive -> 0.58
                    hasHeadsetRoute -> 0.35
                    else -> 0.0
                }

            mapOf(
                "audioRouteKind" to routeKind,
                "carAudioRouteActive" to hasCarRoute,
                "headsetRouteActive" to hasHeadsetRoute,
                "wiredAudioRouteActive" to hasWiredRoute,
                "vehicleContextScore" to vehicleContextScore,
            )
        } catch (_: Exception) {
            mapOf(
                "audioRouteKind" to "unknown",
                "carAudioRouteActive" to false,
                "headsetRouteActive" to false,
                "wiredAudioRouteActive" to false,
                "vehicleContextScore" to 0.0,
            )
        }
    }

    private fun getUsageDigest(): Map<String, Any> {
        if (!hasUsageAccess()) {
            return mapOf(
                "usageAccessGranted" to false,
                "dominantAppPackage" to "",
                "dominantAppMinutes" to 0,
                "socialMediaMinutes" to 0,
                "shortVideoMinutes" to 0,
                "messagingMinutes" to 0,
                "appSwitchesLast30m" to 0,
                "digitalDriftScore" to 0.0,
            )
        }

        return try {
            val usageStatsManager =
                getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
            val now = System.currentTimeMillis()
            val start60m = now - 60L * 60L * 1000L
            val start30m = now - 30L * 60L * 1000L
            val stats = usageStatsManager.queryAndAggregateUsageStats(start60m, now)

            val instagramMinutes = minutesFor(stats, setOf("com.instagram.android"))
            val tiktokMinutes = minutesFor(stats, setOf("com.zhiliaoapp.musically"))
            val youtubeMinutes = minutesFor(stats, setOf("com.google.android.youtube"))
            val whatsappMinutes =
                minutesFor(stats, setOf("com.whatsapp", "com.whatsapp.w4b"))
            val telegramMinutes = minutesFor(stats, setOf("org.telegram.messenger"))

            val socialMediaMinutes = instagramMinutes + tiktokMinutes + youtubeMinutes
            val shortVideoMinutes = instagramMinutes + tiktokMinutes + youtubeMinutes
            val messagingMinutes = whatsappMinutes + telegramMinutes

            val dominantEntry =
                stats.entries.maxByOrNull { (_, value) -> value.totalTimeInForeground }
            val dominantAppPackage = dominantEntry?.key ?: ""
            val dominantAppMinutes =
                ((dominantEntry?.value?.totalTimeInForeground ?: 0L) / 60000L).toInt()

            val usageEvents = usageStatsManager.queryEvents(start30m, now)
            val event = android.app.usage.UsageEvents.Event()
            var launches = 0
            var lastPackage: String? = null
            while (usageEvents.hasNextEvent()) {
                usageEvents.getNextEvent(event)
                if (event.eventType == android.app.usage.UsageEvents.Event.MOVE_TO_FOREGROUND) {
                    val packageName = event.packageName
                    if (packageName != lastPackage) {
                        launches += 1
                        lastPackage = packageName
                    }
                }
            }
            val appSwitchesLast30m = (launches - 1).coerceAtLeast(0)
            val digitalDriftScore =
                (
                    (shortVideoMinutes.coerceAtMost(25) / 25.0) * 0.45 +
                        (messagingMinutes.coerceAtMost(20) / 20.0) * 0.2 +
                        (appSwitchesLast30m.coerceAtMost(18) / 18.0) * 0.35
                ).coerceIn(0.0, 1.0)

            mapOf(
                "usageAccessGranted" to true,
                "dominantAppPackage" to dominantAppPackage,
                "dominantAppMinutes" to dominantAppMinutes,
                "socialMediaMinutes" to socialMediaMinutes,
                "shortVideoMinutes" to shortVideoMinutes,
                "messagingMinutes" to messagingMinutes,
                "appSwitchesLast30m" to appSwitchesLast30m,
                "digitalDriftScore" to digitalDriftScore,
            )
        } catch (_: Exception) {
            mapOf(
                "usageAccessGranted" to false,
                "dominantAppPackage" to "",
                "dominantAppMinutes" to 0,
                "socialMediaMinutes" to 0,
                "shortVideoMinutes" to 0,
                "messagingMinutes" to 0,
                "appSwitchesLast30m" to 0,
                "digitalDriftScore" to 0.0,
            )
        }
    }

    private fun minutesFor(
        stats: Map<String, UsageStats>,
        packages: Set<String>,
    ): Int {
        val millis =
            packages.sumOf { packageName ->
                stats[packageName]?.totalTimeInForeground ?: 0L
            }
        return (millis / 60000L).toInt()
    }

    private fun startGuardedAudioMode(durationSeconds: Int): Map<String, Any> {
        if (!hasPermission(android.Manifest.permission.RECORD_AUDIO)) {
            return mapOf(
                "active" to false,
                "permissionDenied" to true,
                "remainingSeconds" to 0,
            )
        }

        stopGuardedAudioMode()
        resetGuardedAudioStats()

        val now = System.currentTimeMillis()
        guardedAudioStartedAtMillis = now
        guardedAudioEndsAtMillis = now + (durationSeconds.coerceAtLeast(30) * 1000L)
        guardedAudioLastSessionStartedAtMillis = now
        guardedAudioLastSessionEndedAtMillis = null

        try {
            audioRecorder =
                MediaRecorder().apply {
                    setAudioSource(MediaRecorder.AudioSource.MIC)
                    setOutputFormat(MediaRecorder.OutputFormat.THREE_GPP)
                    setAudioEncoder(MediaRecorder.AudioEncoder.AMR_NB)
                    setOutputFile("${cacheDir.absolutePath}/guarded_audio_session.3gp")
                    prepare()
                    start()
                }
            guardedAudioHandler.postDelayed(guardedAudioSampler, 700L)
        } catch (_: Exception) {
            releaseRecorder()
            guardedAudioStartedAtMillis = null
            guardedAudioEndsAtMillis = null
            return mapOf(
                "active" to false,
                "startFailed" to true,
                "remainingSeconds" to 0,
            )
        }

        return getGuardedAudioStatus()
    }

    private fun stopGuardedAudioMode(): Map<String, Any> {
        guardedAudioHandler.removeCallbacks(guardedAudioSampler)
        val startedAt = guardedAudioStartedAtMillis ?: guardedAudioLastSessionStartedAtMillis
        val endedAt = System.currentTimeMillis()
        guardedAudioLastSessionStartedAtMillis = startedAt
        guardedAudioLastSessionEndedAtMillis = endedAt
        releaseRecorder()
        guardedAudioStartedAtMillis = null
        guardedAudioEndsAtMillis = null
        return getGuardedAudioStatus()
    }

    private fun getGuardedAudioStatus(): Map<String, Any> {
        val now = System.currentTimeMillis()
        val endsAt = guardedAudioEndsAtMillis
        val startedAt = guardedAudioStartedAtMillis

        if (endsAt == null || startedAt == null || now >= endsAt) {
            guardedAudioStartedAtMillis = null
            guardedAudioEndsAtMillis = null
            val lastStartedAt = guardedAudioLastSessionStartedAtMillis
            val lastEndedAt = guardedAudioLastSessionEndedAtMillis ?: now
            val durationSeconds =
                if (lastStartedAt == null) {
                    0
                } else {
                    ((lastEndedAt - lastStartedAt) / 1000L).toInt().coerceAtLeast(0)
                }
            return mapOf(
                "active" to false,
                "startedAtMillis" to (lastStartedAt ?: 0L),
                "endedAtMillis" to lastEndedAt,
                "sessionDurationSeconds" to durationSeconds,
                "remainingSeconds" to 0,
                "averageAmplitude" to guardedAudioAverageAmplitude,
                "peakAmplitude" to guardedAudioPeakAmplitude,
                "lighterLikeSpikes" to guardedAudioLighterLikeSpikes,
                "coughLikeBursts" to guardedAudioCoughLikeBursts,
                "steadyBreathCycles" to guardedAudioSteadyBreathCycles,
                "restlessnessBursts" to guardedAudioRestlessnessBursts,
                "audioRiskScore" to guardedAudioRiskScore,
                "sampleCount" to guardedAudioSamples,
            )
        }

        return mapOf(
            "active" to true,
            "startedAtMillis" to startedAt,
            "endsAtMillis" to endsAt,
            "sessionDurationSeconds" to ((now - startedAt) / 1000L).toInt().coerceAtLeast(0),
            "remainingSeconds" to ((endsAt - now) / 1000L).toInt().coerceAtLeast(0),
            "averageAmplitude" to guardedAudioAverageAmplitude,
            "peakAmplitude" to guardedAudioPeakAmplitude,
            "lighterLikeSpikes" to guardedAudioLighterLikeSpikes,
            "coughLikeBursts" to guardedAudioCoughLikeBursts,
            "steadyBreathCycles" to guardedAudioSteadyBreathCycles,
            "restlessnessBursts" to guardedAudioRestlessnessBursts,
            "audioRiskScore" to guardedAudioRiskScore,
            "sampleCount" to guardedAudioSamples,
        )
    }

    private fun sampleGuardedAudio() {
        val recorder = audioRecorder ?: return
        try {
            val amplitude = recorder.maxAmplitude.coerceAtLeast(0)
            if (amplitude <= 0) {
                return
            }

            guardedAudioSamples += 1
            guardedAudioAmplitudeSum += amplitude.toLong()
            guardedAudioAverageAmplitude =
                (guardedAudioAmplitudeSum / guardedAudioSamples).toInt().coerceAtLeast(0)
            guardedAudioPeakAmplitude = maxOf(guardedAudioPeakAmplitude, amplitude)

            val delta = abs(amplitude - guardedAudioLastAmplitude)
            if (amplitude >= 22000 && delta >= 10000) {
                guardedAudioLighterLikeSpikes += 1
            } else if (amplitude in 9000..18000 && delta >= 4500) {
                guardedAudioCoughLikeBursts += 1
            } else if (amplitude in 3200..9000 && delta in 800..2600) {
                guardedAudioSteadyBreathCycles += 1
            } else if (amplitude >= 14000 && delta >= 6500) {
                guardedAudioRestlessnessBursts += 1
            }
            guardedAudioRiskScore =
                ((guardedAudioLighterLikeSpikes * 18) +
                    (guardedAudioCoughLikeBursts * 12) +
                    (guardedAudioRestlessnessBursts * 7) -
                    (guardedAudioSteadyBreathCycles * 4))
                    .coerceIn(0, 100)
            guardedAudioLastAmplitude = amplitude
        } catch (_: Exception) {
            // The session should fail softly rather than killing the activity.
        }
    }

    private fun releaseRecorder() {
        val recorder = audioRecorder ?: return
        try {
            recorder.stop()
        } catch (_: Exception) {
            // Ignore stop failures when the recorder has not fully started.
        }
        try {
            recorder.reset()
        } catch (_: Exception) {
            // Ignore cleanup issues.
        }
        recorder.release()
        audioRecorder = null
    }

    private fun resetGuardedAudioStats() {
        guardedAudioAverageAmplitude = 0
        guardedAudioPeakAmplitude = 0
        guardedAudioLighterLikeSpikes = 0
        guardedAudioCoughLikeBursts = 0
        guardedAudioSteadyBreathCycles = 0
        guardedAudioRestlessnessBursts = 0
        guardedAudioRiskScore = 0
        guardedAudioSamples = 0
        guardedAudioAmplitudeSum = 0
        guardedAudioLastAmplitude = 0
    }

    private fun isCharging(): Boolean {
        val batteryStatus = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
        val status = batteryStatus?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1
        return status == BatteryManager.BATTERY_STATUS_CHARGING ||
            status == BatteryManager.BATTERY_STATUS_FULL
    }

    private fun isLocationServicesEnabled(): Boolean {
        val manager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
        return try {
            manager.isLocationEnabled
        } catch (_: Exception) {
            false
        }
    }

    private fun hasPermission(permission: String): Boolean {
        return ContextCompat.checkSelfPermission(
            this,
            permission,
        ) == PackageManager.PERMISSION_GRANTED
    }

    private fun hasAnyPermission(vararg permissions: String): Boolean {
        return permissions.any { permission -> hasPermission(permission) }
    }

    private fun hasUsageAccess(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                appOps.unsafeCheckOpNoThrow(
                    AppOpsManager.OPSTR_GET_USAGE_STATS,
                    Process.myUid(),
                    packageName,
                )
            } else {
                @Suppress("DEPRECATION")
                appOps.checkOpNoThrow(
                    AppOpsManager.OPSTR_GET_USAGE_STATS,
                    Process.myUid(),
                    packageName,
                )
            }
        return mode == AppOpsManager.MODE_ALLOWED
    }
}
