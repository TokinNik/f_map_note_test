import 'package:f_map_note_test/blocs/map/map_bloc.dart';
import 'package:f_map_note_test/screens/map/map_screen.dart';
import 'package:f_map_note_test/screens/markers/markers_screen.dart';
import 'package:f_map_note_test/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() => runApp(BlocProvider<MapBloc>(
  create: (context) {
    return MapBloc()..add(MarkersLoadProcessedEvent());
  },
  child: MyApp(),
),);

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

