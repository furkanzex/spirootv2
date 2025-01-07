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

class NotificationService {
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

    // İzinler verildiyse bildirimleri planla
    if (granted) {
      debugPrint('Bildirim izinleri onaylandı, bildirimler planlanıyor...');
      await scheduleAstrologyNotifications();
    } else {
      debugPrint('Bildirim izinleri reddedildi, bildirimler planlanamıyor.');
    }
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
      final now = DateTime.now();
      final difference = scheduledDate.difference(now);

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
        // iOS için anlık bildirim planla
        if (Platform.isIOS) {
          // Workmanager ile planla
          await Workmanager().registerOneOffTask(
            'fortune_$fortuneId',
            'scheduleFortuneNotification',
            initialDelay: difference,
            inputData: {
              'title': title,
              'body': body,
              'fortuneType': fortuneType,
              'fortuneId': fortuneId,
            },
            existingWorkPolicy: ExistingWorkPolicy.replace,
          );
          debugPrint(
              'iOS için workmanager görevi planlandı: ${difference.inSeconds} saniye sonra');
        } else {
          // Android için zamanlanmış bildirim
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
          debugPrint(
              'Android için zamanlanmış bildirim planlandı: $scheduledTime');
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Bildirim hatası: $e');
      debugPrint('Hata detayı: $stackTrace');

      // Hata durumunda workmanager ile tekrar dene
      try {
        final delay = scheduledDate.difference(DateTime.now());
        if (delay.inSeconds > 0) {
          await Workmanager().registerOneOffTask(
            'fortune_$fortuneId',
            'scheduleFortuneNotification',
            initialDelay: delay,
            inputData: {
              'title': title,
              'body': body,
              'fortuneType': fortuneType,
              'fortuneId': fortuneId,
            },
            existingWorkPolicy: ExistingWorkPolicy.replace,
          );
          debugPrint('Bildirim workmanager ile yeniden planlandı');
        }
      } catch (retryError) {
        debugPrint('Workmanager planlaması da başarısız: $retryError');
      }
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
      if (Platform.version.startsWith('13')) {
        final alarmStatus = await Permission.scheduleExactAlarm.request();
        return notificationStatus.isGranted && alarmStatus.isGranted;
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
  Future<void> scheduleAstrologyNotifications() async {
    debugPrint('\n=== Astroloji Bildirimleri Kontrol Ediliyor ===');

    // Mevcut bildirimleri kontrol et
    final pendingNotifications =
        await _notificationsPlugin.pendingNotificationRequests();
    debugPrint(
        '\nMevcut Planlanmış Bildirimler (${pendingNotifications.length}):');

    // Astroloji bildirimlerini filtrele (ID: 1001-1003 arası)
    final astrologyNotifications = pendingNotifications
        .where((n) => n.id >= 1001 && n.id <= 1003)
        .toList();
    for (var notification in astrologyNotifications) {
      debugPrint(
          'ID: ${notification.id}, Başlık: ${notification.title}, İçerik: ${notification.body}');
    }

    // Eğer 3 günlük bildirim varsa işlem yapma
    if (astrologyNotifications.length == 3) {
      debugPrint('\nTüm bildirimler zaten planlanmış, işlem yapılmayacak.');
      return;
    }

    // Mevcut bildirim ID'lerini al
    final existingIds = astrologyNotifications.map((n) => n.id).toSet();

    final storage = GetStorage();
    final timeMap =
        storage.read('daily_notification_time') ?? {'hour': 9, 'minute': 0};
    final notificationTime =
        TimeOfDay(hour: timeMap['hour'], minute: timeMap['minute']);

    // Bildirim saatini formatlama
    final formattedTime =
        '${notificationTime.hour.toString().padLeft(2, '0')}:${notificationTime.minute.toString().padLeft(2, '0')}';
    debugPrint('\nSeçili Bildirim Saati: $formattedTime');

    // Eksik günler için bildirimleri planla
    debugPrint('\nEksik Bildirimler Planlanıyor:');
    for (int i = 0; i < 3; i++) {
      final notificationId = 1001 + i;

      // Bu ID için bildirim zaten varsa atla
      if (existingIds.contains(notificationId)) {
        debugPrint(
            'ID: $notificationId için bildirim zaten mevcut, atlanıyor.');
        continue;
      }

      final scheduledDate = DateTime.now().add(Duration(days: i));
      await _schedulePeriodicAstrologyNotification(
        id: notificationId,
        title: easy.tr('notifications.daily_horoscope_title'),
        body: easy.tr('notifications.daily_horoscope_body'),
        notificationTime: notificationTime,
        scheduledDate: scheduledDate,
      );
      debugPrint(
          '${i + 1}. gün için yeni bildirim planlandı: ${scheduledDate.toString()}');
    }

    // Güncel durumu kontrol et
    final updatedNotifications =
        await _notificationsPlugin.pendingNotificationRequests();
    final updatedAstrologyNotifications = updatedNotifications
        .where((n) => n.id >= 1001 && n.id <= 1003)
        .toList();
    debugPrint(
        '\nGüncel Planlanmış Bildirimler (${updatedAstrologyNotifications.length}):');
    for (var notification in updatedAstrologyNotifications) {
      debugPrint(
          'ID: ${notification.id}, Başlık: ${notification.title}, İçerik: ${notification.body}');
    }

    debugPrint('\n=== Bildirim Kontrolü Tamamlandı ===\n');
  }

  Future<void> _schedulePeriodicAstrologyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay notificationTime,
    required DateTime scheduledDate,
  }) async {
    var notificationDateTime = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      notificationTime.hour,
      notificationTime.minute,
    );

    // Eğer belirtilen saat geçmişse, bir sonraki güne planla
    if (notificationDateTime.isBefore(DateTime.now())) {
      notificationDateTime = notificationDateTime.add(const Duration(days: 1));
      debugPrint(
          'Geçmiş saat tespit edildi, bir sonraki güne planlanıyor: ${notificationDateTime.toString()}');
    }

    final androidDetails = const AndroidNotificationDetails(
      'astrology_notifications',
      'Astroloji Bildirimleri',
      channelDescription: 'Günlük astroloji yorumları için bildirimler',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    final iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    final details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    try {
      // Dil dosyasından mesajları çek
      final messages = easy.tr('notifications.daily_horoscope_messages');
      if (messages.isEmpty) {
        throw Exception('Bildirim mesajları bulunamadı');
      }

      // 0-24 arası rastgele bir sayı seç
      final randomIndex = DateTime.now().microsecondsSinceEpoch % 25;

      // Seçilen indekse göre mesajı al
      final randomMessage =
          easy.tr('notifications.daily_horoscope_messages.$randomIndex');
      debugPrint('Seçilen bildirim mesajı: $randomMessage');

      await _notificationsPlugin.zonedSchedule(
        id,
        easy.tr('notifications.daily_horoscope_title'),
        randomMessage,
        tz.TZDateTime.from(notificationDateTime, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      debugPrint(
          'Bildirim başarıyla planlandı - ID: $id, Zaman: ${notificationDateTime.toString()}');
    } catch (e) {
      debugPrint('Bildirim planlanırken hata oluştu - ID: $id, Hata: $e');
    }
  }
}
