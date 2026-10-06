import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:frip_cash/theme/app_colors.dart';

bool isNetworkImageSource(String source) =>
    source.startsWith('http://') ||
    source.startsWith('https://') ||
    source.startsWith('blob:') ||
    source.startsWith('data:');

bool isAssetImageSource(String source) =>
    source.startsWith('assets/') || source.startsWith('packages/');

ImageProvider? appImageProvider(String source) {
  if (source.startsWith('data:')) {
    final bytes = decodeDataUrlBytes(source);
    if (bytes != null) return MemoryImage(bytes);
    return null;
  }
  if (isNetworkImageSource(source)) return NetworkImage(source);
  if (isAssetImageSource(source)) return AssetImage(source);
  return null;
}

/// Decodes `data:image/…;base64,…` (sell-wizard local photos) to bytes.
Uint8List? decodeDataUrlBytes(String source) {
  final match = RegExp(
    r'^data:[^;]+;base64,(.+)$',
    dotAll: true,
  ).firstMatch(source);
  if (match == null) return null;
  try {
    return base64Decode(match.group(1)!);
  } catch (_) {
    return null;
  }
}


/// Loads network URLs and bundled asset images with a shared fallback.
class SafeNetworkImage extends StatefulWidget {
  const SafeNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.iconSize = 48,
    this.showLoadingIndicator = false,
  });

  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final double iconSize;
  final bool showLoadingIndicator;

  @override
  State<SafeNetworkImage> createState() => _SafeNetworkImageState();
}

class _SafeNetworkImageState extends State<SafeNetworkImage> {
  bool _failed = false;

  @override
  void didUpdateWidget(covariant SafeNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _failed = false;
    }
  }

  void _markFailed() {
    if (_failed || !mounted) return;
    setState(() => _failed = true);
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (widget.url.isEmpty || _failed) {
      child = _ImageFallback(iconSize: widget.iconSize);
    } else if (widget.url.startsWith('data:')) {
      final bytes = decodeDataUrlBytes(widget.url);
      child = bytes == null
          ? _ImageFallback(iconSize: widget.iconSize)
          : Image.memory(
              bytes,
              key: ValueKey(widget.url.hashCode),
              width: widget.width,
              height: widget.height,
              fit: widget.fit,
              gaplessPlayback: true,
              filterQuality: FilterQuality.medium,
              errorBuilder: (context, error, stackTrace) {
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _markFailed());
                return _ImageFallback(iconSize: widget.iconSize);
              },
            );
    } else if (isAssetImageSource(widget.url)) {
      child = Image.asset(
        widget.url,
        key: ValueKey(widget.url),
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        gaplessPlayback: true,
        filterQuality: FilterQuality.medium,
        errorBuilder: (context, error, stackTrace) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _markFailed());
          return _ImageFallback(iconSize: widget.iconSize);
        },
      );
    } else if (isNetworkImageSource(widget.url)) {
      child = Image.network(
        widget.url,
        key: ValueKey(widget.url),
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        gaplessPlayback: true,
        filterQuality: FilterQuality.medium,
        loadingBuilder: widget.showLoadingIndicator
            ? (context, child, progress) {
                if (progress == null) return child;
                return _ImageFallback(
                  iconSize: widget.iconSize,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: progress.expectedTotalBytes != null
                        ? progress.cumulativeBytesLoaded /
                            progress.expectedTotalBytes!
                        : null,
                  ),
                );
              }
            : null,
        errorBuilder: (context, error, stackTrace) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _markFailed());
          return _ImageFallback(iconSize: widget.iconSize);
        },
      );
    } else {
      child = _ImageFallback(iconSize: widget.iconSize);
    }

    if (widget.borderRadius != null) {
      child = ClipRRect(borderRadius: widget.borderRadius!, child: child);
    }

    if (widget.width != null || widget.height != null) {
      child = SizedBox(width: widget.width, height: widget.height, child: child);
    }

    return child;
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({required this.iconSize, this.child});

  final double iconSize;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.grey.shade200,
      child: Center(
        child: child ??
            Icon(Icons.image_outlined, color: AppColors.textPrimary, size: iconSize),
      ),
    );
  }
}
