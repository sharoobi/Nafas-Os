import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nafas_os/shared/data/local/nafas_database.dart';
import 'package:nafas_os/shared/data/repositories/nafas_repository.dart';
import 'package:nafas_os/shared/models/app_enums.dart';
import 'package:nafas_os/shared/models/context_snapshot.dart';
import 'package:nafas_os/shared/models/craving_event.dart';
import 'package:nafas_os/shared/models/dashboard_summary.dart';
import 'package:nafas_os/shared/models/guarded_audio_training_sample.dart';
import 'package:nafas_os/shared/models/intervention_event.dart';
import 'package:nafas_os/shared/models/lab_settings.dart';
import 'package:nafas_os/shared/models/mission_memory.dart';
import 'package:nafas_os/shared/models/smoke_event.dart';
import 'package:nafas_os/shared/models/symptom_log.dart';
import 'package:nafas_os/shared/models/user_profile.dart';
import 'package:sqflite/sqflite.dart';

final nafasRepositoryProvider = FutureProvider<NafasRepository>((
  Ref ref,
) async {
  final Database database = await ref.watch(nafasDatabaseProvider.future);
  return SqliteNafasRepository(database);
});

class SqliteNafasRepository implements NafasRepository {
  SqliteNafasRepository(this._database);

  final Database _database;

  @override
  Future<UserProfile> ensureProfile() async {
    final List<Map<String, Object?>> rows = await _database.query(
      'user_profile',
      limit: 1,
    );
    if (rows.isNotEmpty) {
      return _mapUserProfile(rows.first);
    }

    final DateTime now = DateTime.now();
    final int id = await _database.insert('user_profile', <String, Object?>{
      'created_at': now.toIso8601String(),
      'cigarettes_per_day_baseline': 12,
      'first_smoke_hour': 8,
      'coffee_risk_enabled': 1,
      'driving_risk_enabled': 1,
      'location_risk_enabled': 1,
      'notification_aggression': 0.72,
      'critical_threshold': 0.74,
      'support_tone': SupportTone.balanced.name,
      'preferred_rescue': InterventionType.microCbt.name,
      'reels_sensitivity': 0.68,
      'work_stress_sensitivity': 0.64,
      'boredom_sensitivity': 0.58,
      'adaptive_reels_bias': 0.0,
      'adaptive_stress_bias': 0.0,
      'adaptive_boredom_bias': 0.0,
      'adaptive_drive_bias': 0.0,
      'adaptation_confidence': 0.0,
      'last_adapted_at': null,
    });

    return UserProfile(
      id: id,
      createdAt: now,
      cigarettesPerDayBaseline: 12,
      firstSmokeHour: 8,
      coffeeRiskEnabled: true,
      drivingRiskEnabled: true,
      locationRiskEnabled: true,
      notificationAggression: 0.72,
      criticalThreshold: 0.74,
      supportTone: SupportTone.balanced,
      preferredRescue: InterventionType.microCbt,
      reelsSensitivity: 0.68,
      workStressSensitivity: 0.64,
      boredomSensitivity: 0.58,
      adaptiveReelsBias: 0.0,
      adaptiveStressBias: 0.0,
      adaptiveBoredomBias: 0.0,
      adaptiveDriveBias: 0.0,
      adaptationConfidence: 0.0,
      lastAdaptedAt: null,
    );
  }

