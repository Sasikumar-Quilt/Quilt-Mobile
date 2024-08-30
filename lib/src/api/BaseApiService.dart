

abstract class BaseApiService{
  static String baseUrl = "https://nocd-prod.q-u-i-l-t.com/api/";//"https://api-staging.q-u-i-l-t.com/api/";
  static String fcm_base = "https://notifications.q-u-i-l-t.com/notifications/saveDeviceId";//""https://etp.candelatech.in/app/";
  Future<dynamic> getResponse(String endPoint,Status status);
  Future<dynamic> postResponse(String endPoint,Map<String, Object> jsonBody,Status status);
  Future<dynamic> deleteResponse(String endPoint,Status status);

}

enum Status {
  LOADING,
  COMPLETED,
  Success,
  ERROR,
  MOBILE_NUMBER_LOGIN,
  METRIC_DATA,
  REFRESH_TOKEN,
  FCM
}