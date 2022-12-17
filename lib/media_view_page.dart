import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:thegallery/cropper/home_page.dart';
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

  getAllUserDetails() async {
    var users = await _userService.readAllMedia();
    _userList = <Media>[];
    users.forEach((user) {
      setState(() {
        var userModel = Media();
        userModel.id = user['id'];
        userModel.mediaType = user['mediaType'];
        userModel.date = user['date'];
        userModel.mediaUrl = user['mediaUrl'];
        userModel.time = user['time'];
        _userList.add(userModel);
      });
    });
  }

  @override
  void initState() {
    if (widget.data != null) {
      getAllUserDetails();
      _showSuccessSnackBar('User Detail Added Success');
    }

    getAllUserDetails();
    super.initState();
  }

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
        title:  Text("local storage".toUpperCase()),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                                  style: const TextStyle(color: textBlack),
                                ),
                                Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.16,
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(3)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.all(
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
                                      style: const TextStyle(color: textBlack),
                                    ),
                                  ),
                                  Text(
                                    "${_userList[index].date} ${_userList[index].time}",
                                    textAlign: TextAlign.start,
                                    maxLines: 2,
                                    overflow: TextOverflow.clip,
                                    style: const TextStyle(color: textBlack),
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
          // Container(
          //   height: 200,
          //   child: ListView.builder(
          //       scrollDirection: Axis.horizontal,
          //       itemCount: _userList.length,
          //       itemBuilder: (context, index) {
          //         return Card(
          //           child: Column(
          //             children: [
          //               Container(
          //                 height: 250,
          //                 width: 200,
          //                 child: Column(
          //                   children: [
          //                     Padding(
          //                       padding: const EdgeInsets.only(left: 20),
          //                       child: Row(
          //                         children: [
          //                           Text(
          //                               'Id : ${_userList[index].id.toString()}'),
          //                           Text(_userList[index].mediaType ?? ''),
          //                           IconButton(
          //                               onPressed: () {
          //                                 print("iddd:${_userList[index].id} ");
          //                                 _deleteFormDialog(
          //                                     context, _userList[index].id);
          //                               },
          //                               icon: const Icon(
          //                                 Icons.delete,
          //                                 color: Colors.red,
          //                               ))
          //                         ],
          //                       ),
          //                     ),

          //                     Container(
          //                       height: 150,
          //                       width: 130,
          //                       child: Image.network(
          //                         _userList[index].mediaUrl ?? '',
          //                         fit: BoxFit.cover,
          //                       ),
          //                     ),
          //                     // ListTile(

          //                     //   title: Row(
          //                     //     children: [
          //                     //       Text(
          //                     //         _userList[index].mediaUrl ?? '',
          //                     //         maxLines: 2,
          //                     //       ),
          //                     //       SizedBox(
          //                     //         width: 30,
          //                     //       ),
          //                     //       Text('des:click'),
          //                     //     ],
          //                     //   ),
          //                     //   trailing: Row(
          //                     //     mainAxisSize: MainAxisSize.min,
          //                     //     children: [
          //                     //       IconButton(
          //                     //           onPressed: () {},
          //                     //           icon: const Icon(
          //                     //             Icons.edit,
          //                     //             color: Colors.teal,
          //                     //           )),
          //                     //
          //                     //     ],
          //                     //   ),
          //                     // ),
          //                   ],
          //                 ),
          //               ),
          //               Text(
          //                 _userList[index].date ?? '',
          //                 maxLines: 2,
          //               ),
          //               Text(_userList[index].time ?? ''),
          //             ],
          //           ),
          //         );
          //       }),
          // ),
        ],
      ),
    );
  }
}
