import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_transition/page_transition.dart';
import 'package:quilt/main.dart';
import 'package:quilt/src/PrefUtils.dart';
import 'package:quilt/src/Utility.dart';
import 'package:quilt/src/api/BaseApiService.dart';
import 'package:quilt/src/api/LoadingUtils.dart';
import 'package:quilt/src/api/NetworkApiService.dart';
import 'package:quilt/src/auth/OtpWidget.dart';
import 'package:quilt/src/base/BaseState.dart';

import '../api/ApiHelper.dart';
import '../api/Objects.dart';
import '../userBloc/UserBloc.dart';

class GenderWidget extends BasePage {
  @override
  GenderWidgetState createState() => GenderWidgetState();
}

class GenderWidgetState extends BasePageState<GenderWidget> {
  bool isEnable = false;
  String username = "";
  var identifier = "";
  int selectedItem = 0;
  TextEditingController mobileNumberCntrl = new TextEditingController();
  ApiHelper apiHelper = ApiHelper();
  String userName = "";
  String age = "";
  bool isArg = false;

  @override
  void initState() {
    super.initState();
  }

  getArgs() {
    if (!isArg) {
      isArg = true;
      final args = ModalRoute.of(context)?.settings.arguments as Map;
      userName = args["userName"];
      age = args["age"];
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
        leading: Container(),
        title: SvgPicture.asset("assets/images/page3.svg"),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Container(
        margin: EdgeInsets.only(top: 20),
        child: Column(
          children: [
            Text(
              "What’s your gender?",
              style: TextStyle(
                  color: splashTextColor,
                  fontFamily: "Causten-SemiBold",
                  fontSize: 20),
            ),
            InkWell(
              child: Container(
                decoration: BoxDecoration(
                    color: selectedItem == 0 ? Colors.black : Color(0xFFF2F1F2),
                    border: Border.all(
                      color:
                          selectedItem == 0 ? Colors.black : Color(0xFFF2F1F2),
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                margin: const EdgeInsets.only(
                    left: 15, right: 15, bottom: 10, top: 40),
                alignment: Alignment.center,
                padding: const EdgeInsets.only(top: 15, bottom: 15),
                child: Text(
                  "Male",
                  style: TextStyle(
                      color: selectedItem == 0 ? Colors.white : splashTextColor,fontFamily: "Causten-Medium",
                      fontSize: 15),
                ),
              ),
              onTap: () {
                selectedItem = 0;
                setState(() {});
              },
            ),
            InkWell(
              child: Container(
                decoration: BoxDecoration(
                    color: selectedItem == 1 ? Colors.black : Color(0xFFF2F1F2),
                    border: Border.all(
                      color:
                          selectedItem == 1 ? Colors.black : Color(0xFFF2F1F2),
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                margin: const EdgeInsets.only(
                    left: 15, right: 15, bottom: 10, top: 5),
                alignment: Alignment.center,
                padding: const EdgeInsets.only(top: 15, bottom: 15),
                child: Text(
                  "Female",
                  style: TextStyle(
                      color: selectedItem == 1 ? Colors.white : splashTextColor,fontFamily: "Causten-Medium",
                      fontSize: 15),
                ),
              ),
              onTap: () {
                selectedItem = 1;
                setState(() {});
              },
            ),
            InkWell(
              child: Container(
                decoration: BoxDecoration(
                    color: selectedItem == 2 ? Colors.black : Color(0xFFF2F1F2),
                    border: Border.all(
                      color:
                          selectedItem == 2 ? Colors.black : Color(0xFFF2F1F2),
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                margin: const EdgeInsets.only(
                    left: 15, right: 15, bottom: 10, top: 5),
                alignment: Alignment.center,
                padding: const EdgeInsets.only(top: 15, bottom: 15),
                child: Text(
                  "Non-binary",
                  style: TextStyle(
                      color: selectedItem == 2 ? Colors.white : splashTextColor,fontFamily: "Causten-Medium",
                      fontSize: 15),
                ),
              ),
              onTap: () {
                selectedItem = 2;
                setState(() {});
              },
            ),
            InkWell(
              child: Container(
                decoration: BoxDecoration(
                    color: selectedItem == 3 ? Colors.black : Color(0xFFF2F1F2),
                    border: Border.all(
                      color:
                          selectedItem == 3 ? Colors.black : Color(0xFFF2F1F2),
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                margin: const EdgeInsets.only(
                    left: 15, right: 15, bottom: 10, top: 5),
                alignment: Alignment.center,
                padding: const EdgeInsets.only(top: 15, bottom: 15),
                child: Text(
                  "Prefer not to say",
                  style: TextStyle(
                      color: selectedItem == 3 ? Colors.white : splashTextColor,fontFamily: "Causten-Medium",
                      fontSize: 15),
                ),
              ),
              onTap: () {
                selectedItem = 3;
                setState(() {});
              },
            ),
            Expanded(
              child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: Container(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      updateProfileDate();
                    },
                    child: Text(
                      "Continue",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: "Causten-Bold"),
                    ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: /* isEnable?*/
                            Colors.black /*:Color(0xFFE2E2E2)*/,
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
      ),
    ));
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
            context, HomeWidgetRoutes.DashboardWidget, (route) => false,arguments: {"isShowTerms":true});
      } else {
        Utility.showSnackBar(
            context: context, message: loginResponse.message.toString());
      }
    } else {
      Utility.showSnackBar(
          context: context, message: apiResponse.message.toString());
    }
  }
}
