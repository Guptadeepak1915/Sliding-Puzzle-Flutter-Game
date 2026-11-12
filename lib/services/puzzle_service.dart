import 'dart:math';

class GeneratedPuzzle {
  const GeneratedPuzzle({
    required this.board,
    required this.solutionPath,
  });

  final List<int> board;

  // Tile indices in the exact order needed to solve the puzzle.
  final List<int> solutionPath;
}

abstract final class PuzzleService {
  static List<int> solvedBoard(int size) =>
      List<int>.generate(size * size, (index) => (index + 1) % (size * size));

  static GeneratedPuzzle generatePuzzle(
    int size, {
    int? seed,
    int scrambleMoves = 160,
  }) {
    if (size < 2) {
      throw ArgumentError.value(size, 'size', 'Must be at least 2');
    }

    final random = Random(seed);
    final board = solvedBoard(size);

    var empty = board.length - 1;

    // trail = positions of the empty tile, with loops removed.
    final trail = <int>[empty];
    final keys = <String>[board.join(',')];
    final seen = <String, int>{keys.first: 0};

    for (var move = 0; move < scrambleMoves; move++) {
      final previousEmpty = trail.length > 1 ? trail[trail.length - 2] : -1;

      final candidates = adjacentIndices(empty, size)
          .where((index) => index != previousEmpty)
          .toList();
      final next = candidates[random.nextInt(candidates.length)];

      board[empty] = board[next];
      board[next] = 0;
      empty = next;

      final key = board.join(',');
      final seenAt = seen[key];

      if (seenAt != null) {
        // We came back to an old board, so cut the loop out.
        while (trail.length > seenAt + 1) {
          trail.removeLast();
          seen.remove(keys.removeLast());
        }
      } else {
        trail.add(empty);
        keys.add(key);
        seen[key] = trail.length - 1;
      }
    }

    // Avoid returning an already-solved board.
    if (isSolved(board)) {
      final next = adjacentIndices(empty, size).first;
      board[empty] = board[next];
      board[next] = 0;
      trail.add(next);
    }

    // Tiles to tap, in order, to undo the loop-free scramble.
    final fallbackPath =
        trail.sublist(0, trail.length - 1).reversed.toList();

    // Try for the shortest path; if the solver gives up, use the fallback.
    final optimal = solve(board, size);

    return GeneratedPuzzle(
      board: board,
      solutionPath: optimal ?? fallbackPath,
    );
  }

  // Kept for compatibility with existing code using generateBoard().
  static List<int> generateBoard(
    int size, {
    int? seed,
    int scrambleMoves = 160,
  }) {
    return generatePuzzle(
      size,
      seed: seed,
      scrambleMoves: scrambleMoves,
    ).board;
  }

  /// Shortest solution using IDA* + Manhattan distance.
  /// Returns the list of tile indices to tap, or null if too heavy / unsolvable.
  static List<int>? solve(List<int> start, int size, {int maxNodes = 200000}) {
    final board = List<int>.of(start);
    var empty = board.indexOf(0);
    if (empty == -1) return null;

    int dist(int from, int to) =>
        (from ~/ size - to ~/ size).abs() + (from % size - to % size).abs();

    var h0 = 0;
    for (var i = 0; i < board.length; i++) {
      if (board[i] != 0) h0 += dist(i, board[i] - 1);
    }

    const inf = 1 << 30;
    final path = <int>[];
    var nodes = 0;
    var aborted = false;

    // Returns -1 when solved, otherwise the next bound to try.
    int search(int g, int bound, int h, int prevEmpty) {
      final f = g + h;
      if (f > bound) return f;
      if (h == 0) return -1;
      if (++nodes > maxNodes) {
        aborted = true;
        return inf;
      }

      var minF = inf;
      for (final tileIndex in adjacentIndices(empty, size)) {
        if (tileIndex == prevEmpty) continue;

        final tile = board[tileIndex];
        final goal = tile - 1;
        final newH = h - dist(tileIndex, goal) + dist(empty, goal);

        final oldEmpty = empty;
        board[oldEmpty] = tile;
        board[tileIndex] = 0;
        empty = tileIndex;
        path.add(tileIndex);

        final t = search(g + 1, bound, newH, oldEmpty);
        if (t == -1) return -1;

        path.removeLast();
        board[tileIndex] = tile;
        board[oldEmpty] = 0;
        empty = oldEmpty;

        if (aborted) return inf;
        if (t < minF) minF = t;
      }
      return minF;
    }

    var bound = h0;
    while (true) {
      final t = search(0, bound, h0, -1);
      if (t == -1) return List<int>.of(path);
      if (aborted || t >= inf) return null;
      bound = t;
    }
  }

  static List<int> adjacentIndices(int index, int size) {
    final row = index ~/ size;
    final column = index % size;

    return [
      if (row > 0) index - size,
      if (row < size - 1) index + size,
      if (column > 0) index - 1,
      if (column < size - 1) index + 1,
    ];
  }

  static bool canMove(List<int> board, int index, int size) {
    if (index < 0 || index >= board.length || board[index] == 0) {
      return false;
    }

    final empty = board.indexOf(0);
    if (empty == -1) return false;

    return adjacentIndices(empty, size).contains(index);
  }

  static bool move(List<int> board, int index, int size) {
    if (!canMove(board, index, size)) return false;

    final empty = board.indexOf(0);

    board[empty] = board[index];
    board[index] = 0;

    return true;
  }

  static bool isSolved(List<int> board) {
    if (board.isEmpty) return false;

    for (var i = 0; i < board.length - 1; i++) {
      if (board[i] != i + 1) return false;
    }

    return board.last == 0;
  }

  // Fallback for old saved games that do not have a solution path.
  // This is a heuristic, not a guaranteed optimal solution.
  static int hintIndex(List<int> board, int size) {
    final empty = board.indexOf(0);
    if (empty == -1) return -1;

    var bestIndex = -1;
    var bestDistance = double.infinity;

    for (final index in adjacentIndices(empty, size)) {
      final tile = board[index];
      if (tile == 0) continue;

      final goalIndex = tile - 1;

      final currentRow = index ~/ size;
      final currentCol = index % size;
      final goalRow = goalIndex ~/ size;
      final goalCol = goalIndex % size;

      final distance =
          (currentRow - goalRow).abs() +
          (currentCol - goalCol).abs();

      if (distance < bestDistance) {
        bestDistance = distance.toDouble();
        bestIndex = index;
      }
    }

    return bestIndex;
  }
}