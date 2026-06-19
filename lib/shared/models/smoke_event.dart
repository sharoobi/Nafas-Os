class SmokeEvent {
  const SmokeEvent({
    required this.id,
    required this.occurredAt,
    required this.cigarettesCount,
    required this.triggerTag,
    required this.contextLabel,
    required this.stressLevel,
    required this.precededByPrediction,
    required this.predictedRiskScore,
    required this.locationClusterId,
  });

  final int id;
  final DateTime occurredAt;
  final int cigarettesCount;
  final String triggerTag;
  final String contextLabel;
  final int stressLevel;
  final bool precededByPrediction;
  final double predictedRiskScore;
  final String? locationClusterId;
}
