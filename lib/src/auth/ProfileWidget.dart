import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quilt/src/base/BaseWidget.dart';

import '../../main.dart';
import '../PrefUtils.dart';
import '../Utility.dart';
import '../api/ApiHelper.dart';
import '../api/BaseApiService.dart';
import '../api/LoadingUtils.dart';
import '../api/NetworkApiService.dart';
import '../api/Objects.dart';
import 'ProfileMenuWidget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ProfileScreenState();
  }
}

class ProfileScreenState extends BaseState<ProfileScreen> {
  ApiHelper apiHelper = ApiHelper();
  ProfileObject? profileObject;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      getProfileData(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
            onPressed: () => {Navigator.pop(context)},
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            )),
        title: Text(
          "Profile",
          style: TextStyle(
              fontSize: 16,
              fontFamily: "Poppins-medium",
              color: Color(0xffEE2D76),
              fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(5),
          child: Column(
            children: [
              /// -- IMAGE
              Stack(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: const Image(
                            image: AssetImage("assets/images/default.jpg"))),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                  profileObject != null && profileObject!.status == 200
                      ? "${profileObject!.firstName} ${profileObject!.lastName}"
                      : "",
                  style: Theme.of(context).textTheme.headlineSmall),
              Container(
                child: Text(
                    profileObject != null && profileObject!.status == 200
                        ? "${profileObject!.countryCode} ${profileObject!.phoneNumber}"
                        : "",
                    style: Theme.of(context).textTheme.bodyMedium),
                margin: EdgeInsets.only(top: 5),
              ),
              //Text(profileObject!=null&&profileObject!.status==200?"${profileObject!.email}":"", style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 20),

              /// -- BUTTON
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () => {
                    if (profileObject != null && profileObject!.status == 200)
                      {
                        Navigator.pushNamed(
                                context, HomeWidgetRoutes.editProfile,
                                arguments: {"object": profileObject})
                            .then((value) => {getProfileData(false)})
                      }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xffEE2D76),
                      side: BorderSide.none,
                      shape: const StadiumBorder()),
                  child: const Text("Edit Profile",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              SizedBox(
                height: 20,
              ),

              /// -- MENU

              ProfileMenuWidget(
                  title: "Logout",
                  icon: Icons.logout,
                  textColor: Colors.red,
                  endIcon: false,
                  onPress: () {
                    showAlertDialog(context);
                  }),
            ],
          ),
        ),
      ),
    );
  }

  void getProfileData(bool isShow) async {
    if(isShow){
      LoadingUtils.instance.showLoadingIndicator("Receiving...", context);
    }
    ApiResponse apiResponse = await apiHelper.getProfileDetails();
    if(isShow){
      LoadingUtils.instance.hideOpenDialog(context);
    }
    if (apiResponse.status == Status.COMPLETED) {
      profileObject = ProfileObject.fromJson(apiResponse.data);
      if (profileObject!.status == 401) {
        refreshToken(1);
      }
      print(profileObject!.status);
      setState(() {});
    } else {
      Utility.showSnackBar(
          context: context, message: apiResponse.message.toString());
    }
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel",
          style: TextStyle(
            color: Color(0xffEE2D76),
          )),
      onPressed: () {
        Navigator.of(context!, rootNavigator: true).pop('dialog');
      },
    );
    Widget continueButton = TextButton(
      child: Text("Logout",
          style: TextStyle(
            color: Color(0xffEE2D76),
          )),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        PreferenceUtils.setBool("isLoggedIn", false);
        PreferenceUtils.setBool("isHealthConnected", false);
        Navigator.pushNamedAndRemoveUntil(
            context, HomeWidgetRoutes.mobileNumberScreen, (route) => false);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Logout"),
      content: Text(
        "Are you sure? You want to logout?",
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  void onRefreshToken(int apiType) {
    getProfileData(false);
  }
}
