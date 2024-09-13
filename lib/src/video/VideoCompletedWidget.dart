import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';
import 'package:quilt/main.dart';
import 'package:quilt/src/PrefUtils.dart';
import 'package:quilt/src/Utility.dart';
import 'package:quilt/src/api/BaseApiService.dart';
import 'package:quilt/src/api/LoadingUtils.dart';
import 'package:quilt/src/api/NetworkApiService.dart';
import 'package:quilt/src/auth/OtpWidget.dart';
import 'package:quilt/src/base/BaseState.dart';
import 'package:quilt/src/feedback/FeedbackWidget.dart';

import '../api/ApiHelper.dart';
import '../api/Objects.dart';
import '../userBloc/UserBloc.dart';
import 'dart:math' as math;

class VideoCompletedWidget extends BasePage {
  @override
  VideoCompletedWidgetState createState() => VideoCompletedWidgetState();
}

class VideoCompletedWidgetState extends BasePageState<VideoCompletedWidget> {
  bool isEnable = false;
  String username = "";
  var identifier = "";
  int selectedItem = 0;
  TextEditingController mobileNumberCntrl = new TextEditingController();
  ApiHelper apiHelper = ApiHelper();
  String userName = "";
  String age = "";
  String triggerMessage = "";
  bool isArg = false;
  int fromJournal = 0;
  ContentObj? contentObj;
  @override
  void initState() {
    super.initState();

  }

  getArgs() {
    if (!isArg) {
      isArg = true;
      final args = ModalRoute.of(context)?.settings.arguments as Map;
      contentObj = args["object"];
      fromJournal = args["fromJournal"]??0;
      triggerMessage = args["triggerMessage"]??"";
    }
  }

  @override
  Widget build(BuildContext context) {
    getArgs();
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        leading: Container(),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Container(alignment: Alignment.center,
                      margin: EdgeInsets.only(left: 15, right: 15),
                      decoration: BoxDecoration(
                        color: Color(0xff303256),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Stack(alignment: Alignment.center,
                        children: [

                          Container(alignment: Alignment.center,child: Image.asset("assets/images/noisy_complete.png"),),
                          Column(mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                             /* Container(
                                child: Image.asset(
                                    "assets/images/video_completed_bg.png",
                                    fit: BoxFit.fill),
                                width: double.infinity,
                              ),*/
                              Container(alignment: Alignment.center,
                                margin: EdgeInsets.only(
                                    left: 15, right: 15, top: 0),
                                child: Column(mainAxisSize: MainAxisSize.max,crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      child: FloatingActionButton(
                                        onPressed: () {},

                                        backgroundColor: Color.fromRGBO(218, 50, 141, 0.40),
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(100),
                                                bottomLeft:
                                                Radius.circular(100),
                                                bottomRight:
                                                Radius.circular(100),
                                                topLeft: Radius.circular(100))),
                                        child: Container(
                                          child: SvgPicture.asset(
                                            "assets/images/video_completed_icon.svg",
                                            semanticsLabel: 'Acme Logo',
                                          ),
                                          alignment: Alignment.center,
                                          margin: EdgeInsets.only(top: 0),
                                        ),
                                      ),
                                      margin:
                                      EdgeInsets.only(top: 0, bottom: 30),
                                    ),
                                    fromJournal==1?Container(
                                      child: Text(
                                        "You’ve Completed \nyour Journal!",textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 20,color: Colors.white,
                                          fontFamily: "Causten-SemiBold",
                                        ),
                                      ),
                                      margin: EdgeInsets.only(top: 10),
                                    ):fromJournal==2||fromJournal==4?Container(
                                      child: Text(
                                        "Great Job!",textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 20,color: Colors.white,
                                          fontFamily: "Causten-SemiBold",
                                        ),
                                      ),
                                      margin: EdgeInsets.only(top: 10),
                                    ):fromJournal==3?Container():Container(
                                      child: Text(
                                        contentType()+' Completed!',textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 20,color: Colors.white,

                                          fontFamily: "Causten-SemiBold",
                                        ),
                                      ),
                                      margin: EdgeInsets.only(top: 10),
                                    ),
                                    Container(
                                      child: Text(
                                        fromJournal!=4&&fromJournal!=2&&fromJournal!=3?'Swipe left or right to breeze\n through your statistics':fromJournal==3?"Thanks for your response!":fromJournal==4?"Interesting Facts completed!":"Quick reset completed!",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize:fromJournal==3?20: 13,
                                          color: fromJournal==3?Colors.white:Color(0xFFDFDFDF),
                                          fontFamily: "Causten-SemiBold",
                                        ),
                                      ),
                                      margin: EdgeInsets.only(bottom: fromJournal==3?15:5),
                                    ),

                                    fromJournal==3?Container(child: SingleChildScrollView(child: Text(!Utility.isEmpty(triggerMessage)?triggerMessage:
                                    contentObj==null||contentObj!.contentType=="FEEDBACK"?"":"This helps us tailor your content feed based on your mood, and understand what the right moment is for certain kinds of content you see. We appreciate it, and future you will appreciate it too!",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFFDFDFDF),
                                        fontFamily: "Causten-SemiBold",
                                      ),
                                    ),),margin: EdgeInsets.only(bottom: !Utility.isEmpty(triggerMessage)?20:40),height: !Utility.isEmpty(triggerMessage)?150:null,):Container()
                                  ],
                                ),
                              )
                              // Add other elements here like the page indicator
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              flex: 7,
            ),
            Expanded(
              child: Container(
                child: Column(
                  children: [
                    Container(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                         if(fromJournal==3){
                           Navigator.of(context).pop();
                         }else{
                           showFeedbackDialog();
                         }

                         //Navigator.of(context).pop();
                        },
                        child: Text(
                          "Back to Feed",
                          style: TextStyle(
                              color: splashTextColor,
                              fontSize: 14,
                              fontFamily: "Causten-Bold"),
                        ),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: /* isEnable?*/
                                Colors.white /*:Color(0xFFE2E2E2)*/,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(30), // <-- Radius
                            )),
                      ),
                      width: double.infinity,
                      margin: EdgeInsets.only(left: 15, right: 15, bottom: 30),
                    ),

                    fromJournal==3?Container():GestureDetector(child: Container(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/images/repeat.svg",
                            semanticsLabel: 'Acme Logo',
                            width: 25,
                            height: 25,
                            fit: BoxFit.scaleDown,
                          ),
                          Container(
                            child: Text(
                              fromJournal==1?"Replay":"Repeat",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: "Causten-Bold",
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                          )
                        ],
                      ),
                    ),onTap: (){
                      Navigator.of(context).pop({"isReplay":true});
                    },)
                  ],
                ),
              ),
              flex: 2,
            )
          ],
        ),
      ),
    ));
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
   /* showDialog(
      context: context,barrierDismissible: false,
      builder: (BuildContext context) {
        return FeedBackWidget(contentObj: contentObj,); // Custom dialog widget
      },
    ).then((value) => {checkFeedback(value)});*/
  }
