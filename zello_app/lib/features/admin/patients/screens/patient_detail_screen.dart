import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zello_shared/zello_shared.dart';
import '../widgets/add_consultation_dialog.dart';
import '../widgets/add_medication_dialog.dart';
import '../widgets/add_session_note_dialog.dart';
import '../widgets/add_referral_dialog.dart';

final _patientDetailProvider =
    FutureProvider.family<Patient, String>((ref, patientId) async {
  final api = ref.read(apiClientProvider);
  final data = await api.getPatient(patientId);
  return Patient.fromJson(data);
});

class PatientDetailScreen extends ConsumerWidget {
  final String patientId;
  const PatientDetailScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientAsync = ref.watch(_patientDetailProvider(patientId));
    final auth = ref.watch(authProvider);
    final isPsicologo = auth.isPsicologo;

    // Verifica permissões individuais
    final canConsultations = ref.watch(canAccessProvider('consultations'));
    final canMedications = ref.watch(canAccessProvider('medications'));

    // Monta lista de abas conforme permissões
    final tabs = <Tab>[];
    final tabWidgets = <Widget Function(Patient)>[];

    if (isPsicologo) {
      if (canConsultations) {
        tabs.add(const Tab(icon: Icon(LucideIcons.calendar), text: 'Consultas'));
        tabWidgets.add((p) => _ConsultationsTab(patient: p));
      }
      tabs.add(const Tab(icon: Icon(LucideIcons.brain), text: 'Sessões'));
      tabWidgets.add((p) => _SessionNotesTab(patient: p));
      tabs.add(const Tab(icon: Icon(LucideIcons.send), text: 'Encaminhamentos'));
      tabWidgets.add((p) => _ReferralsTab(patient: p));
    } else {
      if (canMedications) {
        tabs.add(const Tab(icon: Icon(LucideIcons.pill), text: 'Medicações'));
        tabWidgets.add((p) => _MedicationsTab(patient: p));
      }
      if (canConsultations) {
        tabs.add(const Tab(icon: Icon(LucideIcons.calendar), text: 'Consultas'));
        tabWidgets.add((p) => _ConsultationsTab(patient: p));
      }
    }

    final hasTabs = tabs.isNotEmpty;

    return DefaultTabController(
      length: hasTabs ? tabs.length : 1,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          backgroundColor: const Color(0xFF1565C0),
          foregroundColor: Colors.white,
          title: patientAsync.when(
            data: (p) =>
                Text(p.name, style: const TextStyle(fontSize: 18, color: Colors.white)),
            loading: () =>
                const Text('Carregando...', style: TextStyle(color: Colors.white)),
            error: (_, __) =>
                const Text('Paciente', style: TextStyle(color: Colors.white)),
          ),
          bottom: hasTabs
              ? TabBar(
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  tabs: tabs,
                )
              : null,
        ),
        body: patientAsync.when(
          data: (patient) {
            if (!hasTabs) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.lock, size: 64, color: Color(0xFFD1D5DB)),
                    SizedBox(height: 16),
                    Text(
                      'Você não tem permissão para acessar\nnenhuma seção deste paciente.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              );
            }
            return TabBarView(
              children: tabWidgets.map((fn) => fn(patient)).toList(),
            );
          },
          loading: () => const LoadingState(),
          error: (e, _) => ErrorState(
            message: 'Não foi possível carregar os dados do paciente.',
            technicalDetails: '$e',
            onRetry: () => ref.invalidate(_patientDetailProvider(patientId)),
          ),
        ),
      ),
    );
  }
}


// ============================================================
// _ConsultationsTab (Admin/Médico/Psicólogo)
// ============================================================
class _ConsultationsTab extends ConsumerWidget {
  final Patient patient;
  const _ConsultationsTab({required this.patient});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consultationsAsync =
        ref.watch(patientConsultationsProvider(patient.id));

