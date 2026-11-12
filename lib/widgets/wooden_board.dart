import 'package:flutter/material.dart';

import '../models/puzzle_model.dart';
import '../utils/puzzle_constants.dart';
import 'wooden_tile.dart';

class WoodenBoard extends StatelessWidget {
  const WoodenBoard({
    required this.model,
    required this.animationsEnabled,
    this.onTileTap,
    super.key,
  });

  final PuzzleModel model;
  final bool animationsEnabled;
  final ValueChanged<int>? onTileTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.biggest.shortestSide;
        final board = model.board;
        final gap = model.size == 5 ? 7.0 : 9.0;
        final cell = (side - gap * (model.size + 1)) / model.size;
        return Container(
          width: side,
          height: side,
          padding: EdgeInsets.all(gap),
          decoration: BoxDecoration(
            color: const Color(0xFF53331F),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: PuzzleConstants.gold.withAlpha(180),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(100),
                offset: const Offset(0, 10),
                blurRadius: 18,
              ),
              const BoxShadow(
                color: Color(0x22F4E2C2),
                offset: Offset(-2, -2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (var index = 0; index < board.length; index++)
                _emptyCell(index, gap, cell, model.size),
              for (var index = 0; index < board.length; index++)
                if (board[index] != 0)
                  AnimatedPositioned(
                    key: ValueKey(board[index]),
                    duration: animationsEnabled
                        ? PuzzleConstants.moveDuration
                        : Duration.zero,
                    curve: Curves.easeOutCubic,
                    left: (index % model.size) * (cell + gap),
                    top: (index ~/ model.size) * (cell + gap),
                    width: cell,
                    height: cell,
                    child: WoodenTile(
                      number: board[index],
                      size: model.size,
                      highlighted: model.highlightedIndex == index,
                      onTap: () {
                        if (onTileTap case final callback?) {
                          callback(index);
                        } else {
                          model.moveTile(index);
                        }
                      },
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }

  Widget _emptyCell(int index, double gap, double cell, int size) {
    return Positioned(
      left: (index % size) * (cell + gap),
      top: (index ~/ size) * (cell + gap),
      width: cell,
      height: cell,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: PuzzleConstants.walnut.withAlpha(100),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: PuzzleConstants.walnut.withAlpha(160)),
        ),
      ),
    );
  }
}
