import 'dart:async';

import 'package:flutter/material.dart';

import '../models/game_settings.dart';
import '../screens/game_screen.dart';
import '../screens/settings_screen.dart';
import '../services/sound_service.dart';
import '../services/storage_service.dart';
import '../utils/puzzle_constants.dart';
import '../widgets/wooden_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.storage,
    required this.sound,
    required this.initialSettings,
    super.key,
  });

  final StorageService storage;
  final SoundService sound;
  final GameSettings initialSettings;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GameSettings _settings = widget.initialSettings;

  Future<void> _saveSettings(GameSettings settings) async {
    setState(() => _settings = settings);
    await widget.sound.setVolume(settings.masterVolume);
    await widget.storage.saveSettings(settings);
  }

  void _startGame({int? dailySeed}) {
    unawaited(widget.sound.play('button', enabled: _settings.soundEnabled));
    Navigator.of(context)
        .push(
          PageRouteBuilder<void>(
            transitionDuration: const Duration(milliseconds: 220),
            pageBuilder: (context, animation, secondaryAnimation) => GameScreen(
              size: _settings.boardSize,
              dailySeed: dailySeed,
              storage: widget.storage,
              sound: widget.sound,
              settings: _settings,
              onSettingsChanged: _saveSettings,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(opacity: animation, child: child),
          ),
        )
        .then((_) {
          if (mounted) setState(() {});
        });
  }

  @override
  Widget build(BuildContext context) {
    final best = widget.storage.bestMoves(_settings.boardSize);
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        tooltip: 'Settings',
                        onPressed: () async {
                          await widget.sound.play(
                            'button',
                            enabled: _settings.soundEnabled,
                          );
                          if (!context.mounted) return;
                          await Navigator.of(context).push<void>(
                            MaterialPageRoute(
                              builder: (_) => SettingsScreen(
                                settings: _settings,
                                storage: widget.storage,
                                onChanged: _saveSettings,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.settings_rounded,
                          color: PuzzleConstants.gold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Icon(
                      Icons.grid_on_rounded,
                      size: 33,
                      color: PuzzleConstants.gold,
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'THE WOODEN',
                      style: TextStyle(
                        color: PuzzleConstants.cream,
                        fontSize: 29,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 4,
                      ),
                    ),
                    const Text(
                      'PUZZLE',
                      style: TextStyle(
                        color: PuzzleConstants.gold,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 7,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _BoardPreview(size: _settings.boardSize),
                    const SizedBox(height: 17),
                    const Text(
                      'A little quiet. A little clever.',
                      style: TextStyle(
                        color: PuzzleConstants.muted,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 21),
                    WoodenButton(
                      label: 'PLAY GAME',
                      icon: Icons.play_arrow_rounded,
                      primary: true,
                      onPressed: () => _startGame(),
                    ),
                    const SizedBox(height: 14),
                    _SizeSelector(
                      value: _settings.boardSize,
                      onChanged: (size) =>
                          _saveSettings(_settings.copyWith(boardSize: size)),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _HomeAction(
                          icon: Icons.wb_sunny_outlined,
                          label: 'DAILY',
                          onTap: () => _startGame(
                            dailySeed:
                                DateTime.now().year * 10000 +
                                DateTime.now().month * 100 +
                                DateTime.now().day,
                          ),
                        ),
                        const SizedBox(width: 26),
                        _HomeAction(
                          icon: _settings.soundEnabled
                              ? Icons.volume_up_rounded
                              : Icons.volume_off_rounded,
                          label: _settings.soundEnabled
                              ? 'SOUND ON'
                              : 'SOUND OFF',
                          onTap: () => _saveSettings(
                            _settings.copyWith(
                              soundEnabled: !_settings.soundEnabled,
                            ),
                          ),
                        ),
                        const SizedBox(width: 26),
                        _HomeAction(
                          icon: Icons.help_outline_rounded,
                          label: 'HOW TO',
                          onTap: _showInstructions,
                        ),
                      ],
                    ),
                    const SizedBox(height: 19),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: PuzzleConstants.walnutLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: PuzzleConstants.mediumWood),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.emoji_events_outlined,
                            color: PuzzleConstants.gold,
                            size: 18,
                          ),
                          const SizedBox(width: 9),
                          Text(
                            best == null
                                ? 'BEST SCORE   —'
                                : 'BEST SCORE   $best MOVES',
                            style: const TextStyle(
                              color: PuzzleConstants.cream,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showInstructions() {
    unawaited(widget.sound.play('button', enabled: _settings.soundEnabled));
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: PuzzleConstants.walnutLight,
        title: const Text(
          'HOW TO PLAY',
          style: TextStyle(color: PuzzleConstants.gold),
        ),
        content: const Text(
          'Slide a tile next to the empty space. Arrange the numbers from 1 upward, with the empty space in the bottom-right corner. Use Hint when you need a nudge; Undo takes back your last move.',
          style: TextStyle(color: PuzzleConstants.cream, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'GOT IT',
              style: TextStyle(color: PuzzleConstants.gold),
            ),
          ),
        ],
      ),
    );
  }
}

class _BoardPreview extends StatelessWidget {
  const _BoardPreview({required this.size});
  final int size;

  @override
  Widget build(BuildContext context) {
    final count = size * size;
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: const Color(0xFF53331F),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: PuzzleConstants.gold.withAlpha(160),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(90),
            offset: const Offset(0, 7),
            blurRadius: 13,
          ),
        ],
      ),
      child: SizedBox(
        width: 180,
        height: 180,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: count,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: size,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
          ),
          itemBuilder: (context, index) {
            if (index == count - 1) {
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: PuzzleConstants.walnut.withAlpha(120),
                  borderRadius: BorderRadius.circular(6),
                ),
              );
            }
            return CustomPaint(
              painter: const _PreviewTilePainter(),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: PuzzleConstants.walnut,
                    fontSize: size == 5 ? 13 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PreviewTilePainter extends CustomPainter {
  const _PreviewTilePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      Paint()..color = PuzzleConstants.oak,
    );
  }

  @override
  bool shouldRepaint(_PreviewTilePainter oldDelegate) => false;
}

class _SizeSelector extends StatelessWidget {
  const _SizeSelector({required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      for (final size in PuzzleConstants.boardSizes)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: ChoiceChip(
            label: Text('$size×$size'),
            selected: size == value,
            onSelected: (_) => onChanged(size),
            selectedColor: PuzzleConstants.oak,
            backgroundColor: PuzzleConstants.walnutLight,
            labelStyle: TextStyle(
              color: size == value
                  ? PuzzleConstants.walnut
                  : PuzzleConstants.cream,
              fontWeight: FontWeight.bold,
            ),
            side: BorderSide(color: PuzzleConstants.mediumWood.withAlpha(180)),
          ),
        ),
    ],
  );
}

class _HomeAction extends StatelessWidget {
  const _HomeAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(10),
    child: Padding(
      padding: const EdgeInsets.all(5),
      child: Column(
        children: [
          Icon(icon, size: 20, color: PuzzleConstants.gold),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              color: PuzzleConstants.muted,
              fontSize: 9,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    ),
  );
}
