import 'package:flutter/material.dart';
import '../core/theme/zello_theme.dart';

class ZelloBadge extends StatelessWidget {
  final String label;
  final ZelloBadgeVariant variant;
  final double? fontSize;

  const ZelloBadge({
    super.key,
    required this.label,
    this.variant = ZelloBadgeVariant.default$,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(12),
        border: variant == ZelloBadgeVariant.outline
            ? Border.all(color: ZelloColors.border)
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.$2,
          fontSize: fontSize ?? 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (Color, Color) _getColors() {
    switch (variant) {
      case ZelloBadgeVariant.default$:
        return (ZelloColors.primary, Colors.white);
      case ZelloBadgeVariant.medical:
        return (ZelloColors.medical, Colors.white);
      case ZelloBadgeVariant.psychology:
        return (ZelloColors.psychology, Colors.white);
      case ZelloBadgeVariant.success:
        return (ZelloColors.accent, Colors.white);
      case ZelloBadgeVariant.warning:
        return (ZelloColors.warning, Colors.white);
      case ZelloBadgeVariant.outline:
        return (Colors.transparent, ZelloColors.textPrimary);
    }
  }
}

enum ZelloBadgeVariant {
  default$,
  medical,
  psychology,
  success,
  warning,
  outline,
}
