import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_app/preferences_helper.dart';
import 'package:flutter_app/screens/charts.dart';
import 'package:flutter_app/screens/cities.dart';
import 'package:flutter_app/screens/preferences.dart';
import 'package:location/location.dart';

import 'api/request_helper.dart';
import 'entities/city.dart';
import 'entities/weather_data.dart';
import 'screens/preferences.dart';
import 'screens/charts.dart';
import 'entities/weather_icon.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'utils.dart';

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
      home: Home(),
      routes: routes,
    );
  }
}

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  final List<Widget> _children = [
    MyHomePage(title: 'Home'),
    PreferencesPage(title: 'Preferences'),
    ChartsPage(title: 'Charts'),
    CitiesPage(title: 'Cities')
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather'),
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.blue,
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.home),
            title: new Text('Home', style: new TextStyle(color: Colors.blue)),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.settings),
            title:
                new Text('Settings', style: new TextStyle(color: Colors.blue)),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.show_chart),
              title: Text('Chart', style: new TextStyle(color: Colors.blue))),
          BottomNavigationBarItem(
              icon: Icon(Icons.location_city),
              title: Text('Cities', style: new TextStyle(color: Colors.blue)))
        ],
      ),
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
  static List<String> dropdownValues = [
    'Minsk',
    'Brest',
    'Moscow',
    'Vitebsk',
    'London',
    'Berlin'
  ];

  String dropdownValue = dropdownValues[0];
  WeatherData weatherData;
  String tempUnitValue = '';
  List<WeatherIcon> icons;

  var location = new Location();
  Map<String, double> userLocation;
  List<String> citiesNearby;
  List<City> cities;
  List<City> filteredCities = [];
  String filter = '';

  Future<Map<String, double>> getLocation() async {
    var currentLocation = <String, double>{};
    try {
      currentLocation = await location.getLocation();
    } catch (e) {
      currentLocation = null;
    }
    return currentLocation;
  }

  void changeCitiesList(List<City> value) {
    setState(() {
      cities = value;
    });
    filterCities();
  }

  void filterCities() async {
    if (filter.isNotEmpty) {
      var result = cities
          .where(
              (city) => city.name.toLowerCase().contains(filter.toLowerCase()))
          .toList();
      setState(() {
        filteredCities = result;
      });
    }
  }

  void getCitiesNearby() {
    RequestHelper.getCitiesList(changeCitiesList, () => {});
    double userLatitude = userLocation['latitude'];
    double userLongitude = userLocation['longitude'];
    for (City city in filteredCities) {
      if (sqrt(pow(userLatitude - city.latitude, 2) + pow(userLongitude - city.longitude, 2)) < 10) {
        citiesNearby.add(city.name);
      }
    }
  }

  static const IconData settingsIcon =
      IconData(0xe8b8, fontFamily: 'MaterialIcons');

  void changeTempUnit(String value) {
    setState(() {
      tempUnitValue = value;
    });
  }

  void changeUserLocation(Map<String, double> location) {
    setState(() {
      userLocation = location;
    });
  }

  void changeWeatherData(WeatherData data) {
    PreferencesHelper.getTempUnit().then((val) => changeTempUnit(val));
    setState(() {
      weatherData = data;
    });
  }

  @override
  void initState() {
    super.initState();
    getLocation().then((val) => changeUserLocation(val));
    RequestHelper.getCurrentWeather(changeWeatherData,() => print('error'));
    rootBundle.loadString('assets/weather_conditions.json').then(parseWeatherIconsJson);
    getCitiesNearby();
  }

  void parseWeatherIconsJson(String data) {
    setState(() {
      icons = (json.decode(data) as List)
          .map((js) => WeatherIcon.fromJson(js))
          .toList();
    });
  }

  _MyHomePageState() {
    RequestHelper.getCurrentWeather(
        (data) => changeWeatherData(data), () => print('error'));
  }

  @override
  Widget build(BuildContext context) {
    AssetImage background;
    if (new DateTime.now().hour > 6 && new DateTime.now().hour < 20) {
      background = AssetImage("assets/day.jpg");
    } else {
      background = AssetImage("assets/night.jpg");
    }
    return Scaffold(
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
                            placeholder: getDefaultWeatherIcon(),
                            image: weatherData != null
                                ? getWeatherIconUrl(weatherData.icon)
                                : getWeatherIconUrl('')),
                        title: Text(
                          weatherData != null
                              ? '${weatherData.temp} ${getTempUnit(tempUnitValue)}'
                              : '',
                          style: TextStyle(fontSize: 32.0),
                        ),
                        subtitle: Column(children: <Widget>[
                          Text(
                            weatherData != null ? weatherData.description : '',
                            style: TextStyle(fontSize: 22.0),
                          ),
                          Text(
                            weatherData != null
                                ? 'Sunrise: ${formatDateTimeFormat(weatherData.sunrise * 1000, weatherData.timezone)}'
                                : '',
                            style: TextStyle(fontSize: 22.0),
                          ),
                          Text(
                            weatherData != null
                                ? 'Sunset: ${formatDateTimeFormat(weatherData.sunset * 1000, weatherData.timezone)}'
                                : '',
                            style: TextStyle(fontSize: 22.0),
                          ),
                        ]),
                      )
                    ],
                  ),
                ),
              ],
            )));
  }
}
