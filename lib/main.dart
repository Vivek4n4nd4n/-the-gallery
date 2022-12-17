import 'package:flutter/material.dart';
import 'package:thegallery/cropper/home_page.dart';
import 'package:thegallery/cropper/local_notification/notif_l0cal.dart';
import 'package:workmanager/workmanager.dart';

const fetchBackground = "getbg";
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case fetchBackground:
        await NotificationApi.showNotification(
            image: "image", body: "no internet");

        // Code to run in background
        break;
    }
    NotificationApi.init();

    return Future.value(true);
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  Workmanager().registerOneOffTask(fetchBackground, fetchBackground,
      inputData: <String, dynamic>{
        'hello': 1,
      },
      initialDelay: Duration(seconds: 3));
  runApp(const MyApp());
}

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
