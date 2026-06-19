import 'package:nafas_os/shared/models/app_enums.dart';

class CompanionBrief {
  const CompanionBrief({
    required this.mode,
    required this.title,
    required this.body,
    required this.focusLabel,
    required this.vibeLine,
  });

  final CompanionMode mode;
  final String title;
  final String body;
  final String focusLabel;
  final String vibeLine;
}
