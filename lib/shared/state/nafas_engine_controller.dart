import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nafas_os/shared/data/repositories/isar_nafas_repository.dart';
import 'package:nafas_os/shared/data/repositories/nafas_repository.dart';
import 'package:nafas_os/shared/models/app_enums.dart';
import 'package:nafas_os/shared/models/companion_brief.dart';
import 'package:nafas_os/shared/models/companion_mission.dart';
import 'package:nafas_os/shared/models/context_snapshot.dart';
import 'package:nafas_os/shared/models/craving_event.dart';
import 'package:nafas_os/shared/models/dashboard_summary.dart';
import 'package:nafas_os/shared/models/guarded_audio_session.dart';
import 'package:nafas_os/shared/models/guarded_audio_training_sample.dart';
import 'package:nafas_os/shared/models/insights_digest.dart';
import 'package:nafas_os/shared/models/intervention_event.dart';
import 'package:nafas_os/shared/models/lab_settings.dart';
import 'package:nafas_os/shared/models/mission_memory.dart';
import 'package:nafas_os/shared/models/permission_matrix.dart';
import 'package:nafas_os/shared/models/risk_assessment.dart';
import 'package:nafas_os/shared/models/smoke_event.dart';
import 'package:nafas_os/shared/models/symptom_log.dart';
import 'package:nafas_os/shared/models/user_profile.dart';
import 'package:nafas_os/shared/services/adaptive_profile_engine.dart';
import 'package:nafas_os/shared/services/context_sampling_service.dart';
import 'package:nafas_os/shared/services/engagement_engine.dart';
import 'package:nafas_os/shared/services/guarded_audio_classifier.dart';
import 'package:nafas_os/shared/services/notification_service.dart';
import 'package:nafas_os/shared/services/permission_orchestrator_service.dart';
import 'package:nafas_os/shared/services/platform_context_bridge_service.dart';
import 'package:nafas_os/shared/services/risk_engine.dart';
import 'package:nafas_os/shared/state/app_lifecycle_controller.dart';

final nafasEngineControllerProvider =
    AsyncNotifierProvider<NafasEngineController, NafasDashboardState>(
      NafasEngineController.new,
    );

class NafasDashboardState {
  const NafasDashboardState({
    required this.profile,
    required this.labSettings,
    required this.summary,
    required this.riskAssessment,
    required this.permissions,
    required this.latestContext,
    required this.timeline,
    required this.notificationsReady,
    required this.capabilities,
    required this.guardedAudioSession,
    required this.activeRescueIntervention,
    required this.activeRescueMissionId,
    required this.activeRescueStartedAt,
    required this.appLifecycleState,
    required this.companionBrief,
    required this.missions,
    required this.missionMemories,
    required this.recentGuardedAudioSamples,
    required this.totalGuardedAudioSamples,
    required this.labeledGuardedAudioSamples,
    required this.insightsDigest,
  });

  final UserProfile profile;
  final LabSettings labSettings;
  final DashboardSummary summary;
  final RiskAssessment riskAssessment;
  final PermissionMatrix permissions;
  final ContextSnapshot? latestContext;
  final List<TimelineCardData> timeline;
  final bool notificationsReady;
  final Map<String, dynamic> capabilities;
  final GuardedAudioSession guardedAudioSession;
  final InterventionType? activeRescueIntervention;
  final String? activeRescueMissionId;
  final DateTime? activeRescueStartedAt;
  final AppLifecycleState appLifecycleState;
  final CompanionBrief companionBrief;
  final List<CompanionMission> missions;
  final List<MissionMemory> missionMemories;
  final List<GuardedAudioTrainingSample> recentGuardedAudioSamples;
  final int totalGuardedAudioSamples;
  final int labeledGuardedAudioSamples;
  final InsightsDigest insightsDigest;

  bool get appInForeground =>
      appLifecycleState == AppLifecycleState.resumed ||
      appLifecycleState == AppLifecycleState.inactive;

