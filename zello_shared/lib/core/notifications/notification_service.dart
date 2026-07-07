import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  StreamSubscription<List<Map<String, dynamic>>>? _examSubscription;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  void subscribeToExamUpdates(String userId) {
    final supabase = Supabase.instance.client;

    _examSubscription?.cancel();
    _examSubscription = supabase
        .from('exam_requests')
        .stream(primaryKey: ['id'])
        .eq('patient_id', userId)
        .listen((data) {
      for (final change in data) {
        final status = change['status'] as String?;
        if (status == 'confirmado' || status == 'recusado') {
          _showExamNotification(
            examType: change['exam_type'] as String? ?? 'Exame',
            status: status!,
          );
        }
      }
    });
  }

  Future<void> _showExamNotification({
    required String examType,
    required String status,
  }) async {
    final title = status == 'confirmado' ? 'Exame Confirmado' : 'Exame Recusado';
    final body = status == 'confirmado'
        ? 'Seu exame "$examType" foi confirmado.'
        : 'Seu exame "$examType" foi recusado.';

    const androidDetails = AndroidNotificationDetails(
      'zello_exam_updates',
      'Atualizações de Exames',
      channelDescription: 'Notificações quando o status de um exame muda',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
    );
  }

  void dispose() {
    _examSubscription?.cancel();
  }
}
