import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_transition/page_transition.dart';
import 'package:quilt/main.dart';
import 'package:quilt/src/Utility.dart';
import 'package:quilt/src/api/BaseApiService.dart';
import 'package:quilt/src/api/LoadingUtils.dart';
import 'package:quilt/src/api/NetworkApiService.dart';
import 'package:quilt/src/auth/OtpWidget.dart';
import 'package:quilt/src/base/BaseState.dart';

import '../PrefUtils.dart';
import '../api/ApiHelper.dart';
import '../api/Objects.dart';
import '../userBloc/UserBloc.dart';

class AssessmentListWidget extends BasePage {
  @override
  AssessmentListWidgetState createState() => AssessmentListWidgetState();
}

class AssessmentListWidgetState extends BasePageState<AssessmentListWidget> {
  double _sliderValue = 0.0;

  ApiHelper apiHelper = ApiHelper();
  int selectedindex = 0;
  PageController _pageController = PageController();
  int selectedItem = -1;
  bool isArg = false;
  ContentObj? contentObj;
  List<AssessmentObject> assessment_questions=[];
  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {});
  }

  getArgs() {
    if (!isArg) {
      isArg = true;
      final args = ModalRoute.of(context)?.settings.arguments as Map;
      contentObj = args["url"];
      assessment_questions=contentObj!.assessmentList!.assessment_questions;
      assessment_questions[0].answer=assessment_questions[0].assessment_questions_options!.options[0];
      for (var f in assessment_questions) {
        f.answer = "";
      }
      assessment_questions[0].answer=assessment_questions[0].assessment_questions_options!.options[0];
      _sliderValue =  double.parse(assessment_questions[0].assessment_questions_options!.options[0]);
    }
  }
  @override
  Widget build(BuildContext context) {
    getArgs();
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          InkWell(
            child: Container(
              child: Icon(
                Icons.close,
                size: 25,
                color: Color(0xff131314),
              ),
              margin: EdgeInsets.only(right: 15),
            ),
            onTap: () {
              Navigator.of(context).pop();
            },
          )
        ],
        leading: InkWell(
          child: Icon(Icons.arrow_back_ios_rounded,
              size: 25, color: Color(0xff131314)),
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
        title: Container(
          child: _buildIndicator(),
          margin: EdgeInsets.only(right: 0),
          alignment: Alignment.center,
        ) /*SvgPicture.asset("assets/images/page1.svg")*/,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: PageView.builder(
        onPageChanged: (int index) {
          selectedindex = index;
          if(Utility.isEmpty(assessment_questions[index].answer)){
             assessment_questions[index].answer=assessment_questions[index].assessment_questions_options!.options[0];
            _sliderValue =  double.parse(assessment_questions[index].answer);
          }else{
            _sliderValue =  double.parse(assessment_questions[index].answer);
          }

          print("selectedindex");
          print(selectedindex);
          print(_sliderValue);
          setState(() {});
        },
        controller: _pageController,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            child: Column(
              children: [
               /* index==2?Container(
                  child: Text(
                    "Over the last two weeks, how often  have you been feeling",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14.0,
                        fontFamily: "Causten-Regular",
                        color: Color(0xff5D5D5D)),
                  ),
                  margin: EdgeInsets.only(top: 20, left: 10, right: 10),
                ):Container(),*/
                Container(
                  child: Text(
                    assessment_questions[index].questionText.replaceAll("\\n", "\n"),
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: 24.0,
                        fontFamily: "Causten-Medium",
                        color: Colors.black),
                  ),
                  margin: EdgeInsets.only(top: 20, left: 10, right: 10),
                ),
                assessment_questions[index].questionType=="Linear_Scale"
                    ? Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(child: Text(
                              assessment_questions[index].answer,
                              style: TextStyle(
                                  fontSize: 16.0,
                                  fontFamily: "Causten-Medium",
                                  color: Colors.black),
                            ),),
                            Container(child: Column(
                              children: [

                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 0),
                                  child: SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      activeTrackColor: Colors.black,
                                      inactiveTrackColor: Colors.grey,
                                      thumbColor: Colors.white,
                                      overlayColor:
                                      Colors.white.withOpacity(0.2),
                                      thumbShape: RoundSliderThumbShape(
                                          enabledThumbRadius: 12.0),
                                      trackHeight: 4.0,
                                    ),
                                    child: Slider(
                                      value: _sliderValue,min: double.parse(assessment_questions[index].assessment_questions_options!.options[0]),max: double.parse( assessment_questions[index].assessment_questions_options!.options[assessment_questions[index].assessment_questions_options!.options.length-1]),
                                      onChanged: (newValue) {
                                        setState(() {
                                          _sliderValue = newValue;
                                          assessment_questions[index].answer=newValue.toStringAsFixed(0);
                                        });
                                      },
                                      divisions: assessment_questions[index].assessment_questions_options!.options.length-1,
                                    ),
                                  ),
                                ),

                                Container(margin:EdgeInsets.only(top: 0),
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),alignment: Alignment.bottomCenter,
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        assessment_questions[index].assessment_questions_options!.options[0],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            fontFamily: "Causten-Regular",
                                            color: Color(0xff5D5D5D)),
                                      ),
                                      Text(
                                        assessment_questions[index].assessment_questions_options!.options[assessment_questions[index].assessment_questions_options!.options.length-1],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            fontFamily: "Causten-Regular",
                                            color: Color(0xff5D5D5D)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )),

                          ],
                        ),
                        margin: EdgeInsets.only(top: 40))
                    : Container(
                        child: Column(
                          children: getOptionWidget(index),
                        ),
                        margin: EdgeInsets.only(top: 20),
                      ),
                Expanded(
                  child: Align(
                    alignment: FractionalOffset.bottomCenter,
                    child: Container(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          if(assessment_questions.length>selectedindex+1){
                            _pageController.jumpToPage(selectedindex+1);
                          }else{
                            updateAssessment();
                          }
                        },
                        child: Text(
                          assessment_questions.length==selectedindex+1?"Done":"Next",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: "Causten-Bold"),
                        ),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: /* isEnable?*/

                                Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(30), // <-- Radius
                            )),
                      ),
                      width: double.infinity,
                      margin: EdgeInsets.only(left: 15, right: 15, bottom: 30),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        itemCount: assessment_questions.length,
      ),
    ));
  }

  List<Widget> getOptionWidget(int index) {
    List<Widget> optionsList = [];
    for (int i = 0; i < assessment_questions[index].assessment_questions_options!.options.length; i++) {
      optionsList.add(GestureDetector(
        child: Container(
          decoration: BoxDecoration(
              color:  assessment_questions[index].answer==assessment_questions[index].assessment_questions_options!.options[i]? Colors.black : Colors.white,
              border: Border.all(
                  color:  assessment_questions[index].answer==assessment_questions[index].assessment_questions_options!.options[i] ? Colors.black : Color(0xFFF2F1F2),
                  width: 1.9),
              borderRadius: BorderRadius.all(Radius.circular(30))),
          margin: const EdgeInsets.only(left: 15, right: 15, bottom: 7, top: 7),
          alignment: Alignment.center,
          padding: const EdgeInsets.only(top: 15, bottom: 15),
          child: Text(
            assessment_questions[index].assessment_questions_options!.options[i],
            style: TextStyle(
                color: assessment_questions[index].answer==assessment_questions[index].assessment_questions_options!.options[i]  ? Colors.white : splashTextColor,
                fontFamily: "Causten-Medium",
                fontSize: 15),
          ),
        ),
        onTap: () {
          assessment_questions[index].answer= assessment_questions[index].assessment_questions_options!.options[i];
          setState(() {

          });
        },
      ));
    }
    return optionsList;
  }



  Widget _buildIndicator() {
    List<Widget> indicators = [];
    for (int i = 0; i < assessment_questions.length; i++) {
      indicators.add(
        InkWell(
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: i == selectedindex ? 30 : 10,
            height: 10,
            margin: EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: i == selectedindex ? Colors.black : Colors.grey,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          onTap: () {
            _pageController.animateToPage(
              i,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        ),
      );
    }

    return SingleChildScrollView(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: indicators,
      ),
      scrollDirection: Axis.horizontal,
    );
  }

  void updateAssessment() async {
    String gender = "";
    if (selectedItem == 0) {
      gender = "Male";
    } else if (selectedItem == 1) {
      gender = "Female";
    } else if (selectedItem == 2) {
      gender = "Non binary";
    } else if (selectedItem == 3) {
      gender = "Prefer not to say";
    }
    List<dynamic>list=[];
    for(int i=0;i<assessment_questions.length;i++){
      String answer=assessment_questions[i].answer;
      if(Utility.isEmpty(answer)){
        answer=assessment_questions[i].assessment_questions_options!.options[0];
      }
      list.add({
        "questionId":assessment_questions[i].id,
        "answer": [
          answer
        ]
      });
    }
    //LoadingUtils.instance.showLoadingIndicator("Receiving...", context);

    ApiResponse apiResponse = await apiHelper.updateAssessment(
        contentObj!.assessmentList!.id, list);
    // LoadingUtils.instance.hideOpenDialog(context);
    if (apiResponse.status == Status.COMPLETED) {
      AssessmentResponse loginResponse = AssessmentResponse.fromJson(apiResponse.data);
      print(loginResponse.status);
      if (loginResponse.status == 200) {
        Navigator.pushNamed(context, HomeWidgetRoutes.VideoCompletedWidget,arguments: {"object":contentObj,"fromJournal":3,"triggerMessage":loginResponse.triggerMessage}) .then((value) => {replayVideo(value)});
      } else {
        Utility.showSnackBar(
            context: context, message: loginResponse.message.toString());
      }
    } else {
      Utility.showSnackBar(
          context: context, message: apiResponse.message.toString());
    }
  }
  replayVideo(value) {
    if(value!=null&&value["isReplay"]){
      Navigator.of(context).pop({"isReplay":true});
    }else{
      Navigator.of(context).pop({"isReplay":false});
    }
  }
}