  NafasDashboardState copyWith({
    UserProfile? profile,
    LabSettings? labSettings,
    DashboardSummary? summary,
    RiskAssessment? riskAssessment,
    PermissionMatrix? permissions,
    ContextSnapshot? latestContext,
    List<TimelineCardData>? timeline,
    bool? notificationsReady,
    Map<String, dynamic>? capabilities,
    GuardedAudioSession? guardedAudioSession,
    InterventionType? activeRescueIntervention,
    String? activeRescueMissionId,
    bool clearActiveRescueMissionId = false,
    bool clearActiveRescueIntervention = false,
    DateTime? activeRescueStartedAt,
    bool clearActiveRescueStartedAt = false,
    AppLifecycleState? appLifecycleState,
    CompanionBrief? companionBrief,
    List<CompanionMission>? missions,
    List<MissionMemory>? missionMemories,
    List<GuardedAudioTrainingSample>? recentGuardedAudioSamples,
    int? totalGuardedAudioSamples,
    int? labeledGuardedAudioSamples,
    InsightsDigest? insightsDigest,
  }) {
    return NafasDashboardState(
      profile: profile ?? this.profile,
      labSettings: labSettings ?? this.labSettings,
      summary: summary ?? this.summary,
      riskAssessment: riskAssessment ?? this.riskAssessment,
      permissions: permissions ?? this.permissions,
      latestContext: latestContext ?? this.latestContext,
      timeline: timeline ?? this.timeline,
      notificationsReady: notificationsReady ?? this.notificationsReady,
      capabilities: capabilities ?? this.capabilities,
      guardedAudioSession: guardedAudioSession ?? this.guardedAudioSession,
      activeRescueMissionId: clearActiveRescueMissionId
          ? null
          : activeRescueMissionId ?? this.activeRescueMissionId,
      activeRescueIntervention: clearActiveRescueIntervention
          ? null
          : activeRescueIntervention ?? this.activeRescueIntervention,
      activeRescueStartedAt: clearActiveRescueStartedAt
          ? null
          : activeRescueStartedAt ?? this.activeRescueStartedAt,
      appLifecycleState: appLifecycleState ?? this.appLifecycleState,
      companionBrief: companionBrief ?? this.companionBrief,
      missions: missions ?? this.missions,
      missionMemories: missionMemories ?? this.missionMemories,
      recentGuardedAudioSamples:
          recentGuardedAudioSamples ?? this.recentGuardedAudioSamples,
      totalGuardedAudioSamples:
          totalGuardedAudioSamples ?? this.totalGuardedAudioSamples,
      labeledGuardedAudioSamples:
          labeledGuardedAudioSamples ?? this.labeledGuardedAudioSamples,
      insightsDigest: insightsDigest ?? this.insightsDigest,
    );
  }
}

class TimelineCardData {
  const TimelineCardData({
    required this.timeLabel,
    required this.title,
    required this.description,
    required this.tintName,
  });

  final String timeLabel;
  final String title;
  final String description;
  final String tintName;
}

class NafasEngineController extends AsyncNotifier<NafasDashboardState> {
  NafasRepository? _repository;
  String? _lastRecordedAudioSessionSignature;

  NafasRepository get _repo {
    final NafasRepository? repository = _repository;
    if (repository == null) {
      throw StateError('NafasRepository has not been initialized yet.');
    }
    return repository;
  }

  @override
  Future<NafasDashboardState> build() async {
    _repository = await ref.watch(nafasRepositoryProvider.future);
    final NotificationService notificationService = ref.read(
      notificationServiceProvider,
    );
    final PermissionOrchestratorService permissionService = ref.read(
      permissionOrchestratorServiceProvider,
    );
    final ContextSamplingService contextSamplingService = ref.read(
      contextSamplingServiceProvider,
    );
    final PlatformContextBridgeService platformBridge = ref.read(
      platformContextBridgeServiceProvider,
    );
    final RiskEngine riskEngine = ref.read(riskEngineProvider);
    final AppLifecycleState lifecycleState = ref.watch(
      appLifecycleControllerProvider,
    );

    final Map<String, dynamic> capabilities = await platformBridge
        .getPlatformCapabilities()
        .catchError((Object _) => <String, dynamic>{});

    final UserProfile profile = await _repo.ensureProfile();
    final LabSettings labSettings = await _repo.ensureLabSettings();
    await notificationService.initialize();
    final PermissionMatrix permissions = await permissionService.snapshot();
    final ContextSnapshot context = await contextSamplingService.capture();
    await _repo.addContextSnapshot(context);
    final GuardedAudioSession guardedAudioSession =
        await _guardedAudioStatusOrInactive();

    final NafasDashboardState dashboard = await _loadDashboard(
      profile: profile,
      labSettings: labSettings,
      permissions: permissions,
      capabilities: capabilities,
      riskEngine: riskEngine,
      notificationsReady: true,
      guardedAudioSession: guardedAudioSession,
      activeRescueIntervention: null,
      activeRescueMissionId: null,
      activeRescueStartedAt: null,
      lifecycleState: lifecycleState,
    );

    await _maybeTriggerNotification(dashboard);
    return dashboard;
  }

  Future<void> refreshDashboard() async {
    final NafasDashboardState? current = state.asData?.value;
    if (current == null) {
      state = const AsyncLoading();
      state = await AsyncValue.guard(build);
      return;
    }

    final PermissionMatrix permissions = await ref
        .read(permissionOrchestratorServiceProvider)
        .snapshot();
    final ContextSnapshot context = await ref
        .read(contextSamplingServiceProvider)
        .capture();
    await _repo.addContextSnapshot(context);
    final PlatformContextBridgeService platformBridge = ref.read(
      platformContextBridgeServiceProvider,
    );
    final Map<String, dynamic> rawGuardedAudioStatus = await platformBridge
        .getGuardedAudioStatus()
        .catchError((Object _) => <String, dynamic>{'active': false});
    if (current.guardedAudioSession.active &&
        !((rawGuardedAudioStatus['active'] as bool?) ?? false)) {
      await _recordGuardedAudioTrainingSample(rawGuardedAudioStatus);
    }
    final GuardedAudioSession guardedAudioSession = await _mapGuardedAudioStatus(
      rawGuardedAudioStatus,
    );
    final AppLifecycleState lifecycleState = ref.read(
      appLifecycleControllerProvider,
    );

    final NafasDashboardState next = await _loadDashboard(
      profile: current.profile,
      labSettings: current.labSettings,
      permissions: permissions,
      capabilities: current.capabilities,
      riskEngine: ref.read(riskEngineProvider),
      notificationsReady: current.notificationsReady,
      guardedAudioSession: guardedAudioSession,
      activeRescueIntervention: current.activeRescueIntervention,
      activeRescueMissionId: current.activeRescueMissionId,
      activeRescueStartedAt: current.activeRescueStartedAt,
      lifecycleState: lifecycleState,
    );
    state = AsyncData(next);
    await _maybeTriggerNotification(next);
  }

