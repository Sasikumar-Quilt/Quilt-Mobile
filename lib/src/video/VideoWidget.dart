import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:quilt/src/Utility.dart';
import 'package:quilt/src/video/AudioPlayerManager.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../DashbaordWidget.dart';

class VideoWidget extends StatefulWidget {
  final String url;
  final String audioUrl;
  final String id;
  final Function(int index, Duration) updatePosition;
  final Function(int index, VideoPlayerController)? updateVideoController;
  final int index;
  final int lastPosition;
  final bool isMute;
  bool isPlay;
  final Duration duration;
  final bool isVideoAudio;
  final VideoPlayerController? videoPlayerController;
  final bool isVisible;

  VideoWidget(
      {required Key key,
      required this.url,
      required this.index,
      required this.updatePosition,
      required this.isMute,
      required this.isPlay,
      required this.duration,
      required this.lastPosition,
      required this.isVideoAudio,
      required this.audioUrl,
      required this.videoPlayerController,
      required this.id,
      required this.isVisible,
      required this.updateVideoController})
      : super(key: key);

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController? videoPlayerController;
  Duration? _lastPosition;
  String contentId = "";

  //final player = AudioPlayer();
  AudioPlayerManager audioPlayerManager = AudioPlayerManager();

  @override
  void initState() {
    super.initState();
    print("widget.isVisible");
    initVideo();
    if (widget.isVisible) {
      playAudio();
    }
  }

