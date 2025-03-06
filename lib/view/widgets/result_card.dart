import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:trim_talk/model/stt/result_extensions.dart';
import 'package:trim_talk/model/utils.dart';
import 'package:trim_talk/model/check_new.dart';
import 'package:trim_talk/types/result.dart';
import 'package:trim_talk/router.dart';
import 'package:trim_talk/view/widgets/scale_on_press.dart';

class ResultCard extends StatefulWidget {
  const ResultCard({
    super.key,
    required this.result,
    required this.box,
    required this.resKey,
    this.isDummy = false,
    this.onTap,
  });

  final Result result;
  final Box<Result> box;
  final int resKey;
  final bool isDummy;
  final void Function()? onTap;

  @override
  State<ResultCard> createState() => _ResultCardState();
}

class _ResultCardState extends State<ResultCard> {
  bool isExpanded = false;

  final maxLines = 6;
  // final summaryThreshHold = 600;

  @override
  Widget build(BuildContext context) {
    // so it's less verbose
    final resKey = widget.resKey;
    final box = widget.box;
    final res = widget.result;
    final transcript = res.transcript;
    final summary = res.summary;
    final isLoadingTranscript = res.loadingTranscript;
    final isLoadingSummary = res.loadingSummary;
    // final longEnoughToSummarize = (transcript?.length ?? 0) > summaryThreshHold || widget.isDummy;

    final canSummarize = transcript != null && summary == null && !isLoadingSummary && !isLoadingTranscript;
    final textOnCard = summary ?? transcript ?? "";

    void onCardTap() async {
      if (widget.isDummy) {
        if (transcript == null) {
          await box.put(resKey, res.copyWith(loadingTranscript: true));
          await Future.delayed(const Duration(seconds: 1));
          await box.put(resKey, dummyResultWithTranscript);
        } else {
          context.pushNamed(NamedRoutes.transcript.name, extra: res);
          if (summary != null) {
            widget.onTap?.call();
          }
        }
        return;
      }
      if (transcript != null) {
        context.pushNamed(NamedRoutes.transcript.name, extra: res);
        return;
      }
      // otherwise transcribe !
      if (isLoadingTranscript) {
        return;
      }
      transcribeFileAndShowResult(resKey);
    }

    void onSummarizeTap() async {
      if (widget.isDummy) {
        box.put(resKey, res.copyWith(loadingSummary: true));
        await Future.delayed(const Duration(seconds: 1));
        box.put(resKey, dummyResultWithTranscriptAndSummaty);
        return;
      }

      await res.summarize(resKey);
    }

    return LayoutBuilder(builder: (context, constraints) {
      // ih has more text to display show expand icon
      final span = TextSpan(text: textOnCard);
      final tp = TextPainter(text: span, textDirection: TextDirection.ltr);
      final width = constraints.maxWidth - 24; // 12 padding on each side
      tp.layout(maxWidth: width);
      final numLines = tp.computeLineMetrics().length;

      final hasMoreLinesToExpand = numLines > maxLines;
      final showSummarizeButton = canSummarize && hasMoreLinesToExpand;

      return ScaleOnPress(
        // behavior: HitTestBehavior.translucent,
        onTap: onCardTap,
        child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            ),
            child: Column(
              children: [
                if (res.sender != null)
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.all(12).copyWith(bottom: 0),
                    child: Text(
                      res.sender!,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                if (textOnCard.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(12).copyWith(bottom: 0),
                    child: Text(
                      textOnCard,
                      softWrap: true,
                      maxLines: isExpanded ? 800 : maxLines,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                SizedBox(
                  height: 50,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: Text(
                          "${res.duration.padRight(5)}  |   ${res.date}", // todo pad this
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      const Spacer(
                        flex: 5,
                      ),
                      // START OF RIGHT SIDE
                      if (transcript == null && isLoadingTranscript) const LoadingWidget(),
                      if (transcript == null && !isLoadingTranscript)
                        const Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Icon(
                            Icons.circle_outlined,
                            size: 30,
                          ),
                        ),
                      // const Spacer(),
                      if (showSummarizeButton)
                        IconButton(
                          visualDensity: VisualDensity.standard,
                          icon: const Icon(
                            Icons.auto_fix_high, // also compress,auto_fix_high, summarize
                            size: 30,
                          ),
                          onPressed: onSummarizeTap,
                        ),
                      if (summary == null && isLoadingSummary) const LoadingWidget(),
                      if (hasMoreLinesToExpand)
                        IconButton(
                          visualDensity: VisualDensity.standard,
                          icon: AnimatedRotation(
                            duration: const Duration(milliseconds: 350),
                            turns: isExpanded ? 0.5 : 0,
                            child: const Icon(
                              Icons.expand_circle_down_outlined,
                              size: 30,
                            ),
                          ),
                          onPressed: () => setState(() {
                            isExpanded = !isExpanded;
                          }),
                        ),
                      gap4,
                    ],
                  ),
                )
              ],
            )),
      );
    });
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: LoadingAnimationWidget.staggeredDotsWave(
        color: Theme.of(context).colorScheme.primary,
        size: 30,
      ),
    );
  }
}
