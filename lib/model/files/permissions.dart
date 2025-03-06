import 'dart:async';
import 'dart:io';

import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:flutter/foundation.dart';
import 'package:notification_listener_service/notification_listener_service.dart';
import 'package:optimization_battery/optimization_battery.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:trim_talk/model/notif/notification_sender.dart';
import 'package:trim_talk/model/files/platform/platform.dart';
import 'package:trim_talk/model/files/wa_files.dart';

/// class representing the permissions of the app
/// mandatory : send/read notifs, storage access
class Permissions {
  /// permission to send notifications
  static Future<bool> askSendNotification() async {
    final res = await Permission.notification.request();
    print('Notification status: ${res.name}');

    if (res.isPermanentlyDenied) {
      return await openAppSettings(); // assume the user will enable it
    }

    return res.isGranted;
  }

  /// below Android 13 (sdk 33) use legacy storage permission
  ///
  /// ios always returns false
  static Future<bool> isLegacyStorage() async {
    if (Platform.isIOS) return false;
    final androidInfo = await DeviceInfoPlugin().androidInfo; // this doesnt need to run after runApp it's for package info

    final int version = androidInfo.version.sdkInt;
    print('Android version: $version');

    return version < 33;
  }

  /// permission to read files
  static Future<bool> askReadFiles() async {
    if (Platform.isIOS) return true;
    if (await isLegacyStorage()) {
      final res = await Permission.storage.request();
      if (res.isPermanentlyDenied) {
        return await openAppSettings();
      }
      return res.isGranted;
    }

    // Android SAF
    final uri = await NativePlatform.pickFolder();
    if (uri == null) {
      return false;
    }
    if (uri == WAFiles.uriNotesDir) {
      return true;
    }

    return false;
  }

  /// permission to read files
  static Future<bool> isReadFilesAllowed() async {
    if (Platform.isIOS) return true;
    if (kDebugMode && !(await DeviceInfoPlugin().androidInfo).isPhysicalDevice) return true;

    // return true;
    if (await isLegacyStorage()) {
      return await Permission.storage.isGranted;
    }
    final list = await NativePlatform.getPersistedUrisPermissions();

    return list.contains(WAFiles.uriNotesDir);
  }

  /// permission to send notifications
  static Future<bool> isSendNotificationAllowed() async {
    return await NotificationSender.isAllowed();
  }

  // using 2 packages for battery optimization because DisableBatteryOptimization result is wrong (returns true when the popup is closed whatever the user choice is)
  static Future<bool> askDisableBatteryOptimization() async {
    await DisableBatteryOptimization.showDisableBatteryOptimizationSettings(); // this returns instantly so we check periodicly

    const timeout = Duration(seconds: 20);
    final endTime = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(endTime)) {
      if (await isBatteryOptimizationDisabled()) {
        return true; // Battery optimization was disabled
      }
      await Future.delayed(const Duration(milliseconds: 600));
    }

    return false; // Timeout reached without disabling battery optimization
  }

  /// used for debuging
  static void openBatterySettings() async {
    OptimizationBattery.openBatteryOptimizationSettings(); // not very user friendly (practical)
  }

  static Future<bool> isBatteryOptimizationDisabled() async {
    if (Platform.isIOS) return true;
    return OptimizationBattery.isIgnoringBatteryOptimizations();
  }

  static Future<bool> isNotifWatchingAllowed() async {
    return NotificationListenerService.isPermissionGranted();
  }

  static Future<bool> askNotifWatch() async {
    // final optiDisabled = await askDisableBatteryOptimization(); // not needed but maybe service lives longer with that

    return (await NotificationListenerService.isPermissionGranted()) || await NotificationListenerService.requestPermission();
  }
}
