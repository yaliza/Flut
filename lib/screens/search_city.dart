import 'package:flutter/material.dart';
import 'package:flutter_app/entities/city.dart';
import 'package:flutter_app/api/request_helper.dart';
import 'dart:collection';
import 'package:flutter_app/preferences_helper.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SearchCityPage extends StatefulWidget {
  SearchCityPage({Key key, this.title}) : super(key: key);

  static const String routeName = "/MyItemsPage";
  final String title;

  @override
  _SearchCityPageState createState() => new _SearchCityPageState();
}

class _SearchCityPageState extends State<SearchCityPage> {
  List<City> cities;
  List<City> filteredCities = [];
  HashSet<String> markedCitiesIds;

  String filter = '';
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      filter = controller.text;
    });
    RequestHelper.getCitiesList(changeCitiesList, () => {});
    PreferencesHelper.getMarkedCitiesIds()
        .then((list) => changeMarkedCitiesList(list));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: cities == null
            ? SpinKitChasingDots(color: Colors.blueAccent, size: 50.0)
            : getMainContentWidget());
  }

  Widget getMainContentWidget() {
    return Column(children: <Widget>[
      Padding(padding: EdgeInsets.only(top: 30.0, left: 20.0, right: 20.0)),
      TextField(
        decoration: InputDecoration(labelText: "Search city"),
        controller: controller,
        onEditingComplete: onEditingComplete,
      ),
      Expanded(
          child: ListView.builder(
              itemCount: filteredCities.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                    child: Row(children: <Widget>[
                  Expanded(flex: 1, child: Text(filteredCities[index].name)),
                  Checkbox(
                      value: markedCitiesIds.contains(filteredCities[index].id),
                      onChanged: (val) =>
                          changeMarkedCity(filteredCities[index].id, val))
                ]));
              }))
    ]);
  }

  void onEditingComplete() {
    filterCities();
  }

  void changeMarkedCity(String id, bool value) {
    value == false ? markedCitiesIds.remove(id) : markedCitiesIds.add(id);
    setState(() {});
    PreferencesHelper.setMarkedCitiesIds(markedCitiesIds.toList());
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

  void changeCitiesList(List<City> value) {
    setState(() {
      cities = value;
    });
    filterCities();
  }

  void changeMarkedCitiesList(List<String> list) {
    setState(() {
      markedCitiesIds = HashSet<String>();
      if (list != null) {
        list.forEach((str) => markedCitiesIds.add(str));
      }
    });
  }
}
