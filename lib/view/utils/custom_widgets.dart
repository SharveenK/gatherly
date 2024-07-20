import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gatherly/view/utils/color_helper.dart';
import 'package:shimmer/shimmer.dart';

Shimmer getLoadingView(Size screenSize) {
  return Shimmer.fromColors(
      baseColor: ColorHelper.hex('#E1E1E1'),
      highlightColor: ColorHelper.hex('#FFFFFF'),
      child: SizedBox(
        width: screenSize.width,
        height: screenSize.height,
        child: Column(
          children: List.generate(
            5,
            (index) => Card(
              color: Colors.grey,
              child: SizedBox(
                width: screenSize.width,
                height: 316,
              ),
            ),
          ),
        ),
      ));
}

Image getImageWidget(String url) {
  return Image.file(File(url),
      width: double.infinity,
      errorBuilder: (context, url, error) => const Icon(Icons.error),
      fit: BoxFit.cover);
}

CachedNetworkImage getNetworkImageWidget(String url) {
  return CachedNetworkImage(
    imageUrl: url,
    imageBuilder: (context, imageProvider) => Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: imageProvider,
          fit: BoxFit.cover,
        ),
      ),
    ),
    placeholder: (context, url) => const Center(
      child: CircularProgressIndicator(),
    ),
    errorWidget: (context, url, error) => const Icon(Icons.error),
  );
}
