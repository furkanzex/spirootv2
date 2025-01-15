import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:get/get.dart';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:workmanager/workmanager.dart';
import 'package:get_storage/get_storage.dart';

// Arka plan görevi için callback
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      if (task == 'scheduleFortuneNotification' && inputData != null) {
        final notificationService = NotificationService();
        await notificationService.initialize();

        final title = inputData['title'] as String;
        final body = inputData['body'] as String;
        final fortuneType = inputData['fortuneType'] as String;
        final fortuneId = inputData['fortuneId'] as String;

        await notificationService._notificationsPlugin.show(
          fortuneId.hashCode,
          title,
          body,
          NotificationDetails(
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
              sound: 'default',
              interruptionLevel: InterruptionLevel.timeSensitive,
              threadIdentifier: 'fortune_notifications',
            ),
            android: const AndroidNotificationDetails(
              'fortune_interpretations',
              'Fal Yorumları',
              channelDescription:
                  'Fal yorumları hazır olduğunda bildirim gönderir',
              importance: Importance.high,
              priority: Priority.high,
              playSound: true,
              enableVibration: true,
              icon: '@mipmap/ic_launcher',
            ),
          ),
          payload: '$fortuneType:$fortuneId',
        );
      }
      return true;
    } catch (e) {
      return false;
    }
  });
}