  void initVideo() {
    audioPlayerManager.setCurrentAction("Video");
    videoPlayerController = widget.videoPlayerController ?? null;
    _lastPosition = widget.duration;
    print("_lastPosition");
    print(widget.url);
    print(widget.index);
    print(_lastPosition);
    print(widget.audioUrl);
    print(widget.isVideoAudio);
    print("videoPlayerController.isInitialized");
    if (videoPlayerController == null) {
      videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(widget.url));
      videoPlayerController!.initialize().then((_) {
        print("videoInitialized");
        widget.updateVideoController!(widget.index, videoPlayerController!);
        if (_lastPosition != null && !widget.isVideoAudio) {
          videoPlayerController!.seekTo(_lastPosition!);
        }
        videoPlayerController!.play();
        //       Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        if (mounted) {
          setState(() {});
        }
      }).timeout(const Duration(seconds: 30)).catchError((onError){
        videoPlayerController!.dispose();
        print("failed to video url");
      });
    } else {
      videoPlayerController?.play();
      if (_lastPosition != null && !widget.isVideoAudio) {
        videoPlayerController!.seekTo(_lastPosition!);
      }
    }
    addVideoListener();
    videoPlayerController?.setLooping(true);
    if (widget.isMute) {
      videoPlayerController?.setVolume(0.0);
    }
  }

  void addVideoListener() {
    videoPlayerController!.addListener(() {
      if (!widget.isVideoAudio) {
        widget.updatePosition(
            widget.index, videoPlayerController!.value.position);
      }
    });
  }

  @override
  void didUpdateWidget(covariant VideoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      print("fullWidgetVisible");
      contentId = widget.id;
      playAudio();
    }
    if (widget.index == tempPageCount) {
      if (oldWidget.isMute != widget.isMute) {
        if (widget.isMute) {
          videoPlayerController!.setVolume(0.0);
        } else {
          videoPlayerController!.setVolume(1.0);
        }
        if (widget.isVideoAudio) {
          //player.setVolume(widget.isMute ? 0.0 : 1.0);
          audioPlayerManager.setVolume(widget.isMute);
        }
      }
      print("oldWidget");
      print(widget.index);
      print(widget.isPlay);
      print(oldWidget.isPlay);
      print("oldWidgetMute");
      print(widget.isMute);
      print(oldWidget.isMute);
      if (oldWidget.isPlay != widget.isPlay) {
        if (widget.isPlay) {
          addVideoListener();
          print("palyButton");
          if (audioPlayerManager.getCurrentAction() != "Video") {
            audioPlayerManager.setCurrentAction("Video");
            playAudio();
          } else {
            resumeAudio();
          }
          videoPlayerController!.play();
        } else {
          videoPlayerController!.removeListener(() {});
          print("pausedVideo");
          videoPlayerController!.pause();
          pauseAudio();
        }
      }
      if (oldWidget.lastPosition != widget.lastPosition) {
        print("tested");
        if (!widget.isVideoAudio) {
          videoPlayerController!.seekTo(widget.duration);
          videoPlayerController!.play();
        } else {
          audioPlayerManager.seek(widget.duration);
        }
      }
    } else {
      print("indexMissMatched");
    }
  }

  @override
  void dispose() {
    // videoPlayerController?.pause();
    if (widget.isVideoAudio) {
      print("dispose");
      //audioPlayerManager.pause();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("VideoWidgetLoaded");
    print("visibleFraction1");

    print(contentId);
    return videoPlayerController != null &&
                videoPlayerController!.value.isInitialized
            ? SizedBox.expand(
                child: FittedBox(
                fit: checkVideoRatio(
                    videoPlayerController!.value.size.width ?? 0,
                    videoPlayerController!.value.size.height ?? 0),
                child: SizedBox(
                  width: videoPlayerController!.value.size.width ?? 0,
                  height: videoPlayerController!.value.size.height ?? 0,
                  child: /*VisibilityDetector(
                    key: Key(contentId),
                    onVisibilityChanged: (VisibilityInfo info) {
                      */ /*print("visibleFraction2");
                      print(contentId);
                      print(info.key);
                      var visiblePercentage = info.visibleFraction * 100;
                      print(visiblePercentage);
                      if (visiblePercentage < 20) {
                        print("pausedVideo2");
                        videoPlayerController!.pause(); //pausing  functionality
                        pauseAudio();
                      } else {
                        if (widget.isPlay) {
                          print("pauseVideo3");
                          videoPlayerController!.play();
                          playAudio();
                        } else {

                          print("pausedVideo1");
                          videoPlayerController!.pause();
                          pauseAudio();
                        }
                      }*/ /*
                    },
                    child: VideoPlayer(videoPlayerController!),
                  )*/
                      VideoPlayer(videoPlayerController!),
                ),
              ))
            : Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Center(
                  child: Container(
                    height: 100,
                    width: 100,
                    color: Colors.black,
                    child: Center(
                        child: Lottie.asset(
                            "assets/images/feed_preloader.json") /* CircularProgressIndicator(
                      backgroundColor: Colors.grey,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                    )*/
                        ),
                  ),
                ),
              ) /*FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        return (snapshot.connectionState == ConnectionState.done)
            ;
      },
    )*/
        ;
  }

  checkVideoRatio(double width, double height) {
    if (width > height) {
      return BoxFit.contain;
    } else if (width < height) {
      return BoxFit.cover;
    } else {
      return BoxFit.contain;
    }
  }

  void playAudio() async {
    print("playAudioInVideoView");
    if (!widget.isVideoAudio || Utility.isEmpty(widget.audioUrl)) {
      return;
    }

    await audioPlayerManager.playAudio(widget.audioUrl, _lastPosition, true);
    /*if (_lastPosition != null) {
      await player.play(UrlSource(widget.audioUrl), position: _lastPosition);
    } else {
      await player.play(UrlSource(widget.audioUrl));
    }*/
    audioPlayerManager.withUpdateCallback((duration) => {
          //print(audioPlayerManager.getCurrentAction()),
          if (audioPlayerManager.getCurrentAction() == "Video")
            {
              if (duration.inMilliseconds != 0)
                {
                  _lastPosition = duration,
                  if (widget.isPlay)
                    {
                      if (videoPlayerController!.value.isPlaying)
                        {}
                      else
                        {
                          if (widget.isVideoAudio)
                            {videoPlayerController!.play()}
                        }
                    }
                  else
                    {videoPlayerController!.pause()},
                  widget.updatePosition(widget.index, duration)
                }
            }
        });
    /* player.onPlayerStateChanged.listen((event) {
      print("onPlayerStateChanged");
      print(event);
    });*/
    //player.setReleaseMode(ReleaseMode.loop);
    audioPlayerManager.setVolume(widget.isMute);
    if (!widget.isPlay) {
      audioPlayerManager.pause();
    }
    /* player.onPositionChanged.listen((event) {
      //print(event);
      if (widget.isPlay) {
        if (videoPlayerController!.value.isPlaying) {
        } else {
          if (widget.isVideoAudio) {
            videoPlayerController!.play();
          }
        }
      } else {
        videoPlayerController!.pause();
      }

      if (event.inMilliseconds != 0) {
        _lastPosition = event;
        widget.updatePosition(widget.index, event);
      }
    });*/
  }

  void resumeAudio() {
    if (!widget.isVideoAudio ||
        Utility.isEmpty(widget.audioUrl) ||
        (audioPlayerManager.player.state == PlayerState.disposed)) {
      return;
    }
    audioPlayerManager.resumeAudio();
  }

  void pauseAudio() {
    if (!widget.isVideoAudio ||
        Utility.isEmpty(widget.audioUrl) ||
        (audioPlayerManager.player.state == PlayerState.disposed)) {
      return;
    }
    print("pausedisVideoAudio");
    audioPlayerManager.pause();
  }
}
