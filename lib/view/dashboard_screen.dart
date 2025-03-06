import 'dart:io';

import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:feedback_github/feedback_github.dart' as feedback;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_scrolling_fab_animated/flutter_scrolling_fab_animated.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trim_talk/model/files/db.dart';
import 'package:trim_talk/model/stt/result_extensions.dart';
import 'package:trim_talk/model/utils.dart';
import 'package:trim_talk/model/files/wa_files.dart';
import 'package:trim_talk/model/check_new.dart';
import 'package:trim_talk/main.dart';
import 'package:trim_talk/router.dart';
import 'package:trim_talk/types/result.dart';
import 'package:trim_talk/view/widgets/result_card.dart';

final needRefreshProvider = StateProvider((ref) => false);

enum Reactions { copy, share, delete, translate }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PrefBuilder<bool>(
        pref: Prefs.isTutoDone,
        builder: (context, isTutoDone) {
          // isTutoDone = false;
          return Scaffold(
            floatingActionButton: isTutoDone && !Platform.isIOS ? CheckNowFab(scrollController: _scrollController) : null,
            appBar: AppBar(
              centerTitle: false,
              title: isTutoDone ? const LastRunIndicator() : null,
              actions: const [PickFileButton(), GoToSupportButton(), FeedbackButton(), GoToSettingsButton()],
            ),
            body: Consumer(builder: (context, ref, child) {
              // to refresh list when action tapped on notif !
              ref.watch(needRefreshProvider);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: ValueListenableBuilder(
                  valueListenable: DB.resultBox.listenable(),
                  builder: (context, box, widget) {
                    if (!isTutoDone) {
                      return const Tutorial();
                    }

                    final keys = box.keys.toList().reversed.toList();

                    if (keys.isEmpty) {
                      if (Platform.isIOS) {
                        return Container(
                          padding: const EdgeInsets.only(top: 40),
                          alignment: Alignment.topCenter,
                          child: Column(
                            children: [
                              Text(context.t.nothingToSeeHere),
                              gapH20,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  gap12,
                                  const Icon(Icons.ios_share),
                                  gap12,
                                  Flexible(child: Text(context.t.shareAnyAudioFileToTheApp).bold()),
                                  gap12,
                                ],
                              ),
                              gapH24,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  gap12,
                                  const Icon(Icons.file_download_outlined),
                                  gap12,
                                  Flexible(child: Text("Or pick a file using this button").bold()),
                                  gap12,
                                ],
                              ),
                            ],
                          ),
                        );
                      }
                      return Container(
                        padding: const EdgeInsets.only(top: 40),
                        alignment: Alignment.topCenter,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(context.t.tapCheckNow).bold(),
                            gap8,
                            const Icon(Icons.arrow_downward),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      controller: _scrollController,
                      // reverse: true,
                      padding: const EdgeInsets.only(bottom: 100, top: 12),
                      separatorBuilder: (context, index) => gap12,
                      itemCount: keys.length,
                      itemBuilder: (context, index) {
                        final int key = keys[index];
                        final res = box.get(key);
                        if (res == null) {
                          return const SizedBox();
                        }

                        final String? displayText = res.summary ?? res.transcript;

                        final txt = "$displayText\n\n${context.t.madeWithTt} https://upotq.app.link/trimtalk";

                        return Dismissible(
                            direction: DismissDirection.none,
                            key: Key(key.toString()),
                            onDismissed: (direction) {
                              print("deleting $key");
                              box.delete(key);
                              // also delete associated file
                              WAFiles.deleteFile(res.path);
                            },
                            onUpdate: (details) {},
                            resizeDuration: null,
                            movementDuration: const Duration(milliseconds: 200),
                            child: ReactionButton<Reactions>(
                                onReactionChanged: (r) {
                                  if (r == null || r.value == null) return;

                                  switch (r.value!) {
                                    case Reactions.copy:
                                      Clipboard.setData(ClipboardData(text: txt));
                                    case Reactions.share:
                                      Share.share(
                                        txt,
                                        sharePositionOrigin: Rect.fromLTWH(0, 0, MediaQuery.of(context).size.width, MediaQuery.of(context).size.height / 2),
                                      );
                                    case Reactions.delete:
                                      box.delete(key);
                                    case Reactions.translate:
                                      res.translate(key);
                                  }
                                },
                                boxPadding: const EdgeInsets.all(4),
                                boxColor: Theme.of(context).colorScheme.surface,
                                // toggle: false,
                                boxOffset: const Offset(0, -15),
                                isChecked: false,
                                itemSize: const Size(40, 40),
                                itemsSpacing: 8,
                                reactions: [
                                  if (displayText != null)
                                    Reaction(
                                      value: Reactions.copy,
                                      icon: const Icon(Icons.copy),
                                      title: Text(context.t.copy),
                                    ),
                                  if (displayText != null)
                                    Reaction(
                                      value: Reactions.share,
                                      icon: Icon(Icons.adaptive.share),
                                      title: Text(context.t.share),
                                    ),
                                  Reaction(
                                    value: Reactions.delete,
                                    icon: const Icon(Icons.delete),
                                    title: Text(context.t.delete),
                                  ),
                                  if (displayText != null)
                                    Reaction(
                                      value: Reactions.translate,
                                      icon: const Icon(Icons.translate),
                                      title: Text(context.t.translate),
                                    ),
                                ],
                                child: ResultCard(result: res, box: box, resKey: key)));
                      },
                    );
                  },
                ),
              );
            }),
          );
        });
  }
}

class GoToSettingsButton extends StatelessWidget {
  const GoToSettingsButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: IconButton(
        icon: Icon(
          Icons.tune,
          size: 30,
          color: Theme.of(context).colorScheme.surface,
        ),
        onPressed: () => context.goNamed(NamedRoutes.settings.name),
      ),
    );
  }
}

