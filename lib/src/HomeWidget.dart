/*
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';
import 'package:loop_page_view/loop_page_view.dart';
import 'package:lottie/lottie.dart';
import 'package:quilt/src/PrefUtils.dart';
import 'package:quilt/src/base/BaseWidget.dart';

import '../main.dart';
import 'Utility.dart';
import 'api/ApiHelper.dart';
import 'api/BaseApiService.dart';
import 'api/LoadingUtils.dart';
import 'api/NetworkApiService.dart';
import 'api/Objects.dart';
import 'db/DatabaseHelper.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends BaseState<HomePage> with WidgetsBindingObserver {
  String _steps = '0';
  String contentId = '';
  LoopPageController? _pageController;
  int totalSteps = -1;
  int lastCount = 0;
  int stepCount = 0;
  DatabaseHelper helper = DatabaseHelper();
  StepCounts? stepCounts = null;
  static final types = [
    HealthDataType.STEPS,
  ];
  Timer? timer;
  var isGonnected = false;
  HealthFactory health = HealthFactory(useHealthConnectIfAvailable: true);
  ApiHelper apiHelper = ApiHelper();
  List<AnimationObject> animationList = [];
  RewardsDetailsResponse? rewardsDetailsResponse;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    animationList.add(AnimationObject());
    _pageController = LoopPageController(
        initialPage: 0,
        scrollMode: LoopScrollMode.shortest,
        activationMode: LoopActivationMode.immediate);
    Future.delayed(Duration.zero, () {
      helper.getStepCountByDate(Utility.getDate("dd-MM-yyyy")).then((value) => {
            if (value.isNotEmpty)
              {
                stepCounts = value[0],
                stepCount = stepCounts!.count,
                _steps = stepCount.toString(),
                lastCount = stepCount,
                setState(() {})
              }
          });
      isGonnected = PreferenceUtils.getBool("isHealthConnected") ?? false;
      if (isGonnected) {
        fetchStepData();
        startTimer();
      }
      getSliderListApi();
      getRewardDetails();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        print("resumed");
        if (isGonnected) {
          startTimer();
        }
        break;
      case AppLifecycleState.paused:
        print("paused");
        timer?.cancel();
        timer = null;
        break;
      case AppLifecycleState.detached:
      // TODO: Handle this case.
      case AppLifecycleState.inactive:
      // TODO: Handle this case.
      case AppLifecycleState.hidden:
      // TODO: Handle this case.
    }
  }

  void startTimer() {
    timer ??= Timer.periodic(const Duration(seconds: 15), (Timer timer) {
      fetchStepData();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          InkWell(
            child: Container(
              child: SizedBox(
                width: 40,
                height: 40,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: const Image(
                        image: AssetImage("assets/images/default.jpg"))),
              ),
              margin: EdgeInsets.only(right: 15),
            ),
            onTap: () {
              Navigator.pushNamed(context, HomeWidgetRoutes.profileScreen);
            },
          )
        ],
      ),
      body: LoopPageView.builder(
        itemBuilder: (BuildContext context, int position) {
          final itemIndex = position;
          print("itemIndex");
          print(itemIndex);
          return itemIndex == 0
              ? InkWell(
                  child: Container(
                    alignment: Alignment.center,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                child: Text(
                                  "Sync quilt with Health Connect",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 18),
                                ),
                                alignment: Alignment.center,
                              ),
                              Container(
                                child: CupertinoSwitch(
                                  value: isGonnected,
                                  onChanged: (value) async {
                                    */