  Future<void> requestAllPermissions() async {
    final PermissionMatrix permissions = await ref
        .read(permissionOrchestratorServiceProvider)
        .requestAllRelevantPermissions();
    await ref.read(notificationServiceProvider).requestPermissions();
    final NafasDashboardState current = state.requireValue;
    state = AsyncData(current.copyWith(permissions: permissions));
  }

  Future<void> requestMicrophonePermission() async {
    final PermissionMatrix permissions = await ref
        .read(permissionOrchestratorServiceProvider)
        .requestMicrophonePermission();
    final NafasDashboardState current = state.requireValue;
    state = AsyncData(current.copyWith(permissions: permissions));
  }

  Future<void> saveLabSettings({
    double? criticalThreshold,
    bool? geofencingEnabled,
    bool? guardedAudioEnabled,
    bool? healthGuardEnabled,
    bool? backgroundInterventionsEnabled,
    bool? bluetoothContextEnabled,
    bool? activityInferenceEnabled,
    int? followUpMinutes,
    int? rescueDurationSeconds,
    int? notificationCooldownMinutes,
  }) async {
    final NafasDashboardState current = state.requireValue;
    final UserProfile nextProfile = current.profile.copyWith(
      criticalThreshold: criticalThreshold,
    );
    final LabSettings nextSettings = current.labSettings.copyWith(
      geofencingEnabled: geofencingEnabled,
      guardedAudioEnabled: guardedAudioEnabled,
      healthGuardEnabled: healthGuardEnabled,
      backgroundInterventionsEnabled: backgroundInterventionsEnabled,
      bluetoothContextEnabled: bluetoothContextEnabled,
      activityInferenceEnabled: activityInferenceEnabled,
      followUpMinutes: followUpMinutes,
      rescueDurationSeconds: rescueDurationSeconds,
      notificationCooldownMinutes: notificationCooldownMinutes,
    );

    await _repo.saveProfile(nextProfile);
    await _repo.saveLabSettings(nextSettings);

    state = AsyncData(
      current.copyWith(profile: nextProfile, labSettings: nextSettings),
    );
    await refreshDashboard();
  }

  Future<void> saveProfileSettings({
    int? cigarettesPerDayBaseline,
    int? firstSmokeHour,
    bool? coffeeRiskEnabled,
    bool? drivingRiskEnabled,
    bool? locationRiskEnabled,
    double? notificationAggression,
    double? criticalThreshold,
    SupportTone? supportTone,
    InterventionType? preferredRescue,
    double? reelsSensitivity,
    double? workStressSensitivity,
    double? boredomSensitivity,
  }) async {
    final NafasDashboardState current = state.requireValue;
    final UserProfile nextProfile = current.profile.copyWith(
      cigarettesPerDayBaseline: cigarettesPerDayBaseline,
      firstSmokeHour: firstSmokeHour,
      coffeeRiskEnabled: coffeeRiskEnabled,
      drivingRiskEnabled: drivingRiskEnabled,
      locationRiskEnabled: locationRiskEnabled,
      notificationAggression: notificationAggression,
      criticalThreshold: criticalThreshold,
      supportTone: supportTone,
      preferredRescue: preferredRescue,
      reelsSensitivity: reelsSensitivity,
      workStressSensitivity: workStressSensitivity,
      boredomSensitivity: boredomSensitivity,
    );
    await _repo.saveProfile(nextProfile);
    state = AsyncData(current.copyWith(profile: nextProfile));
    await refreshDashboard();
  }

  Future<void> logSmoke() async {
    final NafasDashboardState current = state.requireValue;
    await _repo.addSmokeEvent(
      SmokeEvent(
        id: 0,
        occurredAt: DateTime.now(),
        cigarettesCount: 1,
        triggerTag: 'manual_smoke',
        contextLabel: current.riskAssessment.summary,
        stressLevel: 5,
        precededByPrediction:
            current.riskAssessment.level.index >= RiskLevel.moderate.index,
        predictedRiskScore: current.riskAssessment.score,
        locationClusterId: current.latestContext?.locationClusterId,
      ),
    );
    await refreshDashboard();
  }

  Future<void> logCraving({bool resolvedWithoutSmoking = false}) async {
    final NafasDashboardState current = state.requireValue;
    await _repo.addCravingEvent(
      CravingEvent(
        id: 0,
        occurredAt: DateTime.now(),
        intensity: (current.riskAssessment.score * 10).round().clamp(1, 10),
        triggerTag: 'ambient',
        stressLevel: 5,
        contextLabel: current.riskAssessment.summary,
        resolvedWithoutSmoking: resolvedWithoutSmoking,
        predicted:
            current.riskAssessment.level.index >= RiskLevel.moderate.index,
        durationSeconds: resolvedWithoutSmoking
            ? current.labSettings.rescueDurationSeconds
            : 30,
      ),
    );
    if (resolvedWithoutSmoking && current.activeRescueIntervention != null) {
      await completeActiveRescue(successful: true);
      return;
    }
    await refreshDashboard();
  }

