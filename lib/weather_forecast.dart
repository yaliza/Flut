import 'package:flutter/material.dart';
import 'package:flutter_app/preferences_helper.dart';
import 'package:http/http.dart' as http;
import 'preferences.dart';
import 'dart:convert';

class WeatherForecastPage extends StatefulWidget {

  static const String routeName = "/WeatherForecastPage";

  WeatherForecastPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _WeatherForecastPageState createState() => _WeatherForecastPageState();
}

class ForecastData {
  final List<DayWeatherData> weathers;

  ForecastData({this.weathers});

  factory ForecastData.fromJson(Map<String, dynamic> json) {
    List<DayWeatherData> weathersNew = new List<DayWeatherData>();
    int index = 0;
    weathersNew.add(DayWeatherData(json['list'][index]['dt_txt'],
        json['list'][index]['main']['temp'], json['list'][index]['weather'][0]['icon']));
    index = 8;
    weathersNew.add(DayWeatherData(json['list'][index]['dt_txt'],
        json['list'][index]['main']['temp'], json['list'][index]['weather'][0]['icon']));
    index = 16;
    weathersNew.add(DayWeatherData(json['list'][index]['dt_txt'],
        json['list'][index]['main']['temp'], json['list'][index]['weather'][0]['icon']));
    index = 24;
    weathersNew.add(DayWeatherData(json['list'][index]['dt_txt'],
        json['list'][index]['main']['temp'], json['list'][index]['weather'][0]['icon']));
    index = 32;
    weathersNew.add(DayWeatherData(json['list'][index]['dt_txt'],
        json['list'][index]['main']['temp'], json['list'][index]['weather'][0]['icon']));
    return ForecastData(weathers: weathersNew);
  }
}

class DayWeatherData {
  String date;
  double temp;
  String icon;

  DayWeatherData(String date, double temp, String icon) {
    this.date = date;
    this.temp = temp;
    this.icon = icon;
  }
}
/*
class WeatherData {
  final String description;
  final String icon;
  final String temp;

  WeatherData({this.description, this.icon, this.temp});

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      description: json['weather'][0]['main'],
      icon: json['weather'][0]['icon'],
      temp: json['main']['temp'].toString(),
    );
  }
}
*/
class _WeatherForecastPageState extends State<WeatherForecastPage> {
  static List<String> dropdownValues = ['', 'Minsk', 'Brest', 'Moscow'];

  String dropdownValue = dropdownValues[0];

  ForecastData data;

  static const IconData settingsIcon = IconData(0xe8b8, fontFamily: 'MaterialIcons');

  Widget getWeatherWidgets()
  {
    List<Widget> list = new List<Widget>();

    if(data != null) {
      for (var i = 0; i < data.weathers.length; i++) {
        List<Widget> contents = new List<Widget>();
        contents.add(new Text("Date: "));
        contents.add(new Text(data.weathers[i].date));
        contents.add(new Text("Temp: "));
        contents.add(new Text(data.weathers[i].temp.toString()));
        contents.add(new FadeInImage.assetNetwork(
            placeholder: 'place_holder.jpg',
            image: 'http://openweathermap.org/img/wn/' + data.weathers[0].icon +
                '@2x.png'
        ));
        list.add(new Row(children: contents));
      }
    }
    return new Column(children: list);
  }

  void makeApiRequest() async {
    String link = 'https://api.openweathermap.org/data/2.5/forecast?'
        'q=' + await  PreferencesHelper.getCity() +
        '&units=' + await PreferencesHelper.getTempUnit() +
        '&appid=' + await PreferencesHelper.getAppId();

    final response = await http.get(link);

    if (response.statusCode == 200) {
      setState(() {
        ForecastData data = ForecastData.fromJson(json.decode(response.body));
          this.data = data;
      });
    } else {
      throw Exception('Failed to load post');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: <Widget>[
            // action button
            IconButton(
              icon: Icon(settingsIcon),
              onPressed: () {
                Navigator.pushNamed(context, PreferencesPage.routeName);
              },
            ),
            IconButton(
              icon: Icon(Icons.playlist_add),
              tooltip: 'Restitch it',
              onPressed: () {
                Navigator.pushNamed(context, WeatherForecastPage.routeName);
              }
            ),
          ],
        ),
        body: Center(
            child: ListView(
              children: <Widget>[
                DropdownButton<String>(
                  value: dropdownValue,
                  onChanged: (String newValue) {
                    setState(() {
                      dropdownValue = newValue;
                      PreferencesHelper.setCity(dropdownValue);
                      makeApiRequest();
                    });
                  },
                  items: dropdownValues.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                          value,
                          style: TextStyle(fontSize: 22.0)
                      ),
                    );
                  }).toList(),
                ),
                getWeatherWidgets()
              ],
            )
        )
    );
  }
}
