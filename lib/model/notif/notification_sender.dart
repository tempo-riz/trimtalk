import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:trim_talk/model/files/db.dart';
import 'package:trim_talk/model/notif/notification_interaction.dart';
import 'package:trim_talk/model/utils.dart';
import 'package:trim_talk/types/result.dart';

class NotificationSender {
  static Future<bool> requestPermission() async {
    if (Platform.isIOS) {
      return await FlutterLocalNotificationsPlugin().resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions() ?? false;
    }
    return await FlutterLocalNotificationsPlugin()
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission() ??
        false;
  }

  /// This is true with hot reload even if app was already foreground
  /// if the app was killed and the user tap on a notification, will redirect to the usual callback
  static Future<void> callbackIfAppWakeUpFromNotifTap() async {
    final NotificationAppLaunchDetails details = (await FlutterLocalNotificationsPlugin().getNotificationAppLaunchDetails())!; // only null on macos

    if (!details.didNotificationLaunchApp) return;
    final res = details.notificationResponse;

    if (res == null) return;
    onNotification(res);
  }

  static Future<bool> isAllowed() async {
    if (Platform.isIOS) {
      final res = await FlutterLocalNotificationsPlugin().resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.checkPermissions();
      return res?.isEnabled ?? false;
    }
    return await FlutterLocalNotificationsPlugin().resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.areNotificationsEnabled() ??
        false;
  }

  /// if user gave permission + enabled + app is in background
  static bool canSend() {
    return DB.getPref(Prefs.isNotificationEnabled) && !DB.getPref(Prefs.isAppInForeground);
  }

  /// initialize the notification sender
  static Future<bool> init({bool force = false}) async {
    if (!DB.getPref(Prefs.isNotificationEnabled) && !force) return false;
    return await FlutterLocalNotificationsPlugin().initialize(
          InitializationSettings(
              android: const AndroidInitializationSettings('mipmap/ic_launcher'),
              iOS: DarwinInitializationSettings(
                notificationCategories: [
                  DarwinNotificationCategory(chanelId,
                      actions: ActionType.values
                          .map((a) => DarwinNotificationAction.plain(
                                ActionType.transcribe.name.toUpperCase(),
                                ActionType.transcribe.name,
                                options: {
                                  DarwinNotificationActionOption.destructive,
                                },
                              ))
                          .toList(),
                      options: {
                        DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
                      }),
                ],
              )),
          onDidReceiveNotificationResponse: onNotification,
          onDidReceiveBackgroundNotificationResponse: onNotification,
        ) ??
        false;
  }

  static Future<void> clear(int id) async {
    await FlutterLocalNotificationsPlugin().cancel(id);
  }

  /// show only if app is not in foreground
  static Future<void> showLoading(int id, String dur) async {
    if (!canSend()) return;

    const ios = DarwinNotificationDetails(categoryIdentifier: chanelId);

    const android = AndroidNotificationDetails(
      chanelId,
      chanelName,
      // progress/loading
      indeterminate: true,
      showProgress: true,
      playSound: false,
      enableVibration: false,
    );
    const details = NotificationDetails(
      android: android,
      iOS: ios,
    );
    await FlutterLocalNotificationsPlugin().show(id, 'Transcribing $dur ...', null, details);
  }

  static Future<void> showError(int id, String? error) async {
    if (!canSend()) return;

    const ios = DarwinNotificationDetails(categoryIdentifier: chanelId);

    const android = AndroidNotificationDetails(
      chanelId,
      chanelName,
      playSound: false,
      enableVibration: false,
      importance: Importance.max,
      priority: Priority.high,
    );
    const details = NotificationDetails(
      android: android,
      iOS: ios,
    );
    await FlutterLocalNotificationsPlugin().show(id, error ?? 'Failed to transcribe :(', null, details);
  }

  static Future<void> _showNotification({
    required String title,
    int? id,
    String? body,
    String? payload,
    List<ActionType> actions = const [],
  }) async {
    if (!canSend()) return;

    // get random id (max int32)
    int notifId = id ?? randomInt32();

    const ios = DarwinNotificationDetails(categoryIdentifier: chanelId);

    AndroidNotificationDetails android = AndroidNotificationDetails(
      chanelId,
      chanelName,
      // silent: true, // if silent it doesn't show floating notif banner
      playSound: false,
      enableVibration: false,
      importance: Importance.max,
      priority: Priority.high,
      // styleInformation: BigTextStyleInformation(''),
      autoCancel: true, // dismiss notification when tapped
      channelDescription: 'channel description',
      showWhen: false,
      actions: actions
          .map((action) => AndroidNotificationAction(
                action.name,
                action.name.capitalize(),
              ))
          .toList(),
    );
    // for length limitation/croping : https://reteno.com/blog/push-notification-character-limits-tips-to-be-visible
    final details = NotificationDetails(android: android, iOS: ios);
    await FlutterLocalNotificationsPlugin().show(notifId, title, body, details, payload: payload);
  }

  /// ask user if they want to transcribe the audio
  static Future<void> promptUserValidation(Result res, int resKey) async {
    String title = "Trim";
    if (res.sender != null) title += " ${res.sender}";
    title += " ${res.duration} ?";
    String body = res.date;

    await _showNotification(title: title, body: body, payload: resKey.toString(), actions: [
      // disable action since now working fine rn
      // ActionType.dismiss,
      // ActionType.transcribe,
    ]);
  }

  /// show the transcript
  static Future<void> showTranscriptResult(Result res, int resKey, int notifId) async {
    String title = "Audio";
    if (res.sender != null) title += " ${res.sender}";
    title += " ${res.duration}";

    String body = res.transcript ?? "No transcript :/";

    await _showNotification(id: notifId, title: title, body: body, payload: resKey.toString(), actions: [
      // ActionType.dismiss,
      // ActionType.transcribe,
    ]);
  }

  static Future<void> showTest() async {
    await _showNotification(title: "Test", body: "Test body");
  }
}
