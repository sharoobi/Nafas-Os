import 'package:flutter_test/flutter_test.dart';
import 'package:nafas_os/shared/models/app_enums.dart';
import 'package:nafas_os/shared/models/context_snapshot.dart';
import 'package:nafas_os/shared/models/craving_event.dart';
import 'package:nafas_os/shared/models/lab_settings.dart';
import 'package:nafas_os/shared/models/risk_assessment.dart';
import 'package:nafas_os/shared/models/smoke_event.dart';
import 'package:nafas_os/shared/models/symptom_log.dart';
import 'package:nafas_os/shared/models/user_profile.dart';
import 'package:nafas_os/shared/services/risk_engine.dart';

void main() {
  test('risk engine escalates to high or critical on strong context', () {
    const RiskEngine engine = RiskEngine();

    final RiskAssessment assessment = engine.assess(
      profile: UserProfile(
        id: 1,
        createdAt: DateTime(2026, 4, 8, 8),
        cigarettesPerDayBaseline: 15,
        firstSmokeHour: DateTime.now().hour,
        coffeeRiskEnabled: true,
        drivingRiskEnabled: true,
        locationRiskEnabled: true,
        notificationAggression: 0.8,
        criticalThreshold: 0.7,
        supportTone: SupportTone.balanced,
        preferredRescue: InterventionType.microCbt,
        reelsSensitivity: 0.7,
        workStressSensitivity: 0.65,
        boredomSensitivity: 0.6,
        adaptiveReelsBias: 0.1,
        adaptiveStressBias: 0.08,
        adaptiveBoredomBias: 0.06,
        adaptiveDriveBias: 0.14,
        adaptationConfidence: 0.72,
        lastAdaptedAt: DateTime(2026, 4, 15, 4),
      ),
      labSettings: const LabSettings(
        id: 1,
        geofencingEnabled: true,
        guardedAudioEnabled: true,
        healthGuardEnabled: true,
        backgroundInterventionsEnabled: true,
        bluetoothContextEnabled: true,
        activityInferenceEnabled: true,
        followUpMinutes: 8,
        rescueDurationSeconds: 45,
        notificationCooldownMinutes: 12,
      ),
      contextSnapshot: ContextSnapshot(
        id: 1,
        capturedAt: DateTime.now(),
        locationClusterId: '14.5:44.1',
        latitude: 14.5,
        longitude: 44.1,
        speedKph: 42,
        activityContext: ActivityContext.driving,
        bluetoothEnabled: true,
        bluetoothBondedCount: 2,
        bluetoothAudioConnected: true,
        a2dpConnected: true,
        headsetProfileConnected: true,
        carAudioRouteActive: true,
        wiredAudioRouteActive: false,
        audioRouteKind: 'car_audio',
        vehicleContextScore: 0.92,
        musicActive: true,
        screenInteractive: true,
        powerSaveMode: false,
        charging: false,
        coffeeWindow: true,
        driveCandidate: true,
        activityConfidence: 0.88,
        activitySource: 'native_transition',
        usageAccessGranted: true,
        dominantAppPackage: 'com.instagram.android',
        dominantAppMinutes: 18,
        shortVideoMinutes: 16,
        socialMediaMinutes: 18,
        messagingMinutes: 6,
        appSwitchesLast30m: 8,
        digitalDriftScore: 0.76,
      ),
      smokeHistory: <SmokeEvent>[
        SmokeEvent(
          id: 1,
          occurredAt: DateTime.now().subtract(const Duration(minutes: 80)),
          cigarettesCount: 1,
          triggerTag: 'coffee',
          contextLabel: 'coffee',
          stressLevel: 6,
          precededByPrediction: true,
          predictedRiskScore: 0.8,
          locationClusterId: '14.5:44.1',
        ),
      ],
      cravingHistory: <CravingEvent>[
        CravingEvent(
          id: 1,
          occurredAt: DateTime.now().subtract(const Duration(minutes: 5)),
          intensity: 8,
          triggerTag: 'driving',
          stressLevel: 8,
          contextLabel: 'drive',
          resolvedWithoutSmoking: false,
          predicted: true,
          durationSeconds: 45,
        ),
      ],
      symptomHistory: <SymptomLog>[
        SymptomLog(
          id: 1,
          occurredAt: DateTime.now().subtract(const Duration(minutes: 12)),
          coughSeverity: 6,
          breathlessness: 7,
          sputumSeverity: 4,
          bloodInSputum: false,
          chestPain: false,
        ),
      ],
    );

    expect(assessment.score, greaterThan(0.55));
    expect(
      assessment.level == RiskLevel.high ||
          assessment.level == RiskLevel.critical,
      isTrue,
    );
  });
}
