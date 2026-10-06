import 'package:flutter/material.dart';
import 'package:frip_cash/theme/app_colors.dart';

/// Thin-line marketplace illustrations for signup role cards.
abstract final class RoleIllustrations {
  static const buyer = _RoleIllustration(kind: _Kind.buyer);
  static const seller = _RoleIllustration(kind: _Kind.seller);
  static const shop = _RoleIllustration(kind: _Kind.shop);
  static const enseigne = _RoleIllustration(kind: _Kind.enseigne);
  static const grandeSurface = _RoleIllustration(kind: _Kind.grandeSurface);
}

enum _Kind { buyer, seller, shop, enseigne, grandeSurface }

class _RoleIllustration extends StatelessWidget {
  const _RoleIllustration({required this.kind});

  final _Kind kind;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 78,
      height: 78,
      child: CustomPaint(
        painter: switch (kind) {
          _Kind.buyer => const _BuyerPainter(),
          _Kind.seller => const _SellerPainter(),
          _Kind.shop => const _ShopPainter(),
          _Kind.enseigne => const _EnseignePainter(),
          _Kind.grandeSurface => const _GrandeSurfacePainter(),
        },
      ),
    );
  }
}

abstract class _LinePainter extends CustomPainter {
  const _LinePainter();

  static const ink = Color(0xFF2E211C);
  static const accent = AppColors.primary;
  static const soft = Color(0xFFE9C3B4); // blush — soft fill for line art


  Paint get stroke => Paint()
    ..color = ink
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.7
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  Paint get fillSoft => Paint()..color = soft;
  Paint get fillAccent => Paint()..color = accent.withValues(alpha: 0.22);
  Paint get fillInk => Paint()..color = ink;
}

class _BuyerPainter extends _LinePainter {
  const _BuyerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final o = Offset((size.width - s) / 2, (size.height - s) / 2);

    // Soft ground blob
    canvas.drawOval(
      Rect.fromCenter(
        center: o + Offset(s * 0.5, s * 0.78),
        width: s * 0.62,
        height: s * 0.16,
      ),
      fillSoft,
    );

    // Shopping bag body
    final bag = RRect.fromRectAndRadius(
      Rect.fromLTWH(o.dx + s * 0.28, o.dy + s * 0.34, s * 0.44, s * 0.42),
      const Radius.circular(8),
    );
    canvas.drawRRect(bag, fillAccent);
    canvas.drawRRect(bag, stroke);

    // Bag handles
    final handle = Path()
      ..moveTo(o.dx + s * 0.38, o.dy + s * 0.36)
      ..cubicTo(
        o.dx + s * 0.38,
        o.dy + s * 0.18,
        o.dx + s * 0.62,
        o.dy + s * 0.18,
        o.dx + s * 0.62,
        o.dy + s * 0.36,
      );
    canvas.drawPath(handle, stroke);

    // Shirt peeking from bag
    final shirt = Path()
      ..moveTo(o.dx + s * 0.40, o.dy + s * 0.34)
      ..lineTo(o.dx + s * 0.46, o.dy + s * 0.22)
      ..lineTo(o.dx + s * 0.54, o.dy + s * 0.22)
      ..lineTo(o.dx + s * 0.60, o.dy + s * 0.34);
    canvas.drawPath(shirt, stroke);
    canvas.drawCircle(o + Offset(s * 0.5, s * 0.26), s * 0.035, fillInk);

