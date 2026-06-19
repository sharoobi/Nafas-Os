import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nafas_os/shared/models/app_enums.dart';
import 'package:nafas_os/shared/models/context_snapshot.dart';
import 'package:nafas_os/shared/models/craving_event.dart';
import 'package:nafas_os/shared/models/lab_settings.dart';
import 'package:nafas_os/shared/models/risk_assessment.dart';
import 'package:nafas_os/shared/models/smoke_event.dart';
import 'package:nafas_os/shared/models/symptom_log.dart';
import 'package:nafas_os/shared/models/user_profile.dart';

final riskEngineProvider = Provider<RiskEngine>((Ref ref) {
  return const RiskEngine();
});

class RiskEngine {
  const RiskEngine();

  RiskAssessment assess({
    required UserProfile profile,
    required LabSettings labSettings,
    required ContextSnapshot? contextSnapshot,
    required List<SmokeEvent> smokeHistory,
    required List<CravingEvent> cravingHistory,
    required List<SymptomLog> symptomHistory,
  }) {
    final DateTime now = DateTime.now();
    final Map<String, double> factors = <String, double>{};

    final double timeRisk = _timeRisk(now, profile.firstSmokeHour);
    factors['time_window'] = timeRisk;

    final double minutesSinceLastSmoke = smokeHistory.isEmpty
        ? 240
        : now.difference(smokeHistory.first.occurredAt).inMinutes.toDouble();
    final double abstinenceRisk = _abstinenceRisk(
      minutesSinceLastSmoke: minutesSinceLastSmoke,
      baselinePerDay: profile.cigarettesPerDayBaseline,
    );
    factors['minutes_since_last_smoke'] = abstinenceRisk;

    final double contextRisk = _contextRisk(
      snapshot: contextSnapshot,
      smokeHistory: smokeHistory,
      labSettings: labSettings,
      profile: profile,
    );
    factors['context_pattern'] = contextRisk;

    final double cravingCarryOver = cravingHistory.isEmpty
        ? 0
        : (cravingHistory.first.intensity / 10).clamp(0.0, 1.0) * 0.12;
    factors['recent_craving'] = cravingCarryOver;

    final double manualSignalRisk = _manualSignalRisk(
      contextSnapshot: contextSnapshot,
      cravingHistory: cravingHistory,
      profile: profile,
    );
    factors['manual_signal'] = manualSignalRisk;

    final double digitalPatternRisk = _digitalPatternRisk(
      contextSnapshot,
      profile,
    );
    factors['digital_pattern'] = digitalPatternRisk;

    final double symptomRisk = labSettings.healthGuardEnabled
        ? _symptomRisk(symptomHistory)
        : 0;
    factors['symptoms'] = symptomRisk;

    final double rawScore = factors.values
        .fold<double>(0, (double a, double b) => a + b)
        .clamp(0.0, 1.0);
    final double aggressionMultiplier =
        lerpDouble(
          0.92,
          1.12,
          profile.notificationAggression.clamp(0.0, 1.0),
        ) ??
        1.0;
    final double score = (rawScore * aggressionMultiplier).clamp(0.0, 1.0);

    final RiskLevel level = score >= profile.criticalThreshold
        ? RiskLevel.critical
        : score >= 0.56
        ? RiskLevel.high
        : score >= 0.32
        ? RiskLevel.moderate
        : RiskLevel.low;

    final bool healthCaution =
        labSettings.healthGuardEnabled &&
        symptomHistory.isNotEmpty &&
        (symptomHistory.first.bloodInSputum ||
            symptomHistory.first.breathlessness >= 7 ||
            symptomHistory.first.chestPain);

    final InterventionType intervention = _recommendIntervention(
      level: level,
      profile: profile,
      contextSnapshot: contextSnapshot,
      labSettings: labSettings,
      healthCaution: healthCaution,
    );

    return RiskAssessment(
      score: score,
      level: level,
      factors: factors,
      recommendedIntervention: intervention,
      healthCaution: healthCaution,
      summary: _buildSummary(
        level,
        intervention,
        contextSnapshot,
        healthCaution,
        cravingHistory,
      ),
    );
  }

