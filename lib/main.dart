import 'package:flutter/material.dart';
import 'package:flutter_app/preferences_helper.dart';
import 'package:flutter_app/weather_forecast.dart';
import 'package:intl/intl.dart';
import 'api/request_helper.dart';
import 'entities/icons.dart';
import 'entities/weather_data.dart';
import 'preferences.dart';
import 'charts.dart';

import 'package:flutter/services.dart' show rootBundle;

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
  static List<String> dropdownValues = ['Minsk', 'Brest', 'Moscow', 'Vitebsk', 'London', 'Berlin'];

  String dropdownValue = dropdownValues[0];
  String temperature = '';
  String mainDescription = '';
  String description = '';
  String icon = '';
  int sunrise, sunset;
  String sunriseText = '';
  String sunsetText = '';
  String tempUnitValue = '';

  static const IconData settingsIcon =
      IconData(0xe8b8, fontFamily: 'MaterialIcons');

  void changeTempUnit(String value) {
    setState(() {
      tempUnitValue = value;
    });
  }

  void changeWeatherData(WeatherData data) {
    PreferencesHelper.getTempUnit().then((val) => changeTempUnit(val));
    setState(() {
      temperature = data.temp.toString();

      if (tempUnitValue == 'metric') {
        temperature += '°C';
      }
      else {
        temperature += '°F';
      }

      mainDescription = data.mainDescription;
      description = data.description;
      icon = data.icon;
      sunrise = data.sunrise;
      sunset = data.sunset;

      sunriseText = 'Sunset: ' +
          new DateFormat.Hm().format(new DateTime.fromMillisecondsSinceEpoch(sunrise * 1000)).toString();

      sunsetText = 'Sunset: ' +
          new DateFormat.Hm().format(new DateTime.fromMillisecondsSinceEpoch(sunset * 1000)).toString();;
    });
  }

  void changeIconsValue(List<WeatherIcon> value) {
    setState(() {
      PreferencesHelper.icons = (value as List).map((js) => WeatherIcon.fromJson(js)).toList();
    });
  }

  _MyHomePageState() {
    RequestHelper.getCurrentWeather(
            (data) => changeWeatherData(data),
            () => print('error'));
    PreferencesHelper.getIcons(
            (json) => changeIconsValue(json),
            () => print('error')
    );
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
                            image: ''
//                            PreferencesHelper.icons[0].day,
                        ),
                        title: Text(
                          temperature ?? '',
                          style: TextStyle(fontSize: 32.0),
                        ),
                        subtitle: Column(
                          children:<Widget>[
                            Text(
                              description ?? '',
                              style: TextStyle(fontSize: 22.0),
                            ),
                            Text(
                                sunriseText ?? '',
                              style: TextStyle(fontSize: 22.0),
                            ),
                            Text(
                              sunsetText ?? '',
                              style: TextStyle(fontSize: 22.0),
                            ),
                          ]
                      ),
                      )
                    ],
                  ),
                ),
              ],
            )));
  }
}
