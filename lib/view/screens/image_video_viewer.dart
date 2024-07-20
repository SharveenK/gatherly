import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gatherly/models/model_serialize/stall_details.dart';
import 'package:gatherly/models/repo/sqflite_repositor.dart';
import 'package:gatherly/view/utils/custom_widgets.dart';
import 'package:gatherly/view/utils/network_connectivityHelper.dart';
import 'package:gatherly/view_model/ui_bloc/ui_state_management_bloc.dart';
import 'package:gatherly/view/utils/color_helper.dart';
import 'package:video_player/video_player.dart';

class ImageVideoViewer extends StatefulWidget {
  const ImageVideoViewer(
      {super.key,
      required this.isImage,
      required this.url,
      required this.stallDetail,
      required this.isOffline});
  final bool isImage;
  final String url;
  final StallDetails stallDetail;
  final bool isOffline;

  @override
  State<ImageVideoViewer> createState() => _ImageVideoViewerState();
}

class _ImageVideoViewerState extends State<ImageVideoViewer> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  Size screenSize = Size.zero;
  double sliderValue = 0;
  late SqfliteRepositor _sqfliteRepositor;
  bool isOffline = false;
  @override
  void initState() {
    super.initState();
    _sqfliteRepositor = SqfliteRepositor();
    isOffline = widget.isOffline;
    if (!widget.isImage) {
      _controller = isOffline
          ? VideoPlayerController.file(File(
              widget.url,
            ))
          : VideoPlayerController.networkUrl(
              Uri.parse(
                widget.url,
              ),
            );

      // Initialize the controller and store the Future for later use.
      _initializeVideoPlayerFuture = _controller.initialize();

      // Use the controller to loop the video.
      _controller.setLooping(true);
    }
  }

  @override
  void dispose() {
    if (!widget.isImage) {
      // Ensure disposing of the VideoPlayerController to free up resources.
      _controller.pause();
      _controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;

    return BlocProvider(
      create: (_) => UiStateManagementBloc(),
      child: Builder(builder: (context) {
        if (!widget.isImage) {
          _controller.addListener(
            () {
              _controller.position.then(
                (value) {
                  sliderValue = value != null
                      ? (value.inMilliseconds >
                              _controller.value.duration.inMilliseconds)
                          ? _controller.value.duration.inMilliseconds.toDouble()
                          : value.inMilliseconds.toDouble()
                      : 0;
                  context
                      .read<UiStateManagementBloc>()
                      .add(VideoSliderEvent(sliderValue));
                },
              );
            },
          );
        }
        return Scaffold(
          body: StreamBuilder<List<ConnectivityResult>>(
              stream: connectionStatusStream.stream,
              builder: (context, snapshot) {
                // if (snapshot.connectionState == ConnectionState.waiting ||
                //     !snapshot.hasData) {
                //   return getLoadingView(screenSize);
                // }

                if ((snapshot.data == null ||
                        snapshot.data!.contains(ConnectivityResult.none) ||
                        (snapshot.connectionState == ConnectionState.waiting ||
                            !snapshot.hasData)) &&
                    isOffline) {
                  return FutureBuilder<List<Map<String, Object?>>>(
                    future: _sqfliteRepositor.readDataById(
                        'stalls', '${widget.stallDetail.title}'),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        late StallDetails stallDetail;
                        if (snapshot.data != null && snapshot.hasData) {
                          stallDetail =
                              StallDetails.fromJson(snapshot.data![0]);
                        }
                        return getImageVideoWidget(context,
                            url: stallDetail.mediaUrls![0]);
                      }
                      return getLoadingView(screenSize);
                    },
                  );
                }
                return getImageVideoWidget(context);
              }),
        );
      }),
    );
  }

  Stack getImageVideoWidget(BuildContext context, {String? url}) {
    return Stack(
      children: [
        widget.isImage
            ? SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: url != null
                    ? getImageWidget(widget.url)
                    : getNetworkImageWidget(widget.url)
                // CachedNetworkImage(
                //     imageUrl: widget.url,
                //     imageBuilder: (context, imageProvider) => Container(
                //       decoration: BoxDecoration(
                //         image: DecorationImage(
                //           image: imageProvider,
                //           fit: BoxFit.cover,
                //         ),
                //       ),
                //     ),
                //     placeholder: (context, url) => const Center(
                //       child: CircularProgressIndicator(),
                //     ),
                //     errorWidget: (context, url, error) =>
                //         const Icon(Icons.error),
                //   ),
                )
            : FutureBuilder(
                future: _initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    // If the VideoPlayerController has finished initialization, use
                    // the data it provides to limit the aspect ratio of the video.
                    return VideoPlayer(_controller);
                  } else {
                    // If the VideoPlayerController is still initializing, show a
                    // loading spinner.
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
        widget.isImage
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.only(bottom: 80.0),
                child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        BlocBuilder<UiStateManagementBloc,
                            UiStateManagementState>(
                          buildWhen: (previous, current) {
                            if (current is VideoSliderState) {
                              return true;
                            }
                            return false;
                          },
                          builder: (context, state) {
                            return Slider(
                              value: sliderValue,
                              activeColor: ColorHelper.hex('#FF3348'),
                              onChanged: (value) {
                                _controller.seekTo(
                                    Duration(milliseconds: value.toInt()));
                              },
                              min: 0,
                              max: _controller.value.duration.inMilliseconds
                                  .toDouble(),
                            );
                          },
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: GestureDetector(
                                  onTap: () async {
                                    final Duration? currentPosition =
                                        await _controller.position;
                                    if (currentPosition != null) {
                                      final Duration backwardSeekPosition =
                                          currentPosition -
                                              const Duration(milliseconds: 700);

                                      _controller.seekTo(backwardSeekPosition);
                                    }
                                  },
                                  child: Icon(
                                    Icons.replay_10,
                                    size: 32,
                                    color: ColorHelper.hex('#AEAEB2'),
                                  ),
                                ),
                              ),
                              BlocBuilder<UiStateManagementBloc,
                                  UiStateManagementState>(
                                buildWhen: (previous, current) {
                                  if (current is PauseAndResumeIconState) {
                                    return true;
                                  }
                                  return false;
                                },
                                builder: (context, state) {
                                  return Padding(
                                    padding: const EdgeInsets.all(18.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        _controller.value.isPlaying
                                            ? _controller.pause()
                                            : _controller.play();
                                        context
                                            .read<UiStateManagementBloc>()
                                            .add(PauseAndResumeIconEvent(
                                                _controller.value.isPlaying));
                                      },
                                      child: CircleAvatar(
                                        radius: 20,
                                        backgroundColor:
                                            ColorHelper.hex('#FF3348'),
                                        child: _controller.value.isPlaying
                                            ? const Icon(
                                                Icons.pause,
                                                size: 32,
                                              )
                                            : const Icon(
                                                Icons.play_arrow_rounded,
                                                size: 32,
                                              ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.all(
                                  10.0,
                                ),
                                child: GestureDetector(
                                  onTap: () async {
                                    final Duration? currentPosition =
                                        await _controller.position;
                                    if (currentPosition != null) {
                                      final Duration forwardSeekPosition =
                                          const Duration(seconds: 2) +
                                              currentPosition;
                                      if (forwardSeekPosition >
                                          _controller.value.duration) {
                                        _controller
                                            .seekTo(_controller.value.duration);
                                      } else {
                                        _controller.seekTo(forwardSeekPosition);
                                      }
                                    }
                                  },
                                  child: Icon(
                                    Icons.forward_10,
                                    size: 32,
                                    color: ColorHelper.hex('#AEAEB2'),
                                  ),
                                ),
                              ),
                            ]),
                      ],
                    )),
              ),
        Align(
          alignment: Alignment.topRight,
          child: SizedBox(
            width: 50,
            height: 70,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 15,
                child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.close,
                    )),
              ),
            ),
          ),
        )
      ],
    );
  }
}
