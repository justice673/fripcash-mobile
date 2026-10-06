import 'package:frip_cash/api/orders_api.dart';
import 'package:frip_cash/models/fulfillment_mode.dart';
import 'package:frip_cash/models/order_status.dart';
import 'package:frip_cash/models/product.dart';
import 'package:frip_cash/models/seller_type.dart';

/// Snapshotted order line for UI (prefer over live listing lookup).
class OrderLineSnapshot {
  const OrderLineSnapshot({
    required this.listingId,
    required this.title,
    required this.qty,
    required this.unitDisplayPriceGnf,
    this.coverUrl,
    this.unitNetPriceGnf,
    this.lineTotalDisplayGnf,
  });

  final String listingId;
  final String title;
  final int qty;
  final int unitDisplayPriceGnf;
  final String? coverUrl;
  final int? unitNetPriceGnf;
  final int? lineTotalDisplayGnf;

  int get displayLineTotalGnf =>
      lineTotalDisplayGnf ?? (unitDisplayPriceGnf * qty);

  factory OrderLineSnapshot.fromApi(ApiOrderLine line) {
    return OrderLineSnapshot(
      listingId: line.listingId,
      title: line.title,
      qty: line.qty,
      unitDisplayPriceGnf: line.unitDisplayPriceGnf,
      coverUrl: line.coverUrl,
      unitNetPriceGnf: line.unitNetPriceGnf,
      lineTotalDisplayGnf: line.lineTotalDisplayGnf,
    );
  }
}

class MockOrder {
  const MockOrder({
    required this.id,
    required this.productIds,
    required this.status,
    required this.buyerId,
    required this.buyerName,
    required this.buyerZoneId,
    required this.sellerId,
    required this.totalGnf,
    this.createdAtLabel = 'Aujourd\'hui',
    this.courierName,
    this.courierId,
    this.slaOverdue = false,
    this.buyerPhone = '+224 620 00 00 00',
    this.buyerAddress = 'Adresse non renseignée',
    this.buyerLandmark,
    this.deliveryFeeGnf = 5000,
    this.assignmentNote,
    this.pickupCode,
    this.fulfillmentMode = FulfillmentMode.courier,
    this.disputeReason,
    this.disputeOpenedAt,
    this.disputeOpenedVia,
    this.lines = const [],
    this.nextActions = const [],
    this.escrowState,
    this.sellerName,
    this.subtotalGnf,
    this.sellerNetTotalGnf,
    this.ratingStars,
  });

  final String id;
  final List<String> productIds;
  final OrderStatus status;

  /// Stable account id of the buyer — never match orders on display names.
  final String buyerId;
  final String buyerName;
  final String buyerZoneId;
  final String sellerId;
  final int totalGnf;
  final String createdAtLabel;
  final String? courierName;
  final String? courierId;
  final bool slaOverdue;
  final String buyerPhone;
  final String buyerAddress;
  final String? buyerLandmark;
  final int deliveryFeeGnf;
  final String? assignmentNote;

  /// Shared short code for neighborhood shop pickup / local delivery.
  final String? pickupCode;
  final FulfillmentMode fulfillmentMode;

  final String? disputeReason;
  final DateTime? disputeOpenedAt;
  final String? disputeOpenedVia;

  /// Server line snapshots — prefer for money / cover / title UI.
  final List<OrderLineSnapshot> lines;

  /// Server-driven CTAs (empty when mock / not provided).
  final List<OrderNextAction> nextActions;

  final EscrowState? escrowState;
  final String? sellerName;
  final int? subtotalGnf;
  final int? sellerNetTotalGnf;
  final int? ratingStars;

  bool get isProximityFulfillment => fulfillmentMode.skipsCourier;

  bool get hasServerLines => lines.isNotEmpty;

  bool hasNextAction(OrderNextAction action) => nextActions.contains(action);

