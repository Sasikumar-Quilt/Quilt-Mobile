import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:quilt/main.dart';
import 'package:quilt/src/Utility.dart';
import 'package:quilt/src/api/BaseApiService.dart';
import 'package:quilt/src/api/NetworkApiService.dart';
import 'package:quilt/src/base/BaseState.dart';

import '../OtpView.dart';
import '../PrefUtils.dart';
import '../api/ApiHelper.dart';
import '../api/Objects.dart';

class EnterPasswordWidget extends BasePage {
  @override
  EnterPasswordWidgetState createState() => EnterPasswordWidgetState();
}

class EnterPasswordWidgetState extends BasePageState<EnterPasswordWidget> {
  bool isEnable = false;
  bool hidden = false;
  String username = "";
  var identifier = "";
  String verificationCode = "";
  String emailId="";
  TextEditingController mobileNumberCntrl = new TextEditingController();
  ApiHelper apiHelper = ApiHelper();
  List<TextEditingController?>? controls;
 bool isArg=false;
 bool isAlreadyRegistered=false;
  Timer? _timer=null;
  int _start = 59;
  UserResponse? loginResponse;
  bool isApiCalling=false;
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light
        )
    );
    startTimer();
  }
  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }
  @override
  Widget build(BuildContext context) {
    getArgs();

    return Scaffold(resizeToAvoidBottomInset: false,extendBodyBehindAppBar: true,
      body: Container(
        child: Stack(children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF40A1FB), // Lighter blue at the top
                  Colors.black, // Darker blue at the bottom
                  Colors.black, // Darker blue at the bottom
                  Colors.black, // Darker blue at the bottom
                ],
              ),),),
          Container(child: Image.asset("assets/images/noisy.png",fit: BoxFit.fill,),width: double.infinity,),
          Column(

            children: [
              Container(margin: EdgeInsets.only(left: 15,top: 70),alignment: Alignment.topLeft,child: InkWell(child: Icon(Icons.arrow_back_ios_rounded,color: Colors.white, size: 20),onTap: (){
                Navigator.of(context).pop();
              },),),

              Container(
                child: SvgPicture.asset("assets/images/mail.svg",),
                margin: EdgeInsets.only(bottom: 15,top: 30),
              ),
              Text(
                "Check your mail",
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Causten-Medium",
                    fontSize: 24),
              ),
              Container(
                child: Text(
                  "Enter the code sent to $emailId",
                  style: TextStyle(color: Color(0xffB0B0B0), fontSize: 14,fontFamily: "Causten-Medium"),
                ),
                alignment: Alignment.center,
                margin: EdgeInsets.only(top: 15, left: 20, right: 15),
              ),

              Container(
                width: double.infinity,
                height: 55,
                margin: EdgeInsets.only(top: 50, left: 15),
                child: OtpView(
                  borderColor: Color(0xff272727),
                  showCursor: true,
                  focusedBorderColor:  Color(0xff272727),
                  styles: [
                    TextStyle(fontSize: 16, fontFamily: "Causten-Medium",color: Colors.white),
                    TextStyle(fontSize: 16, fontFamily: "Causten-Medium",color: Colors.white),
                    TextStyle(fontSize: 16, fontFamily: "Causten-Medium",color: Colors.white),
                    TextStyle(fontSize: 16, fontFamily: "Causten-Medium",color: Colors.white)
                  ],
                  clearText: false,

                  hasCustomInputDecoration: true,
                  fieldWidth: 50,
                  showFieldAsBox: false,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide:const BorderSide(color: Color(0xff3D3D3D), width: 0.5), // No border
                      borderRadius: BorderRadius.circular(10), // Circular border
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:const BorderSide(color: Color(0xff131314), width: 1.9), // No border
                      borderRadius: BorderRadius.circular(10), // Circular border
                    ),
                    hintText: "",
                    counterText: "",
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                    hintStyle: TextStyle(color: Color(0xFF40A1FB), fontSize: 20),
                  ),
                  textStyle: TextStyle(color: Colors.white,fontSize: 16),
                  onCodeChanged: (String value, String code) {
                    print("object1234");
                    print(value);
                    verificationCode = code;
                    if (verificationCode.length == 4) {
                      isEnable = true;
                    } else {
                      isEnable = false;
                    }
                    setState(() {});
                  },
                  handleControllers: (controllers) {
                    print("controls");
                    controls = controllers;

                    print(controls);
                  },
                  onSubmit: (String verificationCode, String code) {
                    this.verificationCode = verificationCode;
                    print("onSubmit");
                    if (verificationCode.length == 4) {
                      isEnable = true;
                      // verifyEmailOtp();
                    } else {
                      isEnable = false;
                    }
                    setState(() {});
                  }, // end onSubmit
                ),
              ),
              loginResponse!=null?Container(child: Row(crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,children: [
                SvgPicture.asset("assets/images/warning.svg"),
                Container(child: Text(
                  loginResponse!.message,
                  style: TextStyle(
                      color: Color(0xFFC84040),fontFamily: "Causten-Regular",
                      fontSize: 14),
                ),margin: EdgeInsets.only(left: 5),)
              ],),alignment: Alignment.center,margin: EdgeInsets.only(top: 5, left: 20, right: 15),):Container(),
              InkWell(child: Container(
                decoration: BoxDecoration(
                    color: Color(0xff272727),
                    border: Border.all(
                        color:Color(0xff272727),width: 1.9
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                child: Text(
                  _start==0?"Resend code":"Resend in 00:$_start",
                  style: TextStyle(color: _start==0?Colors.white:Colors.white, fontSize: 12,fontFamily: "Causten-Bold"),
                ),
                margin: EdgeInsets.only(top: 30),
                padding:
                EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
              ),onTap: (){
                if(_start==0){
                  sendMailOtp();
                }
              },),
              Container(
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (isEnable&&!isApiCalling) {
                      verifyEmailOtp();
                    }
                  },
                  child: Text(
                    "Confirm email",
                    style: TextStyle(
                        color: isEnable?Colors.black:Color(0xff5D5D5D),
                        fontSize: 14,
                        fontFamily: "Causten-Bold"),
                  ),
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                      isEnable ? Color(0xff40A1FB) : Color(0xFF1A1A1A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30), // <-- Radius
                      )),
                ),
                width: double.infinity,
                margin: EdgeInsets.only(left: 15, right: 15, bottom: 0,top: 60),
              ),
            ],
          ),
          isApiCalling?Positioned(top: 0,bottom: 0,left: 0,right: 0,
            child:  Container(
              height: 150,
              width: 150,
              child: Center(
                  child: Lottie.asset(
                      "assets/images/feed_preloader.json",height: 150,width: 150)
              ),
            ),
          ):Positioned(top: 0,bottom: 0,left: 0,right: 0,child: Container(),)
        ],),
      ),
    );
  }

  void verifyEmailOtp() async {
    isApiCalling=true;
    //LoadingUtils.instance.showLoadingIndicator("Sending OTP...", context);
    loginResponse=null;
    setState(() {

    });
    ApiResponse apiResponse =
        await apiHelper.verifyOtpEmail(emailId,int.parse(verificationCode));
    //LoadingUtils.instance.hideOpenDialog(context);
    print("loginResponse");
    if (apiResponse.status == Status.COMPLETED) {
       loginResponse = UserResponse.fromJson(apiResponse.data);
      print(loginResponse!.status);
      if (loginResponse!.status == 200) {
        PreferenceUtils.setString(
            PreferenceUtils.SESSION_TOKEN, loginResponse!.sessionToken);
        PreferenceUtils.setString(
            PreferenceUtils.USER_ID, loginResponse!.userId);
        if(!loginResponse!.isUserProfileUpdated){
          Navigator.pushNamedAndRemoveUntil(context, HomeWidgetRoutes.EnterUserNameWidget, (route) => false);
        }else{
          PreferenceUtils.setBool(
              PreferenceUtils.IS_LOGIN,true);
          Navigator.pushNamedAndRemoveUntil(context, HomeWidgetRoutes.DashboardWidget, (route) => false);
        }
      } else {
        isApiCalling=false;
        setState(() {

        });
       // Utility.showSnackBar(context: context, message: loginResponse.message);
      }
    } else {
      Utility.showSnackBar(context: context, message: apiResponse.message.toString());
      isApiCalling=false;
      setState(() {

      });
    }


  }

  getArgs() {
    if (!isArg) {
      isArg = true;
      final args = ModalRoute.of(context)?.settings.arguments as Map;
      emailId = args["email"];
      isAlreadyRegistered = args["isAlreadyRegistered"];
    }
  }
  void sendMailOtp() async{
    print("res");
    print(emailId);
    //LoadingUtils.instance.showLoadingIndicator("Sending OTP...",context);
    ApiResponse apiResponse=await apiHelper.sendOtpEmail(emailId);
    //LoadingUtils.instance.hideOpenDialog(context);
    print("loginResponse");
     if(apiResponse.status==Status.COMPLETED){
      LoginResponse loginResponse=LoginResponse.fromJson(apiResponse.data);
      print(loginResponse.status);
      if(loginResponse.status==200){
        _start = 59;
        startTimer();
        final snackBar = SnackBar(
          backgroundColor: Colors.transparent,behavior: SnackBarBehavior.floating,
          elevation: 0, margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height - 130,
            right: 20,
    left: 20),
          content: PhysicalModel(color: Colors.white, elevation: 8,shape: BoxShape.circle,
          child: Container(
              padding: const EdgeInsets.only(left: 15,right: 8,top: 15,bottom: 15),
              decoration: BoxDecoration(
                color:Color(0xff1A1A1A),borderRadius: BorderRadius.all(Radius.circular(20))
                ,boxShadow: [
                BoxShadow(
                color: Color(0xff3D3D3D),
                offset: Offset(0.0, 1.0), //(x,y)
                blurRadius: 6.0,
              ),
            ],
              ),
              child: Row(
                children: [
                  Image.asset("assets/images/CheckCircle1.png",height: 20,),
                  Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Text('Verification code resent', style: TextStyle(color: Colors.white,fontFamily: "Causten-Regular",fontSize: 14)),
                  ),
                ],
              )
          ),),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }else{
        Utility.showSnackBar(context: context, message: loginResponse.message);
      }
    }else{
      Utility.showSnackBar(context: context, message: apiResponse.message.toString());
    }

  }
  void startTimer() {
    Duration  oneSec =  const Duration(seconds: 1);
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
}