  Future<void> logManualCheckIn({
    required String triggerTag,
    required int intensity,
    required int stressLevel,
    bool startRescue = false,
  }) async {
    final NafasDashboardState current = state.requireValue;
    final String readableTrigger = triggerTag.replaceAll('_', ' ');
    final String contextLabel =
        'إشارة يدوية: $readableTrigger، الرغبة $intensity/10، التوتر $stressLevel/10. ${current.riskAssessment.summary}';
    await _repo.addCravingEvent(
      CravingEvent(
        id: 0,
        occurredAt: DateTime.now(),
        intensity: intensity.clamp(1, 10),
        triggerTag: triggerTag,
        stressLevel: stressLevel.clamp(1, 10),
        contextLabel: contextLabel,
        resolvedWithoutSmoking: false,
        predicted:
            current.riskAssessment.level.index >= RiskLevel.moderate.index,
        durationSeconds: current.labSettings.rescueDurationSeconds,
      ),
    );
    await refreshDashboard();
    if (startRescue) {
      await startRescueFlow();
    }
  }

  Future<void> logSymptom({
    int coughSeverity = 6,
    int breathlessness = 4,
    int sputumSeverity = 3,
    bool bloodInSputum = false,
    bool chestPain = false,
  }) async {
    await _repo.addSymptomLog(
      SymptomLog(
        id: 0,
        occurredAt: DateTime.now(),
        coughSeverity: coughSeverity,
        breathlessness: breathlessness,
        sputumSeverity: sputumSeverity,
        bloodInSputum: bloodInSputum,
        chestPain: chestPain,
      ),
    );
    await refreshDashboard();
  }

  Future<void> startRescueFlow({
    InterventionType? interventionType,
    String? missionId,
  }) async {
    final NafasDashboardState current = state.requireValue;
    final InterventionType selected =
        interventionType ?? current.riskAssessment.recommendedIntervention;
    await _repo.addInterventionEvent(
      InterventionEvent(
        id: 0,
        occurredAt: DateTime.now(),
        interventionType: selected,
        riskScore: current.riskAssessment.score,
        accepted: true,
        successful: false,
        contextLabel: 'بدأت جلسة إنقاذ: ${current.riskAssessment.summary}',
      ),
    );
    if (missionId != null) {
      await _recordMissionStart(
        missionId: missionId,
        interventionType: selected,
        existing: current.missionMemories,
      );
    }
    state = AsyncData(
      current.copyWith(
        activeRescueIntervention: selected,
        activeRescueMissionId: missionId,
        activeRescueStartedAt: DateTime.now(),
      ),
    );
    await ref.read(notificationServiceProvider).cancelScheduledFollowUp();
    await refreshDashboard();
  }

  Future<void> moveToNextRescueApproach() async {
    final NafasDashboardState current = state.requireValue;
    final InterventionType previous =
        current.activeRescueIntervention ??
        current.riskAssessment.recommendedIntervention;
    final InterventionType next = _nextIntervention(
      previous,
      current.labSettings,
      current.permissions,
    );

    await _repo.addInterventionEvent(
      InterventionEvent(
        id: 0,
        occurredAt: DateTime.now(),
        interventionType: previous,
        riskScore: current.riskAssessment.score,
        accepted: true,
        successful: false,
        contextLabel:
            '${current.riskAssessment.summary} -> تم التحويل إلى ${_interventionLabel(next)}',
      ),
    );

    state = AsyncData(
      current.copyWith(
        activeRescueIntervention: next,
        activeRescueMissionId: current.activeRescueMissionId,
        activeRescueStartedAt: DateTime.now(),
      ),
    );
    await refreshDashboard();
  }

  Future<void> completeActiveRescue({required bool successful}) async {
    final NafasDashboardState current = state.requireValue;
    final InterventionType intervention =
        current.activeRescueIntervention ??
        current.riskAssessment.recommendedIntervention;

    await _repo.addInterventionEvent(
      InterventionEvent(
        id: 0,
        occurredAt: DateTime.now(),
        interventionType: intervention,
        riskScore: current.riskAssessment.score,
        accepted: true,
        successful: successful,
        contextLabel: current.riskAssessment.summary,
      ),
    );

    if (successful) {
      await _repo.addCravingEvent(
        CravingEvent(
          id: 0,
          occurredAt: DateTime.now(),
          intensity: (current.riskAssessment.score * 10).round().clamp(1, 10),
          triggerTag: 'rescue_success',
          stressLevel: 3,
          contextLabel: current.riskAssessment.summary,
          resolvedWithoutSmoking: true,
          predicted: true,
          durationSeconds: current.labSettings.rescueDurationSeconds,
        ),
      );
    }
    if (current.activeRescueMissionId != null) {
      await _recordMissionOutcome(
        missionId: current.activeRescueMissionId!,
        successful: successful,
        interventionType: intervention,
        existing: current.missionMemories,
      );
    }

    state = AsyncData(
      current.copyWith(
        clearActiveRescueMissionId: true,
        clearActiveRescueIntervention: true,
        clearActiveRescueStartedAt: true,
      ),
    );
    await ref.read(notificationServiceProvider).cancelScheduledFollowUp();
    await refreshDashboard();
  }