  String get displayTitle {
    if (lines.isNotEmpty) {
      if (lines.length == 1) return lines.first.title;
      return '${lines.first.title} +${lines.length - 1}';
    }
    return id;
  }

  String? get displayCoverUrl =>
      lines.isNotEmpty ? lines.first.coverUrl : null;

  int get stepIndex {
    if (status.isTerminalException) return -1;
    final i = OrderStatus.timelineSteps.indexOf(status);
    return i < 0 ? 0 : i;
  }

  bool get isCourierMission =>
      !isProximityFulfillment &&
      !status.isTerminalException &&
      status.index >= OrderStatus.readyForPickup.index &&
      status.index <= OrderStatus.delivered.index;

  bool get isActiveCourierMission =>
      !isProximityFulfillment &&
      !status.isTerminalException &&
      status.index >= OrderStatus.readyForPickup.index &&
      status.index < OrderStatus.delivered.index;

  MockOrder copyWith({
    OrderStatus? status,
    String? courierName,
    String? courierId,
    bool? slaOverdue,
    String? assignmentNote,
    String? pickupCode,
    FulfillmentMode? fulfillmentMode,
    String? disputeReason,
    DateTime? disputeOpenedAt,
    String? disputeOpenedVia,
    List<OrderLineSnapshot>? lines,
    List<OrderNextAction>? nextActions,
    EscrowState? escrowState,
    String? sellerName,
    int? subtotalGnf,
    int? sellerNetTotalGnf,
    int? totalGnf,
    int? deliveryFeeGnf,
    int? ratingStars,
    bool clearRating = false,
  }) {
    return MockOrder(
      id: id,
      productIds: productIds,
      status: status ?? this.status,
      buyerId: buyerId,
      buyerName: buyerName,
      buyerZoneId: buyerZoneId,
      sellerId: sellerId,
      totalGnf: totalGnf ?? this.totalGnf,
      createdAtLabel: createdAtLabel,
      courierName: courierName ?? this.courierName,
      courierId: courierId ?? this.courierId,
      slaOverdue: slaOverdue ?? this.slaOverdue,
      buyerPhone: buyerPhone,
      buyerAddress: buyerAddress,
      buyerLandmark: buyerLandmark,
      deliveryFeeGnf: deliveryFeeGnf ?? this.deliveryFeeGnf,
      assignmentNote: assignmentNote ?? this.assignmentNote,
      pickupCode: pickupCode ?? this.pickupCode,
      fulfillmentMode: fulfillmentMode ?? this.fulfillmentMode,
      disputeReason: disputeReason ?? this.disputeReason,
      disputeOpenedAt: disputeOpenedAt ?? this.disputeOpenedAt,
      disputeOpenedVia: disputeOpenedVia ?? this.disputeOpenedVia,
      lines: lines ?? this.lines,
      nextActions: nextActions ?? this.nextActions,
      escrowState: escrowState ?? this.escrowState,
      sellerName: sellerName ?? this.sellerName,
      subtotalGnf: subtotalGnf ?? this.subtotalGnf,
      sellerNetTotalGnf: sellerNetTotalGnf ?? this.sellerNetTotalGnf,
      ratingStars: clearRating ? null : (ratingStars ?? this.ratingStars),
    );
  }

