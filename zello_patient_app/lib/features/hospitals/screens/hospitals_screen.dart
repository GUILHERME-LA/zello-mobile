import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zello_shared/zello_shared.dart';

class HospitalsScreen extends ConsumerWidget {
  const HospitalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(hospitalsProvider);
    return async.when(
      data: (hospitals) => Scaffold(
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async => ref.invalidate(hospitalsProvider),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 8),
                  SectionHeader(
                    title: 'Hospitais',
                    subtitle: '${hospitals.length} unidades encontradas',
                    trailing: const Icon(Icons.map_outlined, color: Color(0xFF1565C0), size: 22),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: hospitals.map((h) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _HospitalCard(item: h, onTap: () => _showDetail(context, h)),
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Erro: $e'))),
    );
  }

  static void _showDetail(BuildContext context, Hospital h) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(width: 48, height: 48, decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF0D47A1)]), borderRadius: BorderRadius.all(Radius.circular(14))),
                  child: const Icon(Icons.local_hospital, color: Colors.white, size: 24)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(h.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                    Text(h.address, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)), overflow: TextOverflow.ellipsis),
                  ]),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _detailRow(Icons.location_on, h.address),
            if (h.phone.isNotEmpty) ...[
              const SizedBox(height: 12),
              _detailRow(Icons.phone, h.phone),
            ],
            if (h.distance > 0) ...[
              const SizedBox(height: 12),
              _detailRow(Icons.near_me, '${h.distance.toStringAsFixed(1)} km'),
            ],
            if (h.plan.isNotEmpty) ...[
              const SizedBox(height: 12),
              _detailRow(Icons.health_and_safety, h.plan),
            ],
            if (h.phone.isNotEmpty) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ligando para ${h.phone}...'), behavior: SnackBarBehavior.floating,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
                  ),
                  icon: const Icon(Icons.phone, size: 18),
                  label: const Text('Ligar'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Widget _detailRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF6B7280)),
        const SizedBox(width: 10),
        Text(value, style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E), fontWeight: FontWeight.w500)),
      ],
    );
  }

  static Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1565C0), Color(0xFF0D47A1)]),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
      ),
      child: const Row(
        children: [
          Icon(Icons.local_hospital, color: Colors.white, size: 28),
          SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Hospitais', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20)),
            SizedBox(height: 2),
            Text('Encontre hospitais próximos', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ]),
        ],
      ),
    );
  }
}

class _HospitalCard extends StatelessWidget {
  final Hospital item;
  final VoidCallback? onTap;
  const _HospitalCard({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 48, height: 48,
                decoration: BoxDecoration(color: const Color(0xFF1565C0).withAlpha(25), borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.local_hospital, color: Color(0xFF1565C0), size: 24)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 12, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text('${item.distance.toStringAsFixed(1)} km',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)), overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ]),
              ),
              if (item.plan.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFF59E0B).withAlpha(25), borderRadius: BorderRadius.circular(8)),
                  child: Text(item.plan, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFF59E0B))),
                ),
            ],
          ),
          if (item.phone.isNotEmpty) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Ligando para ${item.phone}...'), behavior: SnackBarBehavior.floating,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFFF5F9FF), borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    Icon(Icons.phone, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Expanded(child: Text(item.phone, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)))),
                    const Text('Ligar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1565C0))),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
