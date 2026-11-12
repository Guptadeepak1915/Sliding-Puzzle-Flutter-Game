import 'package:flutter/material.dart';

import '../utils/puzzle_constants.dart';

class GameHeader extends StatelessWidget {
  const GameHeader({
    required this.size,
    required this.daily,
    required this.paused,
    required this.onBack,
    required this.onPause,
    super.key,
  });

  final int size;
  final bool daily;
  final bool paused;
  final VoidCallback onBack;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      IconButton(
        tooltip: 'Back to home',
        onPressed: onBack,
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: PuzzleConstants.cream,
        ),
      ),
      Expanded(
        child: Column(
          children: [
            Text(
              daily ? 'DAILY CHALLENGE' : 'WOODEN PUZZLE',
              style: const TextStyle(
                color: PuzzleConstants.gold,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              '$size × $size',
              style: const TextStyle(
                color: PuzzleConstants.muted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
      IconButton(
        tooltip: paused ? 'Resume' : 'Pause',
        onPressed: onPause,
        icon: Icon(
          paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
          color: PuzzleConstants.cream,
        ),
      ),
    ],
  );
}