  Future<void> startGuardedAudioMode({int? durationSeconds}) async {
    final NafasDashboardState current = state.requireValue;
    final Map<String, dynamic> status = await ref
        .read(platformContextBridgeServiceProvider)
        .startGuardedAudioMode(
          durationSeconds:
              durationSeconds ?? current.labSettings.rescueDurationSeconds * 4,
        );
    final GuardedAudioSession guardedAudioSession =
        await _mapGuardedAudioStatus(status);
    state = AsyncData(
      current.copyWith(guardedAudioSession: guardedAudioSession),
    );
    await ref.read(notificationServiceProvider).cancelScheduledFollowUp();
    await refreshDashboard();
  }

  Future<void> stopGuardedAudioMode() async {
    final NafasDashboardState current = state.requireValue;
    final Map<String, dynamic> status = await ref
        .read(platformContextBridgeServiceProvider)
        .stopGuardedAudioMode();
    await _recordGuardedAudioTrainingSample(status);
    final GuardedAudioSession guardedAudioSession =
        await _mapGuardedAudioStatus(status);
    state = AsyncData(
      current.copyWith(guardedAudioSession: guardedAudioSession),
    );
    await refreshDashboard();
  }

  Future<void> labelGuardedAudioSample({
    required int id,
    required String confirmedLabel,
  }) async {
    await _repo.updateGuardedAudioTrainingSampleLabel(
      id: id,
      confirmedLabel: confirmedLabel,
    );
    await refreshDashboard();
  }

  Future<String?> exportGuardedAudioDataset({bool labeledOnly = true}) async {
    final List<GuardedAudioTrainingSample> samples = await _repo
        .recentGuardedAudioTrainingSamples(limit: 5000);
    final Iterable<GuardedAudioTrainingSample> exportable = labeledOnly
        ? samples.where((GuardedAudioTrainingSample sample) => sample.isLabeled)
        : samples;
    final StringBuffer csv = StringBuffer();
    csv.writeln(
      'captured_at,started_at,ended_at,session_duration_seconds,average_amplitude,peak_amplitude,lighter_like_spikes,cough_like_bursts,steady_breath_cycles,restlessness_bursts,audio_risk_score,sample_count,predicted_label,predicted_confidence,prediction_source,recommended_action,confirmed_label',
    );
    for (final GuardedAudioTrainingSample sample in exportable) {
      csv.writeln(
        <String>[
          sample.capturedAt.toIso8601String(),
          sample.startedAt?.toIso8601String() ?? '',
          sample.endedAt?.toIso8601String() ?? '',
          sample.sessionDurationSeconds.toString(),
          sample.averageAmplitude.toString(),
          sample.peakAmplitude.toString(),
          sample.lighterLikeSpikes.toString(),
          sample.coughLikeBursts.toString(),
          sample.steadyBreathCycles.toString(),
          sample.restlessnessBursts.toString(),
          sample.audioRiskScore.toString(),
          sample.sampleCount.toString(),
          sample.predictedLabel,
          sample.predictedConfidence.toStringAsFixed(4),
          sample.predictionSource,
          sample.recommendedAction,
          sample.confirmedLabel ?? '',
        ].map(_csvField).join(','),
      );
    }
    return ref.read(platformContextBridgeServiceProvider).exportTextToDownloads(
      fileName:
          labeledOnly
              ? 'nafas_guarded_audio_labeled.csv'
              : 'nafas_guarded_audio_all.csv',
      content: csv.toString(),
      mimeType: 'text/csv',
    );
  }