  double _timeRisk(DateTime now, int firstSmokeHour) {
    final int difference = (now.hour - firstSmokeHour).abs();
    if (difference <= 1) {
      return 0.22;
    }
    if (now.hour >= 15 && now.hour <= 19) {
      return 0.18;
    }
    if (now.hour >= 22 || now.hour <= 1) {
      return 0.12;
    }
    return 0.06;
  }

  double _abstinenceRisk({
    required double minutesSinceLastSmoke,
    required int baselinePerDay,
  }) {
    final double safeBaseline = baselinePerDay.clamp(1, 60).toDouble();
    final double expectedIntervalMinutes = (16 * 60) / safeBaseline;
    final double window = (expectedIntervalMinutes * 2.4).clamp(55.0, 240.0);
    return (minutesSinceLastSmoke / window).clamp(0.0, 1.0) * 0.16;
  }

  double _contextRisk({
    required ContextSnapshot? snapshot,
    required List<SmokeEvent> smokeHistory,
    required LabSettings labSettings,
    required UserProfile profile,
  }) {
    if (snapshot == null) {
      return 0.04;
    }

    double value = 0.0;
    if (profile.coffeeRiskEnabled && snapshot.coffeeWindow) {
      value += 0.08;
    }
    if (profile.drivingRiskEnabled && labSettings.activityInferenceEnabled) {
      value +=
          (snapshot.vehicleContextScore *
                  (0.14 + (profile.effectiveDriveSensitivity * 0.08)))
              .clamp(0.0, 0.20);
      if (snapshot.driveCandidate) {
        value += 0.05 + (profile.effectiveDriveSensitivity * 0.04);
      }
      if (snapshot.carAudioRouteActive) {
        value += 0.05;
      }
    }
    if (profile.locationRiskEnabled &&
        labSettings.geofencingEnabled &&
        snapshot.locationClusterId != null &&
        smokeHistory.any(
          (SmokeEvent event) =>
              event.locationClusterId == snapshot.locationClusterId,
        )) {
      value += 0.14;
    }
    if (labSettings.bluetoothContextEnabled &&
        snapshot.bluetoothAudioConnected) {
      value += snapshot.audioRouteKind == 'car_audio' ? 0.08 : 0.05;
    }
    if (snapshot.musicActive) {
      value += 0.04;
    }
    if (snapshot.activityContext == ActivityContext.still &&
        snapshot.speedKph < 1.5) {
      value += 0.03 + (profile.effectiveBoredomSensitivity * 0.04);
      if (snapshot.vehicleContextScore > 0.4) {
        value += 0.06 + (profile.effectiveDriveSensitivity * 0.04);
      }
    }
    if (snapshot.charging) {
      value += 0.02;
    }
    if (snapshot.powerSaveMode) {
      value += 0.03;
    }
    if (snapshot.activityConfidence >= 0.75 &&
        snapshot.activityContext == ActivityContext.driving) {
      value += 0.04;
    }
    return value.clamp(0.0, 0.34);
  }

  double _symptomRisk(List<SymptomLog> symptomHistory) {
    if (symptomHistory.isEmpty) {
      return 0.0;
    }
    final SymptomLog latest = symptomHistory.first;
    double value = 0.0;
    value += latest.coughSeverity >= 6 ? 0.04 : 0.0;
    value += latest.breathlessness >= 5 ? 0.08 : 0.0;
    value += latest.sputumSeverity >= 5 ? 0.03 : 0.0;
    value += latest.bloodInSputum ? 0.12 : 0.0;
    value += latest.chestPain ? 0.12 : 0.0;
    return value.clamp(0.0, 0.24);
  }

