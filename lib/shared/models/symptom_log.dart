class SymptomLog {
  const SymptomLog({
    required this.id,
    required this.occurredAt,
    required this.coughSeverity,
    required this.breathlessness,
    required this.sputumSeverity,
    required this.bloodInSputum,
    required this.chestPain,
  });

  final int id;
  final DateTime occurredAt;
  final int coughSeverity;
  final int breathlessness;
  final int sputumSeverity;
  final bool bloodInSputum;
  final bool chestPain;
}
