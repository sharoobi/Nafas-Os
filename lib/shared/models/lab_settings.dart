class LabSettings {
  const LabSettings({
    required this.id,
    required this.geofencingEnabled,
    required this.guardedAudioEnabled,
    required this.healthGuardEnabled,
    required this.backgroundInterventionsEnabled,
    required this.bluetoothContextEnabled,
    required this.activityInferenceEnabled,
    required this.followUpMinutes,
    required this.rescueDurationSeconds,
    required this.notificationCooldownMinutes,
  });

  final int id;
  final bool geofencingEnabled;
  final bool guardedAudioEnabled;
  final bool healthGuardEnabled;
  final bool backgroundInterventionsEnabled;
  final bool bluetoothContextEnabled;
  final bool activityInferenceEnabled;
  final int followUpMinutes;
  final int rescueDurationSeconds;
  final int notificationCooldownMinutes;

  static const LabSettings defaults = LabSettings(
    id: 1,
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

  LabSettings copyWith({
    int? id,
    bool? geofencingEnabled,
    bool? guardedAudioEnabled,
    bool? healthGuardEnabled,
    bool? backgroundInterventionsEnabled,
    bool? bluetoothContextEnabled,
    bool? activityInferenceEnabled,
    int? followUpMinutes,
    int? rescueDurationSeconds,
    int? notificationCooldownMinutes,
  }) {
    return LabSettings(
      id: id ?? this.id,
      geofencingEnabled: geofencingEnabled ?? this.geofencingEnabled,
      guardedAudioEnabled: guardedAudioEnabled ?? this.guardedAudioEnabled,
      healthGuardEnabled: healthGuardEnabled ?? this.healthGuardEnabled,
      backgroundInterventionsEnabled:
          backgroundInterventionsEnabled ?? this.backgroundInterventionsEnabled,
      bluetoothContextEnabled:
          bluetoothContextEnabled ?? this.bluetoothContextEnabled,
      activityInferenceEnabled:
          activityInferenceEnabled ?? this.activityInferenceEnabled,
      followUpMinutes: followUpMinutes ?? this.followUpMinutes,
      rescueDurationSeconds:
          rescueDurationSeconds ?? this.rescueDurationSeconds,
      notificationCooldownMinutes:
          notificationCooldownMinutes ?? this.notificationCooldownMinutes,
    );
  }
}