  double _manualSignalRisk({
    required ContextSnapshot? contextSnapshot,
    required List<CravingEvent> cravingHistory,
    required UserProfile profile,
  }) {
    if (cravingHistory.isEmpty) {
      return 0.0;
    }
    final CravingEvent latest = cravingHistory.first;
    if (latest.triggerTag == 'ambient' ||
        latest.triggerTag == 'rescue_success' ||
        latest.triggerTag == 'unspecified') {
      return 0.0;
    }
    final int minutesSinceCheckIn = DateTime.now()
        .difference(latest.occurredAt)
        .inMinutes;
    if (minutesSinceCheckIn > 180) {
      return 0.0;
    }

    double value = (latest.stressLevel / 10).clamp(0.0, 1.0) * 0.12;
    if (latest.triggerTag == 'coffee' &&
        (contextSnapshot?.coffeeWindow ?? false)) {
      value += 0.05;
    }
    if (latest.triggerTag == 'driving' &&
        (contextSnapshot?.driveCandidate ?? false)) {
      value += 0.07;
    }
    if (latest.triggerTag == 'stress') {
      value += 0.04 + (profile.effectiveWorkStressSensitivity * 0.04);
    }
    if (latest.triggerTag == 'after_meal') {
      value += 0.03;
    }
    if (latest.triggerTag == 'boredom') {
      value += 0.03 + (profile.effectiveBoredomSensitivity * 0.03);
    }
    return value.clamp(0.0, 0.18);
  }

  double _digitalPatternRisk(ContextSnapshot? snapshot, UserProfile profile) {
    if (snapshot == null || !snapshot.usageAccessGranted) {
      return 0.0;
    }
    double value = 0.0;
    value +=
        (snapshot.digitalDriftScore *
                (0.10 + (profile.effectiveReelsSensitivity * 0.1)))
            .clamp(0.0, 0.20);
    if (snapshot.shortVideoMinutes >= 10) {
      value += 0.03 + (profile.effectiveReelsSensitivity * 0.05);
    }
    if (snapshot.socialMediaMinutes >= 14) {
      value += 0.04;
    }
    if (snapshot.messagingMinutes >= 8 && snapshot.appSwitchesLast30m >= 6) {
      value += 0.05;
    }
    final String dominant = snapshot.dominantAppPackage;
    if (dominant == 'com.instagram.android' ||
        dominant == 'com.zhiliaoapp.musically') {
      value += 0.04;
    }
    if (dominant == 'com.whatsapp' || dominant == 'com.whatsapp.w4b') {
      value += 0.03;
    }
    if (snapshot.activityContext == ActivityContext.still) {
      value += 0.03 * profile.effectiveBoredomSensitivity;
    }
    return value.clamp(0.0, 0.24);
  }

  InterventionType _recommendIntervention({
    required RiskLevel level,
    required UserProfile profile,
    required ContextSnapshot? contextSnapshot,
    required LabSettings labSettings,
    required bool healthCaution,
  }) {
    if (healthCaution) {
      return InterventionType.breathing;
    }
    if (contextSnapshot?.driveCandidate ?? false) {
      return InterventionType.driveShield;
    }
    if (labSettings.guardedAudioEnabled && level == RiskLevel.critical) {
      return InterventionType.guardedAudio;
    }
    if (level == RiskLevel.critical) {
      return InterventionType.ghostCigarette;
    }
    if (level == RiskLevel.high) {
      return profile.preferredRescue;
    }
    if (contextSnapshot?.coffeeWindow ?? false) {
      return InterventionType.water;
    }
    return InterventionType.notificationOnly;
  }

