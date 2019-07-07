import 'package:http/http.dart' as http;
import 'package:flutter_app/preferences_helper.dart';
import 'package:flutter_app/entities/weather_info_prediction.dart';
import 'dart:convert';

class RequestHelper {

  static void getPredictions(Function(List<WeatherInfoPrediction>) callback, Function error) async {
    String link = 'http://api.openweathermap.org/data/2.5/forecast?'
        'q=' + await  PreferencesHelper.getCity() +
        '&units=' + await PreferencesHelper.getTempUnit() +
        '&appid=' + await PreferencesHelper.getAppId();

    final response = await http.get(link);

    if (response.statusCode == 200) {
      var weatherInfoPredictions = (json.decode(response.body)['list'] as List).map((i) => WeatherInfoPrediction.fromJson(i)).toList();
      callback(weatherInfoPredictions);
    } else {
      error();
    }
  }
}
