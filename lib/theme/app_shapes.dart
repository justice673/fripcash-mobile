import 'package:flutter/material.dart';

abstract final class AppShapes {
  static const pillRadius = 28.0;

  static RoundedRectangleBorder get pillShape => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(pillRadius),
      );
}