  String _buildSummary(
    RiskLevel level,
    InterventionType intervention,
    ContextSnapshot? contextSnapshot,
    bool healthCaution,
    List<CravingEvent> cravingHistory,
  ) {
    if (healthCaution) {
      return 'الإشارات التنفسية الحالية تستدعي تهدئة فورية وتدخلاً وقائيًا هادئًا الآن.';
    }

    final CravingEvent? latestManualSignal = cravingHistory.isEmpty
        ? null
        : cravingHistory.first;
    final CravingEvent? visibleManualSignal =
        latestManualSignal == null ||
            latestManualSignal.triggerTag == 'ambient' ||
            latestManualSignal.triggerTag == 'rescue_success' ||
            latestManualSignal.triggerTag == 'unspecified'
        ? null
        : latestManualSignal;

    final String contextLabel = switch (contextSnapshot?.activityContext) {
      ActivityContext.driving => 'أنت الآن في سياق قيادة أو انتقال سريع.',
      ActivityContext.walking => 'هناك حركة خفيفة، وهذا يغيّر شكل التدخل الأنسب.',
      ActivityContext.still => 'أنت ثابت في مكان مألوف، وهذا يرفع قيمة قراءة السياق.',
      _ => 'السياق الحالي ما زال تحت الملاحظة.'
    };

    final String manualCue = visibleManualSignal == null
        ? ''
        : ' آخر إشارة يدوية كانت ${_triggerLabel(visibleManualSignal.triggerTag)} مع توتر ${visibleManualSignal.stressLevel}/10.';

    final String digitalCue = _buildDigitalCue(contextSnapshot);

    return switch (level) {
      RiskLevel.low =>
        'النافذة الحالية هادئة نسبيًا. $contextLabel$manualCue$digitalCue',
      RiskLevel.moderate =>
        'هناك موجة متوسطة تتشكّل الآن. $contextLabel$manualCue$digitalCue ابدأ بتدخل قصير قبل أن ترتفع.',
      RiskLevel.high =>
        'الخطر مرتفع الآن. $contextLabel$manualCue$digitalCue أفضل خطوة الآن: ${_interventionLabel(intervention)}.',
      RiskLevel.critical =>
        'الخطر حرج الآن. $contextLabel$manualCue$digitalCue افتح وضع الإنقاذ وابدأ ${_interventionLabel(intervention)} فورًا.',
    };
  }

  String _buildDigitalCue(ContextSnapshot? snapshot) {
    if (snapshot == null || !snapshot.usageAccessGranted) {
      return '';
    }

    final List<String> cues = <String>[];
    if (snapshot.shortVideoMinutes >= 10) {
      cues.add('جلسة ريلز/فيديو قصير طويلة');
    }
    if (snapshot.messagingMinutes >= 8 && snapshot.appSwitchesLast30m >= 6) {
      cues.add('تنقل متوتر بين تطبيقات المراسلة');
    }
    if (snapshot.digitalDriftScore >= 0.6) {
      cues.add('انجراف رقمي مرتفع');
    }
    final String dominantLabel = _packageLabel(snapshot.dominantAppPackage);
    if (snapshot.dominantAppMinutes >= 12 && dominantLabel.isNotEmpty) {
      cues.add('جلسة طويلة على $dominantLabel');
    }

    if (cues.isEmpty) {
      return '';
    }
    return ' القراءة الرقمية تلاحظ: ${cues.join(' + ')}.';
  }

  String _interventionLabel(InterventionType type) {
    return switch (type) {
      InterventionType.breathing => 'تنفس موجه',
      InterventionType.ghostCigarette => 'سيجارة شبح',
      InterventionType.guardedAudio => 'حراسة صوتية',
      InterventionType.walk => 'مشي قصير',
      InterventionType.water => 'ماء وتهدئة',
      InterventionType.microCbt => 'إعادة تسمية المحفز',
      InterventionType.driveShield => 'درع القيادة',
      InterventionType.notificationOnly => 'تدخل سريع',
    };
  }

  String _triggerLabel(String triggerTag) {
    return switch (triggerTag) {
      'coffee' => 'القهوة',
      'stress' => 'الضغط',
      'after_meal' => 'ما بعد الأكل',
      'driving' => 'القيادة',
      'social' => 'السياق الاجتماعي',
      'boredom' => 'الملل',
      'wake_up' => 'بعد الاستيقاظ',
      _ => triggerTag.replaceAll('_', ' '),
    };
  }

  String _packageLabel(String packageName) {
    return switch (packageName) {
      'com.instagram.android' => 'إنستغرام',
      'com.zhiliaoapp.musically' => 'تيك توك',
      'com.google.android.youtube' => 'يوتيوب',
      'com.whatsapp' => 'واتساب',
      'com.whatsapp.w4b' => 'واتساب بزنس',
      'org.telegram.messenger' => 'تيليغرام',
      _ => '',
    };
  }
}