/*if(isGonnected){

                         // logoutFit();
                        }else{

                        }*//*

                                    if (!isGonnected) {
                                      authorize();
                                    } else {
                                      revokePermissions();
                                    }
                                  },
                                ),
                                alignment: Alignment.center,
                              )
                            ],
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          child: Text(
                            Utility.getDate("EEE").toUpperCase() +
                                "\n" +
                                Utility.getDate("dd") +
                                "\n" +
                                Utility.getDate("MMM").toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black, fontSize: 24),
                          ),
                        ),
                        Container(
                          child: Text(
                            "STEPS",
                            style: TextStyle(
                                color: Color(0xffEE2D76),
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                          margin: EdgeInsets.only(top: 50),
                        ),
                        Container(
                          child: Text(
                            _steps,
                            style: TextStyle(
                                color: Color(0xffEE2D76),
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          margin: EdgeInsets.only(top: 10),
                        ),
                        Container(
                          child: Text(
                            "Wallet Balance",
                            style: TextStyle(
                                color: Color(0xffEE2D76),
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                          margin: EdgeInsets.only(top: 10),
                        ),
                        rewardsDetailsResponse != null
                            ? Container(
                                child: Text(
                                  rewardsDetailsResponse!
                                      .currentUserWalletBalance,
                                  style: TextStyle(
                                      color: Color(0xffEE2D76),
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                margin: EdgeInsets.only(top: 10),
                              )
                            : Container(),
                        Container(
                          child: Text(
                            "Earned Minus Survey",
                            style: TextStyle(
                                color: Color(0xffEE2D76),
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                          margin: EdgeInsets.only(top: 10),
                        ),
                        rewardsDetailsResponse != null
                            ? Container(
                                child: Text(
                                  rewardsDetailsResponse!
                                      .totalEarnedMinusSurvey,
                                  style: TextStyle(
                                      color: Color(0xffEE2D76),
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                margin: EdgeInsets.only(top: 10),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                  onTap: () {
                    */
/* Navigator.pushNamed(
                        context, HomeWidgetRoutes.slideScreen);*//*

                  },
                )
              : InkWell(
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: FutureBuilder(
                          future: loadLottieFromJsonString(
                              animationList[itemIndex].url),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return Lottie.memory(
                                snapshot.data!,
                                animate: true,
                                repeat: true,
                              );
                            } else {
                              return CircularProgressIndicator();
                            }
                          },
                        ),
                      ),
                      Align(
                        child: Container(
                          height: 40,
                          width: 50,
                          child: InkWell(child: Icon(
                            Icons.favorite,
                            color:
                            animationList[itemIndex].favourite ? Color(0xffEE2D76) : Colors.grey,
                            size: 30.0,
                          )*/
/*LikeButton(
                            size: 30.0,
                            isLiked: animationList[itemIndex].favourite,
                            circleColor: CircleColor(
                                start: Colors.pinkAccent[200]!,
                                end: Colors.pinkAccent[400]!),
                            bubblesColor: BubblesColor(
                              dotPrimaryColor: Colors.lightBlue[300]!,
                              dotSecondaryColor: Colors.lightBlue[200]!,
                            ),
                            onTap: onClickLike,
                            likeBuilder: (bool isLiked) {

                              return ;
                            },
                          )*//*
,onTap: (){
                            animationList[itemIndex].favourite=!animationList[itemIndex].favourite;
                            setState(() {

                            });
                            postLogContent(animationList[itemIndex].id,
                                animationList[itemIndex].favourite, false,itemIndex);
                          },),
                          */
/*Icon(Icons.favorite,color: Colors.grey,size: 25,)*//*

                          margin: EdgeInsets.only(right: 15, top: 10),
                        ),
                        alignment: Alignment.topRight,
                      )
                    ],
                  ),
                  onTap: () {
                    contentId = animationList[itemIndex].id;
                    postLogContent(animationList[itemIndex].id, false, true,0);
                    */
/* Navigator.pushNamed(
                        context, HomeWidgetRoutes.webScreenScreen,arguments: {"url":itemIndex==0?"https://www.nytimes.com/puzzles/sudoku":itemIndex==1?"https://supernapie.itch.io/dead-sticks":"https://gemioli.itch.io/skate-hooligans"});
                   *//*

                    if (animationList[itemIndex].contentType.toUpperCase() ==
                        "WEBVIEW") {
                      print(animationList[itemIndex].content);
                      */
