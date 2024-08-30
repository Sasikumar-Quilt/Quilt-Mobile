import 'package:flutter/cupertino.dart';

import '../PrefUtils.dart';
import '../Utility.dart';
import '../api/ApiHelper.dart';
import '../api/BaseApiService.dart';
import '../api/NetworkApiService.dart';
import '../api/Objects.dart';

abstract class BaseState<T extends StatefulWidget> extends State<T>{
  void refreshToken(int apiType) async {
    ApiHelper apiHelper = ApiHelper();
    ApiResponse apiResponse = await apiHelper.refreshToken();
    if (apiResponse.status == Status.COMPLETED) {
      RefreshTokenResponse refreshTokenResponse=RefreshTokenResponse.fromJson(apiResponse.data);
      if(refreshTokenResponse.sessionToken!=""){
        PreferenceUtils.setString(
            PreferenceUtils.SESSION_TOKEN, refreshTokenResponse.sessionToken);
        onRefreshToken(apiType);
      }
    } else {
      Utility.showSnackBar(
          context: context, message: apiResponse.message.toString());
    }
  }
  void onRefreshToken(int apiType);
}