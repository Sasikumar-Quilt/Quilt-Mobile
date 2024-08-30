import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:quilt/main.dart';
import 'package:quilt/src/PrefUtils.dart';
import 'package:quilt/src/base/BaseState.dart';

import '../Utility.dart';
import '../api/ApiHelper.dart';
import '../api/BaseApiService.dart';
import '../api/LoadingUtils.dart';
import '../api/NetworkApiService.dart';
import '../api/Objects.dart';

class OtpWidget extends BasePage {
  @override
  OtpWidgetState createState() => OtpWidgetState();
}

class OtpWidgetState extends BasePageState<OtpWidget> {
  bool isEnable = false;
  String username = "";
  var identifier = "";
  late List<TextStyle?> otpTextStyles;
  late List<TextEditingController?> controls;
  int numberOfFields = 6;
  bool clearText = false;
  String verificationCode = "";
  ApiHelper apiHelper = ApiHelper();
  String mobileNumber = "";
  bool isArg = false;
  Timer? _timer=null;
  int _start = 10;
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _timer?.cancel();
  }
  @override
  Widget build(BuildContext context) {
    getArgs();
    ThemeData theme = Theme.of(context);
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: InkWell(
          child: Icon(
            Icons.keyboard_arrow_left,
            color: Color(0xFF8C8CA1),
          ),
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: Container(
        margin: EdgeInsets.only(top: 20),
        child: Column(
          children: [
            Text(
              "Enter 6 digit Passcode",
              style: TextStyle(
                  color: Color(0xFF1A0E35),
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
          /*  Container(
              width: double.infinity,
              height: 55,
              child: OtpTextField(
                numberOfFields: numberOfFields,
                borderColor: Color(0xFFE2E2E2),
                focusedBorderColor: Color(0xFFE2E2E2),
                clearText: clearText,
                fieldWidth: 50,
                showFieldAsBox: true,
                textStyle: theme.textTheme.subtitle1,
                onCodeChanged: (String value) {
                  print("object");
                  print(value);
                  this.verificationCode = controls[0]!.value.text +
                      controls[1]!.text +
                      controls[2]!.value.text +
                      controls[3]!.value.text +
                      controls[4]!.value.text +
                      controls[5]!.value.text;
                  print("this.verificationCode");
                  print(this.verificationCode);
                  if (verificationCode.length == 6) {
                    isEnable = true;
                  } else {
                    isEnable = false;
                  }
                  setState(() {});
                },
                handleControllers: (controllers) {
                  controls = controllers;
                },
                onSubmit: (String verificationCode) {
                  this.verificationCode = verificationCode;
                  if (verificationCode.length == 6) {
                    isEnable = true;
                  } else {
                    isEnable = false;
                  }
                  setState(() {});
                }, // end onSubmit
              ),
              margin: EdgeInsets.only(top: 30, left: 15),
            ),*/
            Container(
              margin: EdgeInsets.only(left: 17, top: 20),
              child: Row(
                children: [
                  Container(
                    child: Text(
                      "Resend OTP in $_start Sec",
                      style: TextStyle(color: Color(0xFF8C8CA1), fontSize: 13),
                    ),
                    margin: EdgeInsets.only(right: 10),
                  ),
                  InkWell(child: Text(
                    "Resend",
                    style: TextStyle(
                        color: _start==0?Color(0xffEE2D76):Color(0xFF8C8CA1),
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),onTap: (){
                    if(_start==0){
                      mobileNumberLogin();
                    }
                  },)
                ],
              ),
            ),
            Expanded(
              child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: Container(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (isEnable) {
                        verifyOtp();
                      }
                    },
                    child: Text(
                      "Verify Passcode",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: "Poppins-medium"),
                    ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isEnable ? Color(0xffEE2D76) : Color(0xFFE2E2E2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // <-- Radius
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


  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }
  getArgs() {
    if (!isArg) {
      isArg = true;
      final args = ModalRoute.of(context)?.settings.arguments as Map;
      mobileNumber = args["mobileNumber"];
    }
  }

  void verifyOtp() async {
    LoadingUtils.instance.showLoadingIndicator("Verify OTP...", context);
    ApiResponse apiResponse =
    await apiHelper.verifyOtp(mobileNumber, verificationCode);
    if (apiResponse.status == Status.COMPLETED) {
      UserResponse loginResponse = UserResponse.fromJson(apiResponse.data);
      LoadingUtils.instance.hideOpenDialog(context);
      if (loginResponse.status == 200) {
        PreferenceUtils.setBool("isLoggedIn", true);
        PreferenceUtils.setString(
            PreferenceUtils.SESSION_TOKEN, loginResponse!.sessionToken);
        PreferenceUtils.setString(
            PreferenceUtils.USER_ID, loginResponse!.userId);
        Navigator.pushNamedAndRemoveUntil(
            context, HomeWidgetRoutes.homeScreen, (route) => false);
      } else {
        Utility.showSnackBar(context: context, message: loginResponse.message);
      }
    } else {
      Utility.showSnackBar(
          context: context, message: apiResponse.message.toString());
    }
  }
  void mobileNumberLogin() async{
    LoadingUtils.instance.showLoadingIndicator("Sending OTP...",context);
    ApiResponse apiResponse=await apiHelper.mobileNumberLoginApi(mobileNumber);
    LoadingUtils.instance.hideOpenDialog(context);
    print("loginResponse");
    if(apiResponse.status==Status.COMPLETED){
      LoginResponse loginResponse=LoginResponse.fromJson(apiResponse.data);
      print(loginResponse.status);
      if(loginResponse.status==200){
        _start = 10;
        startTimer();
        Utility.showSnackBar(context: context, message: loginResponse.message);
      }else{
        Utility.showSnackBar(context: context, message: loginResponse.message);
      }
    }else{
      Utility.showSnackBar(context: context, message: apiResponse.message.toString());
    }

  }
}
