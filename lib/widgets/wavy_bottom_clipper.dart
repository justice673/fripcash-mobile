import 'package:flutter/material.dart';

class WavyBottomClipper extends CustomClipper<Path> {
  const WavyBottomClipper({this.waveHeight = 16, this.waveCount = 5});

  final double waveHeight;
  final int waveCount;

  @override
  Path getClip(Size size) {
    final path = Path()..moveTo(0, 0);

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - waveHeight);

    final waveWidth = size.width / waveCount;
    for (var i = waveCount; i > 0; i--) {
      final endX = (i - 1) * waveWidth;
      path.quadraticBezierTo(
        (i - 0.5) * waveWidth,
        size.height,
        endX,
        size.height - waveHeight,
      );
    }

    path.lineTo(0, size.height - waveHeight);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant WavyBottomClipper oldClipper) {
    return oldClipper.waveHeight != waveHeight ||
        oldClipper.waveCount != waveCount;
  }
}
