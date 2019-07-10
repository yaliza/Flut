import 'dart:math';

class WeatherInfoPredictions {
  String cityName;
  List<WeatherInfoPrediction> predictions;
  double averageTemp, maxTemp, minTemp, averageHumidity, averagePressure;

  WeatherInfoPredictions(
      {this.cityName,
      this.predictions,
      this.averageTemp,
      this.minTemp,
      this.maxTemp,
      this.averageHumidity,
      this.averagePressure});

  factory WeatherInfoPredictions.fromJson(Map<String, dynamic> json) {
    double minTemp = double.infinity,
        maxTemp = double.negativeInfinity,
        tempSum = 0,
        humiditySum = 0.0,
        pressureSum = 0.0;

    var predictions = (json['list'] as List).map((i) {
      var prediction = WeatherInfoPrediction.fromJson(i);
      minTemp = min(minTemp, prediction.temp);
      maxTemp = max(maxTemp, prediction.temp);
      tempSum += prediction.temp;
      humiditySum += prediction.humidity;
      pressureSum += prediction.pressure;
      return prediction;
    }).toList();

    return WeatherInfoPredictions(
        cityName: json['city']['name'],
        predictions: predictions,
        averageTemp: tempSum / predictions.length,
        minTemp: minTemp,
        maxTemp: maxTemp,
        averageHumidity: humiditySum / predictions.length,
        averagePressure: pressureSum / predictions.length);
  }
}

class WeatherInfoPrediction {
  DateTime dateTime;
  double temp;
  double tempmin;
  double tempmax;
  double pressure;
  int humidity;

  WeatherInfoPrediction(
      {this.dateTime,
      this.temp,
      this.tempmin,
      this.tempmax,
      this.pressure,
      this.humidity});

  String toString() {
    return temp.toString();
  }

  factory WeatherInfoPrediction.fromJson(Map<String, dynamic> json) {
    return WeatherInfoPrediction(
        dateTime: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
        temp: double.parse(json['main']['temp'].toString()),
        tempmin: double.parse((json['main']['temp_min']).toString()),
        tempmax: double.parse(json['main']['temp_max'].toString()),
        pressure: double.parse(json['main']['pressure'].toString()),
        humidity: json['main']['humidity']);
  }
}
