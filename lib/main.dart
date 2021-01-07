import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:workmanager/workmanager.dart';

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) async {
    if (task == 'uniqueKey') {
      ///do the task in Backend for how and when to send notification
      var response = await http.get('https://reqres.in/api/users/2');
      Map dataComingFromTheServer = json.decode(response.body);

      /// here making the notifcation pop up and be shown in status bar
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails('your channel id', 'your channel name',
              'your channel description',
              importance: Importance.max,
              priority: Priority.high,
              showWhen: false);
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
          0,
          dataComingFromTheServer['data']['first_name'],
          dataComingFromTheServer['data']['email'],
          platformChannelSpecifics,
          payload: 'item x');
    }
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
/*******************initialize the flutter_local_notification****************************/
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings(
          'app_icon'); //app_icon needs to be a added as a drawable resource to the Android head project
  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings();
  final MacOSInitializationSettings initializationSettingsMacOS =
      MacOSInitializationSettings();
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: selectNotification);
/*******************initialize WorkManager****************************/

  Workmanager.initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode:
          true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
      );

  //register your task
  Workmanager.registerPeriodicTask(
    "1",
    "uniqueKey",
    frequency: Duration(minutes: 15),
  );
  runApp(MyApp());
}

Future selectNotification(String payload) async {
  if (payload != null) {
    debugPrint('notification payload: $payload');
  }
  // here you can do the logic on pressing the notication
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Testing Notification in Background'),
      ),
    );
  }
}
