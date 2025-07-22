import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trim_talk/l10n/gen/app_localizations.dart';
import 'package:trim_talk/main.dart';
import 'package:trim_talk/model/files/db.dart';

import 'package:trim_talk/router.dart';
import 'package:trim_talk/view/dashboard_screen.dart';
import 'package:upgrader/upgrader.dart';

const trimTalkBlue = Color(0xFF4533EE);
const trimTalkOrange = Color(0xFFFF7B3F);

class App extends HookConsumerWidget {
  const App({super.key});

  final computedPrimary = const Color(0xFF5A5891);
  // #c3c0ff
  final computedPrimaryDark = const Color(0xFFC3C0FF);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useOnAppLifecycleStateChange((_, state) async {
      DB.setPref(Prefs.isAppInForeground, state == AppLifecycleState.resumed);
      print('App state: $state');
      // update the result list when app is resumed (after a notif action tap because uddated is separate isolate)
      if (state == AppLifecycleState.resumed) {
        // await DB.refreshResult();
        ref.read(needRefreshProvider.notifier).state = !ref.read(needRefreshProvider);
        // Future.delayed(const Duration(seconds: 1), () async {
        //   await DB.refreshResult();
        // });
      }
    });

    return PrefBuilder<bool>(
        pref: Prefs.isDarkMode,
        builder: (context, isDarkMode) {
          return PrefBuilder<String>(
              pref: Prefs.appLanguageCode,
              builder: (context, localeCode) {
                return MaterialApp.router(
                  locale: Locale(localeCode),
                  localizationsDelegates: AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,

                  builder: (context, child) {
                    return UpgradeAlert(
                      showIgnore: false,
                      showLater: !forceUpdate,
                      dialogStyle: Platform.isIOS ? UpgradeDialogStyle.cupertino : UpgradeDialogStyle.material,
                      navigatorKey: router.routerDelegate.navigatorKey,
                      child: child,
                    );
                  },
                  routerConfig: router,
                  debugShowCheckedModeBanner: false, //isDebug,
                  theme: ThemeData(
                    useMaterial3: true,
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: trimTalkBlue,
                      brightness: isDarkMode ? Brightness.dark : Brightness.light,
                    ),
                    textTheme: const TextTheme(
                      titleMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      bodyMedium: TextStyle(fontSize: 16),
                      labelMedium: TextStyle(fontSize: 14),
                    ),
                    appBarTheme: AppBarTheme(
                      centerTitle: true,
                      titleTextStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.black : Colors.white,
                      ),
                      backgroundColor: isDarkMode ? computedPrimaryDark : computedPrimary,
                    ),
                  ),
                );
              });
        });
  }
}
