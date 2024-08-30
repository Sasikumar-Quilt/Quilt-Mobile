import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quilt/src/base/BaseWidget.dart';

import '../Utility.dart';
import '../api/ApiHelper.dart';
import '../api/BaseApiService.dart';
import '../api/LoadingUtils.dart';
import '../api/NetworkApiService.dart';
import '../api/Objects.dart';
import 'ProfileMenuWidget.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ProfileScreenState();
  }
}

class ProfileScreenState extends BaseState<EditProfileScreen> {
  ApiHelper apiHelper = ApiHelper();
  ProfileObject? profileObject;
  bool isArgs = false;
  int gender = 0;
  TextEditingController firstNameCtrl = TextEditingController();
  TextEditingController lastNameCtrl = TextEditingController();
  TextEditingController phoneNameCtrl = TextEditingController();
  TextEditingController emailIdCtrl = TextEditingController();
  TextEditingController dobNameCtrl = TextEditingController();
  TextEditingController addressNameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    getArgs();
    return SafeArea(
        child: Scaffold(
      backgroundColor:Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Edit Profile",
          style: TextStyle(
              fontSize: 16,
              fontFamily: "Poppins-medium",
              color: Color(0xffEE2D76),
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: InkWell(
          child: Container(
            child: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            margin: EdgeInsets.only(top: 0, left: 5),
          ),
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
          color: Colors.white,
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      child: Text(
                        "First Name",
                        style: TextStyle(
                          fontFamily: "Poppins-Medium",
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 0),
                        child: TextField(
                          controller: firstNameCtrl,
                          decoration: InputDecoration(
                            hintText: "First Name",
                            hintStyle: TextStyle(
                                fontFamily: "Poppins-medium",
                                color: Colors.grey[500],
                                fontSize: 14),
                            alignLabelWithHint: true,
                            enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black45, width: 0.5),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black45, width: 0.5),
                            ),
                          ),
                          // scrollPadding: EdgeInsets.all(20.0),
                          // keyboardType: TextInputType.multiline,
                          // maxLines: 99999,
                          style: TextStyle(color: Colors.black, fontSize: 15),
                          autofocus: false,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      child: Text(
                        "Last Name",
                        style: TextStyle(
                          fontFamily: "Poppins-Medium",
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 0),
                        child: TextField(
                          controller: lastNameCtrl,
                          decoration: InputDecoration(
                            hintText: "Last Name",
                            hintStyle: TextStyle(
                                fontFamily: "Poppins-medium",
                                color: Colors.grey[500],
                                fontSize: 14),
                            alignLabelWithHint: true,
                            enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black45, width: 0.5),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black45, width: 0.5),
                            ),
                          ),
                          // scrollPadding: EdgeInsets.all(20.0),
                          // keyboardType: TextInputType.multiline,
                          // maxLines: 99999,
                          style: TextStyle(color: Colors.black, fontSize: 15),
                          autofocus: false,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      child: Text(
                        "Phone",
                        style: TextStyle(
                          fontFamily: "Poppins-Medium",
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 0),
                        child: TextField(
                          controller: phoneNameCtrl,
                          keyboardType: TextInputType.number,
                          enabled: false,
                          decoration: InputDecoration(
                            hintText: "Phone",
                            hintStyle: TextStyle(
                                fontFamily: "Poppins-medium",
                                color: Colors.grey[500],
                                fontSize: 14),
                            alignLabelWithHint: true,
                            enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black45, width: 0.5),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black45, width: 0.5),
                            ),
                          ),
                          // scrollPadding: EdgeInsets.all(20.0),
                          // keyboardType: TextInputType.multiline,
                          // maxLines: 99999,
                          style: TextStyle(color: Colors.black, fontSize: 15),
                          autofocus: false,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      child: Text(
                        "Email",
                        style: TextStyle(
                          fontFamily: "Poppins-Medium",
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 0),
                        child: TextField(
                          controller: emailIdCtrl,
                          keyboardType: TextInputType.emailAddress,
                          enabled: true,
                          decoration: InputDecoration(
                            hintText: "Email ID",
                            hintStyle: TextStyle(
                                fontFamily: "Poppins-medium",
                                color: Colors.grey[500],
                                fontSize: 14),
                            alignLabelWithHint: true,
                            enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black45, width: 0.5),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black45, width: 0.5),
                            ),
                          ),
                          // scrollPadding: EdgeInsets.all(20.0),
                          // keyboardType: TextInputType.multiline,
                          // maxLines: 99999,
                          style: TextStyle(color: Colors.black, fontSize: 15),
                          autofocus: false,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      child: Text(
                        "Date of birth",
                        style: TextStyle(
                          fontFamily: "Poppins-Medium",
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 0),
                          child: TextField(
                            controller: dobNameCtrl,
                            enabled: false,
                            decoration: InputDecoration(
                              hintText: "Date of birth",
                              hintStyle: TextStyle(
                                  fontFamily: "Poppins-medium",
                                  color: Colors.grey[500],
                                  fontSize: 14),
                              alignLabelWithHint: true,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black45, width: 0.5),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black45, width: 0.5),
                              ),
                            ),
                            // scrollPadding: EdgeInsets.all(20.0),
                            // keyboardType: TextInputType.multiline,
                            // maxLines: 99999,
                            style: TextStyle(color: Colors.black, fontSize: 15),
                            autofocus: false,
                          ),
                        ),
                        onTap: () async {
                          _showIOS_DatePicker(context);
                        },
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      child: Text(
                        "Gender",
                        style: TextStyle(
                          fontFamily: "Poppins-Medium",
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 0),
                        child: Row(
                          children: [
                            Radio(
                                value: gender == 0 ? 1 : 0,
                                groupValue: 1,
                                onChanged: (changed) {
                                  gender = 0;
                                  setState(() {});
                                }),
                            Text("Male"),
                            Radio(
                                value: gender == 1 ? 1 : 0,
                                groupValue: 1,
                                onChanged: (changed) {
                                  gender = 1;
                                  setState(() {});
                                }),
                            Text("Female"),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                child: ElevatedButton(
                  onPressed: () async {
                    updateProfileDate();
                  },
                  child: Text(
                    "Update",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: "Poppins-medium"),
                  ),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xffEE2D76)),
                ),
                width: double.infinity,
                height: 50,
                margin: EdgeInsets.only(left: 15, right: 15, top: 30),
              )
            ],
          ),
        ),
      ),
    ));
  }

  void updateProfileDate() async {
    LoadingUtils.instance.showLoadingIndicator("Receiving...", context);
    ApiResponse apiResponse = await apiHelper.updateUserDetails(emailIdCtrl.text,firstNameCtrl.text,lastNameCtrl.text,gender==0?"Male":"Female",dobNameCtrl.text,0);
    LoadingUtils.instance.hideOpenDialog(context);
    if (apiResponse.status == Status.COMPLETED) {
      PostMetricResponse loginResponse = PostMetricResponse.fromJson(
          apiResponse.data);
      print(loginResponse.status);
      Utility.showSnackBar(
          context: context, message: loginResponse.message.toString());
      if (loginResponse.status == 200) {
        Navigator.of(context).pop();
      }else if(loginResponse.status==401){
        refreshToken(1);
      }
    } else {
      Utility.showSnackBar(
          context: context, message: apiResponse.message.toString());
    }
  }

  void getArgs() {
    if (!isArgs) {
      final arguments = ModalRoute.of(context)!.settings.arguments as Map;
      profileObject = arguments["object"];
      firstNameCtrl.text=profileObject!.firstName;
      lastNameCtrl.text=profileObject!.lastName;
      phoneNameCtrl.text=profileObject!.phoneNumber;
      emailIdCtrl.text=profileObject!.email;
      if(profileObject!.dob!=null&&profileObject!.dob!=""){
        dobNameCtrl.text=profileObject!.dob.split("T")[0];
      }

      if (profileObject!.gender.toLowerCase() == "female") {
        gender = 1;
      } else {
        gender = 0;
      }
      isArgs = true;
    }
  }
  void _showIOS_DatePicker(ctx) {
    showModalBottomSheet(
        context: ctx,
        builder: (_) => Container(
          height: 240,
          color: Color.fromARGB(255, 255, 255, 255),
          child: Column(
            children: [
              Container(padding: EdgeInsets.all(5),child: Row(children: [
                /* Expanded(child:  InkWell(child: Container(margin: EdgeInsets.only(left: 10),child: Text("CANCEL",style: TextStyle(color: selectedTabColor,fontWeight: FontWeight.bold),),),onTap: (){
                 Navigator.of(context).pop();
               },)),*/
                Expanded(child:  InkWell(child: Container(padding: EdgeInsets.all(5),child: Text("DONE",textAlign: TextAlign.end,style: TextStyle(color: Color(0xffEE2D76),fontWeight: FontWeight.bold),),),onTap: (){
                  Navigator.of(context).pop();
                },))
              ],),),
              Container(
                height: 180,
                child: CupertinoDatePicker(mode: CupertinoDatePickerMode.date,
                    initialDateTime: DateTime.now(),
                    onDateTimeChanged: (val) {
                      var split=val.toString().split(" ");

                      setState(() {
                        print("val.toString()");
                        print(val.toString());

                        dobNameCtrl.text = "${split[0].split("-")[0]}-${split[0].split("-")[1]}-${split[0].split("-")[2]}";
                        //dateSelected = val.toString();
                      });
                    }),
              ),
            ],
          ),
        )).then((value) => {
      /*setState((){})*/
    });
  }

  @override
  void onRefreshToken(int apiType) {
    updateProfileDate();
  }
}
