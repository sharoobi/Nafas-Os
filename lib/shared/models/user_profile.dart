import 'package:nafas_os/shared/models/app_enums.dart';

class UserProfile {
  const UserProfile({
    required this.id,
    required this.createdAt,
    required this.cigarettesPerDayBaseline,
    required this.firstSmokeHour,
    required this.coffeeRiskEnabled,
    required this.drivingRiskEnabled,
    required this.locationRiskEnabled,
    required this.notificationAggression,
    required this.criticalThreshold,
    required this.supportTone,
    required this.preferredRescue,
    required this.reelsSensitivity,
    required this.workStressSensitivity,
    required this.boredomSensitivity,
    required this.adaptiveReelsBias,
    required this.adaptiveStressBias,
    required this.adaptiveBoredomBias,
    required this.adaptiveDriveBias,
    required this.adaptationConfidence,
    required this.lastAdaptedAt,
  });

  final int id;
  final DateTime createdAt;
  final int cigarettesPerDayBaseline;
  final int firstSmokeHour;
  final bool coffeeRiskEnabled;
  final bool drivingRiskEnabled;
  final bool locationRiskEnabled;
  final double notificationAggression;
  final double criticalThreshold;
  final SupportTone supportTone;
  final InterventionType preferredRescue;
  final double reelsSensitivity;
  final double workStressSensitivity;
  final double boredomSensitivity;
  final double adaptiveReelsBias;
  final double adaptiveStressBias;
  final double adaptiveBoredomBias;
  final double adaptiveDriveBias;
  final double adaptationConfidence;
  final DateTime? lastAdaptedAt;

  double get effectiveReelsSensitivity =>
      (reelsSensitivity + adaptiveReelsBias).clamp(0.0, 1.0);

  double get effectiveWorkStressSensitivity =>
      (workStressSensitivity + adaptiveStressBias).clamp(0.0, 1.0);

  double get effectiveBoredomSensitivity =>
      (boredomSensitivity + adaptiveBoredomBias).clamp(0.0, 1.0);

  double get effectiveDriveSensitivity =>
      adaptiveDriveBias.clamp(0.0, 1.0);

  UserProfile copyWith({
    int? id,
    DateTime? createdAt,
    int? cigarettesPerDayBaseline,
    int? firstSmokeHour,
    bool? coffeeRiskEnabled,
    bool? drivingRiskEnabled,
    bool? locationRiskEnabled,
    double? notificationAggression,
    double? criticalThreshold,
    SupportTone? supportTone,
    InterventionType? preferredRescue,
    double? reelsSensitivity,
    double? workStressSensitivity,
    double? boredomSensitivity,
    double? adaptiveReelsBias,
    double? adaptiveStressBias,
    double? adaptiveBoredomBias,
    double? adaptiveDriveBias,
    double? adaptationConfidence,
    DateTime? lastAdaptedAt,
    bool clearLastAdaptedAt = false,
  }) {
    return UserProfile(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      cigarettesPerDayBaseline:
          cigarettesPerDayBaseline ?? this.cigarettesPerDayBaseline,
      firstSmokeHour: firstSmokeHour ?? this.firstSmokeHour,
      coffeeRiskEnabled: coffeeRiskEnabled ?? this.coffeeRiskEnabled,
      drivingRiskEnabled: drivingRiskEnabled ?? this.drivingRiskEnabled,
      locationRiskEnabled: locationRiskEnabled ?? this.locationRiskEnabled,
      notificationAggression:
          notificationAggression ?? this.notificationAggression,
      criticalThreshold: criticalThreshold ?? this.criticalThreshold,
      supportTone: supportTone ?? this.supportTone,
      preferredRescue: preferredRescue ?? this.preferredRescue,
      reelsSensitivity: reelsSensitivity ?? this.reelsSensitivity,
      workStressSensitivity:
          workStressSensitivity ?? this.workStressSensitivity,
      boredomSensitivity: boredomSensitivity ?? this.boredomSensitivity,
      adaptiveReelsBias: adaptiveReelsBias ?? this.adaptiveReelsBias,
      adaptiveStressBias: adaptiveStressBias ?? this.adaptiveStressBias,
      adaptiveBoredomBias:
          adaptiveBoredomBias ?? this.adaptiveBoredomBias,
      adaptiveDriveBias: adaptiveDriveBias ?? this.adaptiveDriveBias,
      adaptationConfidence:
          adaptationConfidence ?? this.adaptationConfidence,
      lastAdaptedAt: clearLastAdaptedAt
          ? null
          : lastAdaptedAt ?? this.lastAdaptedAt,
    );
  }
}