    return Stack(
      children: [
        consultationsAsync.when(
          data: (consultations) => consultations.isEmpty
              ? const EmptyState(
                  icon: LucideIcons.calendar,
                  title: 'Nenhuma consulta cadastrada',
                  subtitle: 'Toque + para agendar a primeira consulta.',
                )
              : RefreshIndicator(
                  onRefresh: () async =>
                      ref.invalidate(patientConsultationsProvider(patient.id)),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: consultations.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _ItemCard(
                        title: consultations[i].doctorName,
                        subtitle: consultations[i].specialty,
                        trailing: consultations[i].status.name,
                        icon: LucideIcons.user,
                        onTap: () => _showItemDetails(
                          context,
                          title: consultations[i].doctorName,
                          subtitle: consultations[i].specialty,
                          status: consultations[i].status.name,
                          icon: LucideIcons.user,
                        ),
                      ),
                    ),
                  ),
                ),
          loading: () => const LoadingState(linesPerCard: 2),
          error: (e, _) => ErrorState(
            message: 'Não foi possível carregar as consultas.',
            technicalDetails: '$e',
            onRetry: () =>
                ref.invalidate(patientConsultationsProvider(patient.id)),
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => AddConsultationDialog(patientId: patient.id),
            ),
            child: const Icon(LucideIcons.plus),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// _MedicationsTab (Médico/Admin apenas)
// ============================================================
class _MedicationsTab extends ConsumerWidget {
  final Patient patient;
  const _MedicationsTab({required this.patient});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicationsAsync =
        ref.watch(patientMedicationsProvider(patient.id));

    return Stack(
      children: [
        medicationsAsync.when(
          data: (medications) => medications.isEmpty
              ? const EmptyState(
                  icon: LucideIcons.pill,
                  title: 'Nenhuma medicação cadastrada',
                  subtitle: 'Toque + para adicionar a primeira medicação.',
                )
              : RefreshIndicator(
                  onRefresh: () async =>
                      ref.invalidate(patientMedicationsProvider(patient.id)),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: medications.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _ItemCard(
                        title: medications[i].name,
                        subtitle:
                            '${medications[i].dosage} - ${medications[i].frequency}',
                        trailing: medications[i].isActive ? 'Ativo' : 'Inativo',
                        icon: LucideIcons.pill,
                        onTap: () => _showItemDetails(
                          context,
                          title: medications[i].name,
                          subtitle:
                              '${medications[i].dosage} - ${medications[i].frequency}',
                          status: medications[i].isActive ? 'Ativo' : 'Inativo',
                          icon: LucideIcons.pill,
                        ),
                      ),
                    ),
                  ),
                ),
          loading: () => const LoadingState(linesPerCard: 2),
          error: (e, _) => ErrorState(
            message: 'Não foi possível carregar as medicações.',
            technicalDetails: '$e',
            onRetry: () =>
                ref.invalidate(patientMedicationsProvider(patient.id)),
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => AddMedicationDialog(patientId: patient.id),
            ),
            child: const Icon(LucideIcons.plus),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// _SessionNotesTab (Psicólogo)
// ============================================================
class _SessionNotesTab extends ConsumerWidget {
  final Patient patient;
  const _SessionNotesTab({required this.patient});

  String _getMoodEmoji(String mood) {
    switch (mood) {
      case 'ansioso':
        return '??';
      case 'triste':
        return '??';
      case 'calmo':
        return '??';
      case 'feliz':
        return '??';
      case 'irritado':
        return '??';
      default:
        return '??';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(patientSessionNotesProvider(patient.id));

    return Stack(
      children: [
        notesAsync.when(
          data: (notes) => notes.isEmpty
              ? const EmptyState(
                  icon: LucideIcons.brain,
                  title: 'Nenhuma sessão registrada',
                  subtitle:
                      'Toque + para registrar a primeira sessão/evolução.',
                )
              : RefreshIndicator(
                  onRefresh: () async =>
                      ref.invalidate(patientSessionNotesProvider(patient.id)),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: notes.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AnimatedCard(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    _getMoodEmoji(notes[i].mood),
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${notes[i].date.day.toString().padLeft(2, '0')}/${notes[i].date.month.toString().padLeft(2, '0')}/${notes[i].date.year}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: ZelloColors.primary
                                          .withAlpha(25),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      notes[i].status,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: ZelloColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (notes[i].content.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  notes[i].content,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                    height: 1.4,
                                  ),
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
          loading: () => const LoadingState(linesPerCard: 2),
          error: (e, _) => ErrorState(
            message: 'Não foi possível carregar as sessões.',
            technicalDetails: '$e',
            onRetry: () =>
                ref.invalidate(patientSessionNotesProvider(patient.id)),
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            backgroundColor: ZelloColors.primary,
            onPressed: () => showDialog(
              context: context,
              builder: (_) => AddSessionNoteDialog(patientId: patient.id),
            ),
            child: const Icon(LucideIcons.plus),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// _ReferralsTab (Psicólogo)
// ============================================================
class _ReferralsTab extends ConsumerWidget {
  final Patient patient;
  const _ReferralsTab({required this.patient});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final referralsAsync = ref.watch(patientReferralsProvider(patient.id));

    return Stack(
      children: [
        referralsAsync.when(
          data: (referrals) => referrals.isEmpty
              ? const EmptyState(
                  icon: LucideIcons.send,
                  title: 'Nenhum encaminhamento',
                  subtitle: 'Toque + para encaminhar para outra especialidade.',
                )
              : RefreshIndicator(
                  onRefresh: () async =>
                      ref.invalidate(patientReferralsProvider(patient.id)),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: referrals.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AnimatedCard(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: ZelloColors.primaryLighter
                                          .withAlpha(25),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                        LucideIcons.send,
                                        color: ZelloColors.primaryLighter),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          referrals[i].toSpecialty.isNotEmpty
                                              ? referrals[i].toSpecialty
                                              : 'Especialidade não informada',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14),
                                        ),
                                        Text(
                                          referrals[i].status == 'ativo'
                                              ? 'Ativo'
                                              : 'Concluído',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: referrals[i].status ==
                                                    'ativo'
                                                ? ZelloColors.primaryLighter
                                                : ZelloColors.primaryLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (referrals[i].reason.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  referrals[i].reason,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
          loading: () => const LoadingState(linesPerCard: 2),
          error: (e, _) => ErrorState(
            message: 'Não foi possível carregar os encaminhamentos.',
            technicalDetails: '$e',
            onRetry: () =>
                ref.invalidate(patientReferralsProvider(patient.id)),
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            backgroundColor: ZelloColors.primaryLighter,
            onPressed: () => showDialog(
              context: context,
              builder: (_) => AddReferralDialog(patientId: patient.id),
            ),
            child: const Icon(LucideIcons.plus),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// Bottom sheet de detalhe (torna os itens clicáveis)
// ============================================================
void _showItemDetails(
  BuildContext context, {
  required String title,
  required String subtitle,
  String? status,
  IconData icon = LucideIcons.fileText,
}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => Padding(
      padding:
          const EdgeInsets.fromLTRB(24, 20, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: ZelloColors.primaryLight.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: ZelloColors.primaryLight, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _DetailRow(label: 'Descrição', value: subtitle),
          if (status != null) ...[
            const SizedBox(height: 8),
            _DetailRow(label: 'Status', value: status),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(ctx),
              style: OutlinedButton.styleFrom(
                foregroundColor: ZelloColors.primary,
                side: BorderSide(color: ZelloColors.primaryLight.withAlpha(120)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Fechar'),
            ),
          ),
        ],
      ),
    ),
  );
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(label,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E))),
        ),
      ],
    );
  }
}

// ============================================================
// _ItemCard (reutilizado das abas existentes)
// ============================================================
class _ItemCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? trailing;
  final IconData icon;
  final Widget? trailingWidget;
  final VoidCallback? onTap;

  const _ItemCard({
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.icon,
    this.trailingWidget,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0).withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF1565C0), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF1A1A2E))),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF6B7280))),
              ],
            ),
          ),
          if (trailingWidget != null)
            trailingWidget!
          else if (trailing != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(trailing!,
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280))),
            ),
        ],
      ),
    );
  }
}