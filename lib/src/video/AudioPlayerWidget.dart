import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_state/phone_state.dart';
import 'package:quilt/main.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../api/Objects.dart';
import '../feedback/FeedbackWidget.dart';
import 'AudioPlayerManager.dart';
import 'PreloadVideo.dart';
import 'SeekBarWidget.dart';
import 'VideoPlayerWidget.dart';

class AudioPlayerWidget extends StatefulWidget {
  const AudioPlayerWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AudioPlayerWidgetState();
  }
}

class AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  StreamSubscription<PhoneState>? _phoneStateSubscription;

  ContentObj? contentObj;
  bool isTap = true;
  String _positionText = '00:00';
  double _sliderValue = 0;
  bool _isSliding = false;
  bool isCompleted = false;
  bool isReplay = false;
  bool isMute = false;
  bool isPlay = true;
  bool isbPlay = true;
  bool isArg = false;

  //final player = AudioPlayer();
  Duration? _duration;
  Duration? _position;
  late VideoPlayerController? videoPlayerController;
  late PreloadVideos preloadVideos;
  AudioPlayerManager audioPlayerManager = AudioPlayerManager();
 bool isDestroy=false;
  @override
  void initState() {
    super.initState();
    audioPlayerManager.setCurrentAction("Audio");
    preloadVideos = PreloadVideos(updateWidget);
    WakelockPlus.enable();
    requestPermission();
  }

  void updateWidget() {
    print("updateWidget");
   if(mounted){
     setState(() {});
   }
  }

  void setStream() {
    _phoneStateSubscription = PhoneState.stream.listen((status) {
      setState(() {
        if (status.status == PhoneStateStatus.CALL_INCOMING ||
            status.status == PhoneStateStatus.CALL_STARTED) {
          videoPlayerController?.pause();
          //player!.pause();
          audioPlayerManager!.pause();
          isbPlay = isPlay;
          isPlay = false;
        } else {
          if (isbPlay) {
            isPlay = true;
            videoPlayerController?.play();
            //player!.resume();
            audioPlayerManager!.resumeAudio();
          }
        }
      });
    });
  }

  void requestPermission() async {
    if (Platform.isAndroid) {
      var status = await Permission.phone.isGranted;
      if (status) {
        setStream();
      } /*else{
        var status = await Permission.phone.request();
        if(status==PermissionStatus.granted){
          setStream();
        }
      }*/
    } else {
      setStream();
    }
  }

  getArgs() async {
    if (!isArg) {
      isArg = true;
      final args = ModalRoute.of(context)?.settings.arguments as Map;
      contentObj = args["url"];
      print("audioUrl");
      print(contentObj!.audioURL);
      print(contentObj!.videoURL);
      if(args["index"]!=null){
        int index=args["index"];
        preloadVideos.playControllerAtIndex(index);
        videoPlayerController = preloadVideos.controllers[index] ?? null;
        if (videoPlayerController != null) {
          videoPlayerController?.play();
        }else{
          videoPlayerController = new VideoPlayerController.networkUrl(
              Uri.parse(contentObj!.videoURL),
              videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));
          videoPlayerController!.initialize().then((_) {
            videoPlayerController?.play();

            //       Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.

            setState(() {});
          });
        }
        isDestroy=false;
      }else{
        isDestroy=true;
        videoPlayerController = new VideoPlayerController.networkUrl(
            Uri.parse(contentObj!.videoURL),
            videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));
        videoPlayerController!.initialize().then((_) {
          videoPlayerController?.play();

          //       Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.

          setState(() {});
        });
      }

      print("duration");
      print(contentObj!.duration);
      print(contentObj!.videoURL);

      videoPlayerController?.setLooping(true);
      videoPlayerController?.setVolume(0.0);
      /* if(contentObj!.duration!=null){
        await player.play(UrlSource(contentObj!.audioURL!),position:contentObj!.duration);
      }else{
        await player.play(UrlSource(contentObj!.audioURL!));
      }*/
      await audioPlayerManager.playAudio(
          contentObj!.audioURL!, contentObj!.duration, false);
      videoPlayerController?.play();
      audioPlayerManager.setVolume(false);
      if (mounted) {
        setState(() {});
      }
      audioPlayerManager.player.getDuration().then(
            (value) => setState(() {
              _duration = value;
              print("audioDuration");
              print(_duration);
            }),
          );
      audioPlayerManager.player.onPlayerComplete.listen((event) {
        if (audioPlayerManager.getCurrentAction() == "Audio")
        {
          audioPlayerManager.pause();
        videoPlayerController?.pause();
        Navigator.pushNamed(context, HomeWidgetRoutes.VideoCompletedWidget,
            arguments: {"object": contentObj})
            .then((value) => {replayVideo(value)});

        }

      });
      audioPlayerManager.withUpdateCallback((duration) => {
            if (audioPlayerManager.getCurrentAction() == "Audio")
              {
                if (isPlay)
                  {
                    if (videoPlayerController != null)
                      {
                        if (videoPlayerController!.value.isPlaying)
                          {
                            // print("isPlaying");
                          }
                        else
                          {
                            //print("isPlayingNot");
                            videoPlayerController?.play()
                          }
                      },
                    _position = duration,
                    //print("currentPos");
                    _sliderValue = _position!.inSeconds.toDouble()
                  }
                else
                  {videoPlayerController?.pause()},
                if (mounted) {setState(() {})}
              }
          });
      /* player.onPositionChanged.listen((event) {
        if(isPlay){
          if(videoPlayerController!=null){
            if(videoPlayerController!.value.isPlaying){
              // print("isPlaying");
            }else{
              //print("isPlayingNot");
              videoPlayerController?.play();
            }
          }
          _position = event;
          //print("currentPos");
          _sliderValue = _position!.inSeconds.toDouble();
        }else{
          videoPlayerController?.pause();
        }

if(mounted){
  setState(() {

  });
}
      });*/
    }
  }

  void onError(message) {
    print("onError");
    print(message);
  }

  void replayVideo(value) {
    if (value != null && value["isReplay"]) {
      //player.play(UrlSource(contentObj!.audioURL!));
      audioPlayerManager.playAudio(contentObj!.audioURL!, null, false);
      videoPlayerController?.play();
      isReplay = true;
      isPlay = true;
      setState(() {});
    } else {
      Navigator.of(context).pop({"position": _position});
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    print("AudioPlayerWidget");

     audioPlayerManager.pause();
    _phoneStateSubscription!.cancel();
    if(isDestroy){
      videoPlayerController?.dispose();
    }else{
      videoPlayerController?.pause();
    }

    videoPlayerController = null;
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

  @override
  Widget build(BuildContext context) {
    getArgs();
    return WillPopScope(
        child: SafeArea(
            child: Scaffold(
          appBar: null,
          backgroundColor: Colors.black,
          body: GestureDetector(
            child: Stack(
              children: [
                videoPlayerController != null
                    ? SizedBox.expand(
                        child: FittedBox(
                        fit: checkVideoRatio(
                            videoPlayerController!.value.size.width ?? 0,
                            videoPlayerController!.value.size.height ?? 0),
                        child: SizedBox(
                          width: videoPlayerController!.value.size.width ?? 0,
                          height: videoPlayerController!.value.size.height ?? 0,
                          child: VisibilityDetector(
                            key: Key("widget.url"),
                            onVisibilityChanged: (VisibilityInfo info) {
                              print("visibleFraction");
                              var visiblePercentage =
                                  info.visibleFraction * 100;

                              print(visiblePercentage);
                              if (visiblePercentage < 20) {
                                videoPlayerController
                                    ?.pause(); //pausing  functionality
                                audioPlayerManager.pause();
                              } else {
                                videoPlayerController?.play();
                                audioPlayerManager.resumeAudio();
                              }
                            },
                            child: VideoPlayer(videoPlayerController!),
                          ),
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
                                child: Lottie.asset("assets/images/feed_preloader.json")),
                          ),
                        ),
                      ),
                isTap
                    ? Align(
                        child: Container(
                          margin: EdgeInsets.all(10),
                          child: Row(
                            children: [
                              InkWell(
                                child: Container(
                                  child: SvgPicture.asset(
                                    "assets/images/close.svg",
                                    semanticsLabel: 'Acme Logo',
                                    width: 25,
                                    height: 25,
                                    fit: BoxFit.scaleDown,
                                  ),
                                  margin: EdgeInsets.only(left: 5),
                                ),
                                onTap: () {
                                  showFeedbackDialog();
                                },
                              ),
                              Expanded(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    child: Text(
                                      contentObj!.contentName!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Color(0xFFF8F7F8),
                                          fontSize: 14,
                                          fontFamily: "Causten-SemiBold"),
                                    ),
                                  ),
                                  Container(
                                    child: Text(
                                      contentObj!.contentDuration! + " min",
                                      style: TextStyle(
                                          color: Color(0xFFF8F7F8)
                                              .withOpacity(0.8),
                                          fontSize: 14,
                                          fontFamily: "Causten-Regular"),
                                    ),
                                    margin: EdgeInsets.only(top: 2),
                                  ),
                                ],
                              )),
                              InkWell(
                                child: Container(
                                  child: SvgPicture.asset(
                                      isMute
                                          ? "assets/images/muted.svg"
                                          : "assets/images/mute.svg",
                                      semanticsLabel: 'Acme Logo'),
                                  margin: EdgeInsets.only(
                                      left: 0, bottom: 0, right: 5),
                                ),
                                onTap: () {
                                  isMute = !isMute;
                                  audioPlayerManager!.setVolume(isMute);
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                        ),
                        alignment: Alignment.topCenter)
                    : Container(),
                isTap && _duration != null
                    ? Align(
                        child: _buildControls(),
                        alignment: Alignment.bottomCenter,
                      )
                    : Container(),
              ],
            ),
            onTap: () {
              isTap = !isTap;
              setState(() {});
            },
          ),
        )),
        onWillPop: _backpress);
  }

  Future<Uint8List> loadLottieFromJsonString(String jsonString) async {
    print("loadLottieFromJsonString");
    final List<int> jsonMap = jsonString.codeUnits;
    final bytes = Uint8List.fromList(jsonMap); //utf8.encode(jsonString);
    return bytes;
    /*await LottieComposition.fromBytes(Uint8List.fromList(bytes))*/;
  }

  Future<bool> _backpress() async {
    Navigator.of(context).pop({"position": _position});
    return Future<bool>.value(true);
  }

  void showFeedbackDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      // Optional: background color with opacity
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return FeedBackWidget(
          contentObj: contentObj,
        ); // Your custom widget
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration:
          Duration(milliseconds: 300), // Optional: transition duration
    ).then((value) => {checkFeedback(value)});
  }

  checkFeedback(value) {
    print(value["isFeedback"]);
    print("checkFeedback");
    if (value != null && value["isFeedback"] == true) {
      Navigator.of(context).pop({"position": _position});
    } else if (value != null && value["skip"] == true) {
      Navigator.of(context).pop({"position": _position});
    }
  }

  Widget _buildControls() {
    double sliderWidth = MediaQuery.of(context).size.width;
    final thumbWidth = 20;
    double offsetValue = (sliderWidth - thumbWidth) *
        (_sliderValue / _duration!.inSeconds.toDouble());

    return Container(
      padding: EdgeInsets.only(top: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            child: Container(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Align(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        thumbShape: RoundSliderThumbShape(
                            enabledThumbRadius: !_isSliding ? 0 : 10),
                        overlayShape:
                            RoundSliderOverlayShape(overlayRadius: 20),
                        trackHeight: 2,
                        trackShape: CustomTrackShape(),
                        thumbColor: Colors.white,
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: Colors.white30,
                        overlayColor: Colors.white.withAlpha(32),
                      ),
                      child: Slider(
                        min: 0,
                        max: _duration!.inSeconds.toDouble(),
                        value: _sliderValue,
                        onChanged: (value) {
                          print("seekChanged");
                          print(value.toInt());
                          final position = Duration(seconds: value.toInt());
                          audioPlayerManager!.seek(position);
                          setState(() {
                            _sliderValue = value;
                            _positionText = _formatDuration(position);
                            _isSliding =
                                true; // Indicate that sliding has started.
                            print(_isSliding);
                          });
                        },
                        onChangeEnd: (value) {
                          print("onChangeEnd");
                          print(value.toInt());
                          // _controller!.seekTo(Duration(seconds:502));
                          //_controller!.play();
                          setState(() {
                            _isSliding =
                                false; // Indicate that sliding has ended.
                            print(_isSliding);
                          });
                          /* if (widget.onSeekRequested != null) {
                  widget.onSeekRequested(Duration(seconds: value.toInt()));
                }*/
                        },
                      ),
                    ),
                    alignment: Alignment.bottomCenter,
                  ),
                  if (_isSliding) // Show this only when the user is sliding the thumb.
                    Positioned(
                      left: offsetValue - 30,
                      bottom: 30,
                      // Adjust this value to position the bubble as needed.
                      child: Container(
                        padding: EdgeInsets.only(
                            left: 15, right: 15, top: 7, bottom: 7),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius:
                                BorderRadius.all(Radius.circular(30))),
                        child: Text(
                          _positionText,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: "Causten-Medium"),
                        ),
                      ),
                    ),
                ],
              ),
              margin: EdgeInsets.only(left: 10, right: 10),
              height: 70,
              alignment: Alignment.bottomCenter,
            ),
            alignment: Alignment.bottomCenter,
          ),
          Align(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                IconButton(
                  icon: InkWell(
                    child: SvgPicture.asset(
                      "assets/images/15_sec_back.svg",
                      semanticsLabel: 'Acme Logo',
                      width: 25,
                      height: 25,
                      fit: BoxFit.scaleDown,
                    ),
                    onTap: () {
                      _skipBackward();
                    },
                  ),
                  onPressed: () {
                    // Implement skipping back
                  },
                ),
                IconButton(
                  icon: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xF8F7F8).withOpacity(0.2),
                    ),
                    child: Icon(
                      isPlay ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    height: 60,
                    width: 60,
                  ),
                  onPressed: () {
                    setState(() {
                      if (isPlay) {
                        isPlay = false;
                        videoPlayerController?.pause();
                        audioPlayerManager!.pause();
                      } else {
                        isPlay = true;
                        videoPlayerController?.play();
                        audioPlayerManager!.resumeAudio();
                      }
                    });
                  },
                ),
                IconButton(
                  icon: InkWell(
                    child: SvgPicture.asset(
                      "assets/images/forward.svg",
                      semanticsLabel: 'Acme Logo',
                      width: 25,
                      height: 25,
                      fit: BoxFit.scaleDown,
                    ),
                    onTap: () {
                      _skipForward();
                    },
                  ),
                  onPressed: () {
                    // Implement skipping forward
                  },
                ),
              ],
            ),
            alignment: Alignment.bottomCenter,
          ),
        ],
      ),
    );
  }

  void _skipForward() {
    final currentPosition = _position ?? Duration.zero;
    final duration = _duration;
    if (duration! - currentPosition >= Duration(seconds: 15)) {
      print("object1234");
      audioPlayerManager!.seek(currentPosition + Duration(seconds: 15));
    } else {
      audioPlayerManager!.seek(duration);
    }
  }

  void _skipBackward() {
    final currentPosition = _position;
    if (currentPosition! >= Duration(seconds: 15)) {
      audioPlayerManager!.seek(currentPosition - Duration(seconds: 15));
    } else {
      audioPlayerManager!.seek(Duration.zero);
    }
  }

  String _formatDuration(Duration duration) {
    return DateFormat('mm:ss')
        .format(DateTime(0, 0, 0, 0, 0, duration.inSeconds));
  }

  /// A stream reporting the combined state of the current media item and its
  /// current position.
