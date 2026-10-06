import 'package:frip_cash/models/listing_catalog.dart';

/// Maps Nest catalog slugs → local size/color taxonomy (`listing_catalog`).
String taxonomyRootIdForCatalogSlug(String slug) {
  final s = slug.toLowerCase();
  if (s.startsWith('fashion')) return 'mode';
  if (s.startsWith('electronics')) return 'electronics';
  if (s.startsWith('home')) return 'home';
  if (s.startsWith('grocery')) return 'grocery';
  if (s.startsWith('sports') || s.startsWith('leisure')) return 'secondhand';
  if (s.startsWith('beauty')) return 'beauty';
  if (s.startsWith('baby')) return 'baby';
  if (s.startsWith('shoe')) return 'shoes';
  return s;
}

/// Maps child slug → taxonomy sub id for size schema lookup.
String? taxonomySubIdForCatalogSlug(String slug) {
  final s = slug.toLowerCase();
  if (s.contains('women')) return 'women';
  if (s.contains('kids') || s.contains('child')) return 'kids';
  if (s.contains('men')) return 'men';
  if (s.contains('accessor')) return 'accessories';
  if (s.contains('phone')) return 'phones';
  if (s.contains('tv')) return 'tvs';
  if (s.contains('computer')) return 'computers';
  if (s.contains('appliance')) return 'appliances';
  if (s.contains('furniture')) return 'furniture';
  if (s.contains('decor')) return 'decor';
  if (s.contains('kitchen')) return 'kitchen';
  if (s.contains('other')) return 'other';
  return null;
}

ListingCategoryNode? listingTaxonomyForCatalogSlug(String rootSlug) {
  return listingCategoryById(taxonomyRootIdForCatalogSlug(rootSlug));
}
