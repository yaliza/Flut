class WeatherIcon {
  String description;
  String day;
  String night;

//  WeatherIcon(String description, String day, String night) {
//    this.description = description;
//    this.day = day;
//    this.night = night;
//  }

  WeatherIcon({this.description, this.day, this.night});

  factory WeatherIcon.fromJson(Map<String, dynamic> json) {
    return WeatherIcon(
        description: json['description'],
        day: json['day'],
        night: json['night']);
  }
}

class WeatherIcons {
  final List<WeatherIcon> icons;

  WeatherIcons({this.icons});

  factory WeatherIcons.fromJson(Map<String, dynamic> json) {
    List<WeatherIcon> icons = new List<WeatherIcon>();
    int index = 0;

    while (index < 9) {
      icons.add(WeatherIcon.fromJson(json[index]));
      index++;
    }
    return WeatherIcons(icons: icons);
  }
}