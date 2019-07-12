import 'package:flutter/material.dart';
import 'package:flutter_app/api/request_helper.dart';
import 'package:flutter_app/entities/weather_info_predictions.dart';
import 'package:flutter_app/utils.dart';

class WeatherForecast extends StatefulWidget{

  final String cityId;
  final String tempUnitValue;

  WeatherForecast({Key key, this.cityId, this.tempUnitValue}) : super(key: key);

  @override
  _WeatherForecastState createState() => _WeatherForecastState();
}

class _WeatherForecastState extends State<WeatherForecast> {
  WeatherInfoPredictions predictions;

  @override
  void initState() {
    super.initState();
    RequestHelper.getPredictions(changeWeatherData, () => print('error'), widget.cityId);
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

  Widget _expanded(Widget child, int flex) =>  Expanded(flex: flex, child: child);

  Column dailyPredictions() {
    List<Widget> list = new List<Widget>();
    if(predictions != null) {
      for (var i = 0; i < predictions.predictions.length; i += 8) {
        List<Widget> contents = new List<Widget>();
        contents.add(_expanded(Text("${getWeekDay(predictions.predictions[i].dateTime.weekday)}",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 17)), 2));

        contents.add(_expanded(FadeInImage.assetNetwork(
            height: 100,
            placeholder: getDefaultWeatherIcon(),
            image: predictions.predictions[i] != null
                ? getWeatherIconUrl(predictions.predictions[i].icon)
                : getWeatherIconUrl('')), 3));
        contents.add(_expanded(Text("${predictions.predictions[i].temp.toStringAsFixed(0)} ${getTempUnit(widget.tempUnitValue)}",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black26)), 1));
        list.add(Row(children: contents));
      }
    }
    return new Column(children: list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(4294967295).withOpacity(0.6),
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
