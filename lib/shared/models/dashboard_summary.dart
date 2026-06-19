class DashboardSummary {
  const DashboardSummary({
    required this.cigarettesToday,
    required this.cravingsToday,
    required this.resistedToday,
    required this.manualCheckInsToday,
    required this.successfulInterventionsToday,
    required this.minutesSinceLastSmoke,
    required this.nextRiskWindowLabel,
    required this.healthAlertActive,
    required this.latestTriggerTag,
    required this.averageStressToday,
    required this.placeIdentityLabel,
    required this.stationaryMinutes,
    required this.dominantAppPackage,
    required this.shortVideoMinutes,
    required this.socialMediaMinutes,
    required this.messagingMinutes,
    required this.appSwitchesLast30m,
    required this.digitalDriftScore,
  });

  final int cigarettesToday;
  final int cravingsToday;
  final int resistedToday;
  final int manualCheckInsToday;
  final int successfulInterventionsToday;
  final int? minutesSinceLastSmoke;
  final String nextRiskWindowLabel;
  final bool healthAlertActive;
  final String? latestTriggerTag;
  final double averageStressToday;
  final String placeIdentityLabel;
  final int stationaryMinutes;
  final String dominantAppPackage;
  final int shortVideoMinutes;
  final int socialMediaMinutes;
  final int messagingMinutes;
  final int appSwitchesLast30m;
  final double digitalDriftScore;
}
