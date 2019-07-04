import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  static final String _appIdKey = "APP_ID";
  static final String _defaultAppId = "e1967bc422760b4edf0d91e58fe7e4d2";

  static final String _tempUnitKey = "TEMP";
  static final String _defaultTemptUnit = "metric";

  static final String _cityKey = "CITY";
  static final String _defaultCity = "minsk";

  static Future<String> getAppId() async {
    return getString(_appIdKey, _defaultAppId);
  }

  static Future<bool> setAppId(String value) {
    return setString(_appIdKey, value);
  }

  static Future<String> getTempUnit() async {
    return getString(_tempUnitKey, _defaultTemptUnit);
  }

  static Future<bool> setTempUnit(String value) async {
    return setString(_tempUnitKey, value);
  }

  static Future<String> getCity() {
    return getString(_cityKey, _defaultCity);
  }

  static Future<bool> setCity(String value) async {
    return setString(_cityKey, value);
  }

  static Future<String> getString(String key, String def) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? def;
  }

  static Future<bool> setString(String key, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(key, value);
  }
}