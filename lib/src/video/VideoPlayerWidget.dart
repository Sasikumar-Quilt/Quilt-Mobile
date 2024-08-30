import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_state/phone_state.dart';
import 'package:quilt/main.dart';
import 'package:quilt/src/base/BaseState.dart';
import 'package:quilt/src/feed/HomeWidgetRoute.dart';
import 'package:quilt/src/feedback/FeedbackWidget.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../api/ApiHelper.dart';
import '../api/Objects.dart';
import 'PreloadVideo.dart';

class VideoplayerWidget extends BasePage {
  @override
  VideoplayerWidgetState createState() => VideoplayerWidgetState();
}

class VideoplayerWidgetState extends BasePageState<VideoplayerWidget> {
  bool isEnable = false;
  String username = "";
  var identifier = "";
  int selectedItem = 0;
  TextEditingController mobileNumberCntrl = new TextEditingController();
  ApiHelper apiHelper = ApiHelper();
  String userName = "";
  String age = "";
  bool isArg = false;
  VideoPlayerController? _controller;
  String _positionText = '00:00';
  String _durationText = '00:00';
  double _sliderValue = 0;
  bool _isSliding = false;
  ContentObj? contentObj;
  bool isTap = true;
  bool isCompleted = false;
  bool isReplay = false;
  bool isMute=false;
  bool isPlay=false;
  bool isbPlay=false;
  StreamSubscription<PhoneState>? _phoneStateSubscription;
  late PreloadVideos preloadVideos;

