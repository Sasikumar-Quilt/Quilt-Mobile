import 'dart:convert';

import 'package:event_bus_plus/event_bus_plus.dart';
import 'package:quilt/src/Utility.dart';

class UserResponse {
  String message = "";
  int status = 0;
  int errorCode = 0;
  String sessionToken = "";
  String userId = "";
  bool isFirstLogin = false;
  bool isUserProfileUpdated = false;

  UserResponse.fromJson(Map<String, dynamic> json) {
    print(json);
    message = json['message'] != null ? json['message'] : "";
    status = json['status'] != null ? json['status'] : 0;
    errorCode = json['errorCode'] != null ? json['errorCode'] : 0;
    if (json["data"] != null) {
      if(json["data"]["errorCode"]==null){
        sessionToken = json["data"]["sessionToken"];
        userId = json["data"]["userId"];
        isFirstLogin = json["data"]["isFirstLogin"];
        isUserProfileUpdated = json["data"]["isUserProfileUpdated"] ?? false;
      }else{
        errorCode=json["data"]["errorCode"];
        message=json["data"]['message'] != null ? json["data"]['message'] : "";
      }

    }
  }
}

class RefreshTokenResponse {
  String sessionToken = "";

  RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    sessionToken = json["sessionToken"] ?? "";
  }
}

class SliderList {
  String message = "";
  int status = 0;
  List<AnimationObject> animationList = [];

  SliderList.fromJson(Map<String, dynamic> json) {
    message = json['message'] as String;
    status = json['status'] != null ? json['status'] : 0;
    if (json["data"] != null && json["data"].length > 0) {
      for (int i = 0; i < json["data"].length; i++) {
        var obj = json["data"][i]["animations"];
        var content = json["data"][i]["content"];
        AnimationObject animationObject = new AnimationObject();
        animationObject.contentType = json["data"][i]["contentType"];
        animationObject.favourite = json["data"][i]["favourite"];
        animationObject.url = jsonEncode(obj["animation"]);
        animationObject.id = json["data"][i]["id"];
        animationObject.content = content != null ? content["content"] : "";
        animationList.add(animationObject);
      }
    }
  }
}

class AnimationObject {
  String contentType = "";
  String url = "";
  String content = "";
  String id = "";
  bool favourite = false;
}

class LoginResponse {
  String message = "";
  int status = 0;
  int errorCode = 0;
  bool isAlreadyRegistered = false;

  LoginResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'].toString();
    status = json['status'] != null ? json['status'] : 0;
    errorCode = json['errorCode'] != null ? json['errorCode'] : 0;
    if (json["data"] != null) {
      if (json["data"]["isAlreadyRegistered"] != null) {
        isAlreadyRegistered = json["data"]["isAlreadyRegistered"];
      }
    }
  }
}
class AssessmentResponse {
  String message = "";
  int status = 0;
  String triggerMessage = "";

  AssessmentResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'].toString();
    triggerMessage = json['triggerMessage']??"";
    status = json['status'] != null ? json['status'] : 0;

  }
}
class PostMetricResponse {
  String message = "";
  String metricType = "";
  String rewards = "";
  int status = 0;

  PostMetricResponse.fromJson(Map<String, dynamic> json)
      : message = json['message'] as String,
        status = json['status'] != null ? json['status'] : 0,
        rewards = json['extraData'] != null
            ? json['extraData']['rewards'].toString()
            : "",
        metricType =
            json['extraData'] != null ? json['extraData']['metricType'] : "";
}

class RewardsDetailsResponse {
  String message = "";
  String currentUserWalletBalance = "";
  String totalEarnedMinusSurvey = "";
  List<String> reasons = [];
  int status = 0;

  RewardsDetailsResponse.fromJson(Map<String, dynamic> json) {
    if (json['userId'] != null) {
      currentUserWalletBalance = json['currentUserWalletBalance'].toString();
      totalEarnedMinusSurvey = json['totalEarnedMinusSurvey'].toString();
      if (json["reasons"] != null && json["reasons"].length > 0) {
        for (int i = 0; i < json["reasons"].length; i++) {
          reasons.add(json["reasons"][i]);
        }
      }
    }
  }
}

