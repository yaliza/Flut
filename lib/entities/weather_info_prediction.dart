class WeatherInfoPrediction {
  DateTime dateTime;
  double temp;
  double tempmin;
  double tempmax;
  double pressure;
  int humidity;

  WeatherInfoPrediction({this.dateTime, this.temp, this.tempmin, this.tempmax, this.pressure, this.humidity});

  String toString() {return temp.toString();}

  factory WeatherInfoPrediction.fromJson(Map<String, dynamic> json) {
    return WeatherInfoPrediction(
        dateTime: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
        temp: json['main']['temp'],
        tempmin: json['main']['temp_min'],
        tempmax: json['main']['temp_max'],
        pressure: double.parse(json['main']['pressure'].toString()),
        humidity: json['main']['humidity']);
  }
}
