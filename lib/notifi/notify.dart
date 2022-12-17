// import 'dart:ui';

// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
// class notificationWidget {
//   static final _notifications = FlutterLocalNotificationsPlugin();
//   static Future init({bool initScheduled = false}) async {
//     var android = AndroidInitializationSettings('@mipmap/ic_launcher');
//     var iOS = DarwinInitializationSettings();
//     final settings = InitializationSettings(android: android, iOS: iOS);

//     await _notifications.initialize(settings);
//      }

//   static Future showNotification({
//     var id = 0,
//     var title,
//     var body,
//     var payload,
//   }) async =>
//       _notifications.show(title, body, id, await notificationDetails(android: AndroidNotificationDetails('channelId', 'channelName')));


//   static Future scheduleNotification({
//     var id = 0,
//     var title,
//     var body,
//     var payload,
//     required DateTime schduleTime
//   }) async =>
//       _notifications.zonedSchedule(title, body,
//      tz.TzDateTime.from(schduleTime, local),
//        id,payload:payload,androidAllowWhileIdle:true, uiLocalNotificationDateInterpretation:UILocalNotificationDateInterpretation.absoluteTime, await notificationDetails(), );

//   static notificationDetails({required AndroidNotificationDetails android})async {
//     return await notificationDetails(
//         // ignore: prefer_const_constructors
//         android: AndroidNotificationDetails(
//       'channel id 8',
//       'channel name',
//        channelDescription: 'description',

//       importance: Importance.max,
//       priority: Priority.high,
//      sound: RawResourceAndroidNotificationSound('notifications'),

//       //playSound: true,
//     )
    
//     );
//   }
// }
