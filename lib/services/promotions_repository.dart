import 'package:flutter/foundation.dart';
import 'package:frip_cash/api/promotions_api.dart';
import 'package:frip_cash/models/product.dart';
import 'package:frip_cash/models/promotion.dart';
import 'package:frip_cash/services/app_locale_service.dart';
import 'package:frip_cash/services/listings_repository.dart';
import 'package:frip_cash/utils/safe_notify.dart';

/// Home featured promotions — `GET /promotions?surface=HOME_APP`.
class PromotionsRepository extends ChangeNotifier with SafeNotify {
  PromotionsRepository._() {
    AppLocaleService.instance.addListener(_onLocaleChanged);
  }

  static final PromotionsRepository instance = PromotionsRepository._();

  PromotionsFeed? _feed;
  bool _loading = false;
  String? _error;
  bool _loaded = false;
  String? _localeWhenFetched;

  List<FeaturedPromotion> get items => _feed?.items ?? const [];
  PromotionsFeed? get feed => _feed;
  bool get isLoading => _loading;
  String? get error => _error;
  bool get isLoaded => _loaded;
  bool get isEmpty => _loaded && items.isEmpty;

  DateTime get estimatedServerNow =>
      _feed?.estimatedServerNow ?? DateTime.now().toUtc();

  Duration remainingUntil(DateTime endsAt) {
    if (_feed != null) return _feed!.remainingUntil(endsAt);
    final left = endsAt.toUtc().difference(DateTime.now().toUtc());
    return left.isNegative ? Duration.zero : left;
  }

  Product? productFor(FeaturedPromotion promo) {
    final id = promo.listingId ??
        (promo.deepLinkType == FeaturedDeepLinkType.listing
            ? promo.deepLinkId
            : null);
    if (id == null || id.isEmpty) return null;
    return ListingsRepository.instance.productById(id);
  }

  Future<void> ensureLoaded({bool force = false}) async {
    final locale =
        AppLocaleService.instance.locale?.languageCode ?? 'fr';
    if (_loaded &&
        !force &&
        items.isNotEmpty &&
        _localeWhenFetched == locale) {
      return;
    }
    if (_loaded &&
        !force &&
        _localeWhenFetched == locale &&
        _error == null) {
      return;
    }
    await refresh(force: force);
  }

  Future<void> refresh({bool force = false}) async {
    if (_loading && !force) return;
    _loading = true;
    _error = null;
    safeNotifyListeners();
    try {
      final feed = await PromotionsApi.instance.fetchPublic(
        surface: 'HOME_APP',
        limit: 12,
      );
      _feed = feed;
      _loaded = true;
      _localeWhenFetched =
          AppLocaleService.instance.locale?.languageCode ?? 'fr';
    } catch (e) {
      _error = e.toString();
      if (_feed == null) _loaded = false;
    } finally {
      _loading = false;
      safeNotifyListeners();
    }
  }

  void _onLocaleChanged() {
    final locale =
        AppLocaleService.instance.locale?.languageCode ?? 'fr';
    if (_localeWhenFetched == locale) return;
    refresh(force: true);
  }
}