  /// Map Nest order DTO → UI model. Prefer server totals / display prices.
  factory MockOrder.fromApi(ApiOrder api) {
    final lineSnaps = api.lines.map(OrderLineSnapshot.fromApi).toList();
    final productIds = lineSnaps
        .map((l) => l.listingId)
        .where((id) => id.isNotEmpty)
        .toList();

    DateTime? disputeOpenedAt;
    final openedAt = api.dispute?.openedAt;
    if (openedAt != null) {
      disputeOpenedAt = DateTime.tryParse(openedAt);
    }

    return MockOrder(
      id: api.id,
      productIds: productIds.isNotEmpty ? productIds : const <String>[],
      status: api.status,
      buyerId: api.buyerUserId,
      buyerName: api.buyerName.isNotEmpty ? api.buyerName : 'Buyer',
      buyerZoneId: api.buyerZoneId,
      sellerId: api.sellerProfileId,
      totalGnf: api.totalGnf,
      createdAtLabel: _createdAtLabel(api.createdAt),
      courierName: api.courierName,
      courierId: api.courierId,
      slaOverdue: api.slaOverdue,
      buyerPhone: api.buyerPhone.isNotEmpty ? api.buyerPhone : '+224',
      buyerAddress: api.buyerAddressLine.isNotEmpty
          ? api.buyerAddressLine
          : 'Adresse non renseignée',
      buyerLandmark: api.buyerLandmark,
      deliveryFeeGnf: api.deliveryFeeGnf,
      pickupCode: api.pickupCode,
      fulfillmentMode: api.fulfillmentMode,
      disputeReason: api.dispute?.reason,
      disputeOpenedAt: disputeOpenedAt,
      disputeOpenedVia: api.dispute?.openedVia,
      lines: lineSnaps,
      nextActions: List.unmodifiable(api.nextActions),
      escrowState: api.escrow?.state,
      sellerName: api.sellerName,
      subtotalGnf: api.subtotalGnf,
      sellerNetTotalGnf: api.sellerNetTotalGnf,
      ratingStars: api.rating?.stars,
    );
  }
}

String _createdAtLabel(String? iso) {
  if (iso == null || iso.isEmpty) return 'Aujourd\'hui';
  final dt = DateTime.tryParse(iso)?.toLocal();
  if (dt == null) return iso;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(dt.year, dt.month, dt.day);
  if (day == today) return 'Aujourd\'hui';
  if (day == today.subtract(const Duration(days: 1))) return 'Hier';
  return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
}

