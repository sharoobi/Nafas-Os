class CravingEvent {
  const CravingEvent({
    required this.id,
    required this.occurredAt,
    required this.intensity,
    required this.triggerTag,
    required this.stressLevel,
    required this.contextLabel,
    required this.resolvedWithoutSmoking,
    required this.predicted,
    required this.durationSeconds,
  });

  final int id;
  final DateTime occurredAt;
  final int intensity;
  final String triggerTag;
  final int stressLevel;
  final String contextLabel;
  final bool resolvedWithoutSmoking;
  final bool predicted;
  final int durationSeconds;
}
