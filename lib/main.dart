import 'dart:io';

import 'package:feedback_github/feedback_github.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:trim_talk/app.dart';
import 'package:trim_talk/model/files/db.dart';
import 'package:trim_talk/model/notif/notification_sender.dart';
import 'package:trim_talk/model/files/receiver.dart';
import 'package:trim_talk/model/notif/notification_watcher.dart';
import 'package:trim_talk/model/check_new.dart';

import 'package:trim_talk/router.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:package_info_plus/package_info_plus.dart';

String firstRoute = '/dashboard';

bool isDebug = !foundation.kReleaseMode;

bool forceUpdate = false;

late PackageInfo packageInfo;

/// this is only for android
Future<void> updateIfAvailable() async {
  if (isDebug || ServicesBinding.rootIsolateToken == null || Platform.isIOS) return;
  try {
    final status = await InAppUpdate.checkForUpdate();

    if (status.updateAvailability == UpdateAvailability.updateAvailable && status.immediateUpdateAllowed) {
      print('Update available $status');
      await InAppUpdate.performImmediateUpdate();
    } else {
      print('No update available');
    }
  } catch (e) {
    print('Error checking for update: $e');
  }
}

/// must be called before runApp or bg callback !
Future<void> initApp() async {
  print('Initializing app...');

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!isDebug) {
    // dont send crash reports in debug mode
    FlutterError.onError = (errorDetails) {
      print('FlutterError error: $errorDetails');
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      print('PlatformDispatcher error: $error');
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  await dotenv.load();
  await DB.init();
  await NotificationSender.init();
  // Task.init();

  Receiver.init();
  NotificationWatcher.init();
  // Accessibility.init();

  firstRoute = await getFirstRoute();
  print("First route: $firstRoute");
}

void main() async {
  await initApp();

  runApp(const BetterFeedback(
    themeMode: ThemeMode.light,
    localeOverride: Locale('en'),
    child: ProviderScope(child: App()),
  ));

  updateIfAvailable();

  // check for new audios on startup if app ready
  if (Platform.isAndroid && (await isSetupOk())) checkForNewAudios();

  // need to be called after runApp
  NotificationSender.callbackIfAppWakeUpFromNotifTap();

  // must be called after runApp !
  packageInfo = await PackageInfo.fromPlatform();
}
