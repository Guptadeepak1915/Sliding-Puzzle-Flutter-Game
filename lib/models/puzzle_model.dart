
import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../services/puzzle_service.dart';

class PuzzleModel extends ChangeNotifier {
  PuzzleModel({
    required this.size,
    required List<int> board,
    List<int>? initialBoard,
    List<int>? solutionPath,
    List<int>? initialSolutionPath,
    List<List<int>>? hintHistory,
    this.moves = 0,
    this.elapsedSeconds = 0,
    this.paused = false,
    List<int> history = const [],
    this.onChanged,
  })  : _board = List<int>.of(board),
        _initialBoard = List<int>.of(initialBoard ?? board),
        _history = List<int>.of(history),
        _exactSolutionEnabled =
            solutionPath != null || initialSolutionPath != null,
        _initialSolutionPath = List<int>.of(
          initialSolutionPath ?? solutionPath ?? [],
        ),
        _solutionPath = List<int>.of(
          solutionPath ?? initialSolutionPath ?? [],
        ),
        _hintHistory = (hintHistory ?? [])
            .map((path) => List<int>.of(path))
            .toList() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!paused && !isComplete) {
        elapsedSeconds++;
        notifyListeners();
      }
    });
  }

  final int size;
  final VoidCallback? onChanged;

  List<int> _board;
  List<int> _initialBoard;
  final List<int> _history;

  bool _exactSolutionEnabled;
  final List<int> _initialSolutionPath;
  final List<int> _solutionPath;
  final List<List<int>> _hintHistory;

  late final Timer _timer;

  int moves;
  int elapsedSeconds;
  bool paused;
  bool isComplete = false;
  int? highlightedIndex;

  List<int> get board => List.unmodifiable(_board);

  bool get canUndo => _history.isNotEmpty;

  bool moveTile(int index) {
    if (paused ||
        isComplete ||
        !PuzzleService.canMove(_board, index, size)) {
      return false;
    }

    final oldEmpty = _board.indexOf(0);

    _history.add(oldEmpty);

    if (_exactSolutionEnabled) {
      // Save the current solution path so Undo can restore it.
      _hintHistory.add(List<int>.of(_solutionPath));

      if (_solutionPath.isNotEmpty && index == _solutionPath.first) {
        // Player followed the correct hint.
        _solutionPath.removeAt(0);
      } else {
        // Player chose another legal move.
        // First undo that move, then continue the known solution.
        _solutionPath.insert(0, oldEmpty);
      }
    }

    PuzzleService.move(_board, index, size);

    moves++;
    highlightedIndex = null;

    isComplete = PuzzleService.isSolved(_board);

    if (isComplete) paused = true;

    onChanged?.call();
    notifyListeners();

    return true;
  }

  void undo() {
    if (paused || _history.isEmpty || isComplete) return;

    final previousEmpty = _history.removeLast();
    final currentEmpty = _board.indexOf(0);

    _board[currentEmpty] = _board[previousEmpty];
    _board[previousEmpty] = 0;

    if (_exactSolutionEnabled && _hintHistory.isNotEmpty) {
      final previousPath = _hintHistory.removeLast();

      _solutionPath
        ..clear()
        ..addAll(previousPath);
    }

    moves = max(0, moves - 1);
    highlightedIndex = null;

    onChanged?.call();
    notifyListeners();
  }

  void showHint() {
  if (paused || isComplete) return;

  // 1) Best: fresh shortest path from the current board.
  var index = -1;
  final fresh = PuzzleService.solve(_board, size);
  if (fresh != null && fresh.isNotEmpty) {
    index = fresh.first;
  }

  // 2) Fallback: stored solution path (for big boards).
  if (index < 0 && _exactSolutionEnabled && _solutionPath.isNotEmpty) {
    final candidate = _solutionPath.first;
    if (PuzzleService.canMove(_board, candidate, size)) {
      index = candidate;
    }
  }

  // 3) Last fallback: old greedy hint.
  if (index < 0) {
    index = PuzzleService.hintIndex(_board, size);
  }

  if (index < 0) return;

  highlightedIndex = index;
  notifyListeners();
}

  void togglePause() {
    if (isComplete) return;

    paused = !paused;
    onChanged?.call();
    notifyListeners();
  }

  void setPaused(bool value) {
    if (isComplete || paused == value) return;

    paused = value;
    onChanged?.call();
    notifyListeners();
  }

  void resume() {
    if (isComplete || !paused) return;

    paused = false;
    notifyListeners();
  }

  void restart() {
    _board = List<int>.of(_initialBoard);

    _solutionPath
      ..clear()
      ..addAll(_initialSolutionPath);

    _history.clear();
    _hintHistory.clear();

    moves = 0;
    elapsedSeconds = 0;
    isComplete = PuzzleService.isSolved(_board);
    paused = isComplete;
    highlightedIndex = null;

    onChanged?.call();
    notifyListeners();
  }

  void shuffle({int? seed}) {
    final generated = PuzzleService.generatePuzzle(
      size,
      seed: seed,
    );
    _exactSolutionEnabled = true;
    _board = List<int>.of(generated.board);
    _initialBoard = List<int>.of(generated.board);

    _solutionPath
      ..clear()
      ..addAll(generated.solutionPath);

    _initialSolutionPath
      ..clear()
      ..addAll(generated.solutionPath);

    _history.clear();
    _hintHistory.clear();

    moves = 0;
    elapsedSeconds = 0;
    isComplete = false;
    paused = false;
    highlightedIndex = null;

    onChanged?.call();
    notifyListeners();
  }

  Map<String, Object> toJson() => {
        'size': size,
        'board': _board,
        'initialBoard': _initialBoard,
        'moves': moves,
        'elapsedSeconds': elapsedSeconds,
        'paused': paused,
        'history': _history,
        'solutionPath': _solutionPath,
        'initialSolutionPath': _initialSolutionPath,
        'hintHistory': _hintHistory,
      };

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