    // Price tag
    final tag = Path()
      ..moveTo(o.dx + s * 0.66, o.dy + s * 0.48)
      ..lineTo(o.dx + s * 0.78, o.dy + s * 0.42)
      ..lineTo(o.dx + s * 0.84, o.dy + s * 0.54)
      ..lineTo(o.dx + s * 0.72, o.dy + s * 0.60)
      ..close();
    canvas.drawPath(tag, fillAccent);
    canvas.drawPath(tag, stroke);
    canvas.drawCircle(o + Offset(s * 0.70, s * 0.50), s * 0.025, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SellerPainter extends _LinePainter {
  const _SellerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final o = Offset((size.width - s) / 2, (size.height - s) / 2);

    canvas.drawOval(
      Rect.fromCenter(
        center: o + Offset(s * 0.5, s * 0.82),
        width: s * 0.58,
        height: s * 0.14,
      ),
      fillSoft,
    );

    // Phone / listing card
    final phone = RRect.fromRectAndRadius(
      Rect.fromLTWH(o.dx + s * 0.22, o.dy + s * 0.16, s * 0.38, s * 0.58),
      const Radius.circular(10),
    );
    canvas.drawRRect(phone, fillAccent);
    canvas.drawRRect(phone, stroke);

    // Photo block in listing
    final photo = RRect.fromRectAndRadius(
      Rect.fromLTWH(o.dx + s * 0.28, o.dy + s * 0.24, s * 0.26, s * 0.22),
      const Radius.circular(5),
    );
    canvas.drawRRect(photo, stroke);
    canvas.drawLine(
      o + Offset(s * 0.28, s * 0.54),
      o + Offset(s * 0.54, s * 0.54),
      stroke,
    );
    canvas.drawLine(
      o + Offset(s * 0.28, s * 0.60),
      o + Offset(s * 0.48, s * 0.60),
      Paint()
        ..color = _LinePainter.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round,
    );

    // Price tag hanging off the side
    final tag = RRect.fromRectAndRadius(
      Rect.fromLTWH(o.dx + s * 0.58, o.dy + s * 0.30, s * 0.26, s * 0.18),
      const Radius.circular(5),
    );
    canvas.drawRRect(tag, Paint()..color = Colors.white);
    canvas.drawRRect(tag, stroke);
    canvas.drawCircle(o + Offset(s * 0.64, s * 0.39), s * 0.03, stroke);

    // String to tag
    canvas.drawLine(
      o + Offset(s * 0.56, s * 0.28),
      o + Offset(s * 0.62, s * 0.34),
      stroke,
    );

    // Coin accent
    canvas.drawCircle(o + Offset(s * 0.74, s * 0.62), s * 0.08, fillAccent);
    canvas.drawCircle(o + Offset(s * 0.74, s * 0.62), s * 0.08, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ShopPainter extends _LinePainter {
  const _ShopPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final o = Offset((size.width - s) / 2, (size.height - s) / 2);

    canvas.drawOval(
      Rect.fromCenter(
        center: o + Offset(s * 0.5, s * 0.84),
        width: s * 0.66,
        height: s * 0.14,
      ),
      fillSoft,
    );

    // Awning
    final awning = Path()
      ..moveTo(o.dx + s * 0.16, o.dy + s * 0.34)
      ..lineTo(o.dx + s * 0.28, o.dy + s * 0.22)
      ..lineTo(o.dx + s * 0.72, o.dy + s * 0.22)
      ..lineTo(o.dx + s * 0.84, o.dy + s * 0.34)
      ..close();
    canvas.drawPath(awning, fillAccent);
    canvas.drawPath(awning, stroke);

    // Awning scallops
    for (var i = 0; i < 4; i++) {
      final x = o.dx + s * (0.26 + i * 0.14);
      canvas.drawArc(
        Rect.fromCenter(center: Offset(x, o.dy + s * 0.34), width: s * 0.14, height: s * 0.10),
        0,
        3.14,
        false,
        stroke,
      );
    }

    // Building body
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(o.dx + s * 0.22, o.dy + s * 0.34, s * 0.56, s * 0.42),
      const Radius.circular(4),
    );
    canvas.drawRRect(body, Paint()..color = Colors.white);
    canvas.drawRRect(body, stroke);

    // Door
    final door = RRect.fromRectAndRadius(
      Rect.fromLTWH(o.dx + s * 0.42, o.dy + s * 0.48, s * 0.16, s * 0.28),
      const Radius.circular(3),
    );
    canvas.drawRRect(door, fillAccent);
    canvas.drawRRect(door, stroke);
    canvas.drawCircle(o + Offset(s * 0.54, s * 0.62), s * 0.015, fillInk);

    // Windows
    canvas.drawRect(
      Rect.fromLTWH(o.dx + s * 0.28, o.dy + s * 0.44, s * 0.10, s * 0.12),
      stroke,
    );
    canvas.drawRect(
      Rect.fromLTWH(o.dx + s * 0.62, o.dy + s * 0.44, s * 0.10, s * 0.12),
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Neighborhood shop: small storefront + checklist of staples.
class _EnseignePainter extends _LinePainter {
  const _EnseignePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final o = Offset((size.width - s) / 2, (size.height - s) / 2);

    canvas.drawOval(
      Rect.fromCenter(
        center: o + Offset(s * 0.5, s * 0.86),
        width: s * 0.68,
        height: s * 0.12,
      ),
      fillSoft,
    );

    // Compact storefront (left)
    final roof = Path()
      ..moveTo(o.dx + s * 0.12, o.dy + s * 0.40)
      ..lineTo(o.dx + s * 0.22, o.dy + s * 0.28)
      ..lineTo(o.dx + s * 0.48, o.dy + s * 0.28)
      ..lineTo(o.dx + s * 0.56, o.dy + s * 0.40)
      ..close();
    canvas.drawPath(roof, fillAccent);
    canvas.drawPath(roof, stroke);

    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(o.dx + s * 0.16, o.dy + s * 0.40, s * 0.36, s * 0.34),
      const Radius.circular(3),
    );
    canvas.drawRRect(body, Paint()..color = Colors.white);
    canvas.drawRRect(body, stroke);

    // Door
    final door = RRect.fromRectAndRadius(
      Rect.fromLTWH(o.dx + s * 0.28, o.dy + s * 0.50, s * 0.12, s * 0.24),
      const Radius.circular(2),
    );
    canvas.drawRRect(door, fillAccent);
    canvas.drawRRect(door, stroke);

    // Window
    canvas.drawRect(
      Rect.fromLTWH(o.dx + s * 0.20, o.dy + s * 0.46, s * 0.08, s * 0.10),
      stroke,
    );

    // Product checklist card (right)
    final card = RRect.fromRectAndRadius(
      Rect.fromLTWH(o.dx + s * 0.52, o.dy + s * 0.30, s * 0.34, s * 0.44),
      const Radius.circular(6),
    );
    canvas.drawRRect(card, Paint()..color = Colors.white);
    canvas.drawRRect(card, stroke);

    // Checklist rows with checkmarks
    for (var i = 0; i < 3; i++) {
      final y = o.dy + s * (0.40 + i * 0.10);
      final box = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(o.dx + s * 0.60, y),
          width: s * 0.07,
          height: s * 0.07,
        ),
        const Radius.circular(2),
      );
      canvas.drawRRect(box, fillAccent);
      canvas.drawRRect(box, stroke);

      // Check
      final check = Path()
        ..moveTo(o.dx + s * 0.575, y)
        ..lineTo(o.dx + s * 0.592, y + s * 0.015)
        ..lineTo(o.dx + s * 0.625, y - s * 0.018);
      canvas.drawPath(check, stroke);

      // Product image stub
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(o.dx + s * 0.66, y - s * 0.025, s * 0.055, s * 0.05),
          const Radius.circular(2),
        ),
        stroke,
      );
      // Label line
      canvas.drawLine(
        Offset(o.dx + s * 0.73, y),
        Offset(o.dx + s * 0.82, y),
        stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Tall commercial building for large specialized retailers.
class _GrandeSurfacePainter extends _LinePainter {
  const _GrandeSurfacePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final o = Offset((size.width - s) / 2, (size.height - s) / 2);

    canvas.drawOval(
      Rect.fromCenter(
        center: o + Offset(s * 0.5, s * 0.88),
        width: s * 0.7,
        height: s * 0.12,
      ),
      fillSoft,
    );

    final tower = RRect.fromRectAndRadius(
      Rect.fromLTWH(o.dx + s * 0.30, o.dy + s * 0.18, s * 0.40, s * 0.62),
      const Radius.circular(4),
    );
    canvas.drawRRect(tower, Paint()..color = Colors.white);
    canvas.drawRRect(tower, stroke);

    for (var row = 0; row < 5; row++) {
      for (var col = 0; col < 2; col++) {
        canvas.drawRect(
          Rect.fromLTWH(
            o.dx + s * (0.36 + col * 0.14),
            o.dy + s * (0.26 + row * 0.10),
            s * 0.08,
            s * 0.06,
          ),
          stroke,
        );
      }
    }

    final entrance = RRect.fromRectAndRadius(
      Rect.fromLTWH(o.dx + s * 0.42, o.dy + s * 0.68, s * 0.16, s * 0.12),
      const Radius.circular(2),
    );
    canvas.drawRRect(entrance, fillAccent);
    canvas.drawRRect(entrance, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
