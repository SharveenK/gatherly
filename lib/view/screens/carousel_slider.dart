import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:gatherly/models/model_serialize/stall_details.dart';
import 'package:gatherly/view/screens/image_video_viewer.dart';
import 'package:gatherly/view/utils/color_helper.dart';
import 'package:gatherly/view/utils/custom_widgets.dart';
import 'package:gatherly/view/utils/network_connectivityHelper.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ShowCaseCarouselSlider extends StatefulWidget {
  const ShowCaseCarouselSlider(
      {super.key,
      required this.urls,
      required this.isOffline,
      required this.stallDetails});

  final List<String> urls;
  final bool isOffline;
  final StallDetails stallDetails;

  @override
  State<ShowCaseCarouselSlider> createState() => _ShowCaseCarouselSliderState();
}

class _ShowCaseCarouselSliderState extends State<ShowCaseCarouselSlider> {
  late List<Widget> items;
  CarouselController carouselController = CarouselController();
  late List<Future<void>> initializeVideoPlayerFutureList = [];
  late List<VideoPlayerController> controllerList = [];

  @override
  Widget build(BuildContext context) {
    items = List.generate(
      widget.urls.length,
      (index) {
        controllerList.add(widget.isOffline
            ? VideoPlayerController.file(File(widget.urls[index]))
            : VideoPlayerController.networkUrl(
                Uri.parse(
                  '',
                ),
              ));
        initializeVideoPlayerFutureList.add(Future.value());
        if (widget.urls[index].contains('.mp4')) {
          VideoPlayerController controller = widget.isOffline
              ? VideoPlayerController.file(File(widget.urls[index]))
              : VideoPlayerController.networkUrl(
                  Uri.parse(
                    widget.urls[index],
                  ),
                );

          Future<void> initializeVideoPlayerFuture =
              controller.initialize().then(
            (value) {
              controller.pause();
            },
          );

          controller.setLooping(false);
          controller.pause();

          controllerList[index] = controller;
          initializeVideoPlayerFutureList[index] = initializeVideoPlayerFuture;
        }
        return _getSlidingElement(widget.urls[index], context, index);
      },
    );
    return _getCarouselSlider(context);
  }

  Widget _getCarouselSlider(BuildContext context) {
    return CarouselSlider(
      carouselController: carouselController,
      items: items,

      //Slider Container properties
      //carousel Slider flutter
      options: CarouselOptions(
        height: MediaQuery.of(context).size.height * 0.7,
        enlargeCenterPage: true,
        onPageChanged: (index, reason) {
          if (widget.urls[index].contains('.mp4') &&
              !controllerList[index].value.isPlaying) {
            controllerList[index].play();
          }

          for (VideoPlayerController controller in controllerList) {
            if (controller.value.isPlaying &&
                controllerList.indexOf(controller) != index) {
              controller.pause();
            }
          }
        },
        autoPlay: true,
        aspectRatio: 3 / 9,
        autoPlayCurve: Curves.fastOutSlowIn,
        enableInfiniteScroll: true,
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        viewportFraction: 1,
      ),
    );
  }

  Widget _getSlidingElement(String url, BuildContext context, int index) {
    return Stack(
      children: [
        StreamBuilder<List<ConnectivityResult>>(
            stream: connectionStatusStream.stream,
            builder: (context, snapshot) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: url.contains('.mp4')
                    ? FutureBuilder(
                        future: initializeVideoPlayerFutureList[index],
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return VideoPlayer(controllerList[index]);
                          } else {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        },
                      )
                    : widget.isOffline
                        ? getImageWidget(url)
                        : getNetworkImageWidget(url),
              );
            }),
        Align(
          alignment: Alignment.topRight,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: GestureDetector(
                onTap: () {
                  for (VideoPlayerController controller in controllerList) {
                    controller.pause();
                  }
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageVideoViewer(
                          isImage: !url.contains('.mp4'),
                          url: url,
                          stallDetail: widget.stallDetails,
                          isOffline: widget.isOffline,
                        ),
                      ));
                },
                child: CircleAvatar(
                    backgroundColor: ColorHelper.hex('#FFFFFF'),
                    child: const Icon(Icons.file_upload_outlined)),
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    for (VideoPlayerController controller in controllerList) {
      controller.pause();
      controller.dispose();
    }
    super.dispose();
  }
}