class NotificationService extends GetxService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    // Android ayarları
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS ayarları
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      notificationCategories: [
        DarwinNotificationCategory(
          'fortune_notifications',
          actions: [
            DarwinNotificationAction.plain('open', 'Aç'),
          ],
        ),
      ],
    );

    // Genel ayarlar
    final initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Plugin'i başlat
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onNotificationTap,
    );

    // İzinleri kontrol et
    final granted = await requestPermissions();
    debugPrint('Bildirim İzinleri: $granted');
  }

  // Bildirim planla
  Future<void> scheduleFortuneNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String fortuneType,
    required String fortuneId,
  }) async {
    debugPrint('Bildirim planlanıyor...');
    debugPrint('Başlık: $title');
    debugPrint('İçerik: $body');
    debugPrint('Planlanan Zaman: $scheduledDate');

    // İzinleri kontrol et
    final hasPermission = await requestPermissions();
    debugPrint('Bildirim İzinleri: $hasPermission');

    if (!hasPermission) {
      debugPrint('Bildirim izinleri reddedildi');
      return;
    }

    // iOS için bildirim detayları
    var iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
      interruptionLevel: InterruptionLevel.timeSensitive,
      categoryIdentifier: 'fortune_notifications',
    );

    // Android için bildirim detayları
    var androidDetails = const AndroidNotificationDetails(
      'fortune_interpretations',
      'Fal Yorumları',
      channelDescription: 'Fal yorumları hazır olduğunda bildirim gönderir',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    // Genel bildirim detayları
    var details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      // Hem iOS hem Android için zonedSchedule kullan
      final scheduledTime = tz.TZDateTime.from(scheduledDate, tz.local);
      await _notificationsPlugin.zonedSchedule(
        fortuneId.hashCode,
        title,
        body,
        scheduledTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: '$fortuneType:$fortuneId',
      );
      debugPrint('Zamanlanmış bildirim planlandı: $scheduledTime');
    } catch (e, stackTrace) {
      debugPrint('Bildirim hatası: $e');
      debugPrint('Hata detayı: $stackTrace');
    }
  }

  // iOS için izinleri kontrol et ve iste
  Future<bool> requestPermissions() async {
    if (Platform.isIOS) {
      final settings = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
            critical: true,
          );
      return settings ?? false;
    } else {
      // Android için bildirim ve tam zamanlı alarm izinlerini kontrol et
      final notificationStatus = await Permission.notification.request();

      // Android 12 ve üzeri için tam zamanlı alarm izni kontrolü
      if (int.parse(Platform.version.split('.')[0]) >= 12) {
        final androidPlugin =
            _notificationsPlugin.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        final alarmPermission =
            await androidPlugin?.requestExactAlarmsPermission() ?? false;
        return notificationStatus.isGranted && alarmPermission;
      }

      return notificationStatus.isGranted;
    }
  }

  // iOS için eski bildirim callback'i
  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    if (Platform.isIOS) {
      showDialog(
        context: Get.context!,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: title != null ? Text(title) : null,
          content: body != null ? Text(body) : null,
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text(easy.tr('common.ok')),
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                if (payload != null) {
                  onNotificationTap(
                    NotificationResponse(
                      notificationResponseType:
                          NotificationResponseType.selectedNotification,
                      payload: payload,
                    ),
                  );
                }
              },
            )
          ],
        ),
      );
    }
  }

  // Bildirime tıklandığında
  void onNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      final parts = response.payload!.split(':');
      if (parts.length == 2) {
        final fortuneType = parts[0];
        final fortuneId = parts[1];

        // Fal detay sayfasına yönlendir
        Get.toNamed('/fortune-detail', arguments: {
          'fortuneType': fortuneType,
          'fortuneId': fortuneId,
        });
      }
    }
  }

  // Fal hazır olduğunda bildirim gönder
  Future<void> scheduleFortuneReadyNotification({
    required String fortuneId,
    required String fortuneType,
    required DateTime revealAt,
  }) async {
    debugPrint('scheduleFortuneReadyNotification çağrıldı');
    debugPrint('Fortune ID: $fortuneId');
    debugPrint('Fortune Type: $fortuneType');
    debugPrint('Reveal Time: $revealAt');

    String title = '';
    String body = '';

    switch (fortuneType) {
      case 'coffee':
        title = easy.tr('notifications.coffee_fortune_ready_title');
        body = easy.tr('notifications.coffee_fortune_ready_body');
        break;
      case 'tarot':
        title = easy.tr('notifications.tarot_fortune_ready_title');
        body = easy.tr('notifications.tarot_fortune_ready_body');
        break;
      case 'angel':
        title = easy.tr('notifications.angel_fortune_ready_title');
        body = easy.tr('notifications.angel_fortune_ready_body');
        break;
      case 'katina':
        title = easy.tr('notifications.katina_fortune_ready_title');
        body = easy.tr('notifications.katina_fortune_ready_body');
        break;
      case 'palm':
        title = easy.tr('notifications.palm_fortune_ready_title');
        body = easy.tr('notifications.palm_fortune_ready_body');
        break;
      case 'face':
        title = easy.tr('notifications.face_fortune_ready_title');
        body = easy.tr('notifications.face_fortune_ready_body');
        break;
      default:
        title = easy.tr('notifications.fortune_ready_title');
        body = easy.tr('notifications.fortune_ready_body');
    }

    debugPrint('Bildirim başlığı: $title');
    debugPrint('Bildirim içeriği: $body');

    // iOS için bildirim detayları
    var iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
      interruptionLevel: InterruptionLevel.timeSensitive,
      categoryIdentifier: 'fortune_notifications',
    );

    // Android için bildirim detayları
    var androidDetails = const AndroidNotificationDetails(
      'fortune_interpretations',
      'Fal Yorumları',
      channelDescription: 'Fal yorumları hazır olduğunda bildirim gönderir',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    // Genel bildirim detayları
    var details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      final now = DateTime.now();
      final difference = revealAt.difference(now);
      debugPrint('Bildirim için kalan süre: ${difference.inSeconds} saniye');

      if (difference.inSeconds <= 0) {
        // Zaman geçmişse hemen gönder
        await _notificationsPlugin.show(
          fortuneId.hashCode,
          title,
          body,
          details,
          payload: '$fortuneType:$fortuneId',
        );
        debugPrint('Anlık bildirim gönderildi');
      } else {
        // Hem iOS hem Android için zonedSchedule kullan
        final scheduledTime = tz.TZDateTime.from(revealAt, tz.local);
        await _notificationsPlugin.zonedSchedule(
          fortuneId.hashCode,
          title,
          body,
          scheduledTime,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: '$fortuneType:$fortuneId',
        );
        debugPrint('Zamanlanmış bildirim planlandı: $scheduledTime');
      }
    } catch (e, stackTrace) {
      debugPrint('Bildirim hatası: $e');
      debugPrint('Hata detayı: $stackTrace');

      // Hata durumunda alternatif yöntem dene
      try {
        final difference = revealAt.difference(DateTime.now());
        if (difference.inSeconds > 0) {
          await Future.delayed(difference, () async {
            await _notificationsPlugin.show(
              fortuneId.hashCode,
              title,
              body,
              details,
              payload: '$fortuneType:$fortuneId',
            );
          });
          debugPrint('Alternatif bildirim planlandı');
        }
      } catch (retryError) {
        debugPrint('Alternatif bildirim de başarısız: $retryError');
      }
    }
  }

  // Astroloji bildirimlerini planla
  Future<void> scheduleAstrologyNotifications({
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    debugPrint('\n=== Astroloji Bildirimi Planlanıyor ===');

    try {
      // Bildirim saatini al
      final storage = GetStorage();
      final timeMap =
          storage.read('daily_notification_time') ?? {'hour': 9, 'minute': 0};
      final notificationTime =
          TimeOfDay(hour: timeMap['hour'], minute: timeMap['minute']);

      // Bildirim saatini formatlama
      final formattedTime =
          '${notificationTime.hour.toString().padLeft(2, '0')}:${notificationTime.minute.toString().padLeft(2, '0')}';
      debugPrint('\nSeçili Bildirim Saati: $formattedTime');

      // Bildirim için tarih oluştur
      final notificationId = scheduledDate.millisecondsSinceEpoch ~/ 1000;
      var notificationDateTime = DateTime(
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
        notificationTime.hour,
        notificationTime.minute,
      );

      // Eğer planlanan zaman geçmişse, bir sonraki güne planla
      if (notificationDateTime.isBefore(DateTime.now())) {
        notificationDateTime =
            notificationDateTime.add(const Duration(days: 1));
        debugPrint(
            'Geçmiş zaman tespit edildi, bir sonraki güne planlanıyor: $notificationDateTime');
      }

      await scheduleFortuneNotification(
        title: title,
        body: body,
        scheduledDate: notificationDateTime,
        fortuneType: 'astrology',
        fortuneId: 'daily_$notificationId',
      );

      debugPrint('\n=== Bildirim Planlaması Tamamlandı ===\n');
    } catch (e) {
      debugPrint('Bildirim planlanırken genel hata oluştu: $e');
    }
  }

  // Test bildirimi gönder
  Future<void> sendTestNotification({
    required String title,
    required String body,
  }) async {
    debugPrint('\n=== Test Bildirimi Gönderiliyor ===');

    try {
      await scheduleFortuneNotification(
        title: title,
        body: body,
        scheduledDate: DateTime.now(),
        fortuneType: 'astrology',
        fortuneId: 'test_notification',
      );
    } catch (e) {
      debugPrint('Test bildirimi gönderilirken hata oluştu: $e');
      debugPrint('Hata detayı: $e');
    }

    debugPrint('=== Test Bildirimi İşlemi Tamamlandı ===\n');
  }

  // Tüm bildirimleri temizle
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    debugPrint('Tüm bildirimler temizlendi');
  }
}
