import 'package:flutter/material.dart';
import 'package:flutter_app/preferences_helper.dart';
import 'package:flutter_app/entities/weather_data.dart';
import 'package:flutter_app/api/request_helper.dart';
import 'package:flutter_app/utils.dart';

class CitiesPage extends StatefulWidget {
  CitiesPage({Key key, this.title}) : super(key: key);

  static const String routeName = "/MyItemsPage";
  final String title;

  @override
  _CitiesPageState createState() => _CitiesPageState();
}

class _CitiesPageState extends State<CitiesPage> {
  List<String> citiesIds = [];
  List<WeatherData> weatherData = [];
  String tempUnitValue = 'metric';

  _CitiesPageState() {
    PreferencesHelper.getMarkedCitiesIds().then(changeCitiesList);
    PreferencesHelper.getTempUnit().then(changeTempUnitValue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView.builder(
      itemCount: weatherData.length,
      itemBuilder: (context, index) {
        return Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Row(children: [
              Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: FadeInImage.assetNetwork(
                  placeholder: Utils.getDefaultWeatherIcon(),
                  height: 70.0,
                  width: 70.0,
                  image: Utils.getWeatherIconUrl(weatherData[index].icon),
                ),
              ),
              Expanded(
                  flex: 5,
                  child:
                      Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(weatherData[index].cityName,
                          style: TextStyle(fontSize: 18)),
                    ),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                            Utils.formatDateTimeFormat(weatherData[index].dt, weatherData[index].timezone),
                            style: TextStyle(fontSize: 14))),
                  ])),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                      '${weatherData[index].temp} ${Utils.getTempUnit(tempUnitValue)}',
                      style: TextStyle(fontSize: 16)),
                ),
              )
            ]),
            Padding(
                padding: EdgeInsets.only(left: 90.0),
                child: Container(color: Colors.black26, height: 1))
          ],
        );
      },
    ));
  }

  void changeCitiesList(List<String> value) {
    if (value != null) {
      citiesIds = value;
      weatherData.clear();
      RequestHelper.getCurrentWeatherByIds(setWeatherData, () => {}, citiesIds);
    }
  }

  void setWeatherData(List<WeatherData> data) {
    setState(() {
      weatherData = data;
    });
  }

  void changeTempUnitValue(String value) {
    setState(() {
      tempUnitValue = value;
    });
  }
}
