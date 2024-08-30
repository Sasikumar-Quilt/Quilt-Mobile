import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quilt/src/PrefUtils.dart';
import 'package:quilt/src/Utility.dart';
import 'package:quilt/src/api/ApiHelper.dart';
import 'package:quilt/src/api/BaseApiService.dart';
import 'package:quilt/src/api/NetworkApiService.dart';
import 'package:quilt/src/api/Objects.dart';
import 'package:quilt/src/auth/MobileNumberWidget.dart';
import 'package:quilt/src/base/BaseState.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'main.dart';

const List<String> scopes = <String>[];

class SplashWidget1 extends StatefulWidget {
  @override
  _AnimatedBackgroundScreenState createState() =>
      _AnimatedBackgroundScreenState();
}

class _AnimatedBackgroundScreenState extends State<SplashWidget1>
    with TickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;
  double _opacity = 0.0; // Initial opacity for the text
  bool _playLottie = false; // Flag to start playing Lottie animation
  bool _playLottie2 = false; // Flag to start playing Lottie animation
  AnimationController? _lottie1AnimCtrl;
  AnimationController? _lottie2AnimCtrl;
  int anim1D = 0;
  int anim2D = 0;
  double _lottieOpacity = 1.0; // Fully visible initially for Lottie
  late double _initialTextTop = 0; // Start at the vertical center
  late double _finalTextTop = -1; // End at the top
  bool showImagesScreen = false;
  late double instructionTextBottom = 0; // Start at the vertical center
  late double instructionTextBottomImage = 0; // Start at the vertical center
  late double swipeUpBootom = 0; // Start at the vertical center
  double instructionTextOpacity = 0.0; // Initial opacity for the text
  double instructionImageOpacity = 0.0; // Initial opacity for the text
  double swipeUpTextOpacity = 0.0; // Initial opacity for the text
  double swipeUpTextOpacity1 = 0.0; // Initial opacity for the text
  bool isSwipeUp = false;
  bool isFinishedInitialSetup = false;
  bool isLoginOptions = false;
  bool isApiCalling = false;
  int swipeCount = 0;
  String imagePath = "assets/images/onboarding1.png";
  String instructionText =
      "When you feel stressed,\n anxious, restless, or down...";
  DragStartDetails? startVerticalDragDetails;
  DragUpdateDetails? updateVerticalDragDetails;

  final List<String> images = [
    'assets/images/video_onboarding1.mp4', // Replace with your asset images
    'assets/images/video_onboarding2.mp4',
    'assets/images/video_onboarding3.mp4', // Assuming you have a third image
  ];
  final List<String> audios = [
    'images/audio_onboarding1.mp3', // Replace with your asset images
    'images/audio_onboarding2.mp3',
    'images/audio_onboarding3.mp3', // Assuming you have a third image
  ];
  final List<String> texts = [
    "When you feel stressed,\n anxious, restless, or down...",
    // Replace with your asset images
    "Quilt crafts personalized\n experiences just for you",
    "To help you when you\n need it most",
    // Assuming you have a third image
  ];
  int currentIndex = 0;
  int nextIndex = 1;
  double currentImagePosition = 0;
  double nextImagePosition = 1;
  double topPosition = 0; // Start at screen view
  double nextImageTopPosition = 1.0; // Start off-screen

  //google login
  GoogleSignInAccount? _currentUser;
  bool _isAuthorized = false; // has granted permissions?
  ApiHelper apiHelper = ApiHelper();
  GoogleSignIn? _googleSignIn;
  TextEditingController mobileNumberCntrl = new TextEditingController();
  bool isEnable = false;

  late VideoPlayerController? videoPlayerController;
  final player = AudioPlayer();
  Map<int, VideoPlayerController> controllers = {};

  @override
  void initState() {
    super.initState();
    initializeVideos();
    playVideo(0,false);
    if (defaultTargetPlatform == TargetPlatform.android) {
      _googleSignIn = GoogleSignIn(
          clientId:
          "930588986366-rp6ddk8dm4siehj4n4di9d0t7kt270f8.apps.googleusercontent.com");
    } else {
      _googleSignIn = GoogleSignIn();
    }
    PreferenceUtils.init();
    /* WidgetsBinding.instance!.addPostFrameCallback((_) {

    });*/
    _lottie1AnimCtrl = AnimationController(vsync: this);
    _lottie2AnimCtrl = AnimationController(vsync: this);

    // Set the status bar color to black once the animation is completed
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.black, // Background color of status bar
      statusBarIconBrightness: Brightness.light, // Icon brightness for Android
      statusBarBrightness: Brightness.dark, // Icon brightness for iOS
    ));
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000), // Animation duration
      vsync: this,
    );

    // Define the animation for the gradient radius
    _animation = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller!, curve: Curves.easeIn))
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          SystemChrome.setSystemUIOverlayStyle(
              SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.white,
                // Background color of status bar
                statusBarIconBrightness: Brightness.dark,
                // Icon brightness for Android
                statusBarBrightness: Brightness.light, // Icon brightness for iOS
              ));
          setState(() {
            _opacity = 1.0;
            Future.delayed(Duration(seconds: 1), () {
              setState(() {
                _playLottie = true;
                print("_playLottie");
                print(_initialTextTop);
                print(_playLottie);
              });
            });
          });
        }
      });
    Future.delayed(Duration(milliseconds: 500), () {
      double screenHeight = MediaQuery.of(context).size.height;
      nextImageTopPosition = MediaQuery.of(context).size.height;
      print("screenHeight");
      print(screenHeight);
      _initialTextTop = (screenHeight / 2) - 180; // Center the text vertically
      instructionTextBottomImage = MediaQuery.of(context).padding.top + 120;
      instructionTextBottom =
          (screenHeight / 2) - 180; // Center the text vertically
      swipeUpBootom =
          MediaQuery.of(context).padding.bottom; // Center the text vertically
      _finalTextTop =
          MediaQuery.of(context).padding.top - 120; // Top of the screen
      _controller!.forward();
    }); // Start the animation
    requestPermission();
  }
  Future<void> requestPermission() async {
    var status = await Permission.notification.isGranted;
    if(!status){
      await Permission.notification.request();
    }
  }
  void initializeVideos(){
    final VideoPlayerController _controller =
    VideoPlayerController.asset(images[0]);
    controllers[0]=_controller;
    final VideoPlayerController _controller1 =
    VideoPlayerController.asset(images[1]);
    controllers[1]=_controller1;
    final VideoPlayerController _controller2 =
    VideoPlayerController.asset(images[2]);
    controllers[2]=_controller2;
    _controller.initialize();
    _controller1.initialize();
    _controller2.initialize();
  }
  void disposeVideos(){
    controllers.forEach((key, value) {
      value.dispose();
    });

  }
  void playVideo(int path,bool isPlay) {
    controllers.forEach((index, controller) {
      controller.pause();
      print('🚀🚀🚀 STOPPED $index');
    });
    final VideoPlayerController _controller = controllers[path]!;
    videoPlayerController =_controller;
    if(isPlay){
      playAudio(path);
    }
    /* videoPlayerController.initialize().then((_) {

      setState(() {});
    });*/

    videoPlayerController?.addListener(() {
      print(videoPlayerController?.value.isCompleted);
      if ((videoPlayerController!.value.isCompleted)) {
        print("VideoCompleted");
      }
    });
    videoPlayerController?.setLooping(true);
  }
  void playAudio(int index) async{

    await player.play(AssetSource(audios[index]));
    videoPlayerController?.play();
    player.onPlayerStateChanged.listen((event) {
      print("onPlayerStateChanged");
      print(event);
    });
    player.setReleaseMode(ReleaseMode.loop);
    player.setVolume(1.0);
    player.onPositionChanged.listen((event) {
      //print(event);
      if(videoPlayerController!=null){
        if(videoPlayerController!.value.isPlaying){
          //print("isPlaying");
        }else{
          print("isPlayingNot");
          videoPlayerController?.play();
        }
      }


    });
  }
  void pauseAudio(){

    player.pause();
  }

  void checkExistMailId() async {
    isApiCalling = true;
    ApiResponse apiResponse = await apiHelper
        .isAlreadyRegisteredApi(mobileNumberCntrl.text.toString());
    print("loginResponse");
    if (apiResponse.status == Status.COMPLETED) {
      LoginResponse loginResponse = LoginResponse.fromJson(apiResponse.data);
      print(loginResponse.status);
      if (loginResponse.status == 200) {
        sendMailOtp();
        Navigator.pushNamed(context, HomeWidgetRoutes.EnterPasswordWidget,
            arguments: {
              "email": mobileNumberCntrl.text.toString(),
              "isAlreadyRegistered": loginResponse.isAlreadyRegistered
            });
      } else {
        isApiCalling = false;
        Utility.showSnackBar(context: context, message: loginResponse.message);
      }
    } else {
      isApiCalling = false;
      Utility.showSnackBar(
          context: context, message: apiResponse.message.toString());
    }
  }

  void sendMailOtp() async {
    ApiResponse apiResponse =
    await apiHelper.sendOtpEmail(mobileNumberCntrl.text.toString());
    print("loginResponse");
  }

  @override
  void dispose() {
    disposeVideos();
    videoPlayerController?.dispose();
    videoPlayerController=null;
    player.dispose();
    _controller!.dispose(); // Dispose controller when widget is removed
    _lottie1AnimCtrl?.dispose();
    _lottie2AnimCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (showImagesScreen) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        // Icon brightness for Android
        statusBarBrightness: Brightness.light,
      ));
    }
    if (isLoginOptions) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        // Icon brightness for Android
        statusBarBrightness: Brightness.light,
      ));
    }
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          // Use a radial gradient that changes its radius according to the animation value
          gradient: RadialGradient(
            center: Alignment.center,
            radius: _animation!.value * 1.5,
            // Increase radius size to ensure it fills the screen
            colors: [Colors.white, Colors.black],
            stops: [
              _animation!.value,
              _animation!.value
            ], // Stops move with the animation value
          ),
        ),
        child: Container(
          child: Stack(
            children: [
              showImagesScreen
                  ? PageView.builder(
                onPageChanged: (index) {
                  isSwipeUp = true;
                  swipeCount = index;
                  swipeUp();
                  print("swipeCount");
                  print(swipeCount);
                  if(index!=3){
                    playVideo(index,true);
                  }else{
                    videoPlayerController?.pause();
                    pauseAudio();
                  }
                  instructionTextBottom = 300;
                  instructionTextBottomImage = 300;
                  setState(() {});
                  Future.delayed(Duration(milliseconds: 500), () {
                    instructionTextOpacity = 0.0;
                    setState(() {});
                    if (swipeCount == 1) {
                      imagePath = "assets/images/onboarding2.png";
                      instructionText =
                      "Quilt crafts personalized\n experiences just for you";
                    } else if (swipeCount == 2) {
                      imagePath = "assets/images/onboarding3.png";
                      instructionText =
                      "To help you when you\n need it most";
                    } else if (swipeCount == 3) {
                      isLoginOptions = true;
                    } else {
                      instructionText =
                      "When you feel stressed,\n anxious, restless, or down...";
                    }
                    instructionTextBottom =
                        MediaQuery.of(context).padding.bottom;
                    instructionTextBottomImage =
                        MediaQuery.of(context).padding.bottom;
                    Future.delayed(Duration(seconds: 0), () {
                      instructionTextBottom =
                          MediaQuery.of(context).padding.bottom +
                              180; // Move "HELLO" text towards the bottom
                      instructionTextBottomImage =
                          MediaQuery.of(context).padding.bottom + 180;
                      instructionTextOpacity = 1.0;
                      instructionImageOpacity = 1.0;
                      setState(() {});
                    });
                  });
                },
                scrollDirection: Axis.vertical,
                physics: isLoginOptions
                    ? NeverScrollableScrollPhysics()
                    : null,
                itemBuilder: (BuildContext context, int index) {
                  return index == 3
                      ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Container(
                          child: Image.asset(
                            "assets/images/log_img.png",
                            fit: BoxFit.cover,
                          ),
                          width: double.infinity,
                        ),
                      ),
                      Container(
                        child: Column(
                          children: [
                            Container(
                              child: Text(
                                "Sign in or create an account",
                                style: TextStyle(
                                    color: Color(0xff131314),
                                    fontSize: 20,
                                    fontFamily: "Causten-Medium"),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            defaultTargetPlatform ==
                                TargetPlatform.android
                                ? Container()
                                : Container(
                              child: Container(
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    appleSignIn();
                                  },
                                  child: Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment
                                        .center,
                                    mainAxisAlignment:
                                    MainAxisAlignment
                                        .center,
                                    children: [
                                      SvgPicture.asset(
                                          "assets/images/apple_img.svg"),
                                      Container(
                                        child: Text(
                                          "Continue with Apple",
                                          style: TextStyle(
                                              color: Colors
                                                  .white,
                                              fontSize: 14,
                                              fontFamily:
                                              "Causten-Bold"),
                                        ),
                                        margin:
                                        EdgeInsets.only(
                                            left: 15),
                                      )
                                    ],
                                  ),
                                  style: ElevatedButton
                                      .styleFrom(
                                      backgroundColor:
                                      Colors.black,
                                      shape:
                                      RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius
                                            .circular(
                                            30), // <-- Radius
                                      )),
                                ),
                                width: double.infinity,
                                margin: EdgeInsets.only(
                                    left: 15,
                                    right: 15,
                                    top: 20),
                              ),
                            ),
                            Container(
                              child: Container(
                                height: 55,
                                child: GestureDetector(
                                  child: Container(
                                    child: Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                            "assets/images/google_img.svg"),
                                        Container(
                                          child: Text(
                                            "Continue with Google",
                                            style: TextStyle(
                                                color:
                                                splashTextColor,
                                                fontSize: 14,
                                                fontFamily:
                                                "Causten-Bold"),
                                          ),
                                          margin: EdgeInsets.only(
                                              left: 15),
                                        )
                                      ],
                                    ),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color:
                                            Color(0xffCED2D6)),
                                        borderRadius:
                                        BorderRadius.circular(
                                            30)),
                                  ),
                                  onTap: () {
                                    googleSignIn();
                                  },
                                ),
                                width: double.infinity,
                                margin: EdgeInsets.only(
                                    left: 15, right: 15, top: 15),
                              ),
                            ),
                            Container(
                              child: Text(
                                "or",
                                style: TextStyle(
                                    color: Color(0xFF888888),
                                    fontSize: 14,
                                    fontFamily: "Causten-Medium"),
                              ),
                              margin: EdgeInsets.only(
                                  top: 10, bottom: 10),
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                  left: 15,
                                  right: 15,
                                  bottom: 5,
                                  top: 0),
                              padding: const EdgeInsets.all(3.0),
                              child: TextField(
                                controller: mobileNumberCntrl,
                                keyboardType:
                                TextInputType.emailAddress,
                                style: TextStyle(
                                    fontFamily: "Causten-Medium",
                                    fontSize: 14),
                                onChanged: (text) {
                                  if (text.isNotEmpty &&
                                      Utility.isValidEmail(text)) {
                                    isEnable = true;
                                  } else {
                                    isEnable = false;
                                  }
                                  setState(() {});
                                },
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Color(0xffCED2D6),
                                          width: 0.7),
                                      // No border
                                      borderRadius:
                                      BorderRadius.circular(
                                          30)),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Color(0xffCED2D6),
                                          width: 0.7),
                                      // No border
                                      borderRadius:
                                      BorderRadius.circular(
                                          30)),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 25.0,
                                      vertical: 15),
                                  hintStyle: TextStyle(
                                      color: Color(0xFFA0949D),
                                      fontFamily: "Causten-Regular",
                                      fontSize: 14),
                                  hintText: "example@example.com",
                                ),
                              ),
                            ),
                            Container(
                              height: 50,
                              child: GestureDetector(
                                child: Container(
                                  alignment: Alignment.center,
                                  /*  onPressed: () async {
                                    if(isEnable){
                                      checkExistMailId();
                                    }
                                  },*/
                                  child: Text(
                                    "Continue with email",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: isEnable
                                            ? Colors.white
                                            : Color(0xffB0B0B0),
                                        fontSize: 14,
                                        fontFamily:
                                        "Causten-SemiBold"),
                                  ),
                                  decoration: BoxDecoration(
                                      color: isEnable
                                          ? Colors.black
                                          : Color(0xffECECEC),
                                      borderRadius:
                                      BorderRadius.circular(
                                          30)),
                                ),
                                onTap: () {
                                  if (isEnable && !isApiCalling) {
                                    checkExistMailId();
                                  }
                                },
                              ),
                              width: double.infinity,
                              margin: EdgeInsets.only(
                                  left: 15, right: 15, bottom: 10),
                            ),
                            GestureDetector(
                              child: Container(
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                          text:
                                          'By continuing you confirm that you’ve read and accepted our ',
                                          style: TextStyle(
                                              color:
                                              Color(0xFF888888),
                                              fontFamily:
                                              "Causten-Regular",
                                              fontSize: 12)),
                                      TextSpan(
                                        text: 'Terms of Use',
                                        style: TextStyle(
                                            decoration:
                                            TextDecoration
                                                .underline,
                                            fontFamily:
                                            "Causten-Medium",
                                            color:
                                            Color(0xFF888888),
                                            fontSize: 12),
                                      ),
                                      TextSpan(
                                          text: ' and ',
                                          style: TextStyle(
                                              color:
                                              Color(0xFF888888),
                                              fontSize: 12)),
                                      TextSpan(
                                        text: 'Privacy Policy',
                                        style: TextStyle(
                                            decoration:
                                            TextDecoration
                                                .underline,
                                            fontFamily:
                                            "Causten-Medium",
                                            color:
                                            Color(0xFF888888),
                                            fontSize: 12),
                                      ),
                                      TextSpan(
                                          text: '.',
                                          style: TextStyle(
                                              color:
                                              Color(0xFF888888),
                                              fontSize: 12)),
                                    ],
                                  ),
                                ),
                                padding: EdgeInsets.only(
                                    left: 30,
                                    right: 30,
                                    bottom: 30,
                                    top: 20),
                              ),
                              onTap: () {
                                Navigator.of(context)
                                    .pushNamed(
                                    HomeWidgetRoutes.TCWebView)
                                    .then((value) => {
                                  SystemChrome
                                      .setSystemUIOverlayStyle(
                                      SystemUiOverlayStyle(
                                        statusBarColor:
                                        Colors.transparent,
                                        statusBarIconBrightness:
                                        Brightness.dark,
                                        // Icon brightness for Android
                                        statusBarBrightness:
                                        Brightness.light,
                                      ))
                                });
                              },
                            )
                          ],
                        ),
                      )
                    ],
                  )
                      : Stack(
                    children: [
                      /* Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(images[index]),
                        fit: BoxFit.cover,
                      ),
                    ),)*/
                      videoPlayerController != null
                          ? SizedBox.expand(
                          child: FittedBox(
                            fit: checkVideoRatio(
                                videoPlayerController!
                                    .value.size.width ??
                                    0,
                                videoPlayerController!
                                    .value.size.height ??
                                    0),
                            child: SizedBox(
                              width: videoPlayerController!
                                  .value.size.width ??
                                  0,
                              height: videoPlayerController!
                                  .value.size.height ??
                                  0,
                              child: VisibilityDetector(
                                key: Key("widget.url"),
                                onVisibilityChanged:
                                    (VisibilityInfo info) {
                                  print("visibleFraction");
                                  var visiblePercentage =
                                      info.visibleFraction * 100;

                                  print(visiblePercentage);
                                  if (visiblePercentage < 20) {
                                    videoPlayerController!
                                        .pause(); //pausing  functionality
                                  } else {
                                    videoPlayerController?.play();
                                  }
                                },
                                child: VideoPlayer(
                                    videoPlayerController!),
                              ),
                            ),
                          ))
                          : Container(
                        width:
                        MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context)
                            .size
                            .height,
                        child: Center(
                          child: Container(
                            height: 70,
                            width: 70,
                            color: Colors.black,
                            child: Center(
                                child:
                                CircularProgressIndicator(
                                  backgroundColor: Colors.grey,
                                  valueColor:
                                  AlwaysStoppedAnimation<
                                      Color>(
                                      Colors.blueAccent),
                                )),
                          ),
                        ),
                      ),
                      !isLoginOptions
                          ? AnimatedPositioned(
                        duration: Duration(milliseconds: 0),
                        bottom: MediaQuery.of(context)
                            .padding
                            .bottom +
                            180,
                        curve: Curves.easeInOut,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Column(
                            children: [
                              AnimatedOpacity(
                                opacity: 1.0,
                                // Use animated opacity for the text
                                duration: Duration(
                                    milliseconds:
                                    isSwipeUp ? 0 : 0),
                                // Duration for the text fade in
                                child: Text(
                                  texts[index],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontFamily:
                                      'Causten-SemiBold'),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                          : Container(),
                      !isSwipeUp && isFinishedInitialSetup
                          ? AnimatedOpacity(
                        opacity: 1.0,
                        // Use animated opacity for the text
                        duration: Duration(milliseconds: 300),
                        child: Center(
                          child: Container(
                            child: Column(
                              children: [
                                Expanded(
                                    child: Align(
                                      child: Column(
                                        mainAxisSize:
                                        MainAxisSize.min,
                                        children: [
                                          Lottie.asset(
                                              "assets/images/swipe_up_anim.json",
                                              repeat: true,
                                              height: 60),
                                          Text(
                                            "Swipe up to continue",
                                            textAlign:
                                            TextAlign.center,
                                            style: TextStyle(
                                                color:
                                                Colors.white,
                                                fontSize: 14,
                                                fontFamily:
                                                'Causten-Bold'),
                                          )
                                        ],
                                      ),
                                      alignment:
                                      Alignment.bottomCenter,
                                    ))
                              ],
                            ),
                            color:
                            Colors.black.withOpacity(0.4),
                            width: double.infinity,
                            alignment: Alignment.bottomCenter,
                            padding:
                            EdgeInsets.only(bottom: 70),
                          ),
                        ),
                      )
                          : Container()
                    ],
                  );
                },
                itemCount: 4,
              )
                  : Container(),
              AnimatedPositioned(
                duration: Duration(milliseconds: 500),
                top: _initialTextTop,
                left: 0,
                right: 0,
                child: Center(
                  child: Column(
                    children: [
                      _playLottie
                          ? AnimatedOpacity(
                        opacity: _lottieOpacity,
                        duration: Duration(
                            milliseconds:
                            _lottieOpacity == 1.0 ? 0 : 200),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Lottie.asset(
                                'assets/images/splash_anim1.json',
                                // Path to your Lottie file
                                repeat: false,
                                // Set to false if it should not loop
                                animate: _playLottie,
                                height: 180,
                                controller: _lottie1AnimCtrl,
                                onLoaded: (composition) {
                                  _lottie1AnimCtrl!
                                    ..duration = composition.duration
                                    ..forward()
                                    ..addListener(() {
                                      print("object");
                                      if (anim1D == 0) {
                                        anim1D = _lottie1AnimCtrl!
                                            .duration!.inSeconds -
                                            1;
                                        print("object123");
                                        print(anim1D);
                                        Future.delayed(
                                            Duration(seconds: anim1D), () {
                                          setState(() {
                                            _playLottie2 = true;
                                          });
                                        });
                                      }
                                    });
                                } // Control animation with the flag
                            ),
                            if (_playLottie2)
                              Lottie.asset(
                                  'assets/images/splash_anim2.json',
                                  // Path to your Lottie file
                                  repeat: false,
                                  // Set to false if it should not loop
                                  animate: _playLottie2,
                                  height: 180,
                                  controller: _lottie2AnimCtrl,
                                  onLoaded: (composition) {
                                    _lottie2AnimCtrl!
                                      ..duration = composition.duration
                                      ..forward()
                                      ..addListener(() {
                                        if (anim2D == 0) {
                                          anim2D = _lottie2AnimCtrl!
                                              .duration!.inSeconds +
                                              1;
                                          print("object1234");
                                          print(anim2D);
                                          Future.delayed(
                                              Duration(seconds: anim2D), () {
                                            setState(() {
                                              _lottieOpacity =
                                              0.0; // Move text to the top of the screen
                                            });
                                            if (!Utility.isEmpty(
                                                PreferenceUtils.getString(
                                                    PreferenceUtils
                                                        .USER_ID,
                                                    "")) &&
                                                !PreferenceUtils.getBool(
                                                    PreferenceUtils
                                                        .IS_LOGIN)!) {
                                              navigateToScreen(false);
                                            } else if (PreferenceUtils
                                                .getBool(PreferenceUtils
                                                .IS_LOGIN)!) {
                                              navigateToScreen(true);
                                            } else {
                                              Future.delayed(
                                                  Duration(milliseconds: 500),
                                                      () {
                                                    setState(() {
                                                      _initialTextTop =
                                                          _finalTextTop;
                                                      showImagesScreen = true;
                                                      playAudio(0);
                                                      Future.delayed(
                                                          Duration(
                                                              milliseconds: 800),
                                                              () {
                                                            setState(() {
                                                              swipeUpBootom =
                                                                  MediaQuery.of(
                                                                      context)
                                                                      .padding
                                                                      .bottom +
                                                                      70;
                                                              instructionTextBottom =
                                                                  MediaQuery.of(
                                                                      context)
                                                                      .padding
                                                                      .bottom +
                                                                      180; // Move "HELLO" text towards the bottom
                                                              instructionTextOpacity =
                                                              1.0;
                                                              instructionImageOpacity =
                                                              1.0;
                                                              swipeUpTextOpacity =
                                                              1.0;
                                                            });
                                                            Future.delayed(
                                                                Duration(seconds: 3),
                                                                    () {
                                                                  if (!isSwipeUp) {
                                                                    isFinishedInitialSetup =
                                                                    true;
                                                                    setState(() {});
                                                                  }
                                                                });
                                                          });
                                                    });
                                                  });
                                            }
                                          });
                                        }
                                      });
                                  } // Control animation with the flag
                              )
                          ],
                        ),
                      )
                          : Container(
                        height: _lottieOpacity == 1.0 ? 180 : 0,
                      ),
                      isLoginOptions
                          ? Container()
                          : AnimatedOpacity(
                        opacity: _opacity,
                        // Use animated opacity for the text
                        duration: Duration(seconds: 1),
                        // Duration for the text fade in
                        child: Text(
                          "QUILT",
                          style: TextStyle(
                            color: !isLoginOptions &&
                                _initialTextTop == _finalTextTop
                                ? !isSwipeUp && isFinishedInitialSetup
                                ? Colors.white.withOpacity(0.4)
                                : Colors.white
                                : null,
                            fontFamily: "Causten-Black",
                            letterSpacing: 4,
                            fontSize: 16,
                          ),
                        ) /*Image.asset("assets/images/quilt_name.png",
                              color: !isLoginOptions &&
                                      _initialTextTop == _finalTextTop
                                  ? Colors.white
                                  : null)*/
                        ,
                      )
                    ],
                  ),
                ),
              ),
              !isSwipeUp && isFinishedInitialSetup
                  ? Container()
                  : !isLoginOptions
                  ? AnimatedPositioned(
                duration: Duration(milliseconds: 1000),
                bottom: swipeUpBootom,
                left: 0,
                right: 0,
                child: Center(
                  child: Column(
                    children: [
                      AnimatedOpacity(
                        opacity: swipeUpTextOpacity,
                        // Use animated opacity for the text
                        duration: Duration(milliseconds: 300),
                        // Duration for the text fade in
                        child: Text(
                          "Swipe up to continue",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                              fontFamily: 'Causten-Medium'),
                        ),
                      )
                    ],
                  ),
                ),
              )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  void swipeUp() {
    if (currentIndex < images.length - 1) {
      setState(() {
        currentIndex++;
      });
    }
  }

  void navigateToScreen(bool isHome) {
    if (isHome) {
      Navigator.pushNamedAndRemoveUntil(
          context, HomeWidgetRoutes.DashboardWidget, (route) => false);
    } else {
      Navigator.pushNamedAndRemoveUntil(
          context, HomeWidgetRoutes.EnterUserNameWidget, (route) => false);
    }
  }

  void googleSignIn() async {
    _googleSignIn?.onCurrentUserChanged
        .listen((GoogleSignInAccount? account) async {
// #docregion CanAccessScopes
      // In mobile, being authenticated means being authorized...
      bool isAuthorized = account != null;

      // However, on web...
// #enddocregion CanAccessScopes

      _currentUser = account;
      print("currentUser");
      _isAuthorized = isAuthorized;
      GoogleSignInAuthentication? googleSignInAuthentication =
      await _currentUser?.authentication;
      print(googleSignInAuthentication?.idToken);
      googleLoginAPI(googleSignInAuthentication?.idToken, true);
    });
    _googleSignIn?.signIn();
  }

  void googleLoginAPI(id, bool isGoogleLogin) async {
    ApiResponse? apiResponse = null;
    if (isGoogleLogin) {
      apiResponse = await apiHelper.googleSign(id);
    } else {
      apiResponse = await apiHelper.appleSignIn(id);
    }
    //LoadingUtils.instance.hideOpenDialog(context);
    print("loginResponse");
    if (apiResponse.status == Status.COMPLETED) {
      UserResponse loginResponse = UserResponse.fromJson(apiResponse.data);
      print(loginResponse!.status);
      if (loginResponse!.status == 200 &&
          loginResponse!.errorCode == 0 &&
          !Utility.isEmpty(loginResponse!.sessionToken!)) {
        PreferenceUtils.setString(
            PreferenceUtils.SESSION_TOKEN, loginResponse!.sessionToken);
        PreferenceUtils.setString(
            PreferenceUtils.USER_ID, loginResponse!.userId);
        if (!loginResponse!.isUserProfileUpdated) {
          Navigator.pushNamedAndRemoveUntil(
              context, HomeWidgetRoutes.EnterUserNameWidget, (route) => false);
        } else {
          PreferenceUtils.setBool(PreferenceUtils.IS_LOGIN, true);
          Navigator.pushNamedAndRemoveUntil(
              context, HomeWidgetRoutes.DashboardWidget, (route) => false);
        }
      } else {
        setState(() {});
        Utility.showSnackBar(context: context, message: loginResponse.message);
      }
    } else {
      Utility.showSnackBar(
          context: context, message: apiResponse.message.toString());
    }
  }

  Future<void> appleSignIn() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
      ],
    );
    if (credential != null && credential.identityToken != null) {
      print("identityToken");
      print(credential.identityToken);
      googleLoginAPI(credential?.identityToken, false);
    }
    // Now send the credential (especially `credential.authorizationCode`) to your server to create a session
    // after they have been validated with Apple (see `Integration` section for more information on how to do this)
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
}
