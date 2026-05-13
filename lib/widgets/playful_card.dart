import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/playful_theme.dart';

class PlayfulCard extends StatefulWidget {
  final Widget child;
  final Color? accentColor;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const PlayfulCard({
    super.key,
    required this.child,
    this.accentColor,
    this.padding,
    this.onTap,
  });

  @override
  State<PlayfulCard> createState() => _PlayfulCardState();
}

class _PlayfulCardState extends State<PlayfulCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..scale(_isPressed ? 0.95 : (_isHovered ? 1.02 : 1.0))
            ..translate(0.0, _isHovered ? -5.0 : 0.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: (widget.accentColor ?? Colors.black).withOpacity(_isHovered ? 0.15 : 0.05),
                blurRadius: _isHovered ? 20 : 10,
                offset: Offset(0, _isHovered ? 10 : 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                if (widget.accentColor != null)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 6,
                    child: Container(color: widget.accentColor),
                  ),
                Padding(
                  padding: widget.padding ?? const EdgeInsets.all(20),
                  child: widget.child,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad);
  }
}
