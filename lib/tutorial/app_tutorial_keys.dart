import 'package:flutter/material.dart';

/// GlobalKeys for product tour targets on the main shell / home tab.
abstract final class AppTutorialKeys {
  static final searchBar = GlobalKey();
  static final notifications = GlobalKey();
  static final cart = GlobalKey();
  static final categoryFilters = GlobalKey();
  static final navHome = GlobalKey();
  static final navBrowse = GlobalKey();
  static final navSell = GlobalKey();
  static final navMessages = GlobalKey();
  static final navProfile = GlobalKey();
}
