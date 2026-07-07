import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/professional.dart';
import 'professionals_provider.dart';

/// Provider que filtra profissionais por tipo (medico, psicologo, etc.)
final filteredProfessionalsProvider =
    Provider.family<AsyncValue<List<Professional>>, String>((ref, type) {
  final allProfessionals = ref.watch(professionalsProvider);
  return allProfessionals.whenData(
    (list) => list.where((p) => p.type == type).toList(),
  );
});
