import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:zello_shared/zello_shared.dart';

class ProntuarioPdf {
  /// Gera um PDF completo com todos os dados de saúde do paciente
  static Future<Uint8List> generate({
    required String patientName,
    required HealthProfile? profile,
    required List<dynamic> surgeries,
    required List<dynamic> hospitalizations,
    required List<dynamic> symptoms,
    required List<dynamic> allergies,
    required List<dynamic> vaccines,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(context),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          // Título
          pw.Center(
            child: pw.Column(
              children: [
                pw.Text(
                  'Histórico de Saúde',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  patientName,
                  style: pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Emitido em ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                  style: pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // --- SEÇÃO 1: DADOS DE SAÚDE ---
          if (profile != null) ...[
            _sectionTitle('Dados de Saúde'),
            _profileTable(profile),
            pw.SizedBox(height: 16),
          ],

          // --- SEÇÃO 2: CONDIÇÕES MÉDICAS ---
          if (profile != null && profile.medicalConditions.isNotEmpty) ...[
            _sectionTitle('Condições Médicas'),
            pw.Paragraph(text: profile.medicalConditions, style: pw.TextStyle(fontSize: 10, lineSpacing: 1.5)),
            pw.SizedBox(height: 12),
          ],

          // --- SEÇÃO 3: HISTÓRICO FAMILIAR ---
          if (profile != null && profile.familyHistory.isNotEmpty) ...[
            _sectionTitle('Histórico Familiar'),
            pw.Paragraph(text: profile.familyHistory, style: pw.TextStyle(fontSize: 10, lineSpacing: 1.5)),
            pw.SizedBox(height: 12),
          ],

          // --- SEÇÃO 4: CIRURGIAS ---
          _sectionTitle('Cirurgias (${surgeries.length})'),
          if (surgeries.isEmpty)
            _emptySection()
          else
            ...surgeries.map((s) => _itemCard(
                  title: s['name'] ?? '',
                  subtitle: _formatDate(s['date']),
                  details: [
                    if ((s['hospital'] ?? '').isNotEmpty) 'Hospital: ${s['hospital']}',
                    if ((s['doctor'] ?? '').isNotEmpty) 'Médico: ${s['doctor']}',
                    if ((s['notes'] ?? '').isNotEmpty) 'Obs: ${s['notes']}',
                  ],
                )),
          pw.SizedBox(height: 12),

          // --- SEÇÃO 5: INTERNAÇÕES ---
          _sectionTitle('Internações (${hospitalizations.length})'),
          if (hospitalizations.isEmpty)
            _emptySection()
          else
            ...hospitalizations.map((h) => _itemCard(
                  title: h['reason'] ?? '',
                  subtitle: '${_formatDate(h['startDate'])} a ${_formatDate(h['endDate']) ?? "em andamento"}',
                  details: [
                    if ((h['hospital'] ?? '').isNotEmpty) 'Hospital: ${h['hospital']}',
                    if ((h['notes'] ?? '').isNotEmpty) 'Obs: ${h['notes']}',
                  ],
                )),
          pw.SizedBox(height: 12),

          // --- SEÇÃO 6: SINTOMAS ---
          _sectionTitle('Sintomas Recorrentes (${symptoms.length})'),
          if (symptoms.isEmpty)
            _emptySection()
          else
            ...symptoms.map((s) => _itemCard(
                  title: s['name'] ?? '',
                  subtitle: '${s['frequency'] ?? ""}${s['frequency'] != null && s['frequency']!.isNotEmpty && s['intensity'] != null && s['intensity']!.isNotEmpty ? " — " : ""}${s['intensity'] ?? ""}',
                  details: [
                    if ((s['notes'] ?? '').isNotEmpty) 'Obs: ${s['notes']}',
                  ],
                )),
          pw.SizedBox(height: 12),

          // --- SEÇÃO 7: ALERGIAS ---
          _sectionTitle('Alergias (${allergies.length})'),
          if (allergies.isEmpty)
            _emptySection()
          else
            ...allergies.map((a) => _itemCard(
                  title: a['name'] ?? '',
                  subtitle: 'Tipo: ${a['type'] ?? ""}',
                  details: [
                    if ((a['reaction'] ?? '').isNotEmpty) 'Reação: ${a['reaction']}',
                    if ((a['notes'] ?? '').isNotEmpty) 'Obs: ${a['notes']}',
                  ],
                  isUrgent: true,
                )),
          pw.SizedBox(height: 12),

          // --- SEÇÃO 8: VACINAS ---
          _sectionTitle('Vacinas (${vaccines.length})'),
          if (vaccines.isEmpty)
            _emptySection()
          else
            ...vaccines.map((v) => _itemCard(
                  title: v['name'] ?? '',
                  subtitle: '${_formatDate(v['date'])}${v['dose'] != null && v['dose']!.isNotEmpty ? " — ${v['dose']}" : ""}',
                  details: [
                    if ((v['location'] ?? '').isNotEmpty) 'Local: ${v['location']}',
                    if ((v['notes'] ?? '').isNotEmpty) 'Obs: ${v['notes']}',
                    if (v['isPending'] == true) '⚠️ PENDENTE',
                  ],
                )),
          pw.SizedBox(height: 20),

          // Disclaimer
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.orange50,
              border: pw.Border.all(color: PdfColors.orange200),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('⚠️ ', style: pw.TextStyle(fontSize: 12)),
                pw.Expanded(
                  child: pw.Text(
                    'Este documento é um resumo informativo do prontuário e não substitui '
                    'documentos médicos oficiais. Em caso de emergência, procure atendimento '
                    'médico imediato.',
                    style: pw.TextStyle(fontSize: 8, color: PdfColors.orange800),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  /// Abre o print/preview do PDF
  static Future<void> preview(Uint8List pdfBytes) async {
    await Printing.layoutPdf(
      onLayout: (_) => pdfBytes,
    );
  }

  /// Salva o PDF em arquivo e retorna o path
  static Future<String> saveToFile(Uint8List pdfBytes, String fileName) async {
    final dir = Directory.systemTemp;
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(pdfBytes);
    return file.path;
  }
}

// ==================== HELPERS DE ESTILO ====================

pw.Widget _buildHeader(pw.Context context) {
  return pw.Container(
    alignment: pw.Alignment.centerRight,
    margin: const pw.EdgeInsets.only(bottom: 8),
    child: pw.Text(
      'Zello Saúde — Prontuário',
      style: pw.TextStyle(fontSize: 8, color: PdfColors.grey400),
    ),
  );
}

pw.Widget _buildFooter(pw.Context context) {
  return pw.Container(
    alignment: pw.Alignment.centerRight,
    margin: const pw.EdgeInsets.only(top: 8),
    child: pw.Text(
      'Página ${context.pageNumber}',
      style: pw.TextStyle(fontSize: 8, color: PdfColors.grey400),
    ),
  );
}

pw.Widget _sectionTitle(String title) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 0),
    decoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: PdfColors.blue200, width: 1)),
    ),
    child: pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 13,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.blue800,
      ),
    ),
  );
}

