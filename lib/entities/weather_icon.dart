class WeatherIcon {
  String description;
  String day;
  String night;

  WeatherIcon({this.description, this.day, this.night});

  factory WeatherIcon.fromJson(Map<String, dynamic> json) {
    return WeatherIcon(
        description: json['description'],
        day: json['day'],
        night: json['night']);
  }
}
