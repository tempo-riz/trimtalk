import 'dart:io';

import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trim_talk/model/notif/notification_sender.dart';
import 'package:trim_talk/main.dart';
import 'package:trim_talk/model/files/db.dart';
import 'package:trim_talk/model/files/permissions.dart';
import 'package:trim_talk/model/files/platform/platform.dart';
import 'package:trim_talk/model/files/wa_files.dart';
import 'package:trim_talk/model/notif/notification_watcher.dart';
import 'package:trim_talk/model/task.dart';
import 'package:trim_talk/model/utils.dart';
import 'package:trim_talk/model/work.dart';
import 'package:trim_talk/router.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:trim_talk/view/widgets/settings_toogle_pref.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(context.t.settings),
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: Icon(
              Icons.adaptive.arrow_back,
              size: 30,
              color: Theme.of(context).colorScheme.surface,
            ),
            onPressed: () {
              context.goNamed(NamedRoutes.dashboard.name);
            },
          ),
        ),
        actions: [
          Text(
            "v${packageInfo.version} (${packageInfo.buildNumber})",
          )
              .textColor(
                Theme.of(context).colorScheme.surface,
              )
              .fontWeight(FontWeight.w500),
          gap12
        ],
      ),
      body: Container(
        // alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 32),
        child: SingleChildScrollView(
          child: Column(
            spacing: 14,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(), // for spacing
              const AppLanguageDropDown(),
              const TranscriptLanguageDropDown(),
              const EnableTranslateToogle(),
              const DarkModeToogle(),
              const AutoTranscriptToogle(),
              const EnableNotificationToogle(),
              if (Platform.isAndroid) ...[
                const EnableNotificationWatchToogle(),
              ],
              // if (Platform.isAndroid) ...[
              //   gap16,
              //   const EnableAutoCheckToggle(),
              //   gap16,
              //   const FrequencySlider(),
              // ],
              const SeeOnGithubButton(),
              const RateOnStoreButton(),
              const ShareButton(),
              const ClearResultsButton(),
              gap48,
              const DebugWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

class ShareButton extends StatelessWidget {
  const ShareButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
        onPressed: () {
          Share.share(
            "${context.t.heyImUsingTtToTranscribeAndSummarizeCheckItOut} \n\nhttps://upotq.app.link/trimtalk",
            sharePositionOrigin: Rect.fromLTWH(0, 0, MediaQuery.of(context).size.width, MediaQuery.of(context).size.height / 2),
          );
        },
        label: Text(context.t.shareTt),
        icon: Icon(Icons.adaptive.share));
  }
}

class RateOnStoreButton extends StatelessWidget {
  const RateOnStoreButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.star_border),
      onPressed: () {
        InAppReview.instance.openStoreListing(appStoreId: "6720703110");
      },
      label: Text(context.t.rateTtOnStore),
    );
  }
}

class SeeOnGithubButton extends StatelessWidget {
  const SeeOnGithubButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.code),
      onPressed: () {
        launchUrl(Uri.parse('https://github.com/tempo-riz/trimtalk'));
      },
      label: Text(context.t.checkCodeOnGithub),
    );
  }
}

class ClearResultsButton extends StatelessWidget {
  const ClearResultsButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        bool? confirmed = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(context.t.areYouSure),
              content: Text(context.t.doYouReallyWantToDeleteEveryTranscriptThisCantBeUndone),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // User pressed No
                  },
                  child: Text(context.t.no),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // User pressed Yes
                  },
                  child: Text(context.t.yes),
                ),
              ],
            );
          },
        );

        if (confirmed == true) {
          // ITERATE OVER ALL FILES AND DELETE THEM
          final results = DB.resultBox.values.toList();
          for (final result in results) {
            WAFiles.deleteFile(result.path);
            await DB.resultBox.delete(result.key);
          }
        }
      },
      label: Text(context.t.deleteAllTranscripts),
      icon: const Icon(Icons.delete_forever),
      style: ElevatedButton.styleFrom(iconColor: Theme.of(context).colorScheme.error),
    );
  }
}

class TranscriptLanguageDropDown extends StatelessWidget {
  const TranscriptLanguageDropDown({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(context.t.transcriptionLanguage).bold(),
        gap8,
        PrefBuilder<String>(
            pref: Prefs.transcriptLanguageCode,
            builder: (context, languageCode) {
              return DropdownMenu(
                menuHeight: 400,
                leadingIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CountryFlag.fromCountryCode(
                    supportedTranscritionLanguages.where((L) => L.code == languageCode).first.flagCode,
                    width: 30,
                    height: 20,
                  ),
                ),
                initialSelection: languageCode,
                // enableFilter: true,
                enableSearch: true,
                requestFocusOnTap: false,

                // menuHeight: MediaQuery.of(context).size.height * 0.6,
                dropdownMenuEntries: supportedTranscritionLanguages
                    .map((L) => DropdownMenuEntry(
                          value: L.code,
                          label: L.name,
                          leadingIcon: CountryFlag.fromCountryCode(
                            L.flagCode,
                            width: 30,
                            height: 20,
                          ),
                        ))
                    .toList(),
                onSelected: (String? value) => DB.setPref(Prefs.transcriptLanguageCode, value ?? 'en'),
              );
            }),
        gap8,
        Text(context.t.autoLanguageDisclaimer).fontSize(12.5),
      ],
    );
  }
}

