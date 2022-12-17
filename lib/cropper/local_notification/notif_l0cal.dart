

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:thegallery/cropper/local_notification/utils.dart';


class NotificationApi {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String?>();

  static Future notificationDetails(image) async {

    final largeIconPath =await Utils.downloadFile(image,
   'largeIcon' );
    final bigPicturePath = await Utils.downloadFile(image,
    'bigPicture');
  final  styleInformation = BigPictureStyleInformation(


    FilePathAndroidBitmap(bigPicturePath),
    largeIcon: FilePathAndroidBitmap(largeIconPath),
  );


    return  NotificationDetails(
      android: AndroidNotificationDetails(
        'channel id 5',
         'channel name',
          channelDescription: 'description',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          styleInformation:styleInformation ),
      iOS:const DarwinNotificationDetails(),
    );
  }

  static Future init({bool initScheduled = false}) async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: iOS);



    await _notifications.initialize(settings,
        onDidReceiveNotificationResponse: (payload) async {
      onNotifications.add(payload.toString());
    });
  }

  static Future showNotification(
          {int id = 0,
          String? title,
          String? body,
          String? payload,
         required String image,
          }) async =>
      _notifications.show(id, title, body, await notificationDetails(image),
          payload: payload);
}
