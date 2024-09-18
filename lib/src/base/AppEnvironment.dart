
enum Environment{prod, staging, demo}
abstract class AppEnvironment{
  static late String baseApiUrl;
  static late String fcmBase;
  static late String userEventBase;
  static late String _environment;
  static String get environment => _environment;
  static setupEnv(String? environment){
    environment=environment ?? "Prod";
    _environment=environment;
    switch(environment){
      case "Prod":
        baseApiUrl="https://nocd-prod.q-u-i-l-t.com/api/";
        fcmBase="https://notifications.q-u-i-l-t.com/notifications/saveDeviceId";
        userEventBase="https://api-staging.q-u-i-l-t.com/api/events/add";
        break;
      case "Staging":
        baseApiUrl="https://api-staging.q-u-i-l-t.com/api/";
        fcmBase="https://notifications-staging.q-u-i-l-t.com/notifications/saveDeviceId";
        userEventBase="https://api-staging.q-u-i-l-t.com/api/events/add";
        break;
      case "Demo":
        baseApiUrl="https://demo.q-u-i-l-t.com/api/";
        fcmBase="https://notifications-staging.q-u-i-l-t.com/notifications/saveDeviceId";
        userEventBase="https://api-staging.q-u-i-l-t.com/api/events/add";
        break;
    }
    print("setupEnv");
    print(baseApiUrl);
  }
}