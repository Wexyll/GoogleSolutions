import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

class ReceivedNotification {
  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload
  });

  final int id;
  final String title;
  final String body;
  final String payload;
}

var now;
var zone;

void initNotifications() async {
  //START OF IMPORTANT MESSAGE: This code initialises the notifications//////////////////////////////////////////////////////
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  //init plugin. app_icon needs to be added as drawable resource to android head project

  final NotificationAppLaunchDetails notificationAppLaunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  final BehaviorSubject<ReceivedNotification> didReceiveNotificationSubject = BehaviorSubject<ReceivedNotification>();
  final BehaviorSubject<String> selectedNotificationSubject = BehaviorSubject<String>();

  String currentTimeZone  = await FlutterNativeTimezone.getLocalTimezone();
  await tz.initializeTimeZones();
  zone = tz.getLocation(currentTimeZone);
  now = await tz.TZDateTime.now(zone);

  String selectedNotificationPayload;
  if(notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    selectedNotificationPayload = notificationAppLaunchDetails.payload;
  }

  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings("icon");
  final IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings(
    onDidReceiveLocalNotification: (int id, String title, String body, String payload) async {
      didReceiveNotificationSubject.add(ReceivedNotification(
        id: id, title: title, body: body, payload: payload,
      ));
    }
  );

  final MacOSInitializationSettings initializationSettingsMacOS = MacOSInitializationSettings();
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
    macOS: initializationSettingsMacOS,
  );
  //END OF IMPORTANT MESSAGE/////////////////////////////////////////////////////////////////////////////////

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: (String payload) async {
      if(payload != null) {
        debugPrint("notification payload: $payload");
      }
      selectedNotificationPayload = payload;
      selectedNotificationSubject.add(payload);
    }
  );
}

var rand = Random();

Future<void> notification(String product, int quantity, int expiry) async {
  now = await tz.TZDateTime.now(zone);
  if(expiry > 0) {
    //Create notification
    flutterLocalNotificationsPlugin.zonedSchedule(
      rand.nextInt(pow(2, 31) - 1),
      "$product going off!",
      "$quantity $product goes off today!",
      tz.TZDateTime(tz.local, now.year, now.month, now.day, 6).add(Duration(days: expiry)),
      const NotificationDetails(
        android: AndroidNotificationDetails("0", "channel", "description"),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime
    );
    /*flutterLocalNotificationsPlugin.zonedSchedule(
      rand.nextInt(pow(2, 31) - 1),
      "$product going off!",
      "$quantity $product goes off tomorrow!",
      now.add(Duration(days : expiry)),
      const NotificationDetails(
        android: AndroidNotificationDetails("0", "channel", "description"),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime
    );*/
  }
}