const mockOrders = <MockOrder>[
  MockOrder(
    id: 'ord_1001',
    productIds: ['1'],
    status: OrderStatus.paid,
    buyerId: 'user_marine',
    buyerName: 'Marine',
    buyerZoneId: 'zone_1',
    sellerId: 'seller_aminata',
    totalGnf: 50000,
    buyerPhone: '+224 620 12 34 56',
    buyerAddress: 'Kipé, près du marché',
    buyerLandmark: 'Face à la pharmacie verte',
  ),
  MockOrder(
    id: 'ord_1002',
    productIds: ['2', '3'],
    status: OrderStatus.readyForPickup,
    buyerId: 'user_ibrahima',
    buyerName: 'Ibrahima',
    buyerZoneId: 'zone_2',
    sellerId: 'seller_ibrahim',
    totalGnf: 205000,
    createdAtLabel: 'Hier',
    slaOverdue: true,
    buyerPhone: '+224 622 33 44 55',
    buyerAddress: 'Madina, rue du marché',
    assignmentNote: 'Mission assignée (rotation automatique)',
  ),
  MockOrder(
    id: 'ord_1003',
    productIds: ['5'],
    status: OrderStatus.delivered,
    buyerId: 'user_aissatou',
    buyerName: 'Aissatou',
    buyerZoneId: 'zone_1',
    sellerId: 'seller_tech',
    totalGnf: 65000,
    createdAtLabel: '12 juin',
    courierId: 'courier_a',
    courierName: 'Mamadou K.',
    buyerPhone: '+224 621 55 66 77',
    buyerAddress: 'Lambanyi, rue 8',
    deliveryFeeGnf: 5000,
  ),
  MockOrder(
    id: 'ord_1004',
    productIds: ['1'],
    status: OrderStatus.courierAssigned,
    buyerId: 'user_fatoumata',
    buyerName: 'Fatoumata',
    buyerZoneId: 'zone_1',
    sellerId: 'seller_aminata',
    totalGnf: 45000,
    courierId: 'courier_a',
    courierName: 'Mamadou K.',
    buyerPhone: '+224 624 11 22 33',
    buyerAddress: 'Dixinn, près de l\'école',
    buyerLandmark: 'Portail bleu',
    assignmentNote: 'Mission assignée (rotation automatique)',
  ),
  MockOrder(
    id: 'ord_1005',
    productIds: ['3'],
    status: OrderStatus.inTransit,
    buyerId: 'user_moussa',
    buyerName: 'Moussa',
    buyerZoneId: 'zone_1',
    sellerId: 'seller_mariam',
    totalGnf: 120000,
    createdAtLabel: 'Aujourd\'hui',
    courierId: 'courier_a',
    courierName: 'Mamadou K.',
    buyerPhone: '+224 625 44 55 66',
    buyerAddress: 'Kaloum, avenue de la République',
    deliveryFeeGnf: 5000,
  ),
  MockOrder(
    id: 'ord_1006',
    productIds: ['p_kiperice', 'p_kipeoil'],
    status: OrderStatus.paid,
    buyerId: 'user_marine',
    buyerName: 'Marine',
    buyerZoneId: 'zone_1',
    sellerId: 'seller_quartier',
    totalGnf: 185000,
    buyerPhone: '+224 620 12 34 56',
    buyerAddress: 'Kipé, près du marché',
    deliveryFeeGnf: 0,
    pickupCode: '7429',
    fulfillmentMode: FulfillmentMode.pickup,
  ),
  /// Delivered — buyer can confirm receipt and release payment (Marine).
  MockOrder(
    id: 'ord_1007',
    productIds: ['2'],
    status: OrderStatus.delivered,
    buyerId: 'user_marine',
    buyerName: 'Marine',
    buyerZoneId: 'zone_1',
    sellerId: 'seller_ibrahim',
    totalGnf: 85000,
    createdAtLabel: 'Hier',
    courierId: 'courier_a',
    courierName: 'Mamadou K.',
    buyerPhone: '+224 620 12 34 56',
    buyerAddress: 'Kipé, près du marché',
    deliveryFeeGnf: 5000,
  ),
  /// Refunded after admin dispute resolution (Marine).
  MockOrder(
    id: 'ord_1008',
    productIds: ['5'],
    status: OrderStatus.refunded,
    buyerId: 'user_marine',
    buyerName: 'Marine',
    buyerZoneId: 'zone_1',
    sellerId: 'seller_tech',
    totalGnf: 65000,
    createdAtLabel: '12 juin',
    courierId: 'courier_a',
    courierName: 'Mamadou K.',
    buyerPhone: '+224 620 12 34 56',
    buyerAddress: 'Kipé, près du marché',
    deliveryFeeGnf: 5000,
    disputeReason: 'Item arrived damaged — admin issued full refund.',
    disputeOpenedVia: 'order_page',
  ),
];

MockOrder? orderById(String id) {
  for (final order in mockOrders) {
    if (order.id == id) return order;
  }
  return null;
}

List<Product> productsForOrder(MockOrder order, List<Product> catalog) {
  if (order.hasServerLines) {
    return [
      for (final line in order.lines)
        Product(
          id: line.listingId,
          title: line.title,
          price: line.unitDisplayPriceGnf,
          image: line.coverUrl ?? '',
          size: 'One size',
          categoryId: 'mode',
          sellerId: order.sellerId,
          sellerType: order.isProximityFulfillment
              ? SellerType.boutique
              : SellerType.particulier,
          stock: line.qty,
        ),
    ];
  }
  return catalog
      .where((product) => order.productIds.contains(product.id))
      .toList();
}

/// Prefer line snapshots (qty × display) over catalog lookup.
List<OrderLineSnapshot> displayLinesForOrder(
  MockOrder order,
  List<Product> catalog,
) {
  if (order.hasServerLines) return order.lines;
  final products = productsForOrder(order, catalog);
  return [
    for (final p in products)
      OrderLineSnapshot(
        listingId: p.id,
        title: p.title,
        qty: 1,
        unitDisplayPriceGnf: p.price,
        coverUrl: p.image,
      ),
  ];
}
