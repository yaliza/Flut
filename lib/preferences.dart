import 'package:flutter/material.dart';
import 'preferences_helper.dart';

class PreferencesPage extends StatefulWidget {
  PreferencesPage({Key key, this.title}) : super(key: key);

  static const String routeName = "/MyItemsPage";
  final String title;
  @override
  _PreferencesPageState createState() => new _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  String tempUnitValue = 'metric';
  var tempUnits = ['metric', 'imperial'];
  final appIdTextController = TextEditingController();

  _PreferencesPageState() {
    PreferencesHelper.getAppId().then((val) => changeAppId(val));
    PreferencesHelper.getTempUnit().then((val) => changeTempUnit(val));
  }

  @override
  void initState() {
    super.initState();
    appIdTextController.addListener(_onAppIdChanged);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Preferences"),
        ),
        body: Container(
            child: new Column(children: [
          new Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              new Expanded(
                child: Text('Temp unit: '),
                flex: 1,
              ),
              new Expanded(
                child: DropdownButton<String>(
                    value: tempUnitValue,
                    items: tempUnits.map((String value) {
                      return new DropdownMenuItem<String>(
                        value: value,
                        child: new Text(value),
                      );
                    }).toList(),
                    onChanged: (val) => _onTempUnitChanged(val)),
                flex: 3,
              )
            ],
          ),
          new Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              new Expanded(
                child: Text('Api key: '),
                flex: 1,
              ),
              new Expanded(
                child: TextField(
                  controller: appIdTextController,
                ),
                flex: 3,
              )
            ],
          )
        ])));
  }

  void changeTempUnit(String value) {
    setState(() {
      tempUnitValue = value;
    });
  }

  void changeAppId(String value) {
    appIdTextController.text = value;
  }

  void _onAppIdChanged() {
    PreferencesHelper.setAppId(appIdTextController.text);
  }

  void _onTempUnitChanged(String value) {
    changeTempUnit(value);
    PreferencesHelper.setTempUnit(value);
  }
}
