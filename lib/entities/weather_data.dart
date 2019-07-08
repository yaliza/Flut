class WeatherData {
  final String description;
  final String icon;
  final String temp;

  WeatherData({this.description, this.icon, this.temp});

  String toString() {return temp.toString();}

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      description: json['weather'][0]['main'],
      icon: json['weather'][0]['icon'],
      temp: json['main']['temp'].toString(),
    );
  }
}