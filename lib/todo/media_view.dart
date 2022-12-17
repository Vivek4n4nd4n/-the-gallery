import 'package:flutter/material.dart';

import 'package:thegallery/todo/colors.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

// ignore: must_be_immutable
class FurnView extends StatefulWidget {
  String mediaUrl;
  String mediaType;
  String message;
  String id;
  FurnView(
      {Key? key,
      required this.mediaType,
      required this.mediaUrl,
      required this.message,
      required this.id})
      : super(key: key);

  @override
  State<FurnView> createState() => _FurnViewState();
}

class _FurnViewState extends State<FurnView> {
  int index = 0;
  late VideoPlayerController _controller;

  late Future<void> _video;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
          _controller = VideoPlayerController.file(File(widget.mediaUrl));
    _video = _controller.initialize();

    });

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        width: width * 0.3,
        child: Column(
          children: [
            Container(
                height: MediaQuery.of(context).size.height * 0.16,
                width: MediaQuery.of(context).size.width * 0.3,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(3)),
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    child: widget.mediaUrl.endsWith("mp4")
                        ? AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(
                              _controller,
                            ),
                          )
                        : Image.network(
                            widget.mediaUrl,
                            fit: BoxFit.cover,
                          ),
                  ),
                )),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: width * 0.33,
                    child: Text(
                      widget.mediaType,
                     
                      style: const TextStyle(color: textBlack),
                    ),
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
  }
}