class ProfileObject {
  String message = "";
  String firstName = "";
  String lastName = "";
  String email = "";
  String phoneNumber = "";
  String countryCode = "";
  String gender = "";
  String timeZone = "";
  String dob = "";
  int status = 0;
  int errorCode = 0;

  ProfileObject.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    status = json['status'] != null ? json['status'] : 0;
    if (json["data"] != null) {
      var pData = json["data"];
      firstName = pData["firstName"];
      lastName = pData["lastName"];
      email = pData["email"];
      phoneNumber = pData["phoneNumber"];
      countryCode = pData["countryCode"];
      gender = pData["gender"];
      dob = pData["dob"];
      timeZone = pData["timeZone"];
    }
  }
}

//prompt
class ResponseModel {
  String? message = "";
  int? status = 0;
  Cluster? data;
  bool isShow=false;
  bool canShow=false;
  List<Mood>? moods=[];
  ResponseModel.fromJson(Map<String, dynamic> json,String input) {
    message = json['message'];
    status = json['status'];
    if (json['data'] != null) {
      json['data'].forEach((key, value) {
        if (key != "word") {
          print(key);
          print("key123");
          data = Cluster.fromJson(value);
          if(data!=null&&data!.moods!=null&&data!.moods!.length>0){
            moods!.addAll(data!.moods!);
          }
        }
      });
      if(moods!.isNotEmpty){
        List<Mood> lists=moods!.where((element) => element.moodName==input.trim()).toList();
        if(input!=""&&lists.isNotEmpty){
          isShow=true;
          Mood mood=lists[0];
          if(mood.canShow!){
            canShow=true;
          }
        }

        moods!.removeWhere((element) => element.canShow==false);
      }
    }
  }
}

class Cluster {
  String? clusterName = "";
  String? clusterId = "";
  List<Mood>? moods=[];

  Cluster({this.clusterName, this.clusterId, this.moods});

  factory Cluster.fromJson(Map<String, dynamic> json) {
    var list = json['moods'] as List;
    List<Mood> moodsList=[];
    if(json['clusterName']!=null){
      Mood mood=Mood();
      print(json['clusterName']);
      mood.moodName=json['clusterName'];
      mood.moodClusterId=json['clusterId'];
      mood.clusterId=json['clusterId'];
      mood.canShow=json['canShow']??true;
      moodsList.add(mood);
    }
    moodsList.addAll(list.map((i) => Mood.fromJson(i)).toList());

    return Cluster(
      clusterName: json['clusterName'],
      clusterId: json['clusterId'],
      moods: moodsList,
    );
  }
}

class Mood {
  String? moodName;
  String? moodClusterId;
  String? clusterId;
  bool? canShow=false;

  Mood({this.moodName, this.moodClusterId, this.clusterId,this.canShow});

  factory Mood.fromJson(Map<String, dynamic> json) {
    return Mood(
      moodName: json['moodName'],
      moodClusterId: json['moodClusterId'],
      clusterId: json['clusterId'],
      canShow: json['canShow']??true,
    );
  }
}

class ContentList {
  List<ContentObj>? contentList;
  String message="";
  bool emptyResponse=false;
  ContentList.fromJson(Map<String, dynamic> json) {
    if(json["errorMessage"]!=null){
      message=json["errorMessage"];
    }
    if (json['data'] != null) {
      var list = json['data'] as List;
      if(list.isNotEmpty&&list.toString().length>250) {
        print("ContentList");
        print(list.length);
        contentList =
          list.map((i) => ContentObj.fromJson(i)).toList();
      }else{
        emptyResponse=true;
      }
    }else{
      if(json["errorMessage"]==null){
        message="No content mapped to this, Please try prompt again";
      }
    }
  }
}