  Future<NafasDashboardState> _loadDashboard({
    required UserProfile profile,
    required LabSettings labSettings,
    required PermissionMatrix permissions,
    required Map<String, dynamic> capabilities,
    required RiskEngine riskEngine,
    required bool notificationsReady,
    required GuardedAudioSession guardedAudioSession,
    required InterventionType? activeRescueIntervention,
    required String? activeRescueMissionId,
    required DateTime? activeRescueStartedAt,
    required AppLifecycleState lifecycleState,
  }) async {
    final List<SmokeEvent> smokeHistory = await _repo.recentSmokeEvents(
      limit: 16,
    );
    final List<CravingEvent> cravingHistory = await _repo.recentCravingEvents(
      limit: 16,
    );
    final List<SymptomLog> symptomHistory = await _repo.recentSymptomLogs(
      limit: 10,
    );
    final List<InterventionEvent> interventions = await _repo
        .recentInterventions(limit: 10);
    final DateTime since30d = DateTime.now().subtract(const Duration(days: 30));
    final List<SmokeEvent> smoke30d = await _repo.smokeEventsSince(since30d);
    final List<CravingEvent> craving30d = await _repo.cravingEventsSince(since30d);
    final List<InterventionEvent> interventions30d = await _repo
        .interventionsSince(since30d);
    final List<ContextSnapshot> context30d = await _repo.contextSnapshotsSince(
      since30d,
    );
    final List<MissionMemory> missionMemories = await _repo.missionMemories();
    final List<GuardedAudioTrainingSample> recentGuardedAudioSamples =
        await _repo.recentGuardedAudioTrainingSamples(limit: 8);
    final int totalGuardedAudioSamples = await _repo
        .countGuardedAudioTrainingSamples();
    final int labeledGuardedAudioSamples = await _repo
        .countGuardedAudioTrainingSamples(labeledOnly: true);
    final ContextSnapshot? latestContext = await _repo.latestContextSnapshot();
    final DashboardSummary summary = await _repo.buildSummary();
    final UserProfile adaptedProfile = ref
        .read(adaptiveProfileEngineProvider)
        .adapt(
          profile: profile,
          smokeEvents: smoke30d,
          cravingEvents: craving30d,
          interventionEvents: interventions30d,
          contextSnapshots: context30d,
        );
    if (_shouldPersistAdaptiveProfile(profile, adaptedProfile)) {
      await _repo.saveProfile(adaptedProfile);
    }

    final RiskAssessment riskAssessment = riskEngine.assess(
      profile: adaptedProfile,
      labSettings: labSettings,
      contextSnapshot: latestContext,
      smokeHistory: smokeHistory,
      cravingHistory: cravingHistory,
      symptomHistory: symptomHistory,
    );

    final EngagementEngine engagementEngine = ref.read(
      engagementEngineProvider,
    );
    final CompanionBrief companionBrief = engagementEngine.buildCompanionBrief(
      profile: adaptedProfile,
      summary: summary,
      assessment: riskAssessment,
      latestContext: latestContext,
    );
    final List<CompanionMission> missions = engagementEngine.buildMissions(
      profile: adaptedProfile,
      summary: summary,
      assessment: riskAssessment,
      latestContext: latestContext,
      missionMemories: missionMemories,
    );
    final InsightsDigest insightsDigest = engagementEngine.buildInsightsDigest(
      smokeEvents: smoke30d,
      cravingEvents: craving30d,
      interventionEvents: interventions30d,
      contextSnapshots: context30d,
      summary: summary,
    );

    final List<TimelineCardData> timeline = <TimelineCardData>[
      ...smokeHistory
          .take(2)
          .map(
            (SmokeEvent event) => TimelineCardData(
              timeLabel: _timeLabel(event.occurredAt),
              title: 'حدث تدخين',
              description: event.contextLabel,
              tintName: 'amber',
            ),
          ),
      ...cravingHistory
          .take(2)
          .map(
            (CravingEvent event) => TimelineCardData(
              timeLabel: _timeLabel(event.occurredAt),
              title: event.resolvedWithoutSmoking
                  ? 'موجة تم تجاوزها'
                  : 'موجة رغبة',
              description: event.contextLabel,
              tintName: event.resolvedWithoutSmoking ? 'emerald' : 'primary',
            ),
          ),
      ...interventions
          .take(2)
          .map(
            (InterventionEvent event) => TimelineCardData(
              timeLabel: _timeLabel(event.occurredAt),
              title: _interventionLabel(event.interventionType),
              description: event.contextLabel,
              tintName: event.successful ? 'emerald' : 'secondary',
            ),
          ),
      ...symptomHistory
          .take(1)
          .map(
            (SymptomLog event) => TimelineCardData(
              timeLabel: _timeLabel(event.occurredAt),
              title: 'ملاحظة صحية',
              description:
                  'السعال ${event.coughSeverity}/10، ضيق النفس ${event.breathlessness}/10',
              tintName: event.bloodInSputum ? 'danger' : 'secondary',
            ),
          ),
      if (guardedAudioSession.active)
        TimelineCardData(
          timeLabel: _timeLabel(DateTime.now()),
          title: 'الحراسة الصوتية نشطة',
          description:
              'متبقٍ ${guardedAudioSession.remainingSeconds}ث، الذروة ${guardedAudioSession.peakAmplitude}، شرارات ${guardedAudioSession.lighterLikeSpikes}، نوبات سعال ${guardedAudioSession.coughLikeBursts}.',
          tintName: 'primary',
        ),
    ];

    return NafasDashboardState(
      profile: adaptedProfile,
      labSettings: labSettings,
      summary: summary,
      riskAssessment: riskAssessment,
      permissions: permissions,
      latestContext: latestContext,
      timeline: timeline.take(8).toList(),
      notificationsReady: notificationsReady,
      capabilities: capabilities,
      guardedAudioSession: guardedAudioSession,
      activeRescueIntervention: activeRescueIntervention,
      activeRescueMissionId: activeRescueMissionId,
      activeRescueStartedAt: activeRescueStartedAt,
      appLifecycleState: lifecycleState,
      companionBrief: companionBrief,
      missions: missions,
      missionMemories: missionMemories,
      recentGuardedAudioSamples: recentGuardedAudioSamples,
      totalGuardedAudioSamples: totalGuardedAudioSamples,
      labeledGuardedAudioSamples: labeledGuardedAudioSamples,
      insightsDigest: insightsDigest,
    );
  }