/*Stream<MediaState> get _mediaStateStream =>
      Rx.combineLatest2<MediaItem?, Duration, MediaState>(
          audioHandler!.mediaItem,
          AudioService.position,
              (mediaItem, position) => MediaState(mediaItem, position));

  IconButton _button(IconData iconData, VoidCallback onPressed) => IconButton(
    icon: Icon(iconData),
    iconSize: 64.0,
    onPressed: onPressed,
  );*/
}

/*

class MediaState {
  final MediaItem? mediaItem;
  final Duration position;

  MediaState(this.mediaItem, this.position);
}

class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  static final _item = MediaItem(
    id: 'https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3',
    album: "Science Friday",
    title: "A Salute To Head-Scratching Science",
    artist: "Science Friday and WNYC Studios",
    duration: const Duration(milliseconds: 5739820),
    artUri: Uri.parse(
        'https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg'),
  );

  final _player = AudioPlayer();

  /// Initialise our audio handler.
  AudioPlayerHandler() {
    // So that our clients (the Flutter UI and the system notification) know
    // what state to display, here we set up our audio handler to broadcast all
    // playback state changes as they happen via playbackState...
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
    // ... and also the current media item via mediaItem.
    mediaItem.add(_item);

    // Load the player.
    _player.setAudioSource(AudioSource.uri(Uri.parse(_item.id)));
  }
  void getAudioPosition(){

  }

  // In this simple example, we handle only 4 actions: play, pause, seek and
  // stop. Any button press from the Flutter UI, notification, lock screen or
  // headset will be routed through to these 4 methods so that you can handle
  // your audio playback logic in one place.
  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() => _player.stop();

  /// Transform a just_audio event into an audio_service state.
  ///
  /// This method is used from the constructor. Every event received from the
  /// just_audio player will be transformed into an audio_service state so that
  /// it can be broadcast to audio_service clients.
  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.rewind,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.fastForward,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }
}*/
