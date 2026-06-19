import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nafas_os/shared/models/app_enums.dart';
import 'package:nafas_os/shared/models/risk_assessment.dart';
import 'package:nafas_os/shared/services/platform_context_bridge_service.dart';

final notificationServiceProvider = Provider<NotificationService>((Ref ref) {
  return NotificationService(ref.read(platformContextBridgeServiceProvider));
});

class NotificationService {
  NotificationService(this._platformBridge);

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final PlatformContextBridgeService _platformBridge;

  bool _initialized = false;
  DateTime? _lastRiskAlertAt;
  Timer? _followUpTimer;

  Future<bool> initialize() async {
    if (_initialized) {
      return true;
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);

    if (!kIsWeb) {
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              'nafas_risk_channel',
              'Nafas Risk Alerts',
              description: 'Risk-aware intervention notifications.',
              importance: Importance.high,
            ),
          );
    }

    _initialized = true;
    return true;
  }

  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> showRiskAlert(
    RiskAssessment assessment, {
    InterventionType? recommendedIntervention,
  }) async {
    await initialize();
    _lastRiskAlertAt = DateTime.now();

    final String title = switch (assessment.level) {
      RiskLevel.low => 'نفس',
      RiskLevel.moderate => 'نافذة رغبة متوسطة',
      RiskLevel.high => 'نافذة رغبة مرتفعة',
      RiskLevel.critical => 'تدخل الآن',
    };
    final String body = recommendedIntervention == null
        ? assessment.summary
        : '${assessment.summary} أفضل خطوة الآن: ${_interventionLabel(recommendedIntervention)}.';

    await _plugin.show(
      9001,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'nafas_risk_channel',
          'Nafas Risk Alerts',
          channelDescription: 'Risk-aware intervention notifications.',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  bool canDispatchRiskAlert({required int cooldownMinutes}) {
    final DateTime? lastRiskAlertAt = _lastRiskAlertAt;
    if (lastRiskAlertAt == null) {
      return true;
    }
    return DateTime.now().difference(lastRiskAlertAt).inMinutes >=
        cooldownMinutes;
  }

  Future<void> scheduleFollowUp({
    required RiskAssessment assessment,
    required int minutes,
    InterventionType? recommendedIntervention,
  }) async {
    _followUpTimer?.cancel();
    if (minutes <= 0) {
      return;
    }

    await initialize();
    final String body = recommendedIntervention == null
        ? 'خذ 45 ثانية الآن قبل القرار التالي. ${assessment.summary}'
        : 'خذ 45 ثانية الآن. جرّب ${_interventionLabel(recommendedIntervention)} قبل القرار التالي.';

    if (defaultTargetPlatform == TargetPlatform.android) {
      await _platformBridge.schedulePersistentFollowUp(
        title: 'متابعة من نفس',
        body: body,
        triggerAtMillis: DateTime.now()
            .add(Duration(minutes: minutes))
            .millisecondsSinceEpoch,
      );
      return;
    }

    _followUpTimer = Timer(Duration(minutes: minutes), () async {
      await _plugin.show(
        9002,
        'متابعة من نفس',
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'nafas_risk_channel',
            'Nafas Risk Alerts',
            channelDescription: 'Risk-aware intervention notifications.',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    });
  }

  Future<void> cancelScheduledFollowUp() async {
    _followUpTimer?.cancel();
    _followUpTimer = null;
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _platformBridge.cancelPersistentFollowUp();
    }
  }

  String _interventionLabel(InterventionType type) {
    return switch (type) {
      InterventionType.breathing => 'تنفس موجّه',
      InterventionType.ghostCigarette => 'سيجارة شبح',
      InterventionType.guardedAudio => 'حراسة صوتية',
      InterventionType.walk => 'مشي قصير',
      InterventionType.water => 'ماء وتهدئة',
      InterventionType.microCbt => 'إعادة تسمية المحفز',
      InterventionType.driveShield => 'درع القيادة',
      InterventionType.notificationOnly => 'تدخل سريع',
    };
  }
}