class ContentObj {
  String? id;
  String? contentId;
  String? contentUrl;
  String? contentName;
  String? contentType;
  String? contentDuration;
  String? contentFormat;
  String? animations;
  bool? favourite;
  Duration? duration;
  bool isMute=false;
  int? lastPositon=0;
  bool isFav=false;
  List<String>hashtags=[];
  String collectionId="";
  String collectionName="";
  String videoURL="";
  String audioURL="";
  AssessmentList? assessmentList;
  bool isVideoAudio=false;
  ContentObj();
  ContentObj.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    print(json["id"]);
    print("contentid");
    contentId = json["contentId"];

    contentName = json["content"]["contentName"]??"";
    contentType = json["content"]["contentType"]??"";
    if(json["content"]["title"]!=null&&json["content"]["title"]["videoURL"]!=null){
      videoURL = json["content"]["title"]["videoURL"];
      audioURL = json["content"]["title"]["audioURL"]??"";
      isVideoAudio=true;
    }
    if(json["content"]["title"]!=null&&json["content"]["title"]["audioURL"]!=null){
      audioURL = json["content"]["title"]["audioURL"]??"";
    }
    if(contentType=="JOURNAL"){
      print("journal");
      print(json["content"]["content"]);
      contentUrl = json["content"]["content"]["question"];
      animations = json["content"]["content"]["imageURL"]??"";
    }else if(contentType=="EMI"||contentType=="INFO_TIDBITS"||contentType=="INFO_TIDBITS_OCD"||contentType=="INFO_TIDBITS_GENERAL"){
      print("emiContext");
      print(json["content"]["content"]);
      contentUrl = json["content"]["content"]["text"];
      animations = json["content"]["content"]["imageURL"];

    }else if(contentType=="ASSESSMENT"){
      print("ASSESSMENT");
      print(json["content"]["content"]);
      contentUrl = json["content"]["content"]["text"];
      animations = json["content"]["content"]["imageURL"];
      assessmentList=AssessmentList.fromJson(json["content"]["content"]);
    }else if(contentType=="FEEDBACK"){
      print("FEEDBACKFEEDBACK");
      print(json["content"]["content"]);
      assessmentList=AssessmentList.fromJson(json["content"]["content"]);
    }else{
      if(isVideoAudio){
        audioURL = json["content"]["content"]["content"]??"";
      }else{
        contentUrl = json["content"]["content"]["content"]??"";
      }

      if(json["content"]["animations"]!=null){
        animations = jsonEncode(json["content"]["animations"]["animation"])??"";
      }
    }
    contentDuration = json["content"]["contentDuration"].toString()??"";
    contentFormat = json["content"]["contentFormat"]??"";
    if(contentFormat=="VIDEO"){
      isVideoAudio=false;
    }
    collectionName = json["content"]["collectionName"]??"";
    collectionId = json["content"]["collectionId"]??"";
    isFav = json["content"]["isFavourite"]??false;
    if(json["content"]["hashtags"]!=null&&json["content"]["hashtags"].length>0){
      for(int k=0;k<json["content"]["hashtags"].length;k++){
        if(!Utility.isEmpty(json["content"]["hashtags"][k])){
            hashtags.add(json["content"]["hashtags"][k]);
        }
      }
    }
    favourite = json["content"]["favourite"]??false;
  }
  ContentObj.prefFromJson(Map<String, dynamic> json) {
    print("prefFromJson");
    print(json);
    id = json["id"];
    contentId = json["contentId"];
    contentUrl = json["contentUrl"];
    contentName = json["contentName"];
    contentType = json["contentType"];
    if(json["animations"]!=null){
      animations =json["animations"]??"";
    }

    contentDuration = json["contentDuration"]??"";
    contentFormat = json["contentFormat"]??"";
    favourite = json["favourite"]??false;
  }
  Map<String, dynamic> toJson() {
    return {
      "id": this.id,
      "contentId": this.contentId,
      "contentUrl": this.contentUrl,
      "contentName": this.contentName,
      "contentType": this.contentType,
      "animations": this.animations,
      "contentDuration": this.contentDuration,
      "contentFormat": this.contentFormat,
      "favourite": this.favourite,
    };
  }
}
class JournalList {
  List<JournalObject>? journalList;
  JournalList.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      var list = json['data'] as List;
      if(list.isNotEmpty) {
        journalList =
            list.map((i) => JournalObject.fromJson(i)).toList();
      }
    }
  }
}
class JournalObject{
  String? id;
  String? contentId;
  String? userId;
  String? response;
  String? createdAt;
  String? date;
  String? updatedAt;
  bool isSeen=false;
  String? question="";

