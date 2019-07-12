import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_app/api/request_helper.dart';
import 'package:flutter_app/entities/weather_data.dart';
import 'package:flutter_app/entities/weather_icon.dart';
import 'package:flutter_app/preferences_helper.dart';
import 'package:flutter_app/screens/weather_forecast.dart';
import 'package:flutter_app/utils.dart';
import 'package:location/location.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> dropdownValues;

  String currentCityValue;
  WeatherData currentWeatherData;
  List<WeatherData> citiesWeather;
  String tempUnitValue = '';
  List<WeatherIcon> icons;
  String iconUrl = '';

  List<String> weatherConditionsMainDescription = ['thunderstorm', 'drizzle', 'snow'];

  void getIconUrl() {
    for (WeatherIcon icon in icons) {
      if (weatherConditionsMainDescription.contains(icon.description)) {
        if (icon.description == currentWeatherData.mainDescription) {
          if (new DateTime.now().hour > 6 && new DateTime.now().hour < 20) {
            iconUrl = icon.day;
          } else {
            iconUrl = icon.night;
          }
          break;
        }
      }
      if (icon.description == currentWeatherData.description) {
        if (new DateTime.now().hour > 6 && new DateTime.now().hour < 20) {
          iconUrl = icon.day;
        } else {
          iconUrl = icon.night;
        }
        break;
      }
    }
  }

  var location = new Location();

  _MyHomePageState() {
    currentCityValue = '';
  }

  @override
  void initState() {
    super.initState();
    PreferencesHelper.getMarkedCitiesIds().then(getMarkedCitiesListIds);
    rootBundle
        .loadString('assets/weather_conditions.json')
        .then(parseWeatherIconsJson);
    PreferencesHelper.getTempUnit().then(changeTempUnit);
  }

  void getMarkedCitiesListIds(List<String> ids) {
    if (ids != null && ids.length > 0) {
      RequestHelper.getCurrentWeatherByIds(changeCitiesWeather, () => {}, ids);
    } else {
      getLocation().then(changeUserLocation);
    }
  }

  Future<Map<String, double>> getLocation() async {
    var currentLocation = <String, double>{};
    try {
      currentLocation = await location.getLocation();
    } catch (e) {
      currentLocation = null;
    }
    return currentLocation;
  }

  void changeCitiesWeather(List<WeatherData> weatherData) {
    setState(() {
      citiesWeather = weatherData;
      dropdownValues =
          weatherData.map((weatherData) => weatherData.cityName).toList();
      if (citiesWeather != null && citiesWeather.length != 0) {
        currentWeatherData = citiesWeather[0];
        currentCityValue = citiesWeather[0].cityName;
        getIconUrl();
      }
    });
  }

  void changeTempUnit(String value) {
    setState(() {
      tempUnitValue = value;
    });
  }

  void changeUserLocation(Map<String, double> loc) {
    RequestHelper.getCurrentWeatherNearestCities(
        changeCitiesWeather, () => {}, loc['latitude'], loc['longitude']);
  }

  void parseWeatherIconsJson(String data) {
    setState(() {
      icons = (json.decode(data) as List)
          .map((js) => WeatherIcon.fromJson(js))
          .toList();
    });
  }

  void changeDropdownValue(String newValue) {
    setState(() {
      if (newValue.isNotEmpty) {
        currentCityValue = newValue;
        currentWeatherData = citiesWeather
            .firstWhere((weather) => weather.cityName == currentCityValue);
      }
    });
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
            child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  dropdownValues != null && dropdownValues.length > 0
                      ? Center(
                      child: dropdownValues.length > 1
                          ? DropdownButton<String>(
                        value: currentCityValue,
                        onChanged: changeDropdownValue,
                        items: dropdownValues
                            .map<DropdownMenuItem<String>>(
                                (String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value,
                                    style: TextStyle(fontSize: 22.0)),
                              );
                            }).toList(),
                      )
                          : Text(dropdownValues[0]))
                      : Text('No cities to present. Please add them in settings.'),
                  Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          leading: FadeInImage.assetNetwork(
                              placeholder: getDefaultWeatherIcon(),
                              image: iconUrl),
                          title: Text(
                            currentWeatherData != null
                                ? '${currentWeatherData.temp} ${getTempUnit(tempUnitValue)}'
                                : '',
                            style: TextStyle(fontSize: 32.0),
                          ),
                          subtitle: Column(children: <Widget>[
                            Text(
                              currentWeatherData != null
                                  ? currentWeatherData.description
                                  : '',
                              style: TextStyle(fontSize: 22.0),
                            ),
                            Text(
                              currentWeatherData != null && currentWeatherData.sunrise != null
                                  ? 'Sunrise: ${formatDateTimeFormat(currentWeatherData.sunrise * 1000, currentWeatherData.timezone)}'
                                  : '',
                              style: TextStyle(fontSize: 22.0),
                            ),
                            Text(
                              currentWeatherData != null && currentWeatherData.sunset != null
                                  ? 'Sunset: ${formatDateTimeFormat(currentWeatherData.sunset * 1000, currentWeatherData.timezone)}'
                                  : '',
                              style: TextStyle(fontSize: 22.0),
                            ),
                          ]),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child:currentWeatherData != null ? Container(
                        height : 400,
                        child: WeatherForecast(key: Key(currentWeatherData.cityId + tempUnitValue) ,cityId: currentWeatherData.cityId, tempUnitValue: tempUnitValue)) : Container(),
                  )
                ])));
  }
}