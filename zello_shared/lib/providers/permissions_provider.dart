import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/permission.dart';
import '../providers/api_client_provider.dart';

final professionalPermissionsProvider = FutureProvider.family<List<Permission>, String>((ref, professionalId) async {
  final api = ref.read(apiClientProvider);
  final data = await api.getProfessionalPermissions(professionalId);
  return data
      .map((json) => Permission.fromJson(json as Map<String, dynamic>))
      .toList();
});
