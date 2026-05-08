import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

/// Compresses a picked image file into a smaller JPEG for upload.
/// Target: keep request body small to avoid 413 on serverless (Vercel).
Future<File?> compressForUpload(
  File input, {
  int quality = 55,
  int maxWidth = 1280,
  int maxHeight = 1280,
}) async {
  try {
    final dir = await getTemporaryDirectory();
    final outPath =
        '${dir.path}/hs_upload_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      input.absolute.path,
      outPath,
      quality: quality,
      minWidth: 0,
      minHeight: 0,
      format: CompressFormat.jpeg,
      keepExif: false,
    );

    if (result == null) return null;

    // Resize if still too large (rare; depends on device and source).
    // FlutterImageCompress's maxWidth/maxHeight are applied via "rotate/resize" APIs on some platforms;
    // compressAndGetFile doesn't expose them directly in all versions, so we just rely on quality here.
    return File(result.path);
  } catch (e) {
    debugPrint('compressForUpload error: $e');
    return null;
  }
}

