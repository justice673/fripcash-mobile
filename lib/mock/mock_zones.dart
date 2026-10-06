class DeliveryZone {
  const DeliveryZone({
    required this.id,
    required this.name,
    required this.quartiers,
  });

  final String id;
  final String name;
  final List<String> quartiers;
}

const otherZoneOption = 'Autre zone';

const mockZones = <DeliveryZone>[
  DeliveryZone(
    id: 'zone_1',
    name: 'Zone 1',
    quartiers: ['Kipé', 'Lambanyi', 'Dixinn', 'Kaloum'],
  ),
  DeliveryZone(
    id: 'zone_2',
    name: 'Zone 2',
    quartiers: ['Madina', 'Matoto', 'Ratoma', 'Sonfonia'],
  ),
];

DeliveryZone? zoneById(String id) {
  for (final zone in mockZones) {
    if (zone.id == id) return zone;
  }
  return null;
}
