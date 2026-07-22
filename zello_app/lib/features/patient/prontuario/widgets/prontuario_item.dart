import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zello_shared/zello_shared.dart';

class ProntuarioItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? trailing;
  final String notes;
  final bool isUrgent;
  final bool isPending;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProntuarioItem({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.notes = '',
    this.isUrgent = false,
    this.isPending = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isUrgent)
            Container(
              width: 4,
              height: 40,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: ZelloColors.danger,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isUrgent ? ZelloColors.danger : ZelloColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (trailing != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isPending
                              ? ZelloColors.warning.withAlpha(20)
                              : isUrgent
                                  ? ZelloColors.danger.withAlpha(15)
                                  : ZelloColors.textTertiary.withAlpha(15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          trailing!,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isPending
                                ? ZelloColors.warning
                                : isUrgent
                                    ? ZelloColors.danger
                                    : ZelloColors.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12, color: ZelloColors.textSecondary),
                      overflow: TextOverflow.ellipsis),
                ],
                if (notes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(notes,
                      style: TextStyle(
                          fontSize: 12,
                          color: ZelloColors.textTertiary,
                          fontStyle: FontStyle.italic),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
          if (onEdit != null || onDelete != null) ...[
            const SizedBox(width: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onEdit != null)
                  IconButton(
                    onPressed: onEdit,
                    icon: Icon(LucideIcons.pencil, size: 16, color: Colors.grey.shade500),
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                    splashRadius: 18,
                  ),
                if (onDelete != null)
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(LucideIcons.trash2, size: 16, color: Colors.red.shade300),
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                    splashRadius: 18,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
