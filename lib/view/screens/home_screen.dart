import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:gatherly/models/repo/sqflite_repositor.dart';
import 'package:gatherly/view/screens/stall_overview_screen.dart';
import 'package:gatherly/view/utils/color_helper.dart';
import 'package:gatherly/view/utils/custom_widgets.dart';
import 'package:gatherly/view/utils/network_connectivityHelper.dart';
import 'package:video_player/video_player.dart';

import '../../models/constants.dart';
import '../../models/model_serialize/stall_details.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Size screenSize;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  late SqfliteRepositor _sqfliteRepositor;
  @override
  void initState() {
    _sqfliteRepositor = SqfliteRepositor();
    initConnectivity();
    connectionStatusStream =
        StreamController<List<ConnectivityResult>>.broadcast(
            onListen: () => _updateConnectionStatus);
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    FlutterNativeSplash.remove();
    super.initState();
  }

  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;

    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      return;
    }

    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    connectionStatusStream.add(result);
  }

  @override
  void dispose() {
    connectionStatusStream.close();
    _connectivitySubscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: ColorHelper.hex('#FFFFFF'),
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SearchAnchor(
                builder: (BuildContext context, SearchController controller) {
                  return SearchBar(
                    backgroundColor: WidgetStatePropertyAll<Color>(
                        ColorHelper.hex('#FFFFFF')),
                    elevation: const WidgetStatePropertyAll(0),
                    leading: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.search,
                        color: ColorHelper.hex('#6B6B6B'),
                      ),
                    ),
                    shape: WidgetStatePropertyAll<OutlinedBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: BorderSide(
                                color: ColorHelper.hex('F3F3F3'),
                                style: BorderStyle.solid))),
                    hintText: 'Search',
                    hintStyle: WidgetStatePropertyAll<TextStyle>(
                        TextStyle(color: ColorHelper.hex('#6B6B6B'))),
                  );
                },
                suggestionsBuilder:
                    (BuildContext context, SearchController controller) {
                  return List.generate(
                    3,
                    (index) => Text('Item $index'),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 20.0,
                ),
                child: Text(
                  'Stalls',
                  style: TextStyle(
                      fontSize: 38,
                      color: ColorHelper.hex('#232323'),
                      fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                  child: StreamBuilder<List<ConnectivityResult>>(
                      stream: connectionStatusStream.stream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting ||
                            !snapshot.hasData ||
                            snapshot.data == null) {
                          return getLoadingView(screenSize);
                        } else if (snapshot.data!
                            .contains(ConnectivityResult.none)) {
                          return FutureBuilder<List<Map<String, Object?>>>(
                            future: _sqfliteRepositor.readData('stalls'),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.waiting ||
                                  !snapshot.hasData) {
                                return getLoadingView(screenSize);
                              }
                              return getHomePageContent(
                                  offlineData: snapshot.data, context);
                            },
                          );
                        }
                        return StreamBuilder<QuerySnapshot>(
                            stream: userCollections.snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.waiting ||
                                  !snapshot.hasData) {
                                return getLoadingView(screenSize);
                              }
                              return getHomePageContent(
                                  snapshot: snapshot, context);
                            });
                      }))
            ],
          ),
        )));
  }

  Widget getHomePageContent(
    BuildContext context, {
    List<Map<String, Object?>>? offlineData,
    AsyncSnapshot<QuerySnapshot<Object?>>? snapshot,
  }) {
    return SingleChildScrollView(
      child: Column(
        children: List.generate(
          offlineData != null
              ? offlineData.length
              : snapshot!.data!.docs.length,
          (index) {
            StallDetails stallDetails = StallDetails.fromJson(offlineData !=
                    null
                ? offlineData[index]
                : (snapshot!.data!.docs[index].data() as Map<String, dynamic>));
            VideoPlayerController? controller;
            late Future<void> initializeVideoPlayerFuture;
            bool isImage = true;
            if (stallDetails.mediaUrls != null &&
                stallDetails.mediaUrls!.isNotEmpty &&
                stallDetails.mediaUrls![0].contains('.mp4')) {
              isImage = false;
              controller = offlineData != null
                  ? VideoPlayerController.file(File(
                      stallDetails.mediaUrls![0],
                    ))
                  : VideoPlayerController.networkUrl(
                      Uri.parse(
                        stallDetails.mediaUrls![0],
                      ),
                    );
              initializeVideoPlayerFuture = controller.initialize();

              controller.setLooping(false);
            }

            return Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Card(
                  color: ColorHelper.hex('#F2F2F7'),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: SizedBox(
                        height: 316,
                        child: Column(
                          children: [
                            SizedBox(
                                height: 178,
                                width: double.infinity,
                                child: isImage
                                    ? offlineData != null
                                        ? getImageWidget(
                                            stallDetails.mediaUrls![0])
                                        : getNetworkImageWidget(
                                            stallDetails.mediaUrls![0])
                                    //  CachedNetworkImage(
                                    //     imageUrl:
                                    //         stallDetails.mediaUrls![0],
                                    //     imageBuilder:
                                    //         (context, imageProvider) =>
                                    //             Container(
                                    //       decoration: BoxDecoration(
                                    //         image: DecorationImage(
                                    //           image: imageProvider,
                                    //           fit: BoxFit.cover,
                                    //         ),
                                    //       ),
                                    //     ),
                                    //     placeholder: (context, url) =>
                                    //         const Center(
                                    //       child:
                                    //           CircularProgressIndicator(),
                                    //     ),
                                    //     errorWidget:
                                    //         (context, url, error) =>
                                    //             const Icon(Icons.error),
                                    //   )
                                    : FutureBuilder(
                                        future: initializeVideoPlayerFuture,
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.done) {
                                            // If the VideoPlayerController has finished initialization, use
                                            // the data it provides to limit the aspect ratio of the video.
                                            return VideoPlayer(controller!);
                                          } else {
                                            // If the VideoPlayerController is still initializing, show a
                                            // loading spinner.
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          }
                                        },
                                      )),
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _getTextWidget(
                                              '${stallDetails.startDate}-${stallDetails.endDate}',
                                              TextStyle(
                                                  color: ColorHelper.hex(
                                                      '#6B6B6B'))),
                                          _getTextWidget(
                                              stallDetails.title!,
                                              TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: ColorHelper.hex(
                                                      '#000000'))),
                                          _getTextWidget(
                                              stallDetails.description!,
                                              TextStyle(
                                                  color: ColorHelper.hex(
                                                      '#6B6B6B'),
                                                  overflow:
                                                      TextOverflow.ellipsis)),
                                          _getTextWidget(
                                              '${stallDetails.mediaUrls!.length} Files',
                                              TextStyle(
                                                  color: ColorHelper.hex(
                                                      '#6B6B6B'))),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 15.0),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  StallOverviewPage(
                                                stallDetail: stallDetails,
                                                index: index,
                                                isOffline: offlineData != null,
                                                streamController:
                                                    connectionStatusStream,
                                              ),
                                            ));
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            ColorHelper.hex('#FF3348'),
                                        shape: const CircleBorder(),
                                        padding: const EdgeInsets.all(20),
                                      ),
                                      child: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        )),
                  ),
                ));
          },
        ),
      ),
    );
  }

  Padding _getTextWidget(String content, TextStyle style) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Text(content, style: style),
    );
  }
}
