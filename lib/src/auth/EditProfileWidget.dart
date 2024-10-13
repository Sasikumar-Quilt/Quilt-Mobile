import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quilt/main.dart';
import 'package:quilt/src/Utility.dart';
import 'package:quilt/src/api/BaseApiService.dart';
import 'package:quilt/src/api/Constants.dart';
import 'package:quilt/src/api/NetworkApiService.dart';
import 'package:quilt/src/base/BaseState.dart';

import '../OtpView.dart';
import '../PrefUtils.dart';
import '../api/ApiHelper.dart';
import '../api/Objects.dart';
import 'package:http/http.dart' as http;

import '../base/AppEnvironment.dart';

class EditProfileWidget extends BasePage {
  @override
  EditProfileWidgetState createState() => EditProfileWidgetState();
}

class EditProfileWidgetState extends BasePageState<EditProfileWidget> {
  bool isEnable = false;
  bool hidden = false;
  String username = "";
  var identifier = "";
  String verificationCode = "";
  String emailId = "";
  String errorMessage = "";
  int editType = 0;
  TextEditingController mobileNumberCntrl = new TextEditingController();
  ApiHelper apiHelper = ApiHelper();
  List<TextEditingController?>? controls;
  bool isArg = false;
  bool isAlreadyRegistered = false;
  Timer? _timer = null;
  int _start = 59;
  bool isApiCalling = false;
  ProfileObject? profileObject;
  int genderType=1;
  bool isOpened=true;
  File? file;
  @override
  void initState() {
    super.initState();
    if (!Utility.isEmpty(PreferenceUtils.getString("profile_data", ""))) {
      profileObject = ProfileObject.sFromJson(
          jsonDecode(PreferenceUtils.getString("profile_data", "")));
    }
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    getArgs();

    return SafeArea(
        child: Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      body: Container(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  margin:
                      EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 40),
                  child: Row(
                    children: [
                      InkWell(child: Container(
                        margin: EdgeInsets.only(right: 10, top: 0),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: "Causten-Medium"),
                        ),
                      ),onTap: (){
                        Navigator.of(context).pop();
                      },),
                      Expanded(
                          child: Container(
                        margin: EdgeInsets.only(right: 10, top: 0),
                        alignment: Alignment.center,
                        child: Text(
                          editType==1?"Edit Name":editType==2?"Edit Age":editType==3?"Edit Gender":"Edit profile photo",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontFamily: "Causten-Medium"),
                        ),
                      )),
                      InkWell(
                        child: Container(
                          margin: EdgeInsets.only(right: 10, top: 0),
                          child: Text(
                            "Save",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: "Causten-Medium"),
                          ),
                        ),
                        onTap: () {
                          if (isEnable) {
                            updateUserProfile(false);
                          }
                        },
                      )
                    ],
                  ),
                ),
                editType!=4?Container(
                  margin: EdgeInsets.only(left: 15, bottom: 10),
                  alignment: Alignment.topLeft,
                  child: Text(
                    editType == 1
                        ? "Name"
                        : editType == 2
                            ? "Age"
                            : "Gender",
                    style: TextStyle(
                        color: Color(0xff888888),
                        fontSize: 14,
                        fontFamily: "Causten-Medium"),
                  ),
                ):Container(),
               editType==1||editType==2? Container(
                  margin: const EdgeInsets.only(
                      left: 15, right: 15, bottom: 5, top: 0),
                  padding: const EdgeInsets.all(3.0),
                  child: TextField(
                    controller: mobileNumberCntrl,
                    keyboardType: editType == 1
                        ? TextInputType.name
                        : TextInputType.number,
                    style: TextStyle(
                        fontFamily: "Causten-Medium",
                        color: Colors.white,
                        fontSize: 14),
                    onChanged: (text) {
                      errorMessage = "";
                      if (editType == 1) {
                        if (text.isNotEmpty) {
                          if (Utility.isNameValid(text)) {
                            if (text.length > 1) {
                              isEnable = true;
                            } else {
                              isEnable = false;
                              errorMessage =
                                  "Name must contain at least 2 characters.";
                            }
                          } else if (!Utility.isNameValid(text)) {
                            isEnable = false;
                            errorMessage =
                                "Enter a name without numbers or special characters.";
                          } else {
                            isEnable = true;
                          }
                        } else {
                          isEnable = false;
                        }
                      } else {
                        if (text.length > 0) {
                          int age = int.parse(text);
                          if (age < 18) {
                            errorMessage = "You must be at least 18 years old.";
                          } else if (age > 120) {
                            isEnable = false;
                            errorMessage = "Age cannot exceed 120 years old.";
                          } else {
                            isEnable = true;
                          }
                        } else {
                          isEnable = false;
                        }
                      }
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Color(0xff6D6D6D), width: 0.7),
                          // No border
                          borderRadius: BorderRadius.circular(30)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Color(0xff6D6D6D), width: 0.7),
                          // No border
                          borderRadius: BorderRadius.circular(30)),
                      filled: true,
                      fillColor: Color.fromRGBO(39, 39, 39, 0.60),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 25.0, vertical: 15),
                      hintStyle: TextStyle(
                          color: Color(0xFFB0B0B0),
                          fontFamily: "Causten-Regular",
                          fontSize: 14),
                      hintText: "",
                    ),
                  ),
                ):Container(),
                editType==3?InkWell(child: Container( margin: const EdgeInsets.only(
                    left: 15, right: 15, bottom: 5, top: 0),padding: EdgeInsets.only(top: 10,left: 15,right: 15,bottom: 10),decoration: BoxDecoration(borderRadius: BorderRadius.circular(30),border: Border.all(color:  Color(0xff6D6D6D))),
                  child: Row(
                    children: [
                      SvgPicture.asset(genderType==1?"assets/images/lead_icon.svg":genderType==2?"assets/images/female_icon.svg":genderType==3?"assets/images/non_binary_icon.svg":"assets/images/other_icon.svg"),
                      Expanded(
                          child: Container(
                            margin: EdgeInsets.only(left: 10, top: 0),
                            child: Text(
                              genderType==1?"Male":genderType==2?"Female":genderType==3?"Non-Binary":"Other",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: "Causten-Regular"),
                            ),
                          )),
                      Icon(isOpened?Icons.keyboard_arrow_up_rounded:Icons.keyboard_arrow_down_rounded,color:  Color(0xff6D6D6D),),
                    ],
                  ),
                ),onTap: (){
                  isOpened=!isOpened;
                  setState(() {

                  });
                },):Container(),
                editType==3&&isOpened?Container(margin: EdgeInsets.only(left: 15,top: 20,right: 15),decoration: BoxDecoration(color: Color(0xff3D3D3D).withOpacity(0.45),borderRadius: BorderRadius.circular(10)),child: Column(children: [
                  InkWell(child: Container( margin: const EdgeInsets.only(
                      left: 0, right: 0, bottom: 5, top: 0),padding: EdgeInsets.only(top: 10,left: 15,right: 15,bottom: 10),
                    child: Row(
                      children: [
                        SvgPicture.asset("assets/images/lead_icon.svg"),
                        Expanded(
                            child: Container(
                              margin: EdgeInsets.only(left: 10, top: 0),
                              child: Text(
                                "Male",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: "Causten-Regular"),
                              ),
                            )),
                        genderType==1? SvgPicture.asset("assets/images/check_circle_blue.svg"):Container(),
                      ],
                    ),
                  ),onTap: (){
                    genderType=1;
                    setState(() {

                    });
                  },),
                  InkWell(child: Container( margin: const EdgeInsets.only(
                      left: 0, right: 0, bottom: 5, top: 0),padding: EdgeInsets.only(top: 10,left: 15,right: 15,bottom: 10),
                    child: Row(
                      children: [
                        SvgPicture.asset("assets/images/female_icon.svg"),
                        Expanded(
                            child: Container(
                              margin: EdgeInsets.only(left: 10, top: 0),
                              child: Text(
                                "Female",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: "Causten-Regular"),
                              ),
                            )),
                        genderType==2?SvgPicture.asset("assets/images/check_circle_blue.svg"):Container(),
                      ],
                    ),
                  ),onTap: (){
                    genderType=2;
                    setState(() {

                    });
                  },),
                  InkWell(child: Container( margin: const EdgeInsets.only(
                      left: 0, right: 0, bottom: 5, top: 0),padding: EdgeInsets.only(top: 10,left: 15,right: 15,bottom: 10),
                    child: Row(
                      children: [
                        SvgPicture.asset("assets/images/non_binary_icon.svg"),
                        Expanded(
                            child: Container(
                              margin: EdgeInsets.only(left: 10, top: 0),
                              child: Text(
                                "Non-Binary",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: "Causten-Regular"),
                              ),
                            )),
                        genderType==3?SvgPicture.asset("assets/images/check_circle_blue.svg"):Container(),
                      ],
                    ),
                  ),onTap: (){
                    genderType=3;
                    setState(() {

                    });
                  },),
                  InkWell(child: Container( margin: const EdgeInsets.only(
                      left: 0, right: 0, bottom: 5, top: 0),padding: EdgeInsets.only(top: 10,left: 15,right: 15,bottom: 10),
                    child: Row(
                      children: [
                        SvgPicture.asset("assets/images/other_icon.svg"),
                        Expanded(
                            child: Container(
                              margin: EdgeInsets.only(left: 10, top: 0),
                              child: Text(
                                "Prefer not to say",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: "Causten-Regular"),
                              ),
                            )),
                        genderType==4?SvgPicture.asset("assets/images/check_circle_blue.svg"):Container(),
                      ],
                    ),
                  ),onTap: (){
                    genderType=4;
                    setState(() {

                    });
                  },)
                ],),):Container(),

                editType==4?InkWell(child: Container(child: Stack(children: [
                  file!=null?CircleAvatar(
                    radius: 80.0,
                    backgroundImage:file!=null?Image.file(file!).image:
                    AssetImage('assets/images/default_photo_edt.png'),
                    backgroundColor: Colors.transparent,
                  ):Utility.isEmpty(profileObject!.profilePicture)?CircleAvatar(
                    radius: 80.0,
                    backgroundImage:
                    AssetImage('assets/images/default_photo_edt.png'),
                    backgroundColor: Colors.transparent,
                  ):CircleAvatar(
                    radius: 80.0,
                    backgroundImage:
                    FastCachedImageProvider(profileObject!.profilePicture,),
                    backgroundColor: Colors.transparent,
                  ),
                  Align(child: Container(height: 40,width: 40,decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xff6D6D6D),
                  ),child: SvgPicture.asset("assets/images/pencil_simple.svg"),alignment: Alignment.center,margin: EdgeInsets.only(bottom: 0),),alignment: Alignment.bottomRight,)
                ],),height: 150,width: 150,),onTap: (){
                  showProfileDialog();
                },):Container(),
                !Utility.isEmpty(errorMessage)
                    ? Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset("assets/images/warning.svg"),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Text(
                          errorMessage,
                          style: TextStyle(
                              color: Color(0xFFC84040),
                              fontFamily: "Causten-Regular",
                              fontSize: 14),
                        ),
                        margin: EdgeInsets.only(left: 5),
                      )
                    ],
                  ),
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(top: 5, left: 20, right: 15),
                )
                    : Container(),
              ],
            ),
            isApiCalling
                ? Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 150,
                      width: 150,
                      child: Center(
                          child: Lottie.asset(
                              "assets/images/feed_preloader.json",
                              height: 150,
                              width: 150)),
                    ),
                  )
                : Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(),
                  )
          ],
        ),
      ),
    ));
  }
  void showProfileDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (builder, setState) {
          return Dialog(
            backgroundColor: Colors.black,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    child: Text(
                      "Change profile photo",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: "Causten-Medium"),
                    ),
                    margin: EdgeInsets.only(top: 5,bottom: 5),
                  ),
                  Divider(color: Colors.white.withOpacity(0.1),),
                  InkWell(child: Container(
                    child: Text(
                      "Choose from library",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(0xff0A84FF),
                          fontSize: 20,
                          fontFamily: "Causten-Regular"),
                    ),
                    margin: EdgeInsets.only(top: 5,bottom: 5),
                  ),onTap: (){
                    Navigator.of(context).pop();
                    openImage(1);
                  },),
                  Divider(color: Colors.white.withOpacity(0.1),),
                  InkWell(child: Container(
                    child: Text(
                      "Take photo",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(0xff0A84FF),
                          fontSize: 20,
                          fontFamily: "Causten-Regular"),
                    ),
                    margin: EdgeInsets.only(top: 5,bottom: 5),
                  ),onTap: (){
                    Navigator.of(context).pop();
                    openImage(2);
                  },),
                  Divider(color: Colors.white.withOpacity(0.1),),
                  InkWell(child: Container(
                    child: Text(
                      "Remove current photo",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(0xffC84040),
                          fontSize: 20,
                          fontFamily: "Causten-Regular"),
                    ),
                    margin: EdgeInsets.only(top: 5,bottom: 5),
                  ),onTap: (){
                    Navigator.of(context).pop();
                    updateUserProfile(true);
                  },),
                  Divider(color: Colors.white.withOpacity(0.1),),
                  InkWell(child: Container(
                    child: Text(
                      "Cancel",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(0xff0A84FF),
                          fontSize: 20,
                          fontFamily: "Causten-Regular"),
                    ),
                    margin: EdgeInsets.only(top: 5,bottom: 5),
                  ),onTap: (){
                    Navigator.of(context).pop();
                  },),

                ],
              ),
            ),
          );
        }); // Custom dialog widget
      },
    );
  }
  void openImage(int type) async {
    final ImagePicker picker = ImagePicker();
    XFile? image = null;
    if (type == 2) {
      image = await picker.pickImage(source: ImageSource.camera);
    } else {
      image = await picker.pickImage(source: ImageSource.gallery);
    }
    DateTime dateTime=new DateTime.now();
    String time=dateTime.millisecond.toString();
    final Directory directory = await getTemporaryDirectory();
    //final File profile = File('${directory.path}/profile.jpg');
    final targetPath = path.join(directory.path, 'compressed_${path.basename(image!.path)}');
    file = await compressAndGetFile(new File(image!.path), targetPath);
     isEnable=true;

     setState(() {

     });
  }
  Future<File> compressAndGetFile(File file, String targetPath) async {
    print("targetPath");
    print(targetPath);

    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 100,
    );
    return File(result!.path);
  }
  getArgs() {
    if (!isArg) {
      isArg = true;
      final args = ModalRoute.of(context)?.settings.arguments as Map;
      editType = args["editType"];
      if (editType == 1) {
        mobileNumberCntrl.text = profileObject!.firstName;
      } else if (editType == 2) {
        mobileNumberCntrl.text = profileObject!.age;
      }else if(editType==3){
        if(profileObject!.gender.toLowerCase()=="male"){
          genderType=1;
        }else if(profileObject!.gender.toLowerCase()=="female"){
          genderType=2;
        }else if(profileObject!.gender.toLowerCase()=="non binary"){
          genderType=3;
        }else if(profileObject!.gender.toLowerCase()=="prefer not to say"){
          genderType=4;
        }
        isEnable=true;
      }
    }
  }

  Future<void> updateUserProfile(bool isDelete) async {
    isApiCalling = true;
    String gender="Male";
    setState(() {});
    try {
      String url =AppEnvironment.baseApiUrl+Constans.updateProfile;
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['accept'] = '*/*';
      request.headers['Authorization'] =
          "Bearer ${PreferenceUtils.getString(PreferenceUtils.SESSION_TOKEN, "")}";
      request.headers['Content-Type'] = 'multipart/form-data';
      request.fields['userId'] =
          PreferenceUtils.getString(PreferenceUtils.USER_ID, "");
      request.fields['isDeleted'] = 'false';
      if(!isDelete){
        if (editType == 1) {
          request.fields['firstName'] = mobileNumberCntrl.text;
        } else if (editType == 2) {
          request.fields['age'] = mobileNumberCntrl.text;
        }else if(editType==3){

          if(genderType==1){
            gender="MALE";
          }else if(genderType==2){
            gender="FEMALE";
          }else if(genderType==3){
            gender="NON BINARY";
          }else if(genderType==4){
            gender="PREFER NOT TO SAY";
          }

          request.fields['gender'] = gender;
        }else if(editType==4){

          request.files.add(await http.MultipartFile.fromPath(
            'profilePicture',
            file!.path,
          ));
        }
      }else{
        request.fields['deleteProfilePicture'] = 'true';
      }

      request.fields['email'] = profileObject!.email;
      var response = await request.send();
      print(response.statusCode);
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        print('Response: $responseBody');
        if (editType == 1) {
          profileObject!.firstName = mobileNumberCntrl.text;
          PreferenceUtils.setString(
              "profile_data", jsonEncode(profileObject!.toJson()));
        } else if (editType == 2) {
          profileObject!.age = mobileNumberCntrl.text;
          PreferenceUtils.setString(
              "profile_data", jsonEncode(profileObject!.toJson()));
        } else if (editType == 3) {
          profileObject!.gender =gender;
          PreferenceUtils.setString(
              "profile_data", jsonEncode(profileObject!.toJson()));
        }
        if(isDelete){
          profileObject!.profilePicture ="";
          PreferenceUtils.setString(
              "profile_data", jsonEncode(profileObject!.toJson()));
        }
        Navigator.of(context).pop({"isUpdate":true});
      } else {
        errorMessage="Failed to update profile";
        isApiCalling = false;
        setState(() {});
      }
    } catch (e) {
      print('Error: $e');
      isApiCalling = false;
      setState(() {});
    }
  }
}
