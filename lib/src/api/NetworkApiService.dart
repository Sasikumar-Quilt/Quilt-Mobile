import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import '../PrefUtils.dart';
import 'AppException.dart';
import 'BaseApiService.dart';
import 'package:http/http.dart' as http;

class NetworkApiService extends BaseApiService {
  @override
  Future deleteResponse(String url, Status status) async {
    dynamic responseJson;
    try {
      print("deleteResponse");
      print(BaseApiService.baseUrl + url);

      print("Bearer ${PreferenceUtils.getString(PreferenceUtils.SESSION_TOKEN, "")}");
      Map<String, String> requestHeaders = {
        'Content-Type': 'application/json',
        'Authorization': "Bearer ${PreferenceUtils.getString(PreferenceUtils.SESSION_TOKEN, "")}"
      };
      final response =
          await http.delete(Uri.parse(BaseApiService.baseUrl + url), headers: requestHeaders);
      responseJson = returnResponse(response, status);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    }
    return responseJson;
  }
@override
  Future putRequest(String url, Map<String, dynamic> jsonBody, Status status) async {
  dynamic responseJson;
  try {
    print("postRequest");
    Map<String, String> requestHeaders;
    if(status==Status.MOBILE_NUMBER_LOGIN){
      requestHeaders = {
        'Content-Type': 'application/json',
        'Authorization': "Bearer 11b623f7-cb76-4130-a7d5-ba24eb1590d6"
      };
    }else{
      requestHeaders = {
        'Content-Type': 'application/json',
        'Authorization': "Bearer ${PreferenceUtils.getString(PreferenceUtils.SESSION_TOKEN, "")}"
      };

    }
    String baseUrl=status==Status.FCM?BaseApiService.fcm_base:BaseApiService.baseUrl + url;
    if(status==Status.USER_EVENT){
      baseUrl=BaseApiService.user_event;
    }
    print(baseUrl);
    http.Response response = await http.put(Uri.parse(baseUrl),
        body: jsonEncode(jsonBody), headers: requestHeaders);
    print(jsonEncode(jsonBody));
    print("postResponse");
    //responseJson = returnResponse(response, status);
    if(response.statusCode==200){
      responseJson = ApiResponse(Status.COMPLETED, responseJson, "");
    }else{
      responseJson = ApiResponse(Status.ERROR, responseJson, "");
    }
  } on SocketException {
    responseJson = ApiResponse(Status.ERROR, responseJson, "No Internet Connection");
    //throw FetchDataException('No Internet Connection');
  }
  return responseJson;
  }
  @override
  Future getResponse(String url, Status status) async {
    dynamic responseJson;
    try {
      print("postRequest");
      print(BaseApiService.baseUrl + url);

      print("Bearer ${PreferenceUtils.getString(PreferenceUtils.SESSION_TOKEN, "")}");
      Map<String, String> requestHeaders = {
        'Content-Type': 'application/json',
        'Authorization': "Bearer ${PreferenceUtils.getString(PreferenceUtils.SESSION_TOKEN, "")}"
      };
      final response =
          await http.get(Uri.parse(BaseApiService.baseUrl + url), headers: requestHeaders);
      responseJson = returnResponse(response, status);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    }
    return responseJson;
  }


  @override
  Future postResponse(String url, Map<String, Object> jsonBody, Status status) async {
    dynamic responseJson;
    try {
      print("postRequest");
      final response;
      Map<String, String> requestHeaders;
      if(status==Status.MOBILE_NUMBER_LOGIN){
       requestHeaders = {
          'Content-Type': 'application/json',
          'Authorization': "Bearer 11b623f7-cb76-4130-a7d5-ba24eb1590d6"
        };
      }else{
        requestHeaders = {
          'Content-Type': 'application/json',
          'Authorization': "Bearer ${PreferenceUtils.getString(PreferenceUtils.SESSION_TOKEN, "")}"
        };

      }
      String baseUrl=status==Status.FCM?BaseApiService.fcm_base:BaseApiService.baseUrl + url;
      if(status==Status.USER_EVENT){
        baseUrl=BaseApiService.user_event;
      }
      response = await http.post(Uri.parse(baseUrl),
          body: jsonEncode(jsonBody), headers: requestHeaders);

      print(BaseApiService.baseUrl + url);
      print(jsonEncode(jsonBody));
      print("postResponse");
      responseJson = returnResponse(response, status);
    } on SocketException {
      responseJson = ApiResponse(Status.ERROR, responseJson, "No Internet Connection");
      //throw FetchDataException('No Internet Connection');
    }
    return responseJson;
  }

  dynamic returnResponse(http.Response response, Status apiName) {
    dynamic responseJson = null;
    String errorMessage = "";
    Status status = Status.COMPLETED;
    print("response.statusCode");
    print(response.statusCode);
    log(response.body);
    switch (response.statusCode) {

      case 403:
      case 200:
      case 500:
      case 401:
        if(response.body.isNotEmpty){
          responseJson = jsonDecode(response.body);
        }
        log(responseJson.toString());
        errorMessage = "success";
        break;
      case 400:
        status = Status.ERROR;
        errorMessage = BadRequestException(response.toString()).toString();
        break;
      case 403:
        status = Status.ERROR;
        errorMessage =
            UnauthorisedException(response.body.toString()).toString();
        break;
      case 404:
        status = Status.ERROR;
        errorMessage =
            UnauthorisedException(response.body.toString()).toString();
        break;
      default:
        status = Status.ERROR;
        errorMessage = FetchDataException(
                'Error occured while communication with server' +
                    ' with status code : ${response.statusCode}')
            .toString();
        break;
    }
    ApiResponse apiResponse = ApiResponse(status, responseJson, errorMessage);
    return apiResponse;
  }
}

class ApiResponse<T> {
  Status? status;
  T? data;
  String? message;

  ApiResponse(this.status, this.data, this.message);

  ApiResponse.loading() : status = Status.LOADING;

  ApiResponse.completed(this.data) : status = Status.COMPLETED;

  ApiResponse.error(this.message) : status = Status.ERROR;

  @override
  String toString() {
    return "Status : $status \n Message : $message \n Data : $data";
  }
}
