
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceUtils {
  static String SESSION_TOKEN="session_token";
  static String USER_ID="user_id";
  static String MOODID="moodId";
  static String IS_LOGIN="is_login";
  static Future<SharedPreferences> get _instance async => _prefsInstance ??= await SharedPreferences.getInstance();
  static SharedPreferences? _prefsInstance;

  // call this method from iniState() function of mainApp().
  static Future<SharedPreferences> init() async {
    _prefsInstance = await _instance;
    return _prefsInstance!;
  }

  static String getString(String key, String defValue) {
    return _prefsInstance==null?"":_prefsInstance!.getString(key) ?? defValue ?? "";
  }
  static int getInt(String key, int defValue) {
    return _prefsInstance==null?-1:_prefsInstance!.getInt(key) ?? defValue ?? -1;
  }
  static bool? getBool(String key) {
    return _prefsInstance!.getBool(key)??false;
  }
  static List<String>? getStringList(String key) {
    return _prefsInstance!.getStringList(key);
  }
  static Future<bool> setBool(String key, bool value) async {
    var prefs = await _instance;
    return prefs.setBool(key, value);
  }
  static Future<bool> setString(String key, String value) async {
    var prefs = await _instance;
    return prefs.setString(key, value);
  }
  static Future<bool> setStringList(String key, List<String> value) async {
    var prefs = await _instance;
    return prefs.setStringList(key, value);
  }
  static Future<bool> setInt(String key, int value) async {
    var prefs = await _instance;
    return prefs.setInt(key, value);
  }
  static Future<bool> clear() async {
    var prefs = await _instance;
    return prefs.clear();
  }
}