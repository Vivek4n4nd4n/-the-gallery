import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:thegallery/cropper/home_page.dart';
import 'package:thegallery/cropper/local_notification/notif_l0cal.dart';
import 'package:thegallery/media_model.dart';
import 'package:thegallery/services/user_services.dart';
import 'package:workmanager/workmanager.dart';

Future<void> main() async {
  runApp(const MyApp());
}

const simpleTaskKey = "be.tramckrijte.workmanagerExample.simpleTask";
const rescheduledTaskKey = "be.tramckrijte.workmanagerExample.rescheduledTask";
const failedTaskKey = "be.tramckrijte.workmanagerExample.failedTask";
const simpleDelayedTask = "be.tramckrijte.workmanagerExample.simpleDelayedTask";
const simplePeriodicTask =
    "sdfsdf";
const simplePeriodic1HourTask =
    "be.tramckrijte.workmanagerExample.simplePeriodic1HourTask";
const noInternet = "noInternet";
const enteredapp = "homeview";
late List<Media> _userList = <Media>[];
final _userService = MediaService();

@pragma(
    'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    NotificationApi.init();

    switch (task) {
      case noInternet:
        print("$noInternet was executed. inputData = $inputData");
        break;
      case "simplePeriodicTask":
        print("$inputData was exRecuted");

        await uploadFile(inputData).then((value) async =>
            await NotificationApi.showNotification(
                body: "upload data to local db"));

        break;
      case "db":
        var users = await _userService.readAllMedia();
        _userList = <Media>[];
        users.forEach((user) {
          var userModel = Media();
          userModel.id = user['id'];
          userModel.mediaType = user['mediaType'];
          userModel.date = user['date'];
          userModel.mediaUrl = user['mediaUrl'];
          userModel.time = user['time'];
          _userList.add(userModel);
        });
        // for (var index = 0; index < _userList.length; index++) {
        //   await NotificationApi.showNotification(
        //       body: "${_userList[index].mediaType}");
        //   await uploadFile({
        //     "imagePath": _userList[index].mediaUrl,
        //     "fileName": _userList[index].mediaType,
        //     "mediaType": _userList[index].mediaType,
        //     "pickedResult": _userList[index].id.toString(),
        //   }).then((value) async => await NotificationApi.showNotification(
        //       body: "upload data to local db"));
        //   index++;
        // }
        break;
    }

    return Future.value(true);
  });
}

getAllUserDetails() async {}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home:

            // FileUpload()
            // HomeScreen()
            //Test()
            //  PickFile()
            //ProfileView()
            const HomePage(
          title: "Upload File",
        ));
  }
}