class AppLanguageDropDown extends StatelessWidget {
  const AppLanguageDropDown({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(context.t.appLanguage).bold(),
        gap8,
        PrefBuilder<String>(
            pref: Prefs.appLanguageCode,
            builder: (context, languageCode) {
              return DropdownMenu(
                // menuHeight: 400,
                leadingIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CountryFlag.fromCountryCode(
                    supportedAppLanguages.where((L) => L.code == languageCode).first.flagCode,
                    width: 30,
                    height: 20,
                  ),
                ),
                initialSelection: languageCode,
                // enableFilter: true,
                enableSearch: true,
                requestFocusOnTap: false,

                // menuHeight: MediaQuery.of(context).size.height * 0.6,
                dropdownMenuEntries: supportedAppLanguages
                    .map((L) => DropdownMenuEntry(
                          value: L.code,
                          label: L.name,
                          leadingIcon: CountryFlag.fromCountryCode(
                            L.flagCode,
                            width: 30,
                            height: 20,
                          ),
                        ))
                    .toList(),
                onSelected: (String? value) => DB.setPref(Prefs.appLanguageCode, value ?? 'en'),
              );
            }),
      ],
    );
  }
}

class FrequencySlider extends StatelessWidget {
  const FrequencySlider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PrefBuilder<bool>(
        pref: Prefs.isTaskRunning,
        builder: (context, isRunning) {
          // if not running, don't show slider
          if (!isRunning) {
            return const SizedBox();
          }
          return PrefBuilder<int>(
              pref: Prefs.frequencyMinutes,
              builder: (context, minutes) {
                return Column(
                  children: [
                    Text("${context.t.checkFrequency}: ${minutesToString(minutes)}").bold(),
                    gap12,
                    Slider(
                      value: minutesToSlider(minutes),
                      onChangeEnd: (lastSliderValue) => Task.start(updateView: false),
                      onChangeStart: (firstSliderValue) => Task.cancel(updateView: false),
                      onChanged: (newSliderValue) => DB.setPref(Prefs.frequencyMinutes, sliderToMinutes(newSliderValue)),
                      divisions: 5,
                      label: minutesToString(minutes),
                    ),
                  ],
                );
              });
        });
  }
}

class EnableAutoCheckToggle extends StatelessWidget {
  const EnableAutoCheckToggle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsTooglePref(
        pref: Prefs.isTaskRunning,
        title: context.t.periodicCheck,
        subtitle: context.t.whenAppIsInBackground,
        onToggleCheck: (newVal) async {
          if (!newVal) {
            Task.cancel();
            return true; // always allow to disable
          }
          final isAllowed = await Permissions.isBatteryOptimizationDisabled() || await Permissions.askDisableBatteryOptimization();
          if (!isAllowed) return false;
          Task.start();
          return true;
        });
  }
}

class AutoTranscriptToogle extends StatelessWidget {
  const AutoTranscriptToogle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsTooglePref(
      pref: Prefs.isAutoTranscript,
      title: context.t.alwaysAutoTranscribe,
      subtitle: context.t.dontAskConfirmation,
    );
  }
}

class DarkModeToogle extends StatelessWidget {
  const DarkModeToogle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsTooglePref(
      pref: Prefs.isDarkMode,
      title: context.t.darkMode,
      enabledIcon: Icons.dark_mode,
      disabledIcon: Icons.light_mode,
    );
  }
}

class EnableTranslateToogle extends StatelessWidget {
  const EnableTranslateToogle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsTooglePref(
      pref: Prefs.isTranslated,
      title: context.t.translate,
      subtitle: context.t.translateExplain,
      enabledIcon: Icons.translate,
    );
  }
}

class EnableNotificationToogle extends StatelessWidget {
  const EnableNotificationToogle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsTooglePref(
        pref: Prefs.isNotificationEnabled,
        title: context.t.sendNotifications,
        subtitle: context.t.whenAppIsInBackground,
        enabledIcon: Icons.notifications,
        onToggleCheck: (newVal) async {
          if (!newVal) return true; // always allow to disable

          return await Permissions.askSendNotification() && await NotificationSender.init(force: true);
        });
  }
}

