import 'package:flutter/material.dart';
import 'package:zello_shared/zello_shared.dart';

class ProntuarioItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? trailing;
  final String notes;
  final bool isUrgent;
  final bool isPending;

  const ProntuarioItem({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.notes = '',
    this.isUrgent = false,
    this.isPending = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
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
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isUrgent ? ZelloColors.danger : ZelloColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (trailing != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isPending
                              ? ZelloColors.warning.withAlpha(25)
                              : isUrgent
                                  ? ZelloColors.danger.withAlpha(15)
                                  : ZelloColors.textTertiary.withAlpha(15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          trailing!,
                          style: TextStyle(
                            fontSize: 10,
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
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 11, color: ZelloColors.textSecondary), overflow: TextOverflow.ellipsis),
                ],
                if (notes.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(notes, style: TextStyle(fontSize: 11, color: ZelloColors.textTertiary, fontStyle: FontStyle.italic), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
