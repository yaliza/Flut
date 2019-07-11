class City {
  String name;
  String id;
  double latitude, longitude;

  City({this.id, this.name, this.latitude, this.longitude});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'].toString(),
      name: json['name'],
      latitude: double.parse(json['coord']['lat']),
      longitude: double.parse(json['coord']['lon'].toString())
    );
  }
}