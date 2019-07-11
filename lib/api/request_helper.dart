import 'dart:isolate';
import 'package:flutter_app/entities/weather_data.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app/preferences_helper.dart';
import 'package:flutter_app/entities/weather_info_predictions.dart';
import 'dart:convert';
import 'package:flutter_app/entities/city.dart';
import 'parser.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class RequestHelper {
  static Parser _parser;
  static SendPort _sendParserWork;
  static List<City> _cities;

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

  static Future<bool> getCitiesList(
      Function(List<City>) callback, Function error) async {
    if (_cities == null) {
      final directory = await getApplicationDocumentsDirectory();
      String path = await directory.path;
      var file = File('$path/cities.gz');
      var bytes;
      if (file.existsSync() == true) {
        bytes = file.readAsBytesSync();
      } else {
        var link = 'http://bulk.openweathermap.org/sample/city.list.json.gz';
        final response = await http.get(link);
        bytes = response.bodyBytes;
        file.writeAsBytesSync(bytes);
      }
      Parser parser = Parser();
      await parser.startWork();
      _sendParserWork = await parser.receivePort.first;
      ReceivePort receiveJsonPort = new ReceivePort();
      _sendParserWork.send(
          [receiveJsonPort.sendPort, bytes, ParserWorkType.CITIES_LIST_BYTES]);
      _cities = await receiveJsonPort.first;
      parser.isolate.kill();
    }
    callback(_cities);
    return true;
  }

  static void _parseJson(
      ParserWorkType parseWorkType, var dataToParse, Function callback) async {
    if (_parser == null) {
      _parser = Parser();
      await _parser.startWork();
      _sendParserWork = await _parser.receivePort.first;
    }
    ReceivePort receiveJsonPort = new ReceivePort();
    _sendParserWork
        .send([receiveJsonPort.sendPort, dataToParse, parseWorkType]);
    callback(await receiveJsonPort.first);
  }
}
