import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:todo/Database/HiveHelper.dart';
import 'package:todo/main.dart';
import 'package:todo/utility/CustomList.dart';
class CustomScheduleNotification{
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin= FlutterLocalNotificationsPlugin();
  Future<void> requestPermission() async {
    if(await Permission.scheduleExactAlarm.isDenied){
      await Permission.scheduleExactAlarm.request();
    }
  }

  void initializeNotification() async {
    final AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings("icon");
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: onNotificationResponse);
  }

  Future<void> showNotification({required int key,required String title, required String description,required Duration duration, required String key_todo}) async {
    if(await Permission.scheduleExactAlarm.isGranted){
      AndroidNotificationDetails notificationDetails = AndroidNotificationDetails("channelId1", "channelName1",
        channelDescription: "This is a scheduled notification",
        importance: Importance.max,
        priority: Priority.high,
        // actions: <AndroidNotificationAction>[
        //   AndroidNotificationAction('delete_task', 'Delete', cancelNotification: true, showsUserInterface: true,),
        //   AndroidNotificationAction('complete_task', 'Complete', cancelNotification: true, showsUserInterface: true,),
        // ]
      );

      NotificationDetails details = NotificationDetails(android: notificationDetails);
      tz.TZDateTime sheduletime = tz.TZDateTime.now(tz.local).add(duration);
      await flutterLocalNotificationsPlugin.zonedSchedule(key, title, description, sheduletime, details, androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,matchDateTimeComponents: DateTimeComponents.time, payload: key_todo);
    }
    else{
      await requestPermission();
    }
  }
}

void onNotificationResponse(NotificationResponse response) async{
  // final int id = int.parse(response.payload!);
  // HiveHelper.init();

  print(response.actionId);
  switch(response.actionId){
    // case 'delete_task':
    //   await HiveHelper.deleteTodo(id);
    //   break;
    // case 'complete_task':
    //   await HiveHelper.updateTodoStatus(
    //     id,
    //     Status.completed,
    //   );
    //
    //   break;
    default:
        navigatorKey.currentState?.push(MaterialPageRoute(builder: (context) => HomePage(),));
  }
}