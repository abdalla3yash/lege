import 'dart:developer';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';

class PlayerNow extends StatefulWidget {
  const PlayerNow(
      {super.key, required this.songModel, required this.audioPlayer});
  final SongModel songModel;
  final AudioPlayer audioPlayer;
  @override
  State<PlayerNow> createState() => _PlayerNowState();
}

class _PlayerNowState extends State<PlayerNow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..repeat();

  Duration _duration = const Duration();
  Duration _position = const Duration();
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    playSong();
  }

  void playSong() {
    try {
      widget.audioPlayer.setAudioSource(AudioSource.uri(
        Uri.parse(
          widget.songModel.uri!,
        ),
        tag: MediaItem(
          id: '${widget.songModel.id}',
          album: "${widget.songModel.album}",
          title: widget.songModel.displayNameWOExt,
          artUri: Uri.parse(
              'https://thumbs.dreamstime.com/b/music-banner-mobile-smartphone-screen-music-application-sound-headphones-audio-voice-radio-beats-black-background-220823216.jpg'),
        ),
      ));
      widget.audioPlayer.play();
      isPlaying = true;
    } on Exception {
      log("Error Parsing Song!");
    }
    widget.audioPlayer.durationStream.listen((d) {
      setState(() {
        _duration = d!;
      });
    });
    widget.audioPlayer.positionStream.listen((p) {
      setState(() {
        _position = p;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_ios),
              ),
              SizedBox(
                height: height * 0.1,
              ),
              Center(
                child: Column(children: [
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (_, child) {
                      return Transform.rotate(
                        angle: _controller.value * 2 * math.pi,
                        child: child,
                      );
                    },
                    child: const CircleAvatar(
                      backgroundColor: Color.fromARGB(255, 195, 214, 22),
                      radius: 100.0,
                      child: Icon(
                        color: Colors.white,
                        Icons.music_note_rounded,
                        size: 80.0,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: height * 0.05,
                  ),
                  Text(
                    widget.songModel.displayNameWOExt,
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30.0,
                    ),
                  ),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  Text(
                    widget.songModel.artist.toString() == "<unknown>"
                        ? "UnKnown Artist"
                        : widget.songModel.artist.toString(),
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                  SizedBox(
                    height: height * 0.05,
                  ),
                  Row(
                    children: [
                      Text(_position.toString().split(".")[0]),
                      Expanded(
                        child: Slider(
                          activeColor: const Color.fromARGB(255, 195, 214, 22),
                          inactiveColor:
                              const Color.fromARGB(255, 196, 219, 224),
                          min: const Duration(seconds: 0).inSeconds.toDouble(),
                          value: _position.inSeconds.toDouble(),
                          max: _duration.inSeconds.toDouble(),
                          onChanged: (value) {
                            setState(
                              () {
                                changeToSceonds(value.toInt());
                                value = value;
                              },
                            );
                          },
                        ),
                      ),
                      Text(_duration.toString().split(".")[0]),
                    ],
                  ),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.skip_previous_rounded,
                            size: 40.0,
                          )),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              if (isPlaying) {
                                widget.audioPlayer.pause();
                              } else {
                                widget.audioPlayer.play();
                              }

                              isPlaying = !isPlaying;
                            });
                          },
                          icon: Icon(
                            isPlaying
                                ? _position.inSeconds.toDouble() ==
                                        _duration.inSeconds.toDouble()
                                    ? Icons.play_arrow_rounded
                                    : Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            size: 40.0,
                            color: const Color.fromARGB(255, 195, 214, 22),
                          )),
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.skip_next_rounded,
                            size: 40.0,
                          )),
                    ],
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void changeToSceonds(int second) {
    Duration duration = Duration(seconds: second);
    widget.audioPlayer.seek(duration);
  }
}
