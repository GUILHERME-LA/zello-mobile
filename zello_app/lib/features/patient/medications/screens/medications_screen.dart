import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zello_shared/zello_shared.dart';

class MedicationsScreen extends ConsumerStatefulWidget {
  const MedicationsScreen({super.key});

  @override
  ConsumerState<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends ConsumerState<MedicationsScreen> {
  final Set<String> _takenIds = {};
  bool _showActive = true;

  void _toggleTaken(String id) {
    setState(() {
      if (_takenIds.contains(id)) {
        _takenIds.remove(id);
      } else {
        _takenIds.add(id);
      }
    });
  }

  void _showMedicationDetail(Medication med) {
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
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                  ),
                  child: const Icon(Icons.medication, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(med.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                      Text(med.dosage, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _detailRow('Frequência', med.frequency),
            const SizedBox(height: 12),
            _detailRow('Médico', med.prescribingDoctor),
            const SizedBox(height: 12),
            _detailRow('Início', med.startDate != null ? Formatters.formatDate(med.startDate!) : 'Data não informada'),
            if (med.endDate != null) ...[
              const SizedBox(height: 12),
              _detailRow('Término', Formatters.formatDate(med.endDate!)),
            ],
            const SizedBox(height: 12),
            _detailRow('Status', med.isActive ? 'Ativo' : 'Inativo'),
          ],
        ),
      ),
    );
  }

  static Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A2E), fontWeight: FontWeight.w600)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(medicationsProvider);
    return async.when(
      data: (meds) {
        final activeMeds = meds.where((m) => m.isActive).toList();
        final inactiveMeds = meds.where((m) => !m.isActive).toList();
        final displayedMeds = _showActive ? activeMeds : inactiveMeds;

        return Scaffold(
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(medicationsProvider),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          _FilterChip(
                            label: 'Ativas',
                            count: activeMeds.length,
                            isSelected: _showActive,
                            onTap: () => setState(() => _showActive = true),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Histórico',
                            count: inactiveMeds.length,
                            isSelected: !_showActive,
                            onTap: () => setState(() => _showActive = false),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SectionHeader(
                      title: _showActive ? 'Medicações Ativas' : 'Histórico',
                      subtitle: '${displayedMeds.length} ${displayedMeds.length == 1 ? 'item' : 'itens'}',
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: displayedMeds.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 40),
                                child: Text(
                                  _showActive
                                      ? 'Nenhuma medicação ativa'
                                      : 'Nenhuma medicação encerrada',
                                  style: const TextStyle(color: Color(0xFF6B7280)),
                                ),
                              ),
                            )
                          : Column(
                              children: displayedMeds.map((m) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _MedicationCard(
                                  name: m.name,
                                  dosage: m.dosage,
                                  doctor: m.prescribingDoctor,
                                  isActive: m.isActive,
                                  isTaken: _takenIds.contains(m.id),
                                  onToggle: m.isActive ? () => _toggleTaken(m.id) : null,
                                  onTap: () => _showMedicationDetail(m),
                                ),
                              )).toList(),
                            ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => _buildLoading(),
      error: (e, _) => Scaffold(body: Center(child: Text('Erro: $e'))),
    );
  }

  Widget _buildLoading() {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 8),
              ...List.generate(4, (_) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: SkeletonCard(),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24),
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.medication, color: Colors.white, size: 28),
          SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Medicações', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20)),
              SizedBox(height: 2),
              Text('Acompanhe seus medicamentos', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MedicationCard extends StatelessWidget {
  final String name;
  final String dosage;
  final String doctor;
  final bool isActive;
  final bool isTaken;
  final VoidCallback? onToggle;
  final VoidCallback? onTap;

  const _MedicationCard({
    required this.name, required this.dosage,
    this.doctor = '',
    required this.isActive, required this.isTaken,
    this.onToggle, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isTaken ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
    return AnimatedCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(14)),
            child: Icon(Icons.medication, color: color, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF1A1A2E))),
                const SizedBox(height: 2),
                Text(dosage, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                if (doctor.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text('Dr(a). $doctor', style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(isTaken ? Icons.check_circle : Icons.access_time, size: 14, color: color),
                    const SizedBox(width: 4),
                    Text(isTaken ? 'Tomado' : isActive ? 'Pendente' : 'Inativo',
                        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
          if (onToggle != null && isActive)
            GestureDetector(
              onTap: onToggle,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isTaken ? const Color(0xFF10B981) : const Color(0xFF1565C0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(isTaken ? 'Tomado' : 'Confirmar',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1565C0) : const Color(0xFFF5F9FF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF1565C0) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label ($count)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
