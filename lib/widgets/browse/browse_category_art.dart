import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Flat, playful category illustrations drawn with [CustomPainter].
class BrowseCategoryArt extends StatelessWidget {
  const BrowseCategoryArt({
    super.key,
    required this.categoryId,
    required this.accent,
  });

  final String categoryId;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BrowseArtPainter(categoryId: categoryId, accent: accent),
      child: const SizedBox.expand(),
    );
  }
}

class _BrowseArtPainter extends CustomPainter {
  _BrowseArtPainter({required this.categoryId, required this.accent});

  final String categoryId;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final soft = accent.withValues(alpha: 0.22);
    final mid = accent.withValues(alpha: 0.45);
    final deep = Color.lerp(accent, const Color(0xFF1A1A1A), 0.35)!;

    // Shared atmospheric blobs.
    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.28),
      size.shortestSide * 0.42,
      Paint()..color = soft,
    );
    canvas.drawCircle(
      Offset(size.width * 0.92, size.height * 0.78),
      size.shortestSide * 0.28,
      Paint()..color = mid.withValues(alpha: 0.25),
    );

    switch (categoryId) {
      case 'women':
        _paintWomen(canvas, size, accent, deep);
      case 'men':
        _paintMen(canvas, size, accent, deep);
      case 'premium':
        _paintPremium(canvas, size, accent, deep);
      case 'kids':
        _paintKids(canvas, size, accent, deep);
      case 'home':
        _paintHome(canvas, size, accent, deep);
      case 'tech':
        _paintTech(canvas, size, accent, deep);
      case 'books':
        _paintBooks(canvas, size, accent, deep);
      case 'hobbies':
        _paintHobbies(canvas, size, accent, deep);
      case 'sports':
        _paintSports(canvas, size, accent, deep);
      default:
        canvas.drawCircle(
          Offset(size.width * 0.7, size.height * 0.55),
          size.shortestSide * 0.22,
          Paint()..color = mid,
        );
    }
  }

  void _paintWomen(Canvas canvas, Size size, Color accent, Color deep) {
    final cx = size.width * 0.68;
    final cy = size.height * 0.52;
    // Dress silhouette
    final dress = Path()
      ..moveTo(cx, cy - 38)
      ..quadraticBezierTo(cx - 22, cy - 10, cx - 34, cy + 48)
      ..lineTo(cx + 34, cy + 48)
      ..quadraticBezierTo(cx + 22, cy - 10, cx, cy - 38)
      ..close();
    canvas.drawPath(dress, Paint()..color = accent.withValues(alpha: 0.85));
    canvas.drawCircle(
      Offset(cx, cy - 52),
      14,
      Paint()..color = deep.withValues(alpha: 0.7),
    );
    // Hanger sparkle dots
    for (final o in [
      Offset(cx - 40, cy - 20),
      Offset(cx + 44, cy - 8),
      Offset(cx + 28, cy + 30),
    ]) {
      canvas.drawCircle(o, 3.5, Paint()..color = Colors.white.withValues(alpha: 0.9));
    }
  }

  void _paintMen(Canvas canvas, Size size, Color accent, Color deep) {
    final cx = size.width * 0.7;
    final cy = size.height * 0.5;
    // Shirt
    final shirt = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy + 8), width: 54, height: 62),
      const Radius.circular(10),
    );
    canvas.drawRRect(shirt, Paint()..color = accent.withValues(alpha: 0.9));
    canvas.drawCircle(Offset(cx, cy - 40), 15, Paint()..color = deep);
    // Collar V
    final collar = Path()
      ..moveTo(cx, cy - 18)
      ..lineTo(cx - 14, cy + 4)
      ..lineTo(cx + 14, cy + 4)
      ..close();
    canvas.drawPath(collar, Paint()..color = Colors.white.withValues(alpha: 0.55));
  }

  void _paintPremium(Canvas canvas, Size size, Color accent, Color deep) {
    final cx = size.width * 0.72;
    final cy = size.height * 0.48;
    final diamond = Path()
      ..moveTo(cx, cy - 36)
      ..lineTo(cx + 28, cy)
      ..lineTo(cx, cy + 40)
      ..lineTo(cx - 28, cy)
      ..close();
    canvas.drawPath(diamond, Paint()..color = accent.withValues(alpha: 0.9));
    canvas.drawPath(
      Path()
        ..moveTo(cx, cy - 36)
        ..lineTo(cx + 14, cy - 4)
        ..lineTo(cx, cy + 8)
        ..lineTo(cx - 14, cy - 4)
        ..close(),
      Paint()..color = Colors.white.withValues(alpha: 0.45),
    );
    canvas.drawCircle(
      Offset(cx + 36, cy - 28),
      5,
      Paint()..color = deep.withValues(alpha: 0.5),
    );
  }

  void _paintKids(Canvas canvas, Size size, Color accent, Color deep) {
    final cx = size.width * 0.7;
    final cy = size.height * 0.55;
    // Balloon
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy - 18), width: 46, height: 54),
      Paint()..color = accent.withValues(alpha: 0.9),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 8, cy - 28), width: 12, height: 18),
      Paint()..color = Colors.white.withValues(alpha: 0.45),
    );
    final string = Path()
      ..moveTo(cx, cy + 10)
      ..quadraticBezierTo(cx + 8, cy + 28, cx - 4, cy + 44);
    canvas.drawPath(
      string,
      Paint()
        ..color = deep
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _paintHome(Canvas canvas, Size size, Color accent, Color deep) {
    final cx = size.width * 0.68;
    final cy = size.height * 0.52;
    final roof = Path()
      ..moveTo(cx, cy - 42)
      ..lineTo(cx + 42, cy - 8)
      ..lineTo(cx - 42, cy - 8)
      ..close();
    canvas.drawPath(roof, Paint()..color = deep.withValues(alpha: 0.75));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + 18), width: 64, height: 48),
        const Radius.circular(6),
      ),
      Paint()..color = accent.withValues(alpha: 0.9),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + 26), width: 16, height: 28),
        const Radius.circular(3),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.65),
    );
  }

  void _paintTech(Canvas canvas, Size size, Color accent, Color deep) {
    final cx = size.width * 0.7;
    final cy = size.height * 0.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: 42, height: 70),
        const Radius.circular(10),
      ),
      Paint()..color = deep.withValues(alpha: 0.85),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy - 2), width: 34, height: 54),
        const Radius.circular(6),
      ),
      Paint()..color = accent.withValues(alpha: 0.95),
    );
    canvas.drawCircle(
      Offset(cx, cy + 30),
      3.5,
      Paint()..color = Colors.white.withValues(alpha: 0.8),
    );
  }

  void _paintBooks(Canvas canvas, Size size, Color accent, Color deep) {
    final baseX = size.width * 0.58;
    final baseY = size.height * 0.62;
    final colors = [
      accent,
      deep,
      accent.withValues(alpha: 0.65),
    ];
    for (var i = 0; i < 3; i++) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(baseX + i * 18, baseY - 50 - i * 6.0, 16, 58 + i * 6.0),
        const Radius.circular(3),
      );
      canvas.drawRRect(rect, Paint()..color = colors[i]);
    }
  }

  void _paintHobbies(Canvas canvas, Size size, Color accent, Color deep) {
    final cx = size.width * 0.7;
    final cy = size.height * 0.5;
    // Palette
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: 70, height: 54),
      Paint()..color = accent.withValues(alpha: 0.88),
    );
    final dots = [
      (Offset(cx - 16, cy - 8), deep),
      (Offset(cx + 6, cy - 12), const Color(0xFFFF7A59)),
      (Offset(cx + 14, cy + 6), const Color(0xFF3D8BFF)),
      (Offset(cx - 6, cy + 10), const Color(0xFFFFC857)),
    ];
    for (final (o, c) in dots) {
      canvas.drawCircle(o, 7, Paint()..color = c);
    }
    // Thumb hole
    canvas.drawCircle(
      Offset(cx - 22, cy + 4),
      9,
      Paint()..color = Colors.white.withValues(alpha: 0.55),
    );
  }

  void _paintSports(Canvas canvas, Size size, Color accent, Color deep) {
    final cx = size.width * 0.7;
    final cy = size.height * 0.5;
    canvas.drawCircle(
      Offset(cx, cy),
      32,
      Paint()..color = accent.withValues(alpha: 0.9),
    );
    final ring = Paint()
      ..color = deep.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(Offset(cx, cy), 32, ring);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: 32),
      -0.4,
      math.pi * 0.9,
      false,
      ring,
    );
    canvas.drawLine(
      Offset(cx - 28, cy - 8),
      Offset(cx + 28, cy + 10),
      ring,
    );
  }

  @override
  bool shouldRepaint(covariant _BrowseArtPainter oldDelegate) =>
      oldDelegate.categoryId != categoryId || oldDelegate.accent != accent;
}
