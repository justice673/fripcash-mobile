enum FulfillmentMode {
  /// Classic FripCash courier delivery.
  courier,

  /// Buyer picks up at the shop — shared order code.
  pickup,

  /// Shop organizes local delivery — shared order code, no courier fee.
  shopLocalDelivery,
}

extension FulfillmentModeX on FulfillmentMode {
  bool get isProximity =>
      this == FulfillmentMode.pickup ||
      this == FulfillmentMode.shopLocalDelivery;

  bool get skipsCourier => isProximity;
}
