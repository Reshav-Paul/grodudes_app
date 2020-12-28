import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageFetcher {
  static Widget getImage(url,
      {BoxFit fit = BoxFit.contain,
      Duration fadeInDuration = const Duration(milliseconds: 500)}) {
    return CachedNetworkImage(
      imageUrl: url ?? '',
      alignment: Alignment.center,
      errorWidget: (context, url, error) => Align(
        alignment: Alignment.center,
        child: Icon(
          Icons.error,
          size: 40,
          color: Colors.red[400],
        ),
      ),
      filterQuality: FilterQuality.low,
      fit: fit,
      fadeInDuration: fadeInDuration,
      progressIndicatorBuilder: (context, url, downloadProgress) => Align(
        alignment: Alignment.center,
        child: LimitedBox(
          maxHeight: 6,
          maxWidth: 6,
          child: CircularProgressIndicator(
            value: downloadProgress.progress,
          ),
        ),
      ),
    );
  }
}
