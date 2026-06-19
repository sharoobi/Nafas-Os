import 'package:nafas_os/shared/models/app_enums.dart';

class InterventionEvent {
  const InterventionEvent({
    required this.id,
    required this.occurredAt,
    required this.interventionType,
    required this.riskScore,
    required this.accepted,
    required this.successful,
    required this.contextLabel,
  });

  final int id;
  final DateTime occurredAt;
  final InterventionType interventionType;
  final double riskScore;
  final bool accepted;
  final bool successful;
  final String contextLabel;
}
