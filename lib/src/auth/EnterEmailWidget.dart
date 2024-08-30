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
class EnterEmailWidget extends BasePage {
  @override
  EnterEmailWidgetState createState() => EnterEmailWidgetState();
}

class EnterEmailWidgetState extends BasePageState<EnterEmailWidget> {
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
        backgroundColor: Colors.white,leading: InkWell(child: Icon(Icons.arrow_back_ios_rounded,size: 20,),onTap: (){
          Navigator.of(context).pop();
      },)
      ),
      backgroundColor: Colors.white,
      body: Container(
        margin: EdgeInsets.only(top: 20),
        child: Column(
          children: [
            Text(
              "Enter your email",
              style: TextStyle(
                  color: splashTextColor,
                  fontFamily: "Causten-SemiBold",
                  fontSize: 20),
            ),
            Container(child: Text(
              "Email",
              style: TextStyle(
                  color: splashTextColor,fontFamily: "Causten-Medium",
                  fontSize: 14),
            ),alignment: Alignment.topLeft,margin: EdgeInsets.only(top: 30, left: 20, right: 15),),
            Container(
              margin: const EdgeInsets.only(
                  left: 15, right: 15, bottom: 15, top: 5),
              padding: const EdgeInsets.all(3.0),
              child: TextField(
                controller: mobileNumberCntrl,
                keyboardType: TextInputType.emailAddress,style: TextStyle(fontFamily: "Causten-Medium",fontSize: 14),
                onChanged: (text) {
                  if (text.isNotEmpty&&Utility.isValidEmail(text)) {
                    isEnable = true;
                  } else {
                    isEnable = false;
                  }
                  setState(() {});
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none, // No border
                      borderRadius: BorderRadius.circular(30)
                  ),
                  filled: true,
                  fillColor: Color(0xFFE6E4E6),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 25.0,vertical: 15),
                  hintStyle: TextStyle(
                      color: Color(0xFFA0949D),
                      fontFamily: "Causten-Medium",
                      fontSize: 14),
                  hintText: "name@example.com",),
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
                        checkExistMailId();
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
                        backgroundColor: isEnable?Colors.black:Color(0xFFE2E2E2),
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
  void sendMailOtp() async{
    //LoadingUtils.instance.showLoadingIndicator("Sending OTP...",context);
    ApiResponse apiResponse=await apiHelper.sendOtpEmail(mobileNumberCntrl.text.toString());
    //LoadingUtils.instance.hideOpenDialog(context);
    print("loginResponse");
   /* if(apiResponse.status==Status.COMPLETED){
      LoginResponse loginResponse=LoginResponse.fromJson(apiResponse.data);
      print(loginResponse.status);
      if(loginResponse.status==200){
        Navigator.pushNamed(context, HomeWidgetRoutes.EnterPasswordWidget,arguments: {"email":mobileNumberCntrl.text.toString(),"isAlreadyRegistered":loginResponse.isAlreadyRegistered});
      }else{
        Utility.showSnackBar(context: context, message: loginResponse.message);
      }
    }else{
      Utility.showSnackBar(context: context, message: apiResponse.message.toString());
    }*/

  }
  void checkExistMailId() async{
    //LoadingUtils.instance.showLoadingIndicator("Sending OTP...",context);
    ApiResponse apiResponse=await apiHelper.isAlreadyRegisteredApi(mobileNumberCntrl.text.toString());
    //LoadingUtils.instance.hideOpenDialog(context);
    print("loginResponse");
    if(apiResponse.status==Status.COMPLETED){
      LoginResponse loginResponse=LoginResponse.fromJson(apiResponse.data);
      print(loginResponse.status);
      if(loginResponse.status==200){
        sendMailOtp();
        Navigator.pushNamed(context, HomeWidgetRoutes.EnterPasswordWidget,arguments: {"email":mobileNumberCntrl.text.toString(),"isAlreadyRegistered":loginResponse.isAlreadyRegistered});
      }else{
        Utility.showSnackBar(context: context, message: loginResponse.message);
      }
    }else{
      Utility.showSnackBar(context: context, message: apiResponse.message.toString());
    }

  }
}