  Future<void> _maybeTriggerNotification(NafasDashboardState dashboard) async {
    if (!dashboard.permissions.notifications) {
      return;
    }
    if (dashboard.activeRescueIntervention != null ||
        dashboard.guardedAudioSession.active) {
      await ref.read(notificationServiceProvider).cancelScheduledFollowUp();
      return;
    }

    final NotificationService notificationService = ref.read(
      notificationServiceProvider,
    );
    final bool appInteractive =
        dashboard.latestContext?.screenInteractive ?? true;
    final bool backgroundAware =
        dashboard.labSettings.backgroundInterventionsEnabled;
    final bool appForeground = dashboard.appInForeground;
    final bool shouldNotify =
        dashboard.riskAssessment.level == RiskLevel.critical ||
        (backgroundAware &&
            !appForeground &&
            !appInteractive &&
            dashboard.riskAssessment.level.index >= RiskLevel.high.index);

    if (!shouldNotify) {
      return;
    }

    if (!notificationService.canDispatchRiskAlert(
      cooldownMinutes: dashboard.labSettings.notificationCooldownMinutes,
    )) {
      return;
    }

    await notificationService.showRiskAlert(
      dashboard.riskAssessment,
      recommendedIntervention: dashboard.riskAssessment.recommendedIntervention,
    );
    if (backgroundAware &&
        dashboard.riskAssessment.level.index >= RiskLevel.high.index) {
      await notificationService.scheduleFollowUp(
        assessment: dashboard.riskAssessment,
        minutes: dashboard.labSettings.followUpMinutes,
        recommendedIntervention:
            dashboard.riskAssessment.recommendedIntervention,
      );
    } else {
      await notificationService.cancelScheduledFollowUp();
    }
  }

  InterventionType _nextIntervention(
    InterventionType current,
    LabSettings settings,
    PermissionMatrix permissions,
  ) {
    final List<InterventionType> candidates = <InterventionType>[
      InterventionType.microCbt,
      InterventionType.breathing,
      InterventionType.water,
      InterventionType.walk,
      InterventionType.ghostCigarette,
      InterventionType.driveShield,
      if (settings.guardedAudioEnabled && permissions.microphone)
        InterventionType.guardedAudio,
    ];
    final int currentIndex = candidates.indexOf(current);
    if (currentIndex == -1) {
      return candidates.first;
    }
    return candidates[(currentIndex + 1) % candidates.length];
  }

  Future<GuardedAudioSession> _guardedAudioStatusOrInactive() async {
    try {
      final Map<String, dynamic> status = await ref
          .read(platformContextBridgeServiceProvider)
          .getGuardedAudioStatus();
      return _mapGuardedAudioStatus(status);
    } catch (_) {
      return const GuardedAudioSession.inactive();
    }
  }

  Future<GuardedAudioSession> _mapGuardedAudioStatus(
    Map<String, dynamic> status,
  ) async {
    final bool active = status['active'] as bool? ?? false;
    if (!active) {
      return const GuardedAudioSession.inactive();
    }

    final GuardedAudioClassification classification = await ref
        .read(guardedAudioClassifierProvider)
        .classify(status);

    final int? startedAtMillis = status['startedAtMillis'] as int?;
    final int? endsAtMillis = status['endsAtMillis'] as int?;
    return GuardedAudioSession(
      active: true,
      startedAt: startedAtMillis == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(startedAtMillis),
      endsAt: endsAtMillis == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(endsAtMillis),
      remainingSeconds: (status['remainingSeconds'] as int?) ?? 0,
      averageAmplitude: (status['averageAmplitude'] as int?) ?? 0,
      peakAmplitude: (status['peakAmplitude'] as int?) ?? 0,
      lighterLikeSpikes: (status['lighterLikeSpikes'] as int?) ?? 0,
      coughLikeBursts: (status['coughLikeBursts'] as int?) ?? 0,
      sampleCount: (status['sampleCount'] as int?) ?? 0,
      steadyBreathCycles: (status['steadyBreathCycles'] as int?) ?? 0,
      restlessnessBursts: (status['restlessnessBursts'] as int?) ?? 0,
      audioRiskScore: (status['audioRiskScore'] as int?) ?? 0,
      classificationLabel: classification.label,
      classificationConfidence: classification.confidence,
      recommendedAction: classification.recommendedAction,
      classificationSource: classification.source,
    );
  }

  Future<void> _recordGuardedAudioTrainingSample(
    Map<String, dynamic> status,
  ) async {
    final int samples = (status['sampleCount'] as int?) ?? 0;
    if (samples < 3) {
      return;
    }
    final String signature =
        '${status['startedAtMillis']}_${status['endedAtMillis']}_${status['sampleCount']}_${status['peakAmplitude']}_${status['lighterLikeSpikes']}_${status['coughLikeBursts']}';
    if (_lastRecordedAudioSessionSignature == signature) {
      return;
    }

    final GuardedAudioClassification classification = await ref
        .read(guardedAudioClassifierProvider)
        .classify(status);
    final DateTime? startedAt = _dateFromMillis(status['startedAtMillis']);
    final DateTime? endedAt = _dateFromMillis(status['endedAtMillis']);
    final GuardedAudioTrainingSample? latest = await _repo
        .latestGuardedAudioTrainingSample();
    if (latest != null &&
        latest.startedAt == startedAt &&
        latest.sampleCount == samples &&
        latest.peakAmplitude == ((status['peakAmplitude'] as int?) ?? 0)) {
      _lastRecordedAudioSessionSignature = signature;
      return;
    }

    await _repo.addGuardedAudioTrainingSample(
      GuardedAudioTrainingSample(
        id: 0,
        capturedAt: DateTime.now(),
        startedAt: startedAt,
        endedAt: endedAt,
        sessionDurationSeconds: (status['sessionDurationSeconds'] as int?) ?? 0,
        averageAmplitude: (status['averageAmplitude'] as int?) ?? 0,
        peakAmplitude: (status['peakAmplitude'] as int?) ?? 0,
        lighterLikeSpikes: (status['lighterLikeSpikes'] as int?) ?? 0,
        coughLikeBursts: (status['coughLikeBursts'] as int?) ?? 0,
        steadyBreathCycles: (status['steadyBreathCycles'] as int?) ?? 0,
        restlessnessBursts: (status['restlessnessBursts'] as int?) ?? 0,
        audioRiskScore: (status['audioRiskScore'] as int?) ?? 0,
        sampleCount: samples,
        predictedLabel: classification.label,
        predictedConfidence: classification.confidence,
        predictionSource: classification.source,
        recommendedAction: classification.recommendedAction,
        confirmedLabel: null,
      ),
    );
    _lastRecordedAudioSessionSignature = signature;
  }

