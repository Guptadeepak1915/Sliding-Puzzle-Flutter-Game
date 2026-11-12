import 'package:flutter/material.dart';

import '../utils/puzzle_constants.dart';

ThemeData buildWoodenTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: PuzzleConstants.oak,
    brightness: Brightness.dark,
    surface: PuzzleConstants.walnutLight,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: PuzzleConstants.walnut,
    fontFamily: 'Georgia',
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        color: PuzzleConstants.cream,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
      titleLarge: TextStyle(
        color: PuzzleConstants.cream,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
      ),
      bodyMedium: TextStyle(color: PuzzleConstants.cream),
    ),
  );
}
