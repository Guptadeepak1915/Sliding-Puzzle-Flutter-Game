import 'package:flutter/material.dart';

import '../utils/puzzle_constants.dart';

class GameControls extends StatelessWidget {
  const GameControls({
    required this.onShuffle,
    required this.onRestart,
    required this.onHint,
    required this.onUndo,
    required this.onSound,
    required this.soundEnabled,
    required this.canUndo,
    super.key,
  });

  final VoidCallback onShuffle;
  final VoidCallback onRestart;
  final VoidCallback onHint;
  final VoidCallback onUndo;
  final VoidCallback onSound;
  final bool soundEnabled;
  final bool canUndo;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _Control(
          icon: Icons.shuffle_rounded,
          label: 'SHUFFLE',
          onTap: onShuffle,
        ),
        _Control(
          icon: Icons.refresh_rounded,
          label: 'RESTART',
          onTap: onRestart,
        ),
        _Control(
          icon: Icons.lightbulb_outline_rounded,
          label: 'HINT',
          onTap: onHint,
        ),
        _Control(
          icon: Icons.undo_rounded,
          label: 'UNDO',
          onTap: onUndo,
          enabled: canUndo,
        ),
        _Control(
          icon: soundEnabled
              ? Icons.volume_up_rounded
              : Icons.volume_off_rounded,
          label: 'SOUND',
          onTap: onSound,
        ),
      ],
    );
  }
}

class _Control extends StatelessWidget {
  const _Control({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22,
                color: enabled ? PuzzleConstants.gold : PuzzleConstants.muted,
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 8,
                  letterSpacing: 0.7,
                  color: enabled
                      ? PuzzleConstants.muted
                      : PuzzleConstants.muted.withAlpha(100),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
