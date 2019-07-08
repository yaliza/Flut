import 'package:flutter/material.dart';
import 'package:flutter_app/entities/city.dart';
import 'package:flutter_app/api/request_helper.dart';
import 'dart:collection';
import 'package:flutter_app/preferences_helper.dart';

class SearchCityPage extends StatefulWidget {
  SearchCityPage({Key key, this.title}) : super(key: key);

  static const String routeName = "/MyItemsPage";
  final String title;

  @override
  _SearchCityPageState createState() => new _SearchCityPageState();
}

class _SearchCityPageState extends State<SearchCityPage> {
  List<City> cities = [];
  List<City> filteredCities = [];
  HashSet<String> markedCities;

  String filter = '';
  TextEditingController controller = TextEditingController();

  _SearchCityPageState() {
    RequestHelper.getCitiesList(changeCitiesList, () => {});
    PreferencesHelper.getMarkedCities()
        .then((list) => changeMarkedCitiesList(list));
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      filter = controller.text;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: <Widget>[
      Padding(padding: EdgeInsets.only(top: 20.0)),
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
                  Padding(
                      padding: EdgeInsetsDirectional.only(
                          bottom: 10.0, top: 10.0, start: 5.0, end: 5.0),
                      child: Text(filteredCities[index].name)),
                  Checkbox(
                      value: markedCities.contains(filteredCities[index].name),
                      onChanged: (val) =>
                          changeMarkedCity(filteredCities[index].name, val))
                ]));
              }))
    ]));
  }

  void onEditingComplete() {
    filterCities();
  }

  void changeMarkedCity(String cityName, bool value) {
    if (value == false) {
      markedCities.remove(cityName);
    } else {
      markedCities.add(cityName);
    }
    setState(() {});
    PreferencesHelper.setMarkedCities(markedCities.toList());
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
    cities = value;
    filterCities();
  }

  void changeMarkedCitiesList(List<String> list) {
    print(list);
    setState(() {
      markedCities = HashSet<String>();
      if (list != null) {
        list.forEach((str) => markedCities.add(str));
      }
    });
  }
}
