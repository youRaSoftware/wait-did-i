import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum ImageType {
  svg,
  filePath,
  other,
  network,
  none,
}

/// Универсальный виджет для отображения изображений (SVG, PNG, network).
class AppImage extends StatelessWidget {
  final double? height;
  final double? width;
  final String image;
  final BorderRadius borderRadius;
  final BoxFit? fit;
  final Color? color;
  final ColorFilter? colorFilter;
  final Widget? loader;

  const AppImage({
    required this.image,
    this.height,
    this.width,
    this.color,
    this.borderRadius = BorderRadius.zero,
    this.fit,
    this.colorFilter,
    this.loader,
    super.key,
  });

  ImageType _getImageType(String fileName) {
    if (fileName.isEmpty) {
      return ImageType.none;
    }
    if (fileName.isNetworkImage()) {
      return ImageType.network;
    }
    if (fileName.isFilePath()) {
      return ImageType.filePath;
    }
    if (fileName.isSvg()) {
      return ImageType.svg;
    }
    return ImageType.other;
  }

  ColorFilter? _getColorFilter() {
    if (colorFilter != null) {
      return colorFilter;
    }
    if (color != null) {
      return ColorFilter.mode(color!, BlendMode.srcIn);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    switch (_getImageType(image)) {
      case ImageType.svg:
        return ClipRRect(
          borderRadius: borderRadius,
          child: SizedBox(
            height: height,
            width: width,
            child: SvgPicture.asset(
              image,
              fit: fit ?? BoxFit.contain,
              width: width,
              height: height,
              colorFilter: _getColorFilter(),
            ),
          ),
        );
      case ImageType.filePath:
        return ClipRRect(
          borderRadius: borderRadius,
          child: Image.file(
            File(image),
            width: width,
            height: height,
            fit: fit,
          ),
        );
      case ImageType.other:
        return ClipRRect(
          borderRadius: borderRadius,
          child: SizedBox(
            height: height,
            width: width,
            child: Image.asset(
              image,
              width: width,
              height: height,
              fit: fit,
              color: color,
            ),
          ),
        );
      case ImageType.network:
        if (image.isSvg()) {
          return ClipRRect(
            borderRadius: borderRadius,
            child: SizedBox(
              height: height,
              width: width,
              child: SvgPicture.network(
                image,
                placeholderBuilder: (_) => Container(color: Colors.transparent),
                fit: fit ?? BoxFit.contain,
                width: width,
                height: height,
                colorFilter: _getColorFilter(),
              ),
            ),
          );
        }
        return ClipRRect(
          borderRadius: borderRadius,
          child: CachedNetworkImage(
            fadeInDuration: const Duration(milliseconds: 300),
            imageUrl: image,
            placeholder: (_, _) => loader ?? Container(color: Colors.transparent),
            errorWidget: (_, _, _) => loader ?? Container(color: Colors.transparent),
            fit: fit,
            width: width,
            height: height,
          ),
        );
      case ImageType.none:
        return SizedBox(
          height: height,
          width: width,
        );
    }
  }
}
