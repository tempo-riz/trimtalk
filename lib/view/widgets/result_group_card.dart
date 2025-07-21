import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:trim_talk/model/stt/result_extensions.dart';
import 'package:trim_talk/types/result.dart';
import 'package:trim_talk/view/widgets/result_card.dart';

class ResultGroupCard extends StatefulWidget {
  const ResultGroupCard({super.key, required this.box, required this.keys});

  final Box<Result> box;
  final List<int> keys;

  @override
  State<ResultGroupCard> createState() => _ResultGroupCardState();
}

class _ResultGroupCardState extends State<ResultGroupCard> {
  // String? summary;
  bool loadingSummary = false;
  // disapear when done
  // bool done = false;
  @override
  Widget build(BuildContext context) {
    // if (done) return const SizedBox.shrink();

    if (widget.keys.length < 2) return const SizedBox.shrink();

    final results = widget.keys.map((key) => widget.box.get(key)).whereType<Result>().toList();

    if (!results.every((r) => r.transcript != null)) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(8.0).copyWith(top: 20),
      child: CircleAvatar(
        maxRadius: 30,
        child: Center(
          child: loadingSummary
              ? LoadingWidget()
              : IconButton(
                  onPressed: () async {
                    setState(() => loadingSummary = true);
                    // remove the keys from the box and add the new result
                    final res = await results.summarizeAsOneAndMerge();
                    if (mounted) {
                      setState(() => loadingSummary = false);
                    }
                    if (res == null) {
                      return;
                    }

                    for (final key in widget.keys) {
                      await widget.box.delete(key);
                    }
                    widget.box.add(res);

                    // it will disapear alone
                    // setState(() => done = true);
                  },
                  icon: Icon(
                    Icons.auto_fix_high,
                    size: 30,
                  )),
        ),
      ),
    );
  }
}
