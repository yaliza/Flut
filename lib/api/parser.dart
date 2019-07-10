import 'dart:isolate';
import 'package:flutter_app/entities/weather_data.dart';
import 'package:flutter_app/entities/city.dart';
import 'package:flutter_app/entities/weather_info_predictions.dart';
import 'package:archive/archive.dart';
import 'dart:convert';

enum ParserWorkType { WEATHER_BY_IDS, CITIES_LIST_BYTES, WEATHER_PREDICTION }

class Parser {
  ReceivePort receivePort;
  Isolate isolate;

  Future startWork() async {
    receivePort = ReceivePort();
    isolate = await Isolate.spawn(doWork, receivePort.sendPort);
    return;
  }

  static void doWork(SendPort sendPort) async {
    ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    await for (var data in receivePort) {
      SendPort sendPort = data[0];
      var dataToParse = data[1];
      ParserWorkType workType = data[2];
      switch(workType){
        case ParserWorkType.WEATHER_BY_IDS:
          sendPort.send(parseWeatherDataByIds(dataToParse));
          break;
        case ParserWorkType.CITIES_LIST_BYTES:
          sendPort.send(parseCities(dataToParse));
          break;
        case ParserWorkType.WEATHER_PREDICTION:
          sendPort.send(parseWeatherPrediction(dataToParse));
          break;
      }
    }
  }

  static List<WeatherData> parseWeatherDataByIds(var data){
    return (json.decode(data)['list'] as List).map((js) => WeatherData.fromJsonCitiesIds(js)).toList();
  }

  static WeatherInfoPredictions parseWeatherPrediction(var data){
    return WeatherInfoPredictions.fromJson(json.decode(data));
  }

  static List<City> parseCities(var bytes){
    List<dynamic> list = json.decode(Utf8Codec().decode(GZipDecoder().decodeBytes(bytes)));
    return list.map(((str) => City.fromJson(str))).toList();
  }
}