class CustomScrollPhysics extends ScrollPhysics {
  final bool canScrollLeft;
  final bool canScrollRight;

  const CustomScrollPhysics(
      {required this.canScrollLeft,
      required this.canScrollRight,
      ScrollPhysics? parent})
      : super(parent: parent);

  @override
  CustomScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomScrollPhysics(
      canScrollLeft: canScrollLeft,
      canScrollRight: canScrollRight,
      parent: buildParent(ancestor),
    );
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    if (value < 0.0 && !canScrollLeft) {
      return value - position.pixels; // block leftward movement
    }
    if (value > 0.0 && !canScrollRight) {
      return value - position.pixels; // block rightward movement
    }
    return 0.0; // no change to behavior
  }
}
class GradientSliderTrackShape extends SliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 4.0;
    final double trackLeft = offset.dx;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;

    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
      PaintingContext context,
      Offset offset, {
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required Animation<double> enableAnimation,
        required TextDirection textDirection,
        required Offset thumbCenter,
        bool isEnabled = false,
        bool isDiscrete = false,
        Offset? secondaryOffset,
      }) {
    if (sliderTheme.trackHeight == null) {
      return;
    }

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final Paint paint = Paint()..shader = LinearGradient(
      colors: [
        Colors.green,
        Colors.orange,
        Colors.red,
      ],
      stops: [
        0.0,
        0.5,
        1.0,
      ],
    ).createShader(trackRect);

    context.canvas.drawRRect(
      RRect.fromRectAndCorners(
        trackRect,
        topLeft: Radius.circular(4),
        topRight: Radius.circular(4),
        bottomLeft: Radius.circular(4),
        bottomRight: Radius.circular(4),
      ),
      paint,
    );
  }
}