/* _launchURL(context,animationList[itemIndex].content);*//*

                      Navigator.pushNamed(
                          context, HomeWidgetRoutes.webScreenScreen,
                          arguments: {"url": animationList[itemIndex].content});
                    } else if (animationList[itemIndex]
                            .contentType
                            .toUpperCase() ==
                        "NATIVE") {
                      Navigator.pushNamed(
                          context, HomeWidgetRoutes.slideScreen);
                    }
                  },
                );
        },
        itemCount: animationList.length,
        scrollDirection: Axis.vertical,
        controller: _pageController,
        physics: const AlwaysScrollableScrollPhysics(),
      ),
    );
  }

  Future authorize() async {
    final permissions = types.map((e) => HealthDataAccess.READ_WRITE).toList();

    // create a HealthFactory for use in the app
    // If we are trying to read Step Count, Workout, Sleep or other data that requires
    // the ACTIVITY_RECOGNITION permission, we need to request the permission first.
    // This requires a special request authorization call.
    //
    // The location permission is requested for Workouts using the Distance information.
    */
/*  await Permission.activityRecognition.request();
    await Permission.location.request();*//*


    // Check if we have permission
    bool? hasPermissions =
        await health.hasPermissions(types, permissions: permissions);

    // hasPermissions = false because the hasPermission cannot disclose if WRITE access exists.
    // Hence, we have to request with WRITE as well.
    hasPermissions = false;

    bool authorized = false;
    if (!hasPermissions) {
      // requesting access to the data types before reading them
      try {
        authorized =
            await health.requestAuthorization(types, permissions: permissions);
      } catch (error) {
        Utility.showSnackBar(context: context, message: error.toString());
        print("Exception in authorize: $error");
      }
    }
    isGonnected = authorized;
    PreferenceUtils.setBool("isHealthConnected", isGonnected);
    setState(() {});
    if (authorized) {
      fetchStepData();
      if (timer == null) {
        startTimer();
      }
    }
  }

  Future<void> revokePermissions() async {
    try {
      await health.revokePermissions();
      isGonnected = false;
      PreferenceUtils.setBool("isHealthConnected", isGonnected);
      setState(() {});
    } catch (error) {
      Utility.showSnackBar(context: context, message: error.toString());
      print("Exception in authorize: $error");
    }
  }

  void getSliderListApi() async {
    LoadingUtils.instance.showLoadingIndicator("Receiving...", context);
    ApiResponse apiResponse = await apiHelper.getContentList();
    LoadingUtils.instance.hideOpenDialog(context);
    if (apiResponse.status == Status.COMPLETED) {
      SliderList loginResponse = SliderList.fromJson(apiResponse.data);
      print(loginResponse.status);
      if (loginResponse.status == 200) {
        animationList.addAll(loginResponse.animationList);
        print("contentList");
        print(animationList.length);
        setState(() {});
      } else if (loginResponse.status == 401) {
        refreshToken(4);
      }
    } else {
      Utility.showSnackBar(
          context: context, message: apiResponse.message.toString());
    }
  }

  void postLogContent(String id, bool isFav, bool isLogContent,int itemIndex) async {
    ApiResponse apiResponse =
        await apiHelper.logContent(id, isFav, isLogContent);
    if (apiResponse.status == Status.COMPLETED) {
      PostMetricResponse loginResponse =
          PostMetricResponse.fromJson(apiResponse.data);
      if (loginResponse!.status == 401) {
        refreshToken(3);
      }else if(loginResponse.status==200&&isFav){
        print(loginResponse.status);
      }else{
        animationList[itemIndex].favourite =!
            animationList[itemIndex].favourite;
      }
    } else {
      Utility.showSnackBar(
          context: context, message: apiResponse.message.toString());
    }
  }

  void favourite(String id, bool isEnabled, int itemIndex) async {
    ApiResponse apiResponse = await apiHelper.updateFavourite(isEnabled, id);
    if (apiResponse.status == Status.COMPLETED) {
      PostMetricResponse loginResponse =
          PostMetricResponse.fromJson(apiResponse.data);
      if (loginResponse!.status == 401) {
        refreshToken(3);
      } else if (loginResponse!.status == 200) {}
    } else {
      Utility.showSnackBar(
          context: context, message: apiResponse.message.toString());
    }
  }

  void getRewardDetails() async {
    ApiResponse apiResponse = await apiHelper.getRewardDetails();
    if (apiResponse.status == Status.COMPLETED) {
      rewardsDetailsResponse =
          RewardsDetailsResponse.fromJson(apiResponse.data);
      if (rewardsDetailsResponse!.status == 401) {
        refreshToken(2);
      }
      setState(() {});
    } else {
      Utility.showSnackBar(
          context: context, message: apiResponse.message.toString());
    }
  }

  void postMetricData(int stepCount) async {
    */
