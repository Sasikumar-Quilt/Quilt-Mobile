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
import 'package:quilt/src/feedback/FeedbackWidget.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../main.dart';
import '../api/ApiHelper.dart';
import '../api/BaseApiService.dart';
import '../api/NetworkApiService.dart';
import '../video/AudioPlayerManager.dart';
import '../video/PreloadVideo.dart';

class EMIWidget extends StatefulWidget {
  @override
  EMIWidgetState createState() => EMIWidgetState();
}

class EMIWidgetState extends State<EMIWidget> with WidgetsBindingObserver {
  DateTime? selectedDate;
  DateTime? currentWeekStart;
  ContentObj? contentObj;
  bool isArg = false;
  bool isCompleted = false;
  int selectedindex = 0;
  List<EmiObject> emiList = [];
  List<EmiObject> emiDuplicateList = [];
  int currentPos = 0;
  bool isTapped = false;
  bool isApiCompleted = false;
  ApiHelper apiHelper = ApiHelper();
  bool _isPressed = false;
  double _fillAmount = 0.0;
  PageController pageController = new PageController();

  late VideoPlayerController? videoPlayerController;
  //final player = AudioPlayer();
  StreamSubscription<PhoneState>? _phoneStateSubscription;
  bool isResumed = true;
  late PreloadVideos preloadVideos;
  AudioPlayerManager audioPlayerManager = AudioPlayerManager();
  bool isDestroy=false;
  bool isMute=false;

