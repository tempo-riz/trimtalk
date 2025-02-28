import 'dart:io';

import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';
import 'package:trim_talk/model/files/permissions.dart';
import 'package:trim_talk/model/utils.dart';
import 'package:trim_talk/router.dart';
import 'package:trim_talk/view/dashboard_screen.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  bool readFiles = false;
  bool isLegacy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => getInitialStatus());
  }

  // called right after initstate
  void getInitialStatus() async {
    final read = await Permissions.isReadFilesAllowed();
    if (read) return router.goNamed(NamedRoutes.dashboard.name);
    final legacy = await Permissions.isLegacyStorage();
    if (mounted) {
      setState(() {
        readFiles = read;
        isLegacy = legacy;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(context.t.letsGetStarted),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: FeedbackButton(),
            )
          ],
        ),
        body: Container(
          margin: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                context.t.ttNeedsToAccesAudioFiles,
                textAlign: TextAlign.center,
              ).fontSize(18),
              gap20,
              if (!isLegacy) const NonLegacyPrecisionWidget(),
              if (readFiles) TitleCheck(title: context.t.readAudioFiles, check: readFiles),
              if (!readFiles)
                FilePermissionButton(
                  onSucces: () async {
                    setState(() {
                      readFiles = true;
                    });
                    // show tick
                    await Future.delayed(const Duration(milliseconds: 500));
                    router.goNamed(NamedRoutes.dashboard.name);
                  },
                ),
              gap8,
              Text(
                context.t.yourDataIsPrivateAndNeverShared,
                textAlign: TextAlign.center,
              ).fontSize(14),
              gap32,
            ],
          ),
        ));
  }

  // Future<void> showPrecisionForNonLegacyModal(BuildContext context) {
  //   return showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         // titlePadding: const EdgeInsets.all(16),
  //         contentPadding: const EdgeInsets.all(16),
  //         title: const Text('Give access to "WhatsApp Voice Notes"').fontSize(16).bold(),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             const Text('It should open as default location. If not navigate to:'),
  //             gap8,
  //             const Text('Android > media > com.whatsapp > WhatsApp > Media >').bold(),
  //           ],
  //         ),

  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               router.pop();
  //               // Navigator.of(context, rootNavigator: true).pop();
  //             },
  //             child: const Text("Okay").bold().fontSize(16),
  //           )
  //         ],
  //       );
  //     },
  //   );
  // }
}

class FilePermissionButton extends StatelessWidget {
  const FilePermissionButton({
    super.key,
    required this.onSucces,
  });

  final void Function() onSucces;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      label: Text(context.t.givePermission),
      icon: const Icon(Icons.folder),
      onPressed: () async {
        final res = await Permissions.askReadFiles();
        if (res) onSucces();
      },
    );
  }
}

class NonLegacyPrecisionWidget extends StatelessWidget {
  const NonLegacyPrecisionWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.t.giveAccesToTheFollowingFolder),
          gap8,
          const Text('Android > media > com.whatsapp > WhatsApp > Media > WhatsApp Voice Notes').fontWeight(FontWeight.w500),
        ],
      ),
    );
  }
}

class TitleCheck extends StatelessWidget {
  const TitleCheck({
    super.key,
    required this.title,
    required this.check,
  });

  final String title;
  final bool check;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title).fontWeight(FontWeight.w500),
        if (check) ...[
          gap4,
          Icon(Icons.check_circle_outline, color: Theme.of(context).colorScheme.primary),
        ],
      ],
    );
  }
}
