import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_settings.dart';

class StorageService {
  StorageService(this._preferences);

  final SharedPreferences _preferences;
  static const _sessionKey = 'saved_game';

  static Future<StorageService> create() async =>
      StorageService(await SharedPreferences.getInstance());

  GameSettings loadSettings() => GameSettings(
    boardSize: _preferences.getInt('board_size') ?? 4,
    soundEnabled: _preferences.getBool('sound_enabled') ?? true,
    masterVolume: _preferences.getDouble('master_volume') ?? 0.65,
    hapticsEnabled: _preferences.getBool('haptics_enabled') ?? true,
    animationsEnabled: _preferences.getBool('animations_enabled') ?? true,
  );

  Future<void> saveSettings(GameSettings settings) async {
    await _preferences.setInt('board_size', settings.boardSize);
    await _preferences.setBool('sound_enabled', settings.soundEnabled);
    await _preferences.setDouble('master_volume', settings.masterVolume);
    await _preferences.setBool('haptics_enabled', settings.hapticsEnabled);
    await _preferences.setBool(
      'animations_enabled',
      settings.animationsEnabled,
    );
  }

  int? bestMoves(int size) => _preferences.getInt('best_moves_$size');
  int? bestTime(int size) => _preferences.getInt('best_time_$size');

  Future<void> recordResult(int size, int moves, int seconds) async {
    final oldMoves = bestMoves(size);
    final oldTime = bestTime(size);
    if (oldMoves == null || moves < oldMoves) {
      await _preferences.setInt('best_moves_$size', moves);
    }
    if (oldTime == null || seconds < oldTime) {
      await _preferences.setInt('best_time_$size', seconds);
    }
  }

  Future<void> resetRecords() async {
    for (final size in [3, 4, 5]) {
      await _preferences.remove('best_moves_$size');
      await _preferences.remove('best_time_$size');
    }
  }

  Future<void> saveGame(Map<String, Object> game) async {
    await _preferences.setString(_sessionKey, jsonEncode(game));
  }

  Map<String, dynamic>? loadGame(int expectedSize) {
    final value = _preferences.getString(_sessionKey);
    if (value == null) return null;
    Object? decoded;
    try {
      decoded = jsonDecode(value);
    } on FormatException catch (error) {
      _discardInvalidSession('invalid JSON ($error)');
      return null;
    }
    if (decoded is! Map<String, dynamic>) {
      _discardInvalidSession('unexpected data format');
      return null;
    }
    if (decoded['size'] != expectedSize) return null;
    final board = decoded['board'];
    final initialBoard = decoded['initialBoard'];
    final history = decoded['history'];
    if (board is! List ||
        board.length != expectedSize * expectedSize ||
        board.any((tile) => tile is! int) ||
        board.toSet().length != board.length ||
        !board.contains(0) ||
        board.whereType<int>().any(
          (tile) => tile < 0 || tile >= board.length,
        ) ||
        decoded['moves'] is! int ||
        (decoded['moves'] as int) < 0 ||
        decoded['elapsedSeconds'] is! int ||
        (decoded['elapsedSeconds'] as int) < 0 ||
        decoded['paused'] is! bool ||
        initialBoard != null &&
            (initialBoard is! List ||
                initialBoard.length != expectedSize * expectedSize ||
                initialBoard.any((tile) => tile is! int) ||
                initialBoard.toSet().length != initialBoard.length ||
                !initialBoard.contains(0) ||
                initialBoard.whereType<int>().any(
                  (tile) => tile < 0 || tile >= initialBoard.length,
                )) ||
        history != null &&
            (history is! List ||
                history.any(
                  (index) =>
                      index is! int || index < 0 || index >= board.length,
                ))) {
      _discardInvalidSession('invalid board or progress data');
      return null;
    }
    return decoded;
  }

  void _discardInvalidSession(String reason) {
    debugPrint('Discarding saved puzzle session: $reason');
    unawaited(_preferences.remove(_sessionKey));
  }

  Future<void> clearSavedGame() async {
    await _preferences.remove(_sessionKey);
  }
}
