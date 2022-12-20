// ignore_for_file: prefer_is_empty

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:thegallery/cropper/home_page.dart';
import 'package:thegallery/cropper/local_notification/notif_l0cal.dart';
import 'package:thegallery/cropper/local_notification/schedule_notifi.dart';
import 'package:thegallery/media_model.dart';
import 'package:thegallery/services/user_services.dart';
import 'package:thegallery/todo/colors.dart';
import 'package:video_player/video_player.dart';

class MyHomePage extends StatefulWidget {
  var data;
  MyHomePage({required this.data});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<Media> _userList = <Media>[];
  final _userService = MediaService();
  late VideoPlayerController _controller;

  late Future<void> _video;
  @override
  void initState() {
    super.initState();
    NotificationApi.init();
    getAllUserDetails();

  }

  getAllUserDetails() async {
    var users = await _userService.readAllMedia();
    _userList = <Media>[];
    users.forEach((user) {
      setState(() {
        var userModel = Media();
        userModel.id = user['id'];
        userModel.mediaType = user['mediaType'].toString();
        userModel.date = user['date'].toString();
        userModel.mediaUrl = user['mediaUrl'].toString();
        userModel.time = user['time'].toString();
        _userList.add(userModel);
      });
    });
    print("user data ${_userList[0].mediaType}");
    await NotificationApi.showNotification(body: "network noonnn");
  }

  // @override
  // void initState() {
  //   print("widget.media: ${widget.data}");
  //   if (widget.data != null) {
  //     getAllUserDetails();
  //     for (int i = 0; i < _userList.length; i++) {
  //       NotificationHelper().scheduledNotification(
  //         hour: int.parse(_userList[i].time.toString().split(":")[0]),
  //         minutes: int.parse(_userList[i].time.toString().split(":")[1]),
  //         id: int.parse(_userList[i].id.toString()),
  //         sound: 'sound0',
  //       );
  //     }
  //   }

  //   getAllUserDetails();
  //   super.initState();
  // }

  _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  _deleteFormDialog(BuildContext context, userId) {
    return showDialog(
        context: context,
        builder: (c) {
          print("userId $userId");
          return AlertDialog(
            title: const Text(
              'Are You Sure to Delete',
              style: TextStyle(color: Colors.teal, fontSize: 20),
            ),
            actions: [
              TextButton(
                  style: TextButton.styleFrom(
                      primary: Colors.white, // foreground
                      backgroundColor: Color.fromARGB(255, 243, 117, 108)),
                  onPressed: () {
                    var result = _userService.deleteMedia(userId);
                    if (result != null) {
                      getAllUserDetails();
                      Navigator.pop(context);

                      _showSuccessSnackBar('User Detail Deleted Success');
                    }
                  },
                  child: const Text('Delete')),
              TextButton(
                  style: TextButton.styleFrom(
                      primary: Colors.white, // foreground
                      backgroundColor: Colors.teal),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Close'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("local storage".toUpperCase()),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _userList.length == 0
                ? const Center(
                    child: Text(
                      "upload data to view here..!",
                      style: TextStyle(fontSize: 20),
                    ),
                  )
                : SizedBox(
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisSpacing: 4,
                                mainAxisSpacing: 4,
                                crossAxisCount: 2),
                        itemCount: _userList.length,
                        itemBuilder: (context, index) {
                          _controller = VideoPlayerController.file(
                              File(_userList[index].mediaUrl.toString()));
                          _video = _controller.initialize();

                          return GestureDetector(
                            onLongPress: () {
                              print("iddd:${_userList[index].id} ");
                              _deleteFormDialog(context, _userList[index].id);
                            },
                            child: Container(
                              width: 150,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        _userList[index].id.toString(),
                                        textAlign: TextAlign.start,
                                        maxLines: 2,
                                        overflow: TextOverflow.clip,
                                        style:
                                            const TextStyle(color: textBlack),
                                      ),
                                      Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.16,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.3,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(3)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(3.0),
                                            child: ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(10)),
                                              child: _userList[index]
                                                      .mediaUrl!
                                                      .endsWith("mp4")
                                                  ? AspectRatio(
                                                      aspectRatio: _controller
                                                          .value.aspectRatio,
                                                      child: VideoPlayer(
                                                        _controller,
                                                      ),
                                                    )
                                                  : Image.file(
                                                      File(_userList[index]
                                                          .mediaUrl
                                                          .toString()),
                                                      fit: BoxFit.cover,
                                                    ),
                                            ),
                                          )),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SizedBox(
                                          width: 152,
                                          child: Text(
                                            _userList[index].mediaType ?? '',
                                            textAlign: TextAlign.start,
                                            maxLines: 2,
                                            overflow: TextOverflow.clip,
                                            style: const TextStyle(
                                                color: textBlack),
                                          ),
                                        ),
                                        Text(
                                          "${_userList[index].date} ${_userList[index].time}",
                                          textAlign: TextAlign.start,
                                          maxLines: 2,
                                          overflow: TextOverflow.clip,
                                          style:
                                              const TextStyle(color: textBlack),
                                        ),
                                        // Padding(
                                        //   padding: const EdgeInsets.only(right: 8, left: 4),
                                        //   child: Text(widget.id,
                                        //       style: const TextStyle(
                                        //           color: textBlack,
                                        //           fontWeight: FontWeight.bold,
                                        //           fontSize: 14)),
                                        // )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
