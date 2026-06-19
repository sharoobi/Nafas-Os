import 'package:nafas_os/shared/models/app_enums.dart';

class MissionMemory {
  const MissionMemory({
    required this.id,
    required this.missionId,
    required this.startedCount,
    required this.successCount,
    required this.failureCount,
    required this.currentStreak,
    required this.bestStreak,
    required this.momentumScore,
    required this.lastOutcome,
    required this.lastInterventionType,
    required this.lastUpdatedAt,
  });

  final int id;
  final String missionId;
  final int startedCount;
  final int successCount;
  final int failureCount;
  final int currentStreak;
  final int bestStreak;
  final double momentumScore;
  final String lastOutcome;
  final InterventionType lastInterventionType;
  final DateTime lastUpdatedAt;

  double get successRate {
    if (startedCount <= 0) {
      return 0;
    }
    return (successCount / startedCount).clamp(0.0, 1.0);
  }

  MissionMemory copyWith({
    int? id,
    String? missionId,
    int? startedCount,
    int? successCount,
    int? failureCount,
    int? currentStreak,
    int? bestStreak,
    double? momentumScore,
    String? lastOutcome,
    InterventionType? lastInterventionType,
    DateTime? lastUpdatedAt,
  }) {
    return MissionMemory(
      id: id ?? this.id,
      missionId: missionId ?? this.missionId,
      startedCount: startedCount ?? this.startedCount,
      successCount: successCount ?? this.successCount,
      failureCount: failureCount ?? this.failureCount,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      momentumScore: momentumScore ?? this.momentumScore,
      lastOutcome: lastOutcome ?? this.lastOutcome,
      lastInterventionType: lastInterventionType ?? this.lastInterventionType,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }
}
