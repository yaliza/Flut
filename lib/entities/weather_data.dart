class WeatherData {
  final String mainDescription;
  final String description;
  final String icon;
  final int temp;
  final int sunrise;
  final int sunset;

  WeatherData({this.mainDescription, this.description, this.icon, this.temp, this.sunrise, this.sunset});

  String toString() {return temp.toString();}

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      mainDescription: json['weather'][0]['main'],
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      temp: json['main']['temp'].toInt(),
      sunrise: json['sys']['sunrise'],
      sunset: json['sys']['sunset'],
    );
  }
}