  @override
  void initState() {
    super.initState();
    preloadVideos= PreloadVideos(updateWidget);

    requestPermission();
    WakelockPlus.enable();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.black, // Background color of status bar
      statusBarIconBrightness: Brightness.light, // Icon brightness for Android
      statusBarBrightness: Brightness.dark, // Icon brightness for iOS
    ));
  }
  void updateWidget(){
    print("updateWidget");

    setState(() {

    });
  }
  String _formatDuration(Duration duration) {
    return DateFormat('mm:ss')
        .format(DateTime(0, 0, 0, 0, 0, duration.inSeconds));
  }
  void requestPermission() async {
    if(Platform.isAndroid){
      var status = await Permission.phone.isGranted;
      if(status){
        setStream();
      }/*else{
        var status = await Permission.phone.request();
        if(status==PermissionStatus.granted){
          setStream();
        }
      }*/
    }else{
      setStream();
    }

  }
  void setStream() {
    _phoneStateSubscription=PhoneState.stream.listen((status) {
      setState(() {
        if(_controller!=null){
          if(status.status==PhoneStateStatus.CALL_INCOMING||status.status==PhoneStateStatus.CALL_STARTED){
            _controller!.pause();
            isbPlay=isPlay;
            isPlay=false;
          }else{
            if(isbPlay){
              _controller!.play();
              isPlay=true;
            }
          }
        }

      });
    });
  }
  getArgs() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!isArg) {
        isArg = true;
        final args = ModalRoute.of(context)?.settings.arguments as Map;
        contentObj = args["url"];
        int index=args["index"];
        preloadVideos.playControllerAtIndex(index);
        _controller = preloadVideos.controllers[index] ?? null;
        if(_controller==null){
          _controller = VideoPlayerController.networkUrl(
              Uri.parse(contentObj!.videoURL!),
              videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true,allowBackgroundPlayback: true))
            ..initialize().then((_) {
              if (contentObj!.duration != null) {
                _controller!.seekTo(contentObj!.duration!);
              }
              _controller?.play();
              print("totalSeconds");
              print(_controller!.value.duration.inSeconds.toDouble());
              setState(() {});
            });
        }else{
          if (contentObj!.duration != null) {
            _controller!.seekTo(contentObj!.duration!);
          }
          _controller?.play();
          print("isPlayingVideo");
          print(_controller!.value.duration.inSeconds.toDouble());
          setState(() {});
        }
        isPlay=true;
        _controller!.addListener(() {
          if(!mounted||_controller==null||currentRouteName!=HomeWidgetRoutes.VideoCompletedWidget){
            return;
          }
          final Duration position = _controller!.value.position;
          final Duration duration = _controller!.value.duration;
          if (isReplay &&
              _controller!.value.position.inSeconds.toInt() < 15) {
            isCompleted = false;
            isReplay = false;
          }
          _positionText = _formatDuration(position);
          _sliderValue = position.inSeconds.toDouble();
          _durationText = _formatDuration(duration);
          setState(() {
          });
          if ((_controller!.value.position == _controller!.value.duration) &&
              (_controller!.value.isCompleted) &&
              !isCompleted) {
            isCompleted = true;
            _controller?.pause();
            Navigator.pushNamed(context, HomeWidgetRoutes.VideoCompletedWidget,arguments: {"object":contentObj})
                .then((value) => {replayVideo(value)});
          }
        });
        _controller?.setLooping(false);
      }
    });

  }

  void replayVideo(value) {
    if (value != null && value["isReplay"]) {
      _controller?.play();
      isReplay = true;
    } else {
      Navigator.of(context).pop({"position":_controller!.value.position.inSeconds.toInt()});
    }
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _phoneStateSubscription?.cancel();
    _controller?.pause();
    _controller?.removeListener(() { });
    _controller=null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    getArgs();
    return WillPopScope(child: SafeArea(
        child: Scaffold(
          appBar: null,
          backgroundColor: Colors.black,
          body:_controller!=null&& _controller!.value.isInitialized
              ? GestureDetector(
            child: Stack(
              children: [

                SizedBox.expand(
                    child: FittedBox(
                      fit: checkVideoRatio(_controller!.value.size.width ?? 0,
                          _controller!.value.size.height ?? 0),
                      child: SizedBox(
                        width: _controller!.value.size.width ?? 0,
                        height: _controller!.value.size.height ?? 0,
                        child: /*VisibilityDetector(
                          key: Key(contentObj!.contentUrl!),
                          onVisibilityChanged: (VisibilityInfo info) {
                            var visiblePercentage = info.visibleFraction * 100;
                            print(visiblePercentage);
                            if (visiblePercentage < 20) {
                              _controller!.pause(); //pausing  functionality
                            } else {
                              _controller!.play();
                            }
                          },
                          child: VideoPlayer(_controller!),
                        )*/VideoPlayer(_controller!),
                      ),
                    )),
                /*  VideoProgressIndicator(
                    _controller!,
                    allowScrubbing: true,
                    padding: EdgeInsets.all(3),
                    colors: VideoProgressColors(
                        playedColor: Theme.of(context).primaryColor),
                  ),*/
                isTap
                    ?Align(child: Container(margin: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      InkWell(
                        child: Container(child: SvgPicture.asset(
                          "assets/images/close.svg",
                          semanticsLabel: 'Acme Logo',
                          width: 25,
                          height: 25,
                          fit: BoxFit.scaleDown,
                        ),margin: EdgeInsets.only(left: 5),),
                        onTap: () {
                          showFeedbackDialog();
                          //Navigator.pushNamed(context, HomeWidgetRoutes.VideoCompletedWidget,arguments: {"object":contentObj}) .then((value) => {replayVideo(value)});
                          //Navigator.of(context).pop({"position":_controller!.value.position.inSeconds.toInt()});
                        },
                      ),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.center,mainAxisSize: MainAxisSize.min,children: [
                        Container(
                          child: Text(
                            contentObj!.contentName!,textAlign: TextAlign.center,
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
                                color: Color(0xFFF8F7F8).withOpacity(0.8),
                                fontSize: 14,
                                fontFamily: "Causten-Regular"),
                          ),
                          margin: EdgeInsets.only(top: 2),
                        ),
                      ],)),
                      InkWell(child: Container(
                        child: SvgPicture.asset(isMute?"assets/images/muted.svg":"assets/images/mute.svg",
                            semanticsLabel: 'Acme Logo'),
                        margin: EdgeInsets.only(left: 0, bottom: 0, right: 5),
                      ),onTap: (){
                        isMute=!isMute;
                        if(isMute){
                          _controller!.setVolume(0.0);
                        }else{
                          _controller!.setVolume(1.0);
                        }
                        setState(() {

                        });
                      },),
                    ],
                  ),
                ),alignment: Alignment.topCenter):Container(),
                isTap
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
          )
              : Center(child: Lottie.asset("assets/images/feed_preloader.json")),
        )),onWillPop:()=> _backpress(),);
  }
