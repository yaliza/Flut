import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/preferences_helper.dart';
import 'package:flutter_app/weather_forecast.dart';
import 'api/request_helper.dart';
import 'entities/weather_data.dart';
import 'preferences.dart';
import 'charts.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var routes = <String, WidgetBuilder>{
      PreferencesPage.routeName: (BuildContext context) =>
          new PreferencesPage(title: "Preferences"),
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

class _MyHomePageState extends State<MyHomePage> {
  static List<String> dropdownValues = ['Minsk', 'Brest', 'Moscow'];

  String dropdownValue = dropdownValues[0];
  String temperature = '';
  String description = '';
  String icon = '';
  static const IconData settingsIcon =
      IconData(0xe8b8, fontFamily: 'MaterialIcons');

  void changeWeatherData(WeatherData data) {
    setState(() {
      temperature = data.temp;
      description = data.description;
      icon = data.icon;
    });
  }

  _MyHomePageState() {
    RequestHelper.getCurrentWeather(
            (data) => changeWeatherData(data),
            () => print('error'));
  }

  @override
  Widget build(BuildContext context) {
    AssetImage background;
    if (new DateTime.now().hour > 6 && new DateTime.now().hour < 20) {
      background = AssetImage("assets/day.jpg");
    }
    else {
      background = AssetImage("assets/night.jpg");
    }
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
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              WeatherForecastPage(title: 'Forecast')));
                }),
            IconButton(
                icon: Icon(Icons.details),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChartsPage(title: 'Charts')));
                }),
          ],
        ),
        body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: background,
                fit: BoxFit.cover,
              ),
            ),
            child: ListView(
              children: <Widget>[
                Center(
                  child: DropdownButton<String>(
                    value: dropdownValue,
                    onChanged: (String newValue) {
                      setState(() {
                        dropdownValue = newValue;
                        PreferencesHelper.setCity(dropdownValue);
                        RequestHelper.getCurrentWeather(
                            (data) => changeWeatherData(data),
                            () => print('error'));
                      });
                    },
                    items: dropdownValues
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: TextStyle(fontSize: 22.0)),
                      );
                    }).toList(),
                  ),
                ),
                Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        leading: FadeInImage.assetNetwork(
                            placeholder: 'place_holder.jpg',
                            image: 'http://openweathermap.org/img/wn/' +
                                icon +
                                '@2x.png'),
                        title: Text(
                          temperature,
                          style: TextStyle(fontSize: 22.0),
                        ),
                        subtitle: Text(
                          description,
                          style: TextStyle(fontSize: 22.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )));
  }
}
