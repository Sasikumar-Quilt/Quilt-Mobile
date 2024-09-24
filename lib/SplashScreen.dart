import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
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
import 'package:touch_ripple_effect/touch_ripple_effect.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'main.dart';

const List<String> scopes = <String>[];

class SplashWidget extends StatefulWidget {
  @override
  _AnimatedBackgroundScreenState createState() =>
      _AnimatedBackgroundScreenState();
}

class _AnimatedBackgroundScreenState extends State<SplashWidget>
    with TickerProviderStateMixin ,WidgetsBindingObserver{
  AnimationController? _controller;
  Animation<double>? _animation;
  double _opacity = 1.0; // Initial opacity for the text
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
  bool changeHeightForLogo = false;
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
  int swipeCount = -1;
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

  /*final List<String> texts = [
    """
      <p style="font-family: 'Causten-SemiBold', Arial, sans-serif; font-size: 32px; color: #ffffff; padding: 20px;">
        When you <span style="color: #40A1FB;">feel stressed</span>, anxious, restless, or down...
      </p>
    """,
    """
      <p style="font-family: 'Causten-SemiBold', Arial, sans-serif; font-size: 32px; color: #ffffff; padding: 20px;">
        Quilt crafts <span style="color: #40A1FB;">personalized experiences</span> just for you
      </p>
    """,
    // Replace with your asset images
    """
      <p style="font-family: 'Causten-SemiBold', Arial, sans-serif; font-size: 32px; color: #ffffff; padding: 20px;">
        To help you when <span style="color: #40A1FB;">you needs</span> it most
      </p>
    """,
    // Assuming you have a third image
  ];*/

  final List<String> texts = [
    """
      <p style="font-family: 'Causten-SemiBold', Arial, sans-serif; font-size: 32px; color: #ffffff; padding: 20px;">
        When you feel<span style="color: #40A1FB;"> stressed, anxious, </span>or <span style="color: #40A1FB;">tangled up</span> in intrusive thoughts ...
      </p>
    """,
    """
      <p style="font-family: 'Causten-SemiBold', Arial, sans-serif; font-size: 32px; color: #ffffff; padding: 20px;">
        Whether it’s just a hard day or <span style="color: #40A1FB;">your fears</span> or obsessions are triggered …
      </p>
    """,
    // Replace with your asset images
    """
      <p style="font-family: 'Causten-SemiBold', Arial, sans-serif; font-size: 32px; color: #ffffff; padding: 20px;">
        Quilt crafts <span style="color: #40A1FB;">experiences</span> just for you to help you when you need it most.
      </p>
    """,
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
  double screenHeight = 0;
  bool isResumed=true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    initializeVideos();
    playVideo(0, false);
    if (defaultTargetPlatform == TargetPlatform.android) {
      _googleSignIn = GoogleSignIn(
          clientId:
              "930588986366-rp6ddk8dm4siehj4n4di9d0t7kt270f8.apps.googleusercontent.com");
    } else {
      _googleSignIn = GoogleSignIn();
    }
    PreferenceUtils.init();

    _lottie1AnimCtrl = AnimationController(vsync: this);
    _lottie2AnimCtrl = AnimationController(vsync: this);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent, // Background color of status bar
      statusBarIconBrightness: Brightness.light, // Icon brightness for Android
      statusBarBrightness: Brightness.dark, // Icon brightness for iOS
    ));

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000), // Animation duration
      vsync: this,
    );

    // Define the animation for the gradient radius

    Future.delayed(Duration(milliseconds: 1500), () {
      nextImageTopPosition = MediaQuery.of(context).size.height;
      print("screenHeight");

      instructionTextBottomImage = MediaQuery.of(context).padding.top + 120;
      instructionTextBottom =
          (screenHeight / 2) - 180; // Center the text vertically
      swipeUpBootom =
          MediaQuery.of(context).padding.bottom; // Center the text vertically
      _finalTextTop =
          MediaQuery.of(context).padding.top - 120; // Top of the screen
      _controller!.forward();
      Future.delayed(Duration(seconds: 1), () {
        setLogoAnimation();
      });
    }); // Start the animation
    requestPermission();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      isResumed=false;
      pauseAudio();
      videoPlayerController?.pause();
    } else if (state == AppLifecycleState.resumed) {
      isResumed=true;
      print("resumed");
     if(swipeCount!=3){
       player.resume();
       videoPlayerController?.play();
     }
    }
  }

  Future<void> requestPermission() async {
    var status = await Permission.notification.isGranted;
    if (!status) {
      await Permission.notification.request();
    }
  }

  void initializeVideos() {
    final VideoPlayerController _controller =
        VideoPlayerController.asset(images[0]);
    controllers[0] = _controller;
    final VideoPlayerController _controller1 =
        VideoPlayerController.asset(images[1]);
    controllers[1] = _controller1;
    final VideoPlayerController _controller2 =
        VideoPlayerController.asset(images[2]);
    controllers[2] = _controller2;
    _controller.initialize();
    _controller1.initialize();
    _controller2.initialize();
  }

  void disposeVideos() {
    controllers.forEach((key, value) {
      value.dispose();
    });
  }

  void playVideo(int path, bool isPlay) {
    controllers.forEach((index, controller) {
      controller.pause();
      print('🚀🚀🚀 STOPPED $index');
    });
    final VideoPlayerController _controller = controllers[path]!;
    videoPlayerController = _controller;
    if (isPlay) {
      playAudio(path);
    }
    videoPlayerController?.addListener(() {
      print(videoPlayerController?.value.isCompleted);
      if ((videoPlayerController!.value.isCompleted)) {
        print("VideoCompleted");
      }
    });
    videoPlayerController?.setLooping(true);
  }

  void playAudio(int index) async {

    await player.play(AssetSource(audios[index]));
    if(!isResumed){
      player.pause();
      videoPlayerController?.play();
    }
    player.onPlayerStateChanged.listen((event) {
      print("onPlayerStateChanged");
      print(event);
    });
    player.setReleaseMode(ReleaseMode.loop);
    player.setVolume(1.0);
    player.onPositionChanged.listen((event) {
      //print(event);
      if (videoPlayerController != null) {
        if (videoPlayerController!.value.isPlaying) {
          //print("isPlaying");
        } else {
          print("isPlayingNot");
          videoPlayerController?.play();
        }
      }
    });
  }

  void pauseAudio() {
    player.pause();
  }

  void checkExistMailId() async {
    isApiCalling = true;
    setState(() {});
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
            }).then((value) => {isApiCalling = false, setState(() {})});
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

  void setLogoAnimation() {
    /* anim2D = _lottie2AnimCtrl!
      .duration!.inSeconds +
      1;
  print("object1234");
  print(anim2D);
  Future.delayed(
      Duration(seconds: anim2D), () {
    setState(() {
      _lottieOpacity =
      0.0; // Move text to the top of the screen
    });*/
    _lottieOpacity = 1.0; // Move text to the top of the screen
    if (!Utility.isEmpty(
            PreferenceUtils.getString(PreferenceUtils.USER_ID, "")) &&
        !PreferenceUtils.getBool(PreferenceUtils.IS_LOGIN)!) {
      navigateToScreen(false);
    } else if (PreferenceUtils.getBool(PreferenceUtils.IS_LOGIN)!) {
      navigateToScreen(true);
    } else {
      Future.delayed(Duration(milliseconds: 500), () {
        setState(() {
          _initialTextTop = _finalTextTop;
          showImagesScreen = true;
          changeHeightForLogo = true;
          playAudio(0);
          Future.delayed(Duration(milliseconds: 800), () {
            setState(() {
              swipeUpBootom = MediaQuery.of(context).padding.bottom + 70;
              instructionTextBottom = MediaQuery.of(context).padding.bottom +
                  180; // Move "HELLO" text towards the bottom
              instructionTextOpacity = 1.0;
              instructionImageOpacity = 1.0;
              swipeUpTextOpacity = 1.0;
            });
            if (!isSwipeUp) {
              isFinishedInitialSetup = true;
              setState(() {});
            }
            /*Future.delayed(
                        Duration(seconds: 0),
                            () {

                        });*/
          });
        });
      });
    }
    /* });*/
  }

  @override
  void dispose() {
    disposeVideos();
    //videoPlayerController?.dispose();
    videoPlayerController = null;
    player.dispose();
    _controller!.dispose(); // Dispose controller when widget is removed
    _lottie1AnimCtrl?.dispose();
    _lottie2AnimCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (screenHeight == 0) {
      screenHeight = MediaQuery.of(context).size.height;
      _initialTextTop = (screenHeight / 2); // Center the text vertically
      print(screenHeight);
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        child: Container(
          child: Stack(
            children: [
              Container(
                child: Stack(
                  children: [
                    Image.asset(
                      "assets/images/splash.gif",
                      fit: BoxFit.fill,
                      width: double.infinity,height: double.infinity,
                    ),
                    //  Image.asset("assets/images/noisy.png",fit: BoxFit.fill,width: double.infinity, colorBlendMode: BlendMode.overlay, color: Colors.black.withOpacity(0.0),),
/*
                Align(child: SvgPicture.asset("assets/images/app_logo1.svg",height: 53,),alignment: Alignment.center,),
*/
                  ],
                ),
              ),
              showImagesScreen
                  ? PageView.builder(
                      onPageChanged: (index) {
                        isSwipeUp = true;
                        swipeCount = index;
                        swipeUp();
                        print("swipeCount");
                        print(swipeCount);
                        if (index != 3) {
                          playVideo(index, true);
                        } else {
                          changeHeightForLogo = false;
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
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  /* Expanded(
                                    child: Container(
                                      child: Image.asset(
                                        "assets/images/log_img.png",
                                        fit: BoxFit.cover,
                                      ),
                                      width: double.infinity,
                                    ),
                                  ),*/
                                  Container(
                                    margin: EdgeInsets.only(bottom: 15),
                                    child: Text(
                                      "Sign in or create an account",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
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
                                            child: TouchRippleEffect(
                                              rippleColor: Colors.blue,
                                              child: Container(
                                                height: 55,
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SvgPicture.asset(
                                                        "assets/images/apple_img.svg"),
                                                    Container(
                                                      child: Text(
                                                        "Continue with Apple",
                                                        style: TextStyle(
                                                            color:
                                                                splashTextColor,
                                                            fontSize: 14,
                                                            fontFamily:
                                                                "Causten-Medium"),
                                                      ),
                                                      margin: EdgeInsets.only(
                                                          left: 15),
                                                    )
                                                  ],
                                                ),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.white),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                    color: Colors.white),
                                              ),
                                              onTap: () {
                                                appleSignIn();
                                              },
                                            ),
                                            width: double.infinity,
                                            margin: EdgeInsets.only(
                                                left: 15, right: 15, top: 15),
                                          ),
                                        ),
                                  Container(
                                    child: Container(
                                      height: 55,
                                      child: TouchRippleEffect(
                                        rippleColor: Colors.blue,
                                        child: Container(
                                          height: 55,
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
                                                      color: splashTextColor,
                                                      fontSize: 14,
                                                      fontFamily:
                                                          "Causten-Medium"),
                                                ),
                                                margin:
                                                    EdgeInsets.only(left: 15),
                                              )
                                            ],
                                          ),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.white),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              color: Colors.white),
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
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontFamily: "Causten-Medium"),
                                    ),
                                    margin:
                                        EdgeInsets.only(top: 10, bottom: 10),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(
                                        left: 15, right: 15, bottom: 5, top: 0),
                                    padding: const EdgeInsets.all(3.0),
                                    child: TextField(
                                      controller: mobileNumberCntrl,
                                      keyboardType: TextInputType.emailAddress,
                                      style: TextStyle(
                                          fontFamily: "Causten-Medium",
                                          color: Colors.white,
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
                                                color: Color(0xff6D6D6D),
                                                width: 0.7),
                                            // No border
                                            borderRadius:
                                                BorderRadius.circular(30)),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Color(0xff6D6D6D),
                                                width: 0.7),
                                            // No border
                                            borderRadius:
                                                BorderRadius.circular(30)),
                                        filled: true,
                                        fillColor:
                                            Color.fromRGBO(39, 39, 39, 0.60),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 25.0, vertical: 15),
                                        hintStyle: TextStyle(
                                            color: Color(0xFFB0B0B0),
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
                                                  : Color(0xff5D5D5D),
                                              fontSize: 14,
                                              fontFamily: "Causten-Medium"),
                                        ),
                                        decoration: BoxDecoration(
                                            color: /*isEnable
                                                ? */
                                                Colors
                                                    .black /* : Color(0xffECECEC)*/,
                                            borderRadius:
                                                BorderRadius.circular(30)),
                                      ),
                                      onTap: () {
                                        if (isEnable && !isApiCalling) {
                                          checkExistMailId();
                                        }
                                      },
                                    ),
                                    width: double.infinity,
                                    margin: EdgeInsets.only(
                                        left: 15,
                                        right: 15,
                                        bottom: 10,
                                        top: 10),
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
                                                    color: Colors.white,
                                                    fontFamily:
                                                        "Causten-Regular",
                                                    fontSize: 12)),
                                            TextSpan(
                                              text: 'Terms of Use',
                                              style: TextStyle(
                                                  decoration:
                                                      TextDecoration.underline,
                                                  fontFamily: "Causten-Medium",
                                                  color: Colors.white,
                                                  fontSize: 12),
                                            ),
                                            TextSpan(
                                                text: ' and ',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12)),
                                            TextSpan(
                                              text: 'Privacy Policy',
                                              style: TextStyle(
                                                  decoration:
                                                      TextDecoration.underline,
                                                  fontFamily: "Causten-Medium",
                                                  color: Colors.white,
                                                  fontSize: 12),
                                            ),
                                            TextSpan(
                                                text: '.',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                      padding: EdgeInsets.only(
                                          left: 30,
                                          right: 30,
                                          bottom: 0,
                                          top: 20),
                                    ),
                                    onTap: () {
                                      Navigator.of(context)
                                          .pushNamed(HomeWidgetRoutes.TCWebView)
                                          .then((value) => {
                                                SystemChrome
                                                    .setSystemUIOverlayStyle(
                                                        SystemUiOverlayStyle
                                                            .dark
                                                            .copyWith(
                                                  statusBarColor:
                                                      Colors.transparent,
                                                  // Background color of status bar
                                                  statusBarIconBrightness:
                                                      Brightness.light,
                                                  // Icon brightness for Android
                                                  statusBarBrightness: Brightness
                                                      .dark, // Icon brightness for iOS
                                                ))
                                              });
                                    },
                                  )
                                  /*Container(
                                    child: Column( mainAxisSize: MainAxisSize.max,crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [

                                      ],
                                    ),
                                  )*/
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
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    color: Colors.black.withOpacity(0.7),
                                    height: double.infinity,
                                    width: double.infinity,
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
                                                    child: Html(
                                                      data: texts[index],
                                                      style: {
                                                        "p": Style(
                                                          fontSize:
                                                              FontSize(32.0),
                                                          fontFamily:
                                                              'Causten-SemiBold', // Replace with your font family
                                                        ),
                                                      },
                                                    ))
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
                      Container(
                        height: changeHeightForLogo ? 180 : 0,
                      ),
                      isLoginOptions
                          ? Container()
                          : AnimatedOpacity(
                              opacity: _opacity,
                              // Use animated opacity for the text
                              duration: Duration(seconds: 1),
                              // Duration for the text fade in
                              child: SvgPicture.asset(
                                  "assets/images/app_logo1.svg",
                                  width: showImagesScreen
                                      ? 54
                                      : null) /*Text(
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
                              )*/ /*Image.asset("assets/images/quilt_name.png",
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
              isApiCalling
                  ? Positioned(
                      top: 0,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 150,
                        width: 150,
                        child: Center(
                            child: Lottie.asset(
                                "assets/images/feed_preloader.json",
                                height: 150,
                                width: 150)),
                      ),
                    )
                  : Positioned(
                      top: 0,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(),
                    )
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
    isApiCalling = true;
    setState(() {});
    _googleSignIn?.onCurrentUserChanged
        .listen((GoogleSignInAccount? account) async {
      print("GoogleSignInAccount");
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
    }).onError(handleError);
    try {
      GoogleSignInAccount? googleSignInAccount = await _googleSignIn?.signIn();
      if (googleSignInAccount == null) {
        isApiCalling = false;
        setState(() {});
        print("cancelled");
      }
    } catch (error) {
      isApiCalling = false;
      setState(() {});
    }
  }

  void handleError(error) {
    isApiCalling = false;
    setState(() {});
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
        isApiCalling = false;
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
        isApiCalling = false;
        setState(() {});
        Utility.showSnackBar(context: context, message: loginResponse.message);
      }
    } else {
      isApiCalling = false;
      setState(() {});
      Utility.showSnackBar(
          context: context, message: apiResponse.message.toString());
    }
  }

  Future<void> appleSignIn() async {
    isApiCalling = true;
    setState(() {});
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
      ],
    );
    if (credential != null && credential.identityToken != null) {
      print("identityToken");
      print(credential.identityToken);
      googleLoginAPI(credential?.identityToken, false);
    } else {
      isApiCalling = false;
      setState(() {});
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