pw.Widget _emptySection() {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 8),
    child: pw.Text(
      'Nenhum registro encontrado.',
      style: pw.TextStyle(fontSize: 10, color: PdfColors.grey500, fontStyle: pw.FontStyle.italic),
    ),
  );
}

pw.Widget _itemCard({
  required String title,
  String? subtitle,
  List<String>? details,
  bool isUrgent = false,
}) {
  final borderColor = isUrgent ? PdfColors.red200 : PdfColors.grey300;

  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 6),
    padding: const pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: borderColor),
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      color: isUrgent ? PdfColors.red50 : PdfColors.white,
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            pw.Expanded(
              child: pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: isUrgent ? PdfColors.red800 : PdfColors.grey800,
                ),
              ),
            ),
          ],
        ),
        if (subtitle != null && subtitle.isNotEmpty) ...[
          pw.SizedBox(height: 2),
          pw.Text(subtitle, style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
        ],
        if (details != null && details.isNotEmpty) ...[
          pw.SizedBox(height: 4),
          ...details.where((d) => d.isNotEmpty).map((d) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 1),
                child: pw.Text(
                  d,
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: d.contains('PENDENTE') ? PdfColors.orange700 : PdfColors.grey600,
                  ),
                ),
              )),
        ],
      ],
    ),
  );
}

pw.Widget _profileTable(HealthProfile p) {
  final imc = p.imc;
  final cells = [
    _labelValue('Peso', p.weight > 0 ? '${p.weight.toStringAsFixed(0)} kg' : '—'),
    _labelValue('Altura', p.height > 0 ? '${p.height.toStringAsFixed(0)} cm' : '—'),
    _labelValue('IMC', imc > 0 ? '${imc.toStringAsFixed(1)} (${p.imcCategory})' : '—'),
    _labelValue('Tipo Sanguíneo', p.bloodType.isNotEmpty ? p.bloodType : '—'),
  ];

  return pw.Table(
    border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
    children: [
      pw.TableRow(
        children: cells.sublist(0, 2),
      ),
      pw.TableRow(
        children: cells.sublist(2, 4),
      ),
    ],
  );
}

pw.Widget _labelValue(String label, String value) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(8),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
        pw.SizedBox(height: 2),
        pw.Text(value, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
      ],
    ),
  );
}

String? _formatDate(dynamic date) {
  if (date == null) return null;
  if (date is String) {
    if (date.isEmpty) return null;
    final parsed = DateTime.tryParse(date);
    if (parsed != null) return DateFormat('dd/MM/yyyy').format(parsed);
    return date;
  }
  return date.toString();
}
