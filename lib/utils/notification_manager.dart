import 'package:f_map_note_test/db/database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationManager {
  NotificationManager._();

  static final NotificationManager notificationManager = NotificationManager._();

  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  init() async {
    var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/notif_icon');

    var initializationSettingsIOS = IOSInitializationSettings();

    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }
  Future<void> scheduleNotification(MarkerData markerData) async {
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
}