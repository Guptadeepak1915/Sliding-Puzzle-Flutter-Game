import 'package:flutter/material.dart';

import '../utils/puzzle_constants.dart';
import '../widgets/statistics_panel.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({
    required this.size,
    required this.moves,
    required this.seconds,
    required this.bestMoves,
    required this.bestTime,
    required this.onShare,
    required this.onReplay,
    required this.onHome,
    super.key,
  });

  final int size;
  final int moves;
  final int seconds;
  final int bestMoves;
  final int? bestTime;
  final VoidCallback onShare;
  final VoidCallback onReplay;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(21, 22, 21, 14),
    decoration: BoxDecoration(
      color: PuzzleConstants.walnutLight,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: PuzzleConstants.gold.withAlpha(180)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(120),
          offset: const Offset(0, 9),
          blurRadius: 18,
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.emoji_events_rounded,
          color: PuzzleConstants.gold,
          size: 44,
        ),
        const SizedBox(height: 9),
        const Text(
          'AMAZING!\nPUZZLE SOLVED!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: PuzzleConstants.cream,
            fontSize: 20,
            height: 1.4,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$size × $size  •  ${StatisticsPanel.formatTime(seconds)}',
          style: const TextStyle(color: PuzzleConstants.muted, fontSize: 12),
        ),
        const SizedBox(height: 16),
        _resultLine('TOTAL MOVES', '$moves'),
        _resultLine('BEST MOVES', '$bestMoves'),
        _resultLine(
          'BEST TIME',
          bestTime == null ? '—' : StatisticsPanel.formatTime(bestTime!),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 4,
          children: [
            TextButton(
              onPressed: onShare,
              child: const Text(
                'SHARE SCORE',
                style: TextStyle(color: PuzzleConstants.gold, fontSize: 11),
              ),
            ),
            TextButton(
              onPressed: onReplay,
              child: const Text(
                'REPLAY',
                style: TextStyle(color: PuzzleConstants.gold, fontSize: 11),
              ),
            ),
            TextButton(
              onPressed: onHome,
              child: const Text(
                'HOME',
                style: TextStyle(color: PuzzleConstants.cream, fontSize: 11),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _resultLine(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: PuzzleConstants.muted,
            fontSize: 11,
            letterSpacing: 1,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: PuzzleConstants.cream,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
