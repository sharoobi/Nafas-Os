class GuardedAudioSession {
  const GuardedAudioSession({
    required this.active,
    required this.startedAt,
    required this.endsAt,
    required this.remainingSeconds,
    required this.averageAmplitude,
    required this.peakAmplitude,
    required this.lighterLikeSpikes,
    required this.coughLikeBursts,
    required this.steadyBreathCycles,
    required this.restlessnessBursts,
    required this.audioRiskScore,
    required this.sampleCount,
    required this.classificationLabel,
    required this.classificationConfidence,
    required this.recommendedAction,
    required this.classificationSource,
  });

  const GuardedAudioSession.inactive()
    : active = false,
      startedAt = null,
      endsAt = null,
      remainingSeconds = 0,
      averageAmplitude = 0,
      peakAmplitude = 0,
      lighterLikeSpikes = 0,
      coughLikeBursts = 0,
      steadyBreathCycles = 0,
      restlessnessBursts = 0,
      audioRiskScore = 0,
      sampleCount = 0,
      classificationLabel = 'inactive',
      classificationConfidence = 0,
      recommendedAction = 'no_action',
      classificationSource = 'none';

  final bool active;
  final DateTime? startedAt;
  final DateTime? endsAt;
  final int remainingSeconds;
  final int averageAmplitude;
  final int peakAmplitude;
  final int lighterLikeSpikes;
  final int coughLikeBursts;
  final int steadyBreathCycles;
  final int restlessnessBursts;
  final int audioRiskScore;
  final int sampleCount;
  final String classificationLabel;
  final double classificationConfidence;
  final String recommendedAction;
  final String classificationSource;
}
