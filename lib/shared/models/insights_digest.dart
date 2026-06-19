class InsightsDigest {
  const InsightsDigest({
    required this.today,
    required this.week,
    required this.month,
    required this.hypotheses,
  });

  final InsightWindowSummary today;
  final InsightWindowSummary week;
  final InsightWindowSummary month;
  final List<BehaviorHypothesis> hypotheses;
}

class InsightWindowSummary {
  const InsightWindowSummary({
    required this.label,
    required this.smokeCount,
    required this.cravingCount,
    required this.rescueCount,
    required this.rescueWinRate,
    required this.resistedCount,
    required this.averageCravingIntensity,
    required this.topTrigger,
    required this.firstSmokeDelayMinutes,
  });

  final String label;
  final int smokeCount;
  final int cravingCount;
  final int rescueCount;
  final double rescueWinRate;
  final int resistedCount;
  final double averageCravingIntensity;
  final String topTrigger;
  final int? firstSmokeDelayMinutes;
}

class BehaviorHypothesis {
  const BehaviorHypothesis({
    required this.title,
    required this.detail,
    required this.status,
  });

  final String title;
  final String detail;
  final String status;
}
