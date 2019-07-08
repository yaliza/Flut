
class City {
  String name;
  double lon;
  double lat;

  City({this.name, this.lat, this.lon});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      name: json['name'],
      lon: double.parse(json['coord']['lon'].toString()),
      lat: double.parse(json['coord']['lat'].toString())
    );
  }
}