import 'package:f_map_note_test/db/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationManager {
  NotificationManager._();

  static final NotificationManager notificationManager = NotificationManager._();//todo it's norm?

  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  init() async {
    var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/notif_icon');

    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);

    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
  }

  showNotification() async {
    var android = AndroidNotificationDetails(
        'id',
        'channel ',
        'description',
        priority: Priority.High,
        importance: Importance.Max);
    var iOS = IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin.show(
        0,
        'Flutter devs', 'Flutter Local Notification Demo',
        platform,
        payload: 'Welcome to the Local Notification demo');
  }

  Future<void> scheduleNotification(MarkerData markerData) async {
     // = .add(
     //    Duration(seconds: 5));
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'channel id',
      'channel name',
      'channel description');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(
        markerData.id,
        'Marker alarm',
        markerData.name,
        markerData.time,
        platformChannelSpecifics);
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future selectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    //await Navigator.push(context, MaterialPageRoute(builder: (context) => MapScreen()));//todo marker coord
  }


  Future onDidReceiveLocalNotification(int id, String title, String body, String payload) {
    //
  }
}