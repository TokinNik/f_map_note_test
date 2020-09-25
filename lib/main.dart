import 'package:f_map_note_test/blocs/map/map_bloc.dart';
import 'package:f_map_note_test/screens/map/map_screen.dart';
import 'package:f_map_note_test/screens/splash/splash_screen.dart';
import 'package:f_map_note_test/utils/notification_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() => runApp(BlocProvider<MapBloc>(
  create: (context) {
    NotificationManager.notificationManager.init();
    return MapBloc()..add(MarkersLoadProcessedEvent());
  },
  child: MyApp(),
),);

class MyApp extends StatelessWidget {

  final routes = <String, WidgetBuilder> {
    '/Map': (BuildContext context) => MapScreen(),
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

