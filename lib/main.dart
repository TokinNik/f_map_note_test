import 'package:f_map_note_test/screens/map/map_screen.dart';
import 'package:f_map_note_test/screens/markers/markers_screen.dart';
import 'package:f_map_note_test/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  final routes = <String, WidgetBuilder> {
    '/Map': (BuildContext context) => MapScreen(),
    '/Markers': (BuildContext context) => MarkersScreen()
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Map Note Test',
      home: SplashScreen(nextRoute: '/Map',),
      routes: routes,
    );
  }
}

