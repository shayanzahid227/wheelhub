import 'dart:io';

import 'package:flutter/material.dart';

class VehicleImage extends StatelessWidget {
  const VehicleImage({
    super.key,
    required this.source,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
  });

  final String source;
  final double? height;
  final double? width;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (_isAssetPath(source)) {
      return Image.asset(
        source,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: _fallback,
      );
    }

    final filePath =
        source.startsWith('file://') ? source.replaceFirst('file://', '') : source;

    return Image.file(
      File(filePath),
      height: height,
      width: width,
      fit: fit,
      errorBuilder: _fallback,
    );
  }

  bool _isAssetPath(String value) => value.startsWith('images/');

  Widget _fallback(_, __, ___) {
    return Container(
      height: height,
      width: width,
      color: const Color(0xff17253E),
      alignment: Alignment.center,
      child: const Icon(Icons.directions_car, size: 48, color: Colors.white54),
    );
  }
}
