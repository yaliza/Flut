import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'entities/icons.dart';
import 'package:flutter/services.dart' show rootBundle;

class PreferencesHelper {
  static final String _appIdKey = "APP_ID";
  static final String _defaultAppId = "e1967bc422760b4edf0d91e58fe7e4d2";

  static final String _tempUnitKey = "TEMP";
  static final String _defaultTemptUnit = "metric";

  static final String _cityKey = "CITY";
  static final String _defaultCity = "minsk";

  static List<WeatherIcon> icons;

  static Future<String> getIcons(Function(List<WeatherIcon>) callback, Function error) async {
    return await rootBundle.loadString('assets/weather_conditions.json').then((
        val) => json.decode(val));
  }

  static final String _fillAreaBelowPlotKey = "FILL_AREA_BELOW_PLOT";
  static final bool _defaultFillAreaBelowPlot = true;

  static final String _showGridKey = "SHOW_GRID";
  static final bool _defaultShowGrid = true;

  static final String _cityIdKey = "DEFAULT_CITY_ID";
  static final String _defaultCityId = "625144";

  static Future<String> getCityId() async {
    return getString(_cityIdKey, _defaultCityId);
  }

  static final _citiesKey = 'CITIES';

  static Future<bool> setCityId(String value) {
    return setString(_cityIdKey, value);
  }

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

  static Future<bool> getFillAreaBelowPlot() {
    return getBoolean(_fillAreaBelowPlotKey, _defaultFillAreaBelowPlot);
  }

  static Future<bool> setFillAreBelowPlot(bool value) async {
    return setBool(_fillAreaBelowPlotKey, value);
  }

  static Future<List<String>> getMarkedCitiesIds() async {
    return getStringList(_citiesKey, []);
  }

  static Future<bool> setMarkedCitiesIds(List<String> list) async {
    return setStringList(_citiesKey, list);
  }

  static Future<bool> getShowGrid() {
    return getBoolean(_showGridKey, _defaultShowGrid);
  }

  static Future<bool> setShowGrid(bool value) async {
    return setBool(_showGridKey, value);
  }

  static Future<String> getString(String key, String def) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? def;
  }

  static Future<bool> setString(String key, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(key, value);
  }

  static Future<bool> getBoolean(String key, bool def) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? def;
  }

  static Future<bool> setBool(String key, bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(key, value);
  }

  static Future<List<String>> getStringList(String key, List<String> def) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key) ?? def;
  }

  static Future<bool> setStringList(String key, List<String> val) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setStringList(key, val);
  }
}