/* LoadingUtils.instance.showLoadingIndicator(
        "Updating step count...", context);*//*

    ApiResponse apiResponse = await apiHelper.postMetricData(2641);
    //LoadingUtils.instance.hideOpenDialog(context);
    if (apiResponse.status == Status.COMPLETED) {
      PostMetricResponse loginResponse =
          PostMetricResponse.fromJson(apiResponse.data);
      print(loginResponse.status);
      Utility.showSnackBar(
          context: context, message: loginResponse.message.toString());
      if (loginResponse.status == 200) {
        getRewardDetails();
      } else if (loginResponse.status == 401) {
        refreshToken(1);
      }
    } else {
      Utility.showSnackBar(
          context: context, message: apiResponse.message.toString());
    }
  }

  Future fetchStepData() async {
    int? steps;

    // get steps for today (i.e., since midnight)
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    bool requested = await health.requestAuthorization([HealthDataType.STEPS]);

    if (requested) {
      try {
        steps = await health.getTotalStepsInInterval(midnight, now);
      } catch (error) {
        Utility.showSnackBar(context: context, message: error.toString());
        print("Caught exception in getTotalStepsInInterval: $error");
      }

      print('Total number of steps: $steps');

      if (stepCount != steps) {
        setState(() {
          stepCount = (steps == null) ? 0 : steps;
          _steps = stepCount.toString();
          //_state = (steps == null) ? AppState.NO_DATA : AppState.STEPS_READY;
        });
        postMetricData(stepCount);
        if (stepCounts == null) {
          insertStepCount();
        } else {
          updateStepCount(stepCounts!);
        }
      }
    } else {
      Utility.showSnackBar(
          context: context, message: "Authorization not granted ");
      print("Authorization not granted - error in authorization");
      // setState(() => _state = AppState.DATA_NOT_FETCHED);
    }
  }

  Future<Uint8List> loadLottieFromJsonString(String jsonString) async {
    log(jsonString);
    final List<int> jsonMap = jsonString.codeUnits;
    final bytes = Uint8List.fromList(jsonMap); //utf8.encode(jsonString);
    return bytes;
    */
/*await LottieComposition.fromBytes(Uint8List.fromList(bytes))*//*
;
  }

  Future<void> insertStepCount() async {
    StepCounts stepCount = StepCounts(
        id: 0, count: this.stepCount, date: Utility.getDate("dd-MM-yyyy"));
    int result = await helper.insertStepCount(stepCount);
    helper.getStepCountByDate(Utility.getDate("dd-MM-yyyy")).then((value) => {
          if (value.isNotEmpty) {stepCounts = value[0]}
        });
    print("result");
    print(result);
  }

  Future<void> updateStepCount(StepCounts stepCounts) async {
    stepCounts.count = this.stepCount;
    int result = await helper.updateStepCount(stepCounts);
    print(result);
  }

  void onPedestrianStatusError(error) {}

  void onStepCountError(error) {}

  @override
  void onRefreshToken(int apiType) {
    if (apiType == 1) {
      postMetricData(stepCount);
    } else if (apiType == 2) {
      getRewardDetails();
    } else if (apiType == 3) {
      postLogContent(contentId,false,true,0);
    } else if (apiType == 4) {
      getSliderListApi();
    }
  }

  Future<bool?> onClickLike(bool isLiked) async {
    return !isLiked;
  }
}
*/
