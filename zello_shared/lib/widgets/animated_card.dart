import 'package:flutter/material.dart';
import '../core/theme/zello_theme.dart';
import '../core/theme/zello_shadows.dart';

class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? backgroundColor;
  final bool enabled;

  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.backgroundColor,
    this.enabled = true,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _elevation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _elevation = Tween<double>(begin: 1, end: 4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shadows = isDark ? ZelloShadows.darkSm : ZelloShadows.sm;

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) => Transform.scale(
        scale: _scale.value,
        child: Container(
          padding: widget.padding ?? const EdgeInsets.all(16),
          margin: widget.margin,
          decoration: BoxDecoration(
            color: widget.backgroundColor ??
                Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: isDark
                  ? ZelloColors.darkBorder.withAlpha(80)
                  : ZelloColors.border.withAlpha(80),
            ),
            boxShadow: _elevation.value > 1 ? shadows : null,
          ),
          child: InkWell(
            onTap: widget.enabled && widget.onTap != null
                ? () {
                    _controller.forward().then((_) => _controller.reverse());
                    widget.onTap!();
                  }
                : null,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: child,
          ),
        ),
      ),
    );
  }
}
