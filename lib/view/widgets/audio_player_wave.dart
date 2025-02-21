import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:trim_talk/model/utils.dart';

class AudioPlayerWave extends StatefulWidget {
  const AudioPlayerWave({super.key, required this.path});

  final String path;

  @override
  State<AudioPlayerWave> createState() => _AudioPlayerWaveState();
}

class _AudioPlayerWaveState extends State<AudioPlayerWave> {
  PlayerController controller = PlayerController(); // Initialise
  bool isPlaying = false;
  bool isSetup = false;
  bool hasError = false;
  final double spacing = 6;

  late Future<void> playerFuture;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setupPlayer();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  Future<void> setupPlayer() async {
    if (isSetup) return;
    isSetup = true;
    if (!mounted) return;

    controller.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      if (state == PlayerState.playing) {
        setState(() {
          isPlaying = true;
        });
      } else {
        setState(() {
          isPlaying = false;
        });
      }
    });

    final width = MediaQuery.of(context).size.width - 120; // button size

    try {
      playerFuture = controller.preparePlayer(
        path: widget.path,
        shouldExtractWaveform: true,
        noOfSamples: getSamplesForWidth(width), // Get samples for width
        volume: 0.8,
      );
    } catch (e) {
      print('Error setting file path ${widget.path} wave player: $e');
      hasError = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return gap12;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.filled(
          onPressed: () {
            final state = controller.playerState;

            if (state == PlayerState.stopped) {
              // not ready
              return;
            }

            if (state == PlayerState.playing) {
              controller.pausePlayer();
            } else {
              controller.startPlayer();
            }
          },
          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
        ),
        gap12,
        Expanded(
          child: LayoutBuilder(builder: (context, constraints) {
            final width = constraints.maxWidth;

            return FutureBuilder(
                future: playerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const SizedBox(
                      height: 120,
                      width: 100,
                    );
                  }
                  if (!mounted) return const SizedBox();

                  return AudioFileWaveforms(
                    size: Size(width, 120),
                    playerController: controller,
                    enableSeekGesture: true,
                    waveformType: WaveformType.fitWidth,
                    playerWaveStyle: PlayerWaveStyle(
                      fixedWaveColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                      liveWaveColor: Theme.of(context).colorScheme.primary,
                      spacing: spacing,
                    ),
                  );
                });
          }),
        ),
      ],
    );
  }

  int getSamplesForWidth(double width) {
    return width ~/ spacing;
  }
}
