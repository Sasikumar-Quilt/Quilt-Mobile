

import 'package:device_info_plus/device_info_plus.dart';
import 'package:intl/intl.dart';
import 'package:quilt/src/PrefUtils.dart';
import 'package:quilt/src/Utility.dart';
import 'package:quilt/src/api/Constants.dart';

import 'BaseApiService.dart';
import 'NetworkApiService.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
class ApiHelper {
  ApiHelper._();

  static final ApiHelper _instance = ApiHelper._();

  factory ApiHelper() {
    return _instance;
  }
  Future<ApiResponse> isAlreadyRegisteredApi(String text) async {
    var request = {
      "email": text,
    };
    BaseApiService baseApiService = NetworkApiService();
    ApiResponse response =
    await baseApiService.postResponse(Constans.isAlreadyRegistered,request, Status.MOBILE_NUMBER_LOGIN);
    return response;
  }
  Future<ApiResponse> sendOtpEmail(String text) async {
    var request = {
      "email": text,
    };
    BaseApiService baseApiService = NetworkApiService();
    ApiResponse response =
    await baseApiService.postResponse(Constans.sendOtpEmail,request, Status.MOBILE_NUMBER_LOGIN);
    return response;
  }
  Future<ApiResponse> appleSignIn(String text) async {
    var deviceType="IOS";
    if(defaultTargetPlatform == TargetPlatform.android){
      deviceType="ANDROID";
    }
    var request = {
      "idToken": text,
    };
    BaseApiService baseApiService = NetworkApiService();
    ApiResponse response =
    await baseApiService.postResponse(Constans.loginWithApple,request, Status.MOBILE_NUMBER_LOGIN);
    return response;
  }
  Future<ApiResponse> googleSign(String text) async {
    var deviceType="IOS";
    if(defaultTargetPlatform == TargetPlatform.android){
      deviceType="ANDROID";
    }
    var request = {
      "token": text,
      "deviceType": deviceType,
    };
    BaseApiService baseApiService = NetworkApiService();
    ApiResponse response =
    await baseApiService.postResponse(Constans.loginWithGoogle,request, Status.MOBILE_NUMBER_LOGIN);
    return response;
  }
  Future<ApiResponse> verifyOtpEmail(String text,int code) async {
    var request = {
      "email": text,
      "otp":code
    };
    BaseApiService baseApiService = NetworkApiService();
    ApiResponse response =
    await baseApiService.postResponse(Constans.verifyOtpEmail,request, Status.MOBILE_NUMBER_LOGIN);
    return response;
  }
  Future<ApiResponse> verifyOtp(String mobileNumber,String otp) async {
    var request = {
      "countryCode": "+91",
      "phoneNumber": mobileNumber,
      "otp": int.parse(otp),
    };
    BaseApiService baseApiService = NetworkApiService();
    ApiResponse response =
    await baseApiService.postResponse(Constans.otpVerify,request, Status.MOBILE_NUMBER_LOGIN);
    return response;
  }
  Future<ApiResponse> mobileNumberLoginApi(String text) async {
    var request = {
      "countryCode": "+91",
      "phoneNumber": text
    };
    BaseApiService baseApiService = NetworkApiService();
    ApiResponse response =
    await baseApiService.postResponse(Constans.sendOtp,request, Status.MOBILE_NUMBER_LOGIN);
    return response;
  }
  Future<ApiResponse> getContentList() async {
    BaseApiService baseApiService = NetworkApiService();
    ApiResponse response =
    await baseApiService.getResponse(Constans.contentList+PreferenceUtils.getString(PreferenceUtils.USER_ID, ""), Status.MOBILE_NUMBER_LOGIN);
    return response;
  }
  Future<ApiResponse> getProfileDetails() async {
    BaseApiService baseApiService = NetworkApiService();
    ApiResponse response =
    await baseApiService.getResponse(Constans.getProfile+PreferenceUtils.getString(  PreferenceUtils.USER_ID, ""), Status.MOBILE_NUMBER_LOGIN);
    return response;
  }
  Future<ApiResponse> getPromptNames(String word,bool isPositive) async {
    BaseApiService baseApiService = NetworkApiService();
    String moodType=isPositive?"POSITIVE":"NEGATIVE";
    ApiResponse response =
    await baseApiService.getResponse(Constans.getSimilarPrompt+word+"&moodType="+moodType, Status.MOBILE_NUMBER_LOGIN);
    return response;
  }
  Future<ApiResponse> getContentLists(String id,int currentSize,bool isSurpriseMe,bool isHashTag) async {
    BaseApiService baseApiService = NetworkApiService();
    String request=Constans.getContentList+PreferenceUtils.getString(PreferenceUtils.USER_ID, "")+"&moodClusterId="+id+"&page=$currentSize&pageSize=10";
    if(isSurpriseMe){
      request=Constans.getContentList+PreferenceUtils.getString(PreferenceUtils.USER_ID, "")+"&page=$currentSize&pageSize=10&isSurpriseMe=$isSurpriseMe";
    }
    if(isHashTag){
      request=Constans.getContentList+PreferenceUtils.getString(PreferenceUtils.USER_ID, "")+"&page=$currentSize&pageSize=10&hashtagName=$id";

    }
    ApiResponse response =
    await baseApiService.getResponse(request, Status.MOBILE_NUMBER_LOGIN);
    return response;
  }
  Future<ApiResponse> getFavList() async {
    BaseApiService baseApiService = NetworkApiService();
    String request=Constans.getFavorites+PreferenceUtils.getString(PreferenceUtils.USER_ID, "");

    ApiResponse response =
    await baseApiService.getResponse(request, Status.MOBILE_NUMBER_LOGIN);
    return response;
  }
  Future<ApiResponse> getContentListWithMoodName(String id,int currentSize) async {
    BaseApiService baseApiService = NetworkApiService();
    ApiResponse response =
    await baseApiService.getResponse(Constans.getContentList+PreferenceUtils.getString(PreferenceUtils.USER_ID, "")+"&moodName="+id+"&page=$currentSize&pageSize=10", Status.MOBILE_NUMBER_LOGIN);
    return response;
  }
  Future<ApiResponse> getJournalList(int date) async {
    BaseApiService baseApiService = NetworkApiService();
    ApiResponse response =
    await baseApiService.getResponse(Constans.getJournalList+PreferenceUtils.getString(PreferenceUtils.USER_ID, "")+"&date="+date.toString(), Status.MOBILE_NUMBER_LOGIN);
    return response;
  }
  Future<ApiResponse> getCollections() async {
    BaseApiService baseApiService = NetworkApiService();
    ApiResponse response =
    await baseApiService.getResponse(Constans.getCollection+PreferenceUtils.getString(PreferenceUtils.USER_ID, ""), Status.MOBILE_NUMBER_LOGIN);
    return response;
  }
  Future<ApiResponse> deleteCollection(String id) async {
    BaseApiService baseApiService = NetworkApiService();
    ApiResponse response =
    await baseApiService.deleteResponse(Constans.getCollection+PreferenceUtils.getString(PreferenceUtils.USER_ID, "")+"&collectionId="+id, Status.MOBILE_NUMBER_LOGIN);
    return response;
  }
  Future<ApiResponse> updateFavorite(String id,String collectionId,bool isFavorite) async {
    var request;
    request = {
      "userId": PreferenceUtils.getString(PreferenceUtils.USER_ID, ""),
      "collectionId": collectionId,
      "contentId": id,
      "isFavourite":isFavorite
    };

    BaseApiService baseApiService = NetworkApiService();
    ApiResponse response =
    await baseApiService.postResponse(Constans.favouritesUpdate,request, Status.METRIC_DATA);
    return response;
  }
  Future<ApiResponse> createCollection(String collectionName,String id) async {
    var request;
    request = {
      "userId": PreferenceUtils.getString(PreferenceUtils.USER_ID, ""),
      "collectionId": id,
      "collectionName": collectionName,
    };

    BaseApiService baseApiService = NetworkApiService();
    ApiResponse response =
    await baseApiService.postResponse(Constans.createCollection,request, Status.METRIC_DATA);
    return response;
  }
  Future<ApiResponse> updateOverallFeedback(String rating,String overallFeedback) async {
    var request;
    request = {
      "userId": PreferenceUtils.getString(PreferenceUtils.USER_ID, ""),
      "rating": rating,
      "overallFeedback": overallFeedback,
    };

    BaseApiService baseApiService = NetworkApiService();
    ApiResponse response =
    await baseApiService.postResponse(Constans.overallFeedback,request, Status.METRIC_DATA);
    return response;
  }
  Future<ApiResponse> logContent(String id,bool isFav,bool isContent) async {
    var request;
    if(isContent){
       request = {
        "id": id,
        "isContentConsumed": true,
      };
    }else{
       request = {
        "id": id,
        "isFavourite": isFav,
      };
    }

    BaseApiService baseApiService = NetworkApiService();
    ApiResponse response =
    await baseApiService.postResponse(Constans.logContent,request, Status.METRIC_DATA);
    return response;
  }
  Future<ApiResponse> updateJournal(String id,String text) async {

    var request = {
      "userContentId": id,
      "journalResponse": text,
      "userId": PreferenceUtils.getString(  PreferenceUtils.USER_ID, ""),
    };
    BaseApiService baseApiService = NetworkApiService();
    ApiResponse response =
    await baseApiService.postResponse(Constans.updateJournal,request, Status.METRIC_DATA);
    return response;
  }
  Future<ApiResponse> deleteJournal(String id,String text) async {

    var request = {
      "userContentId": id,
      "isDeleted": true,
    };
    BaseApiService baseApiService = NetworkApiService();
    ApiResponse response =
    await baseApiService.postResponse(Constans.updateJournal,request, Status.METRIC_DATA);
    return response;
  }
  Future<ApiResponse> addJournal(String id,String text,String date) async {

    var request = {
      "userId": PreferenceUtils.getString(  PreferenceUtils.USER_ID, ""),
      "contentId": id,
      "journalResponse": text,
      "date": date,
      "isDeleted": false,
    };
    BaseApiService baseApiService = NetworkApiService();
    ApiResponse response =
    await baseApiService.postResponse(Constans.updateJournal,request, Status.METRIC_DATA);
    return response;
  }
  Future<ApiResponse> logEmi(String id) async {

    var request = {
      "userId": PreferenceUtils.getString(  PreferenceUtils.USER_ID, ""),
      "contentId": id,
      "contentResponse": "Good",
    };
    BaseApiService baseApiService = NetworkApiService();
    ApiResponse response =
    await baseApiService.postResponse(Constans.logEmi,request, Status.METRIC_DATA);
    return response;
  }
  Future<ApiResponse> updateFirebaseToken(String fcmToken) async {
    var request = {
      "userId": PreferenceUtils.getString(  PreferenceUtils.USER_ID, ""),
      "deviceId":fcmToken
    };
    BaseApiService baseApiService = NetworkApiService();
    ApiResponse response =
    await baseApiService.postResponse(Constans.updateContentFeedback,request, Status.FCM);
    return response;
  }
  Future<ApiResponse> updateContentFeedback(int feedback,String id) async {
    String cFeedback="Worse";
    if(feedback==1){
      cFeedback="Better";
    }else  if(feedback==2){
      cFeedback="Good";
    }else  if(feedback==3){
      cFeedback="Neutral";
    }else  if(feedback==4){
      cFeedback="Bad";
    }
    var request = {
      "userId": PreferenceUtils.getString(  PreferenceUtils.USER_ID, ""),
      "contentId": id,
      "moodId": PreferenceUtils.getString(  PreferenceUtils.MOODID, ""),
      "comment": cFeedback,
      "isDeleted": false,
    };
    BaseApiService baseApiService = NetworkApiService();
    ApiResponse response =
    await baseApiService.postResponse(Constans.updateContentFeedback,request, Status.METRIC_DATA);
    return response;
  }
  Future<ApiResponse> getRewardDetails() async {

    var request = {
      "userId": PreferenceUtils.getString(PreferenceUtils.USER_ID, ""),
      "fromDate": Utility.getDateWithAdditional(Constans.DATE_FORMAT_1,5),
    };
    BaseApiService baseApiService = NetworkApiService();
    ApiResponse response =
    await baseApiService.postResponse(Constans.rewardDetails,request, Status.METRIC_DATA);
    return response;
  }
  Future<ApiResponse> postMetricData(int stepCount) async {
    List<Map<String, Object>> mertricList=[];
    mertricList.add({
      "timestamp": Utility.getDate(Constans.DATE_FORMAT_1),
      "stepCount": stepCount,
    });
    var request = {
      "userId": PreferenceUtils.getString(PreferenceUtils.USER_ID, ""),
      "metricType": "STEP_COUNT",
      "dataType": "ACCUMULATED",
      "metricData":mertricList
    };
    BaseApiService baseApiService = NetworkApiService();
    ApiResponse response =
    await baseApiService.postResponse(Constans.postMetric,request, Status.METRIC_DATA);
    return response;
  }
  Future<ApiResponse> updateUserDetails(String emailId,String fName,String lastName,String gender,String dob,int age,String clinicId) async {

    var request = {
      "userId": PreferenceUtils.getString(PreferenceUtils.USER_ID, ""),
      "firstName": fName,
      "gender": gender.toUpperCase(),
      "timeZone": "GMT+3:30",
      "age":age,
      "isDeleted": false,
      "clinicId": clinicId,
    };
    BaseApiService baseApiService = NetworkApiService();
    ApiResponse response =
    await baseApiService.postResponse(Constans.updateProfile,request, Status.METRIC_DATA);
    return response;
  }
  Future<ApiResponse> refreshToken() async {
    var request = {
      "userId": PreferenceUtils.getString(PreferenceUtils.USER_ID, ""),
    };
    BaseApiService baseApiService = NetworkApiService();
    ApiResponse response =
    await baseApiService.postResponse(Constans.refreshToken,request, Status.REFRESH_TOKEN);
    return response;
  }