  @override
  void initState() {
    super.initState();
    audioPlayerManager.setCurrentAction("EMI");
    preloadVideos= PreloadVideos(updateWidget);
    WidgetsBinding.instance.addObserver(this);
    requestPermission();
  }
  void updateWidget(){
    print("updateWidget");

   if(mounted){
     setState(() {

     });
   }
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      isResumed = false;
      print("fromEmiWidget");
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

  void playAudio() async {
    print("audioUrl");
    print(contentObj!.audioURL);
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
    //player.setReleaseMode(ReleaseMode.loop);
    audioPlayerManager.setVolume(isMute);
    /*player.onPositionChanged.listen((event) {
      //print(event);
      if (videoPlayerController != null &&
          videoPlayerController!.value.isInitialized) {
        if (videoPlayerController!.value.isPlaying) {
          // print("isPlaying");
        } else {
          //  print("isPlayingNot");
          videoPlayerController?.play();
        }
      }

      if (event.inMilliseconds != 0) {
        // print("audioUpdate");
        contentObj!.duration = event;
      }
    });*/
    audioPlayerManager.withUpdateCallback((duration) => {
      if(audioPlayerManager.getCurrentAction()=="EMI"){
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
  }

  void pauseAudio() {
    if (Utility.isEmpty(contentObj!.audioURL)) {
      return;
    }
    audioPlayerManager.pause();
  }

  getArgs() {
    if (!isArg) {
      isArg = true;
      final args = ModalRoute.of(context)?.settings.arguments as Map;
      contentObj = args["url"];
      isMute = args["isMute"];
      print("EmiWidget");
      print(contentObj!.contentUrl!);
      print(contentObj!.videoURL);
      mapData();
      if(args["index"]!=null){
        int index = args["index"];
        preloadVideos.playControllerAtIndex(index);
        videoPlayerController=preloadVideos.controllers[index]??null;
        if(videoPlayerController!=null){
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
        videoPlayerController = new VideoPlayerController.networkUrl(
            Uri.parse(contentObj!.videoURL),
            videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));
        videoPlayerController!.initialize().then((_) {
          videoPlayerController?.play();

          //       Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.

          setState(() {});
        });
        isDestroy=true;
      }

      Future.delayed(Duration(milliseconds: 200),(){
        playAudio();
      });
      videoPlayerController?.setLooping(true);
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

  void mapData() {
    emiList = [];
    emiDuplicateList = [];
    List<String> emis = contentObj!.contentUrl!
        .replaceAll("•", "")
        .replaceAll("•", "")
        .replaceAll("\\", "")
        .split(".");
    for (int i = 0; i < emis.length; i++) {
      EmiObject emiObject = new EmiObject();
      emiObject.emi = emis[i];
      if (!Utility.isEmpty(emis[i].trim())) {
        List<String> splitEmi = emis[i].trim().split(",");
        if (splitEmi.isNotEmpty) {
          for (int j = 0; j < splitEmi.length; j++) {
            EmiObject emiObj = new EmiObject();
            emiObj.emi = splitEmi[j];
            emiObj.isSeen = j == 0 ? true : false;
            emiObject.subList.add(emiObj);
          }
          emiObject.dupSubList.add(emiObject.subList[0]);
        } else {
          EmiObject emiObj = new EmiObject();
          emiObj.emi = emis[i].trim();
          emiObj.isSeen = true;
          emiObject.subList.add(emiObj);
          emiObject.dupSubList.add(emiObject.subList[0]);
        }
        if (emiObject.subList.length == 1) {
          emiObject.isSeen = true;
        }
        emiList.add(emiObject);
        emiDuplicateList.add(emiObject);
      }
    }
    if ((emiList.length == 1) && emiList[0].subList.length == 1) {
      isCompleted = true;
    }
    print("emiList");
    print(emiList.length);
  }

  Future<void> updateEmi() async {
    //ApiResponse? apiRespons;
    //pauseAudio();
    videoPlayerController?.pause();
    isApiCompleted = true;
    apiHelper.logEmi(contentObj!.contentId!);
    int from = 2;
    if (contentObj!.contentType == "INFO_TIDBITS" ||
        contentObj!.contentType == "INFO_TIDBITS_OCD"||contentObj!.contentType == "INFO_TIDBITS_GENERAL") {
      from = 4;
    }
    Navigator.pushNamed(context, HomeWidgetRoutes.VideoCompletedWidget,
            arguments: {"object": contentObj, "fromJournal": from})
        .then((value) => {replayVideo(value)});

    /*if (apiRespons!.status == Status.COMPLETED) {
      LoginResponse loginResponse = LoginResponse.fromJson(apiRespons.data);
      isApiCompleted=true;
      if(loginResponse.status==200){
        Navigator.pushNamed(context, HomeWidgetRoutes.VideoCompletedWidget,arguments: {"object":contentObj,"fromJournal":2}) .then((value) => {replayVideo(value)});

       // showFeedbackDialog();
      }
    }*/
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
                                //playAudio();
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
              child: _buildIndicator(),
              alignment: Alignment.topCenter,
              margin: EdgeInsets.only(top: 20),
            ),
            Container(
              child: PageView.builder(
                controller: pageController,
                onPageChanged: (index) {
                  currentPos = index;
                  if ((currentPos == emiList.length - 1) &&
                      emiList[currentPos].subList.length == 1) {
                    isCompleted = true;
                  }
                  setState(() {});
                },
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    excludeFromSemantics: true,
                    canRequestFocus: false,
                    enableFeedback: false,
                    splashFactory: NoSplash.splashFactory,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                    child: Container(
                      child: Stack(
                        children: [
                          Align(
                              alignment: Alignment.center,
                              child: Container(
                                child: ListView(
                                  shrinkWrap: true,
                                  children: getEmiList(),
                                ),
                                margin: EdgeInsets.only(top: 40, bottom: 120),
                                alignment: Alignment.center,
                              )),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  (currentPos != emiList.length - 1) &&
                                          (emiList[currentPos].isSeen)
                                      ? GestureDetector(
                                          excludeFromSemantics: true,
                                          child: Container(
                                            child: SvgPicture.asset(
                                                "assets/images/icon_next.svg"),
                                            margin: EdgeInsets.only(
                                                top: 20, bottom: 70),
                                            width: double.infinity,
                                            height: 50,
                                          ),
                                          onTap: () {
                                            pageController.animateToPage(
                                                currentPos + 1,
                                                curve: Curves.ease,
                                                duration: Duration(
                                                    milliseconds: 200));
                                          },
                                        )
                                      : Container(),
                                  !emiList[currentPos].isSeen
                                      ? Container(
                                          margin: EdgeInsets.only(
                                              top: 20, bottom: 70),
                                          child: Text(
                                            "Tap anywhere on the screen",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.7),
                                                fontSize: 14,
                                                fontFamily: "Causten-Medium"),
                                          ),
                                        )
                                      : Container(),
                                  (isCompleted &&
                                          currentPos == emiList.length - 1)
                                      ? Container(
                                          margin: EdgeInsets.only(
                                              top: 20, bottom: 20),
                                          child: Text(
                                            "Tap and hold to commit",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontFamily: "Causten-Medium"),
                                          ),
                                        )
                                      : Container(),
                                  (isCompleted &&
                                          currentPos == emiList.length - 1)
                                      ? GestureDetector(
                                          onPanDown: (details) {
                                            setState(() {
                                              _isPressed = true;
                                              _fillAmount = 0.0;
                                            });
                                            _startFillAnimation();
                                          },
                                          onTap: () {
                                            if (isApiCompleted) {
                                              int from = 2;
                                              if (contentObj!.contentType ==
                                                      "INFO_TIDBITS" ||
                                                  contentObj!.contentType ==
                                                      "INFO_TIDBITS_OCD"|| contentObj!.contentType ==
                                                  "INFO_TIDBITS_GENERAL") {
                                                from = 4;
                                              }
                                              Navigator.pushNamed(
                                                  context,
                                                  HomeWidgetRoutes
                                                      .VideoCompletedWidget,
                                                  arguments: {
                                                    "object": contentObj,
                                                    "fromJournal": from
                                                  }).then((value) =>
                                                  {replayVideo(value)});
                                            }
                                          },
                                          onTapUp: (_) {
                                            setState(() {
                                              //_isPressed = false;
                                            });
                                          },
                                          onTapCancel: () {
                                            setState(() {
                                              //_isPressed = false;
                                            });
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            height: 55,
                                            margin: EdgeInsets.only(
                                                left: 15,
                                                right: 15,
                                                bottom: 30),
                                            child: Stack(
                                              children: [
                                                // Background container
                                                Container(
                                                  width: double.infinity,
                                                  height: 55,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25),
                                                      border: Border.all(
                                                          color: Colors.white)),
                                                ),
                                                // Fill container
                                                Align(
                                                  alignment: Alignment.center,
                                                  child: AnimatedContainer(
                                                    duration: Duration(
                                                        milliseconds: 50),
                                                    width: _fillAmount *
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    height: 55,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25),
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                Center(
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                        child: Icon(
                                                          Icons.done_outlined,
                                                          color: _isPressed
                                                              ? Colors.black
                                                              : Colors.white,
                                                        ),
                                                        margin: EdgeInsets.only(
                                                            right: 10),
                                                      ),
                                                      Text(
                                                        "I can do it",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: _isPressed
                                                                ? Colors.black
                                                                : Colors.white,
                                                            fontSize: 16,
                                                            fontFamily:
                                                                "Causten-Bold"),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    onTap: () {
                      print(emiList[currentPos].subList.length);
                      print("length");
                      if (!emiList[currentPos].isSeen &&
                          (emiList[currentPos].subList.length >
                              emiList[currentPos].dupSubList.length)) {
                        int pos = emiList[currentPos].dupSubList.length;
                        emiList[currentPos]
                            .dupSubList
                            .add(emiList[currentPos].subList[pos]);
                        emiList[currentPos]
                            .dupSubList
                            .map((e) => e.isSeen = false)
                            .toList();
                        emiList[currentPos].dupSubList[pos].isSeen = true;
                        /* print(currentPos);
            emiDuplicateList[currentPos].isSeen=true;
            if(!isTapped){
              isTapped=true;
            }*/
                        if (emiList[currentPos].dupSubList.length ==
                            emiList[currentPos].subList.length) {
                          emiList[currentPos].isSeen = true;
                          if (currentPos == emiList.length - 1) {
                            isCompleted = true;
                          }
                        }
                      } else {
                        if (currentPos != emiList.length - 1) {
                          pageController.animateToPage(currentPos + 1,
                              curve: Curves.ease,
                              duration: Duration(milliseconds: 200));
                        }
                      }
                      setState(() {});
                    },
                  );
                },
                itemCount: emiList.length,
              ),
              margin: EdgeInsets.only(top: 40),
            ),
            Container(
              margin: EdgeInsets.only(top: 0, left: 15),
              child: IconButton(
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            GestureDetector(

              child: Container(alignment: Alignment.topRight,
                child: SvgPicture.asset(
                    isMute
                        ? "assets/images/muted.svg"
                        : "assets/images/mute.svg",
                    semanticsLabel: 'Acme Logo'),
                margin: EdgeInsets.only(top: isMute?15:13, right: 15),
              ),
              onTap: () {
                isMute = !isMute!;
                audioPlayerManager.setVolume(isMute);
                setState(() {});
              },
            )
          ],
        ),
      ),
    ));
  }

  Widget _buildIndicator() {
    List<Widget> indicators = [];
    for (int i = 0; i < emiList.length; i++) {
      indicators.add(
        InkWell(
          excludeFromSemantics: true,
          canRequestFocus: false,
          enableFeedback: false,
          splashFactory: NoSplash.splashFactory,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          overlayColor: MaterialStateProperty.all(Colors.transparent),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: i == currentPos ? 30 : 10,
            height: 10,
            margin: EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: i == currentPos ? Colors.white : Colors.grey,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          onTap: () {
            print("object");
            pageController.animateToPage(i,
                curve: Curves.ease, duration: Duration(milliseconds: 200));

            /* currentPos=i;
         isTapped=true;
         updateViews();
         if(currentPos==emiDuplicateList.length-1){
           isCompleted=true;
         }
         setState(() {

         });*/
          },
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: indicators,
    );
  }

  void _startFillAnimation() {
    Future.delayed(Duration(milliseconds: 50), () {
      if (_isPressed && _fillAmount < 1.0) {
        setState(() {
          _fillAmount += 0.1;
        });
        _startFillAnimation();
        _checkAnimationEnd();
      }
    });
  }

  void _checkAnimationEnd() {
    print(_fillAmount);
    if (_fillAmount >= 1.0 && !isApiCompleted) {
      print('Animation Completed');
      // Navigate to the next screen
      updateEmi();
    }
  }

  void updateViews() {
    for (int i = 0; i < emiDuplicateList.length; i++) {
      if (i <= currentPos) {
        emiDuplicateList[i].isSeen = true;
      }
    }
  }

  /*List<Widget>getEmiList(){
    List<Widget> emiListWidget=[];
    for(int i=0;i<emiDuplicateList.length;i++){
      if(emiDuplicateList[i].isSeen){
        emiListWidget.add(InkWell(child: Container(margin: EdgeInsets.only(top: 0),child: Text(emiDuplicateList[i].emi,textAlign: TextAlign.center,
          style: TextStyle(
              color: i!=currentPos?Color(0xffCFC9CE).withOpacity(0.3):Colors.white,fontSize: i!=currentPos?18:28,fontFamily: "Causten-Medium"
          ),
        ),),onTap: (){
          currentPos=i;
          isTapped=true;
          if(currentPos==emiDuplicateList.length-1){
            isCompleted=true;
          }
          setState(() {

          });
        },));
      }
    }
    return emiListWidget;
  }*/
  List<Widget> getEmiList() {
    List<Widget> emiListWidget = [];
    for (int i = 0; i < emiList[currentPos].dupSubList.length; i++) {
      emiListWidget.add(InkWell(
        excludeFromSemantics: true,
        canRequestFocus: false,
        enableFeedback: false,
        splashFactory: NoSplash.splashFactory,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        onTap: () {
          setState(() {
            emiList[currentPos].dupSubList.forEach((e) => e.isSeen = false);
            emiList[currentPos].dupSubList[i].isSeen = true;
          });
        },
        child: AnimatedOpacity(
          opacity: emiList[currentPos].dupSubList[i].isSeen ? 1.0 : 0.4,
          duration: Duration(milliseconds: 1000),
          child: AnimatedContainer(
            duration: Duration(microseconds: 1000),
            padding: EdgeInsets.all(0.0),
            margin: EdgeInsets.only(left: 15, right: 15),
            curve: Curves.easeInOut,
            child: Text(
              emiList[currentPos].dupSubList[i].isSeen
                  ? emiList[currentPos].dupSubList[i].emi.trim()
                  : emiList[currentPos].dupSubList[i].emi.trim() + ",",
              textAlign: TextAlign.start,
              style: TextStyle(
                color: Colors.white,
                fontSize: emiList[currentPos].dupSubList[i].isSeen ? 30 : 27,
                fontFamily: "Causten-Medium",
              ),
            ),
          ),
        ),
      ));
    }
    return emiListWidget;
  }

  replayVideo(value) {
    if (value != null && value["isReplay"]) {
      //playAudio();
      videoPlayerController?.play();
      _fillAmount = 0.0;
      isCompleted = false;
      isTapped = false;
      _isPressed = false;
      isApiCompleted = false;
      currentPos = 0;
      pageController.jumpToPage(0);
      mapData();
      setState(() {});
    } else {
      Navigator.of(context).pop();
    }
  }


  checkFeedback(value) {
    print(value["isFeedback"]);
    print("checkFeedback");
    if (value != null && value["isFeedback"] == true) {
      Navigator.of(context).pop();
    }
  }
}

class EmiObject {
  bool isSeen = false;
  String emi = "";
  List<EmiObject> subList = [];
  List<EmiObject> dupSubList = [];
}
