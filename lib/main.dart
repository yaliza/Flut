import 'package:flutter/material.dart';
import 'package:flutter_app/screens/charts.dart';
import 'package:flutter_app/screens/cities.dart';
import 'package:flutter_app/screens/home.dart';
import 'package:flutter_app/screens/preferences.dart';

import 'screens/charts.dart';
import 'screens/preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var routes = <String, WidgetBuilder>{
      PreferencesPage.routeName: (BuildContext context) =>
          new PreferencesPage(title: "Preferences"),
    };
    return MaterialApp(
      title: 'Weather',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(),
      routes: routes,
    );
  }
}

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  final List<Widget> _children = [
    MyHomePage(title: 'Home'),
    PreferencesPage(title: 'Preferences'),
    ChartsPage(title: 'Charts'),
    CitiesPage(title: 'Cities')
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather'),
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.blue,
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.home),
            title: new Text('Home', style: new TextStyle(color: Colors.blue)),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.settings),
            title:
                new Text('Settings', style: new TextStyle(color: Colors.blue)),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.show_chart),
              title: Text('Chart', style: new TextStyle(color: Colors.blue))),
          BottomNavigationBarItem(
              icon: Icon(Icons.location_city),
              title: Text('Cities', style: new TextStyle(color: Colors.blue)))
        ],
      ),
    );
  }
}
