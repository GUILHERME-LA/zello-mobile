import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dashboard_stats.dart';
import 'api_client_provider.dart';

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final api = ref.read(apiClientProvider);
  final data = await api.getDashboardStats();
  return DashboardStats.fromJson(data);
});
