import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Returns true if [url] looks like a network URL (http/https).
bool isNetworkImageUrl(String? url) {
  if (url == null || url.isEmpty) return false;
  final s = url.trim();
  return s.startsWith('http://') || s.startsWith('https://');
}

/// Returns an ImageProvider: network for URLs, otherwise asset placeholder.
/// Use when setting CircleAvatar.backgroundImage etc. so URLs are never passed to AssetImage.
ImageProvider imageProviderFor(String? urlOrPath, {required String placeholderAsset}) {
  if (urlOrPath == null || urlOrPath.isEmpty) return AssetImage(placeholderAsset);
  final s = urlOrPath.trim();
  if (s.startsWith('http://') || s.startsWith('https://')) {
    return CachedNetworkImageProvider(s);
  }
  return AssetImage(placeholderAsset);
}
