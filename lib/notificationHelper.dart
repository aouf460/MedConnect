

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'views/Doctor/DoctorAppointmentDetails.dart';
import 'views/UserAppointmentDetails.dart';

class NotificationHelper{

  String title;
  String body;
  String payload;
  String id;
  String type;
  BuildContext context;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;


  NotificationHelper(){
    initialize();
    print("\n\nPayload : $payload");
  } // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project

  initialize() async{
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final IOSInitializationSettings initializationSettingsIOS =
    IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);

    final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  showNotification({String title, String body, String payload, String id, BuildContext context2}) async{
    context = context2;
    AndroidNotificationDetails androidPlatformChannelSpecifics =
    new AndroidNotificationDetails(
      id, body, payload,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, title, body, platformChannelSpecifics,
        payload: payload);

  }

  Future onSelectNotification(String payload) async {
    print("Called");
    if (payload != null) {
      print('\n\nnotification payload: $payload');

       if(payload.split(":")[0] == "user_id"){
         print("In Payload");
         await Navigator.push(context,
          MaterialPageRoute(builder: (context) => UserAppointmentDetails(payload.split(":")[1].toString())),
        );
      }
      else if(payload.split(":")[0] == "doctor_id"){
        await Navigator.push(context,
          MaterialPageRoute(builder: (context) => DoctorAppointmentDetails(payload.split(":")[1].toString())),
        );
      }

    }
    // await Navigator.push(
    //   context,
    //   MaterialPageRoute<void>(builder: (context) => SecondScreen(payload)),
    // );
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) => CupertinoAlertDialog(
    //     title: Text(title),
    //     content: Text(body),
    //     actions: [
    //       CupertinoDialogAction(
    //         isDefaultAction: true,
    //         child: Text('Ok'),
    //         onPressed: () async {
    //           Navigator.of(context, rootNavigator: true).pop();
    //           //await Navigator.push(
    //           // context,
    //           // MaterialPageRoute(
    //           //   builder: (context) => SecondScreen(payload),
    //           // ),
    //           //);
    //         },
    //       )
    //     ],
    //   ),
    // );
  }

}