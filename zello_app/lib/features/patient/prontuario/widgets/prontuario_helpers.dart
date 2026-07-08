import 'package:flutter/material.dart';
import 'package:zello_shared/zello_shared.dart';

Widget infoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: ZelloColors.textSecondary)),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: ZelloColors.textPrimary)),
      ],
    ),
  );
}

Widget multiLineInfo(String label, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TextStyle(fontSize: 12, color: ZelloColors.textTertiary, fontWeight: FontWeight.w500)),
      const SizedBox(height: 2),
      Text(value, style: TextStyle(fontSize: 13, color: ZelloColors.textSecondary, height: 1.4)),
    ],
  );
}

Widget sectionLabel(String label, IconData icon) {
  return Row(
    children: [
      Icon(icon, size: 18, color: ZelloColors.textSecondary),
      const SizedBox(width: 8),
      Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: ZelloColors.textPrimary)),
    ],
  );
}

Widget riskBadge(String risk) {
  Color color;
  IconData icon;
  String label;

  switch (risk) {
    case 'alto':
      color = ZelloColors.danger;
      icon = Icons.warning;
      label = 'Risco Alto';
      break;
    case 'moderado':
      color = ZelloColors.warning;
      icon = Icons.info_outline;
      label = 'Risco Moderado';
      break;
    default:
      color = ZelloColors.success;
      icon = Icons.check_circle_outline;
      label = 'Risco Baixo';
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: color.withAlpha(20),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withAlpha(60)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: color)),
      ],
    ),
  );
}
