class CheckoutAddress {
  const CheckoutAddress({
    required this.name,
    required this.phone,
    required this.zoneId,
    this.quartier,
    this.manualAddress,
    this.landmark,
  });

  final String name;
  final String phone;
  /// `zone_1`, `zone_2`, or `other`.
  final String zoneId;
  final String? quartier;
  final String? manualAddress;
  final String? landmark;

  bool get isOtherZone => zoneId == 'other';

  String get zoneLabel => switch (zoneId) {
        'zone_1' => 'Zone 1',
        'zone_2' => 'Zone 2',
        'other' => 'Autre zone',
        _ => zoneId,
      };

  String get fullAddressLine {
    if (isOtherZone) {
      return [manualAddress, landmark].where((part) => part?.isNotEmpty == true).join(' · ');
    }
    return [quartier, zoneLabel].where((part) => part?.isNotEmpty == true).join(', ');
  }
}
