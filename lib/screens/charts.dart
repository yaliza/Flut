import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/api/request_helper.dart';
import 'package:flutter_app/entities/weather_info_prediction.dart';
import 'package:flutter_app/preferences_helper.dart';
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
  var weatherInfoPredictions = List<WeatherInfoPrediction>(),
      formatter = new DateFormat('MMMM d'),
      cityValue = '',
      tempUnitValue = '',
      dots = [FlSpot(0, 20.0)],
      minX = 0.0,
      maxX = 7.0,
      minY = 11.0,
      maxY = 25.0,
      avgPressure = 0.0,
      avgTemp = 0.0,
      avgHumidity = 0.0,
      gradientColors = [Color(0xff23b6e6), Color(0xff02d39a)],
      showAreaBelowPlot = true,
      showGrid = true;

  _ChartsPageState() {
    RequestHelper.getPredictions(changeWeatherInfoList, () => print('error'));
    PreferencesHelper.getCity().then(changeCity);
    PreferencesHelper.getTempUnit().then(changeTempUnit);
    PreferencesHelper.getFillAreaBelowPlot().then(changeShowAreaBelowPlot);
    PreferencesHelper.getShowGrid().then(changeShowGrid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //appBar: AppBar(title: Text(widget.title)),
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
                      height: MediaQuery.of(context).size.height,
                      decoration: BoxDecoration(color: Color(0xff232d37)),
                      child: Padding(
                          padding: const EdgeInsets.only(
                              right: 18.0, left: 12.0, top: 45, bottom: 12),
                          child: getChartWidget()),
                      // ),
                    ),
                  )
                ],
              ),
            )
          ],
        ));
  }

  Widget getChartWidget() {
    return FlChart(
      chart: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: showGrid,
            drawHorizontalGrid: true,
            getDrawingVerticalGridLine: (value) =>
                const FlLine(color: Color(0xff37434d), strokeWidth: 1),
            getDrawingHorizontalGridLine: (value) =>
                const FlLine(color: Color(0xff37434d), strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            show: true,
            horizontalTitlesTextStyle:
                TextStyle(color: Color(0xff68737d), fontSize: 16),
            getHorizontalTitles: (val) => getDateLabel(val),
            verticalTitlesTextStyle:
                TextStyle(color: Color(0xff67727d), fontSize: 13),
            getVerticalTitles: (val) => val.toStringAsFixed(2),
            verticalTitlesReservedWidth: 28,
            verticalTitleMargin: 12,
            horizontalTitleMargin: 8,
          ),
          borderData: FlBorderData(
              show: true,
              border: Border.all(color: Color(0xff37434d), width: 1)),
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
                show: showAreaBelowPlot,
                colors: gradientColors
                    .map((color) => color.withOpacity(0.3))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getKeyValueWiget(String key, String value) {
    return Expanded(
        flex: 1,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Align(
                alignment: FractionalOffset.bottomCenter,
                child: Text(value,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15))),
            Align(
                alignment: FractionalOffset.topCenter,
                child: Text(key,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12)))
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

  void changeShowAreaBelowPlot(bool value) {
    setState(() {
      showAreaBelowPlot = value;
    });
  }

  void changeShowGrid(bool value) {
    setState(() {
      showGrid = value;
    });
  }

  void changeCity(String value) {
    setState(() {
      cityValue = value;
    });
  }
}
