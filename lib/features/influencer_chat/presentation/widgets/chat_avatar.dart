import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatAvatar extends StatelessWidget {
  const ChatAvatar({
    super.key,
    required this.imageUrl,
    required this.fallbackText,
    this.size,
  });

  final String imageUrl;
  final String fallbackText;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final double avatarSize = size ?? 46.w;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14.r),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: avatarSize,
        height: avatarSize,
        fit: BoxFit.cover,
        placeholder: (_, _) =>
            _FallbackAvatar(size: avatarSize, fallbackText: fallbackText),
        errorWidget: (_, _, _) =>
            _FallbackAvatar(size: avatarSize, fallbackText: fallbackText),
      ),
    );
  }
}

class _FallbackAvatar extends StatelessWidget {
  const _FallbackAvatar({required this.size, required this.fallbackText});

  final double size;
  final String fallbackText;

  @override
  Widget build(BuildContext context) {
    final String trimmed = fallbackText.trim();
    final String initial = trimmed.isEmpty ? '?' : trimmed[0].toUpperCase();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      color: const Color(0xFFEAF6FF),
      child: Text(
        initial,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF0072DE),
        ),
      ),
    );
  }
}
