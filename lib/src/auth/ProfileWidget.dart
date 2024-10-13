import 'dart:convert';

import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:quilt/SplashScreen.dart';
import 'package:quilt/src/PrefUtils.dart';
import 'package:quilt/src/Utility.dart';
import 'package:quilt/src/favorite/CollectionHelper.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;

import '../../main.dart';
import '../api/ApiHelper.dart';
import '../api/BaseApiService.dart';
import '../api/Constants.dart';
import '../api/NetworkApiService.dart';
import '../api/Objects.dart';
import '../base/AppEnvironment.dart';

class ProfileWidget extends StatefulWidget{
  ProfileWidget({Key? key}): super(key: key);
  @override
  State<StatefulWidget> createState() {
    return ProfileWidgetState();
  }
}
class ProfileWidgetState extends State<ProfileWidget>{
  bool isEmpty=false;
  ApiHelper apiHelper = ApiHelper();
  List<FavoriteListObject>favLists=[];
  bool isApiContentLoading=false;
  CollectionHelper collectionHelper=new CollectionHelper();
  ProfileObject? profileObject;
  GoogleSignIn? _googleSignIn;
  @override
  void initState() {
    super.initState();
    print("initFav");
    if (defaultTargetPlatform == TargetPlatform.android) {
      _googleSignIn = GoogleSignIn(
          clientId:
          "930588986366-rp6ddk8dm4siehj4n4di9d0t7kt270f8.apps.googleusercontent.com");
    } else {
      _googleSignIn = GoogleSignIn();
    }
    Future.delayed(Duration.zero,(){
      getProfileApi(false);
    });
  }
  Future<void> getProfileApi(bool isUpdate) async {
    if(!Utility.isEmpty(PreferenceUtils.getString("profile_data", ""))){
      profileObject=ProfileObject.sFromJson(jsonDecode(PreferenceUtils.getString("profile_data", "")));
    }else{
      isApiContentLoading=true;
    }
   /* if(!isUpdate){
      profileObject!.profilePicture="";
    }*/
    setState(() {

    });
    ApiResponse? apiResponse=null;
    apiResponse = await apiHelper.getProfileDetails();
    if (apiResponse.status == Status.COMPLETED) {
      String profilePic="";
      if(profileObject==null||(Utility.isEmpty(profileObject?.profilePicture))){
        isUpdate=true;
      }else{
        profilePic=profileObject!.profilePicture;
      }
      profileObject=ProfileObject.fromJson(apiResponse.data);
      if(isUpdate&&!Utility.isEmpty(profileObject!.profilePicture)){
        profileObject?.profilePicture= "${profileObject!.profilePicture}?${DateTime.now().millisecondsSinceEpoch}";
      }else{
        profileObject?.profilePicture=profilePic;
      }
       if(profileObject!.status==200){
         print("profileSaved");
         print(profileObject!.toJson());
         PreferenceUtils.setString("profile_data", jsonEncode(profileObject!.toJson()));
       }
       setState(() {

       });
    }
    isApiContentLoading=false;
    setState(() {

    });
  }
void updateProfile(){
  if(!Utility.isEmpty(PreferenceUtils.getString("profile_data", ""))){
    profileObject=ProfileObject.sFromJson(jsonDecode(PreferenceUtils.getString("profile_data", "")));
  setState(() {

  });
}
}
Future<void> deletingImage(value) async {
  if(!Utility.isEmpty(PreferenceUtils.getString("profile_data", ""))){
    profileObject=ProfileObject.sFromJson(jsonDecode(PreferenceUtils.getString("profile_data", "")));
  }
  if(!Utility.isEmpty(profileObject!.profilePicture)){
    getProfileApi(value!=null&&value["isUpdate"]);
  }else{
    getProfileApi(value!=null&&value["isUpdate"]);
  }
}
  @override
  Widget build(BuildContext context) {

    return  SafeArea(child: Scaffold(backgroundColor: Colors.black,body: Stack(children: [
      SingleChildScrollView(child: Container(margin: EdgeInsets.only(left: 15,right: 15),child:Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
        Container(margin: EdgeInsets.only(left: 0,top: 30),child: Text("ACCOUNT",style: TextStyle(color: Color(0xff8E8E93),fontSize: 12,fontFamily: "Causten-Medium"),),)
        ,Container(padding: EdgeInsets.only(top: 15,bottom: 15,left: 20,right: 0),margin: EdgeInsets.only(top: 12),decoration: BoxDecoration(color: Color(0xff3D3D3D).withOpacity(0.45),borderRadius: BorderRadius.circular(10)),child: Column(children: [
         InkWell(child:  Container(child: Row(crossAxisAlignment: CrossAxisAlignment.center,children: [
           profileObject==null||Utility.isEmpty(profileObject!.profilePicture)?CircleAvatar(
             radius: 15.0,
             backgroundImage:
             AssetImage('assets/images/default_pic.png'),
             backgroundColor: Colors.transparent,

           ):CircleAvatar(
              radius: 15.0,
              backgroundImage: FastCachedImageProvider(profileObject!.profilePicture),
              backgroundColor: Colors.transparent,
            ),
           Expanded(child: Container(margin: EdgeInsets.only(left: 10,top: 0),child: Text("Profile photo",style: TextStyle(color: Colors.white,fontSize: 16,fontFamily: "Causten-Regular"),),))
           ,SvgPicture.asset("assets/images/right_arrow.svg")
         ],),padding: EdgeInsets.only(top: 5,bottom: 5,right: 20),),onTap: (){
           Navigator.pushNamed(context, HomeWidgetRoutes.EditProfileWidget,arguments: {"editType":4}).then((value) =>
           {
             deletingImage(value)

           });
         },),
          Divider(color: Colors.white.withOpacity(0.1),),

          InkWell(child: Container(child: Row(crossAxisAlignment: CrossAxisAlignment.center,children: [
            Expanded(child: Container(margin: EdgeInsets.only(left: 0,top: 0),child: Text("Name",style: TextStyle(color: Colors.white,fontSize: 16,fontFamily: "Causten-Regular"),),))
            ,Container(margin: EdgeInsets.only(right: 10,top: 0),child: Text(profileObject!=null?profileObject!.firstName:"",style: TextStyle(color: Color(0xff8E8E93),fontSize: 16,fontFamily: "Causten-Regular"),),)
            ,SvgPicture.asset("assets/images/right_arrow.svg")
          ],),padding: EdgeInsets.only(top: 5,bottom: 5,right: 20),),onTap: (){
            Navigator.pushNamed(context, HomeWidgetRoutes.EditProfileWidget,arguments: {"editType":1}).then((value) =>
            {
              updateProfile()
            });
          },),
          Divider(color: Colors.white.withOpacity(0.1),),
          Container(child: Row(crossAxisAlignment: CrossAxisAlignment.center,children: [
            Expanded(child: Container(margin: EdgeInsets.only(left: 0,top: 0),child: Text("Email",style: TextStyle(color: Colors.white,fontSize: 16,fontFamily: "Causten-Regular"),),))
            ,Container(margin: EdgeInsets.only(right: 10,top: 0),child: Text(profileObject!=null?profileObject!.email:"",style: TextStyle(color: Color(0xff8E8E93),fontSize: 16,fontFamily: "Causten-Regular"),),)
            ,SvgPicture.asset("assets/images/right_arrow.svg")
          ],),padding: EdgeInsets.only(top: 5,bottom: 5,right: 20),),
          Divider(color: Colors.white.withOpacity(0.1),),

          InkWell(child: Container(child: Row(crossAxisAlignment: CrossAxisAlignment.center,children: [
            Expanded(child: Container(margin: EdgeInsets.only(left: 0,top: 0),child: Text("Gender",style: TextStyle(color: Colors.white,fontSize: 16,fontFamily: "Causten-Regular"),),))
            ,Container(margin: EdgeInsets.only(right: 10,top: 0),child: Text(profileObject!=null?profileObject!.gender.capitalize():"",style: TextStyle(color: Color(0xff8E8E93),fontSize: 16,fontFamily: "Causten-Regular"),),)
            ,SvgPicture.asset("assets/images/right_arrow.svg")
          ],),padding: EdgeInsets.only(top: 5,bottom: 5,right: 20),),onTap: (){
            Navigator.pushNamed(context, HomeWidgetRoutes.EditProfileWidget,arguments: {"editType":3}).then((value) =>
            {
              updateProfile()
            });
          },),
          Divider(color: Colors.white.withOpacity(0.1),),

         InkWell(child:  Container(child: Row(crossAxisAlignment: CrossAxisAlignment.center,children: [
           Expanded(child: Container(margin: EdgeInsets.only(left: 0,top: 0),child: Text("Age",style: TextStyle(color: Colors.white,fontSize: 16,fontFamily: "Causten-Regular"),),))
           ,Container(margin: EdgeInsets.only(right: 10,top: 0),child: Text(profileObject!=null?profileObject!.age:"",style: TextStyle(color: Color(0xff8E8E93),fontSize: 16,fontFamily: "Causten-Regular"),),)
           ,SvgPicture.asset("assets/images/right_arrow.svg")
         ],),padding: EdgeInsets.only(top: 5,bottom: 5,right: 20),),onTap: (){
           Navigator.pushNamed(context, HomeWidgetRoutes.EditProfileWidget,arguments: {"editType":2}).then((value) =>
           {
             updateProfile()
           });

         },)
        ],),)
        ,Container(margin: EdgeInsets.only(left: 0,top: 20),child: Text("PREFERENCES",style: TextStyle(color: Color(0xff8E8E93),fontSize: 12,fontFamily: "Causten-Medium"),),)
        , Container(padding: EdgeInsets.only(top: 15,bottom: 15,left: 20,right: 20),margin: EdgeInsets.only(top: 12),decoration: BoxDecoration(color: Color(0xff3D3D3D).withOpacity(0.45),borderRadius: BorderRadius.circular(10)),child: Row(crossAxisAlignment: CrossAxisAlignment.center,children: [
          SvgPicture.asset("assets/images/bell.svg")
          ,Expanded(child: Container(margin: EdgeInsets.only(left: 10,top: 0),child: Text("Notifications",style: TextStyle(color: Colors.white,fontSize: 16,fontFamily: "Causten-Regular"),),))
          ,Container(margin: EdgeInsets.only(right: 10,top: 0),child: Text("On",style: TextStyle(color: Color(0xff8E8E93),fontSize: 16,fontFamily: "Causten-Regular"),),)
          ,SvgPicture.asset("assets/images/right_arrow.svg")
        ],),)
        ,Container(margin: EdgeInsets.only(left: 0,top: 20),child: Text("HELP & SUPPORT",style: TextStyle(color: Color(0xff8E8E93),fontSize: 12,fontFamily: "Causten-Medium"),),)
        ,Container(padding: EdgeInsets.only(top: 15,bottom: 15,left: 20,right: 20),margin: EdgeInsets.only(top: 12),decoration: BoxDecoration(color: Color(0xff3D3D3D).withOpacity(0.45),borderRadius: BorderRadius.circular(10)),child: Column(children: [
          Row(crossAxisAlignment: CrossAxisAlignment.center,children: [
            SvgPicture.asset("assets/images/info_profile.svg")
            ,Expanded(child: Container(margin: EdgeInsets.only(left: 10,top: 0),child: Text("Help Center",style: TextStyle(color: Colors.white,fontSize: 16,fontFamily: "Causten-Regular"),),))
            ,SvgPicture.asset("assets/images/right_arrow.svg")
          ],),
          Container(alignment: Alignment.topLeft,margin: EdgeInsets.only(left: 0,top: 20),child: Text("Learn how to use Quilt or Contact us",style: TextStyle(color: Color(0xff888888),fontSize: 14,fontFamily: "Causten-Medium"),),)

        ],),)
        ,Container(
          height: 50,
          child: ElevatedButton(
            onPressed: () async {
              showDeleteDialog(false);
            },
            child: Text(
              "Sign out",
              style: TextStyle(
                  color:Colors.black,
                  fontSize: 14,
                  fontFamily: "Causten-Medium"),
            ),
            style: ElevatedButton.styleFrom(
                backgroundColor:
                Color(0xFF40A1FB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // <-- Radius
                )),
          ),
          width: double.infinity,
          margin: EdgeInsets.only(left: 0, right: 0, bottom: 0,top: 30),
        )
/*
        ,Container(
          height: 50,
          child: ElevatedButton(
            onPressed: () async {
             // showDeleteDialog(true);
            },
            child: Text(
              "Delete my account",
              style: TextStyle(
                  color:Color(0xffC84040),
                  fontSize: 14,
                  fontFamily: "Causten-Medium"),
            ),
            style: ElevatedButton.styleFrom(
                backgroundColor:
                Color(0xffC84040).withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // <-- Radius
                )),
          ),
          width: double.infinity,
          margin: EdgeInsets.only(left: 0, right: 0, bottom: 0,top: 20),
        )
*/

      ],)),),
      isApiContentLoading?Positioned(top: 0,bottom: 0,left: 0,right: 0,
        child:  Container(
          height: 150,
          width: 150,
          child: Center(
              child: Lottie.asset(
                  "assets/images/feed_preloader.json",height: 150,width: 150)
          ),
        ),
      ):Positioned(top: 0,bottom: 0,left: 0,right: 0,child: Container(),)
    ],),));
  }
  Future<void> deleteAccountApi() async {
  /*  isApiContentLoading = true;
    setState(() {});*/
    try {
      String url = AppEnvironment.baseApiUrl+Constans.updateProfile;
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['accept'] = '*/*';
      request.headers['Authorization'] =
      "Bearer ${PreferenceUtils.getString(PreferenceUtils.SESSION_TOKEN, "")}";
      request.headers['Content-Type'] = 'multipart/form-data';
      request.fields['userId'] =
          PreferenceUtils.getString(PreferenceUtils.USER_ID, "");
      request.fields['isDeleted'] = 'true';

      request.fields['email'] = profileObject!.email;
      var response = await request.send();
      print(response.statusCode);
      if (response.statusCode == 200) {
         PreferenceUtils.clear();
         Navigator.pushNamedAndRemoveUntil(context, HomeWidgetRoutes.SplashScreen, (route) => false);
      } else {
        isApiContentLoading = false;
        setState(() {});
      }
    } catch (e) {
      print('Error: $e');
      isApiContentLoading = false;
      setState(() {});
    }
  }
  void showDeleteDialog(bool isDeleteAccount) {
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
                      isDeleteAccount?"Delete your account?":"Are you sure?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: "Causten-Medium"),
                    ),
                    margin: EdgeInsets.only(top: 10),
                  ),
                  Container(
                    child: Text(
                      isDeleteAccount?"This action cannot be undone.":"Signing out will clear today's progress",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(0xff888888),
                          fontSize: 14,
                          fontFamily: "Causten-Regular"),
                    ),
                    margin: EdgeInsets.only(top: 10, left: 15, right: 15),
                  ),
                  GestureDetector(
                    onTapDown: (dertails) {
                      Navigator.pop(context);
                      if(isDeleteAccount){
                        deleteAccountApi();
                      }else{
                        _googleSignIn?.signOut();
                        PreferenceUtils.clear();
                        Navigator.of(context).pop();
                        Navigator.pushNamedAndRemoveUntil(context, HomeWidgetRoutes.SplashScreen, (route) => false);

                      }

                    },
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(
                          left: 10, right: 10, top: 20, bottom: 10),
                      padding: EdgeInsets.only(
                          left: 15, right: 15, top: 15, bottom: 15),
                      child: Text(
                        isDeleteAccount?"Delete":"Yes",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: "Causten-Bold"),
                        textAlign: TextAlign.center,
                      ),
                      decoration: BoxDecoration(
                          color: Color(0xffC84040),
                          borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                  GestureDetector(
                    onTapDown: (dertails) {
                      Navigator.of(context).pop();
                      },
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(
                          left: 10, right: 10, top: 0, bottom: 20),
                      padding: EdgeInsets.only(
                          left: 15, right: 15, top: 15, bottom: 15),
                      child: Text("No",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: "Causten-Medium"),
                          textAlign: TextAlign.center),
                    ),
                  )
                ],
              ),
            ),
          );
        }); // Custom dialog widget
      },
    );
  }

}
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}
