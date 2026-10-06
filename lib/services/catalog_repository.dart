import 'package:flutter/foundation.dart';
import 'package:frip_cash/api/catalog_api.dart';
import 'package:frip_cash/models/catalog_category.dart';
import 'package:frip_cash/models/product.dart';
import 'package:frip_cash/services/listings_repository.dart';
import 'package:frip_cash/utils/safe_notify.dart';

/// Nest catalog: categories + best-sellers carousel.
class CatalogRepository extends ChangeNotifier with SafeNotify {
  CatalogRepository._();

  static final CatalogRepository instance = CatalogRepository._();

  List<Product> _bestSellers = const [];
  List<CatalogCategory> _categories = const [];
  bool _loading = false;
  bool _categoriesLoading = false;
  String? _error;
  String? _categoriesError;
  bool _loaded = false;
  bool _categoriesLoaded = false;

  List<Product> get bestSellers => _bestSellers;
  List<CatalogCategory> get categories => _categories;
  List<CatalogCategory> get rootCategories {
    final roots = _categories.where((c) => c.isRoot).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return roots;
  }

  bool get isLoading => _loading;
  bool get isCategoriesLoading => _categoriesLoading;
  String? get error => _error ?? _categoriesError;
  bool get isLoaded => _loaded;
  bool get isCategoriesLoaded => _categoriesLoaded;

  List<CatalogCategory> childrenOf(String parentId) {
    final kids = _categories.where((c) => c.parentId == parentId).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return kids;
  }

  /// Category id itself + direct children (for parent browse filters).
  Set<String> filterIdsFor(String categoryId) {
    final ids = <String>{categoryId};
    for (final child in childrenOf(categoryId)) {
      ids.add(child.id);
    }
    return ids;
  }

  CatalogCategory? byId(String id) {
    for (final c in _categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  Future<void> ensureLoaded({bool force = false}) async {
    await Future.wait([
      if (!_loaded || force) refresh(),
      if (!_categoriesLoaded || force) refreshCategories(),
    ]);
  }

  Future<void> refreshCategories({bool force = false}) async {
    if (_categoriesLoaded && !force && _categories.isNotEmpty) return;
    _categoriesLoading = true;
    _categoriesError = null;
    safeNotifyListeners();
    try {
      final rows = await CatalogApi.instance.fetchCategories();
      rows.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      _categories = List.unmodifiable(rows);
      _categoriesLoaded = true;
    } catch (e) {
      _categoriesError = e.toString();
      if (_categories.isEmpty) _categoriesLoaded = false;
    } finally {
      _categoriesLoading = false;
      safeNotifyListeners();
    }
  }

  Future<void> refresh() async {
    _loading = true;
    _error = null;
    safeNotifyListeners();
    try {
      var products = ListingsRepository.instance.allCached;
      if (products.isEmpty) {
        products = await ListingsRepository.instance.fetch();
      }
      final listingsError = ListingsRepository.instance.error;
      if (products.isEmpty && listingsError != null) {
        _error = listingsError;
        _bestSellers = const [];
        _loaded = false;
        return;
      }
      final ranked = List<Product>.of(products)
        ..sort((a, b) => b.likes.compareTo(a.likes));
      _bestSellers = ranked.take(8).toList(growable: false);
      _loaded = true;
    } catch (e) {
      _error = e.toString();
      _bestSellers = const [];
      _loaded = false;
    } finally {
      _loading = false;
      safeNotifyListeners();
    }
  }
}
