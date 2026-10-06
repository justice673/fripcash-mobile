import 'package:frip_cash/mock/mock_shops.dart';
import 'package:frip_cash/mock/mock_zones.dart';
import 'package:frip_cash/models/listing_destination.dart';
import 'package:frip_cash/models/product.dart';
import 'package:frip_cash/services/listings_repository.dart';

String homeQuartierFromAddress(String? address, {String fallback = 'Kipé'}) {
  if (address != null) {
    final first = address.split(',').first.trim();
    if (first.isNotEmpty) return first;
  }
  return fallback;
}

String homeLocationLabel({required String zoneId, String? address}) {
  final zone = zoneById(zoneId);
  final quartier = homeQuartierFromAddress(
    address,
    fallback: zone?.quartiers.first ?? 'Kipé',
  );
  return '${zone?.name ?? 'Zone 1'} - $quartier';
}

int totalSecondeMainCount() {
  return ListingsRepository.instance
      .cachedFor(destination: ListingDestination.secondeMain)
      .length;
}

int totalArticlesNeufsCountAll() {
  return ListingsRepository.instance
      .cachedFor(destination: ListingDestination.articlesNeufs)
      .length;
}

int quartierShopCount(String quartier) =>
    quartierShopsForNeighborhood(quartier).length;

int enseigneCountForZone(String zoneId) => enseignesForZone(zoneId).length;

List<String> homeSearchTokens(String query) {
  return query
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((token) => token.length >= 2)
      .toList(growable: false);
}

bool productMatchesHomeSearch(Product product, String query) {
  final tokens = homeSearchTokens(query);
  if (tokens.isEmpty) return true;
  final haystack = [
    product.title,
    product.brand ?? '',
    product.description ?? '',
    product.categoryId,
    product.condition,
  ].join(' ').toLowerCase();
  return tokens.every(haystack.contains);
}