class GoToSupportButton extends StatelessWidget {
  const GoToSupportButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.local_cafe_outlined,
        size: 30,
        color: Theme.of(context).colorScheme.surface,
      ),
      onPressed: () => context.goNamed(NamedRoutes.support.name),
    );
  }
}

class CheckNowFab extends StatelessWidget {
  const CheckNowFab({
    super.key,
    required ScrollController scrollController,
  }) : _scrollController = scrollController;

  final ScrollController _scrollController;

  @override
  Widget build(BuildContext context) {
    return PrefBuilder<bool>(
        pref: Prefs.isCheckingForFiles,
        builder: (context, isChecking) {
          return ScrollingFabAnimated(
            color: Theme.of(context).colorScheme.primary,
            icon: isChecking
                ? LoadingAnimationWidget.staggeredDotsWave(
                    color: Colors.white,
                    size: 24,
                  )
                : Icon(
                    Icons.refresh,
                    color: Theme.of(context).colorScheme.surface,
                  ),
            text: Text(
              context.t.checkNow,
              style: TextStyle(color: Theme.of(context).colorScheme.surface, fontSize: 16.0),
            ),
            onPress: () {
              if (isDebug) {
                createAndCheck();
                return;
              }
              checkForNewAudios(userRequestedTrim: true);
            },
            scrollController: _scrollController,
            animateIcon: true,
            inverted: false,
            limitIndicator: 1,
            radius: 10.0,
            width: 156,
          );
        });
  }
}

class FeedbackButton extends StatelessWidget {
  const FeedbackButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        feedback.BetterFeedback.of(context).showAndUploadToGitHub(
          allowEmptyText: false,
          allowProdEmulatorFeedback: false,
          repoUrl: "https://github.com/tempo-riz/trimtalk",
          gitHubToken: dotenv.get("GITHUB_ISSUE_TOKEN"),
          onSucces: (_) => showSnackBar(context.t.thankYou),
          onError: (e) => showSnackBar(context.t.failedToSendFeedbackPleaseTryAgain),
          onCancel: () => showSnackBar(context.t.pleaseTryAgainWithText),
        );
      },
      icon: const Icon(Icons.feedback_outlined),
      iconSize: 30,
      color: Theme.of(context).colorScheme.surface,
    );
  }
}

class PickFileButton extends StatelessWidget {
  const PickFileButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        print("picking file");
        FilePickerResult? picked = await FilePicker.platform.pickFiles(
          // type: FileType.audio, doesn't seem to work properly
          type: FileType.custom, allowedExtensions: ['mp3', 'wav', 'aac', 'flac', 'ogg', 'm4a', 'opus'],
          allowCompression: false,
        );
        print("result: $picked");
        if (picked == null) return;

        File file = File(picked.files.single.path!);

        if (!isAudioFile(file.path)) {
          print('Not an audio file');
          return;
        }
        print('Processing shared file: ${file.path}');

        final res = Result.fromShare(file.path);
        final key = await DB.createResultAsync(res);

        await res.transcribe(key);
      },
      icon: const Icon(Icons.file_download_outlined),
      iconSize: 30,
      color: Theme.of(context).colorScheme.surface,
    );
  }
}

class Tutorial extends StatelessWidget {
  const Tutorial({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: ValueListenableBuilder(
          valueListenable: DB.dummyResultBox.listenable(),
          builder: (context, box, child) {
            final key = box.keys.first;
            final res = box.get(key)!;

            final color = Theme.of(context).colorScheme.primary;
            return SingleChildScrollView(
              child: Column(
                children: [
                  gap20,

                  Text(context.t.quickExplanation).bold().fontSize(18),
                  // gap16,
                  // Text(context.t.audioMessagesAppearLikeThat),
                  gap12,
                  ResultCard(
                    result: res,
                    box: box,
                    resKey: key,
                    isDummy: true,
                    onTap: () {
                      // only when it's transcribed
                      DB.setPref(Prefs.isTutoDone, true);
                      print("tapped");
                    },
                  ),
                  gap8,
                  if (res.transcript == null) Text(context.t.tapTheCardToLoadTheTranscript).textColor(color).bold(),
                  if (res.transcript != null && res.summary == null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("${context.t.tap} ").textColor(color).bold(),
                        Icon(
                          Icons.auto_fix_high,
                          color: color,
                        ),
                        Text(" ${context.t.toSummarize}").textColor(color).bold(),
                      ],
                    ),
                  if (res.summary != null) Text(context.t.tapTheCardToSeeDetails).textColor(color).bold(),
                  // if (res.summary != null && isDone) const Text("Now try on your own audios !"),
                  // ElevatedButton.icon(
                  //   onPressed: () {
                  //   },
                  //   icon: const Icon(Icons.tune),
                  //   label: const Text("Check settings"),
                  // ),

                  gap16,
                  gap16,
                  gap16,
                  gap16,

                  gap16,
                  TextButton.icon(
                    icon: const Icon(Icons.skip_next),
                    onPressed: () {
                      DB.setPref(Prefs.isTutoDone, true);
                    },
                    label: Text(context.t.skipTutorial).textColor(color),
                  ),

                  gap4,
                ],
              ),
            );
          }),
    );
  }
}

class LastRunIndicator extends StatelessWidget {
  const LastRunIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return const Text("TrimTalk");
    }
    return PrefBuilder<String>(
        pref: Prefs.lastRun,
        builder: (BuildContext context, String time) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                Icons.task_alt,
                color: Theme.of(context).colorScheme.surface,
              ),
              gap12,
              Text(time.toReadableTime()),
            ],
          );
        });
  }
}
