import 'package:flutter/foundation.dart';

class FollowStore extends ChangeNotifier {
  FollowStore._();

  static final instance = FollowStore._();

  final Set<String> _followedSellerIds = {};

  bool isFollowing(String sellerId) => _followedSellerIds.contains(sellerId);

  void toggle(String sellerId) {
    if (_followedSellerIds.contains(sellerId)) {
      _followedSellerIds.remove(sellerId);
    } else {
      _followedSellerIds.add(sellerId);
    }
    notifyListeners();
  }
}
