import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slidingnumberpuzzle/models/game_settings.dart';
import 'package:slidingnumberpuzzle/models/puzzle_model.dart';
import 'package:slidingnumberpuzzle/screens/home_screen.dart';
import 'package:slidingnumberpuzzle/services/puzzle_service.dart';
import 'package:slidingnumberpuzzle/services/sound_service.dart';
import 'package:slidingnumberpuzzle/services/storage_service.dart';
import 'package:slidingnumberpuzzle/widgets/wooden_board.dart';

void main() {
  group('PuzzleService', () {
    test('generates solvable, non-complete boards in every supported size', () {
      for (final size in [3, 4, 5]) {
        for (var seed = 0; seed < 30; seed++) {
          final board = PuzzleService.generateBoard(size, seed: seed);
          expect(board.toSet().length, size * size);
          expect(board, contains(0));
          expect(PuzzleService.isSolved(board), isFalse);

          final inversions = _inversionCount(board);
          if (size.isOdd) {
            expect(inversions.isEven, isTrue);
          } else {
            final blankRowFromBottom = size - board.indexOf(0) ~/ size;
            expect((inversions + blankRowFromBottom).isOdd, isTrue);
          }
        }
      }
    });

    test('accepts each orthogonal move and rejects invalid moves', () {
      const size = 3;
      const board = [1, 2, 3, 4, 0, 5, 6, 7, 8];
      for (final index in [1, 3, 5, 7]) {
        final next = List<int>.of(board);
        expect(PuzzleService.move(next, index, size), isTrue);
        expect(next[index], 0);
      }
      for (final index in [-1, 0, 2, 4, 6, 8, 9]) {
        final unchanged = List<int>.of(board);
        expect(PuzzleService.move(unchanged, index, size), isFalse);
        expect(unchanged, board);
      }
    });

    test('daily seeds generate the same puzzle', () {
      expect(
        PuzzleService.generateBoard(4, seed: 20261031),
        PuzzleService.generateBoard(4, seed: 20261031),
      );
    });
  });

  test('model counts valid moves, supports undo, and detects completion', () {
    final model = PuzzleModel(size: 3, board: [1, 2, 3, 4, 5, 6, 7, 0, 8]);
    expect(model.moveTile(0), isFalse);
    expect(model.moves, 0);
    expect(model.moveTile(8), isTrue);
    expect(model.isComplete, isTrue);
    expect(model.moves, 1);
    model.dispose();

    final undoModel = PuzzleModel(size: 3, board: [1, 2, 3, 4, 0, 5, 6, 7, 8]);
    final original = undoModel.board;
    expect(undoModel.moveTile(5), isTrue);
    expect(undoModel.moves, 1);
    undoModel.undo();
    expect(undoModel.board, original);
    expect(undoModel.moves, 0);
    undoModel.dispose();
  });

  test('storage preserves settings, progress, and best records', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = StorageService(await SharedPreferences.getInstance());
    const settings = GameSettings(
      boardSize: 5,
      soundEnabled: false,
      masterVolume: 0.3,
      hapticsEnabled: false,
    );
    await storage.saveSettings(settings);
    expect(storage.loadSettings().boardSize, 5);
    expect(storage.loadSettings().soundEnabled, isFalse);
    expect(storage.loadSettings().masterVolume, 0.3);
    expect(storage.loadSettings().hapticsEnabled, isFalse);

    final game = {
      'size': 3,
      'board': [1, 2, 3, 4, 5, 6, 7, 0, 8],
      'moves': 12,
      'elapsedSeconds': 34,
      'paused': true,
    };
    await storage.saveGame(game);
    expect(storage.loadGame(3)?['board'], game['board']);
    expect(storage.loadGame(4), isNull);

    await storage.recordResult(3, 22, 75);
    await storage.recordResult(3, 25, 50);
    expect(storage.bestMoves(3), 22);
    expect(storage.bestTime(3), 50);
  });

  testWidgets('wooden board responds to a legal tile tap', (tester) async {
    final model = PuzzleModel(size: 3, board: [1, 2, 3, 4, 5, 6, 7, 0, 8]);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              height: 320,
              child: WoodenBoard(model: model, animationsEnabled: true),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('8'));
    await tester.pumpAndSettle();
    expect(model.isComplete, isTrue);
    expect(model.moves, 1);
    model.dispose();
  });

  testWidgets('home screen starts a playable game', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = StorageService(await SharedPreferences.getInstance());
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          storage: storage,
          sound: SoundService(),
          initialSettings: const GameSettings(),
        ),
      ),
    );
    expect(find.text('THE WOODEN'), findsOneWidget);
    await tester.tap(find.text('PLAY GAME'));
    await tester.pumpAndSettle();
    expect(find.text('WOODEN PUZZLE'), findsOneWidget);
    await tester.tap(find.byTooltip('Back to home'));
    await tester.pumpAndSettle();
    expect(find.text('THE WOODEN'), findsOneWidget);
  });
}

int _inversionCount(List<int> board) {
  var inversions = 0;
  for (var first = 0; first < board.length; first++) {
    if (board[first] == 0) continue;
    for (var second = first + 1; second < board.length; second++) {
      if (board[second] != 0 && board[first] > board[second]) inversions++;
    }
  }
  return inversions;
}
