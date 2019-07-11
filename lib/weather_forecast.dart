import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/preferences_helper.dart';
import 'package:flutter_app/screens/preferences.dart';
import 'package:flutter_app/utils.dart';
import 'package:http/http.dart' as http;

import 'api/request_helper.dart';
import 'entities/weather_info_predictions.dart';
import 'package:flutter_app/screens/preferences.dart';
import 'dart:convert';


class WeatherForecast extends StatefulWidget{
  @override
  _WeatherForecastState createState() => _WeatherForecastState();
}

class _WeatherForecastState extends State<WeatherForecast> {
  WeatherInfoPredictions predictions;
  String cityId;

  _WeatherForecastState() {
    PreferencesHelper.getCityId().then((val) => changeCityId(val));
  }

  void changeCityId(String cityId) {
    setState(() {
      this.cityId = cityId;
      RequestHelper.getPredictions(
              (data) => changeWeatherData(data),
              () => print('error'),
          cityId
      );
    });
  }


  void changeWeatherData(WeatherInfoPredictions predictions) {
    setState(() {
      this.predictions = predictions;
    });
  }

  String getWeekDay(int i) {
    String res;
    switch(i) {
      case 1:
        res = "Monday   ";
        break;
      case 2:
        res = "Tuesday  ";
        break;
      case 3:
        res = "Wednesday";
        break;
      case 4:
        res = "Thursday ";
        break;
      case 5:
        res = "Friday   ";
        break;
      case 6:
        res = "Saturday ";
        break;
      case 7:
        res = "Sunday   ";
        break;
    }
    return res;
  }

  Row hourlyPredictions() {
    List<Widget> list = new List<Widget>();
    if(predictions != null) {
      for (var i = 0; i < 6; i++) {
        List<Widget> contents = new List<Widget>();
        int hour = predictions.predictions[i].dateTime.hour;
        String time;
        if(hour >= 12 )
          time = (hour - 12).toString() + " pm";
        else
          time = hour.toString() + " am";
        contents.add(new Text(time));
        contents.add(new FadeInImage.assetNetwork(
            height: 60,
            placeholder: getDefaultWeatherIcon(),
            image: predictions.predictions[i] != null
                ? getWeatherIconUrl(predictions.predictions[i].icon)
                : getWeatherIconUrl('')));
        contents.add(new Text(
            predictions.predictions[i].tempmax.toString(),
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black26),
        ));
        list.add(new Column(children: contents));
      }
    }
    return new Row(children: list);
  }

  Column dailyPredictions() {
    List<Widget> list = new List<Widget>();
    if(predictions != null) {
      for (var i = 0; i < predictions.predictions.length; i += 8) {
        List<Widget> contents = new List<Widget>();
        contents.add(new Text("   " + getWeekDay(predictions.predictions[i].dateTime.weekday),
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 17)));
        contents.add(new FadeInImage.assetNetwork(
            height: 100,
            placeholder: getDefaultWeatherIcon(),
            image: predictions.predictions[i] != null
                ? getWeatherIconUrl(predictions.predictions[i].icon)
                : getWeatherIconUrl('')));
        contents.add(new Text(predictions.predictions[i].tempmax.toString() + "   ",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black26),));
        contents.add(new Text(predictions.predictions[i].tempmin.toString(),
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),));
        list.add(new Row(children: contents));
      }
    }
    return new Column(children: list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: ListView(
              children: <Widget>[
                hourlyPredictions(),
                dailyPredictions()
              ],
            )
        ),
    );
  }

}

/*
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

class _WeatherForecastPageState extends State<WeatherForecastPage> {
  int _selectedIndex = 0;
  static List<String> dropdownValues = ['', 'Minsk', 'Brest', 'Moscow'];

  String dropdownValue = dropdownValues[0];

  ForecastData data;

  static const IconData settingsIcon = IconData(0xe8b8, fontFamily: 'MaterialIcons');

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
        ),
        bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
          icon: Icon(Icons.home),
      title: Text('Home'),
     ),
      BottomNavigationBarItem(
      icon: Icon(Icons.business),
      title: Text('Business'),
    ) ,
    BottomNavigationBarItem(
    icon: Icon(Icons.school),
    title: Text('School'),
    ),
    ],
    currentIndex: _selectedIndex,
    selectedItemColor: Colors.amber[800],
    onTap: _onItemTapped,
    )
    );
  }
}
*/