
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:share_plus/share_plus.dart';

import '../models/game_settings.dart';
import '../models/puzzle_model.dart';
import '../services/ad_service.dart';
import '../services/haptic_service.dart';
import '../services/puzzle_service.dart';
import '../services/sound_service.dart';
import '../services/storage_service.dart';
import '../utils/puzzle_constants.dart';
import '../widgets/game_controls.dart';
import '../widgets/game_header.dart';
import '../widgets/statistics_panel.dart';
import '../widgets/wooden_board.dart';
import '../widgets/wooden_button.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    required this.size,
    required this.storage,
    required this.sound,
    required this.settings,
    required this.onSettingsChanged,
    this.dailySeed,
    super.key,
  });

  final int size;
  final int? dailySeed;
  final StorageService storage;
  final SoundService sound;
  final GameSettings settings;
  final Future<void> Function(GameSettings) onSettingsChanged;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with WidgetsBindingObserver {
  late final PuzzleModel _model;
  late GameSettings _settings;

  bool _resultPresented = false;
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  final _haptics = const HapticService();

  @override
  void initState() {
    super.initState();

    _settings = widget.settings;

    WidgetsBinding.instance.addObserver(this);

    // Load saved game.
    final saved = widget.storage.loadGame(widget.size);

    final savedBoard = saved?['board'];
    final savedHistory = saved?['history'];
    final savedInitialBoard = saved?['initialBoard'];

    final validSavedBoard =
        savedBoard is List &&
        savedBoard.length == widget.size * widget.size &&
        savedBoard.every((tile) => tile is int);

    // Generate a new puzzle only if there is no valid saved board.
    final generatedPuzzle = validSavedBoard
        ? null
        : PuzzleService.generatePuzzle(
            widget.size,
            seed: widget.dailySeed,
          );

    final generatedBoard = validSavedBoard
        ? savedBoard.cast<int>()
        : generatedPuzzle!.board;

    final validInitialBoard =
        savedInitialBoard is List &&
        savedInitialBoard.length == widget.size * widget.size &&
        savedInitialBoard.every((tile) => tile is int);

    // Restore solution path.
    final savedSolutionPath = saved?['solutionPath'];
    final savedInitialSolutionPath = saved?['initialSolutionPath'];
    final rawHintHistory = saved?['hintHistory'];

    final validSolutionPath =
        savedSolutionPath is List &&
        savedSolutionPath.every((item) => item is int);

    final validInitialSolutionPath =
        savedInitialSolutionPath is List &&
        savedInitialSolutionPath.every((item) => item is int);

    // Restore hint history safely.
    final parsedHintHistory = rawHintHistory is List
        ? rawHintHistory
            .whereType<List>()
            .map((path) => path.whereType<int>().toList())
            .toList()
        : <List<int>>[];

    // Create puzzle model.
    _model = PuzzleModel(
      size: widget.size,
      board: generatedBoard,

      initialBoard: validInitialBoard
          ? savedInitialBoard.cast<int>()
          : generatedBoard,

      solutionPath: validSolutionPath
          ? savedSolutionPath.cast<int>()
          : generatedPuzzle?.solutionPath,

      initialSolutionPath: validInitialSolutionPath
          ? savedInitialSolutionPath.cast<int>()
          : generatedPuzzle?.solutionPath,

      hintHistory: parsedHintHistory,

      moves: saved?['moves'] as int? ?? 0,
      elapsedSeconds: saved?['elapsedSeconds'] as int? ?? 0,
      paused: saved?['paused'] as bool? ?? false,

      history: savedHistory is List &&
              savedHistory.every((index) => index is int)
          ? savedHistory.cast<int>()
          : const [],

      onChanged: _persist,
    );

    _model.addListener(_onModelChanged);
    _loadBannerAd();
  }

  void _loadBannerAd() {
    if (!AdService.isSupportedPlatform) return;

    final banner = BannerAd(
      adUnitId: AdService.bannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() => _isBannerAdReady = true);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner failed: $error');
          ad.dispose();
          if (identical(_bannerAd, ad)) {
            _bannerAd = null;
          }
        },
      ),
    );
    _bannerAd = banner;
    banner.load();
  }

  void _showHint() {
    AdService.instance.showRewarded(
      onReward: _applyHint,
      onNotReady: _applyHint,
    );
  }

  void _applyHint() {
    if (!mounted) return;
    _model.showHint();

    unawaited(
      widget.sound.play(
        'button',
        enabled: _settings.soundEnabled,
      ),
    );

    unawaited(
      _haptics.tap(
        enabled: _settings.hapticsEnabled,
      ),
    );
  }

  // Save game progress.
  Future<void> _persist() async {
    if (_model.isComplete) {
      await widget.storage.clearSavedGame();
    } else {
      await widget.storage.saveGame(_model.toJson());
    }
  }

  // Handle tile movement.
  void _attemptMove(int index) {
    final moved = _model.moveTile(index);

    if (moved) {
      unawaited(
        widget.sound.play(
          _model.isComplete ? 'place' : 'tile',
          enabled: _settings.soundEnabled,
        ),
      );

      unawaited(
        _haptics.tap(enabled: _settings.hapticsEnabled),
      );
    } else {
      unawaited(
        widget.sound.play(
          'invalid',
          enabled: _settings.soundEnabled,
        ),
      );
    }
  }

  // Listen for puzzle completion.
  void _onModelChanged() {
    if (_model.isComplete && !_resultPresented) {
      _resultPresented = true;
      unawaited(_completeGame());
    }
  }

  Future<void> _completeGame() async {
    await widget.storage.recordResult(
      widget.size,
      _model.moves,
      _model.elapsedSeconds,
    );

    await widget.storage.clearSavedGame();

    await widget.sound.play(
      'win',
      enabled: _settings.soundEnabled,
    );

    await _haptics.success(
      enabled: _settings.hapticsEnabled,
    );

    if (mounted) {
      await _showResult();
    }
    AdService.instance.maybeShowInterstitial();
  }

  // Show result dialog.
  Future<void> _showResult() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: ResultScreen(
          size: widget.size,
          moves: _model.moves,
          seconds: _model.elapsedSeconds,

          bestMoves:
              widget.storage.bestMoves(widget.size) ?? _model.moves,

          bestTime: widget.storage.bestTime(widget.size),

          onShare: () {
            unawaited(
              SharePlus.instance.share(
                ShareParams(
                  text:
                      'I solved the ${widget.size}×${widget.size} Wooden Puzzle in '
                      '${_model.moves} moves and '
                      '${StatisticsPanel.formatTime(_model.elapsedSeconds)}!',
                ),
              ),
            );
          },

          onReplay: () {
            Navigator.pop(dialogContext);

            _model.restart();

            _resultPresented = false;
          },

          onHome: () {
            Navigator.pop(dialogContext);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  // Pause automatically when app goes into background.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _model.setPaused(true);
      unawaited(_persist());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _model.removeListener(_onModelChanged);

    _bannerAd?.dispose();

    unawaited(_persist());

    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          unawaited(_persist());
        }
      },

      child: Scaffold(
        body: SafeArea(
          child: AnimatedBuilder(
            animation: _model,

            builder: (context, _) => Stack(
              fit: StackFit.expand,

              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    17,
                    7,
                    17,
                    12,
                  ),

                  child: Column(
                    children: [
                      // Game header.
                      GameHeader(
                        size: size,
                        daily: widget.dailySeed != null,
                        paused: _model.paused,

                        onBack: () async {
                          await _persist();

                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },

                        onPause: () {
                          _model.togglePause();

                          unawaited(
                            widget.sound.play(
                              'button',
                              enabled: _settings.soundEnabled,
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 7),

                      // Game statistics.
                      StatisticsPanel(
                        moves: _model.moves,
                        seconds: _model.elapsedSeconds,

                        bestMoves:
                            widget.storage.bestMoves(size),

                        bestTime:
                            widget.storage.bestTime(size),
                      ),

                      const SizedBox(height: 13),

                      // Wooden puzzle board.
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final side = min(
                              constraints.maxWidth,
                              constraints.maxHeight,
                            );

                            return Center(
                              child: SizedBox(
                                width: side,
                                height: side,

                                child: WoodenBoard(
                                  model: _model,

                                  animationsEnabled:
                                      _settings.animationsEnabled,

                                  onTileTap: _attemptMove,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Game controls.
                      GameControls(
                        onShuffle: () {
                          unawaited(
                            widget.sound.play(
                              'shuffle',
                              enabled: _settings.soundEnabled,
                            ),
                          );

                          _model.shuffle(
                            seed: Random().nextInt(1 << 31),
                          );
                        },

                        onRestart: () {
                          unawaited(
                            widget.sound.play(
                              'button',
                              enabled: _settings.soundEnabled,
                            ),
                          );

                          unawaited(_confirmRestart());
                        },

                        // HINT BUTTON.
                        onHint: _showHint,

                        onUndo: () {
                          _model.undo();

                          unawaited(
                            widget.sound.play(
                              'button',
                              enabled: _settings.soundEnabled,
                            ),
                          );
                        },

                        onSound: () {
                          final updated = _settings.copyWith(
                            soundEnabled: !_settings.soundEnabled,
                          );

                          setState(() {
                            _settings = updated;
                          });

                          unawaited(
                            widget.onSettingsChanged(updated),
                          );

                          unawaited(
                            widget.sound.play(
                              'button',
                              enabled: updated.soundEnabled,
                            ),
                          );
                        },

                        soundEnabled: _settings.soundEnabled,

                        canUndo:
                            _model.canUndo && !_model.paused,
                      ),

                      if (_isBannerAdReady && _bannerAd != null) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          width: _bannerAd!.size.width.toDouble(),
                          height: _bannerAd!.size.height.toDouble(),
                          child: AdWidget(ad: _bannerAd!),
                        ),
                      ],
                    ],
                  ),
                ),

                // Pause overlay.
                if (_model.paused)
                  Positioned.fill(
                    child: ColoredBox(
                      color: Colors.black.withAlpha(175),

                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 27,
                          ),

                          decoration: BoxDecoration(
                            color: PuzzleConstants.walnutLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: PuzzleConstants.gold,
                            ),
                          ),

                          child: Column(
                            mainAxisSize: MainAxisSize.min,

                            children: [
                              const Icon(
                                Icons.pause_circle_outline_rounded,
                                size: 42,
                                color: PuzzleConstants.gold,
                              ),

                              const SizedBox(height: 8),

                              const Text(
                                'PAUSED',

                                style: TextStyle(
                                  color: PuzzleConstants.cream,
                                  fontSize: 18,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 18),

                              WoodenButton(
                                label: 'RESUME',
                                icon: Icons.play_arrow_rounded,
                                primary: true,

                                onPressed: () {
                                  _model.togglePause();

                                  unawaited(
                                    widget.sound.play(
                                      'button',
                                      enabled: _settings.soundEnabled,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Restart confirmation.
  Future<void> _confirmRestart() async {
    final confirmed = await showDialog<bool>(
      context: context,

      builder: (context) => AlertDialog(
        backgroundColor: PuzzleConstants.walnutLight,

        title: const Text(
          'Start over?',
          style: TextStyle(
            color: PuzzleConstants.cream,
          ),
        ),

        content: const Text(
          'Your current progress will be lost.',
          style: TextStyle(
            color: PuzzleConstants.muted,
          ),
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),

            child: const Text('KEEP PLAYING'),
          ),

          TextButton(
            onPressed: () => Navigator.pop(context, true),

            child: const Text(
              'RESTART',

              style: TextStyle(
                color: PuzzleConstants.gold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _model.restart();
    }
  }
}
