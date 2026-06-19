import 'package:nafas_os/shared/models/app_enums.dart';

class CompanionMission {
  const CompanionMission({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.rewardLine,
    required this.progress,
    required this.target,
    required this.interventionType,
    required this.interactionMode,
  });

  final String id;
  final String title;
  final String subtitle;
  final String rewardLine;
  final int progress;
  final int target;
  final InterventionType interventionType;
  final MissionInteractionMode interactionMode;

  double get completionRatio {
    if (target <= 0) {
      return 0;
    }
    return (progress / target).clamp(0.0, 1.0);
  }
}
