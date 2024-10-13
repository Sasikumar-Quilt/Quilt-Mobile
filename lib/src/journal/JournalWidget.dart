import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_state/phone_state.dart';
import 'package:quilt/src/Utility.dart';
import 'package:quilt/src/api/Objects.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../main.dart';
import '../video/AudioPlayerManager.dart';
import '../video/PreloadVideo.dart';
import 'JournalListWidget.dart';
bool isJournalMute=false;
class JournalWidget extends StatefulWidget {
  @override
  JournalWidgetState createState() => JournalWidgetState();
}

class JournalWidgetState extends State<JournalWidget>
    with WidgetsBindingObserver {
  DateTime? selectedDate;
  DateTime? currentWeekStart;
  ContentObj? contentObj;
  bool isArg = false;
  late VideoPlayerController? videoPlayerController;
 // final player = AudioPlayer();
  StreamSubscription<PhoneState>? _phoneStateSubscription;
  bool isResumed = true;
  bool isMute = false;
  late PreloadVideos preloadVideos;
  AudioPlayerManager audioPlayerManager = AudioPlayerManager();
  bool isDestroy=false;

  @override
  void initState() {
    super.initState();
    audioPlayerManager.setCurrentAction("Journal");
    preloadVideos= PreloadVideos(updateWidget);
    WidgetsBinding.instance.addObserver(this);
    requestPermission();
    selectedDate = DateTime.now();
    currentWeekStart = _startOfWeek(selectedDate!);
  }
  void updateWidget(){
    print("updateWidget");

   if(mounted){
     setState(() {

     });
   }
  }
  void playAudio() async {
    if (Utility.isEmpty(contentObj!.audioURL)) {
      return;
    }
   /* if (contentObj!.duration != null) {
      await player.play(UrlSource(contentObj!.audioURL),
          position: contentObj!.duration);
    } else {
      await player.play(UrlSource(contentObj!.audioURL));
    }*/

    await audioPlayerManager.playAudio(contentObj!.audioURL, contentObj!.duration, true);
   /* player.onPlayerStateChanged.listen((event) {
      print("onPlayerStateChanged");
      print(event);
    });*/
   // player.setReleaseMode(ReleaseMode.loop);
    audioPlayerManager.setVolume(isMute);
    audioPlayerManager.withUpdateCallback((duration) => {
      if(audioPlayerManager.getCurrentAction()=="Journal"){
        if (videoPlayerController != null &&
            videoPlayerController!.value.isInitialized) {
          if (videoPlayerController!.value.isPlaying) {
            // print("isPlaying");
          } else {
            // print("isPlayingNot");
            videoPlayerController?.play()
          }
        },

        if (duration.inMilliseconds != 0) {
          // print("audioUpdate");
          contentObj!.duration = duration
        }
      }
    });
/*    player.onPositionChanged.listen((event) {
      //  print(event);
      if (videoPlayerController != null &&
          videoPlayerController!.value.isInitialized) {
        if (videoPlayerController!.value.isPlaying) {
          // print("isPlaying");
        } else {
          // print("isPlayingNot");
          videoPlayerController?.play();
        }
      }

      if (event.inMilliseconds != 0) {
        // print("audioUpdate");
        contentObj!.duration = event;
      }
    });*/
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      isResumed = false;
      pauseAudio();
      videoPlayerController?.pause();
    } else if (state == AppLifecycleState.resumed) {
      isResumed = true;
      if (!Utility.isEmpty(contentObj!.audioURL)) {
        audioPlayerManager.resumeAudio();
      }
      videoPlayerController?.play();
    }
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

  void setStream() {
    _phoneStateSubscription = PhoneState.stream.listen((status) {
      setState(() {
        if (status.status == PhoneStateStatus.CALL_INCOMING ||
            status.status == PhoneStateStatus.CALL_STARTED) {
          pauseAudio();
          videoPlayerController?.pause();
        } else {
          if (isResumed) {
            if (!Utility.isEmpty(contentObj!.audioURL)) {
              audioPlayerManager.resumeAudio();
            }
            videoPlayerController?.play();
          }
        }
      });
    });
  }

  void pauseAudio() {
    if (Utility.isEmpty(contentObj!.audioURL)) {
      return;
    }
    audioPlayerManager.pause();
  }

  DateTime _startOfWeek(DateTime date) {
    int daysFromMonday = (date.weekday - DateTime.monday) % 7;
    return date.subtract(Duration(days: daysFromMonday));
  }

  getArgs() {
    if (!isArg) {
      isArg = true;
      final args = ModalRoute.of(context)?.settings.arguments as Map;
      contentObj = args["url"];
      isMute = args["isMute"]??false;
      isJournalMute =isMute;
      if(args["index"]!=null){
        int index = args["index"];
        preloadVideos.playControllerAtIndex(index);
        videoPlayerController = preloadVideos.controllers[index] ?? null;
        if (videoPlayerController != null) {
          videoPlayerController?.play();
        } else {
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

      Future.delayed(Duration(milliseconds: 200),(){
        playAudio();
      });
      videoPlayerController?.setLooping(true);
    }
  }

  replayVideo(value) {
    if (value != null && value["isReplay"]!=null&& value["isReplay"]) {
      Navigator.of(context).pop();
    } else {
      videoPlayerController?.play();
      //playAudio();
    }
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
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    if(isDestroy){
      videoPlayerController?.dispose();
      audioPlayerManager.pause();
    }else{
      videoPlayerController?.pause();
    }
    videoPlayerController = null;
    _phoneStateSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    getArgs();
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        child: Stack(
          children: [
            /* Container( width: double.infinity,
        height: double.infinity,child:CachedNetworkImage( fit: BoxFit.cover,
      imageUrl: contentObj!.animations!,imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                  colorFilter:
                  ColorFilter.mode(
                      Colors.black.withOpacity(0.85),
                      BlendMode.darken
                  )),
            ),
          ),
      errorWidget: (context, url, error) => Icon(Icons.error),
    ),),*/
            videoPlayerController != null
                ? Stack(
                    children: [
                      SizedBox.expand(
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
                                //pauseAudio();
                              } else {
                                videoPlayerController?.play();
                                // playAudio();
                              }
                            },
                            child: VideoPlayer(videoPlayerController!),
                          ),
                        ),
                      )),
                      Container(
                        padding: EdgeInsets.all(10),
                        color: Colors.black.withOpacity(0.8),
                        height: double.infinity,
                        width: double.infinity,
                      )
                    ],
                  )
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
            Container(
              margin: EdgeInsets.only(top: 20, left: 15),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Align(
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      child: Text(
                        Utility.getDate("EEE, dd MMM"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color(0xffCFC9CE),
                            fontSize: 12,
                            fontFamily: "Causten-Regular"),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 15),
                      child: Text(
                        contentObj!.contentName!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontFamily: "Causten-Medium"),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 15),
                      height: contentObj!.contentUrl!.length > 200 ? 150 : null,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Container(
                          child: Text(
                            contentObj!.contentUrl!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: "Causten-Regular"),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(top: 15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white.withOpacity(0.2)),
                            child: Row(
                              children: [
                                Container(
                                  child:
                                      SvgPicture.asset("assets/images/pen.svg"),
                                  margin: EdgeInsets.only(left: 5),
                                ),
                                Container(
                                  child: Text(
                                    "JOURNAL",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontFamily: "Causten-Regular"),
                                  ),
                                  margin: EdgeInsets.only(left: 5, right: 5),
                                )
                              ],
                            ),
                          ),
                          Container(
                            child: Text(
                              contentObj!.contentDuration! + " min",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontFamily: "Causten-Regular"),
                            ),
                            margin: EdgeInsets.only(left: 5, right: 5),
                          )
                        ],
                      ),
                    )
                  ],
                )),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      child: ElevatedButton(
                        onPressed: () {
                          //pauseAudio();
                          videoPlayerController?.pause();
                          Navigator.pushNamed(
                                  context, HomeWidgetRoutes.JournalEditorWidget,
                                  arguments: {"url": contentObj,"isMute":isMute})
                              .then((value) => {replayVideo(value)});
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add,
                              color: Colors.black,
                            ),
                            Container(
                              child: Text(
                                'Add Entry',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: "Causten-Bold",
                                    fontSize: 16),
                              ),
                              margin: EdgeInsets.only(left: 10),
                            )
                          ],
                        ),
                      ),
                      margin: EdgeInsets.only(top: 0, bottom: 20),
                      width: double.infinity,
                      height: 50,
                    ),
                    InkWell(
                      child: Container(
                        margin: EdgeInsets.only(top: 10, bottom: 30),
                        child: Text(
                          "See Previous Entries",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: "Causten-Bold"),
                        ),
                      ),
                      onTap: () {
                        showJournalModel(context);
                      },
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    ));
  }

  void showJournalModel(BuildContext context) {
    //pauseAudio();
    videoPlayerController?.pause();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.95,

        child: JournalListWidget(
          contentObj: contentObj
        ),
      ),
    ).then((value) => {
          //playAudio(),
          videoPlayerController?.play()
        });
  }
}
