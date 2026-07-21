import 'package:flutter/material.dart';
import '../core/theme/zello_theme.dart';

class GradientHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final double bottomPadding;
  final String? greeting;
  final bool showBack;

  const GradientHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.bottomPadding = 24,
    this.greeting,
    this.showBack = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPadding),
      decoration: BoxDecoration(
        gradient: ZelloGradients.header,
        borderRadius: ZelloRadius.headerRadius,
      ),
      child: Row(
        children: [
          if (showBack)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (greeting != null)
                  Text(
                    greeting!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withAlpha(179),
                        ),
                  ),
                if (greeting != null) const SizedBox(height: 2),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withAlpha(179),
                        ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
