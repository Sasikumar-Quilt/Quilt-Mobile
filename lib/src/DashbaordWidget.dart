import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'dart:ui';
import 'dart:developer' as logd;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/svg.dart';
import 'package:is_lock_screen2/is_lock_screen2.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_state/phone_state.dart';
import 'package:quilt/src/PrefUtils.dart';
import 'package:quilt/src/PushNotificationService.dart';
import 'package:quilt/src/base/BaseState.dart';
import 'package:quilt/src/dialog/FeedbackDialog.dart';
import 'package:quilt/src/feed/LottieWidget.dart';
import 'package:quilt/src/feed/TextScrollWidget.dart';
import 'package:quilt/src/feedback/OpenFeedBackWidget.dart';
import 'package:quilt/src/remoteCOnfig/RemoteConfig.dart';
import 'package:quilt/src/tooltip/enums.dart';
import 'package:quilt/src/tooltip/super_tooltip.dart';
import 'package:quilt/src/tooltip/super_tooltip_controller.dart';
import 'package:quilt/src/video/AudioPlayerManager.dart';
import 'package:quilt/src/video/PreloadImages.dart';
import 'package:quilt/src/video/PreloadVideo.dart';
import 'package:quilt/src/video/VideoWidget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../main.dart';
import 'Analytics/UserTrackingHelper.dart';
import 'Utility.dart';
import 'api/ApiHelper.dart';
import 'api/BaseApiService.dart';
import 'api/NetworkApiService.dart';
import 'api/Objects.dart';
import 'dialog/VersionUpdateDialog.dart';
import 'favorite/FavoriteDialog.dart';
import 'feed/HomeWidgetRoute.dart';
import 'feed/ImageViewWidget.dart';
import 'feedback/FeedbackWidget.dart';

int tempPageCount = 0;

class DashboardWidget extends BasePage {
  DashboardWidget({Key? key}) : super(key: key);

  @override
  DashboardWidgetState createState() => DashboardWidgetState();
}

