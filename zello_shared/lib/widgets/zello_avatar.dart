import 'package:flutter/material.dart';
import '../core/theme/zello_theme.dart';
import '../core/utils/formatters.dart';

class ZelloAvatar extends StatelessWidget {
  final String name;
  final double size;
  final String? imageUrl;
  final Color? backgroundColor;

  const ZelloAvatar({
    super.key,
    required this.name,
    this.size = 48,
    this.imageUrl,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final initials = Formatters.getInitials(name);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? ZelloColors.primary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.35,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
