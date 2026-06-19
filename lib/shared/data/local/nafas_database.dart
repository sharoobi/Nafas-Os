import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

final nafasDatabaseProvider = FutureProvider<Database>((Ref ref) async {
  final String databasesDirectory = await getDatabasesPath();
  final String databasePath = p.join(databasesDirectory, 'nafas_os.db');

  return openDatabase(
    databasePath,
    version: 8,
    onCreate: (Database db, int version) async {
      await db.execute('''
        CREATE TABLE user_profile (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          created_at TEXT NOT NULL,
          cigarettes_per_day_baseline INTEGER NOT NULL,
          first_smoke_hour INTEGER NOT NULL,
          coffee_risk_enabled INTEGER NOT NULL,
          driving_risk_enabled INTEGER NOT NULL,
          location_risk_enabled INTEGER NOT NULL,
          notification_aggression REAL NOT NULL,
          critical_threshold REAL NOT NULL,
          support_tone TEXT NOT NULL DEFAULT 'balanced',
          preferred_rescue TEXT NOT NULL DEFAULT 'breathing',
          reels_sensitivity REAL NOT NULL DEFAULT 0.68,
          work_stress_sensitivity REAL NOT NULL DEFAULT 0.64,
          boredom_sensitivity REAL NOT NULL DEFAULT 0.58,
          adaptive_reels_bias REAL NOT NULL DEFAULT 0.0,
          adaptive_stress_bias REAL NOT NULL DEFAULT 0.0,
          adaptive_boredom_bias REAL NOT NULL DEFAULT 0.0,
          adaptive_drive_bias REAL NOT NULL DEFAULT 0.0,
          adaptation_confidence REAL NOT NULL DEFAULT 0.0,
          last_adapted_at TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE smoke_event (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          occurred_at TEXT NOT NULL,
          cigarettes_count INTEGER NOT NULL,
          trigger_tag TEXT NOT NULL,
          context_label TEXT NOT NULL,
          stress_level INTEGER NOT NULL,
          preceded_by_prediction INTEGER NOT NULL,
          predicted_risk_score REAL NOT NULL,
          location_cluster_id TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE craving_event (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          occurred_at TEXT NOT NULL,
          intensity INTEGER NOT NULL,
          trigger_tag TEXT NOT NULL,
          stress_level INTEGER NOT NULL,
          context_label TEXT NOT NULL,
          resolved_without_smoking INTEGER NOT NULL,
          predicted INTEGER NOT NULL,
          duration_seconds INTEGER NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE symptom_log (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          occurred_at TEXT NOT NULL,
          cough_severity INTEGER NOT NULL,
          breathlessness INTEGER NOT NULL,
          sputum_severity INTEGER NOT NULL,
          blood_in_sputum INTEGER NOT NULL,
          chest_pain INTEGER NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE intervention_event (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          occurred_at TEXT NOT NULL,
          intervention_type TEXT NOT NULL,
          risk_score REAL NOT NULL,
          accepted INTEGER NOT NULL,
          successful INTEGER NOT NULL,
          context_label TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE lab_settings (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          geofencing_enabled INTEGER NOT NULL,
          guarded_audio_enabled INTEGER NOT NULL,
          health_guard_enabled INTEGER NOT NULL,
          background_interventions_enabled INTEGER NOT NULL,
          bluetooth_context_enabled INTEGER NOT NULL,
          activity_inference_enabled INTEGER NOT NULL,
          follow_up_minutes INTEGER NOT NULL,
          rescue_duration_seconds INTEGER NOT NULL,
          notification_cooldown_minutes INTEGER NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE context_snapshot (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          captured_at TEXT NOT NULL,
          location_cluster_id TEXT,
          latitude REAL,
          longitude REAL,
          speed_kph REAL NOT NULL,
          activity_context TEXT NOT NULL,
          bluetooth_enabled INTEGER NOT NULL,
          bluetooth_bonded_count INTEGER NOT NULL,
          bluetooth_audio_connected INTEGER NOT NULL,
          a2dp_connected INTEGER NOT NULL DEFAULT 0,
          headset_profile_connected INTEGER NOT NULL DEFAULT 0,
          car_audio_route_active INTEGER NOT NULL DEFAULT 0,
          wired_audio_route_active INTEGER NOT NULL DEFAULT 0,
          audio_route_kind TEXT NOT NULL DEFAULT 'unknown',
          vehicle_context_score REAL NOT NULL DEFAULT 0,
          music_active INTEGER NOT NULL,
          screen_interactive INTEGER NOT NULL,
          power_save_mode INTEGER NOT NULL,
          charging INTEGER NOT NULL,
          coffee_window INTEGER NOT NULL,
          drive_candidate INTEGER NOT NULL,
          activity_confidence REAL NOT NULL DEFAULT 0,
          activity_source TEXT NOT NULL DEFAULT 'heuristic',
          usage_access_granted INTEGER NOT NULL DEFAULT 0,
          dominant_app_package TEXT NOT NULL DEFAULT '',
          dominant_app_minutes INTEGER NOT NULL DEFAULT 0,
          short_video_minutes INTEGER NOT NULL DEFAULT 0,
          social_media_minutes INTEGER NOT NULL DEFAULT 0,
          messaging_minutes INTEGER NOT NULL DEFAULT 0,
          app_switches_last_30m INTEGER NOT NULL DEFAULT 0,
          digital_drift_score REAL NOT NULL DEFAULT 0
        )
      ''');
      await db.execute('''
        CREATE TABLE mission_memory (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          mission_id TEXT NOT NULL UNIQUE,
          started_count INTEGER NOT NULL DEFAULT 0,
          success_count INTEGER NOT NULL DEFAULT 0,
          failure_count INTEGER NOT NULL DEFAULT 0,
          current_streak INTEGER NOT NULL DEFAULT 0,
          best_streak INTEGER NOT NULL DEFAULT 0,
          momentum_score REAL NOT NULL DEFAULT 0,
          last_outcome TEXT NOT NULL DEFAULT 'none',
          last_intervention_type TEXT NOT NULL DEFAULT 'notificationOnly',
          last_updated_at TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE guarded_audio_training_sample (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          captured_at TEXT NOT NULL,
          started_at TEXT,
          ended_at TEXT,
          session_duration_seconds INTEGER NOT NULL DEFAULT 0,
          average_amplitude INTEGER NOT NULL,
          peak_amplitude INTEGER NOT NULL,
          lighter_like_spikes INTEGER NOT NULL,
          cough_like_bursts INTEGER NOT NULL,
          steady_breath_cycles INTEGER NOT NULL,
          restlessness_bursts INTEGER NOT NULL,
          audio_risk_score INTEGER NOT NULL,
          sample_count INTEGER NOT NULL,
          predicted_label TEXT NOT NULL,
          predicted_confidence REAL NOT NULL,
          prediction_source TEXT NOT NULL,
          recommended_action TEXT NOT NULL,
          confirmed_label TEXT
        )
      ''');
    },
    onUpgrade: (Database db, int oldVersion, int newVersion) async {
      if (oldVersion < 2) {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS lab_settings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            geofencing_enabled INTEGER NOT NULL,
            guarded_audio_enabled INTEGER NOT NULL,
            health_guard_enabled INTEGER NOT NULL,
            background_interventions_enabled INTEGER NOT NULL,
            bluetooth_context_enabled INTEGER NOT NULL,
            activity_inference_enabled INTEGER NOT NULL,
            follow_up_minutes INTEGER NOT NULL,
            rescue_duration_seconds INTEGER NOT NULL,
            notification_cooldown_minutes INTEGER NOT NULL
          )
        ''');
        await db.execute(
          'ALTER TABLE context_snapshot ADD COLUMN bluetooth_audio_connected INTEGER NOT NULL DEFAULT 0',
        );
        await db.execute(
          'ALTER TABLE context_snapshot ADD COLUMN music_active INTEGER NOT NULL DEFAULT 0',
        );
        await db.execute(
          'ALTER TABLE context_snapshot ADD COLUMN charging INTEGER NOT NULL DEFAULT 0',
        );
      }
      if (oldVersion < 3) {
        await db.execute(
          "ALTER TABLE craving_event ADD COLUMN trigger_tag TEXT NOT NULL DEFAULT 'unspecified'",
        );
        await db.execute(
          'ALTER TABLE craving_event ADD COLUMN stress_level INTEGER NOT NULL DEFAULT 5',
        );
      }
      if (oldVersion < 4) {
        await db.execute(
          'ALTER TABLE context_snapshot ADD COLUMN a2dp_connected INTEGER NOT NULL DEFAULT 0',
        );
        await db.execute(
          'ALTER TABLE context_snapshot ADD COLUMN headset_profile_connected INTEGER NOT NULL DEFAULT 0',
        );
        await db.execute(
          'ALTER TABLE context_snapshot ADD COLUMN car_audio_route_active INTEGER NOT NULL DEFAULT 0',
        );
        await db.execute(
          'ALTER TABLE context_snapshot ADD COLUMN wired_audio_route_active INTEGER NOT NULL DEFAULT 0',
        );
        await db.execute(
          "ALTER TABLE context_snapshot ADD COLUMN audio_route_kind TEXT NOT NULL DEFAULT 'unknown'",
        );
        await db.execute(
          'ALTER TABLE context_snapshot ADD COLUMN vehicle_context_score REAL NOT NULL DEFAULT 0',
        );
        await db.execute(
          'ALTER TABLE context_snapshot ADD COLUMN activity_confidence REAL NOT NULL DEFAULT 0',
        );
        await db.execute(
          "ALTER TABLE context_snapshot ADD COLUMN activity_source TEXT NOT NULL DEFAULT 'heuristic'",
        );
      }
      if (oldVersion < 5) {
        await db.execute(
          'ALTER TABLE context_snapshot ADD COLUMN usage_access_granted INTEGER NOT NULL DEFAULT 0',
        );
        await db.execute(
          "ALTER TABLE context_snapshot ADD COLUMN dominant_app_package TEXT NOT NULL DEFAULT ''",
        );
        await db.execute(
          'ALTER TABLE context_snapshot ADD COLUMN dominant_app_minutes INTEGER NOT NULL DEFAULT 0',
        );
        await db.execute(
          'ALTER TABLE context_snapshot ADD COLUMN short_video_minutes INTEGER NOT NULL DEFAULT 0',
        );
        await db.execute(
          'ALTER TABLE context_snapshot ADD COLUMN social_media_minutes INTEGER NOT NULL DEFAULT 0',
        );
        await db.execute(
          'ALTER TABLE context_snapshot ADD COLUMN messaging_minutes INTEGER NOT NULL DEFAULT 0',
        );
        await db.execute(
          'ALTER TABLE context_snapshot ADD COLUMN app_switches_last_30m INTEGER NOT NULL DEFAULT 0',
        );
        await db.execute(
          'ALTER TABLE context_snapshot ADD COLUMN digital_drift_score REAL NOT NULL DEFAULT 0',
        );
      }
      if (oldVersion < 6) {
        await db.execute(
          "ALTER TABLE user_profile ADD COLUMN support_tone TEXT NOT NULL DEFAULT 'balanced'",
        );
        await db.execute(
          "ALTER TABLE user_profile ADD COLUMN preferred_rescue TEXT NOT NULL DEFAULT 'breathing'",
        );
        await db.execute(
          'ALTER TABLE user_profile ADD COLUMN reels_sensitivity REAL NOT NULL DEFAULT 0.68',
        );
        await db.execute(
          'ALTER TABLE user_profile ADD COLUMN work_stress_sensitivity REAL NOT NULL DEFAULT 0.64',
        );
        await db.execute(
          'ALTER TABLE user_profile ADD COLUMN boredom_sensitivity REAL NOT NULL DEFAULT 0.58',
        );
      }
      if (oldVersion < 7) {
        await db.execute(
          'ALTER TABLE user_profile ADD COLUMN adaptive_reels_bias REAL NOT NULL DEFAULT 0.0',
        );
        await db.execute(
          'ALTER TABLE user_profile ADD COLUMN adaptive_stress_bias REAL NOT NULL DEFAULT 0.0',
        );
        await db.execute(
          'ALTER TABLE user_profile ADD COLUMN adaptive_boredom_bias REAL NOT NULL DEFAULT 0.0',
        );
        await db.execute(
          'ALTER TABLE user_profile ADD COLUMN adaptive_drive_bias REAL NOT NULL DEFAULT 0.0',
        );
        await db.execute(
          'ALTER TABLE user_profile ADD COLUMN adaptation_confidence REAL NOT NULL DEFAULT 0.0',
        );
        await db.execute(
          'ALTER TABLE user_profile ADD COLUMN last_adapted_at TEXT',
        );
        await db.execute('''
          CREATE TABLE IF NOT EXISTS mission_memory (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            mission_id TEXT NOT NULL UNIQUE,
            started_count INTEGER NOT NULL DEFAULT 0,
            success_count INTEGER NOT NULL DEFAULT 0,
            failure_count INTEGER NOT NULL DEFAULT 0,
            current_streak INTEGER NOT NULL DEFAULT 0,
            best_streak INTEGER NOT NULL DEFAULT 0,
            momentum_score REAL NOT NULL DEFAULT 0,
            last_outcome TEXT NOT NULL DEFAULT 'none',
            last_intervention_type TEXT NOT NULL DEFAULT 'notificationOnly',
            last_updated_at TEXT NOT NULL
          )
        ''');
      }
      if (oldVersion < 8) {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS guarded_audio_training_sample (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            captured_at TEXT NOT NULL,
            started_at TEXT,
            ended_at TEXT,
            session_duration_seconds INTEGER NOT NULL DEFAULT 0,
            average_amplitude INTEGER NOT NULL,
            peak_amplitude INTEGER NOT NULL,
            lighter_like_spikes INTEGER NOT NULL,
            cough_like_bursts INTEGER NOT NULL,
            steady_breath_cycles INTEGER NOT NULL,
            restlessness_bursts INTEGER NOT NULL,
            audio_risk_score INTEGER NOT NULL,
            sample_count INTEGER NOT NULL,
            predicted_label TEXT NOT NULL,
            predicted_confidence REAL NOT NULL,
            prediction_source TEXT NOT NULL,
            recommended_action TEXT NOT NULL,
            confirmed_label TEXT
          )
        ''');
      }
    },
  );
});