class DashboardWidgetState extends BasePageState<DashboardWidget>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  StreamSubscription<PhoneState>? _phoneStateSubscription;

  bool isEnable = false;
  String username = "";
  var identifier = "";
  ApiHelper apiHelper = ApiHelper();
  bool isArg = false;
  int isLoading = 0;
  Cluster? cluster;
  Cluster? dCluster;
  List<Mood>? moods;
  bool isSurpriseMe = false;
  List<Mood>? dMoods = [];
  List<Mood>? dMoods2 = [];

  List<Mood>? positiveMoods = [];
  List<Mood>? positiveMoods2 = [];

  List<Mood>? moods2;
  Mood? selectedMood = null;

  TextEditingController textEditingController = new TextEditingController();
  List<ContentObj>? contentList = [];
  bool isRefreshFeed = false;
  List<ContentObj>? bContentList = [];
  bool isHasTag = false;
  bool isClosedBottomSheet = true;
  bool isOpenFeelDialog = false;
  bool isPositiveEmotion = false;
  bool isContentListApiRunning = false;
  SuperTooltipController? controller1 = SuperTooltipController();
  SuperTooltipController? controller2 = SuperTooltipController();
  SuperTooltipController? controller3 = SuperTooltipController();
  String moodName = "Surprise me";
  String bMoodName = "Surprise me";
  bool isPlay = true;
  PageController? _pageController;
  int currentPage = 1;
  int bCurrentPage = 1;
  int pageCount = 0;
  int bPageCount = 0;
  bool hasMoreData = true;
  final int pageSize = 10;
  String moodId = "";
  String bMoodId = "";
  int selectedPositive = 0;
  bool isMute = false;
  Timer? timer;
  bool isNeedPrompt = false;
  bool isShowTerms = false;
  FocusNode _focusNode = FocusNode();
  bool isShowSwipeAnim = false;
  bool isShowTapAnim = false;
  bool isFromInitState = false;
  int currentTab = 0;
  List<Widget> webViewList = [];
  List<CollectionObject> collectionList = [];
  bool isFullEmotion = false;
  late PreloadVideos preloadVideos;
  late PreloadImages preloadImages;
  bool isScroll = true;
  bool bIsPlay = false;
  PhoneState status = PhoneState.nothing();
  AudioPlayerManager audioManager = AudioPlayerManager();
  RemoteConfigService? remoteConfigService;
  UserTrackingHelper? userTrackingHelper;
  late MenuController _iFeelMenuController = MenuController();

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      getNotificationDetails();
    } else {
      FirebaseMessaging.instance
          .getInitialMessage()
          .then((RemoteMessage? message) {
        print("getInitialMessage123");
        if (message != null) {
          print(message.data);
          print("object");
          print(message.notification);
          getNotificationIosDetails(message, true);
        } else {
          init();
        }
      });
    }

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onMessageOpenedApp");

      if (message != null) {
        print(message.data);
        print("object");
        print(message.notification);

        getNotificationIosDetails(message, false);
      }
    });
  }

  void getNotificationIosDetails(RemoteMessage message, bool isInit) {
    Map<dynamic, dynamic> dataObj = message.data['data'] is String
        ? jsonDecode(message.data['data'])
        : message.data['data'];
    Map<String, dynamic> content = dataObj['content'] is String
        ? jsonDecode(dataObj['content'])
        : dataObj['content'];
    if (content["feedbackNotifications"] != null) {
      Map<String, dynamic> feedbackNotifications =
          content["feedbackNotifications"] is String
              ? jsonDecode(message.data['feedbackNotifications'])
              : content['feedbackNotifications'];
      if (feedbackNotifications != null &&
          feedbackNotifications["shouldSendFeedbackNotification"]) {
        String feedbackId = feedbackNotifications["assessmentId"];

        PushNotificationService.isNotificationClick = true;
        if (userTrackingHelper != null) {
          bIsPlay = isPlay;
          isPlay = false;
          pauseAudio();
          setState(() {});
          PushNotificationService.isNotificationClick = false;
          Navigator.pushNamed(
              context, HomeWidgetRoutes.AssessmentListWidget, arguments: {
            "feedbackId": feedbackId
          }).then((value) => {
                if (bIsPlay) {isPlay = true, playAudio(), setState(() {})}
              });
        } else {
          Navigator.pushNamed(context, HomeWidgetRoutes.AssessmentListWidget,
                  arguments: {"feedbackId": feedbackId})
              .then((value) => {
                    PushNotificationService.isNotificationClick = false,
                    init()
                  });
        }
      } else {
        if (isInit) {
          init();
        }
      }
    } else {
      if (isInit) {
        init();
      }
    }
  }

  Future<void> getNotificationDetails() async {
    if (!PushNotificationService.checkIfInitialized()) {
      print("checkIfInitialized");
      init();
      return;
    }
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await PushNotificationService.flutterLocalNotificationsPlugin
            .getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails != null &&
        notificationAppLaunchDetails!.didNotificationLaunchApp) {
      print(
          'Notification payload: ${notificationAppLaunchDetails.notificationResponse}');
      print(
          'Notification payload: ${notificationAppLaunchDetails.notificationResponse!.payload}');
      String? data = notificationAppLaunchDetails.notificationResponse!.payload;
      if (!Utility.isEmpty(data)) {
        Map<String, dynamic> content;
        Map<String, dynamic> dataObj;
        print("message.data");
        print(data);
        dataObj = jsonDecode(data!);
        content = dataObj['content'] is String
            ? jsonDecode(dataObj['content'])
            : dataObj['content'];
        if (content["feedbackNotifications"] != null) {
          Map<String, dynamic> feedbackNotifications =
              content["feedbackNotifications"] is String
                  ? jsonDecode(content['feedbackNotifications'])
                  : content['feedbackNotifications'];
          if (feedbackNotifications != null &&
              feedbackNotifications["shouldSendFeedbackNotification"]) {
            Future.delayed(Duration.zero, () {
              Navigator.pushNamed(
                  context, HomeWidgetRoutes.AssessmentListWidget, arguments: {
                "feedbackId": feedbackNotifications["assessmentId"]
              }).then((value) => {
                    PushNotificationService.isNotificationClick = false,
                    init()
                  });
            });
          } else {
            init();
          }
        } else {
          init();
        }
      } else {
        init();
      }
    } else {
      init();
    }
  }

  void init() {
    userTrackingHelper = UserTrackingHelper();
    userTrackingHelper!.init();
    userTrackingHelper!.saveUserEntries("app_open", "");
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light));
    requestPermission();
    preloadVideos = PreloadVideos(updateWidget);
    preloadImages = PreloadImages(updateWidget);
    WakelockPlus.enable();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController(initialPage: 0, keepPage: false);
    _focusNode.addListener(() {
      setState(() {}); // To update the UI when the focus state changes
    });

    Future.delayed(Duration.zero, () {
      getCollectionList();
      if (!Utility.isEmpty(
          PreferenceUtils.getString(PreferenceUtils.MOODID, ""))) {
        moodName = PreferenceUtils.getString("moodName", "Surprise me");
        isSurpriseMe = PreferenceUtils.getBool("is_surprise") ?? false;
        isFromInitState = true;
        getContentList(
            PreferenceUtils.getString(PreferenceUtils.MOODID, ""), context);
      }
      getDefaultMoods();
      checkForAppUpdate();
    });
    getFirebaseToken();
    updateContentFav();
  }

  void checkForAppUpdate() {
    remoteConfigService = RemoteConfigService(context);
    remoteConfigService!.initialize().then((value) => {
          remoteConfigService!.shouldForceUpdate().then((value) => {
                if (value) {showVersionUpdateDialog()}
              })
        });
  }

  void requestPermission() async {
    if (Platform.isAndroid) {
      var status = await Permission.phone.isGranted;
      if (status) {
        setStream();
      } else {
        var status = await Permission.phone.request();
        if (status == PermissionStatus.granted) {
          setStream();
        }
      }
    } else {
      setStream();
    }
  }

  void setStream() {
    _phoneStateSubscription = PhoneState.stream.listen((event) {
      status = event;
      print("PhoneStatus");
      print(status.status);
      if (status.status == PhoneStateStatus.CALL_INCOMING ||
          status.status == PhoneStateStatus.CALL_STARTED) {
        if (timer == null) {
          bIsPlay = isPlay;
          isPlay = false;
          pauseAudio();
        }
      } else {
        if (timer == null) {
          if (bIsPlay) {
            isPlay = true;
            playAudio();
          }
        }
      }
      setState(() {});
    });
  }

  void showSwipeAnim() {
    bool isSwiped = PreferenceUtils.getBool("isSwiped") ?? false;
    bool isTapAnim = PreferenceUtils.getBool("isTapAnim") ?? false;
    if (!isSwiped) {
      isShowSwipeAnim = true;
      PreferenceUtils.setBool("isSwiped", true);
    }
    if (!isTapAnim && isSwiped) {
      isShowTapAnim = true;
      PreferenceUtils.setBool("isTapAnim", true);
    }
  }

  void updateWidget() {
    print("updateWidget");
    setState(() {});
  }

  void updateContentFav() {
    eventBus.on<MyEvent>().listen((event) {
      List<ContentObj> receivedList = event.list;
      print(receivedList.length);
      if (receivedList.isNotEmpty && contentList!.isNotEmpty) {
        for (int i = 0; i < receivedList.length; i++) {
          print(receivedList[i].id);
          int index = contentList!
              .indexWhere((element) => element.contentId == receivedList[i].id);
          if (index != -1) {
            contentList![index].isFav = false;
          }
        }
        print('${DateTime.now()} Event: $event');
      }
    });
    eventBus.on<NotificationEvent>().listen((event) {
      List<String> receivedList = event.id;
      print(receivedList.length);
      if (userTrackingHelper != null) {
        bIsPlay = isPlay;
        isPlay = false;
        pauseAudio();
        setState(() {});
        PushNotificationService.isNotificationClick = false;
        Navigator.pushNamed(
            context, HomeWidgetRoutes.AssessmentListWidget, arguments: {
          "feedbackId": receivedList[0]
        }).then((value) => {
              if (bIsPlay) {isPlay = true, playAudio(), setState(() {})}
            });
      }
    });
  }

  void playAudio() async {
    print("gameAudio");
    if (contentList == null ||
        contentList!.isEmpty ||
        contentList![pageCount]!.contentFormat != "WEB_VIEW" ||
        Utility.isEmpty(contentList![pageCount]!.audioURL)) {
      return;
    }
    print(contentList![pageCount].duration);
    print(contentList![pageCount].audioURL);
    audioManager.setCurrentAction("Feed");
    await audioManager.playAudio(contentList![pageCount]!.audioURL!,
        contentList![pageCount]!.duration, true);
    audioManager.setVolume(isMute);
    audioManager.withUpdateCallback((duration) => {
          if (currentRouteName == HomeWidgetRoutes.DashboardWidget ||
              currentRouteName == "/" ||
              currentRouteName == null)
            {
              if (audioManager.getCurrentAction() == "Feed")
                {contentList![pageCount].duration = duration}
            }
        });
  }

  Future<void> pauseAudio() async {
    if (contentList != null && contentList!.isNotEmpty) {
      print("audioPause");
      return audioManager.pause();
    }
  }

  @override
  void dispose() {
    super.dispose();
    audioManager?.dispose();
    _phoneStateSubscription?.cancel();
    preloadVideos.disposeAll();
    eventBus.dispose();
  }

  @override
  void didUpdateWidget(covariant DashboardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    print(currentRouteName);
    print("didUpdateWidget");
    int currentTap = PreferenceUtils.getInt("currentTap", 0);
    if (currentRouteName == HomeWidgetRoutes.DashboardWidget ||
        currentRouteName == "/" ||
        currentRouteName == null) {
      PreferenceUtils.setBool("isFirstTime", false);
      getCollectionList();
      if (bIsPlay) {
        isPlay = true;
        playAudio();
      }
    } else {
      if (timer != null ||
          currentRouteName == HomeWidgetRoutes.FavoriteWidget) {
        if (currentTap == 1 && !PreferenceUtils.getBool("isFirstTime")!) {
          PreferenceUtils.setBool("isFirstTime", true);
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          bIsPlay = isPlay;
          isPlay = false;
          pauseAudio();
          timer?.cancel();
          timer = null;
        } else {
          if (currentTap == 0) {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            bIsPlay = isPlay;
            isPlay = false;
            pauseAudio();
            timer?.cancel();
            timer = null;
          }
        }
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (currentRouteName == HomeWidgetRoutes.DashboardWidget ||
        currentRouteName == "/" ||
        currentRouteName == null) {
      int currentTap = PreferenceUtils.getInt("currentTap", 0);

      if (state == AppLifecycleState.paused) {
        userTrackingHelper!.saveUserEntries("app_minimise", "");
        userTrackingHelper!.sendUserTrackingRequest();
        print("applicationPaused");
        print(currentRouteName);
        if ((currentRouteName == HomeWidgetRoutes.DashboardWidget ||
                currentRouteName == "/" ||
                currentRouteName == null) &&
            currentTap == 0) {
          bIsPlay = isPlay;
          print("pausedPlay");
          isPlay = false;
          pauseAudio();
          setState(() {});
        }
        final isLock = await isLockScreen();
        if (!isLock!) {
          isNeedPrompt = false;
          if (currentRouteName == HomeWidgetRoutes.DashboardWidget ||
              currentRouteName == "/" ||
              currentRouteName == null) {
            resumeFunction();
            print('app inactive MINIMIZED!');
          }
        }
      } else if (state == AppLifecycleState.resumed) {
        userTrackingHelper!.saveUserEntries("app_open", "");
        print('app resumed');
        timer?.cancel();
        timer = null;
        print(isNeedPrompt);
        if (isNeedPrompt &&
            ((currentRouteName == HomeWidgetRoutes.DashboardWidget) ||
                (currentRouteName == "/") ||
                (currentRouteName == null)) &&
            currentTap == 0) {
          isNeedPrompt = false;
          isClosedBottomSheet = false;
          if (!Utility.isEmpty(
              PreferenceUtils.getString(PreferenceUtils.MOODID, ""))) {
            isFromInitState = true;
            currentPage = 1;
            contentList = [];
            getContentList(
                PreferenceUtils.getString(PreferenceUtils.MOODID, ""), context);
          }
          if (dMoods != null && dMoods!.isNotEmpty) {
            isLoading = 0;
            selectedPositive = 0;
            textEditingController.text = "";
            moods = [];
            moods2 = [];
            if (isPositiveEmotion) {
              if (positiveMoods != null && positiveMoods!.isNotEmpty) {
                moods!.addAll(positiveMoods!);
                moods2!.addAll(positiveMoods2!);
              }
            } else {
              if (dMoods != null && dMoods!.isNotEmpty) {
                moods!.addAll(dMoods!);
                moods2!.addAll(dMoods2!);
              }
            }
            selectedMood = null;
            //setState(() {});
            _showEmotionModal();
          }
        } else {
          isNeedPrompt = false;
          if (currentTap == 0 &&
              (currentRouteName == HomeWidgetRoutes.DashboardWidget ||
                  currentRouteName == "/" ||
                  currentRouteName == null) &&
              contentList != null &&
              contentList!.isNotEmpty) {
            if (bIsPlay) {
              isPlay = true;
              playAudio();
            }
            setState(() {});
          }
        }
      }
    }
  }

  void resumeFunction() {
    timer = new Timer(Duration(minutes: 15), () {
      isNeedPrompt = true;
    });
  }

  getArgs() {
    if (!isArg) {
      isArg = true;
      if (ModalRoute.of(context)?.settings.arguments != null) {
        final args = ModalRoute.of(context)?.settings.arguments as Map;
        isShowTerms = args["isShowTerms"] ?? false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    getArgs();
    return Scaffold(
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        child: Container(
          child: Stack(
            children: [
              Align(
                  child: contentList != null && contentList!.length > 0
                      ? Container(
                          child: PageView.builder(
                            controller: _pageController,
                            physics: !isScroll
                                ? NeverScrollableScrollPhysics()
                                : null,
                            itemCount: contentList!.length,
                            onPageChanged: (index) async {
                              await pauseAudio();
                              userTrackingHelper!.saveUserEntries("feed_exit",
                                  contentList![pageCount].contentId!);
                              pageCount = index;
                              tempPageCount = pageCount;
                              isPlay = true;
                              print(pageCount);
                              print("onPageChanged");
                              print(contentList![index]!.contentFormat);
                              print(contentList![index]!.duration);
                              if (contentList![index]!.contentFormat ==
                                  "WEB_VIEW") {
                                playAudio();
                              }
                              isScroll = true;

                              if (isShowTapAnim) {
                                isShowTapAnim = false;
                              }
                              if (isShowSwipeAnim) {
                                isShowSwipeAnim = false;
                                isShowTapAnim = true;
                                PreferenceUtils.setBool("isTapAnim", true);
                              }
                              setState(() {});
                              preloadVideos.onPageChanged(index);
                              preloadImages.onPageChanged(index);
                              userTrackingHelper!.saveUserEntries("feed_entry",
                                  contentList![pageCount].contentId!);
                            },
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, index) {
                              if (index == contentList!.length - 2 &&
                                  hasMoreData) {
                                print("nextPage");
                                getContentList(
                                    moodId, context); // Load more items
                              }
                              return Stack(
                                children: [
                                  InkWell(
                                    excludeFromSemantics: true,
                                    canRequestFocus: false,
                                    enableFeedback: false,
                                    splashFactory: NoSplash.splashFactory,
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    overlayColor: MaterialStateProperty.all(
                                        Colors.transparent),
                                    child: Stack(
                                      children: [
                                        buildContentView(index),
                                        Align(
                                          child: Container(
                                            color: Color(0x13131414)
                                                .withOpacity(0.2),
                                            height: double.infinity,
                                            child: Stack(
                                              children: [
                                                Align(
                                                  alignment:
                                                      Alignment.topCenter,
                                                  child: Container(
                                                    height: 300,
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        begin:
                                                            Alignment.topCenter,
                                                        end: Alignment
                                                            .bottomCenter,
                                                        colors: [
                                                          Color(0xFF100C10)
                                                              .withOpacity(0.4),
                                                          // 60%// 0%
                                                          Color(0x00100C10),
                                                          // 60%// 0%
                                                        ],
                                                        stops: [0.1, 0.9],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Align(
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  child: Container(
                                                    height: 320,
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        begin:
                                                            Alignment.topCenter,
                                                        end: Alignment
                                                            .bottomCenter,
                                                        colors: [
                                                          Color(0x00100C10),
                                                          Color(0xFF100C10)
                                                              .withOpacity(
                                                                  0.6), // 60%// 0%
                                                          // 60%// 0%
                                                        ],
                                                        stops: [0.1, 0.9],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                        ),
                                        (contentList![index].contentType ==
                                                "FEEDBACK")
                                            ? Container()
                                            : bottomView(index)
                                      ],
                                    ),
                                    onTap: () {
                                      print("clicked");
                                      handleTap(index);
                                    },
                                  ),
                                  buildSwipeAnimation()
                                ],
                              );
                            },
                          ),
                        )
                      : isContentListApiRunning && isClosedBottomSheet
                          ? Container(
                              child: Lottie.asset(
                                  "assets/images/feed_preloader.json"),
                            )
                          : Container()),
              buildLeftSearchBar(),
            ],
          ),
        ),
        onRefresh: () async {
          refreshFeed();
        },
      ),
    );
  }

  void handleTap(int index) {
    userTrackingHelper!
        .saveUserEntries("content_entry", contentList![index].contentId!);
    if (contentList![index].contentFormat == "VIDEO") {
      _phoneStateSubscription?.pause();
      isPlay = false;
      setState(() {});
      Navigator.pushNamed(context, HomeWidgetRoutes.VideoplayerWidget,
              arguments: {"url": contentList![index], "index": index})
          .then((value) => {
                _phoneStateSubscription?.resume(),
                updateVideoLastPosition(value, index)
              })
          .then((value) => {
                userTrackingHelper!.saveUserEntries(
                    "content_exit", contentList![index].contentId!)
              });
    } else if (contentList![index].contentType == "JOURNAL") {
      isPlay = false;
      _phoneStateSubscription?.pause();
      setState(() {});
      print(contentList![index].contentUrl!);
      Navigator.pushNamed(context, HomeWidgetRoutes.JournalWidget,
              arguments: {"url": contentList![index], "index": index})
          .then((value) => {
                userTrackingHelper!.saveUserEntries(
                    "content_exit", contentList![index].contentId!),
                isPlay = true,
                _phoneStateSubscription?.resume(),
                setState(() {})
              });
    } else if (contentList![index].contentType == "EMI" ||
        contentList![index].contentType == "INFO_TIDBITS" ||
        contentList![index].contentType == "INFO_TIDBITS_OCD" ||
        contentList![index].contentType == "INFO_TIDBITS_GENERAL") {
      _phoneStateSubscription?.pause();
      isPlay = false;
      setState(() {});
      print(contentList![index].contentUrl!);
      Navigator.pushNamed(context, HomeWidgetRoutes.EmiWidget,
              arguments: {"url": contentList![index], "index": index})
          .then((value) => {
                userTrackingHelper!.saveUserEntries(
                    "content_exit", contentList![index].contentId!),
                isPlay = true,
                _phoneStateSubscription?.resume(),
                setState(() {})
              });
    } else if (contentList![index].contentType == "ASSESSMENT") {
      Navigator.pushNamed(
          context, HomeWidgetRoutes.AssessmentWidget, arguments: {
        "url": contentList![index]
      }).then((value) => {
            userTrackingHelper!
                .saveUserEntries("content_exit", contentList![index].contentId!)
          });
    } else if (contentList![index].contentType == "FEEDBACK") {
      Navigator.pushNamed(
          context, HomeWidgetRoutes.AssessmentListWidget, arguments: {
        "url": contentList![index]
      }).then((value) => {
            userTrackingHelper!
                .saveUserEntries("content_exit", contentList![index].contentId!)
          });
    } else if (contentList![index].contentFormat == "AUDIO") {
      _phoneStateSubscription?.pause();
      isPlay = false;
      bIsPlay = false;
      setState(() {});
      Navigator.pushNamed(context, HomeWidgetRoutes.AudioPlayerWidget,
              arguments: {"url": contentList![index], "index": index})
          .then((value) => {
                userTrackingHelper!.saveUserEntries(
                    "content_exit", contentList![index].contentId!),
                _phoneStateSubscription?.resume(),
                updateAudioLastPosition(value, index)
              });
    } else {
      pauseAudio();
      Navigator.pushNamed(
          context, HomeWidgetRoutes.webScreenScreen, arguments: {
        "url": contentList![index]
      }).then((value) => {
            userTrackingHelper!.saveUserEntries(
                "content_exit", contentList![index].contentId!),
            playAudio()
          });
    }
  }

  void updateVideoController(int index, VideoPlayerController videoController) {
    preloadVideos.controllers[index] = videoController;
  }

  Widget buildContentView(int index) {
    if (contentList![index].contentType == "ASSESSMENT") {
      return ImageViewWidget(imageUrl: contentList![index].animations!);
    } else if (contentList![index].contentType == "FEEDBACK") {
      return Container(
        child: Container(
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                child: Image.asset("assets/images/feeback_img.png"),
                height: 60,
                width: 60,
              ),
              Container(
                margin: EdgeInsets.only(left: 15, top: 30),
                child: Text(
                  "Rate your experience",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: "Causten-Medium"),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 15, top: 10),
                child: Text(
                  "Your opinion means the world.\n Please share it with us",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color(0xff888888),
                      fontSize: 14,
                      fontFamily: "Causten-Regular"),
                ),
              ),
              GestureDetector(
                child: Container(
                  padding:
                      EdgeInsets.only(left: 15, top: 8, right: 15, bottom: 8),
                  margin: EdgeInsets.only(top: 25),
                  decoration: BoxDecoration(
                      color: Color(0xff40A1FB),
                      border: Border.all(color: Color(0xff40A1FB)),
                      borderRadius: BorderRadius.circular(30)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 8, top: 0),
                        child: Text(
                          "Give feedback",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontFamily: "Causten-Medium"),
                        ),
                      )
                    ],
                  ),
                ),
                onTap: () {
                  //showOpenFeedback();
                },
              )
            ],
          ),
        ),
      );
    }
    if (contentList![index].isVideoAudio ||
        contentList![index].contentFormat == "VIDEO") {
      return VideoWidget(
        updateVideoController: updateVideoController,
        key: Key('feed-item-$index'),
        isVisible: index == pageCount,
        id: contentList![index].contentId!,
        audioUrl: contentList![index].isVideoAudio
            ? contentList![index].audioURL
            : "",
        url: contentList![index].isVideoAudio
            ? contentList![index].videoURL!
            : contentList![index].contentUrl!,
        index: index,
        updatePosition: updateVideoPosition,
        isMute: isMute,
        isPlay: isPlay,
        duration: contentList![index].duration ?? Duration(seconds: 0),
        lastPosition: contentList![index].lastPositon ?? 0,
        isVideoAudio: contentList![index].isVideoAudio,
        videoPlayerController: preloadVideos.controllers.isNotEmpty
            ? preloadVideos.controllers[index] ?? null
            : null,
      );
    } else {
      return Align(
        alignment: Alignment.center,
        child: contentList![index].animations != null &&
                contentList![index].animations!.length > 10
            ? Container(
                child: LottieWidget(
                    animationJsonString: contentList![index].animations!),
                margin: EdgeInsets.only(bottom: 20),
              )
            : Container(),
      );
    }
  }

  Widget bottomView(int index) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  contentList![index].contentType != "ASSESSMENT" ||
                          (contentList![index].contentType == "FEEDBACK")
                      ? GestureDetector(
                          child: Container(
                            child: SvgPicture.asset(
                                isMute
                                    ? "assets/images/muted.svg"
                                    : "assets/images/mute.svg",
                                semanticsLabel: 'Acme Logo'),
                            margin: EdgeInsets.only(left: 0, bottom: 25),
                          ),
                          onTap: () {
                            isMute = !isMute!;
                            audioManager.setVolume(isMute);
                            setState(() {});
                          },
                        )
                      : Container(),
                  contentList![index].contentType == "ASSESSMENT"
                      ? Container()
                      : GestureDetector(
                          child: Container(
                            child: SvgPicture.asset(
                                "assets/images/SmilePlus.svg",
                                semanticsLabel: 'Acme Logo'),
                            margin: EdgeInsets.only(right: 4, bottom: 25),
                          ),
                          onTap: () {
                            showFeedbackDialog(contentList![index]);
                          },
                        ),
                  contentList![index].contentType != "ASSESSMENT"
                      ? InkWell(
                          child: Container(
                            child: !contentList![index].isFav
                                ? Icon(
                                    Icons.bookmark_border,
                                    color: Colors.white,
                                  )
                                : Icon(
                                    Icons.bookmark,
                                    color: Colors.white,
                                  ),
                            margin: EdgeInsets.only(right: 3, bottom: 25),
                          ),
                          onTap: () {
                            contentList![pageCount].isFav =
                                !contentList![pageCount].isFav;
                            updateFavoriteApi(
                                contentList![pageCount].contentId!,
                                contentList![pageCount].isFav);
                          },
                        )
                      : Container(),
                ],
              ),
              alignment: Alignment.topRight,
            ),
            contentList![index].contentType == "FEEDBACK"
                ? Container()
                : Container(
                    margin: EdgeInsets.only(bottom: 20),
                    child: Row(
                      children: [
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: TextScrollWidget(
                                text: contentList![index].contentType ==
                                        "ASSESSMENT"
                                    ? contentList![index]
                                        .assessmentList!
                                        .assessmentTitle!
                                    : contentList![index].contentName!,
                                scrollSpeed: pageCount == index ? 50 : 0,
                                shouldScroll: true,
                              ),
                            ),
                            contentList![index].hashtags.isNotEmpty
                                ? Container(
                                    margin: EdgeInsets.only(top: 5),
                                    child: SingleChildScrollView(
                                        child: Row(
                                          children: getHashTags(
                                              contentList![index].hashtags),
                                        ),
                                        scrollDirection: Axis.horizontal),
                                  )
                                : Container(),
                            contentList![index].contentType == "ASSESSMENT"
                                ? Container(
                                    child: Column(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(
                                              bottom: 10, top: 10),
                                          child: Row(
                                            children: [
                                              Container(
                                                child: SvgPicture.asset(
                                                    "assets/images/user_ass.svg"),
                                              ),
                                              Container(
                                                margin:
                                                    EdgeInsets.only(left: 10),
                                                child: Text(
                                                  "Take a self-assessment to curate a\n personalized experience within the app",
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Color(0xffF8F7F8),
                                                    fontFamily:
                                                        "Causten-Regular",
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(bottom: 10),
                                          child: Row(
                                            children: [
                                              Container(
                                                child: SvgPicture.asset(
                                                    "assets/images/target_ass.svg"),
                                              ),
                                              Container(
                                                margin:
                                                    EdgeInsets.only(left: 10),
                                                child: Text(
                                                  "Discover strategies that align with your\n interests and goals",
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Color(0xffF8F7F8),
                                                    fontFamily:
                                                        "Causten-Regular",
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                : Container(),
                            Container(
                              child: Row(
                                children: [
                                  Container(
                                    alignment: Alignment.topLeft,
                                    decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.3),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30))),
                                    child: Row(
                                      children: [
                                        Container(
                                          child: SvgPicture.asset(
                                            contentTypeImage(contentList![index]
                                                .contentType!
                                                .toLowerCase()),
                                            semanticsLabel: 'Acme Logo',
                                            width: 22,
                                            height: 22,
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ),
                                        Container(
                                          child: Text(
                                            getContentType(contentList![index]
                                                .contentType!),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontFamily: "Causten-Regular"),
                                          ),
                                          margin: EdgeInsets.only(
                                              left: 10, right: 10),
                                        ),
                                      ],
                                    ),
                                    margin: EdgeInsets.only(top: 0, left: 0),
                                    padding: EdgeInsets.only(
                                        left: 15, right: 15, top: 8, bottom: 8),
                                  ),
                                  Container(
                                    child: Text(
                                      contentList![index]!.contentDuration! +
                                          " min",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFFFFFFFF),
                                          fontFamily: "Causten-Regular"),
                                    ),
                                    margin: EdgeInsets.only(left: 10),
                                  )
                                ],
                              ),
                              margin: EdgeInsets.only(top: 5),
                            )
                          ],
                        )),
                        !((contentList![index].contentType == "GAME") ||
                                (contentList![index].contentType ==
                                    "JOURNAL") ||
                                (contentList![index].contentType == "EMI") ||
                                (contentList![index].contentType ==
                                    "INFO_TIDBITS") ||
                                (contentList![index].contentType ==
                                    "INFO_TIDBITS_OCD") ||
                                (contentList![index].contentType ==
                                    "INFO_TIDBITS_GENERAL") ||
                                (contentList![index].contentType ==
                                    "ASSESSMENT") ||
                                (contentList![index].contentType == "FEEDBACK"))
                            ? GestureDetector(
                                child: Container(
                                  child: SvgPicture.asset(
                                      isPlay
                                          ? "assets/images/pause.svg"
                                          : "assets/images/play.svg",
                                      semanticsLabel: 'Acme Logo'),
                                  margin: EdgeInsets.only(left: 0),
                                ),
                                onTap: () {
                                  isPlay = !isPlay;
                                  setState(() {});
                                },
                              )
                            : Container()
                      ],
                    ),
                  ),
          ],
        ),
        margin: EdgeInsets.only(left: 15, right: 15, bottom: 0),
      ),
    );
  }

  Widget buildSwipeAnimation() {
    return isShowSwipeAnim
        ? Align(
            child: Container(
            child: Container(
              color: Colors.black.withOpacity(0.8),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset("assets/images/swipe_up_anim.json",
                        repeat: true, height: 60),
                    Container(
                        child: Text(
                      "Swipe up",
                      style: TextStyle(
                          fontFamily: "Causten-Medium",
                          fontSize: 16,
                          color: Colors.white),
                      textAlign: TextAlign.center,
                    )),
                    Container(
                      child: Text("To see more experiences",
                          style: TextStyle(
                              fontFamily: "Causten-Regular",
                              fontSize: 14,
                              color: Colors.white),
                          textAlign: TextAlign.center),
                      margin: EdgeInsets.only(top: 5),
                    ),
                  ],
                ),
              ),
            ),
          ))
        : isShowTapAnim
            ? Container(
                child: Container(
                  child: Container(
                    color: Colors.black.withOpacity(0.8),
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset("assets/images/tap_anim.json",
                              repeat: true, height: 80),
                          Container(
                              child: Text(
                            "Tap on the screen",
                            style: TextStyle(
                                fontFamily: "Causten-Medium",
                                fontSize: 16,
                                color: Colors.white),
                            textAlign: TextAlign.center,
                          )),
                          Container(
                            child: Text("To enter your experience",
                                style: TextStyle(
                                    fontFamily: "Causten-Regular",
                                    fontSize: 14,
                                    color: Colors.white),
                                textAlign: TextAlign.center),
                            margin: EdgeInsets.only(top: 5),
                          ),
                          InkWell(
                            child: Container(
                              margin: EdgeInsets.only(top: 25),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border:
                                    Border.all(width: 1.0, color: Colors.white),
                                borderRadius: BorderRadius.all(Radius.circular(
                                        20.0) //                 <--- border radius here
                                    ),
                              ),
                              padding: EdgeInsets.only(
                                  left: 15, right: 15, top: 8, bottom: 8),
                              child: Text(
                                "Got it",
                                style: TextStyle(
                                    color: Color(0xFF2E292C),
                                    fontSize: 14,
                                    fontFamily: "Causten-Bold"),
                              ),
                            ),
                            onTap: () {
                              PreferenceUtils.setBool("isTapAnim", true);
                              isShowTapAnim = false;
                              setState(() {});
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : Container();
  }

  Widget buildLeftSearchBar() {
    return Container(
      margin: EdgeInsets.only(top: 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            child: Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    child: Container(
                      child: isHasTag
                          ? Icon(
                              Icons.arrow_back_ios_new_outlined,
                              size: 18,
                              color: Colors.white,
                            )
                          : SvgPicture.asset(
                              "assets/images/search.svg",
                              semanticsLabel: 'Acme Logo',
                              width: 18,
                              height: 18,
                              fit: BoxFit.scaleDown,
                            ),
                    ),
                    onTap: () {
                      if (isHasTag) {
                        isHasTag = false;
                        pauseAudio();
                        isSurpriseMe = false;
                        selectedPositive = 0;
                        moodName = bMoodName;
                        moodId = bMoodId;
                        currentPage = bCurrentPage;
                        bPageCount = pageCount;
                        hasMoreData = true;
                        contentList = [];
                        contentList!.addAll(bContentList!);
                        pageCount = bPageCount;
                        tempPageCount = pageCount;
                        _pageController!.jumpToPage(pageCount);
                        if (contentList![pageCount].contentFormat ==
                            "WEB_VIEW") {
                          playAudio();
                        }
                        preloadVideos.updateVideoList(contentList!);
                        preloadImages.updateVideoList(contentList!);
                        preloadVideos.onPageChanged(pageCount);
                        preloadImages.onPageChanged(pageCount);
                        setState(() {});
                      }
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 1.0, color: Colors.white),
                      ),
                    ),
                    child: Text(
                      moodName,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                          fontFamily: "Causten-Medium"),
                    ),
                    margin: EdgeInsets.only(left: 10, right: 10),
                  ),
                ],
              ),
              margin: EdgeInsets.only(top: 0, left: 15),
              padding:
                  EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
            ),
            onTap: () {
              isLoading = 0;
              selectedPositive = 0;
              textEditingController.text = "";
              moods = [];
              moods2 = [];

              if (isPositiveEmotion) {
                if (positiveMoods != null && positiveMoods!.isNotEmpty) {
                  moods!.addAll(positiveMoods!);
                  moods2!.addAll(positiveMoods2!);
                }
              } else {
                if (dMoods != null && dMoods!.isNotEmpty) {
                  moods!.addAll(dMoods!);
                  moods2!.addAll(dMoods2!);
                }
              }
              selectedMood = null;
              // setState(() {});
              _showEmotionModal();
            },
          ),
          InkWell(
            child: Container(
              padding: EdgeInsets.only(left: 15, right: 15, bottom: 6, top: 6),
              margin: EdgeInsets.only(right: 15, top: 5),
              child: Text(
                "Give feedback",
                style: TextStyle(
                    fontFamily: "Causten-Medium",
                    color: Colors.white,
                    fontSize: 14),
              ),
              decoration: BoxDecoration(
                  border: Border.all(color: Color(0xffECECEC), width: 1),
                  borderRadius: BorderRadius.circular(30)),
            ),
            onTap: () {
              showOpenFeedback(false);
            },
          )
        ],
      ),
    );
  }

  void refreshFeed() {
    isClosedBottomSheet = true;
    if (!Utility.isEmpty(
        PreferenceUtils.getString(PreferenceUtils.MOODID, ""))) {
      pauseAudio();
      isPlay = false;
      isFromInitState = false;
      currentPage = 1;
      bContentList = [];
      contentList = [];
      setState(() {});
      isRefreshFeed = true;
      getContentList(
          PreferenceUtils.getString(PreferenceUtils.MOODID, ""), context);
    }
  }

  void moveObjectToFirst(List<CollectionObject> list) {
    // Find the index of the object with the specified ID
    int index =
        list.indexWhere((element) => element.collectionName == "Your Library");

    // Check if the object is found
    if (index != -1) {
      // Remove the object from its current position
      var object = list.removeAt(index);
      // Insert the object at the beginning of the list
      list.insert(0, object);
    }
  }

  List<Widget> getHashTags(List<String> hashTagList) {
    List<Widget> listWidgets = [];
    if (hashTagList.isNotEmpty) {
      for (int i = 0; i < hashTagList.length; i++) {
        listWidgets.add(InkWell(
          child: Container(
            child: Text(
              "#" + hashTagList[i] + " ",
              style: TextStyle(
                  fontFamily: "Causten-Regular",
                  fontSize: 14,
                  color: Colors.white),
            ),
          ),
          onTap: () {
            pauseAudio();
            isSurpriseMe = false;
            selectedPositive = 0;
            bMoodName = moodName;
            moodName = "#" + hashTagList[i];
            bMoodId = moodId;
            bCurrentPage = currentPage;
            // PreferenceUtils.setString("moodName",  "#"+hashTagList[i]);
            currentPage = 1;
            bPageCount = pageCount;
            hasMoreData = true;
            bContentList = [];
            bContentList!.addAll(contentList!);
            contentList = [];
            setState(() {});
            getContentList("#" + hashTagList[i], context);
          },
        ));
      }
    }
    return listWidgets;
  }

  Future<void> getCollectionList() async {
    print("collectionApiRequest");
    print(DateTime.timestamp());
    ApiResponse? apiResponse = await apiHelper.getCollections();
    CollectionList sCollectionList = CollectionList.fromJson(apiResponse.data);
    print("collectionListResponse");
    print(DateTime.timestamp());
    collectionList = [];
    if (sCollectionList.collectionList!.isNotEmpty) {
      collectionList.addAll(sCollectionList.collectionList!);
      print("collectionList");
      print(collectionList.length);
      if (Utility.isEmpty(PreferenceUtils.getString("collectionID", ""))) {
        PreferenceUtils.setString(
            "collectionID", collectionList[0].collectionId!);
        PreferenceUtils.setString(
            "collectionName", collectionList[0].collectionName!);
      } else {
        if (collectionList
            .where((element) =>
                element.collectionId ==
                PreferenceUtils.getString("collectionID", ""))
            .toList()
            .isEmpty) {
          PreferenceUtils.setString(
              "collectionID", collectionList[0].collectionId!);
          PreferenceUtils.setString(
              "collectionName", collectionList[0].collectionName!);
        } else {
          CollectionObject collectionObject = collectionList
              .where((element) =>
                  element.collectionId ==
                  PreferenceUtils.getString("collectionID", ""))
              .toList()[0];
          PreferenceUtils.setString(
              "collectionName", collectionObject.collectionName!);
        }
      }
      // setState(() {});
    } else {
      createCollectionApi("Your Library");
    }
  }

  Future<void> updateFavoriteApi(String id, bool isFav) async {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    if (Utility.isEmpty(PreferenceUtils.getString("collectionID", ""))) {
      getCollectionList();
    } else {
      setState(() {});
      contentList![pageCount].collectionId = !isFav
          ? contentList![pageCount].collectionId
          : PreferenceUtils.getString("collectionID", "");
      contentList![pageCount].collectionName = !isFav
          ? contentList![pageCount].collectionName
          : PreferenceUtils.getString("collectionName", "");
      showSnackbar(contentList![pageCount].collectionName, isFav);

      ApiResponse? apiResponse = await apiHelper.updateFavorite(
          id,
          !isFav
              ? contentList![pageCount].collectionId
              : PreferenceUtils.getString("collectionID", ""),
          isFav);
      LoginResponse loginResponse = LoginResponse.fromJson(apiResponse.data);
      if (loginResponse.status == 200) {
      } else {
        contentList![pageCount].isFav = !isFav;
        setState(() {});
      }
    }
  }

  void showSnackbar(String collectionName, bool isFav) {
    int height = 180;
    if (Platform.isIOS) {
      height = 240;
    }
    final snackBar = SnackBar(
      backgroundColor: Colors.transparent,
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - height,
          right: 5,
          left: 5),
      content: PhysicalModel(
        color: Colors.white,
        elevation: 8,
        shape: BoxShape.circle,
        child: Container(
            padding:
                const EdgeInsets.only(left: 8, right: 8, top: 15, bottom: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0.0, 1.0), //(x,y)
                  blurRadius: 6.0,
                ),
              ],
            ),
            child: Row(
              children: [
                SvgPicture.asset("assets/images/CheckCircle.svg"),
                Expanded(
                    child: Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 10),
                      child: Text(isFav ? 'Saved to ' : "Removed from ",
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: "Causten-Regular",
                              fontSize: 14)),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 0),
                      child: Text(collectionName,
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: "Causten-Bold",
                              fontSize: 14)),
                    )
                  ],
                )),
                isFav
                    ? InkWell(
                        child: Container(
                          margin: EdgeInsets.only(right: 10),
                          child: Text('Change',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: "Causten-Medium",
                                  fontSize: 14)),
                        ),
                        onTap: () {
                          showFavModelSheet(context, isFav);
                        },
                      )
                    : Container(),
              ],
            )),
      ),
    );
    print("snackbar");
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void updateFavourite(value) {
    print("updateFavourite");
    print(value);
    if (value["isUpdated"] != null && value["isUpdated"]) {
      contentList![pageCount].isFav = true;
      contentList![pageCount].collectionName =
          PreferenceUtils.getString("collectionName", "");
      contentList![pageCount].collectionId =
          PreferenceUtils.getString("collectionID", "");
      showSnackbar(PreferenceUtils.getString("collectionName", ""), true);
    }
    if (value["cList"] != null) {
      collectionList = value["cList"];
    }

    setState(() {});
  }

  Future<void> createCollectionApi(String collectionName) async {
    print("createCollectionApi");
    print(DateTime.timestamp());
    ApiResponse? apiResponse =
        await apiHelper.createCollection(collectionName, "");
    CreateCollectionObject collectionObject =
        CreateCollectionObject.fromJson(apiResponse.data);
    print("createCollectionApiResponse");
    print(DateTime.timestamp());
    if (collectionObject.collectionObject != null) {
      if (collectionList.isEmpty) {
        PreferenceUtils.setString(
            "collectionID", collectionObject.collectionObject!.collectionId!);
        PreferenceUtils.setString("collectionName",
            collectionObject.collectionObject!.collectionName!);
      } else {
        if (collectionList
            .where((element) =>
                element.collectionId ==
                PreferenceUtils.getString("collectionID", ""))
            .toList()
            .isEmpty) {
          PreferenceUtils.setString(
              "collectionID", collectionList[0].collectionId!);
          PreferenceUtils.setString(
              "collectionName", collectionList[0].collectionName!);
        }
      }
      collectionList.add(collectionObject.collectionObject!);
    }
  }

  void getContentList(String id, ctx) async {
    print(currentPage);
    print("getContentList");
    if (moodId != id) {
      userTrackingHelper!.sendUserTrackingRequest();
    }
    PreferenceUtils.setBool("is_surprise", isSurpriseMe);
    moodId = id;
    if (!isFromInitState) {
      isContentListApiRunning = true;
    }
    if (!moodId.contains("#")) {
      isHasTag = false;
      PreferenceUtils.setString(PreferenceUtils.MOODID, id);
    } else {
      isHasTag = true;
      userTrackingHelper!.setHashTagName(moodId);
    }
    userTrackingHelper!.setHashTag(isHasTag);
    ApiResponse? apiResponse = null;
    if (moodId.contains("#") && !isSurpriseMe) {
      apiResponse = await apiHelper.getContentLists(
          id.replaceAll("#", ""), currentPage, isSurpriseMe, true);
    } else {
      if (moodId.length > 10 || isSurpriseMe) {
        apiResponse = await apiHelper.getContentLists(
            id, currentPage, isSurpriseMe, false);
      } else {
        apiResponse = await apiHelper.getContentListWithMoodName(
            id.toLowerCase(), currentPage);
      }
    }

    if (apiResponse.status == Status.COMPLETED) {
      ContentList cList = ContentList.fromJson(apiResponse.data);
      if (cList.contentList != null && cList.contentList!.isNotEmpty) {
        showSwipeAnim();
        contentList!.addAll(cList.contentList!);
        print(contentList!.length);
        print("contentList.length");
        hasMoreData = true; //cList.contentList!.length == pageSize;
        print(contentList!.length);

        currentPage++; // Prepare for next page request
        if (contentList!.length <= 10 && _pageController!.hasClients) {
          userTrackingHelper!
              .saveUserEntries("feed_entry", contentList![0].contentId!);
          if (isClosedBottomSheet) {
            isPlay = true;
          } else {
            isPlay = false;
          }
          pageCount = 0;
          tempPageCount = 0;
          _pageController?.jumpToPage(0);
          if (contentList![0].contentFormat == "WEB_VIEW" &&
              isClosedBottomSheet) {
            print("audio2");
            playAudio();
          }
          preloadVideos.init(contentList);
          preloadImages.init(contentList);
        } else {
          if (contentList!.length <= 10) {
            userTrackingHelper!
                .saveUserEntries("feed_entry", contentList![0].contentId!);
            print("isClosedBottomSheet");
            print(isClosedBottomSheet);
            if (isClosedBottomSheet) {
              isPlay = true;
            } else {
              isPlay = false;
            }
            pageCount = 0;
            tempPageCount = 0;
            if (contentList![0].contentFormat == "WEB_VIEW" &&
                isClosedBottomSheet) {
              print("audio2");
              playAudio();
            }
            preloadVideos.init(contentList);
            preloadImages.init(contentList);
          } else {
            preloadVideos.updateVideoList(contentList);
            preloadVideos.updateVideoList(contentList);
          }
        }
        //setState(() {});
      } else {
        hasMoreData = false;
        print(contentList);
        print("contentList123");
        if (contentList != null &&
            contentList!.isNotEmpty &&
            cList.emptyResponse) {
          currentPage = 1;
          getContentList(moodId, ctx);
        }
      }
    } else {
      hasMoreData = false;
    }
    isContentListApiRunning = false;

    if (!isClosedBottomSheet && !isFromInitState && !isRefreshFeed) {
      isPlay = true;
      Navigator.pop(context);
    }
    isRefreshFeed = false;
    isFromInitState = false;
    setState(() {});
  }

  void _showEmotionModal() {
    pauseAudio();
    bool isControl1 = false;
    // bool isControl2 = false;
    bool isControl3 = false;
    int showToolTip = 0;
    isContentListApiRunning = false;
    isPlay = false;
    isFullEmotion = false;
    isLoading = 0;
    selectedPositive = 0;
    selectedMood = null;
    textEditingController.text = "";
    setState(() {});
    isClosedBottomSheet = false;
    if (moods!.isNotEmpty) {
      isLoading = 2;
    }
    bool isShownTip = PreferenceUtils.getBool("is_shown_tip") ?? false;

    if (!isShownTip) {
      Future.delayed(Duration(milliseconds: 1000), () {
        _focusNode.unfocus();
        PreferenceUtils.setBool("is_shown_tip", true);
        controller1!.showTooltip();
      });
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withOpacity(0.1),
      isScrollControlled: true,
      isDismissible:
          (contentList != null && contentList!.isNotEmpty) || (isFromInitState),
      enableDrag: contentList != null && contentList!.isNotEmpty,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context, setState) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 5.0,
                    sigmaY: 5.0,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.2),
                          Color(0xff131314).withOpacity(0.4),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      backgroundBlendMode: BlendMode.lighten,
                    ),
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize:
                                MainAxisSize.min, // To fit content size
                            children: <Widget>[
                              // The downward arrow icon
                              /*  Container(
                      child: Image.asset("assets/images/indicator1.png"),
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(top: 5),
                    ),*/
                              Container(
                                margin: EdgeInsets.only(
                                    left: 15, right: 15, top: 30),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      child: Container(
                                          child: SvgPicture.asset(
                                        "assets/images/Info.svg",
                                        color: showToolTip == 3 ||
                                                showToolTip == 2 ||
                                                showToolTip == 1
                                            ? Color(0xF8F7F8).withOpacity(0.2)
                                            : null,
                                      )),
                                      onTap: () {
                                        _focusNode.unfocus();
                                        controller1!.showTooltip();
                                      },
                                    ),
                                    SuperTooltip(
                                      left: 45,
                                      barrierColor:
                                          Color.fromARGB(26, 47, 45, 47),
                                      right: 10,
                                      arrowTipDistance: 19.0,
                                      arrowBaseWidth: 15.0,
                                      arrowLength: 8.0,
                                      borderWidth: 2.0,
                                      onHide: () {
                                        print("hide");
                                        if (!isControl3) {
                                          _focusNode.requestFocus();
                                          showToolTip = 0;
                                          setState(() {});
                                        }
                                        isControl3 = false;
                                      },
                                      controller: controller3,
                                      onShow: () {
                                        showToolTip = 3;
                                        setState(() {});
                                      },
                                      hideTooltipOnTap: true,
                                      showBarrier: true,
                                      popupDirection: TooltipDirection.left,
                                      child: GestureDetector(
                                          child: SvgPicture.asset(
                                            "assets/images/Button_Light.svg",
                                            color: showToolTip == 2 ||
                                                    showToolTip == 1
                                                ? Color(0xF8F7F8)
                                                    .withOpacity(0.2)
                                                : null,
                                          ),
                                          onTap: () {
                                            if (!isContentListApiRunning) {
                                              isSurpriseMe = true;
                                              isFromInitState = false;
                                              selectedPositive = 0;
                                              moodName = "Surprise me";
                                              PreferenceUtils.setString(
                                                  "moodName", moodName);
                                              currentPage = 1;
                                              hasMoreData = true;
                                              contentList = [];
                                              setState(() {});
                                              getContentList(moodId, context);
                                            }
                                          }),
                                      content: Container(
                                        height: 110,
                                        child: Column(
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(
                                                  left: 5,
                                                  right: 10,
                                                  bottom: 10),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Container(
                                                    child: Text("2/2",
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFF888888),
                                                            fontSize: 12,
                                                            fontFamily:
                                                                "Causten-Medium")),
                                                  ),
                                                  GestureDetector(
                                                    child: Container(
                                                      child: SvgPicture.asset(
                                                          "assets/images/x.svg"),
                                                    ),
                                                    onTap: () {
                                                      controller3!
                                                          .hideTooltip();
                                                    },
                                                  )
                                                ],
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(left: 5),
                                              child: Text(
                                                "Not sure what you're looking for? Tap  the dice icon for a surprise scenario!",
                                                style: TextStyle(
                                                    color: Color(0xff131314),
                                                    fontSize: 14,
                                                    fontFamily:
                                                        "Causten-Regular"),
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(top: 5),
                                              alignment: Alignment.topRight,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  GestureDetector(
                                                    child: SvgPicture.asset(
                                                        "assets/images/btn1.svg"),
                                                    onTap: () {
                                                      isControl3 = true;
                                                      controller3!
                                                          .hideTooltip();
                                                      controller1!
                                                          .showTooltip();
                                                    },
                                                  ),
                                                  GestureDetector(
                                                    child: Container(
                                                      child: SvgPicture.asset(
                                                          "assets/images/btn3.svg"),
                                                      margin: EdgeInsets.only(
                                                          left: 5, right: 5),
                                                    ),
                                                    onTap: () {
                                                      controller3!
                                                          .hideTooltip();
                                                    },
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(height: 10),
                              // The text: "What's weighing you down?"

                              Container(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    SuperTooltip(
                                      left: 45,
                                      onShow: () {
                                        showToolTip = 2;
                                        setState(() {});
                                      },
                                      barrierColor:
                                          Color.fromARGB(26, 47, 45, 47),
                                      right: 55,
                                      arrowTipDistance: 22.0,
                                      arrowBaseWidth: 15.0,
                                      arrowLength: 8.0,
                                      borderWidth: 2.0,
                                      controller: controller1,
                                      onHide: () {
                                        if (!isControl1) {
                                          controller3!.showTooltip();
                                        }
                                        isControl1 = false;
                                      },
                                      popupDirection: TooltipDirection.up,
                                      showBarrier: true,
                                      child: MenuAnchor(
                                        alignmentOffset: Offset(0, 0),
                                        style: MenuStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Color(0xFF1A1A1A)),
                                          shape: MaterialStateProperty.all(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                            ),
                                          ),
                                        ),
                                        controller: _iFeelMenuController,
                                        onOpen: () {
                                          isOpenFeelDialog = true;
                                          setState(() {});
                                        },
                                        menuChildren: [
                                          MenuItemButton(
                                            onPressed: () {
                                              isPositiveEmotion = false;
                                              onIfeelMenuButtonPressed();
                                              setState(() {});
                                            },
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty
                                                      .resolveWith<Color?>(
                                                          (states) {
                                                if (states.contains(
                                                    MaterialState.pressed)) {
                                                  return Color(
                                                      0xFF272727); // Background when pressed
                                                }
                                                return null; // Default background
                                              }),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 16),
                                              child: Text(
                                                'I feel',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'Causten-Medium',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  height: 20 / 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                          MenuItemButton(
                                            onPressed: () {
                                              isPositiveEmotion = true;
                                              onIfeelMenuButtonPressed();
                                              setState(() {});
                                            },
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty
                                                      .resolveWith<Color?>(
                                                          (states) {
                                                if (states.contains(
                                                    MaterialState.pressed)) {
                                                  return Color(
                                                      0xFF272727); // Background when pressed
                                                }
                                                return null; // Default background
                                              }),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 16),
                                              child: Text(
                                                'I want to feel',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'Causten-Medium',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  height: 20 / 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                        builder: (context, controller, child) {
                                          return InkWell(
                                            child: Container(
                                              child: Row(
                                                children: [
                                                  Text(
                                                    isPositiveEmotion
                                                        ? "I want to feel"
                                                        : "I feel",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 24,
                                                        fontFamily:
                                                            "Causten-Regular",
                                                        color: showToolTip ==
                                                                    1 ||
                                                                showToolTip == 3
                                                            ? Color(0xF8F7F8)
                                                                .withOpacity(
                                                                    0.2)
                                                            : Colors.white),
                                                  ),
                                                  Container(
                                                      child: SvgPicture.asset(
                                                          isOpenFeelDialog
                                                              ? "assets/images/caretUp.svg"
                                                              : "assets/images/cartDown.svg"),
                                                      margin: EdgeInsets.only(
                                                          left: 3))
                                                ],
                                              ),
                                              alignment: Alignment.center,
                                              margin: EdgeInsets.only(top: 10),
                                            ),
                                            onTap: () {
                                              controller.open();
                                            },
                                          );
                                        },
                                      ),
                                      content: Container(
                                        height: 130,
                                        child: Column(
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(
                                                  left: 5,
                                                  right: 10,
                                                  bottom: 10),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Container(
                                                    child: Text(
                                                      "1/2",
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xFF888888),
                                                          fontSize: 12,
                                                          fontFamily:
                                                              "Causten-Medium"),
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    child: Container(
                                                      child: SvgPicture.asset(
                                                          "assets/images/x.svg"),
                                                    ),
                                                    onTap: () {
                                                      isControl1 = false;
                                                      controller1!
                                                          .hideTooltip();
                                                    },
                                                  )
                                                ],
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(left: 0),
                                              child: Text(
                                                "Type in your issue or choose from the suggestions below, and we'll craft  experiences to help you.",
                                                style: TextStyle(
                                                    color: Color(0xff131314),
                                                    fontSize: 14,
                                                    fontFamily:
                                                        "Causten-Regular"),
                                              ),
                                            ),
                                            Container(
                                              alignment: Alignment.topRight,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  GestureDetector(
                                                    child: SvgPicture.asset(
                                                        "assets/images/btn4.svg"),
                                                    onTap: () {},
                                                  ),
                                                  GestureDetector(
                                                    child: Container(
                                                      child: SvgPicture.asset(
                                                          "assets/images/btn2.svg"),
                                                      margin: EdgeInsets.only(
                                                          left: 5, right: 5),
                                                    ),
                                                    onTap: () {
                                                      isControl1 = true;
                                                      controller1!
                                                          .hideTooltip();
                                                      controller3!
                                                          .showTooltip();
                                                    },
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        margin:
                                            EdgeInsets.only(left: 5, bottom: 0),
                                        width: isPositiveEmotion ? 155 : 180,
                                        child: ConstrainedBox(
                                          constraints:
                                              BoxConstraints(minWidth: 30),
                                          child: IntrinsicWidth(
                                            child: TextField(
                                              controller: textEditingController,
                                              onChanged: (text) {
                                                text = text.trim();
                                                if (text.length >= 3) {
                                                  Future.delayed(
                                                      Duration(
                                                          milliseconds: 500),
                                                      () async {
                                                    loadDefaultMoods();
                                                    isLoading = 1;
                                                    setState(() {});
                                                    //LoadingUtils.instance.showLoadingIndicator("Receiving...", context);
                                                    ApiResponse apiResponse =
                                                        await apiHelper
                                                            .getPromptNames(
                                                                text,
                                                                isPositiveEmotion);
                                                    isLoading = 0;
                                                    setState(() {});
                                                    // LoadingUtils.instance.hideOpenDialog(context);
                                                    print("apiResponse.status");
                                                    print(apiResponse.status);
                                                    if (apiResponse.status ==
                                                        Status.COMPLETED) {
                                                      ResponseModel
                                                          responseModel =
                                                          ResponseModel
                                                              .fromJson(
                                                                  apiResponse
                                                                      .data,
                                                                  text);
                                                      print(
                                                          responseModel.status);
                                                      if (responseModel
                                                              .status ==
                                                          200) {
                                                        if (responseModel.moods != null &&
                                                            responseModel
                                                                    .moods !=
                                                                null &&
                                                            responseModel.moods!
                                                                .isNotEmpty) {
                                                          isFullEmotion =
                                                              responseModel
                                                                  .isShow;
                                                          List<Mood> cluster =
                                                              responseModel
                                                                  .moods!;
                                                          moods = [];
                                                          moods2 = [];
                                                          isLoading = 2;
                                                          print("moods.length");
                                                          print(isLoading);

                                                          print(
                                                              cluster!.length);
                                                          for (int i = 0;
                                                              i <
                                                                  cluster!
                                                                      .length;
                                                              i++) {
                                                            if (i % 2 == 0) {
                                                              moods!.add(
                                                                  cluster![i]);
                                                            } else {
                                                              moods2!.add(
                                                                  cluster![i]);
                                                            }
                                                          }
                                                          if (textEditingController
                                                                  .text.length <
                                                              3) {
                                                            moods = [];
                                                            moods2 = [];
                                                            if (isPositiveEmotion) {
                                                              if (positiveMoods !=
                                                                      null &&
                                                                  positiveMoods!
                                                                      .isNotEmpty) {
                                                                moods!.addAll(
                                                                    positiveMoods!);
                                                                moods2!.addAll(
                                                                    positiveMoods2!);
                                                              }
                                                            } else {
                                                              if (dMoods !=
                                                                      null &&
                                                                  dMoods!
                                                                      .isNotEmpty) {
                                                                moods!.addAll(
                                                                    dMoods!);
                                                                moods2!.addAll(
                                                                    dMoods2!);
                                                              }
                                                            }
                                                          }
                                                          setState(() {});
                                                        } else {
                                                          isLoading = 3;
                                                          moods = [];
                                                          moods2 = [];
                                                          print("no result");
                                                          if (isPositiveEmotion) {
                                                            if (positiveMoods !=
                                                                    null &&
                                                                positiveMoods!
                                                                    .isNotEmpty) {
                                                              moods!.addAll(
                                                                  positiveMoods!);
                                                              moods2!.addAll(
                                                                  positiveMoods2!);
                                                            }
                                                          } else {
                                                            if (dMoods !=
                                                                    null &&
                                                                dMoods!
                                                                    .isNotEmpty) {
                                                              moods!.addAll(
                                                                  dMoods!);
                                                              moods2!.addAll(
                                                                  dMoods2!);
                                                            }
                                                          }
                                                          if (textEditingController
                                                                  .text.length <
                                                              3) {
                                                            isLoading = 2;
                                                          }
                                                          setState(() {});
                                                        }
                                                      } else {
                                                        isLoading = 3;
                                                        moods = [];
                                                        moods2 = [];
                                                        if (textEditingController
                                                                .text.length <
                                                            3) {
                                                          isLoading = 2;
                                                        }

                                                        if (isPositiveEmotion) {
                                                          if (positiveMoods !=
                                                                  null &&
                                                              positiveMoods!
                                                                  .isNotEmpty) {
                                                            moods!.addAll(
                                                                positiveMoods!);
                                                            moods2!.addAll(
                                                                positiveMoods2!);
                                                          }
                                                        } else {
                                                          if (dMoods != null &&
                                                              dMoods!
                                                                  .isNotEmpty) {
                                                            moods!.addAll(
                                                                dMoods!);
                                                            moods2!.addAll(
                                                                dMoods2!);
                                                          }
                                                        }
                                                        setState(() {});
                                                      }
                                                    } else {
                                                      isLoading = 3;
                                                      setState(() {});
                                                      Utility.showSnackBar(
                                                          context: context,
                                                          message: apiResponse
                                                              .message
                                                              .toString());
                                                      moods = [];
                                                      moods2 = [];

                                                      if (isPositiveEmotion) {
                                                        if (positiveMoods !=
                                                                null &&
                                                            positiveMoods!
                                                                .isNotEmpty) {
                                                          moods!.addAll(
                                                              positiveMoods!);
                                                          moods2!.addAll(
                                                              positiveMoods2!);
                                                        }
                                                      } else {
                                                        if (dMoods != null &&
                                                            dMoods!
                                                                .isNotEmpty) {
                                                          moods!
                                                              .addAll(dMoods!);
                                                          moods2!
                                                              .addAll(dMoods2!);
                                                        }
                                                      }
                                                      setState(() {});
                                                    }
                                                  });
                                                } else {
                                                  isLoading = 2;
                                                  moods = [];
                                                  moods2 = [];

                                                  if (isPositiveEmotion) {
                                                    if (positiveMoods != null &&
                                                        positiveMoods!
                                                            .isNotEmpty) {
                                                      moods!.addAll(
                                                          positiveMoods!);
                                                      moods2!.addAll(
                                                          positiveMoods2!);
                                                    }
                                                  } else {
                                                    if (dMoods != null &&
                                                        dMoods!.isNotEmpty) {
                                                      moods!.addAll(dMoods!);
                                                      moods2!.addAll(dMoods2!);
                                                    }
                                                  }
                                                  setState(() {});
                                                }
                                              },
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  decorationThickness: 0,
                                                  color: Color(0xF8F7F8)
                                                      .withOpacity(0.9),
                                                  decoration:
                                                      TextDecoration.none,
                                                  fontSize: 24,
                                                  fontFamily:
                                                      "Causten-Regular"),
                                              cursorColor: Colors.white,
                                              enabled: !isContentListApiRunning,
                                              showCursor: true,
                                              autofocus: isShownTip,
                                              focusNode: _focusNode,
                                              decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  enabledBorder:
                                                      UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.white
                                                            .withOpacity(0.4)),
                                                  ),
                                                  focusedBorder:
                                                      UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.white
                                                            .withOpacity(0.4)),
                                                  ),
                                                  contentPadding:
                                                      EdgeInsets.only(
                                                          bottom: 6),
                                                  hintStyle: TextStyle(
                                                      fontSize: 24,
                                                      color: Colors.white
                                                          .withOpacity(0.4),
                                                      fontFamily:
                                                          "Causten-Regular"),
                                                  hintText: ""),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                alignment: Alignment.center,
                                margin: EdgeInsets.only(left: 20, right: 20),
                              ),
                              isLoading == 3
                                  ? Container(
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.only(
                                          left: 15, right: 15, top: 10),
                                      padding: EdgeInsets.only(
                                          left: 10,
                                          right: 10,
                                          top: 10,
                                          bottom: 10),
                                      decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            child: Image.asset(
                                              "assets/images/Info1.png",
                                              width: 18,
                                              height: 18,
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(left: 10),
                                            child: Text(
                                              "Sorry, we couldn’t find this emotion. Can you \npick something close from the list below?",
                                              softWrap: true,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: "Causten-Regular",
                                                  fontSize: 14),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  : Container(),
                              SizedBox(height: 25),
                              // Emotion buttons will go here...
                              // Your button list...

                              SingleChildScrollView(
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      isLoading == 1 ||
                                              isLoading == 2 ||
                                              isLoading == 3
                                          ? isLoading == 1
                                              ? Shimmer.fromColors(
                                                  enabled: isLoading == 1
                                                      ? true
                                                      : false,
                                                  baseColor: isLoading == 1
                                                      ? Color(0xF8F7F8)
                                                          .withOpacity(0.2)
                                                      : Colors.white,
                                                  // Base color of the shimmer
                                                  highlightColor: Colors.white,
                                                  // Highlight color of the shimmer
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: moods!
                                                        .map(
                                                            (e) =>
                                                                GestureDetector(
                                                                  child: Stack(
                                                                    children: [
                                                                      Container(
                                                                        padding: EdgeInsets.only(
                                                                            left:
                                                                                12,
                                                                            right:
                                                                                12,
                                                                            top:
                                                                                10,
                                                                            bottom:
                                                                                10),
                                                                        margin: EdgeInsets.only(
                                                                            bottom:
                                                                                10,
                                                                            right:
                                                                                10),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color: isLoading == 1
                                                                              ? Color(0xF8F7F8).withOpacity(0.9)
                                                                              : (e.moodName == textEditingController.text.trim() && isFullEmotion)
                                                                                  ? Colors.white
                                                                                  : null,
                                                                          borderRadius:
                                                                              BorderRadius.all(Radius.circular(30)),
                                                                          border: showToolTip == 3 || showToolTip == 2 || showToolTip == 1
                                                                              ? Border.all(color: Color(0xF8F7F8).withOpacity(0.2), width: 0.5)
                                                                              : isLoading == 1
                                                                                  ? Border.all(
                                                                                      color: Color(0xD9D9D9),
                                                                                    )
                                                                                  : (e.moodName == textEditingController.text.trim() && isFullEmotion)
                                                                                      ? Border.all(
                                                                                          color: Colors.white,
                                                                                        )
                                                                                      : Border.all(
                                                                                          color: Color(0xF8F7F8).withOpacity(0.2),
                                                                                        ),
                                                                        ),
                                                                        child:
                                                                            Text(
                                                                          e.moodName!,
                                                                          style: TextStyle(
                                                                              color: showToolTip == 3 || showToolTip == 2 || showToolTip == 1
                                                                                  ? Color(0xF8F7F8).withOpacity(0.2)
                                                                                  : isLoading == 1
                                                                                      ? Color(0xF8F7F8).withOpacity(0.2)
                                                                                      : (e.moodName == textEditingController.text.trim() && isFullEmotion)
                                                                                          ? Color(0xff131314)
                                                                                          : Color(0xFFF8F7F8),
                                                                              fontSize: 14,
                                                                              fontFamily: "Causten-Regular"),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  onTap: () {
                                                                    if (!isContentListApiRunning) {
                                                                      isFromInitState =
                                                                          false;
                                                                      isSurpriseMe =
                                                                          false;
                                                                      selectedPositive =
                                                                          0;
                                                                      selectedMood =
                                                                          e;
                                                                      moodName =
                                                                          selectedMood!
                                                                              .moodName!;
                                                                      PreferenceUtils.setString(
                                                                          "moodName",
                                                                          selectedMood!
                                                                              .moodName!);
                                                                      currentPage =
                                                                          1;
                                                                      hasMoreData =
                                                                          true;
                                                                      contentList =
                                                                          [];
                                                                      setState(
                                                                          () {});
                                                                      getContentList(
                                                                          selectedMood!
                                                                              .moodClusterId!,
                                                                          context);
                                                                    }
                                                                  },
                                                                ))
                                                        .toList(),
                                                  ),
                                                )
                                              : Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: moods!
                                                      .map(
                                                          (e) =>
                                                              GestureDetector(
                                                                child: Stack(
                                                                  children: [
                                                                    Container(
                                                                      padding: EdgeInsets.only(
                                                                          left:
                                                                              12,
                                                                          right:
                                                                              12,
                                                                          top:
                                                                              10,
                                                                          bottom:
                                                                              10),
                                                                      margin: EdgeInsets.only(
                                                                          bottom:
                                                                              10,
                                                                          right:
                                                                              10),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: isLoading ==
                                                                                1
                                                                            ? Color(0xF8F7F8).withOpacity(0.9)
                                                                            : (e.moodName == textEditingController.text.trim() && isFullEmotion)
                                                                                ? null
                                                                                : null,
                                                                        borderRadius:
                                                                            BorderRadius.all(Radius.circular(30)),
                                                                        border: showToolTip == 3 ||
                                                                                showToolTip == 2 ||
                                                                                showToolTip == 1
                                                                            ? Border.all(color: Color(0xF8F7F8).withOpacity(0.2), width: 0.5)
                                                                            : isLoading == 1
                                                                                ? Border.all(
                                                                                    color: Color(0xD9D9D9),
                                                                                  )
                                                                                : (e.moodName == textEditingController.text.trim() && isFullEmotion)
                                                                                    ? Border.all(
                                                                                        color: Color(0xff40A1FB),
                                                                                      )
                                                                                    : Border.all(
                                                                                        color: Color(0xF8F7F8).withOpacity(0.2),
                                                                                      ),
                                                                      ),
                                                                      child:
                                                                          Text(
                                                                        e.moodName!,
                                                                        style: TextStyle(
                                                                            color: showToolTip == 3 || showToolTip == 2 || showToolTip == 1
                                                                                ? Color(0xF8F7F8).withOpacity(0.2)
                                                                                : isLoading == 1
                                                                                    ? Color(0xF8F7F8).withOpacity(0.2)
                                                                                    : /*(e.moodName == textEditingController.text.trim() && isFullEmotion)
                                                                                        ? Color(0xff131314)
                                                                                        : */
                                                                                    Color(0xFFF8F7F8),
                                                                            fontSize: 14,
                                                                            fontFamily: "Causten-Regular"),
                                                                      ),
                                                                    ),
                                                                    (e.moodName ==
                                                                                textEditingController.text.trim() &&
                                                                            isFullEmotion)
                                                                        ? Positioned(
                                                                            bottom:
                                                                                9,
                                                                            right:
                                                                                9,
                                                                            child:
                                                                                Container(
                                                                              width: 16,
                                                                              height: 16,
                                                                              decoration: BoxDecoration(
                                                                                color: Color(0xff40A1FB),
                                                                                shape: BoxShape.circle,
                                                                                border: Border.all(color: Colors.black, width: 2),
                                                                              ),
                                                                              child: Icon(
                                                                                Icons.check,
                                                                                size: 8,
                                                                                color: Colors.black,
                                                                              ),
                                                                            ),
                                                                          )
                                                                        : Container(),
                                                                  ],
                                                                ),
                                                                onTap: () {
                                                                  if (!isContentListApiRunning) {
                                                                    isFromInitState =
                                                                        false;
                                                                    isSurpriseMe =
                                                                        false;
                                                                    selectedPositive =
                                                                        0;
                                                                    selectedMood =
                                                                        e;
                                                                    moodName =
                                                                        selectedMood!
                                                                            .moodName!;
                                                                    PreferenceUtils.setString(
                                                                        "moodName",
                                                                        selectedMood!
                                                                            .moodName!);
                                                                    currentPage =
                                                                        1;
                                                                    hasMoreData =
                                                                        true;
                                                                    contentList =
                                                                        [];
                                                                    setState(
                                                                        () {});
                                                                    getContentList(
                                                                        selectedMood!
                                                                            .moodClusterId!,
                                                                        context);
                                                                  }
                                                                },
                                                              ))
                                                      .toList(),
                                                )
                                          : Container(),
                                      isLoading == 1 ||
                                              isLoading == 2 ||
                                              isLoading == 3
                                          ? Shimmer.fromColors(
                                              enabled:
                                                  isLoading == 1 ? true : false,
                                              baseColor: isLoading == 1
                                                  ? Color(0xF8F7F8)
                                                      .withOpacity(0.2)
                                                  : Colors.white,
                                              // Base color of the shimmer
                                              highlightColor: Colors.white,
                                              // Highlight color of the shimmer
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: moods2!
                                                    .map((e) => GestureDetector(
                                                          child: Container(
                                                            child: Container(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 12,
                                                                      right: 12,
                                                                      top: 10,
                                                                      bottom:
                                                                          10),
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      bottom:
                                                                          10,
                                                                      right:
                                                                          10),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: isLoading ==
                                                                        1
                                                                    ? Color(0xF8F7F8)
                                                                        .withOpacity(
                                                                            0.9)
                                                                    : null,
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            30)),
                                                                border: showToolTip == 3 ||
                                                                        showToolTip ==
                                                                            2 ||
                                                                        showToolTip ==
                                                                            1
                                                                    ? Border.all(
                                                                        color: Color(0xF8F7F8).withOpacity(
                                                                            0.2),
                                                                        width:
                                                                            0.5)
                                                                    : isLoading ==
                                                                            1
                                                                        ? Border
                                                                            .all(
                                                                            color:
                                                                                Color(0xD9D9D9),
                                                                          )
                                                                        : Border
                                                                            .all(
                                                                            color:
                                                                                Color(0xF8F7F8).withOpacity(0.2),
                                                                          ),
                                                              ),
                                                              child: Text(
                                                                e.moodName!,
                                                                style: TextStyle(
                                                                    color: showToolTip == 3 || showToolTip == 2 || showToolTip == 1
                                                                        ? Color(0xF8F7F8).withOpacity(0.2)
                                                                        : isLoading != 1
                                                                            ? Color(0xFFF8F7F8)
                                                                            : Color(0xF8F7F8).withOpacity(0.2),
                                                                    fontSize: 14,
                                                                    fontFamily: "Causten-Regular"),
                                                              ),
                                                            ),
                                                          ),
                                                          onTap: () {
                                                            if (!isContentListApiRunning) {
                                                              isFromInitState =
                                                                  false;
                                                              selectedPositive =
                                                                  0;
                                                              selectedMood = e;
                                                              isSurpriseMe =
                                                                  false;
                                                              moodName =
                                                                  selectedMood!
                                                                      .moodName!;
                                                              PreferenceUtils.setString(
                                                                  "moodName",
                                                                  selectedMood!
                                                                      .moodName!);
                                                              currentPage = 1;
                                                              hasMoreData =
                                                                  true;
                                                              contentList = [];
                                                              setState(() {});
                                                              getContentList(
                                                                  selectedMood!
                                                                      .moodClusterId!,
                                                                  context);
                                                            }
                                                          },
                                                        ))
                                                    .toList(),
                                              ),
                                            )
                                          : Container(),
                                    ],
                                  ),
                                  margin: EdgeInsets.only(left: 15),
                                ),
                                scrollDirection: Axis.horizontal,
                              ),
                              SizedBox(height: 10),

                              InkWell(
                                excludeFromSemantics: true,
                                canRequestFocus: false,
                                enableFeedback: false,
                                splashFactory: NoSplash.splashFactory,
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                overlayColor: MaterialStateProperty.all(
                                    Colors.transparent),
                                child: Container(
                                  child: Container(
                                    width: 45,
                                    height: 45,
                                    child: Icon(Icons.done,
                                        color: isFullEmotion
                                            ? Colors.black
                                            : Color(0xffB0B0B0),
                                        size: 20),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isFullEmotion
                                          ? Color(0xff40A1FB)
                                          : Color(0xff6D6D6D),
                                    ),
                                  ),
                                  margin:
                                      EdgeInsets.only(bottom: 10, right: 10),
                                  alignment: Alignment.bottomRight,
                                ),
                                onTap: () {
                                  if (!isContentListApiRunning &&
                                      isFullEmotion) {
                                    isFromInitState = false;
                                    selectedPositive = 1;
                                    isSurpriseMe = false;
                                    contentList = [];
                                    moodName =
                                        textEditingController.text.toString();
                                    PreferenceUtils.setString("moodName",
                                        textEditingController.text.toString());
                                    currentPage = 1;
                                    hasMoreData = true;
                                    setState(() {});
                                    getContentList(
                                        textEditingController.text.toString(),
                                        context); //bce2fa1b-d000-4fe2-be34-5984855cacab
                                  }
                                },
                              )
                              // Slider goes here...
                            ],
                          ),
                        ),
                        isContentListApiRunning
                            ? Positioned(
                                top: 0,
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 100,
                                  width: 100,
                                  margin: EdgeInsets.all(5),
                                  child: Center(
                                      child: Lottie.asset(
                                          "assets/images/feed_preloader.json",
                                          height: 100,
                                          width:
                                              100)) /*CircularProgressIndicator(
                                      strokeWidth: 2.0,
                                      valueColor:
                                          AlwaysStoppedAnimation(Colors.white),
                                    )*/
                                  ,
                                ),
                              )
                            : Container(
                                height: 0,
                              )
                      ],
                    ),
                  ),
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                )),
          );
        });
      },
    ).then((value) => {
          if (contentList != null && contentList!.isNotEmpty)
            {
              isPlay = true,
              setState(() {}),
              isClosedBottomSheet = true,
              if (pageCount < contentList!.length &&
                  contentList![pageCount].contentFormat == "WEB_VIEW")
                {print("audio1"), playAudio()}
            }
          else
            {
              moods = [],
              moods2 = [],
              if (isPositiveEmotion)
                {
                  if (positiveMoods != null && positiveMoods!.isNotEmpty)
                    {
                      moods!.addAll(positiveMoods!),
                      moods2!.addAll(positiveMoods2!)
                    }
                }
              else
                {
                  if (dMoods != null && dMoods!.isNotEmpty)
                    {moods!.addAll(dMoods!), moods2!.addAll(dMoods2!)}
                },
              _showEmotionModal()
            }
        });
  }

  void showOpenFeedback(bool isWeekly) {
    bIsPlay = isPlay;
    isPlay = false;
    pauseAudio();
    setState(() {});
    showModalBottomSheet(
        context: context,
        backgroundColor: Color(0xff131314),
        isScrollControlled: true,
        barrierColor: Colors.transparent,
        isDismissible: false,
        builder: (BuildContext context) {
          return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: OpenFeedBackWidget(isWeekly: isWeekly));
        }).then((value) => {updateOpenFeedback(value, isWeekly)});
  }

  void updateOpenFeedback(value, bool isWeekly) {
    print("updateOpenFeedback");
    print(value);
    if (value != value["success"]) {
      showFeedbackSuccessDialog(isWeekly);
    } else {
      if (!isWeekly) {
        if (bIsPlay) {
          isPlay = true;
          bIsPlay = false;
          playAudio();
          setState(() {});
        }
      }
    }
  }

  void showFeedbackSuccessDialog(bool isWeekly) {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Color(0xff1A1A1A),
            child: FeedBackDialog(),
          );
        }).then((value) => {
          if (!isWeekly)
            {
              if (bIsPlay)
                {isPlay = true, bIsPlay = false, playAudio(), setState(() {})}
            }
        });
  }

  void showVersionUpdateDialog() {
    bIsPlay = isPlay;
    isPlay = false;
    pauseAudio();
    setState(() {});
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Color(0xff1A1A1A),
            child: VersionUpdateDialog(),
          );
        });
  }

  void getPositiveDefaultMoods() async {
    ApiResponse apiResponse = await apiHelper.getPromptNames("", true);
    if (apiResponse.status == Status.COMPLETED) {
      ResponseModel responseModel =
          ResponseModel.fromJson(apiResponse.data, "");
      print(responseModel.status);
      if (responseModel.status == 200) {
        if (responseModel.moods != null &&
            responseModel.moods != null &&
            responseModel.moods!.isNotEmpty) {
          List<Mood> dCluster = responseModel!.moods!;
          positiveMoods = [];
          positiveMoods2 = [];
          print("positiveMoods");
          print(dCluster!.length);
          for (int i = 0; i < dCluster!.length; i++) {
            if (i % 2 == 0) {
              positiveMoods!.add(dCluster![i]);
            } else {
              positiveMoods2!.add(dCluster![i]);
            }
          }
        }
      }
    }
  }

  void getDefaultMoods() async {
    getPositiveDefaultMoods();
    ApiResponse apiResponse =
        await apiHelper.getPromptNames("", isPositiveEmotion);
    if (apiResponse.status == Status.COMPLETED) {
      ResponseModel responseModel =
          ResponseModel.fromJson(apiResponse.data, "");
      print(responseModel.status);
      if (responseModel.status == 200) {
        if (responseModel.moods != null &&
            responseModel.moods != null &&
            responseModel.moods!.isNotEmpty) {
          List<Mood> dCluster = responseModel!.moods!;
          dMoods = [];
          dMoods2 = [];
          print(dCluster!.length);
          for (int i = 0; i < dCluster!.length; i++) {
            if (i % 2 == 0) {
              dMoods!.add(dCluster![i]);
            } else {
              dMoods2!.add(dCluster![i]);
            }
          }
        }
      }
    }
    if (dMoods != null && dMoods!.length > 0) {
      isClosedBottomSheet = false;
      moods = [];
      moods2 = [];
      moods!.addAll(dMoods!);
      moods2!.addAll(dMoods2!);
      selectedMood = null;
    }
    if (!isShowTerms) {
      _showEmotionModal();
    }
  }

  void showFavModelSheet(BuildContext context, bool isFav) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: false,
      builder: (BuildContext context) {
        return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: ModalContent(this.collectionList,
                contentList![pageCount].contentId!, isFav));
      },
    ).then((value) => {updateFavourite(value)});
  }

  Widget _buildBottomSheetOption(BuildContext context, String text,
      {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 17),
        width: double.infinity,
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Color(0xff007AFF),
              fontFamily:
                  text == "Cancel" ? "Causten-Medium" : "Causten-Regular",
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  void loadDefaultMoods() {
    moods = [];
    moods!.add(Mood(moodName: "testtest"));
    moods!.add(Mood(moodName: "tetttett"));
    moods!.add(Mood(moodName: "tetttett"));
    moods!.add(Mood(moodName: "tettttetttt"));
    moods!.add(Mood(moodName: "tett"));
    moods2 = [];
    moods2!.add(Mood(moodName: "tetttett"));
    moods2!.add(Mood(moodName: "test"));
    moods2!.add(Mood(moodName: "tettt"));
    moods2!.add(Mood(moodName: "tetttett"));
    moods2!.add(Mood(moodName: "tett"));
    moods2!.add(Mood(moodName: "tetttett"));
  }

  void showFeedbackDialog(ContentObj contentObj) {
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
    ).then((value) => {
          // Handle the returned value if needed
        });
  }

  void updateVideoLastPosition(value, int index) {
    if (value != null && value["position"] != null) {
      contentList![index].lastPositon = value["position"];
      contentList![index].duration =
          Duration(seconds: contentList![index].lastPositon!);
    }
    ;
    //isPlay = true,
    // setState(() {});
  }

  void updateAudioLastPosition(value, int index) {
    if (value != null && value["position"] != null) {
      contentList![index].duration = value["position"];
    }
    print(isPlay);
    // setState(() {});
  }

  void updateVideoPosition(int index, Duration position) {
    if (contentList != null &&
        contentList!.isNotEmpty &&
        contentList!.length >= index) {
      contentList![index].duration = position;
    }
  }

  String getContentType(String lowerCase) {
    if ((lowerCase.toLowerCase() == "positive_meditation") ||
        (lowerCase.toLowerCase() == "mantra_meditation") ||
        (lowerCase.toLowerCase() == "negative_meditation") ||
        (lowerCase.toLowerCase() == "mindfulness_meditation")) {
      return "MEDITATION";
    } else if ((lowerCase.toLowerCase() == "hypnotic_induction")) {
      return "HYPNOSIS";
    } else if ((lowerCase.toLowerCase() == "info_tidbits") ||
        (lowerCase.toLowerCase() == "info_tidbits_ocd") ||
        (lowerCase.toLowerCase() == "info_tidbits_general")) {
      return "INTERESTING FACTS";
    } else if (lowerCase.toLowerCase() == "emi") {
      return "QUICK RESET";
    } else if (lowerCase.toLowerCase() == "426_breathing" ||
        lowerCase.toLowerCase() == "box_breathing" ||
        lowerCase.toLowerCase() == "positive_426_breathing" ||
        lowerCase.toLowerCase() == "positive_box_breathing") {
      return "BREATH";
    } else {
      return lowerCase.toUpperCase().replaceAll("_", " ");
    }
  }

  String contentTypeImage(String lowerCase) {
    if (lowerCase == "sleep_story") {
      return "assets/images/moon.svg";
    } else if (lowerCase == "game") {
      return "assets/images/game.svg";
    } else if ((lowerCase == "meditation") ||
        (lowerCase == "mindfulness") ||
        (lowerCase == "positive_meditation") ||
        (lowerCase == "mantra_meditation") ||
        (lowerCase == "negative_meditation") ||
        (lowerCase == "mindfulness_meditation")) {
      return "assets/images/meditation.svg";
    } else if (lowerCase == "breath" ||
        lowerCase == "426_breathing" ||
        lowerCase == "box_breathing" ||
        lowerCase == "positive_426_breathing" ||
        lowerCase == "positive_box_breathing") {
      return "assets/images/wind.svg";
    } else if (lowerCase == "journal") {
      return "assets/images/pen_white.svg";
    } else if (lowerCase == "assessment") {
      return "assets/images/FirstAid.svg";
    } else if (lowerCase == "emi") {
      return "assets/images/emi.svg";
    } else if (lowerCase == "hypnotic_induction") {
      return "assets/images/Hipnosys.svg";
    } else if (lowerCase == "info_tidbits" ||
        lowerCase == "info_tidbits_ocd" ||
        lowerCase == "info_tidbits_general") {
      return "assets/images/Lightbulb.svg";
    } else {
      return "assets/images/moon.svg";
    }
  }

  void handleError(mess) {
    print(mess);
  }

  Future<void> getFirebaseToken() async {
    FirebaseMessaging.instance.getToken().then((value) => {
          print("firebaseToken"),
          print(value),
          //if(!Utility.isEmpty(value)&&(Utility.isEmpty(PreferenceUtils.getString("fcm_token",""))||PreferenceUtils.getString("fcm_token","")!=value)){
          PreferenceUtils.setString('fcm_token', value!),

          updateFirebaseToken(value!)
          //},
        });
  }

  void updateFirebaseToken(String fcm) {
    apiHelper.updateFirebaseToken(fcm);
  }

  void onIfeelMenuButtonPressed() {
    isOpenFeelDialog = false;
    moods = [];
    moods2 = [];
    if (isPositiveEmotion) {
      if (positiveMoods != null && positiveMoods!.isNotEmpty) {
        moods!.addAll(positiveMoods!);
        moods2!.addAll(positiveMoods2!);
      }
    } else {
      if (dMoods != null && dMoods!.isNotEmpty) {
        moods!.addAll(dMoods!);
        moods2!.addAll(dMoods2!);
      }
    }
  }
}
