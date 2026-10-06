import 'package:frip_cash/api/platform_api.dart';
import 'package:frip_cash/models/shop_kind.dart';
import 'package:frip_cash/utils/price_formatter.dart';

/// Fallback defaults when platform rates not loaded.
const commissionRate = 0.08;
const proximityCommissionRate = 0.05;

double commissionRateFor({ShopKind? shopKind, bool isProximity = false}) {
  final cached = PlatformApi.instance.cached;
  if (cached != null) {
    if (isProximity || shopKind == ShopKind.proximite) {
      return cached.proximite;
    }
    return cached.effectiveForMe > 0 ? cached.effectiveForMe : cached.standard;
  }
  if (isProximity || shopKind == ShopKind.proximite) {
    return proximityCommissionRate;
  }
  return commissionRate;
}

/// Prefer [PlatformApi] effective rate for the signed-in seller.
double effectiveCommissionRate({
  ShopKind? shopKind,
  bool isProximity = false,
}) {
  final cached = PlatformApi.instance.cached;
  if (cached != null) return cached.effectiveForMe;
  return commissionRateFor(shopKind: shopKind, isProximity: isProximity);
}

int displayPriceFromNet(
  int netPrice, {
  ShopKind? shopKind,
  bool isProximity = false,
  double? rateOverride,
}) {
  final rate = rateOverride ??
      effectiveCommissionRate(shopKind: shopKind, isProximity: isProximity);
  return (netPrice * (1 + rate)).round();
}

int commissionAmountFromNet(
  int netPrice, {
  ShopKind? shopKind,
  bool isProximity = false,
  double? rateOverride,
}) {
  return displayPriceFromNet(
        netPrice,
        shopKind: shopKind,
        isProximity: isProximity,
        rateOverride: rateOverride,
      ) -
      netPrice;
}

int netPriceFromDisplay(
  int displayPrice, {
  ShopKind? shopKind,
  bool isProximity = false,
  double? rateOverride,
}) {
  final rate = rateOverride ??
      effectiveCommissionRate(shopKind: shopKind, isProximity: isProximity);
  return (displayPrice / (1 + rate)).round();
}

String sellerPayoutMessage(int netPrice) =>
    'Vous recevrez ${formatPrice(netPrice)} GNF. '
    'Les frais de service sont automatiquement ajoutés.';
