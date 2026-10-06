class MockCourier {
  const MockCourier({
    required this.id,
    required this.name,
    required this.zoneId,
    required this.phone,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String zoneId;
  final String phone;
  final bool isActive;
}

const mockCouriers = <MockCourier>[
  MockCourier(
    id: 'courier_a',
    name: 'Mamadou K.',
    zoneId: 'zone_1',
    phone: '+224 628 88 99 00',
  ),
  MockCourier(
    id: 'courier_b',
    name: 'Alpha B.',
    zoneId: 'zone_1',
    phone: '+224 629 11 22 33',
  ),
  MockCourier(
    id: 'courier_c',
    name: 'Ibrahima D.',
    zoneId: 'zone_1',
    phone: '+224 630 44 55 66',
  ),
  MockCourier(
    id: 'courier_d',
    name: 'Ousmane T.',
    zoneId: 'zone_2',
    phone: '+224 631 77 88 99',
  ),
];

MockCourier? courierById(String id) {
  for (final courier in mockCouriers) {
    if (courier.id == id) return courier;
  }
  return null;
}

List<MockCourier> couriersInZone(String zoneId, {String? excludeId}) {
  return mockCouriers
      .where((c) => c.zoneId == zoneId && c.id != excludeId)
      .toList();
}
