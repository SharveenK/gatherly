import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gatherly/models/constants.dart';
import 'package:gatherly/models/model_serialize/stall_details.dart';
import 'package:gatherly/models/repo/sqflite_repositor.dart';
import 'package:gatherly/view/screens/carousel_slider.dart';
import 'package:gatherly/view/utils/color_helper.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:gatherly/view/utils/custom_widgets.dart';
import 'package:gatherly/view/utils/network_connectivityHelper.dart';
import 'package:gatherly/view_model/ui_bloc/ui_state_management_bloc.dart';

class StallOverviewPage extends StatefulWidget {
  const StallOverviewPage(
      {super.key,
      required this.stallDetail,
      required this.index,
      required this.isOffline,
      required this.streamController});
  final StallDetails stallDetail;
  final int index;
  final bool isOffline;
  final StreamController<List<ConnectivityResult>> streamController;
  @override
  State<StallOverviewPage> createState() => _StallOverviewPageState();
}

class _StallOverviewPageState extends State<StallOverviewPage> {
  Size screenSize = Size.zero;
  late StallDetails stallDetail;
  late SqfliteRepositor _sqfliteRepositor;
  bool isOffline = false;
  @override
  void initState() {
    _sqfliteRepositor = SqfliteRepositor();
    stallDetail = widget.stallDetail;
    isOffline = widget.isOffline;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    return BlocProvider(
      create: (_) => UiStateManagementBloc(),
      child: Builder(builder: (builderContext) {
        return Scaffold(
            body: Stack(
          children: [
            Column(
              children: [
                StreamBuilder<List<ConnectivityResult>>(
                    stream: connectionStatusStream.stream,
                    builder: (context, snapshot) {
                      if ((snapshot.data == null ||
                              snapshot.data!
                                  .contains(ConnectivityResult.none) ||
                              (snapshot.connectionState ==
                                      ConnectionState.waiting ||
                                  !snapshot.hasData)) &&
                          isOffline) {
                        return BlocBuilder<UiStateManagementBloc,
                            UiStateManagementState>(
                          buildWhen: (previous, current) {
                            if (current is FileUploadedState) {
                              if (!current.isUploaded) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Something went wrong')));
                              }
                              _sqfliteRepositor
                                  .readDataById(
                                      'stalls', '${widget.stallDetail.title}')
                                  .then(
                                (value) {
                                  stallDetail = StallDetails.fromJson(value[0]);
                                  builderContext
                                      .read<UiStateManagementBloc>()
                                      .add(UploadFileConditionEvent(true));
                                },
                              );
                              return true;
                            }
                            return false;
                          },
                          builder: (context, state) {
                            return FutureBuilder<List<Map<String, Object?>>>(
                              future: _sqfliteRepositor.readDataById(
                                  'stalls', '${widget.stallDetail.title}'),
                              builder: (context, snapshot) {
                                if (snapshot.hasData && snapshot.data != null) {
                                  if (snapshot.data != null &&
                                      snapshot.hasData) {
                                    stallDetail = StallDetails.fromJson(
                                        snapshot.data![0]);
                                  }
                                  return _getSlidingWidget(isOffline: true);
                                }
                                return getLoadingView(screenSize);
                              },
                            );
                          },
                        );
                      }
                      return StreamBuilder<DocumentSnapshot>(
                          stream: userCollections
                              .doc('stall${widget.index + 1}')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.data != null && snapshot.hasData) {
                              stallDetail = StallDetails.fromJson(snapshot.data!
                                  .data() as Map<String, dynamic>);
                            }
                            return _getSlidingWidget(isOffline: false);
                          });
                    }),
                Expanded(
                    child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _getTextWidget(
                          stallDetail.title!,
                          const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        _getTextWidget(
                          stallDetail.description!,
                          TextStyle(
                              fontSize: 16, color: ColorHelper.hex('#6B6B6B')),
                        ),
                        BlocBuilder<UiStateManagementBloc,
                            UiStateManagementState>(
                          buildWhen: (previous, current) {
                            if (current is FileUploadedState) {
                              return true;
                            }
                            return false;
                          },
                          builder: (context, state) {
                            return _getTextWidget(
                              '${stallDetail.mediaUrls!.length} Files',
                              TextStyle(
                                  fontSize: 16,
                                  color: ColorHelper.hex('#6B6B6B')),
                            );
                          },
                        ),
                        Expanded(
                          child: Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 12.0, right: 10, left: 10, top: 15),
                                child: BlocBuilder<UiStateManagementBloc,
                                    UiStateManagementState>(
                                  builder: (context, state) {
                                    return GestureDetector(
                                      onTap: () {
                                        builderContext
                                            .read<UiStateManagementBloc>()
                                            .add(UploadFileEvent(
                                                widget.index,
                                                widget.stallDetail.mediaUrls!,
                                                isOffline,
                                                widget.stallDetail));
                                      },
                                      child: DottedBorder(
                                        borderType: BorderType.RRect,
                                        radius: const Radius.circular(10),
                                        dashPattern: const [
                                          10,
                                          6,
                                        ],
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(8),
                                          decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10))),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.library_add_outlined,
                                                size: 24,
                                              ),
                                              _getTextWidget(
                                                state is UploadingProgressLevel
                                                    ? 'Uploading...${state.uploadingPercentage.toInt()}%'
                                                    : 'Attach File',
                                                const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )),
                        )
                      ],
                    ),
                  ),
                )),
              ],
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: CircleAvatar(
                            backgroundColor: ColorHelper.hex('#FFFFFF'),
                            child:
                                const Icon(Icons.keyboard_arrow_left_outlined)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment(
                  Alignment.bottomCenter.x, Alignment.bottomCenter.y - 0.7),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Wrap(
                          children: List.generate(
                            stallDetail.mediaUrls!.length,
                            (index) => Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Container(
                                color: Colors.grey,
                                height: 1.5,
                                width: (MediaQuery.of(context).size.width -
                                        40 -
                                        ((stallDetail.mediaUrls!.length + 2) *
                                            2)) /
                                    stallDetail.mediaUrls!.length,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
      }),
    );
  }

  SizedBox _getSlidingWidget({bool isOffline = false}) {
    return SizedBox(
      height: 0.7 * screenSize.height,
      child: ShowCaseCarouselSlider(
          urls: stallDetail.mediaUrls!,
          isOffline: isOffline,
          stallDetails: stallDetail),
    );
  }

  Padding _getTextWidget(String content, TextStyle style) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(content, style: style),
    );
  }
}
