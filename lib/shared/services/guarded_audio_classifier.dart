import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class GuardedAudioClassification {
  const GuardedAudioClassification({
    required this.label,
    required this.confidence,
    required this.recommendedAction,
    required this.source,
  });

  final String label;
  final double confidence;
  final String recommendedAction;
  final String source;
}

final guardedAudioClassifierProvider = Provider<GuardedAudioClassifier>(
  (Ref ref) => GuardedAudioClassifier(),
);

class GuardedAudioClassifier {
  GuardedAudioClassifier();

  static const String _modelAsset =
      'assets/models/guarded_audio_classifier.tflite';
  static const List<String> _labels = <String>[
    'warming_up',
    'lighter_like_pattern',
    'restless_window',
    'steady_breathing',
    'cough_stress',
    'high_arousal_audio',
    'ambient_or_unclear',
  ];

  Interpreter? _interpreter;
  bool _loadAttempted = false;

  Future<GuardedAudioClassification> classify(
    Map<String, dynamic> status,
  ) async {
    final int samples = (status['sampleCount'] as int?) ?? 0;
    if (samples < 3) {
      return const GuardedAudioClassification(
        label: 'warming_up',
        confidence: 0.22,
        recommendedAction: 'keep_listening',
        source: 'warmup',
      );
    }

    final Interpreter? interpreter = await _ensureInterpreter();
    if (interpreter == null) {
      return _heuristicClassification(status);
    }

    try {
      final List<List<double>> input = <List<double>>[_featureVector(status)];
      final List<List<double>> output = <List<double>>[
        List<double>.filled(_labels.length, 0.0),
      ];
      interpreter.run(input, output);

      final List<double> probabilities = output.first;
      if (probabilities.every((double value) => value == 0.0)) {
        return _heuristicClassification(status);
      }
      int bestIndex = 0;
      double bestValue = probabilities.first;
      for (int index = 1; index < probabilities.length; index += 1) {
        if (probabilities[index] > bestValue) {
          bestValue = probabilities[index];
          bestIndex = index;
        }
      }
      final String label = _labels[bestIndex];
      return GuardedAudioClassification(
        label: label,
        confidence: bestValue.clamp(0.0, 0.99),
        recommendedAction: _recommendedAction(label),
        source: 'tflite',
      );
    } catch (_) {
      return _heuristicClassification(status);
    }
  }

  Future<Interpreter?> _ensureInterpreter() async {
    if (_interpreter != null) {
      return _interpreter;
    }
    if (_loadAttempted) {
      return null;
    }
    _loadAttempted = true;
    try {
      _interpreter = await Interpreter.fromAsset(_modelAsset);
      return _interpreter;
    } catch (_) {
      return null;
    }
  }

  List<double> _featureVector(Map<String, dynamic> status) {
    final double audioRisk = ((status['audioRiskScore'] as int?) ?? 0) / 100.0;
    final double lighter = ((status['lighterLikeSpikes'] as int?) ?? 0) / 6.0;
    final double cough = ((status['coughLikeBursts'] as int?) ?? 0) / 6.0;
    final double breath = ((status['steadyBreathCycles'] as int?) ?? 0) / 8.0;
    final double restless =
        ((status['restlessnessBursts'] as int?) ?? 0) / 8.0;
    final double averageAmplitude =
        ((status['averageAmplitude'] as int?) ?? 0) / 32768.0;
    final double peakAmplitude =
        ((status['peakAmplitude'] as int?) ?? 0) / 32768.0;
    final double sampleCount = ((status['sampleCount'] as int?) ?? 0) / 32.0;

    return <double>[
      audioRisk.clamp(0.0, 1.0),
      lighter.clamp(0.0, 1.0),
      cough.clamp(0.0, 1.0),
      breath.clamp(0.0, 1.0),
      restless.clamp(0.0, 1.0),
      averageAmplitude.clamp(0.0, 1.0),
      peakAmplitude.clamp(0.0, 1.0),
      sampleCount.clamp(0.0, 1.0),
    ];
  }

  GuardedAudioClassification _heuristicClassification(
    Map<String, dynamic> status,
  ) {
    final int risk = (status['audioRiskScore'] as int?) ?? 0;
    final int lighter = (status['lighterLikeSpikes'] as int?) ?? 0;
    final int cough = (status['coughLikeBursts'] as int?) ?? 0;
    final int breath = (status['steadyBreathCycles'] as int?) ?? 0;
    final int restless = (status['restlessnessBursts'] as int?) ?? 0;
    final int samples = (status['sampleCount'] as int?) ?? 0;

    if (samples < 3) {
      return const GuardedAudioClassification(
        label: 'warming_up',
        confidence: 0.22,
        recommendedAction: 'keep_listening',
        source: 'heuristic',
      );
    }

    if (lighter >= 2 && risk >= 45) {
      final double confidence = ((0.55 + (lighter * 0.12)) + (risk / 250))
          .clamp(0.0, 0.98);
      return GuardedAudioClassification(
        label: 'lighter_like_pattern',
        confidence: confidence,
        recommendedAction: 'mirror_interrupt',
        source: 'heuristic',
      );
    }

    if (restless >= 3 && breath <= 1 && risk >= 30) {
      final double confidence = ((0.48 + (restless * 0.08)) + (risk / 300))
          .clamp(0.0, 0.94);
      return GuardedAudioClassification(
        label: 'restless_window',
        confidence: confidence,
        recommendedAction: 'micro_reset',
        source: 'heuristic',
      );
    }

    if (breath >= 4 && risk <= 35) {
      final double confidence = ((0.44 + (breath * 0.07)) - (risk / 500))
          .clamp(0.0, 0.9);
      return GuardedAudioClassification(
        label: 'steady_breathing',
        confidence: confidence,
        recommendedAction: 'continue_breathing',
        source: 'heuristic',
      );
    }

    if (cough >= 2) {
      final double confidence = ((0.38 + (cough * 0.1)) + (risk / 400))
          .clamp(0.0, 0.9);
      return GuardedAudioClassification(
        label: 'cough_stress',
        confidence: confidence,
        recommendedAction: 'health_guard',
        source: 'heuristic',
      );
    }

    if (risk >= 55) {
      return GuardedAudioClassification(
        label: 'high_arousal_audio',
        confidence: (0.52 + (risk / 220)).clamp(0.0, 0.95),
        recommendedAction: 'rescue_now',
        source: 'heuristic',
      );
    }

    return GuardedAudioClassification(
      label: 'ambient_or_unclear',
      confidence: (0.3 + (samples / 40)).clamp(0.0, 0.72),
      recommendedAction: 'observe',
      source: 'heuristic',
    );
  }

  String _recommendedAction(String label) {
    return switch (label) {
      'warming_up' => 'keep_listening',
      'lighter_like_pattern' => 'mirror_interrupt',
      'restless_window' => 'micro_reset',
      'steady_breathing' => 'continue_breathing',
      'cough_stress' => 'health_guard',
      'high_arousal_audio' => 'rescue_now',
      _ => 'observe',
    };
  }
}