class EnableNotificationWatchToogle extends StatelessWidget {
  const EnableNotificationWatchToogle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsTooglePref(
      pref: Prefs.isWatchingNotification,
      title: context.t.autoDetect,
      subtitle: context.t.autoDetectExplain,
      enabledIcon: Icons.autorenew,
      onToggleCheck: (newVal) async {
        if (!newVal) return true; // always allow to disable

        final watchNotif = await Permissions.askNotifWatch();
        // disable battery optimization
        final isAllowed = await Permissions.isBatteryOptimizationDisabled() || await Permissions.askDisableBatteryOptimization();
        if (!watchNotif || !isAllowed) return false;
        // then make sure send notif is enabled
        final sendNotif = await Permissions.isSendNotificationAllowed() || await Permissions.askSendNotification();
        if (!sendNotif) return false;
        DB.setPref(Prefs.isNotificationEnabled, true);

        NotificationWatcher.init();
        NotificationSender.init(force: true);

        return true;
      },
    );
  }
}

/// this widget is only visible in debug mode and contains buttons to test some features
class DebugWidget extends StatelessWidget {
  const DebugWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (!isDebug) return const SizedBox();
    return Column(
      children: [
        gap32,
        ElevatedButton(
            onPressed: () {
              final key = DB.resultBox.keys.last;
              final resultText = DB.resultBox.get(key)!.transcript;
              print(resultText);
              final res = DB.resultBox.get(key)!.copyWith(transcript: null, loadingSummary: false, loadingTranscript: false, summary: null);

              DB.resultBox.put(key, dummyEmptyResult.copyWith(path: res.path));
            },
            child: const Text('reset first card')),
        ElevatedButton(
            onPressed: () async {
              await DB.dummyResultBox.clear();
              await DB.dummyResultBox.add(dummyEmptyResult);
            },
            child: const Text('reset dummy')),
        ElevatedButton(onPressed: () => DB.setPref(Prefs.isTutoDone, false), child: const Text('reset demo')),
        ElevatedButton(onPressed: () => DB.setPref(Prefs.isAcknowledged, false), child: const Text('reset explain')),
        ElevatedButton(onPressed: () => weekNumber(DateTime.now()), child: const Text('week number')),
        ElevatedButton(onPressed: () => print(dummyResultWithShortTranscript.transcript!.length), child: const Text('get prompt size')),
        ElevatedButton(onPressed: () => NativePlatform.getPersistedUrisPermissions().then(print), child: const Text('persistent path')),
        ElevatedButton(onPressed: () async => await createAndCheck(), child: const Text("Debug 1 file")),
        ElevatedButton(onPressed: () async => WAFiles.debug(), child: const Text("read files")),
        ElevatedButton(onPressed: () => DB.resultBox.add(dummyEmptyResult).then(print), child: const Text('Add empty result')),
        ElevatedButton(onPressed: () => DB.resultBox.add(dummyLoadingResult).then(print), child: const Text('Add loading result')),
        ElevatedButton(onPressed: () => DB.resultBox.add(dummyResultWithTranscript).then(print), child: const Text('Add transcript result')),
        ElevatedButton(
            onPressed: () => DB.resultBox.add(dummyResultWithTranscript.copyWith(loadingSummary: true)).then(print), child: const Text('Add loading summary')),
        ElevatedButton(onPressed: () => DB.resultBox.clear(), child: const Text('clear results')),
        ElevatedButton(onPressed: () => DB.refreshResult(), child: const Text('refresh results')),
        ElevatedButton(
          onPressed: () => throw Exception(),
          child: const Text("Throw Test Exception"),
        ),
        ElevatedButton(
          onPressed: () => NativePlatform.pickFolder(),
          child: const Text("pick"),
        ),
        ElevatedButton(
          onPressed: () async {
            final stopwatch = Stopwatch()..start();
            final results = await NativePlatform.listAfter(DateTime.now().subtract(const Duration(days: 100)));
            print("1 ----- ${stopwatch.elapsed}");
            print(results.first.path);
            // final uri = results.first.path;
            // final
            final path = await NativePlatform.copyToSupportDir(results.first);
            // copy to dir
            print("2 ----- ${stopwatch.elapsed}");

            print(path);
            if (path == null) return;
            // try to read file
            // final res = await Transcriber.fromPath(path, forceRun: true);

            // print(res);
            // print("2 ----- ${stopwatch.elapsed}");

            // print(File(results.first.path).existsSync()); // false so copy it
            // final newPath = await AndroidPlatform.copyToSupport(results.first.path); //DOESNT WORKS (file does not exist)
            // print(newPath);
            // if (newPath == null) return;
            // print(File(newPath).existsSync());
          },
          child: const Text("test"),
        ),
      ],
    );
  }
}
