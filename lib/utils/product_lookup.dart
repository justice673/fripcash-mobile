import 'package:frip_cash/models/product.dart';
import 'package:frip_cash/services/listings_repository.dart';

Product? productById(String id) =>
    ListingsRepository.instance.productById(id);

int get catalogMinPrice {
  final products = ListingsRepository.instance.allCached;
  if (products.isEmpty) return 0;
  return products.map((p) => p.price).reduce((a, b) => a < b ? a : b);
}

int get catalogMaxPrice {
  final products = ListingsRepository.instance.allCached;
  if (products.isEmpty) return 100000;
  return products.map((p) => p.price).reduce((a, b) => a > b ? a : b);
}

List<Product> productsForSeller(String sellerId, {int? limit}) {
  final list = ListingsRepository.instance.allCached
      .where((p) => p.sellerId == sellerId)
      .toList();
  if (limit == null || list.length <= limit) return list;
  return list.take(limit).toList();
}

/// Max items shown in home showcase / section carousels.
const homeSectionProductLimit = 8;
