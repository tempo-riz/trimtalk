import 'dart:io';

import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:trim_talk/model/utils.dart';
import 'package:trim_talk/router.dart';
import 'package:trim_talk/types/result.dart';
import 'package:trim_talk/view/widgets/audio_player_opus.dart';
import 'package:trim_talk/view/widgets/audio_player_standard.dart';
import 'package:trim_talk/view/widgets/audio_player_wave.dart';

class TranscriptScreen extends StatelessWidget {
  const TranscriptScreen({super.key, required this.result});

  final Result result;

  @override
  Widget build(BuildContext context) {
    final path = result.path;

    Widget player;
    if (Platform.isIOS) {
      if (path.endsWith(".opus")) {
        player = AudioPlayerOpus(path: path, duration: result.duration);
      } else {
        player = AudioPlayerStandard(path: path, duration: result.duration);
      }
    } else {
      player = AudioPlayerWave(path: path);
    }

    return Scaffold(
      appBar: AppBar(
        // bottom: const PreferredSize(
        //   preferredSize: Size.fromHeight(10),
        //   child: SizedBox(),
        // ),
        leading: IconButton(
          icon: Icon(Icons.adaptive.arrow_back),
          color: Theme.of(context).colorScheme.surface,
          onPressed: () {
            // pop if coming from transcript list screen
            if (router.canPop()) {
              return router.pop();
            }
            context.goNamed(NamedRoutes.dashboard.name);
          },
        ),
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(child: Text(result.sender ?? context.t.audioMessage)),
            gap4,
            // // const Text("  |   "),
            gap4,
            Text(result.duration),
          ],
        ),
      ),
      body: Container(
        height: MediaQuery.sizeOf(context).height - AppBar().preferredSize.height,
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              gap24,
              DateInfoWidget(result: result),
              gap16,
              if (result.summary != null) SummaryPart(summary: result.summary!),
              // gap12,
              Text(result.transcript ?? "transcribing...", style: const TextStyle(fontSize: 17.5)),
              gap8,
              // gap8,

              player,
              // gap8,
              CopyTextButton(label: context.t.copyTranscript, textToCopy: result.transcript),
              gap64,
            ],
          ),
        ),
      ),
    );
  }
}

class DateInfoWidget extends StatelessWidget {
  const DateInfoWidget({
    super.key,
    required this.result,
  });

  final Result result;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          result.date,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w400),
        ),
        gap8,
        const Icon(
          Icons.schedule,
          size: 20,
        )
      ],
    );
  }
}

class SummaryPart extends StatelessWidget {
  const SummaryPart({
    super.key,
    required this.summary,
  });

  final String summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            context.t.summary,
          ).bold(),
        ),
        gap8,
        Text(summary, style: const TextStyle(fontSize: 17.5)),
        gap12,
        CopyTextButton(label: context.t.copySummary, textToCopy: summary),
        gap12,
        // const Divider(color: Colors.black),
      ],
    );
  }
}

class CopyTextButton extends StatefulWidget {
  const CopyTextButton({
    super.key,
    required this.label,
    required this.textToCopy,
  });

  final String label;
  final String? textToCopy;

  @override
  State<CopyTextButton> createState() => _CopyTextButtonState();
}

class _CopyTextButtonState extends State<CopyTextButton> {
  bool isCopied = false;

  @override
  Widget build(BuildContext context) {
    if (widget.textToCopy == null) return const SizedBox();

    final txt = "${widget.textToCopy}\n\n${context.t.madeWithTt} https://upotq.app.link/trimtalk";

    return ElevatedButton.icon(
        onPressed: () {
          Clipboard.setData(ClipboardData(text: txt));
          setState(() {
            isCopied = true;
          });
          Future.delayed(const Duration(seconds: 2), () {
            if (!mounted) return;
            setState(() {
              isCopied = false;
            });
          });
        },
        label: Text(isCopied ? context.t.copied : widget.label),
        icon: Icon(isCopied ? Icons.done : Icons.copy));
  }
}
