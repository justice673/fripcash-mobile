import 'package:frip_cash/mock/mock_users.dart';
import 'package:frip_cash/models/listing_destination.dart';
import 'package:frip_cash/models/product.dart';
import 'package:frip_cash/models/seller_type.dart';
import 'package:frip_cash/models/shop_kind.dart';
import 'package:frip_cash/services/mock_session.dart';

/// Maps a seller role choice (signup or buyer upgrade) → home section.
ListingDestination listingDestinationForSignUpRole(SignUpRole role) {
  return switch (role) {
    SignUpRole.particulier => ListingDestination.secondeMain,
    SignUpRole.boutique => ListingDestination.articlesNeufs,
    SignUpRole.commerceLocal => ListingDestination.quartierBoutiques,
    SignUpRole.grandeSurface => ListingDestination.enseignes,
    SignUpRole.acheteur => ListingDestination.secondeMain,
  };
}

/// Maps registration / seller profile → home section (spec: « où atterrissent les articles »).
ListingDestination listingDestinationForUser(MockUser user) {
  return switch (user.role) {
    UserRole.vendeurParticulier => ListingDestination.secondeMain,
    UserRole.boutique => switch (user.shopKind) {
        ShopKind.proximite => ListingDestination.quartierBoutiques,
        ShopKind.enseigne => ListingDestination.enseignes,
        ShopKind.standard || null => ListingDestination.articlesNeufs,
      },
    _ => ListingDestination.secondeMain,
  };
}

ListingDestination listingDestinationForProduct(Product product) {
  if (product.destination != null) return product.destination!;
  if (product.isNeighborhoodShop) return ListingDestination.quartierBoutiques;
  return switch (product.sellerType) {
    SellerType.particulier => ListingDestination.secondeMain,
    SellerType.enseigne => ListingDestination.enseignes,
    SellerType.boutique => _isNewItem(product)
        ? ListingDestination.articlesNeufs
        : ListingDestination.secondeMain,
  };
}

SellerType sellerTypeForDestination(ListingDestination destination) {
  return switch (destination) {
    ListingDestination.secondeMain => SellerType.particulier,
    ListingDestination.articlesNeufs => SellerType.boutique,
    ListingDestination.quartierBoutiques => SellerType.boutique,
    ListingDestination.enseignes => SellerType.enseigne,
  };
}

bool isProximityListing(ListingDestination destination) =>
    destination == ListingDestination.quartierBoutiques;

/// Articles neufs require new-item condition labelling.
String normalizeConditionForDestination({
  required ListingDestination destination,
  required String condition,
}) {
  if (destination == ListingDestination.articlesNeufs ||
      destination == ListingDestination.enseignes ||
      destination == ListingDestination.quartierBoutiques) {
    final lower = condition.toLowerCase();
    if (lower.contains('neuf')) return condition;
    return 'Neuf';
  }
  return condition;
}

bool _isNewItem(Product product) {
  final condition = product.condition.toLowerCase();
  return condition.contains('neuf') || product.categoryId != 'secondhand';
}
