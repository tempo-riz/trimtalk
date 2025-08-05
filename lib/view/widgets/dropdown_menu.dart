import 'package:feedback_github/feedback_github.dart' as feedback;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trim_talk/model/utils.dart';
import 'package:trim_talk/router.dart';
import 'package:url_launcher/url_launcher.dart';

class MenuDropdown extends StatefulWidget {
  const MenuDropdown({
    super.key,
  });

  @override
  State<MenuDropdown> createState() => _MenuDropdownState();
}

class _MenuDropdownState extends State<MenuDropdown> {
  late final controller = MenuController();

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
        controller: controller,
        alignmentOffset: const Offset(0, 6),
        menuChildren: <Widget>[
          const GoToSettingsButton(),
          FeedbackButton(onStart: () => controller.close()),
          const GoToSupportButton(),
          const ShareButton(),
          const RateOnStoreButton(),
          const SeeOnGithubButton(),
        ],
        child: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            icon: Icon(
              Icons.more_vert,
              size: 26,
              color: Theme.of(context).colorScheme.surface,
            ),
            onPressed: () => controller.isOpen ? controller.close() : controller.open(),
          ),
        ));
  }
}

class GoToSettingsButton extends StatelessWidget {
  const GoToSettingsButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
        onPressed: () => context.goNamed(NamedRoutes.settings.name),
        label: SizedBox(
          width: double.infinity,
          child: Text("Settings"),
        ),
        icon: const Icon(
          Icons.tune,
          size: 26,
        ));
  }
}

class GoToSupportButton extends StatelessWidget {
  const GoToSupportButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => context.goNamed(NamedRoutes.support.name),
      icon: const Icon(
        Icons.local_cafe_outlined,
        size: 26,
      ),
      label: SizedBox(
        width: double.infinity,
        child: Text(
          "Support",
        ),
      ),
    );
  }
}

class FeedbackButton extends StatelessWidget {
  const FeedbackButton({
    super.key,
    this.onStart,
  });

  final void Function()? onStart;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        onStart?.call();
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
      label: SizedBox(child: Text("Feedback")),
      icon: const Icon(
        Icons.feedback_outlined,
        size: 26,
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
    return TextButton.icon(
        onPressed: () {
          SharePlus.instance.share(ShareParams(
            text: "${context.t.heyImUsingTtToTranscribeAndSummarizeCheckItOut} \n\nhttps://upotq.app.link/trimtalk",
            subject: context.t.shareTt,
            sharePositionOrigin: Rect.fromLTWH(0, 0, MediaQuery.of(context).size.width, MediaQuery.of(context).size.height / 2),
          )); // Share
        },
        label: SizedBox(
          width: double.infinity,
          child: Text("Share the app"),
        ),
        icon: Icon(
          Icons.adaptive.share,
          size: 26,
        ));
  }
}

class RateOnStoreButton extends StatelessWidget {
  const RateOnStoreButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: const Icon(
        Icons.star_border,
        size: 26,
      ),
      onPressed: () {
        InAppReview.instance.openStoreListing(appStoreId: "6720703110");
      },
      label: SizedBox(
        width: double.infinity,
        child: Text("Rate TrimTalk"),
      ),
    );
  }
}

class SeeOnGithubButton extends StatelessWidget {
  const SeeOnGithubButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: const Icon(
        Icons.code,
        size: 26,
      ),
      onPressed: () {
        launchUrl(Uri.parse('https://github.com/tempo-riz/trimtalk'));
      },
      label: SizedBox(
        width: double.infinity,
        child: Text("Check the code"),
      ),
    );
  }
}
