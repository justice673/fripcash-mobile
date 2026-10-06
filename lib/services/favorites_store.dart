import 'package:flutter/foundation.dart';
import 'package:frip_cash/models/product.dart';
import 'package:frip_cash/services/listings_repository.dart';

class FavoritesStore extends ChangeNotifier {
  FavoritesStore._();

  static final FavoritesStore instance = FavoritesStore._();

  final Set<String> _ids = {};

  bool isFavorite(String productId) => _ids.contains(productId);

  List<Product> get favorites {
    final catalog = ListingsRepository.instance.allCached;
    return [
      for (final p in catalog)
        if (_ids.contains(p.id)) p,
    ];
  }

  void toggle(String productId) {
    if (_ids.contains(productId)) {
      _ids.remove(productId);
    } else {
      _ids.add(productId);
    }
    notifyListeners();
  }

  void setFavorite(String productId, bool value) {
    if (value) {
      _ids.add(productId);
    } else {
      _ids.remove(productId);
    }
    notifyListeners();
  }
}
