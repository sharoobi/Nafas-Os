import 'package:nafas_os/shared/models/app_enums.dart';

class RiskAssessment {
  const RiskAssessment({
    required this.score,
    required this.level,
    required this.factors,
    required this.recommendedIntervention,
    required this.healthCaution,
    required this.summary,
  });

  final double score;
  final RiskLevel level;
  final Map<String, double> factors;
  final InterventionType recommendedIntervention;
  final bool healthCaution;
  final String summary;
}
