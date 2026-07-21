import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:zello_shared/zello_shared.dart';
import 'section_card.dart';

class TypedListSection<T> extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final AsyncValue<List<T>> async;
  final String emptyText;
  final Widget Function(T) itemBuilder;
  final bool isUrgent;
  final VoidCallback? onAdd;

  const TypedListSection({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.async,
    required this.emptyText,
    required this.itemBuilder,
    this.isUrgent = false,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return async.when(
      data: (items) => SectionCard(
        icon: icon,
        iconColor: iconColor,
        title: title,
        subtitle: '${items.length} ${items.length == 1 ? 'registro' : 'registros'}',
        isUrgent: isUrgent,
        trailing: onAdd != null
            ? SizedBox(
                width: 32,
                height: 32,
                child: IconButton(
                  onPressed: onAdd,
                  icon: const Icon(LucideIcons.plus, size: 18),
                  padding: EdgeInsets.zero,
                  tooltip: 'Adicionar $title',
                  style: IconButton.styleFrom(
                    backgroundColor: iconColor.withAlpha(20),
                    foregroundColor: iconColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              )
            : null,
        child: items.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(emptyText,
                    style: TextStyle(
                        fontSize: 13,
                        color: ZelloColors.textTertiary,
                        fontStyle: FontStyle.italic)),
              )
            : Column(
                children: items.asMap().entries.map((entry) {
                  return Column(
                    children: [
                      if (entry.key > 0) const Divider(height: 1),
                      itemBuilder(entry.value),
                    ],
                  );
                }).toList(),
              ),
      ),
      loading: () => SectionCard(
        icon: icon,
        iconColor: iconColor,
        title: title,
        child: const LinearProgressIndicator(),
      ),
      error: (e, _) => SectionCard(
        icon: icon,
        iconColor: iconColor,
        title: title,
        child: Text('Erro: $e',
            style: TextStyle(fontSize: 12, color: ZelloColors.danger)),
      ),
    );
  }
}
