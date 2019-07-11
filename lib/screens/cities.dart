import 'package:flutter/material.dart';
import 'package:flutter_app/preferences_helper.dart';
import 'package:flutter_app/entities/weather_data.dart';
import 'package:flutter_app/api/request_helper.dart';
import 'package:flutter_app/utils.dart';
import 'search_city.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CitiesPage extends StatefulWidget {
  CitiesPage({Key key, this.title}) : super(key: key);

  static const String routeName = "/MyItemsPage";
  final String title;

  @override
  _CitiesPageState createState() => _CitiesPageState();
}

class _CitiesPageState extends State<CitiesPage> {
  List<String> citiesIds = [];
  List<WeatherData> weatherData;
  String tempUnitValue = 'metric';

  _CitiesPageState() {
    PreferencesHelper.getMarkedCitiesIds().then(_changeCitiesList);
    PreferencesHelper.getTempUnit().then(_changeTempUnitValue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
      RaisedButton(
          onPressed: navigateChangeCitiesList,
          textColor: Colors.white,
          padding: const EdgeInsets.all(0.0),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  Color(0xFF0D47A1),
                  Color(0xFF1976D2),
                  Color(0xFF42A5F5),
                ],
              ),
            ),
            padding: const EdgeInsets.all(10.0),
            child: const Text('Change cities list',
                style: TextStyle(fontSize: 20)),
          )),
      Expanded(
          flex: 1,
          child: citiesIds != null && citiesIds.length == 0
              ? Center(child: Text('No data to display. Please, add cities.'))
              : weatherData == null
                  ? SpinKitChasingDots(color: Colors.blueAccent, size: 50.0)
                  : getWidgetCitiesList())
    ]));
  }

  Widget getWidgetCitiesList() {
    return ListView.builder(
      itemCount: weatherData.length,
      itemBuilder: (context, index) {
        return Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Row(children: [
              Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: FadeInImage.assetNetwork(
                  placeholder: getDefaultWeatherIcon(),
                  height: 70.0,
                  width: 70.0,
                  image: getWeatherIconUrl(weatherData[index].icon),
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
                            formatDateTimeFormat(weatherData[index].dt,
                                weatherData[index].timezone),
                            style: TextStyle(fontSize: 14))),
                  ])),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                      '${weatherData[index].temp} ${getTempUnit(tempUnitValue)}',
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
    );
  }

  void navigateChangeCitiesList() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SearchCityPage(title: 'Search city')));
  }

  void _changeCitiesList(List<String> value) {
    if (value != null) {
      citiesIds = value;
      RequestHelper.getCurrentWeatherByIds(
          _setWeatherData, () => {}, citiesIds);
    }
  }

  void _setWeatherData(List<WeatherData> data) {
    setState(() {
      weatherData = data;
    });
  }

  void _changeTempUnitValue(String value) {
    setState(() {
      tempUnitValue = value;
    });
  }
}
