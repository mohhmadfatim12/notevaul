import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  void Function(String noteId)? onNoteSelected;

  static const String channelId = 'notevault_reminders';
  static const String channelName = 'NoteVault Reminders';
  static const String channelDescription =
      'Notifications for scheduled note reminders and alerts';

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      tz.initializeTimeZones();

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidSettings);

      await _plugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (response) {
          final payload = response.payload;
          if (payload != null && payload.isNotEmpty) {
            onNoteSelected?.call(payload);
          }
        },
      );

      // Create Android Notification Channel
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            channelId,
            channelName,
            description: channelDescription,
            importance: Importance.high,
            enableVibration: true,
          ),
        );
      }

      _initialized = true;
    } catch (e) {
      debugPrint('Notification service initialization error: $e');
    }
  }

  Future<bool> requestPermission() async {
    try {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        return granted ?? false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  int _getNotificationId(String noteId) {
    return noteId.hashCode.abs() % 1000000;
  }

  Future<void> scheduleReminder({
    required String noteId,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (!_initialized) await initialize();

    final now = DateTime.now();
    if (scheduledDate.isBefore(now)) return;

    try {
      final id = _getNotificationId(noteId);
      final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'Note Reminder',
        styleInformation: BigTextStyleInformation(
          body.isNotEmpty ? body : 'Reminder for your note',
          contentTitle: title.isNotEmpty ? title : 'NoteVault Reminder',
        ),
      );

      final notificationDetails = NotificationDetails(android: androidDetails);

      await _plugin.zonedSchedule(
        id: id,
        title: title.isNotEmpty ? title : 'NoteVault Reminder',
        body: body.isNotEmpty ? body : 'You have a scheduled reminder.',
        scheduledDate: tzDateTime,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: noteId,
      );
    } catch (e) {
      debugPrint('Failed to schedule reminder: $e');
    }
  }

  Future<void> cancelReminder(String noteId) async {
    try {
      final id = _getNotificationId(noteId);
      await _plugin.cancel(id: id);
    } catch (e) {
      debugPrint('Failed to cancel reminder: $e');
    }
  }

  Future<void> cancelAllReminders() async {
    try {
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('Failed to cancel all reminders: $e');
    }
  }
}
