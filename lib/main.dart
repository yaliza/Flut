import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/preferences_helper.dart';
import 'package:http/http.dart' as http;
import 'preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var routes = <String, WidgetBuilder>{
      PreferencesPage.routeName: (BuildContext context) => new PreferencesPage(title: "Preferences"),
    };
    return MaterialApp(
      title: 'Weather',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Weather'),
      routes: routes,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

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

class _MyHomePageState extends State<MyHomePage> {
  static List<String> dropdownValues = ['', 'Minsk', 'Brest', 'Moscow'];

  String dropdownValue = dropdownValues[0];
  String temperature = '';
  String description = '';
  String icon = '';
  static const IconData settingsIcon = IconData(0xe8b8, fontFamily: 'MaterialIcons');

  void makeApiRequest() async {
    String link = 'https://api.openweathermap.org/data/2.5/weather?'
        'q=' + await  PreferencesHelper.getCity() +
        '&units=' + await PreferencesHelper.getTempUnit() +
        '&appid=' + await PreferencesHelper.getAppId();

    final response = await http.get(link);

    if (response.statusCode == 200) {
      setState(() {
        WeatherData data = WeatherData.fromJson(json.decode(response.body));
        temperature = data.temp;
        description = data.description;
        icon = data.icon;
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
            )
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
            Text(
              temperature,
              style: TextStyle(fontSize: 22.0),
            ),
            Text(
              description,
              style: TextStyle(fontSize: 22.0),
            ),
            FadeInImage.assetNetwork(
                placeholder: 'place_holder.jpg',
                image: 'http://openweathermap.org/img/wn/' + icon + '@2x.png'
            ),
          ],
        )
      )
    );
  }
}
