import 'dart:io';

import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:trim_talk/model/files/db.dart';
import 'package:trim_talk/model/utils.dart';
import 'package:trim_talk/router.dart';
import 'package:trim_talk/view/settings_screen.dart';

class ExplainScreen extends StatelessWidget {
  const ExplainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("TrimTalk"),
      ),
      body: Container(
        margin: const EdgeInsets.all(30),
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: AppLanguageDropDown()),
            gap24,
            Text(
              context.t.ttMeaning,
            ).fontSize(16),
            gap24,
            if (Platform.isIOS)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.t.transcribeAndSummarizeBySharingThemWithTheApp,
                    ).fontSize(16),
                  ),
                  gap8,
                  const Icon(
                    Icons.ios_share,
                    size: 35,
                  ),
                ],
              ),
            if (Platform.isAndroid) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(context.t.transcribeAndSummarizeWhatsAppAudioMessages).fontSize(16),
                  ),
                  gap4,
                  SvgPicture.asset(
                    "assets/images/whatsapp.svg",
                    height: 40,
                    width: 40,
                    // color: Colors.green,
                  ),
                ],
              ),
              gap24,
              Row(
                children: [
                  Expanded(
                    child: Text(context.t.youCanAlsoTranscribeOtherAudioFilesBySharingThemWithTheApp).fontSize(16),
                  ),
                  gap8,
                  const Icon(
                    Icons.share,
                    size: 35,
                  ),
                ],
              ),
              gap24,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // gap12,
                  Expanded(child: Text(context.t.stillInDevDisclaimer)),
                  gap8,
                  const Icon(
                    Icons.feedback_outlined,
                    size: 40,
                  ),
                  // gap12
                ],
              ),
            ],
            gap24,
            Center(
              child: ElevatedButton.icon(
                label: Text(context.t.okay),
                icon: const Icon(Icons.check_box),
                onPressed: () async {
                  await DB.setPref(Prefs.isAcknowledged, true);
                  if (!context.mounted) return;

                  if (Platform.isIOS) return context.goNamed(NamedRoutes.dashboard.name);
                  context.goNamed(NamedRoutes.permissions.name);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
