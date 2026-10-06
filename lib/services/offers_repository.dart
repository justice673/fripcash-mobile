import 'package:flutter/foundation.dart';
import 'package:frip_cash/api/api_client.dart';
import 'package:frip_cash/api/offers_api.dart';
import 'package:frip_cash/models/offer.dart';
import 'package:frip_cash/models/product.dart';

/// Live Nest offers — replaces in-memory OffersStore.
class OffersRepository extends ChangeNotifier {
  OffersRepository._();

  static final OffersRepository instance = OffersRepository._();

  final _api = OffersApi.instance;

  List<ProductOffer> _mine = [];
  List<ProductOffer> _sellerPending = [];
  List<ProductOffer> _sellerAccepted = [];
  int _sellerPendingCount = 0;
  bool loadingMine = false;
  bool loadingSeller = false;
  String? error;

  List<ProductOffer> get offers => List.unmodifiable(_mine);
  List<ProductOffer> get pendingOffers =>
      _mine.where((o) => o.status == OfferStatus.pending).toList();
  int get sellerPendingCount => _sellerPendingCount;

  List<ProductOffer> pendingOffersForSeller(String sellerId) =>
      List.unmodifiable(_sellerPending);

  List<ProductOffer> acceptedOffersForSeller(String sellerId) =>
      List.unmodifiable(_sellerAccepted);

  ProductOffer? acceptedOfferFor(String productId) {
    for (final offer in _mine) {
      if (offer.productId == productId &&
          offer.status == OfferStatus.accepted &&
          offer.checkoutToken != null &&
          offer.checkoutToken!.isNotEmpty) {
        return offer;
      }
    }
    return null;
  }

  int? acceptedPriceFor(String productId) =>
      acceptedOfferFor(productId)?.offeredPrice;

  Future<void> refreshMine() async {
    loadingMine = true;
    error = null;
    notifyListeners();
    try {
      final page = await _api.listMine(status: 'ALL');
      _mine = page.items;
      loadingMine = false;
      notifyListeners();
    } on ApiException catch (e) {
      loadingMine = false;
      error = e.message;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> refreshSeller() async {
    loadingSeller = true;
    error = null;
    notifyListeners();
    try {
      final pending = await _api.listSeller(status: 'PENDING');
      final accepted = await _api.listSeller(status: 'ACCEPTED');
      _sellerPending = pending.items;
      _sellerAccepted = accepted.items;
      _sellerPendingCount = pending.pendingCount ?? pending.items.length;
      loadingSeller = false;
      notifyListeners();
    } on ApiException catch (e) {
      loadingSeller = false;
      error = e.message;
      notifyListeners();
      rethrow;
    }
  }

  Future<ProductOffer> submitOffer({
    required Product product,
    required int offeredPrice,
    String? sellerName,
  }) async {
    final offer = await _api.create(
      listingId: product.id,
      offeredPriceGnf: offeredPrice,
    );
    _mine = [offer, ..._mine.where((o) => o.id != offer.id)];
    notifyListeners();
    return offer;
  }

  Future<void> acceptOffer(String offerId) async {
    final updated = await _api.accept(offerId);
    _sellerPending.removeWhere((o) => o.id == offerId);
    _sellerAccepted = [
      updated,
      ..._sellerAccepted.where((o) => o.id != offerId),
    ];
    _sellerPendingCount = _sellerPending.length;
    notifyListeners();
  }

  Future<void> refuseOffer(String offerId) async {
    await _api.refuse(offerId);
    _sellerPending.removeWhere((o) => o.id == offerId);
    _sellerPendingCount = _sellerPending.length;
    notifyListeners();
  }

  Future<void> cancelOffer(String offerId) async {
    final updated = await _api.cancel(offerId);
    _mine = [
      for (final o in _mine)
        if (o.id == offerId) updated else o,
    ];
    notifyListeners();
  }
}

/// @Deprecated — use [OffersRepository.instance]
typedef OffersStore = OffersRepository;
