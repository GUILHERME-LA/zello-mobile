import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zello_shared/zello_shared.dart';

import 'add_exam_dialog.dart';

class ExamsScreen extends ConsumerStatefulWidget {
  const ExamsScreen({super.key});

  @override
  ConsumerState<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends ConsumerState<ExamsScreen> {
  String _filter = 'todos';

  Color _statusColor(String status) {
    switch (status) {
      case 'concluido':
        return const Color(0xFF10B981);
      case 'confirmado':
        return const Color(0xFF1565C0);
      case 'recusado':
      case 'cancelado':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  void _showExamDetail(Exam exam) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, scroll) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: ListView(
            controller: scroll,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
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
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _statusColor(exam.status).withAlpha(25),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(LucideIcons.flaskConical,
                        color: _statusColor(exam.status), size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(exam.title,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A2E))),
                        Text(exam.examType,
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF6B7280))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _detailRow('Status', exam.statusLabel),
              const SizedBox(height: 12),
              if (exam.requestedAt != null)
                _detailRow('Solicitado em',
                    Formatters.formatDate(exam.requestedAt!)),
              const SizedBox(height: 12),
              if (exam.notes != null && exam.notes!.isNotEmpty)
                _detailRow('Observacoes', exam.notes!),
              const SizedBox(height: 12),
              if (exam.resultUrl != null && exam.resultUrl!.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: () => _openResult(exam.resultUrl!),
                  icon: const Icon(LucideIcons.externalLink),
                  label: const Text('Abrir resultado'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openResult(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      await launchUrl(uri);
    }
  }

  static Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500)),
        Expanded(
          child: Text(value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1A1A2E),
                  fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(examsProvider);
    return async.when(
      data: (exams) {
        final filtered = _filter == 'todos'
            ? exams
            : exams.where((e) => e.status == _filter).toList();
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => const AddExamDialog(),
            ),
            child: const Icon(LucideIcons.plus),
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(examsProvider),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _FilterChip(
                              label: 'Todos',
                              isSelected: _filter == 'todos',
                              onTap: () => setState(() => _filter = 'todos'),
                            ),
                            const SizedBox(width: 8),
                            ...Exam.statuses.map((s) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _FilterChip(
                                label: Exam.statusLabels[s] ?? s,
                                isSelected: _filter == s,
                                onTap: () => setState(() => _filter = s),
                              ),
                            )),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SectionHeader(
                      title: 'Exames',
                      subtitle:
                          '${filtered.length} ${filtered.length == 1 ? 'item' : 'itens'}',
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: filtered.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: Text('Nenhum exame encontrado.',
                                    style: TextStyle(color: Color(0xFF6B7280))),
                              ),
                            )
                          : Column(
                              children: filtered.map((e) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _ExamCard(
                                  title: e.title,
                                  type: e.examType,
                                  status: e.statusLabel,
                                  color: _statusColor(e.status),
                                  onTap: () => _showExamDetail(e),
                                ),
                              )).toList(),
                            ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => _buildLoading(),
      error: (e, _) => Scaffold(
        body: SafeArea(
          child: Center(child: Text('Erro: $e')),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 8),
              ...List.generate(
                  4,
                  (_) => const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        child: SkeletonCard(),
                      )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(38),
              borderRadius: BorderRadius.circular(14),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Exames',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 20)),
              SizedBox(height: 2),
              Text('Acompanhe seus exames e resultados',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  final String title;
  final String type;
  final String status;
  final Color color;
  final VoidCallback? onTap;

  const _ExamCard({
    required this.title,
    required this.type,
    required this.status,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(14)),
            child: Icon(LucideIcons.flaskConical, color: color, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF1A1A2E))),
                const SizedBox(height: 2),
                if (type.isNotEmpty)
                  Text(type,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF6B7280))),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(LucideIcons.circleDot, size: 14, color: color),
                    const SizedBox(width: 4),
                    Text(status,
                        style: TextStyle(
                            fontSize: 11,
                            color: color,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
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
            color: isSelected
                ? const Color(0xFF1565C0)
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}
