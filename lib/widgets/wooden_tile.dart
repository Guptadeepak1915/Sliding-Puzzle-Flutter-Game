import 'package:flutter/material.dart';

import '../utils/puzzle_constants.dart';

class WoodenTile extends StatefulWidget {
  const WoodenTile({
    required this.number,
    required this.size,
    required this.onTap,
    required this.highlighted,
    super.key,
  });

  final int number;
  final int size;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  State<WoodenTile> createState() => _WoodenTileState();
}

class _WoodenTileState extends State<WoodenTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final numberSize = (42 - widget.size * 3).clamp(22, 34).toDouble();
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 90),
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _WoodGrainPainter(
              highlighted: widget.highlighted,
              color: widget.highlighted
                  ? PuzzleConstants.oakLight
                  : PuzzleConstants.oak,
            ),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: widget.highlighted
                      ? PuzzleConstants.cream
                      : PuzzleConstants.oakLight.withAlpha(175),
                  width: widget.highlighted ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(85),
                    offset: Offset(0, _pressed ? 1 : 4),
                    blurRadius: _pressed ? 2 : 4,
                  ),
                  const BoxShadow(
                    color: Color(0x33FFF0CE),
                    offset: Offset(-1, -1),
                    blurRadius: 2,
                  ),
                ],
              ),
              child: Text(
                '${widget.number}',
                style: TextStyle(
                  color: PuzzleConstants.walnut,
                  fontSize: numberSize,
                  fontWeight: FontWeight.w800,
                  shadows: const [
                    Shadow(color: Color(0x55FFF0CE), offset: Offset(0, 1)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WoodGrainPainter extends CustomPainter {
  const _WoodGrainPainter({required this.color, required this.highlighted});

  final Color color;
  final bool highlighted;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = PuzzleConstants.mediumWood.withAlpha(highlighted ? 42 : 27)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    for (var line = 0; line < 3; line++) {
      final y = size.height * (0.25 + line * 0.24);
      final path = Path()
        ..moveTo(size.width * 0.12, y)
        ..quadraticBezierTo(
          size.width * 0.46,
          y - size.height * 0.06,
          size.width * 0.88,
          y + size.height * 0.025,
        );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_WoodGrainPainter oldDelegate) =>
      color != oldDelegate.color || highlighted != oldDelegate.highlighted;
}
