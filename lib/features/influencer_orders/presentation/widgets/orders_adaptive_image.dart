import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class OrdersAdaptiveImage extends StatelessWidget {
  const OrdersAdaptiveImage({
    super.key,
    required this.source,
    required this.width,
    required this.height,
    required this.fit,
    required this.fallback,
  });

  final String source;
  final double width;
  final double height;
  final BoxFit fit;
  final Widget fallback;

  bool get _isNetworkSource {
    final String normalized = source.trim().toLowerCase();
    return normalized.startsWith('http://') ||
        normalized.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    if (_isNetworkSource) {
      return CachedNetworkImage(
        imageUrl: source,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, _) =>
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        errorWidget: (_, _, _) => fallback,
      );
    }

    return Image.asset(
      source,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, _, _) => fallback,
    );
  }
}
