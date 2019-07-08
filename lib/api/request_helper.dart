import 'package:flutter_app/entities/weather_data.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app/preferences_helper.dart';
import 'package:flutter_app/entities/weather_info_prediction.dart';
import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:flutter_app/entities/city.dart';

class RequestHelper {
  static void getPredictions(
      Function(List<WeatherInfoPrediction>) callback, Function error) async {
    String link = 'http://api.openweathermap.org/data/2.5/forecast?'
            'q=' +
        await PreferencesHelper.getCity() +
        '&units=' +
        await PreferencesHelper.getTempUnit() +
        '&appid=' +
        await PreferencesHelper.getAppId();

    final response = await http.get(link);

    if (response.statusCode == 200) {
      var weatherInfoPredictions = (json.decode(response.body)['list'] as List)
          .map((i) => WeatherInfoPrediction.fromJson(i))
          .toList();
      callback(weatherInfoPredictions);
    } else {
      error();
    }
  }

  static void getCurrentWeather(
      Function(WeatherData) callback, Function error) async {
    String link = 'https://api.openweathermap.org/data/2.5/weather?'
            'q=' +
        await PreferencesHelper.getCity() +
        '&units=' +
        await PreferencesHelper.getTempUnit() +
        '&appid=' +
        await PreferencesHelper.getAppId();

    final response = await http.get(link);

    if (response.statusCode == 200) {
      WeatherData data = WeatherData.fromJson(json.decode(response.body));
      callback(data);
    } else {
      error();
    }
  }

  static void getCitiesList(Function(List<City>) callback, Function error) async {
    var link = 'http://bulk.openweathermap.org/sample/city.list.json.gz';
    final response = await http.get(link);
    var bytes = GZipDecoder().decodeBytes(response.bodyBytes);
    List<dynamic> list = json.decode(Utf8Codec().decode(bytes));
    List<City> res = list.map(((str) => City.fromJson(str))).toList();
    callback(res);
  }
}
