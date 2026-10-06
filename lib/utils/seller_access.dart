import 'package:frip_cash/mock/mock_users.dart';
import 'package:frip_cash/models/shop_kind.dart';
import 'package:frip_cash/services/mock_session.dart';
import 'package:frip_cash/services/seller_verification_service.dart';

enum SellerProfileKind {
  particulier,
  boutiqueStandard,
  boutiqueProximite,
  boutiqueEnseigne,
}

/// Real seller profile only — no demo “fake seller” toggle.
bool get hasSellerAccess {
  return MockSession.instance.user.role.isSeller;
}

/// Seller id for dashboard / listings (always the signed-in user).
String effectiveSellerId([MockUser? user]) {
  final current = user ?? MockSession.instance.user;
  return current.sellerId;
}

SellerProfileKind sellerProfileKind([MockUser? user]) {
  final current = user ?? MockSession.instance.user;
  if (current.role == UserRole.vendeurParticulier) {
    return SellerProfileKind.particulier;
  }
  if (current.isPartnerEnseigne) {
    return SellerProfileKind.boutiqueEnseigne;
  }
  if (current.isProximityShop) {
    return SellerProfileKind.boutiqueProximite;
  }
  if (current.role == UserRole.boutique || current.hasShop) {
    return SellerProfileKind.boutiqueStandard;
  }
  return SellerProfileKind.particulier;
}

bool get isBuyerAccount {
  return MockSession.instance.user.role == UserRole.acheteur;
}

bool get isShopAccount {
  return MockSession.instance.user.role == UserRole.boutique;
}

bool isProximitySellerProfile([MockUser? user]) =>
    sellerProfileKind(user) == SellerProfileKind.boutiqueProximite;

ShopKind? shopKindForUser([MockUser? user]) {
  return (user ?? MockSession.instance.user).shopKind;
}

String buyerFirstName(String fullName) {
  final trimmed = fullName.trim();
  if (trimmed.isEmpty) return 'Client';
  return trimmed.split(RegExp(r'\s+')).first;
}

bool get canManageListings => hasSellerAccess && canPublishListings;

bool get canAccessSellerDashboard => hasSellerAccess;

/// Proximité / enseigne pending admin approval.
bool get isSellerVerificationPending {
  final me = MockSession.instance.me;
  if (me?.isVerificationPending == true) return true;
  final user = MockSession.instance.user;
  if (!user.isProximityShop && !user.isPartnerEnseigne) return false;
  return SellerVerificationService.instance.requiresManualReview(user.sellerId);
}

/// Live publish allowed only when seller exists and is not pending-blocked.
bool get canPublishListings {
  if (!hasSellerAccess) return false;
  final me = MockSession.instance.me;
  if (me != null) {
    if (me.isVerificationPending) return false;
    return me.canCreateListing;
  }
  if (isSellerVerificationPending) return false;
  return true;
}

bool get canAccessExcelImport {
  if (!hasSellerAccess) return false;
  final me = MockSession.instance.me;
  if (me != null) return me.excelImport;
  final kind = sellerProfileKind();
  return kind == SellerProfileKind.boutiqueStandard ||
      kind == SellerProfileKind.boutiqueProximite ||
      kind == SellerProfileKind.boutiqueEnseigne;
}

bool get canAccessProductLibrary {
  if (!hasSellerAccess) return false;
  final me = MockSession.instance.me;
  if (me != null) return me.productLibrary;
  return sellerProfileKind() == SellerProfileKind.boutiqueProximite;
}

/// Buyer may start “devenir vendeur”.
bool get canStartSellingAsIndividual => isBuyerAccount;

/// Particulier (or buyer) may apply to create a boutique.
bool get canCreateOrUpgradeShop {
  final user = MockSession.instance.user;
  return user.role == UserRole.acheteur ||
      user.role == UserRole.vendeurParticulier;
}

bool get canAccessSellerTools => hasSellerAccess;

bool get isIndividualSeller {
  return MockSession.instance.user.role == UserRole.vendeurParticulier;
}
