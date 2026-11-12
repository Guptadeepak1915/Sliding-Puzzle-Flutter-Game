import 'package:flutter/material.dart';

import '../utils/puzzle_constants.dart';

class StatisticsPanel extends StatelessWidget {
  const StatisticsPanel({
    required this.moves,
    required this.seconds,
    required this.bestMoves,
    required this.bestTime,
    super.key,
  });

  final int moves;
  final int seconds;
  final int? bestMoves;
  final int? bestTime;

  static String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainder = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainder.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: PuzzleConstants.walnutLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PuzzleConstants.mediumWood),
      ),
      child: Row(
        children: [
          _stat('MOVES', '$moves'),
          _divider(),
          _stat('TIME', formatTime(seconds)),
          _divider(),
          _stat('BEST', bestMoves?.toString() ?? '—'),
          _divider(),
          _stat('RECORD', bestTime == null ? '—' : formatTime(bestTime!)),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) => Expanded(
    child: Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: PuzzleConstants.muted,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: PuzzleConstants.cream,
          ),
        ),
      ],
    ),
  );

  Widget _divider() => Container(
    width: 1,
    height: 28,
    color: PuzzleConstants.mediumWood.withAlpha(180),
  );
}
