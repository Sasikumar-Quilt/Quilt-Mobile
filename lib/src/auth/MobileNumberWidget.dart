import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

class MobileNumberWidget extends BasePage {
  @override
  MobileNumberWidgetState createState() => MobileNumberWidgetState();
}

class MobileNumberWidgetState extends BasePageState<MobileNumberWidget> {
  bool isEnable = false;
  String username = "";
  var identifier = "";
  TextEditingController mobileNumberCntrl = new TextEditingController();
  ApiHelper apiHelper=ApiHelper();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Container(
        margin: EdgeInsets.only(top: 20),
        child: Column(
          children: [
            Text(
              "Login with your phone number",
              style: TextStyle(
                  color: Color(0xFF1A0E35),
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
            Container(
              margin: const EdgeInsets.only(
                  left: 15, right: 15, bottom: 15, top: 30),
              padding: const EdgeInsets.all(3.0),
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFFE2E2E2)),
                borderRadius: BorderRadius.all(Radius.circular(
                        10.0) //                 <--- border radius here
                    ),
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      child: Text("+91"),
                      margin: EdgeInsets.only(right: 10, left: 10),
                    ),
                    VerticalDivider(
                      color: Color(0xFFE2E2E2),
                      thickness: 1,
                    ),
                    Expanded(
                        child: TextField(
                      controller: mobileNumberCntrl,
                      keyboardType: TextInputType.number,maxLength: 10,
                      onChanged: (text) {
                        if (text.length == 10) {
                          isEnable = true;
                        } else {
                          isEnable = false;
                        }
                        setState(() {});
                      },
                      decoration: InputDecoration(
                          border: InputBorder.none,counterText: '',
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 10.0),
                          filled: true,
                          hintStyle: TextStyle(
                              color: Colors.black.withOpacity(0.5),
                              fontFamily: "Poppins-medium",
                              fontSize: 14),
                          hintText: "Mobile number",
                          fillColor: Colors.white),
                    )),
                    isEnable?Container(child: Image.asset("assets/images/check-circle.png",width: 20,height: 20,),):Container()

                  ],
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: Container(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if(isEnable){
                        mobileNumberLogin();
                      }
                    },
                    child: Text(
                      "Generate One Time Passcode",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: "Poppins-medium"),
                    ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: isEnable?Color(0xffEE2D76):Color(0xFFE2E2E2),
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
}
