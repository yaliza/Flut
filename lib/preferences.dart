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
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Preferences"),
        ),
        body: Container(
        child: DropdownButton<String>(
          items: <String>['metric', 'imperial'].map((String value) {
            return new DropdownMenuItem<String>(
              value: value,
              child: new Text(value),
            );
          }).toList(),
          onChanged: (val) => _onTempUnitChanged(val),
        ))
    );
  }

  void _onTempUnitChanged(String value) {
    PreferencesHelper.setTempUnit(value);
  }
}
