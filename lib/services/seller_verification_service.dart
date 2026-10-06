import 'package:flutter/foundation.dart';

/// Manual validation for neighborhood shops and partner enseignes (mock).
class SellerVerificationService extends ChangeNotifier {
  SellerVerificationService._();

  static final SellerVerificationService instance =
      SellerVerificationService._();

  /// Seeded partner / quartier sellers visible in directories.
  static const _seedVerified = {
    'seller_quartier',
    'seller_madina_epicerie',
    'seller_carrefour',
    'seller_tech',
    'seller_imperial',
    'seller_maison_plus',
    'seller_mode_express',
    'seller_epicerie_express',
  };

  final Set<String> _verified = {..._seedVerified};
  final Set<String> _pending = {};

  bool requiresManualReview(String sellerId) => _pending.contains(sellerId);

  bool isDirectoryVisible(String sellerId) =>
      _verified.contains(sellerId) && !_pending.contains(sellerId);

  void markPending(String sellerId) {
    if (_seedVerified.contains(sellerId)) return;
    _pending.add(sellerId);
    _verified.remove(sellerId);
    notifyListeners();
  }

  void approve(String sellerId) {
    _pending.remove(sellerId);
    _verified.add(sellerId);
    notifyListeners();
  }
}
