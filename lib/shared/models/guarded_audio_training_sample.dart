class GuardedAudioTrainingSample {
  const GuardedAudioTrainingSample({
    required this.id,
    required this.capturedAt,
    required this.startedAt,
    required this.endedAt,
    required this.sessionDurationSeconds,
    required this.averageAmplitude,
    required this.peakAmplitude,
    required this.lighterLikeSpikes,
    required this.coughLikeBursts,
    required this.steadyBreathCycles,
    required this.restlessnessBursts,
    required this.audioRiskScore,
    required this.sampleCount,
    required this.predictedLabel,
    required this.predictedConfidence,
    required this.predictionSource,
    required this.recommendedAction,
    required this.confirmedLabel,
  });

  final int id;
  final DateTime capturedAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int sessionDurationSeconds;
  final int averageAmplitude;
  final int peakAmplitude;
  final int lighterLikeSpikes;
  final int coughLikeBursts;
  final int steadyBreathCycles;
  final int restlessnessBursts;
  final int audioRiskScore;
  final int sampleCount;
  final String predictedLabel;
  final double predictedConfidence;
  final String predictionSource;
  final String recommendedAction;
  final String? confirmedLabel;

  bool get isLabeled => confirmedLabel != null && confirmedLabel!.isNotEmpty;

  List<double> get featureVector {
    return <double>[
      (audioRiskScore / 100.0).clamp(0.0, 1.0),
      (lighterLikeSpikes / 6.0).clamp(0.0, 1.0),
      (coughLikeBursts / 6.0).clamp(0.0, 1.0),
      (steadyBreathCycles / 8.0).clamp(0.0, 1.0),
      (restlessnessBursts / 8.0).clamp(0.0, 1.0),
      (averageAmplitude / 32768.0).clamp(0.0, 1.0),
      (peakAmplitude / 32768.0).clamp(0.0, 1.0),
      (sampleCount / 32.0).clamp(0.0, 1.0),
    ];
  }

  GuardedAudioTrainingSample copyWith({
    int? id,
    DateTime? capturedAt,
    DateTime? startedAt,
    DateTime? endedAt,
    int? sessionDurationSeconds,
    int? averageAmplitude,
    int? peakAmplitude,
    int? lighterLikeSpikes,
    int? coughLikeBursts,
    int? steadyBreathCycles,
    int? restlessnessBursts,
    int? audioRiskScore,
    int? sampleCount,
    String? predictedLabel,
    double? predictedConfidence,
    String? predictionSource,
    String? recommendedAction,
    String? confirmedLabel,
    bool clearConfirmedLabel = false,
  }) {
    return GuardedAudioTrainingSample(
      id: id ?? this.id,
      capturedAt: capturedAt ?? this.capturedAt,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      sessionDurationSeconds:
          sessionDurationSeconds ?? this.sessionDurationSeconds,
      averageAmplitude: averageAmplitude ?? this.averageAmplitude,
      peakAmplitude: peakAmplitude ?? this.peakAmplitude,
      lighterLikeSpikes: lighterLikeSpikes ?? this.lighterLikeSpikes,
      coughLikeBursts: coughLikeBursts ?? this.coughLikeBursts,
      steadyBreathCycles: steadyBreathCycles ?? this.steadyBreathCycles,
      restlessnessBursts: restlessnessBursts ?? this.restlessnessBursts,
      audioRiskScore: audioRiskScore ?? this.audioRiskScore,
      sampleCount: sampleCount ?? this.sampleCount,
      predictedLabel: predictedLabel ?? this.predictedLabel,
      predictedConfidence: predictedConfidence ?? this.predictedConfidence,
      predictionSource: predictionSource ?? this.predictionSource,
      recommendedAction: recommendedAction ?? this.recommendedAction,
      confirmedLabel: clearConfirmedLabel
          ? null
          : confirmedLabel ?? this.confirmedLabel,
    );
  }
}
