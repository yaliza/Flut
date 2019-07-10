import 'dart:isolate';
import 'package:flutter_app/entities/weather_data.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app/preferences_helper.dart';
import 'package:flutter_app/entities/weather_info_predictions.dart';
import 'dart:convert';
import 'package:flutter_app/entities/city.dart';
import 'parser.dart';

class RequestHelper {
  static Parser parser;
  static SendPort sendParserWork;
  static List<City> cachedCities;

  static void getPredictions(Function(WeatherInfoPredictions) callback,
      Function error, String cityId) async {
    String link =
        'http://api.openweathermap.org/data/2.5/forecast?id=$cityId&units=${await PreferencesHelper.getTempUnit()}&appid=${await PreferencesHelper.getAppId()}';
    final response = await http.get(link);
    if (response.statusCode == 200) {
      _parseJson(ParserWorkType.WEATHER_PREDICTION, response.body, callback);
    } else {
      error();
    }
  }

  static void getCurrentWeather(
      Function(WeatherData) callback, Function error) async {
    String link =
        'https://api.openweathermap.org/data/2.5/weather?q=${await PreferencesHelper.getCity()}&units=${await PreferencesHelper.getTempUnit()}&appid=${await PreferencesHelper.getAppId()}';
    final response = await http.get(link);
    if (response.statusCode == 200) {
      callback(WeatherData.fromJson(json.decode(response.body)));
    } else {
      error();
    }
  }

  static void getCurrentWeatherByIds(Function(List<WeatherData>) callback,
      Function error, List<String> citiesIds) async {
    String link =
        'http://api.openweathermap.org/data/2.5/group?id=${citiesIds.join(',')}&units=${await PreferencesHelper.getTempUnit()}&appid=${await PreferencesHelper.getAppId()}';
    final response = await http.get(link);
    if (response.statusCode == 200) {
      _parseJson(ParserWorkType.WEATHER_BY_IDS, response.body, callback);
    } else {
      error();
    }
  }

  static void getCitiesList(
      Function(List<City>) callback, Function error) async {
    if (cachedCities == null) {
      print('null');
      var link = 'http://bulk.openweathermap.org/sample/city.list.json.gz';
      final response = await http.get(link);
      if (parser == null) {
        parser = Parser();
        await parser.startWork();
        sendParserWork = await parser.receivePort.first;
      }
      ReceivePort receiveJsonPort = new ReceivePort();
      sendParserWork.send([
        receiveJsonPort.sendPort,
        response.bodyBytes,
        ParserWorkType.CITIES_LIST_BYTES
      ]);
      cachedCities = await receiveJsonPort.first;
    }
    callback(cachedCities);
  }

  static void _parseJson(
      ParserWorkType parseWorkType, var dataToParse, Function callback) async {
    if (parser == null) {
      parser = Parser();
      await parser.startWork();
      sendParserWork = await parser.receivePort.first;
    }
    ReceivePort receiveJsonPort = new ReceivePort();
    sendParserWork.send([receiveJsonPort.sendPort, dataToParse, parseWorkType]);
    callback(await receiveJsonPort.first);
  }
}
