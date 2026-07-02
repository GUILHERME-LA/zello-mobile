import 'package:intl/intl.dart';

class Formatters {
  static String formatPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length == 11) {
      return '(${cleaned.substring(0, 2)}) ${cleaned.substring(2, 7)}-${cleaned.substring(7)}';
    }
    return phone;
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yy').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yy HH:mm').format(date);
  }

  static String getInitials(String name) {
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }

  static String formatCpf(String cpf) {
    final cleaned = cpf.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length == 11) {
      return '${cleaned.substring(0, 3)}.${cleaned.substring(3, 6)}.${cleaned.substring(6, 9)}-${cleaned.substring(9)}';
    }
    return cpf;
  }
}
