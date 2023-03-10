// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thegallery/cropper/local_notification/notif_l0cal.dart';

import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield_new/datetime_picker_formfield_new.dart';
import 'package:thegallery/main.dart';
import 'package:thegallery/media_model.dart';
import 'package:thegallery/media_view_page.dart';
import 'package:thegallery/services/user_services.dart';
import 'package:thegallery/todo/colors.dart';
import 'package:thegallery/todo/data-list.dart';
import 'package:thegallery/todo/media_view.dart';
import 'package:video_player/video_player.dart';
import 'package:workmanager/workmanager.dart';

class HomePage extends StatefulWidget {
  final String title;
  const HomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

Future uploadFile(obj) async {
  var dio = Dio();

  if (obj["pickedResult"] != null) {
    FormData data = FormData.fromMap(
      {
        "mediaUrl": await MultipartFile.fromFile(
          obj["imagePath"],
          filename: obj["fileName"],
          contentType: MediaType("image", "jpeg"),
        ),
        "mediaType": obj["mediaType"],
      },
    );
    var response = await dio.post('https://apiv2.bemeli.com/taskapi/postCreate',
        data: data, onSendProgress: (int sent, int total) async {
      await NotificationApi.showNotification(body: "$sent:$total");

      // setState(() {
      //   dsent = sent;
      //   dtotal = total;
      // });
    }).whenComplete(() {
      debugPrint("complete:");

      NotificationApi.showNotification(
          body: "${obj["mediaType"]} Upload Completed",
          title: obj["imagePath"]);
      // _clear();
    }).catchError((onError) {
      debugPrint("error:${onError.toString()}");
    });
  } else {}
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  TextEditingController selectDateContrller = TextEditingController();
  TextEditingController selectTimeController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TimeOfDay? showTime;
  // final formate = DateFormat('hh:mm');
  int? dtotal;
  int? dsent;
  var objResult;
  XFile? _pickedFile;
  var imagePath;
  var croppedFilePath;
  var pickedFilePath;
  var imageopath;
  var pickedResult;
  var fileName;
  StreamSubscription? internetconnection;
  bool? isoffline;
  late VideoPlayerController _controller;
  late List<Media> _userList = <Media>[];
  final _userService = MediaService();

  late Future<void> _video;
  File? video;
  var mediaType;

  Future<DateTime?> selectdate() async {
    DateTime? pickDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (pickDate != null) {
      setState(() {
        selectDateContrller.text = DateFormat('dd-MM-yyyy').format(pickDate);
      });
    }
  }

  Future pickVideo() async {
    try {
      final video = await ImagePicker().pickVideo(source: ImageSource.gallery);
      if (video == null) return;
      final temporaryVideo = File(video.path);
      setState(() {
        this.video = temporaryVideo;
        _controller = VideoPlayerController.file(File(video.path));
        _video = _controller.initialize();
      });
    } on PlatformException catch (e) {}
  }

  pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      File file = File(result!.files.single.path ?? "");
      String filename = file.path.split('/').last;

      String filepath = file.path;

      setState(() {
        _controller = VideoPlayerController.file(File(filepath));
        _video = _controller.initialize();
        imagePath = filepath;
        pickedResult = result;
        fileName = filename;
        mediaType = imagePath.toString().endsWith('mp4') ? 'Video' : 'Image';
      });
    } catch (e) {}
  }

  @override
  void initState() {
    super.initState();
    NotificationApi.init();
    internetconnection = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      // whenevery connection status is changed.
      if (result == ConnectivityResult.none) {
        //there is no any connection
        setState(() {
          isoffline = true;
        });
      } else if (result == ConnectivityResult.mobile) {
        //connection is mobile data network
        setState(() {
          isoffline = false;
        });
      } else if (result == ConnectivityResult.wifi) {
        //connection is from wifi
        setState(() {
          isoffline = false;
        });
        if (isoffline == false) {
          await NotificationApi.showNotification(body: "network available");
        }
      }
    });
    Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );

    // Workmanager().registerOneOffTask(
    //   "db",
    //   "db",
    //   initialDelay: const Duration(seconds: 15),
    // );
  }

  @override
  Widget build(BuildContext context) {
    if (isoffline == true) {
      NotificationApi.showNotification(
        title: "Network issue...!",
        body: "check internet",
        payload: 'item x',
      );
    }

    return Scaffold(
      appBar: AppBar(
          title:
              isoffline == true ? Text("check internet") : Text(widget.title)),
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: _body()),
            imagePath == null
                ? ElevatedButton(
                    onPressed: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyHomePage(
                                    data: objResult,
                                  )));

                      // await NotificationApi.showNotification(
                      //     image:
                      //         "https://images.pexels.com/photos/1133957/pexels-photo-1133957.jpeg?auto=compress&cs=tinysrgb&w=600",
                      //     title: 'The Gallery',
                      //     body: "Nice images",
                      //     payload: '');
                    },
                    child: Text('view Data'))
                : SizedBox()
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (imagePath != null) {
      return _imageCard();
    } else {
      return GestureDetector(
          onTap: (() {
            pickFile();
          }),
          child: _uploadeIFile());
    }
  }

  Widget _imageCard() {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: kIsWeb ? 24.0 : 16.0),
            child: Card(
              elevation: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(kIsWeb ? 24.0 : 16.0),
                child: imagePath != null
                    ? Stack(
                        children: [
                          imagePath.toString().toLowerCase().endsWith("mp4")
                              ? AspectRatio(
                                  aspectRatio: _controller.value.aspectRatio,
                                  child: VideoPlayer(
                                    _controller,
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () {},
                                  child: Image.file(File(imagePath))),
                          Positioned(
                            top: 5,
                            right: 3,
                            child: imagePath
                                    .toString()
                                    .toLowerCase()
                                    .endsWith("mp4")
                                ? FloatingActionButton(
                                    onPressed: () {
                                      if (_controller.value.isPlaying) {
                                        setState(() {
                                          _controller.pause();
                                        });
                                      } else {
                                        setState(() {
                                          _controller.play();
                                        });
                                      }
                                    },
                                    child: Icon(_controller.value.isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow),
                                  )
                                : SizedBox(),
                          ),
                        ],
                      )
                    : GestureDetector(
                        onTap: () {
                          var obj = {
                            "pickedResult": pickedResult,
                            "mediaType": mediaType,
                            "imagePath": imagePath,
                            "fileName": fileName
                          };
                          uploadFile(obj);
                        },
                        child: Icon(Icons.image)),
                // _image(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24.0),
        _menu(),
      ],
    );
  }

  Widget _menu() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                onPressed: () {
                  _clear();
                },
                backgroundColor: Colors.red,
                tooltip: 'Delete',
                child: const Icon(Icons.delete),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                      child: TextFormField(
                    readOnly: true,
                    controller: selectDateContrller,
                    validator: (value) {
                      if (value != null && value.isEmpty) {
                        return 'please Select Date';
                      }
                      return null;
                    },
                    onTap: () {
                      selectdate();
                    },
                    decoration: const InputDecoration(
                      labelText: 'select date',
                      border: InputBorder.none,
                    ),
                  )),
                ),
                Spacer(),
                Expanded(
                  child: Card(
                    child: TextFormField(
                      controller: selectTimeController,
                      keyboardType: TextInputType.none,
                      style: TextStyle(fontSize: 10),
                      readOnly: true,
                      validator: ((value) {
                        if (showTime == null) {
                          return "Please Select Time";
                        }
                        return null;
                      }),
                      onTap: () async {
                        showTime = await showTimePicker(
                            context: context, initialTime: TimeOfDay.now());
                        selectTimeController.text = _displayTimeText(showTime);
                      },
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Time",
                      ),
                    ),

                    // DateTimeField(

                    //   controller: selectTimeController,
                    //   validator: (value) {
                    //     if (value != null && showTime == '') {
                    //       return 'please select Time';
                    //     }
                    //     return null;
                    //   },
                    //   decoration: InputDecoration(
                    //       border: InputBorder.none,
                    //       label: Padding(
                    //         padding: const EdgeInsets.all(1.0),
                    //         child: Text("Time"),
                    //       )),
                    //   format: formate,
                    //   onShowPicker: ((context, currentValue) async {
                    //     final time = await showTimePicker(
                    //         context: context,
                    //         initialTime: TimeOfDay.fromDateTime(
                    //             currentValue!));
                    //     setState(() {
                    //       showTime = time!;
                    //     });
                    //     return DateTimeField.convert(time);
                    //   }),
                    // ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: imagePath != null
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          uploadToLocalDb(
                            imagePath.toString(),
                            mediaType.toString(),
                            "${selectDateContrller.text.toString()},${selectTimeController.text.toString()}",
                            dateTimeStringToMilliseconds(
                                selectDateContrller.text.toString(),
                                selectTimeController.text.toString()),
                          );
                          Workmanager().initialize(
                            callbackDispatcher,
                            isInDebugMode: true,
                          );
                          var users = await _userService.readAllMedia();
                          _userList = <Media>[];
                          users.forEach((user) {
                            setState(() {
                              var userModel = Media();
                              userModel.id = user['id'];
                              userModel.mediaType =
                                  user['mediaType'].toString();
                              userModel.date = user['date'].toString();
                              userModel.mediaUrl = user['mediaUrl'].toString();
                              userModel.time = user['time'].toString();
                              _userList.add(userModel);
                            });
                          });

                          print("user data ${_userList[0].mediaType}");
                          var nextTimeStamp =
                              int.parse(_userList[0].time.toString()) -
                                  DateTime.now().millisecondsSinceEpoch;
                          // print(
                          //     "currentTimeStamp:  ${DateTime.now().millisecondsSinceEpoch}");
                          // print("first index time: ${_userList[0].time}");
                          // print("nextTimeStamp $nextTimeStamp");
                          uploadImgData() async {
                            Workmanager().registerOneOffTask(
                                "simplePeriodicTask", "simplePeriodicTask",
                                initialDelay:
                                    Duration(milliseconds: nextTimeStamp),
                                inputData: {
                                  "imagePath": _userList[0].mediaUrl.toString(),
                                  "fileName": _userList[0].mediaType.toString(),
                                  "mediaType":
                                      _userList[0].mediaType.toString(),
                                  "pickedResult": _userList[0].id.toString(),

                                  //
                                }).then((value) {
                              // _clear();
                              uploadImgData();
                            });
                          }

                          uploadImgData();

                          //  uploadFile();
                        }
                      },
                      child: const Text('Upload'),
                    )
                  : SizedBox()),
          const SizedBox(
            height: 10,
          ),
          dsent != null && dtotal != null
              ? dsent == dtotal
                  ? const Text(
                      "Upload Status : Completed",
                      style: TextStyle(color: Colors.green),
                    )
                  : Text(' upload status : $dsent : $dtotal')
              : const Text("Choose File")
        ],
      ),
    );
  }

  dateTimeStringToMilliseconds(String dateString, String timeString) {
    // Create a DateFormat object for parsing the date and time strings
    final DateFormat inputFormat = DateFormat('dd-MM-yyyy hh:mm a');

    // Parse the date and time strings to create a DateTime object
    DateTime dateTime = inputFormat.parse('$dateString $timeString');

    // Return the number of milliseconds since the Unix epoch
    // (1970-01-01 00:00:00 UTC)
    return dateTime.millisecondsSinceEpoch.toString();
  }

  String _displayTimeText(TimeOfDay? time) {
    if (time != null) {
      return '${time.format(context).toString()}';
    } else {
      return 'Choose The Date';
    }
  }

  Widget _uploadeIFile() {
    return Column(
      children: [
        viewdata(),
        Center(
          child: Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: SizedBox(
              width: kIsWeb ? 380.0 : 320.0,
              height: 200.0,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: DottedBorder(
                        radius: const Radius.circular(12.0),
                        borderType: BorderType.RRect,
                        dashPattern: const [8, 4],
                        color:
                            Theme.of(context).highlightColor.withOpacity(0.4),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image,
                                color: Theme.of(context).highlightColor,
                                size: 80.0,
                              ),
                              const SizedBox(height: 20.0),
                              Text(
                                'Upload an File to start',
                                style: kIsWeb
                                    ? Theme.of(context)
                                        .textTheme
                                        .headline5!
                                        .copyWith(
                                            color: Colors.amber, fontSize: 20)
                                    : Theme.of(context)
                                        .textTheme
                                        .bodyText2!
                                        .copyWith(
                                            color: Colors.blueGrey,
                                            fontSize: 20),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  uploadToLocalDb(mediaPath, mediaType, date, time) async {
    var media = Media();
    media.mediaUrl = mediaPath;
    media.mediaType = mediaType;
    media.date = date;
    media.time = time;
    var result = await MediaService().saveMedia(media);
    setState(() {
      objResult = result;
    });
    _clear();
  }

  late Future<DataList> futureAlbum;

  Future<List<DataList>> fetchAlbum() async {
    final response =
        await http.get(Uri.parse('https://apiv2.bemeli.com/taskapi/getdatas'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> result =
          const JsonDecoder().convert(response.body);
      List<dynamic> data = result["data"];

      return data.reversed.map((e) => DataList.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  Widget viewdata() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        height: 180,
        color: Colors.amber,
        child: FutureBuilder<List<DataList>>(
            future: fetchAlbum(),
            builder: (context, snapshot) {
              var size = MediaQuery.of(context).size;

              final double itemHeight =
                  (size.height - kToolbarHeight - 24) / 1.8;
              final double itemWidth = size.width / 2;

              if (snapshot.hasData) {
                return GridView.builder(
                  scrollDirection: Axis.horizontal,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: itemWidth / itemHeight / 0.4,
                      crossAxisCount: 1),
                  itemCount: 16,
                  // snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () async {},
                      child: FurnView(
                          mediaUrl: snapshot.data![index].mediaUrl.toString(),
                          message: snapshot.data![index].message.toString(),
                          id: snapshot.data![index].id.toString(),
                          mediaType: snapshot.data![index].image.toString()),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              return const Center(child: CircularProgressIndicator());
            }),
      ),
    );
  }

  void _clear() {
    setState(() {
      imagePath = null;
      dsent = null;
      dtotal = null;
      fileName = null;
      selectedDate = DateTime.now();
    });
  }
}
