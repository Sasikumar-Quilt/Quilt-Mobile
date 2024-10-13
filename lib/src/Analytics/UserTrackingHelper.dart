import 'dart:convert';

import 'package:quilt/src/api/NetworkApiService.dart';

import '../PrefUtils.dart';
import '../Utility.dart';
import '../api/ApiHelper.dart';
import '../api/BaseApiService.dart';
import '../api/Constants.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../database/DatabaseHelper.dart';

class UserTrackingHelper {
  static final UserTrackingHelper _instance = UserTrackingHelper._internal();
  String currentVersion = "";
  bool isHashTag = false;
  String hashTag = "";
  DataBaseHelper? dataBaseHelper;

  factory UserTrackingHelper() {
    return _instance;
  }

  Future<void> init() async {
    dataBaseHelper=DataBaseHelper.instance;
    checkExistUserEventRequest();
    getCurrentVersion().then((value) => {currentVersion = value});
  }

  void setHashTag(bool isHashTag) {
    this.isHashTag = isHashTag;
  }

  void setHashTagName(String hashTag) {
    this.hashTag = hashTag;
  }

  Future<String> getCurrentVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  UserTrackingHelper._internal();

  List<Event> eventList = [];
  ApiHelper apiHelper = ApiHelper();

  void saveUserEntries(String interactionType, String contentId) {
    print("saveUserEntries");
    print(contentId);
    String eventType = "user_views";
    if (interactionType == "app_open" ||
        interactionType == "app_close" ||
        interactionType == "app_minimise") {
      eventType = "system_event";
    }
    Event event = new Event(
        contentId: contentId,
        eventType: eventType,
        interactionType: interactionType,
        timestamp: Utility.getUtcDate(Constans.DATE_FORMAT_1));
   // eventList.add(event);
    String moodId=PreferenceUtils.getString(PreferenceUtils.MOODID, "");
    if(Utility.isEmpty(moodId)){
      moodId="empty";
    }

    dataBaseHelper?.getStoredRequestsByMoodId(moodId).then((value) => {
      getRequestList(value,event,moodId)
    });
  }
  void fetchLastEvent(){
    String moodId=PreferenceUtils.getString(PreferenceUtils.MOODID, "");
    dataBaseHelper?.getLastStoredRequestByMoodId(moodId).then((value) => {
      saveAppCloseEvent(value)
    });
  }
  void saveAppCloseEvent(ApiRequestModel? value){
    if(value!=null){
      List<Event>eventList=[];
      eventList=jsonStringToEventList(value.jsonRequest);
      if(eventList[eventList.length-1].interactionType=="app_minimise"){
        Event event = new Event(
            contentId: eventList[eventList.length-1].contentId,
            eventType: eventList[eventList.length-1].eventType,
            interactionType: "app_close",
            timestamp:eventList[eventList.length-1].timestamp);
        // eventList.add(event);
        String moodId=PreferenceUtils.getString(PreferenceUtils.MOODID, "");
        if(Utility.isEmpty(moodId)){
          moodId="empty";
        }
        dataBaseHelper?.getStoredRequestsByMoodId(moodId).then((value) => {
          getRequestList(value,event,moodId)
        });
      }
    }
  }
  void getRequestList(List<ApiRequestModel> value,Event event,String moodId){
    List<Event>eventList=[];
    if(value.isNotEmpty){
      List<ApiRequestModel> sList=value;
      eventList=jsonStringToEventList(sList[0].jsonRequest);
      eventList.add(event);
    }else{
      eventList.add(event);
    }
    print("insertEventData");
    print(event.contentId);
    print(event.interactionType);
    print(eventListToJsonString(eventList));
    dataBaseHelper
        ?.storeApiRequest(eventListToJsonString(eventList),moodId);
  }
  String eventListToJsonString(List<Event> eventList) {
    return jsonEncode(eventList.map((event) => event.toJson()).toList());
  }
  List<Event> jsonStringToEventList(String jsonString) {
    List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => Event.fromJson(json)).toList();
  }

  void checkExistUserEventRequest() async {
    dataBaseHelper?.getStoredRequests().then((value) => {
      uploadExistingData(value)
    });

  }
  void uploadExistingData(List<ApiRequestModel>? list){
    if(list==null||list.isEmpty){
      return;
    }
    for (int i = 0; i < list.length; i++) {
      DateTime dateTime = DateTime.now();
      UserRequest userRequest = UserRequest(
          userId: PreferenceUtils.getString(PreferenceUtils.USER_ID, ""),
          appVersion: currentVersion,
          timezone: dateTime.timeZoneName,
          hashtagId: list[i].moodId.contains("#")?list[i].moodId:"",
          moodId:list[i].moodId.contains("#")
              ? ""
              : list[i].moodId,
          events: jsonStringToEventList(list[i].jsonRequest),
          timestamp: Utility.getUtcDate(Constans.DATE_FORMAT_1));
      var data=userRequest.toJson();
      data.removeWhere((key, value) {
        if (value == null) return true; // Remove null values
        if (value is String && value.isEmpty) return true; // Remove empty strings
        if (value is String && value == "empty") return true; // Remove values that are "empty"
        if (value is List && value.isEmpty) return true; // Remove empty lists
        if (value is Map && value.isEmpty) return true; // Remove empty maps
        return false;
      });
      print("eventApiRequestTime");
      print(DateTime.timestamp());
      apiHelper.updateUserEvent(data).then((value) => {
      print(DateTime.timestamp()),
      print("eventApiResponseTime"),
        if (value.status == Status.COMPLETED)
          {dataBaseHelper?.deleteApiRequest(list[i].moodId)}
      });
    }

  }

