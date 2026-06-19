import 'package:flutter/material.dart';

class AppPalette {
  const AppPalette._();

  static const Color background = Color(0xFF071116);
  static const Color backgroundDeep = Color(0xFF040B10);
  static const Color surface = Color(0xFF0E1B22);
  static const Color surfaceElevated = Color(0xFF14252D);
  static const Color primary = Color(0xFF39D5C7);
  static const Color secondary = Color(0xFF5AA9FF);
  static const Color emerald = Color(0xFF3CE58D);
  static const Color amber = Color(0xFFFFC86B);
  static const Color danger = Color(0xFFEE6A77);
  static const Color textPrimary = Color(0xFFF5FBFE);
  static const Color textSecondary = Color(0xFFB2C2CA);
  static const Color textMuted = Color(0xFF7D919A);
  static const Color stroke = Color(0xFF1D333C);

  static const LinearGradient appGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0xFF102028), Color(0xFF081218), Color(0xFF051016)],
  );

  static const RadialGradient rescueGlow = RadialGradient(
    center: Alignment.topCenter,
    radius: 1.2,
    colors: <Color>[Color(0x8039D5C7), Color(0x0025323A)],
  );
}
