import 'package:flutter/material.dart';

import '../models/game_settings.dart';
import '../services/storage_service.dart';
import '../utils/puzzle_constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    required this.settings,
    required this.storage,
    required this.onChanged,
    super.key,
  });

  final GameSettings settings;
  final StorageService storage;
  final Future<void> Function(GameSettings) onChanged;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late GameSettings _settings = widget.settings;

  Future<void> _update(GameSettings settings) async {
    setState(() => _settings = settings);
    await widget.onChanged(settings);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: PuzzleConstants.walnut,
      foregroundColor: PuzzleConstants.cream,
      title: const Text(
        'SETTINGS',
        style: TextStyle(letterSpacing: 2, fontSize: 17),
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
      children: [
        _sectionTitle('PREFERENCES'),
        _switch(
          'Sound effects',
          'Warm wooden clicks and chimes',
          _settings.soundEnabled,
          (value) => _update(_settings.copyWith(soundEnabled: value)),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 14, right: 12, bottom: 10),
          child: Row(
            children: [
              const Text(
                'Volume',
                style: TextStyle(color: PuzzleConstants.muted),
              ),
              Expanded(
                child: Slider(
                  value: _settings.masterVolume,
                  activeColor: PuzzleConstants.gold,
                  inactiveColor: PuzzleConstants.mediumWood,
                  onChanged: (value) =>
                      _update(_settings.copyWith(masterVolume: value)),
                ),
              ),
              Text(
                '${(_settings.masterVolume * 100).round()}%',
                style: const TextStyle(
                  color: PuzzleConstants.cream,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        _switch(
          'Haptic feedback',
          'A gentle tap with each move',
          _settings.hapticsEnabled,
          (value) => _update(_settings.copyWith(hapticsEnabled: value)),
        ),
        _switch(
          'Tile animations',
          'Smooth sliding transitions',
          _settings.animationsEnabled,
          (value) => _update(_settings.copyWith(animationsEnabled: value)),
        ),
        const SizedBox(height: 20),
        _sectionTitle('BOARD SIZE'),
        Wrap(
          spacing: 10,
          children: [
            for (final size in PuzzleConstants.boardSizes)
              ChoiceChip(
                label: Text('$size×$size'),
                selected: size == _settings.boardSize,
                onSelected: (_) => _update(_settings.copyWith(boardSize: size)),
                selectedColor: PuzzleConstants.oak,
                backgroundColor: PuzzleConstants.walnutLight,
                labelStyle: const TextStyle(color: PuzzleConstants.cream),
              ),
          ],
        ),
        const SizedBox(height: 28),
        _sectionTitle('YOUR RECORDS'),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'Reset best scores',
            style: TextStyle(color: PuzzleConstants.cream),
          ),
          subtitle: const Text(
            'Clear best moves and times for every board size',
            style: TextStyle(color: PuzzleConstants.muted),
          ),
          trailing: const Icon(
            Icons.delete_outline,
            color: PuzzleConstants.gold,
          ),
          onTap: _confirmReset,
        ),
        const SizedBox(height: 20),
        _sectionTitle('PRIVACY'),
        const Text(
          'Your settings and scores stay on this device. The game works offline and does not collect or transmit personal data.',
          style: TextStyle(color: PuzzleConstants.muted, height: 1.5),
        ),
      ],
    ),
  );

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Text(
      title,
      style: const TextStyle(
        color: PuzzleConstants.gold,
        fontSize: 11,
        letterSpacing: 1.5,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget _switch(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) => SwitchListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(title, style: const TextStyle(color: PuzzleConstants.cream)),
    subtitle: Text(
      subtitle,
      style: const TextStyle(color: PuzzleConstants.muted, fontSize: 12),
    ),
    value: value,
    activeThumbColor: PuzzleConstants.gold,
    onChanged: onChanged,
  );

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: PuzzleConstants.walnutLight,
        title: const Text(
          'Reset records?',
          style: TextStyle(color: PuzzleConstants.cream),
        ),
        content: const Text(
          'This clears best moves and times for all board sizes.',
          style: TextStyle(color: PuzzleConstants.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'RESET',
              style: TextStyle(color: PuzzleConstants.gold),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.storage.resetRecords();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Best scores reset')));
      }
    }
  }
}
