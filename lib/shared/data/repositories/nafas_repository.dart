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

abstract class NafasRepository {
  Future<UserProfile> ensureProfile();
  Future<UserProfile> saveProfile(UserProfile profile);
  Future<LabSettings> ensureLabSettings();
  Future<LabSettings> saveLabSettings(LabSettings settings);
  Future<void> addSmokeEvent(SmokeEvent event);
  Future<void> addCravingEvent(CravingEvent event);
  Future<void> addSymptomLog(SymptomLog log);
  Future<void> addInterventionEvent(InterventionEvent event);
  Future<void> addContextSnapshot(ContextSnapshot snapshot);
  Future<List<SmokeEvent>> recentSmokeEvents({int limit = 20});
  Future<List<CravingEvent>> recentCravingEvents({int limit = 20});
  Future<List<SymptomLog>> recentSymptomLogs({int limit = 20});
  Future<List<InterventionEvent>> recentInterventions({int limit = 20});
  Future<List<ContextSnapshot>> recentContextSnapshots({int limit = 20});
  Future<List<SmokeEvent>> smokeEventsSince(DateTime since, {int limit = 500});
  Future<List<CravingEvent>> cravingEventsSince(
    DateTime since, {
    int limit = 500,
  });
  Future<List<InterventionEvent>> interventionsSince(
    DateTime since, {
    int limit = 500,
  });
  Future<List<ContextSnapshot>> contextSnapshotsSince(
    DateTime since, {
    int limit = 500,
  });
  Future<List<MissionMemory>> missionMemories();
  Future<MissionMemory> upsertMissionMemory(MissionMemory memory);
  Future<void> addGuardedAudioTrainingSample(GuardedAudioTrainingSample sample);
  Future<List<GuardedAudioTrainingSample>> recentGuardedAudioTrainingSamples({
    int limit = 20,
  });
  Future<GuardedAudioTrainingSample?> latestGuardedAudioTrainingSample();
  Future<GuardedAudioTrainingSample?> updateGuardedAudioTrainingSampleLabel({
    required int id,
    required String confirmedLabel,
  });
  Future<int> countGuardedAudioTrainingSamples({bool labeledOnly = false});
  Future<ContextSnapshot?> latestContextSnapshot();
  Future<DashboardSummary> buildSummary();
}
