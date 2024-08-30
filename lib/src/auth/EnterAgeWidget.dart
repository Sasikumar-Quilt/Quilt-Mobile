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

import '../api/ApiHelper.dart';
import '../api/Objects.dart';
import '../userBloc/UserBloc.dart';

class EnterAgeWidget extends BasePage {
  @override
  EnterAgeWidgetState createState() => EnterAgeWidgetState();
}

class EnterAgeWidgetState extends BasePageState<EnterAgeWidget> {
  bool isEnable = false;
  String username = "";
  var identifier = "";
  TextEditingController mobileNumberCntrl = new TextEditingController();
  ApiHelper apiHelper = ApiHelper();
  String errorMessage = "";
  String userName="";
  bool isArg=false;

  @override
  void initState() {
    super.initState();
  }
  getArgs() {
    if (!isArg) {
      isArg = true;
      final args = ModalRoute.of(context)?.settings.arguments as Map;
      userName = args["userName"];
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
        leading:Container(),title: SvgPicture.asset("assets/images/page2.svg"),centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Container(
        margin: EdgeInsets.only(top: 20),
        child: Column(
          children: [
            Text(
              "How old are you?",
              style: TextStyle(
                  color: splashTextColor,
                  fontFamily: "Causten-SemiBold",
                  fontSize: 20),
            ),
            Container(
              margin: const EdgeInsets.only(
                  left: 15, right: 15, bottom: 15, top: 50),
              alignment: Alignment.center,
              padding: const EdgeInsets.all(3.0),
              child: TextField(
                controller: mobileNumberCntrl,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                onChanged: (text) {
                  errorMessage="";
                  if (text.length > 0) {
                    int age = int.parse(text);
                    if (age < 18) {
                      isEnable = false;
                      errorMessage = "You must be at least 18 years old.";
                    }else  if (age > 120) {
                      isEnable = false;
                      errorMessage = "Age cannot exceed 120 years old.";
                    }else{
 isEnable=true;
                    }
                  } else {
                    isEnable = false;
                  }
                  setState(() {});
                },
                style: TextStyle(
                    color: splashTextColor,
                    fontSize: 25,
                    fontFamily: "Causten-Medium"),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 25.0, vertical: 15),
                  hintStyle: TextStyle(
                      color: Color(0xFFCFC9CE),
                      fontFamily: "Causten-Medium",
                      fontSize: 25),
                  hintText: "Age",
                ),
              ),
            ),
            !Utility.isEmpty(errorMessage)
                ? Container(
                    child: Text(
                      errorMessage,
                      style: TextStyle(color: Color(0xFFC84040), fontSize: 12,fontFamily: "Causten-Medium"),
                    ),
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
                      if (isEnable) {
                        Navigator.pushNamed(
                            context, HomeWidgetRoutes.GenderWidget,arguments: {"userName":userName,"age":mobileNumberCntrl.text});
                      }
                    },
                    child: Text(
                      "Continue",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: "Causten-Bold"),
                    ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isEnable ? Colors.black : Color(0xFFE2E2E2),
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

  void mobileNumberLogin() async {
    LoadingUtils.instance.showLoadingIndicator("Sending OTP...", context);
    ApiResponse apiResponse =
        await apiHelper.mobileNumberLoginApi(mobileNumberCntrl.text.toString());
    LoadingUtils.instance.hideOpenDialog(context);
    print("loginResponse");
    if (apiResponse.status == Status.COMPLETED) {
      LoginResponse loginResponse = LoginResponse.fromJson(apiResponse.data);

      print(loginResponse.status);
      if (loginResponse.status == 200) {
        Navigator.pushNamed(context, HomeWidgetRoutes.OtpScreen,
            arguments: {"mobileNumber": mobileNumberCntrl.text.toString()});
      } else {
        Utility.showSnackBar(context: context, message: loginResponse.message);
      }
    } else {
      Utility.showSnackBar(
          context: context, message: apiResponse.message.toString());
    }
  }
}