  Future<ApiResponse> updateFavourite(bool isEnabled,String id) async {
    var request = {
      "userId": PreferenceUtils.getString(PreferenceUtils.USER_ID, ""),
      "gameId":id,
      "isFavourite":isEnabled,
    };
    BaseApiService baseApiService = NetworkApiService();
    ApiResponse response =
    await baseApiService.postResponse(Constans.favourite,request, Status.REFRESH_TOKEN);
    return response;
  }
  Future<ApiResponse> updateAssessment(String surveyId,List<dynamic>answer) async {
    DateTime now = DateTime.now();
    DateFormat dateFormat = DateFormat("EEE MMM dd yyyy HH:mm:ss 'GMT'");

    String formattedDate = dateFormat.format(now);
    String timeZoneOffset = now.timeZoneOffset.isNegative ? '-' : '+';
    timeZoneOffset += now.timeZoneOffset.abs().inHours.toString().padLeft(2, '0');
    timeZoneOffset += (now.timeZoneOffset.inMinutes.remainder(60)).toString().padLeft(2, '0');

    var request = {
      "userId": PreferenceUtils.getString(PreferenceUtils.USER_ID, ""),
      "surveyId": surveyId,
      "date": '$formattedDate$timeZoneOffset',
      "questions": answer
    };
    BaseApiService baseApiService = NetworkApiService();
    ApiResponse response =
    await baseApiService.postResponse(Constans.updateAssessment,request, Status.METRIC_DATA);
    return response;
  }
  Future<ApiResponse> updateFeedbackSurvey(String surveyId,List<dynamic>answer) async {
    DateTime now = DateTime.now();
    DateFormat dateFormat = DateFormat("EEE MMM dd yyyy HH:mm:ss 'GMT'");

    String formattedDate = dateFormat.format(now);
    String timeZoneOffset = now.timeZoneOffset.isNegative ? '-' : '+';
    timeZoneOffset += now.timeZoneOffset.abs().inHours.toString().padLeft(2, '0');
    timeZoneOffset += (now.timeZoneOffset.inMinutes.remainder(60)).toString().padLeft(2, '0');

    var request = {
      "userId": PreferenceUtils.getString(PreferenceUtils.USER_ID, ""),
      "feedbackId": surveyId,
      "date": '$formattedDate$timeZoneOffset',
      "questions": answer
    };
    BaseApiService baseApiService = NetworkApiService();
    ApiResponse response =
    await baseApiService.postResponse(Constans.updateFeedbackSurvey,request, Status.METRIC_DATA);
    return response;
  }
  Future<ApiResponse> updateUserEvent(dynamic request) async {

    BaseApiService baseApiService = NetworkApiService();
    ApiResponse response =
    await baseApiService.putRequest(Constans.updateContentFeedback,request, Status.USER_EVENT);
    return response;
  }
  Future<ApiResponse> getAssessmentList(String id) async {
    BaseApiService baseApiService = NetworkApiService();
    ApiResponse response =
    await baseApiService.getResponse(Constans.getAssessmentList+id, Status.MOBILE_NUMBER_LOGIN);
    return response;
  }

  Future<ApiResponse> getAllClinics() async {
    BaseApiService baseApiService = NetworkApiService();
    ApiResponse response =
    await baseApiService.getResponse(Constans.getAllClinics, Status.MOBILE_NUMBER_LOGIN);
    return response;
  }
}