  @override
  Future<UserProfile> saveProfile(UserProfile profile) async {
    await _database.update(
      'user_profile',
      <String, Object?>{
        'created_at': profile.createdAt.toIso8601String(),
        'cigarettes_per_day_baseline': profile.cigarettesPerDayBaseline,
        'first_smoke_hour': profile.firstSmokeHour,
        'coffee_risk_enabled': profile.coffeeRiskEnabled ? 1 : 0,
        'driving_risk_enabled': profile.drivingRiskEnabled ? 1 : 0,
        'location_risk_enabled': profile.locationRiskEnabled ? 1 : 0,
        'notification_aggression': profile.notificationAggression,
        'critical_threshold': profile.criticalThreshold,
        'support_tone': profile.supportTone.name,
        'preferred_rescue': profile.preferredRescue.name,
        'reels_sensitivity': profile.reelsSensitivity,
        'work_stress_sensitivity': profile.workStressSensitivity,
        'boredom_sensitivity': profile.boredomSensitivity,
        'adaptive_reels_bias': profile.adaptiveReelsBias,
        'adaptive_stress_bias': profile.adaptiveStressBias,
        'adaptive_boredom_bias': profile.adaptiveBoredomBias,
        'adaptive_drive_bias': profile.adaptiveDriveBias,
        'adaptation_confidence': profile.adaptationConfidence,
        'last_adapted_at': profile.lastAdaptedAt?.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: <Object?>[profile.id],
    );
    return profile;
  }

  @override
  Future<LabSettings> ensureLabSettings() async {
    final List<Map<String, Object?>> rows = await _database.query(
      'lab_settings',
      limit: 1,
    );
    if (rows.isNotEmpty) {
      return _mapLabSettings(rows.first);
    }

    final int id = await _database.insert('lab_settings', <String, Object?>{
      'geofencing_enabled': 1,
      'guarded_audio_enabled': 0,
      'health_guard_enabled': 1,
      'background_interventions_enabled': 1,
      'bluetooth_context_enabled': 1,
      'activity_inference_enabled': 1,
      'follow_up_minutes': 8,
      'rescue_duration_seconds': 45,
      'notification_cooldown_minutes': 12,
    });

    return LabSettings(
      id: id,
      geofencingEnabled: true,
      guardedAudioEnabled: false,
      healthGuardEnabled: true,
      backgroundInterventionsEnabled: true,
      bluetoothContextEnabled: true,
      activityInferenceEnabled: true,
      followUpMinutes: 8,
      rescueDurationSeconds: 45,
      notificationCooldownMinutes: 12,
    );
  }

  @override
  Future<LabSettings> saveLabSettings(LabSettings settings) async {
    await _database.update(
      'lab_settings',
      <String, Object?>{
        'geofencing_enabled': settings.geofencingEnabled ? 1 : 0,
        'guarded_audio_enabled': settings.guardedAudioEnabled ? 1 : 0,
        'health_guard_enabled': settings.healthGuardEnabled ? 1 : 0,
        'background_interventions_enabled':
            settings.backgroundInterventionsEnabled ? 1 : 0,
        'bluetooth_context_enabled': settings.bluetoothContextEnabled ? 1 : 0,
        'activity_inference_enabled': settings.activityInferenceEnabled ? 1 : 0,
        'follow_up_minutes': settings.followUpMinutes,
        'rescue_duration_seconds': settings.rescueDurationSeconds,
        'notification_cooldown_minutes': settings.notificationCooldownMinutes,
      },
      where: 'id = ?',
      whereArgs: <Object?>[settings.id],
    );
    return settings;
  }

  @override
  Future<void> addSmokeEvent(SmokeEvent event) async {
    await _database.insert('smoke_event', <String, Object?>{
      'occurred_at': event.occurredAt.toIso8601String(),
      'cigarettes_count': event.cigarettesCount,
      'trigger_tag': event.triggerTag,
      'context_label': event.contextLabel,
      'stress_level': event.stressLevel,
      'preceded_by_prediction': event.precededByPrediction ? 1 : 0,
      'predicted_risk_score': event.predictedRiskScore,
      'location_cluster_id': event.locationClusterId,
    });
  }

  @override
  Future<void> addCravingEvent(CravingEvent event) async {
    await _database.insert('craving_event', <String, Object?>{
      'occurred_at': event.occurredAt.toIso8601String(),
      'intensity': event.intensity,
      'trigger_tag': event.triggerTag,
      'stress_level': event.stressLevel,
      'context_label': event.contextLabel,
      'resolved_without_smoking': event.resolvedWithoutSmoking ? 1 : 0,
      'predicted': event.predicted ? 1 : 0,
      'duration_seconds': event.durationSeconds,
    });
  }

  @override
  Future<void> addSymptomLog(SymptomLog log) async {
    await _database.insert('symptom_log', <String, Object?>{
      'occurred_at': log.occurredAt.toIso8601String(),
      'cough_severity': log.coughSeverity,
      'breathlessness': log.breathlessness,
      'sputum_severity': log.sputumSeverity,
      'blood_in_sputum': log.bloodInSputum ? 1 : 0,
      'chest_pain': log.chestPain ? 1 : 0,
    });
  }

  @override
  Future<void> addInterventionEvent(InterventionEvent event) async {
    await _database.insert('intervention_event', <String, Object?>{
      'occurred_at': event.occurredAt.toIso8601String(),
      'intervention_type': event.interventionType.name,
      'risk_score': event.riskScore,
      'accepted': event.accepted ? 1 : 0,
      'successful': event.successful ? 1 : 0,
      'context_label': event.contextLabel,
    });
  }

  @override
  Future<void> addContextSnapshot(ContextSnapshot snapshot) async {
    await _database.insert('context_snapshot', <String, Object?>{
      'captured_at': snapshot.capturedAt.toIso8601String(),
      'location_cluster_id': snapshot.locationClusterId,
      'latitude': snapshot.latitude,
      'longitude': snapshot.longitude,
      'speed_kph': snapshot.speedKph,
      'activity_context': snapshot.activityContext.name,
      'bluetooth_enabled': snapshot.bluetoothEnabled ? 1 : 0,
      'bluetooth_bonded_count': snapshot.bluetoothBondedCount,
      'bluetooth_audio_connected': snapshot.bluetoothAudioConnected ? 1 : 0,
      'a2dp_connected': snapshot.a2dpConnected ? 1 : 0,
      'headset_profile_connected': snapshot.headsetProfileConnected ? 1 : 0,
      'car_audio_route_active': snapshot.carAudioRouteActive ? 1 : 0,
      'wired_audio_route_active': snapshot.wiredAudioRouteActive ? 1 : 0,
      'audio_route_kind': snapshot.audioRouteKind,
      'vehicle_context_score': snapshot.vehicleContextScore,
      'music_active': snapshot.musicActive ? 1 : 0,
      'screen_interactive': snapshot.screenInteractive ? 1 : 0,
      'power_save_mode': snapshot.powerSaveMode ? 1 : 0,
      'charging': snapshot.charging ? 1 : 0,
      'coffee_window': snapshot.coffeeWindow ? 1 : 0,
      'drive_candidate': snapshot.driveCandidate ? 1 : 0,
      'activity_confidence': snapshot.activityConfidence,
      'activity_source': snapshot.activitySource,
      'usage_access_granted': snapshot.usageAccessGranted ? 1 : 0,
      'dominant_app_package': snapshot.dominantAppPackage,
      'dominant_app_minutes': snapshot.dominantAppMinutes,
      'short_video_minutes': snapshot.shortVideoMinutes,
      'social_media_minutes': snapshot.socialMediaMinutes,
      'messaging_minutes': snapshot.messagingMinutes,
      'app_switches_last_30m': snapshot.appSwitchesLast30m,
      'digital_drift_score': snapshot.digitalDriftScore,
    });
  }

  @override
  Future<List<SmokeEvent>> recentSmokeEvents({int limit = 20}) async {
    final List<Map<String, Object?>> rows = await _database.query(
      'smoke_event',
      orderBy: 'occurred_at DESC',
      limit: limit,
    );
    return rows.map(_mapSmokeEvent).toList();
  }

  @override
  Future<List<CravingEvent>> recentCravingEvents({int limit = 20}) async {
    final List<Map<String, Object?>> rows = await _database.query(
      'craving_event',
      orderBy: 'occurred_at DESC',
      limit: limit,
    );
    return rows.map(_mapCravingEvent).toList();
  }

  @override
  Future<List<SymptomLog>> recentSymptomLogs({int limit = 20}) async {
    final List<Map<String, Object?>> rows = await _database.query(
      'symptom_log',
      orderBy: 'occurred_at DESC',
      limit: limit,
    );
    return rows.map(_mapSymptomLog).toList();
  }

  @override
  Future<List<InterventionEvent>> recentInterventions({int limit = 20}) async {
    final List<Map<String, Object?>> rows = await _database.query(
      'intervention_event',
      orderBy: 'occurred_at DESC',
      limit: limit,
    );
    return rows.map(_mapInterventionEvent).toList();
  }

  @override
  Future<List<ContextSnapshot>> recentContextSnapshots({int limit = 20}) async {
    final List<Map<String, Object?>> rows = await _database.query(
      'context_snapshot',
      orderBy: 'captured_at DESC',
      limit: limit,
    );
    return rows.map(_mapContextSnapshot).toList();
  }

  @override
  Future<List<SmokeEvent>> smokeEventsSince(DateTime since, {int limit = 500}) async {
    final List<Map<String, Object?>> rows = await _database.query(
      'smoke_event',
      where: 'occurred_at >= ?',
      whereArgs: <Object?>[since.toIso8601String()],
      orderBy: 'occurred_at DESC',
      limit: limit,
    );
    return rows.map(_mapSmokeEvent).toList();
  }

  @override
  Future<List<CravingEvent>> cravingEventsSince(
    DateTime since, {
    int limit = 500,
  }) async {
    final List<Map<String, Object?>> rows = await _database.query(
      'craving_event',
      where: 'occurred_at >= ?',
      whereArgs: <Object?>[since.toIso8601String()],
      orderBy: 'occurred_at DESC',
      limit: limit,
    );
    return rows.map(_mapCravingEvent).toList();
  }

  @override
  Future<List<InterventionEvent>> interventionsSince(
    DateTime since, {
    int limit = 500,
  }) async {
    final List<Map<String, Object?>> rows = await _database.query(
      'intervention_event',
      where: 'occurred_at >= ?',
      whereArgs: <Object?>[since.toIso8601String()],
      orderBy: 'occurred_at DESC',
      limit: limit,
    );
    return rows.map(_mapInterventionEvent).toList();
  }

  @override
  Future<List<ContextSnapshot>> contextSnapshotsSince(
    DateTime since, {
    int limit = 500,
  }) async {
    final List<Map<String, Object?>> rows = await _database.query(
      'context_snapshot',
      where: 'captured_at >= ?',
      whereArgs: <Object?>[since.toIso8601String()],
      orderBy: 'captured_at DESC',
      limit: limit,
    );
    return rows.map(_mapContextSnapshot).toList();
  }

  @override
  Future<List<MissionMemory>> missionMemories() async {
    final List<Map<String, Object?>> rows = await _database.query(
      'mission_memory',
      orderBy: 'last_updated_at DESC',
    );
    return rows.map(_mapMissionMemory).toList();
  }

  @override
  Future<MissionMemory> upsertMissionMemory(MissionMemory memory) async {
    final MissionMemory nextMemory = memory.copyWith(
      lastUpdatedAt: memory.lastUpdatedAt,
    );
    await _database.insert(
      'mission_memory',
      <String, Object?>{
        'mission_id': nextMemory.missionId,
        'started_count': nextMemory.startedCount,
        'success_count': nextMemory.successCount,
        'failure_count': nextMemory.failureCount,
        'current_streak': nextMemory.currentStreak,
        'best_streak': nextMemory.bestStreak,
        'momentum_score': nextMemory.momentumScore,
        'last_outcome': nextMemory.lastOutcome,
        'last_intervention_type': nextMemory.lastInterventionType.name,
        'last_updated_at': nextMemory.lastUpdatedAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    final List<Map<String, Object?>> rows = await _database.query(
      'mission_memory',
      where: 'mission_id = ?',
      whereArgs: <Object?>[nextMemory.missionId],
      limit: 1,
    );
    return _mapMissionMemory(rows.first);
  }

  @override
  Future<void> addGuardedAudioTrainingSample(
    GuardedAudioTrainingSample sample,
  ) async {
    await _database.insert('guarded_audio_training_sample', <String, Object?>{
      'captured_at': sample.capturedAt.toIso8601String(),
      'started_at': sample.startedAt?.toIso8601String(),
      'ended_at': sample.endedAt?.toIso8601String(),
      'session_duration_seconds': sample.sessionDurationSeconds,
      'average_amplitude': sample.averageAmplitude,
      'peak_amplitude': sample.peakAmplitude,
      'lighter_like_spikes': sample.lighterLikeSpikes,
      'cough_like_bursts': sample.coughLikeBursts,
      'steady_breath_cycles': sample.steadyBreathCycles,
      'restlessness_bursts': sample.restlessnessBursts,
      'audio_risk_score': sample.audioRiskScore,
      'sample_count': sample.sampleCount,
      'predicted_label': sample.predictedLabel,
      'predicted_confidence': sample.predictedConfidence,
      'prediction_source': sample.predictionSource,
      'recommended_action': sample.recommendedAction,
      'confirmed_label': sample.confirmedLabel,
    });
  }

  @override
  Future<List<GuardedAudioTrainingSample>> recentGuardedAudioTrainingSamples({
    int limit = 20,
  }) async {
    final List<Map<String, Object?>> rows = await _database.query(
      'guarded_audio_training_sample',
      orderBy: 'captured_at DESC',
      limit: limit,
    );
    return rows.map(_mapGuardedAudioTrainingSample).toList();
  }

  @override
  Future<GuardedAudioTrainingSample?> latestGuardedAudioTrainingSample() async {
    final List<Map<String, Object?>> rows = await _database.query(
      'guarded_audio_training_sample',
      orderBy: 'captured_at DESC',
      limit: 1,
    );
    return rows.isEmpty ? null : _mapGuardedAudioTrainingSample(rows.first);
  }

  @override
  Future<GuardedAudioTrainingSample?> updateGuardedAudioTrainingSampleLabel({
    required int id,
    required String confirmedLabel,
  }) async {
    await _database.update(
      'guarded_audio_training_sample',
      <String, Object?>{'confirmed_label': confirmedLabel},
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
    final List<Map<String, Object?>> rows = await _database.query(
      'guarded_audio_training_sample',
      where: 'id = ?',
      whereArgs: <Object?>[id],
      limit: 1,
    );
    return rows.isEmpty ? null : _mapGuardedAudioTrainingSample(rows.first);
  }

  @override
  Future<int> countGuardedAudioTrainingSamples({bool labeledOnly = false}) async {
    final List<Map<String, Object?>> rows = await _database.rawQuery(
      labeledOnly
          ? 'SELECT COUNT(*) AS count FROM guarded_audio_training_sample WHERE confirmed_label IS NOT NULL AND confirmed_label != \'\''
          : 'SELECT COUNT(*) AS count FROM guarded_audio_training_sample',
    );
    return (rows.first['count'] as int?) ?? 0;
  }

  @override
  Future<ContextSnapshot?> latestContextSnapshot() async {
    final List<Map<String, Object?>> rows = await _database.query(
      'context_snapshot',
      orderBy: 'captured_at DESC',
      limit: 1,
    );
    return rows.isEmpty ? null : _mapContextSnapshot(rows.first);
  }

  @override
  Future<DashboardSummary> buildSummary() async {
    final DateTime now = DateTime.now();
    final String startOfDay = DateTime(
      now.year,
      now.month,
      now.day,
    ).toIso8601String();
    final List<Map<String, Object?>> smokeRows = await _database.query(
      'smoke_event',
      where: 'occurred_at >= ?',
      whereArgs: <Object?>[startOfDay],
    );
    final List<Map<String, Object?>> cravingRows = await _database.query(
      'craving_event',
      where: 'occurred_at >= ?',
      whereArgs: <Object?>[startOfDay],
    );
    final List<Map<String, Object?>> interventionRows = await _database.query(
      'intervention_event',
      where: 'occurred_at >= ?',
      whereArgs: <Object?>[startOfDay],
    );
    final List<Map<String, Object?>> latestSmokeRows = await _database.query(
      'smoke_event',
      orderBy: 'occurred_at DESC',
      limit: 1,
    );
    final List<Map<String, Object?>> latestSymptomRows = await _database.query(
      'symptom_log',
      orderBy: 'occurred_at DESC',
      limit: 1,
    );
    final List<Map<String, Object?>> latestContextRows = await _database.query(
      'context_snapshot',
      orderBy: 'captured_at DESC',
      limit: 12,
    );

    final int cigarettesToday = smokeRows.fold<int>(
      0,
      (int sum, Map<String, Object?> row) =>
          sum + ((row['cigarettes_count'] as int?) ?? 0),
    );
    final int resistedToday = cravingRows
        .where(
          (Map<String, Object?> row) =>
              (row['resolved_without_smoking'] as int?) == 1,
        )
        .length;
    final List<Map<String, Object?>> manualCravingRows = cravingRows.where((
      Map<String, Object?> row,
    ) {
      final String trigger = ((row['trigger_tag'] as String?) ?? '').trim();
      return trigger.isNotEmpty &&
          trigger != 'ambient' &&
          trigger != 'rescue_success' &&
          trigger != 'unspecified';
    }).toList();
    final int successfulInterventionsToday = interventionRows
        .where((Map<String, Object?> row) => (row['successful'] as int?) == 1)
        .length;
    final int manualCheckInsToday = manualCravingRows.length;
    final double averageStressToday = manualCravingRows.isEmpty
        ? 0
        : manualCravingRows.fold<double>(
                0,
                (double sum, Map<String, Object?> row) =>
                    sum + (((row['stress_level'] as int?) ?? 5).toDouble()),
              ) /
              manualCravingRows.length;
    final String? latestTriggerTag = manualCravingRows.isEmpty
        ? null
        : (manualCravingRows.first['trigger_tag'] as String?)?.trim().isEmpty ==
              true
        ? null
        : manualCravingRows.first['trigger_tag'] as String?;

    int? minutesSinceLastSmoke;
    if (latestSmokeRows.isNotEmpty) {
      final DateTime lastSmoke = DateTime.parse(
        latestSmokeRows.first['occurred_at']! as String,
      );
      minutesSinceLastSmoke = now.difference(lastSmoke).inMinutes;
    }

    bool healthAlertActive = false;
    if (latestSymptomRows.isNotEmpty) {
      final Map<String, Object?> row = latestSymptomRows.first;
      healthAlertActive =
          (row['blood_in_sputum'] as int?) == 1 ||
          ((row['breathlessness'] as int?) ?? 0) >= 7 ||
          (row['chest_pain'] as int?) == 1;
    }

    final String nextRiskWindowLabel =
        '${((now.hour + 1) % 24).toString().padLeft(2, '0')}:00';
    final Map<String, Object?>? latestContextRow = latestContextRows.isEmpty
        ? null
        : latestContextRows.first;
    final String currentClusterId =
        latestContextRow?['location_cluster_id'] as String? ?? '';
    int stationaryMinutes = 0;
    if (currentClusterId.isNotEmpty) {
      for (final Map<String, Object?> row in latestContextRows) {
        final String rowClusterId =
            (row['location_cluster_id'] as String?) ?? '';
        final double speed = (row['speed_kph'] as num?)?.toDouble() ?? 0;
        if (rowClusterId != currentClusterId || speed > 2.5) {
          break;
        }
        stationaryMinutes += 3;
      }
    }
    final String placeIdentityLabel = await _inferPlaceIdentity(
      latestContextRow,
    );

    return DashboardSummary(
      cigarettesToday: cigarettesToday,
      cravingsToday: cravingRows.length,
      resistedToday: resistedToday,
      manualCheckInsToday: manualCheckInsToday,
      successfulInterventionsToday: successfulInterventionsToday,
      minutesSinceLastSmoke: minutesSinceLastSmoke,
      nextRiskWindowLabel: nextRiskWindowLabel,
      healthAlertActive: healthAlertActive,
      latestTriggerTag: latestTriggerTag,
      averageStressToday: averageStressToday,
      placeIdentityLabel: placeIdentityLabel,
      stationaryMinutes: stationaryMinutes,
      dominantAppPackage:
          (latestContextRow?['dominant_app_package'] as String?) ?? '',
      shortVideoMinutes:
          (latestContextRow?['short_video_minutes'] as int?) ?? 0,
      socialMediaMinutes:
          (latestContextRow?['social_media_minutes'] as int?) ?? 0,
      messagingMinutes: (latestContextRow?['messaging_minutes'] as int?) ?? 0,
      appSwitchesLast30m:
          (latestContextRow?['app_switches_last_30m'] as int?) ?? 0,
      digitalDriftScore:
          (latestContextRow?['digital_drift_score'] as num?)?.toDouble() ?? 0,
    );
  }

  UserProfile _mapUserProfile(Map<String, Object?> row) {
    return UserProfile(
      id: row['id']! as int,
      createdAt: DateTime.parse(row['created_at']! as String),
      cigarettesPerDayBaseline: row['cigarettes_per_day_baseline']! as int,
      firstSmokeHour: row['first_smoke_hour']! as int,
      coffeeRiskEnabled: (row['coffee_risk_enabled']! as int) == 1,
      drivingRiskEnabled: (row['driving_risk_enabled']! as int) == 1,
      locationRiskEnabled: (row['location_risk_enabled']! as int) == 1,
      notificationAggression: (row['notification_aggression']! as num)
          .toDouble(),
      criticalThreshold: (row['critical_threshold']! as num).toDouble(),
      supportTone: SupportTone.values.firstWhere(
        (SupportTone value) => value.name == (row['support_tone'] as String?),
        orElse: () => SupportTone.balanced,
      ),
      preferredRescue: InterventionType.values.firstWhere(
        (InterventionType value) =>
            value.name == (row['preferred_rescue'] as String?),
        orElse: () => InterventionType.microCbt,
      ),
      reelsSensitivity: (row['reels_sensitivity'] as num?)?.toDouble() ?? 0.68,
      workStressSensitivity:
          (row['work_stress_sensitivity'] as num?)?.toDouble() ?? 0.64,
      boredomSensitivity:
          (row['boredom_sensitivity'] as num?)?.toDouble() ?? 0.58,
      adaptiveReelsBias:
          (row['adaptive_reels_bias'] as num?)?.toDouble() ?? 0.0,
      adaptiveStressBias:
          (row['adaptive_stress_bias'] as num?)?.toDouble() ?? 0.0,
      adaptiveBoredomBias:
          (row['adaptive_boredom_bias'] as num?)?.toDouble() ?? 0.0,
      adaptiveDriveBias:
          (row['adaptive_drive_bias'] as num?)?.toDouble() ?? 0.0,
      adaptationConfidence:
          (row['adaptation_confidence'] as num?)?.toDouble() ?? 0.0,
      lastAdaptedAt: (row['last_adapted_at'] as String?) == null
          ? null
          : DateTime.tryParse(row['last_adapted_at']! as String),
    );
  }

  MissionMemory _mapMissionMemory(Map<String, Object?> row) {
    return MissionMemory(
      id: (row['id'] as int?) ?? 0,
      missionId: row['mission_id']! as String,
      startedCount: (row['started_count'] as int?) ?? 0,
      successCount: (row['success_count'] as int?) ?? 0,
      failureCount: (row['failure_count'] as int?) ?? 0,
      currentStreak: (row['current_streak'] as int?) ?? 0,
      bestStreak: (row['best_streak'] as int?) ?? 0,
      momentumScore: (row['momentum_score'] as num?)?.toDouble() ?? 0.0,
      lastOutcome: (row['last_outcome'] as String?) ?? 'none',
      lastInterventionType: InterventionType.values.firstWhere(
        (InterventionType value) =>
            value.name == (row['last_intervention_type'] as String?),
        orElse: () => InterventionType.notificationOnly,
      ),
      lastUpdatedAt:
          DateTime.tryParse((row['last_updated_at'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  GuardedAudioTrainingSample _mapGuardedAudioTrainingSample(
    Map<String, Object?> row,
  ) {
    return GuardedAudioTrainingSample(
      id: (row['id'] as int?) ?? 0,
      capturedAt: DateTime.parse(row['captured_at']! as String),
      startedAt: (row['started_at'] as String?) == null
          ? null
          : DateTime.tryParse(row['started_at']! as String),
      endedAt: (row['ended_at'] as String?) == null
          ? null
          : DateTime.tryParse(row['ended_at']! as String),
      sessionDurationSeconds: (row['session_duration_seconds'] as int?) ?? 0,
      averageAmplitude: (row['average_amplitude'] as int?) ?? 0,
      peakAmplitude: (row['peak_amplitude'] as int?) ?? 0,
      lighterLikeSpikes: (row['lighter_like_spikes'] as int?) ?? 0,
      coughLikeBursts: (row['cough_like_bursts'] as int?) ?? 0,
      steadyBreathCycles: (row['steady_breath_cycles'] as int?) ?? 0,
      restlessnessBursts: (row['restlessness_bursts'] as int?) ?? 0,
      audioRiskScore: (row['audio_risk_score'] as int?) ?? 0,
      sampleCount: (row['sample_count'] as int?) ?? 0,
      predictedLabel: (row['predicted_label'] as String?) ?? 'ambient_or_unclear',
      predictedConfidence:
          (row['predicted_confidence'] as num?)?.toDouble() ?? 0.0,
      predictionSource: (row['prediction_source'] as String?) ?? 'unknown',
      recommendedAction: (row['recommended_action'] as String?) ?? 'observe',
      confirmedLabel: (row['confirmed_label'] as String?)?.trim().isEmpty ?? true
          ? null
          : (row['confirmed_label'] as String?)!.trim(),
    );
  }

  SmokeEvent _mapSmokeEvent(Map<String, Object?> row) {
    return SmokeEvent(
      id: row['id']! as int,
      occurredAt: DateTime.parse(row['occurred_at']! as String),
      cigarettesCount: row['cigarettes_count']! as int,
      triggerTag: row['trigger_tag']! as String,
      contextLabel: _sanitizeLegacyText(
        row['context_label']! as String,
        fallback: 'Legacy smoke context',
      ),
      stressLevel: row['stress_level']! as int,
      precededByPrediction: (row['preceded_by_prediction']! as int) == 1,
      predictedRiskScore: (row['predicted_risk_score']! as num).toDouble(),
      locationClusterId: row['location_cluster_id'] as String?,
    );
  }

  CravingEvent _mapCravingEvent(Map<String, Object?> row) {
    return CravingEvent(
      id: row['id']! as int,
      occurredAt: DateTime.parse(row['occurred_at']! as String),
      intensity: row['intensity']! as int,
      triggerTag: (row['trigger_tag'] as String?) ?? 'unspecified',
      stressLevel: (row['stress_level'] as int?) ?? 5,
      contextLabel: _sanitizeLegacyText(
        row['context_label']! as String,
        fallback: 'Legacy craving context',
      ),
      resolvedWithoutSmoking: (row['resolved_without_smoking']! as int) == 1,
      predicted: (row['predicted']! as int) == 1,
      durationSeconds: row['duration_seconds']! as int,
    );
  }

  SymptomLog _mapSymptomLog(Map<String, Object?> row) {
    return SymptomLog(
      id: row['id']! as int,
      occurredAt: DateTime.parse(row['occurred_at']! as String),
      coughSeverity: row['cough_severity']! as int,
      breathlessness: row['breathlessness']! as int,
      sputumSeverity: row['sputum_severity']! as int,
      bloodInSputum: (row['blood_in_sputum']! as int) == 1,
      chestPain: (row['chest_pain']! as int) == 1,
    );
  }

  InterventionEvent _mapInterventionEvent(Map<String, Object?> row) {
    return InterventionEvent(
      id: row['id']! as int,
      occurredAt: DateTime.parse(row['occurred_at']! as String),
      interventionType: InterventionType.values.firstWhere(
        (InterventionType type) => type.name == row['intervention_type'],
        orElse: () => InterventionType.notificationOnly,
      ),
      riskScore: (row['risk_score']! as num).toDouble(),
      accepted: (row['accepted']! as int) == 1,
      successful: (row['successful']! as int) == 1,
      contextLabel: _sanitizeLegacyText(
        row['context_label']! as String,
        fallback: 'Legacy intervention context',
      ),
    );
  }

  ContextSnapshot _mapContextSnapshot(Map<String, Object?> row) {
    return ContextSnapshot(
      id: row['id']! as int,
      capturedAt: DateTime.parse(row['captured_at']! as String),
      locationClusterId: row['location_cluster_id'] as String?,
      latitude: (row['latitude'] as num?)?.toDouble(),
      longitude: (row['longitude'] as num?)?.toDouble(),
      speedKph: (row['speed_kph']! as num).toDouble(),
      activityContext: ActivityContext.values.firstWhere(
        (ActivityContext type) => type.name == row['activity_context'],
        orElse: () => ActivityContext.unknown,
      ),
      bluetoothEnabled: (row['bluetooth_enabled']! as int) == 1,
      bluetoothBondedCount: row['bluetooth_bonded_count']! as int,
      bluetoothAudioConnected:
          ((row['bluetooth_audio_connected'] as int?) ?? 0) == 1,
      a2dpConnected: ((row['a2dp_connected'] as int?) ?? 0) == 1,
      headsetProfileConnected:
          ((row['headset_profile_connected'] as int?) ?? 0) == 1,
      carAudioRouteActive: ((row['car_audio_route_active'] as int?) ?? 0) == 1,
      wiredAudioRouteActive:
          ((row['wired_audio_route_active'] as int?) ?? 0) == 1,
      audioRouteKind: (row['audio_route_kind'] as String?) ?? 'unknown',
      vehicleContextScore:
          (row['vehicle_context_score'] as num?)?.toDouble() ?? 0,
      musicActive: ((row['music_active'] as int?) ?? 0) == 1,
      screenInteractive: (row['screen_interactive']! as int) == 1,
      powerSaveMode: (row['power_save_mode']! as int) == 1,
      charging: ((row['charging'] as int?) ?? 0) == 1,
      coffeeWindow: (row['coffee_window']! as int) == 1,
      driveCandidate: (row['drive_candidate']! as int) == 1,
      activityConfidence: (row['activity_confidence'] as num?)?.toDouble() ?? 0,
      activitySource: (row['activity_source'] as String?) ?? 'heuristic',
      usageAccessGranted: ((row['usage_access_granted'] as int?) ?? 0) == 1,
      dominantAppPackage: (row['dominant_app_package'] as String?) ?? '',
      dominantAppMinutes: (row['dominant_app_minutes'] as int?) ?? 0,
      shortVideoMinutes: (row['short_video_minutes'] as int?) ?? 0,
      socialMediaMinutes: (row['social_media_minutes'] as int?) ?? 0,
      messagingMinutes: (row['messaging_minutes'] as int?) ?? 0,
      appSwitchesLast30m: (row['app_switches_last_30m'] as int?) ?? 0,
      digitalDriftScore:
          (row['digital_drift_score'] as num?)?.toDouble() ?? 0,
    );
  }

  LabSettings _mapLabSettings(Map<String, Object?> row) {
    return LabSettings(
      id: row['id']! as int,
      geofencingEnabled: (row['geofencing_enabled']! as int) == 1,
      guardedAudioEnabled: (row['guarded_audio_enabled']! as int) == 1,
      healthGuardEnabled: (row['health_guard_enabled']! as int) == 1,
      backgroundInterventionsEnabled:
          (row['background_interventions_enabled']! as int) == 1,
      bluetoothContextEnabled: (row['bluetooth_context_enabled']! as int) == 1,
      activityInferenceEnabled:
          (row['activity_inference_enabled']! as int) == 1,
      followUpMinutes: row['follow_up_minutes']! as int,
      rescueDurationSeconds: row['rescue_duration_seconds']! as int,
      notificationCooldownMinutes: row['notification_cooldown_minutes']! as int,
    );
  }

  String _sanitizeLegacyText(String value, {required String fallback}) {
    if (value.contains('Ø') || value.contains('Ù')) {
      return fallback;
    }
    return value;
  }
  Future<String> _inferPlaceIdentity(Map<String, Object?>? latestContextRow) async {
    if (latestContextRow == null) {
      return 'unknown';
    }
    final String? clusterId = latestContextRow['location_cluster_id'] as String?;
    if (clusterId == null || clusterId.isEmpty) {
      return 'transient';
    }
    final List<Map<String, Object?>> rows = await _database.query(
      'context_snapshot',
      columns: <String>['captured_at'],
      where: 'location_cluster_id = ?',
      whereArgs: <Object?>[clusterId],
      orderBy: 'captured_at DESC',
      limit: 60,
    );
    final int occurrences = rows.length;
    if (occurrences <= 2) {
      return 'new_place';
    }
    int nightHits = 0;
    int dayHits = 0;
    for (final Map<String, Object?> row in rows) {
      final DateTime time = DateTime.parse(row['captured_at']! as String);
      if (time.hour >= 20 || time.hour <= 6) {
        nightHits += 1;
      }
      if (time.hour >= 8 && time.hour <= 16) {
        dayHits += 1;
      }
    }
    if (nightHits >= 8 && nightHits >= dayHits) {
      return 'home_like';
    }
    if (dayHits >= 8 && dayHits > nightHits) {
      return 'work_like';
    }
    if (occurrences >= 8) {
      return 'recurring_place';
    }
    return 'under_observation';
  }
}