  JournalObject.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    contentId = json["contentId"];
    userId = json["userId"];
    response = json["response"];
    question = json["ContentData"]["content"]["question"];
    createdAt = json["createdAt"];
    date = json["date"];
    updatedAt = json["updatedAt"];
  }
}

class CollectionList {
  List<CollectionObject>? collectionList=[];
  CollectionList.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      var list = json['data'] as List;
      if(list.isNotEmpty) {
        collectionList =
            list.map((i) => CollectionObject.fromJson(i)).toList();
      }
    }
  }
}
class CreateCollectionObject{
  CollectionObject? collectionObject;
  CreateCollectionObject.fromJson(Map<String, dynamic> json) {
    if(json["data"]!=null){
      collectionObject= CollectionObject();
      collectionObject!.collectionId=json["data"]["collectionId"];
      collectionObject!.collectionName=json["data"]["collectionName"];
    }

  }
  }
class CollectionObject{
  String? id;
  String? collectionId;
  String? collectionName;
  CollectionObject();
   CollectionObject.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    collectionId = json["collectionId"];
    collectionName = json["collectionDetails"]["collectionName"];

  }
}
class FavoriteListObject{
  String collectionId="";
  String collectionName="";
  List<ContentObj>? contentList=[];
}
class FavoriteList {
  List<FavoriteListObject>? favList=[];
  FavoriteList.fromJson(Map<String, dynamic> json) {
    if(json["data"]!=null&&json["data"].length>0){
      var lists=json["data"];
      for(int j=0;j<lists.length;j++){
        List<ContentObj>? contentList=[];
        FavoriteListObject favoriteListObject=FavoriteListObject();
        if (lists[j]["contents"] != null) {
          var list = lists[j]["contents"] as List;
          if(list.isNotEmpty) {
            for(int i=0;i<list.length;i++){
              if(list[i]==null){
                continue;
              }
              ContentObj contentObj=ContentObj();
              contentObj.id=list[i]["id"];
              contentObj.contentId=list[i]["id"];
              contentObj.contentName=list[i]["contentName"];
              contentObj.contentType=list[i]["contentType"];
              if(list[i]["title"]!=null&&list[i]["title"]["videoURL"]!=null){
                contentObj.videoURL = list[i]["title"]["videoURL"];
                contentObj.audioURL = list[i]["title"]["audioURL"]??"";
                contentObj.isVideoAudio=true;
              }
              if(list[i]["title"]!=null&&list[i]["title"]["audioURL"]!=null){
                contentObj.audioURL = list[i]["title"]["audioURL"]??"";
              }
              contentObj.contentDuration=list[i]["contentDuration"].toString();
              contentObj.contentFormat=list[i]["contentFormat"];
              if( contentObj.contentType=="JOURNAL"){
                print("journal");
                print(list[i]["content"]);
                contentObj.contentUrl = list[i]["content"]["question"];
                contentObj.animations = list[i]["content"]["imageURL"];
              }else if( contentObj.contentType=="EMI"||contentObj.contentType=="INFO_TIDBITS"||contentObj.contentType=="INFO_TIDBITS_OCD"||contentObj.contentType=="INFO_TIDBITS_GENERAL"){
                print("emiContext");
                print(list[i]["content"]["content"]);
                contentObj.contentUrl = list[i]["content"]["text"];
                contentObj.animations = list[i]["content"]["imageURL"];
              }else if( contentObj.contentType=="ASSESSMENT"){
                print("ASSESSMENT");
                print(json["content"]["content"]);
                contentObj.contentUrl = json["content"]["content"]["text"];
                contentObj.animations = json["content"]["content"]["imageURL"];
                contentObj.assessmentList=AssessmentList.fromJson(json["content"]["content"]);
              }else{
                if(contentObj.isVideoAudio){
                  contentObj.audioURL = list[i]["content"]["content"];
                }else{
                  contentObj.contentUrl = list[i]["content"]["content"];
                }
                if(list[i]["content"]["animations"]!=null){
                  contentObj.animations = jsonEncode(list[i]["content"]["animations"]["animation"])??"";
                }
              }
              contentList.add(contentObj);
            }
          }

        }
        favoriteListObject.contentList=contentList;
        favoriteListObject.collectionName=lists[j]["userContentCollectionDetails"]["collectionName"];
        favoriteListObject.collectionId=lists[j]["collectionId"];
        favList!.add(favoriteListObject);
      }
    }
  }
}
class AssessmentResult{
  AssessmentList? assessmentList;
  AssessmentResult.from(Map<String, dynamic> json){
    if(json["data"]!=null){
      assessmentList=AssessmentList.fromJson(json);
    }
  }
}
class AssessmentList{
  String assessmentName="";
  String assessmentTitle="";
  String assessmentDescription="";
  String assessmentPriority="";
  String id="";
  List<AssessmentObject> assessment_questions=[];
  AssessmentList.fromJson(Map<String, dynamic> json){
    if(json["assessment"]!=null||json["feedback"]!=null||json["data"]!=null){
      var obj;
      if(json["assessment"]!=null){
        obj=json["assessment"];
      }else if(json["data"]!=null){
        obj=json["data"];
      }else{
        obj=json["feedback"];
      }

      assessmentName=obj["assessmentName"]??"";
      id=obj["id"]??"";
      assessmentTitle=obj["assessmentTitle"]??"";
      assessmentDescription=obj["assessmentDescription"]??"";
      assessmentPriority=obj["assessmentPriority"]??"";
      var questionList=obj["assessment_questions"];
      for(int i=0;i<questionList.length;i++){
        AssessmentObject assessmentObject=new AssessmentObject();
        assessmentObject.id=questionList[i]["id"];
        assessmentObject.assessmentId=questionList[i]["assessmentId"];
        assessmentObject.questionText=questionList[i]["questionText"];
        assessmentObject.questionType=questionList[i]["questionType"];
        List<String>optionList=[];
        AssessmentQuestionsOptions assessmentQuestionsOptions=new AssessmentQuestionsOptions();
        if(questionList[i]["assessment_questions_options"]!=null){
          assessmentQuestionsOptions.id=questionList[i]["assessment_questions_options"]["id"];
          for(int j=0;j<questionList[i]["assessment_questions_options"]["options"].length;j++){
            optionList.add(questionList[i]["assessment_questions_options"]["options"][j]);
          }
          print("optionList");
          print(optionList.length);
          assessmentQuestionsOptions.options=optionList;
          assessmentObject.assessment_questions_options=assessmentQuestionsOptions;
        }

        assessment_questions.add(assessmentObject);
      }
    }
  }
}
class AssessmentObject{
  String id="";
  String assessmentId="";
  String questionText="";
  String questionType="";
  AssessmentQuestionsOptions? assessment_questions_options;
  String questionId="";
  String answer="";
  int total=0;

}
class AssessmentQuestionsOptions{
  String id="";
  List<String> options=[];
}
class NotificationEvent extends AppEvent{
  List<String> id;
  NotificationEvent(this.id);

  @override
  // TODO: implement props
  List<Object?> get props => id;


}
class MyEvent extends AppEvent{
  List<ContentObj>list=[];
  MyEvent(this.list);

  @override
  List<Object?> get props =>list;

}