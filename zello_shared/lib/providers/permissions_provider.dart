import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/permission.dart';
import '../providers/api_client_provider.dart';
import '../providers/auth_provider.dart';

final professionalPermissionsProvider = FutureProvider.family<List<Permission>, String>((ref, professionalId) async {
  final api = ref.read(apiClientProvider);
  final data = await api.getProfessionalPermissions(professionalId);
  return data
      .map((json) => Permission.fromJson(json as Map<String, dynamic>))
      .toList();
});

final canAccessProvider = Provider.family<bool, String>((ref, permission) {
  final auth = ref.watch(authProvider);
  final user = auth.user;
  if (user == null || !user.isProfessional) return true;
  final professionalId = user.professionalId;
  if (professionalId == null) return false;
  final permissionsAsync = ref.watch(professionalPermissionsProvider(professionalId));
  final permissions = permissionsAsync.valueOrNull ?? [];
  return permissions.any((p) => p.permission == permission);
});