Future<bool>_backpress() async{
  Navigator.of(context).pop({"position":_controller!.value.position.inSeconds.toInt()});
  return Future<bool>.value(true);

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

  Widget _buildControls() {
    double sliderWidth = MediaQuery.of(context).size.width;
    final thumbWidth = 20;
    double offsetValue = (sliderWidth - thumbWidth) *
        (_sliderValue / _controller!.value.duration.inSeconds.toDouble());

    return Container(
      padding: EdgeInsets.only(top: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /*Container(
            child: Row(
              children: <Widget>[
                Expanded(
                    child: Slider(
                  value: _controller!.value.position.inSeconds.toDouble(),
                  min: 0.0,
                  max: _controller!.value.duration.inSeconds.toDouble(),
                  onChanged: (double value) {
                    final position = Duration(seconds: value.toInt());
                    _controller!.seekTo(position);
                  },
                )),
              ],
            ),
            margin: EdgeInsets.only(left: 5, right: 5, bottom: 10),
          ),*/

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
                        max: _controller!.value.duration.inSeconds.toDouble(),
                        value: _sliderValue,
                        onChanged: (value) {
                          print("seekChanged");
                          print(value.toInt());
                          final position = Duration(seconds: value.toInt());
                          _controller!.seekTo(position);
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
                      _controller!.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    height: 60,
                    width: 60,
                  ),
                  onPressed: () {
                    setState(() {
                      _controller!.value.isPlaying
                          ? _controller!.pause()
                          : _controller!.play();
                      isPlay=_controller!.value.isPlaying;
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
    if (_controller == null) return;
    final currentPosition = _controller!.value.position;
    final duration = _controller!.value.duration;
    if (duration - currentPosition >= Duration(seconds: 15)) {
      _controller!.seekTo(currentPosition + Duration(seconds: 15));
    } else {
      _controller!.seekTo(duration);
    }
  }

  void _skipBackward() {
    if (_controller == null) return;
    final currentPosition = _controller!.value.position;
    if (currentPosition >= Duration(seconds: 15)) {
      _controller!.seekTo(currentPosition - Duration(seconds: 15));
    } else {
      _controller!.seekTo(Duration.zero);
    }
  }
  void showFeedbackDialog(){
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5), // Optional: background color with opacity
      pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
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
      transitionDuration: Duration(milliseconds: 300), // Optional: transition duration
    ).then((value) => {
      checkFeedback(value)
    });
    /*showDialog(
      context: context,barrierDismissible: false,
      builder: (BuildContext context) {
        return FeedBackWidget(contentObj: contentObj,); // Custom dialog widget
      },
    ).then((value) => {
      checkFeedback(value)
    });*/
  }
  checkFeedback(value) {
    print(value["isFeedback"]);
    print("checkFeedback");
    if(value!=null&&value["isFeedback"]==true){
      Navigator.of(context).pop({"position":_controller!.value.position.inSeconds.toInt()});
    }else if(value!=null&&value["skip"]==true){
      Navigator.of(context).pop({"position":_controller!.value.position.inSeconds.toInt()});
    }
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight;
    final trackLeft = offset.dx;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight!) / 1.2;
    final trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

}

