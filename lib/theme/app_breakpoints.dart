import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Tablet / iPad / wide-web layout helpers.
abstract final class AppBreakpoints {
  static const wideWidth = 600.0;

  /// Form column width on tablet — matches common auth UIs (~420px).
  static const formMaxWidth = 420.0;

  /// Home feed / promo column on portrait tablet (Amazon/ASOS-style).
  static const homeContentMaxWidth = 840.0;

  /// Soft cap so ultra-wide web doesn't sprawl forever.
  static const homeLandscapeMaxWidth = 1200.0;

  /// True when the viewport is wide enough for tablet-style layout.
  /// Uses width (not only shortestSide) so Chrome / landscape also match.
  static bool isTablet(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return size.width >= wideWidth || size.shortestSide >= wideWidth;
  }

  static bool isLandscape(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return size.width > size.height;
  }

  /// Auth / form content max width.
  static double contentMaxWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (!isTablet(context)) return width;
    return formMaxWidth;
  }

  /// Home sections max width (header, hero, etc.).
  /// Portrait tablet stays ~840; landscape fills the canvas with gutters.
  static double homeMaxWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (!isTablet(context)) return width;
    if (isLandscape(context)) {
      return math.min(width - 48, homeLandscapeMaxWidth);
    }
    return math.min(width - 32, homeContentMaxWidth);
  }

  /// Product card grids: 2 on phone, 3 on tablet (Depop/ASOS-style).
  static int productGridCrossAxisCount(BuildContext context) {
    return isTablet(context) ? 3 : 2;
  }

  /// Browse category tiles: denser on tablet so cards don't stretch.
  static int browseCategoryCrossAxisCount(BuildContext context) {
    if (!isTablet(context)) return 2;
    return isLandscape(context) ? 4 : 3;
  }

  /// Vertical gap between product grid rows (tight — avoid tall empty gutters).
  static double productGridMainAxisSpacing(BuildContext context) => 8;

  /// Aspect ratio for photo-led product cards (width / height).
  /// Higher = shorter cells; tuned so meta sits snug under the square image.
  static double productGridChildAspectRatio(BuildContext context) {
    if (!isTablet(context)) return 0.62;
    // Wider tablet cells need a taller ratio so rows don't leave empty space
    // under the price line.
    return isLandscape(context) ? 0.72 : 0.68;
  }
}
