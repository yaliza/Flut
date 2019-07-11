class WeatherData {
  final String cityName;
  final String mainDescription;
  final String description;
  final String icon;
  final int temp;
  final int sunrise;
  final int sunset;
  final int dt;
  final int timezone;

  WeatherData({this.cityName, this.mainDescription, this.description, this.icon, this.temp, this.sunrise, this.sunset, this.dt, this.timezone});

  String toString() {return temp.toString();}

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
        cityName: json['name'],
        mainDescription: json['weather'][0]['main'],
        description: json['weather'][0]['description'],
        icon: json['weather'][0]['icon'],
        temp: json['main']['temp'].toInt(),
        sunrise: json['sys']['sunrise'],
        sunset: json['sys']['sunset'],
        dt: json['dt'],
        timezone: json['timezone']
    );
  }
  
  factory WeatherData.fromJsonCitiesIds(Map<String, dynamic> json) {
    return WeatherData(
      cityName: json['name'],
      mainDescription: json['weather'][0]['main'],
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      temp: json['main']['temp'].toInt(),
      sunrise: json['sys']['sunrise'],
      sunset: json['sys']['sunset'],
      dt: json['dt'],
      timezone: json['sys']['timezone']
    );
  }
}