  bool _shouldPersistAdaptiveProfile(
    UserProfile previous,
    UserProfile next,
  ) {
    return (previous.adaptiveReelsBias - next.adaptiveReelsBias).abs() >=
            0.01 ||
        (previous.adaptiveStressBias - next.adaptiveStressBias).abs() >=
            0.01 ||
        (previous.adaptiveBoredomBias - next.adaptiveBoredomBias).abs() >=
            0.01 ||
        (previous.adaptiveDriveBias - next.adaptiveDriveBias).abs() >= 0.01 ||
        (previous.adaptationConfidence - next.adaptationConfidence).abs() >=
            0.02;
  }

  Future<void> _recordMissionStart({
    required String missionId,
    required InterventionType interventionType,
    required List<MissionMemory> existing,
  }) async {
    final MissionMemory? memory = _findMissionMemory(existing, missionId);
    final DateTime now = DateTime.now();
    final MissionMemory nextMemory =
        (memory ??
                MissionMemory(
                  id: 0,
                  missionId: missionId,
                  startedCount: 0,
                  successCount: 0,
                  failureCount: 0,
                  currentStreak: 0,
                  bestStreak: 0,
                  momentumScore: 0.0,
                  lastOutcome: 'none',
                  lastInterventionType: interventionType,
                  lastUpdatedAt: now,
                ))
            .copyWith(
              startedCount: (memory?.startedCount ?? 0) + 1,
              lastOutcome: 'started',
              lastInterventionType: interventionType,
              lastUpdatedAt: now,
              momentumScore: _nextMomentum(
                previous: memory?.momentumScore ?? 0.0,
                successful: null,
              ),
            );
    await _repo.upsertMissionMemory(nextMemory);
  }

  Future<void> _recordMissionOutcome({
    required String missionId,
    required bool successful,
    required InterventionType interventionType,
    required List<MissionMemory> existing,
  }) async {
    final MissionMemory? memory = _findMissionMemory(existing, missionId);
    final DateTime now = DateTime.now();
    final int currentStreak = successful
        ? (memory?.currentStreak ?? 0) + 1
        : 0;
    final MissionMemory nextMemory =
        (memory ??
                MissionMemory(
                  id: 0,
                  missionId: missionId,
                  startedCount: 0,
                  successCount: 0,
                  failureCount: 0,
                  currentStreak: 0,
                  bestStreak: 0,
                  momentumScore: 0.0,
                  lastOutcome: 'none',
                  lastInterventionType: interventionType,
                  lastUpdatedAt: now,
                ))
            .copyWith(
              successCount:
                  (memory?.successCount ?? 0) + (successful ? 1 : 0),
              failureCount:
                  (memory?.failureCount ?? 0) + (successful ? 0 : 1),
              currentStreak: currentStreak,
              bestStreak: math.max(memory?.bestStreak ?? 0, currentStreak),
              momentumScore: _nextMomentum(
                previous: memory?.momentumScore ?? 0.0,
                successful: successful,
              ),
              lastOutcome: successful ? 'success' : 'failure',
              lastInterventionType: interventionType,
              lastUpdatedAt: now,
            );
    await _repo.upsertMissionMemory(nextMemory);
  }

  MissionMemory? _findMissionMemory(List<MissionMemory> memories, String id) {
    for (final MissionMemory memory in memories) {
      if (memory.missionId == id) {
        return memory;
      }
    }
    return null;
  }

  double _nextMomentum({
    required double previous,
    required bool? successful,
  }) {
    if (successful == null) {
      return (previous * 0.82 + 0.12).clamp(0.0, 1.0);
    }
    if (successful) {
      return (previous * 0.72 + 0.34).clamp(0.0, 1.0);
    }
    return (previous * 0.55).clamp(0.0, 1.0);
  }

  DateTime? _dateFromMillis(dynamic value) {
    final int? millis = value as int?;
    if (millis == null || millis <= 0) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  String _csvField(String value) {
    final String escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }

  String _timeLabel(DateTime value) {
    final String hour = value.hour.toString().padLeft(2, '0');
    final String minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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