/*
  void sendUserTrackingRequest() async {
    if (eventList.isEmpty) return;
    DateTime dateTime = DateTime.now();
    UserRequest userRequest = UserRequest(
        userId: PreferenceUtils.getString(PreferenceUtils.USER_ID, ""),
        appVersion: currentVersion,
        timezone: dateTime.timeZoneName,
        hashtagId: isHashTag?hashTag:"",
        moodId:isHashTag
            ? ""
            : PreferenceUtils.getString(PreferenceUtils.MOODID, ""),
        events: eventList,
        timestamp: Utility.getUtcDate(Constans.DATE_FORMAT_1));
    var data=userRequest.toJson();
    data.removeWhere((key, value) {
      if (value == null) return true; // Remove null values
      if (value is String && value.isEmpty) return true; // Remove empty strings
      if (value is List && value.isEmpty) return true; // Remove empty lists
      if (value is Map && value.isEmpty) return true; // Remove empty maps
      return false;
    });
    String jsonString = jsonEncode(data);
print("sendUserTrackingRequest");
print(dataBaseHelper);
    dataBaseHelper
        ?.storeApiRequest(jsonString)
        .then((value) async => {sendApiRequest(data, value!)});
  }
*/

  /*void sendApiRequest(dynamic request, int id) async {
    print(request);
    print("sendApiRequest");
    ApiResponse apiResponse;
    apiResponse = await apiHelper.updateUserEvent(request);
    if (apiResponse.status == Status.COMPLETED) {
      dataBaseHelper?.deleteApiRequest(id);
    }
  }*/
}

class UserRequest {
  final String userId;
  final String appVersion;
  final String timezone;
  final String moodId;
  final String hashtagId;
  final String timestamp;
  final List<Event> events;

  UserRequest(
      {required this.userId,
      required this.appVersion,
      required this.timezone,
      required this.moodId,
      required this.hashtagId,
      required this.events,
      required this.timestamp});

  // Method to convert a UserRequest instance into a JSON map
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'appVersion': appVersion,
      'timezone': timezone,
      'moodId': moodId,
      'hashtagId': hashtagId,
      'timestamp': timestamp,
      'events': events.map((event) => event.toJson()).toList(),
    };
  }

  // Method to create a UserRequest instance from a JSON map
  factory UserRequest.fromJson(Map<String, dynamic> json) {
    return UserRequest(
      userId: json['userId'],
      appVersion: json['appVersion'],
      timezone: json['timezone'],
      moodId: json['moodId'],
      hashtagId: json["hashtagId"],
      timestamp: json['timestamp'],
      events: (json['events'] as List<dynamic>)
          .map((eventJson) => Event.fromJson(eventJson))
          .toList(),
    );
  }
}

class Event {
  final String contentId;
  final String eventType;
  final String interactionType;
  final String timestamp;

  Event({
    required this.contentId,
    required this.eventType,
    required this.interactionType,
    required this.timestamp,
  });

  // Method to convert an Event instance into a JSON map
  Map<String, dynamic> toJson() {
    return {
      'contentId': contentId,
      'eventType': eventType,
      'interactionType': interactionType,
      'timestamp': timestamp,
    };
  }

  // Method to create an Event instance from a JSON map
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      contentId: json['contentId'],
      eventType: json['eventType'],
      interactionType: json['interactionType'],
      timestamp: json['timestamp'],
    );
  }
}
