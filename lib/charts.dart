import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'api/request_helper.dart';
import 'entities/weather_info_prediction.dart';
import 'preferences_helper.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class ChartsPage extends StatefulWidget {
  ChartsPage({Key key, this.title}) : super(key: key);

  static const String routeName = "/MyItemsPage";
  final String title;

  @override
  _ChartsPageState createState() => new _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  String tempUnitValue = '';
  String cityValue = '';
  var weatherInfoPredictions = List<WeatherInfoPrediction>();
  final appIdTextController = TextEditingController();

  var formatter = new DateFormat('MMMM d');

  var dots = [FlSpot(0, 20.0)];
  var minX = 0.0;
  var maxX = 7.0;
  var minY = 11.0;
  var maxY = 25.0;
  var avgPressure = 0.0;
  var avgTemp = 0.0;
  var avgHumidity = 0.0;

  _ChartsPageState() {
    RequestHelper.getPredictions(
        (list) => changeWeatherInfoList(list), () => print('error'));
    PreferencesHelper.getCity().then((val) => changeCity(val));
    PreferencesHelper.getTempUnit().then((val) => changeTempUnit(val));
  }

  @override
  Widget build(BuildContext context) {
    List<Color> gradientColors = [Color(0xff23b6e6), Color(0xff02d39a)];
    return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Column(
          children: <Widget>[
            Expanded(
                flex: 1,
                child: Column(
                  children: <Widget>[
                    Expanded(
                        flex: 1,
                        child: Align(
                            alignment: FractionalOffset.center,
                            child: Text(cityValue,
                                style: TextStyle(fontSize: 22),
                                textAlign: TextAlign.center))),
                    Expanded(
                      flex: 1,
                      child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            getKeyValueWiget(
                                "Avg temp", avgTemp.toStringAsFixed(2)),
                            Container(color: Colors.black26, width: 1),
                            getKeyValueWiget(
                                "Avg humidity", avgHumidity.toStringAsFixed(2)),
                            Container(color: Colors.black26, width: 1),
                            getKeyValueWiget(
                                "Avg pressure", avgPressure.toStringAsFixed(2))
                          ]),
                    )
                  ],
                )),
            Expanded(
              flex: 3,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 800,
                      decoration: BoxDecoration(color: Color(0xff232d37)),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            right: 18.0, left: 12.0, top: 45, bottom: 12),
                        child: FlChart(
                          chart: LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawHorizontalGrid: true,
                                getDrawingVerticalGridLine: (value) {
                                  return const FlLine(
                                    color: Color(0xff37434d),
                                    strokeWidth: 1,
                                  );
                                },
                                getDrawingHorizontalGridLine: (value) {
                                  return const FlLine(
                                    color: Color(0xff37434d),
                                    strokeWidth: 1,
                                  );
                                },
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                horizontalTitlesTextStyle: TextStyle(
                                    color: Color(0xff68737d), fontSize: 16),
                                getHorizontalTitles: (val) => getDateLabel(val),
                                verticalTitlesTextStyle: TextStyle(
                                    color: Color(0xff67727d), fontSize: 13),
                                getVerticalTitles: (val) =>
                                    val.toStringAsFixed(2),
                                verticalTitlesReservedWidth: 28,
                                verticalTitleMargin: 12,
                                horizontalTitleMargin: 8,
                              ),
                              borderData: FlBorderData(
                                  show: true,
                                  border: Border.all(
                                      color: Color(0xff37434d), width: 1)),
                              minX: minX,
                              maxX: maxX,
                              minY: minY,
                              maxY: maxY,
                              lineBarsData: [
                                LineChartBarData(
                                  spots: dots,
                                  isCurved: true,
                                  colors: gradientColors,
                                  barWidth: 2,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(show: false),
                                  belowBarData: BelowBarData(
                                    show: true,
                                    colors: gradientColors
                                        .map((color) => color.withOpacity(0.3))
                                        .toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // ),
                    ),
                  )
                ],
              ),
            )
          ],
        ));
  }

  Widget getKeyValueWiget(String key, String value) {
    return Expanded(
        flex: 1,
        child: Column(
          children: <Widget>[
            Expanded(
                flex: 1,
                child: Align(
                    alignment: FractionalOffset.bottomCenter,
                    child: Text(value,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15)))),
            Expanded(
                flex: 1,
                child: Align(
                    alignment: FractionalOffset.topCenter,
                    child: Text(key,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12))))
          ],
        ));
  }

  String getDateLabel(double value) {
    switch (value.toInt()) {
      case 5:
        return formatter.format(DateTime.now());
      case 15:
        return formatter.format(DateTime.now().add(Duration(days: 1)));
      case 25:
        return formatter.format(DateTime.now().add(Duration(days: 2)));
      case 35:
        return formatter.format(DateTime.now().add(Duration(days: 3)));
    }
    return "";
  }

  void changeWeatherInfoList(List<WeatherInfoPrediction> predictions) {
    int i = 0;
    var newDots = <FlSpot>[];
    var newMinY = predictions[0].temp;
    var newMaxY = predictions[0].temp;
    var newAvgHumidity = 0.0;
    var newAvgPressure = 0.0;
    var newAvgTemp = 0.0;
    predictions.forEach((pred) {
      newDots.add(FlSpot(double.parse((i++).toString()), pred.temp));
      newMinY = math.min(pred.temp, newMinY);
      newMaxY = math.max(pred.temp, newMaxY);
      newAvgHumidity += pred.humidity;
      newAvgPressure += pred.pressure;
      newAvgTemp += pred.temp;
    });

    setState(() {
      dots = newDots;
      maxX = predictions.length.toDouble() - 1;
      minX = 0;
      minY = newMinY;
      maxY = newMaxY + 1.0;
      avgTemp = newAvgTemp /= predictions.length;
      avgPressure = newAvgPressure /= predictions.length;
      avgHumidity = newAvgHumidity /= predictions.length;
    });
  }

  void changeTempUnit(String value) {
    setState(() {
      tempUnitValue = value;
    });
  }

  void changeCity(String value) {
    setState(() {
      cityValue = value;
    });
  }
}