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

class EnterUserNameWidget extends BasePage {
  @override
  EnterUserNameWidgetState createState() => EnterUserNameWidgetState();
}

class EnterUserNameWidgetState extends BasePageState<EnterUserNameWidget> {
  bool isEnable = false;
  bool isAgeEnable = false;
  bool isGenderENable = false;
  String username = "";
  var identifier = "";
  FocusNode _focusNode = FocusNode();
  FocusNode _focusNode2 = FocusNode();

  TextEditingController mobileNumberCntrl = new TextEditingController();
  ApiHelper apiHelper=ApiHelper();
  String errorMessage="";
  String ageErrorMessage="";
  int selectedindex=0;
  PageController _pageController = PageController();
  int selectedItem = -1;
  TextEditingController ageCntrl = new TextEditingController();
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light
        )
    );
    _pageController.addListener((){
      setState(() {
        if(selectedindex==0&&_pageController.page!.toInt()==1){
          if(!isEnable){
            _pageController.jumpToPage(
              0,
            );
          }else{
            _focusNode.unfocus();
            selectedindex = _pageController.page!.toInt();
            print("selectedindex");
            print(selectedindex);
          }
        }else  if(selectedindex==1&&_pageController.page!.toInt()==2){
          if(!isAgeEnable){
            _pageController.jumpToPage(
              1
            );
          }else{
            _focusNode2.unfocus();
            selectedindex = _pageController.page!.toInt();
            print("selectedindex");
            print(selectedindex);
          }
        }else{
          selectedindex = _pageController.page!.toInt();
          print("selectedindex");
          print(selectedindex);
        }

      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFDA328D), // Lighter blue at the top
                Colors.black, // Darker blue at the bottom
                Colors.black, // Darker blue at the bottom
                Colors.black, // Darker blue at the bottom
              ],
            ),),),
        Container(child: Image.asset("assets/images/noisy.png",fit: BoxFit.fill,),width: double.infinity,),

        Column(children: [
          Container(margin: EdgeInsets.only(left: 15,top: 50,bottom: 10),alignment: Alignment.topLeft,child: Container(child:_buildIndicator(),margin: EdgeInsets.only(right: 45),alignment: Alignment.center,),),
          Expanded(child: PageView.builder(onPageChanged: (int index){
            selectedindex=index;
            print("selectedindex");
            print(selectedindex);
            setState(() {

            });
          },controller: _pageController,itemBuilder: (BuildContext context,int index){
            if(index==0){
              return Container(
                margin: EdgeInsets.only(top: 20),
                child: Column(
                  children: [
                    Text(
                      "Let’s get started,\nwhat’s your name?",textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Causten-Medium",
                          fontSize: 24),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          left: 15, right: 15, bottom: 15, top: 50),alignment: Alignment.center,
                      padding: const EdgeInsets.all(3.0),
                      child:  TextField(
                        controller: mobileNumberCntrl,focusNode: _focusNode,
                        keyboardType: TextInputType.text,textAlign: TextAlign.center,
                        onChanged: (text) {
                          errorMessage="";
                          if (text.isNotEmpty) {
                            if(Utility.isNameValid(text)){
                              if(text.length>1){
                                isEnable = true;
                              }else{
                                isEnable=false;
                                errorMessage="Name must contain at least 2 characters.";
                              }
                            }else if(!Utility.isNameValid(text)){
                              isEnable = false;
                              errorMessage="Enter a name without numbers or special characters.";
                            }else{
                              isEnable=true;
                            }
                          } else {
                            isEnable = false;
                          }
                          setState(() {});
                        },style: TextStyle(color: Colors.white,fontSize: 25,fontFamily: "Causten-Medium"),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding:
                          const EdgeInsets.symmetric(horizontal: 25.0,vertical: 15),
                          hintStyle: TextStyle(
                              color: Color(0xFF6D6D6D),
                              fontFamily: "Causten-Medium",
                              fontSize: 25),
                          hintText: "Name",),
                      ),
                    ),
                    !Utility.isEmpty(errorMessage)?Container(child: Row(crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,children: [
                      SvgPicture.asset("assets/images/warning.svg"),
                      Container(child: Text(
                        errorMessage,
                        style: TextStyle(
                            color: Color(0xFFC84040),fontFamily: "Causten-Regular",
                            fontSize: 14),
                      ),margin: EdgeInsets.only(left: 5),)
                    ],),alignment: Alignment.center,margin: EdgeInsets.only(top: 5, left: 20, right: 15),):Container(),

                    Expanded(
                      child: Align(
                        alignment: FractionalOffset.bottomCenter,
                        child: Container(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              if(isEnable){
                                _focusNode.unfocus();
                                _pageController.animateToPage(
                                  1,
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                            child: Text(
                              "Continue",
                              style: TextStyle(
                                  color: isEnable?Colors.black:Color(0xff5D5D5D),
                                  fontSize: 14,
                                  fontFamily: "Causten-Bold"),
                            ),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: isEnable ? Color(0xff40A1FB) : Color(0xFF1A1A1A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30), // <-- Radius
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
            }else if(index==1){
              return Container(
                margin: EdgeInsets.only(top: 20),
                child: Column(
                  children: [
                    Text(
                      "How old are you?",
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Causten-Medium",
                          fontSize: 24),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          left: 15, right: 15, bottom: 15, top: 50),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(3.0),
                      child: TextField(
                        controller: ageCntrl,focusNode: _focusNode2,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        onChanged: (text) {
                          ageErrorMessage="";
                          if (text.length > 0) {
                            int age = int.parse(text);
                            if (age < 18) {
                              isAgeEnable = false;
                              ageErrorMessage = "You must be at least 18 years old.";
                            }else  if (age > 120) {
                              isAgeEnable = false;
                              ageErrorMessage = "Age cannot exceed 120 years old.";
                            }else{
                              isAgeEnable=true;
                            }
                          } else {
                            isAgeEnable = false;
                          }
                          setState(() {});
                        },
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontFamily: "Causten-Medium"),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 25.0, vertical: 15),
                          hintStyle: TextStyle(
                              color: Color(0xFF6D6D6D),
                              fontFamily: "Causten-Medium",
                              fontSize: 25),
                          hintText: "Age",
                        ),
                      ),
                    ),

                    !Utility.isEmpty(ageErrorMessage)
                        ? Container(
                      child: Row(crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,children: [
                        SvgPicture.asset("assets/images/warning.svg"),
                        Container(child: Text(
                          ageErrorMessage,
                          style: TextStyle(
                              color: Color(0xFFC84040),fontFamily: "Causten-Regular",
                              fontSize: 14),
                        ),margin: EdgeInsets.only(left: 5),)
                      ],),
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(top: 5, left: 20, right: 15),
                    )
                        : Container(),
                    Expanded(
                      child: Align(
                        alignment: FractionalOffset.bottomCenter,
                        child: Container(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (isAgeEnable) {
                                _focusNode2.unfocus();
                                _pageController.animateToPage(
                                  2,
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                            child: Text(
                              "Continue",
                              style: TextStyle(
                                  color: isAgeEnable?Colors.black:Color(0xff5D5D5D),
                                  fontSize: 14,
                                  fontFamily: "Causten-Bold"),
                            ),
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                isAgeEnable ? Color(0xff40A1FB) : Color(0xFF1A1A1A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30), // <-- Radius
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
            }else{

              return Container(
                margin: EdgeInsets.only(top: 20),
                child: Column(
                  children: [
                    Text(
                      "What’s your gender?",
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Causten-Medium",
                          fontSize: 24),
                    ),
                    GestureDetector(
                      child: Container(
                        decoration: BoxDecoration(
                            color: Color(0xff131314),

                            border: Border.all(
                                color:
                                selectedItem == 0 ? Color(0xff40A1FB) : Color(0xFF454545),width: 1.9
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(30))),
                        margin: const EdgeInsets.only(
                            left: 15, right: 15, bottom: 10, top: 40),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.only(top: 15, bottom: 15),
                        child: Text(
                          "Male",
                          style: TextStyle(
                              color: Colors.white ,fontFamily: "Causten-Medium",
                              fontSize: 15),
                        ),
                      ),
                      onTap: () {
                        selectedItem = 0;
                        isGenderENable=true;
                        setState(() {});
                      },
                    ),
                    GestureDetector(
                      child: Container(
                        decoration:BoxDecoration(
                            color: Color(0xff131314),

                            border: Border.all(
                                color:
                                selectedItem == 1 ? Color(0xff40A1FB) : Color(0xFF454545),width: 1.9
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(30))),
                        margin: const EdgeInsets.only(
                            left: 15, right: 15, bottom: 10, top: 5),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.only(top: 15, bottom: 15),
                        child: Text(
                          "Female",
                          style: TextStyle(
                              color: Colors.white,fontFamily: "Causten-Medium",
                              fontSize: 15),
                        ),
                      ),
                      onTap: () {
                        selectedItem = 1;
                        isGenderENable=true;
                        setState(() {});
                      },
                    ),
                    GestureDetector(
                      child: Container(
                        decoration: BoxDecoration(
                            color: Color(0xff131314),

                            border: Border.all(
                                color:
                                selectedItem == 2 ? Color(0xff40A1FB) : Color(0xFF454545),width: 1.9
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(30))),
                        margin: const EdgeInsets.only(
                            left: 15, right: 15, bottom: 10, top: 5),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.only(top: 15, bottom: 15),
                        child: Text(
                          "Non-binary",
                          style: TextStyle(
                              color: Colors.white ,fontFamily: "Causten-Medium",
                              fontSize: 15),
                        ),
                      ),
                      onTap: () {
                        selectedItem = 2;
                        isGenderENable=true;
                        setState(() {});
                      },
                    ),
                    GestureDetector(
                      child: Container(
                        decoration: BoxDecoration(
                            color: Color(0xff131314),

                            border: Border.all(
                                color:
                                selectedItem == 3 ? Color(0xff40A1FB) : Color(0xFF454545),width: 1.9
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(30))),
                        margin: const EdgeInsets.only(
                            left: 15, right: 15, bottom: 10, top: 5),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.only(top: 15, bottom: 15),
                        child: Text(
                          "Prefer not to say",
                          style: TextStyle(
                              color: Colors.white ,fontFamily: "Causten-Medium",
                              fontSize: 15),
                        ),
                      ),
                      onTap: () {
                        selectedItem = 3;
                        isGenderENable=true;
                        setState(() {});
                      },
                    ),
                    Container(margin: EdgeInsets.only(left: 15,top: 15),child: Row(children: [
                      Image.asset("assets/images/geninfo.png",height: 16,),
                      Container(margin: EdgeInsets.only(left: 10),child: Text("We use this information to personalize your\n experience.",style: TextStyle(color: Color(0xff888888),fontSize: 14,fontFamily: "Causten-Regular"),),)
                    ],),),
                    Expanded(
                      child: Align(
                        alignment: FractionalOffset.bottomCenter,
                        child: Container(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              if(isGenderENable){
                                updateProfileDate();
                              }
                            },
                            child: Text(
                              "Create account",
                              style: TextStyle(
                                  color: isGenderENable?Colors.black:Color(0xff5D5D5D),
                                  fontSize: 14,
                                  fontFamily: "Causten-Bold"),
                            ),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: /* isEnable?*/

                                isGenderENable ? Color(0xff40A1FB) : Color(0xFF1A1A1A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30), // <-- Radius
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
            }
          },itemCount: 3,))
        ],)
      ],),
    );
  }
  void mobileNumberLogin() async{
    LoadingUtils.instance.showLoadingIndicator("Sending OTP...",context);
    ApiResponse apiResponse=await apiHelper.mobileNumberLoginApi(mobileNumberCntrl.text.toString());
    LoadingUtils.instance.hideOpenDialog(context);
    print("loginResponse");
    if(apiResponse.status==Status.COMPLETED){
      LoginResponse loginResponse=LoginResponse.fromJson(apiResponse.data);

      print(loginResponse.status);
      if(loginResponse.status==200){
        Navigator.pushNamed(context, HomeWidgetRoutes.OtpScreen,arguments: {"mobileNumber":mobileNumberCntrl.text.toString()});
      }else{
        Utility.showSnackBar(context: context, message: loginResponse.message);
      }
    }else{
      Utility.showSnackBar(context: context, message: apiResponse.message.toString());
    }

  }
  Widget _buildIndicator() {
    List<Widget> indicators = [];
    for (int i = 0; i < 3; i++) {
      indicators.add(
        InkWell(child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: i == selectedindex ? 30 : 10,
          height: 10,
          margin: EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: i == selectedindex ? Colors.white : Colors.grey.withOpacity(0.7),
            borderRadius: BorderRadius.circular(5),
          ),
        ),onTap: (){
          if(selectedindex==0&&i==1){
            if(isEnable){
              _pageController.animateToPage(
                i,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          }else if(selectedindex==0&&i==2){
            if(isEnable){
              _pageController.animateToPage(
                i,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          }else if(selectedindex==1&&i==2){
            if(isAgeEnable){
              _pageController.animateToPage(
                i,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          }else{
            _pageController.animateToPage(
              i,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }

        },),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: indicators,
    );
  }
  bool enableRight(){
    if(selectedindex==0){
      print("enableRight");
      return isEnable;
    }else if(selectedindex==1){
      return isAgeEnable;
    }
    return false;
  }
  void updateProfileDate() async {

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
    //LoadingUtils.instance.showLoadingIndicator("Receiving...", context);
    ApiResponse apiResponse = await apiHelper.updateUserDetails(
        "", mobileNumberCntrl.text, "", gender, "", int.parse(ageCntrl.text));
    // LoadingUtils.instance.hideOpenDialog(context);
    if (apiResponse.status == Status.COMPLETED) {
      LoginResponse loginResponse = LoginResponse.fromJson(apiResponse.data);
      print(loginResponse.status);
      if (loginResponse.status == 200) {
        PreferenceUtils.setBool(PreferenceUtils.IS_LOGIN, true);
        showModel();
      } else {
        Utility.showSnackBar(
            context: context, message: loginResponse.message.toString());
      }
    } else {
      Utility.showSnackBar(
          context: context, message: apiResponse.message.toString());
    }
  }
  void showModel() {
    showModalBottomSheet(
        backgroundColor: Colors.black,
        isScrollControlled: true,
        enableDrag: true,
        isDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return FractionallySizedBox(
            child: DraggableScrollableSheet(
                expand: false,
                initialChildSize: 1.0,
                builder: (_, builder) {
                  return Container(
                    child: Stack(
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                              left: 15, right: 15, top: 10, bottom: 10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              /* Container(
                        child: SvgPicture.asset("assets/images/Indicator.svg"),
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(top: 5, bottom: 5),
                      ),*/

                              Expanded(
                                  child: ListView(
                                    children: [
                                      Container(
                                        child: SvgPicture.asset(
                                          "assets/images/terms_img.svg",
                                          height: 50,
                                          width: 50,
                                        ),
                                        alignment: Alignment.center,
                                        margin:
                                        EdgeInsets.only(top: 90, bottom: 30),
                                      ),
                                      Container(
                                        child: Text(
                                          "Please read Medical Disclaimer and Appropriate Use of the Quilt App",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontFamily: "Causten-Medium"),
                                        ),
                                      ),

                                      Container(
                                        child: Text(
                                          "1. Age Restriction and User Agreement Notice",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontFamily: "Causten-Medium"),
                                        ),
                                        margin: EdgeInsets.only(top: 40),
                                      ),
                                      Container(
                                        child: Text(
                                          "The Quilt app is intended for users over the age of 18. By using this app, you represent you are at least 18 years of age. If you are not 18 years of age or otherwise do not agree to use the app according to the below information, you must not access the app.",
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              color: Color(0xFFDFDFDF),
                                              fontSize: 14,
                                              fontFamily: "Causten-Regular"),
                                        ),
                                        margin: EdgeInsets.only(top: 5),
                                      ),
                                      Container(
                                          child: Divider(
                                            color: Color(0xff272727),
                                          ),
                                          margin:
                                          EdgeInsets.only(top: 30, bottom: 0)),
                                      Container(
                                        child: Text(
                                          "2. Disclaimer of Medical Advice",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontFamily: "Causten-Medium"),
                                        ),
                                        margin: EdgeInsets.only(top: 30),
                                      ),
                                      Container(
                                        child: Text(
                                          "The Quilt app does not provide any medical advice, psychiatric diagnosis, or treatment, either on this app or elsewhere. The app and the data it generates are intended for informational purposes only.",
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              color: Color(0xFFDFDFDF),
                                              fontSize: 14,
                                              fontFamily: "Causten-Regular"),
                                        ),
                                        margin: EdgeInsets.only(top: 5),
                                      ),
                                      Container(
                                          child: Divider(
                                            color: Color(0xff272727),
                                          ),
                                          margin:
                                          EdgeInsets.only(top: 30, bottom: 0)),
                                      Container(
                                        child: Text(
                                          "3. Consultation Recommendation and Emergency Protocol",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontFamily: "Causten-Medium"),
                                        ),
                                        margin: EdgeInsets.only(top: 30),
                                      ),
                                      Container(
                                        child: Text(
                                          "This app is not a replacement for licensed medical treatment. All information from the app should be discussed and confirmed with your physician, psychiatrist, or other healthcare provider before using it to inform medical or other life decisions. \n\nConsult a physician and if you are experiencing symptoms of any illness.\n\nIf you are experiencing a medical emergency, call 911 or your local emergency number immediately.",
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              color: Color(0xFFDFDFDF),
                                              fontSize: 14,
                                              fontFamily: "Causten-Regular"),
                                        ),
                                        margin:
                                        EdgeInsets.only(top: 5, bottom: 100),
                                      )
                                    ],
                                  ))
                            ],
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            child: Align(
                              alignment: FractionalOffset.bottomCenter,
                              child: Container(
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "Continue",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontFamily: "Causten-Bold"),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xff40A1FB),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            30), // <-- Radius
                                      )),
                                ),
                                width: double.infinity,
                                margin: EdgeInsets.only(
                                    left: 0, right: 0, bottom: 20),
                              ),
                            ),

                            padding:
                            EdgeInsets.only(left: 15, right: 15, top: 10),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
          );
        }).then((value) => {
    Navigator.pushNamedAndRemoveUntil(
    context, HomeWidgetRoutes.DashboardWidget, (route) => false)
    });
  }

}
class CustomScrollPhysics extends ScrollPhysics {
  final bool canScrollLeft;
  final bool canScrollRight;

  const CustomScrollPhysics({required this.canScrollLeft, required this.canScrollRight, ScrollPhysics? parent})
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