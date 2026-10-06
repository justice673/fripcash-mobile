const _defaultFee = 5000;

const _zoneMatrix = <String, int>{
  'zone_1_zone_1': 5000,
  'zone_2_zone_2': 5000,
  'zone_1_zone_2': 8000,
  'zone_2_zone_1': 8000,
};

/// Mock delivery fee from seller zone to buyer zone (GNF).
int shippingFeeForZones({
  required String sellerZoneId,
  required String buyerZoneId,
}) {
  if (sellerZoneId == 'other' || buyerZoneId == 'other') {
    return 12000;
  }
  return _zoneMatrix['${sellerZoneId}_$buyerZoneId'] ?? _defaultFee;
}