String contentType(){
    if(contentObj!.contentType=="SLEEP_STORY"){
      return "Sleep Story";
    }else if(contentObj!.contentType=="MEDITATION"){
      return "Meditation";
    }else if(contentObj!.contentType=="BREATH"||(contentObj!.contentType=="426_BREATHING")||(contentObj!.contentType=="POSITIVE_426_BREATHING")||(contentObj!.contentType=="BOX_BREATHING")||(contentObj!.contentType=="POSITIVE_BOX_BREATHING")){
      return "Breathing Exercise";
    }else if(contentObj!.contentType=="MINDFULNESS"){
      return "Mindfulness Meditation";
    }else  if ((contentObj!.contentType!.toLowerCase()=="positive_meditation")|| (contentObj!.contentType!.toLowerCase()=="mantra_meditation")||(contentObj!.contentType!.toLowerCase()=="negative_meditation")||(contentObj!.contentType!.toLowerCase()=="mindfulness_meditation")) {
      return "Meditation";
    }
    return "Sleep Story";
}
  void updateProfileDate() async {
    String gender = "";
    if (selectedItem == 0) {
      gender = "Male";
    } else if (selectedItem == 1) {
      gender = "Female";
    } else if (selectedItem == 2) {
      gender = "Non=binary";
    } else if (selectedItem == 3) {
      gender = "Prefer not to say";
    }
    //LoadingUtils.instance.showLoadingIndicator("Receiving...", context);
    ApiResponse apiResponse = await apiHelper.updateUserDetails(
        "", userName, "", gender, "", int.parse(age));
    // LoadingUtils.instance.hideOpenDialog(context);
    if (apiResponse.status == Status.COMPLETED) {
      LoginResponse loginResponse = LoginResponse.fromJson(apiResponse.data);
      print(loginResponse.status);
      if (loginResponse.status == 200) {
        PreferenceUtils.setBool(PreferenceUtils.IS_LOGIN, true);
        Navigator.pushNamedAndRemoveUntil(
            context, HomeWidgetRoutes.DashboardWidget, (route) => false,
            arguments: {"isShowTerms": true});
      } else {
        Utility.showSnackBar(
            context: context, message: loginResponse.message.toString());
      }
    } else {
      Utility.showSnackBar(
          context: context, message: apiResponse.message.toString());
    }
  }

  checkFeedback(value) {
    if(value!=null&&value["isFeedback"]==true){
      Navigator.of(context).pop();
    }else{
      Navigator.of(context).pop();
    }
  }
}
