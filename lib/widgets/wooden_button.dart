import 'package:flutter/material.dart';

import '../utils/puzzle_constants.dart';

class WoodenButton extends StatefulWidget {
  const WoodenButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.primary = false,
    this.compact = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool primary;
  final bool compact;

  @override
  State<WoodenButton> createState() => _WoodenButtonState();
}

class _WoodenButtonState extends State<WoodenButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final background = widget.primary
        ? PuzzleConstants.oak
        : PuzzleConstants.mediumWood;
    return GestureDetector(
      onTapDown: widget.onPressed == null
          ? null
          : (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: widget.onPressed == null
          ? null
          : (_) => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.compact ? 14 : 22,
            vertical: widget.compact ? 11 : 15,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: PuzzleConstants.oakLight.withAlpha(100)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(70),
                offset: Offset(0, _pressed ? 1 : 4),
                blurRadius: _pressed ? 2 : 5,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 19, color: PuzzleConstants.cream),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  color: PuzzleConstants.cream,
                  fontSize: widget.compact ? 13 : 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.7,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
