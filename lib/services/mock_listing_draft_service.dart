import 'package:flutter/foundation.dart';

/// Snapshot of an unfinished sell form.
class ListingDraft {
  ListingDraft({
    required this.id,
    required this.updatedAt,
    this.title = '',
    this.description = '',
    this.photos = const [],
    this.categoryId,
    this.subcategoryId,
    this.categoryPathLabel,
    this.brand,
    this.condition,
    this.size,
    this.colors = const [],
    this.netPrice,
    this.shippingCost,
    this.stock = 1,
    this.worldwideShipping = false,
  });

  final String id;
  DateTime updatedAt;
  String title;
  String description;
  List<String> photos;
  String? categoryId;
  String? subcategoryId;
  String? categoryPathLabel;
  String? brand;
  String? condition;
  String? size;
  List<String> colors;
  int? netPrice;
  int? shippingCost;
  int stock;
  bool worldwideShipping;

  /// Enough to post: photo, description, category, condition, price.
  bool get isReadyToPost {
    return photos.isNotEmpty &&
        description.trim().isNotEmpty &&
        categoryId != null &&
        condition != null &&
        netPrice != null &&
        netPrice! > 0;
  }

  String get displayTitle {
    final t = title.trim();
    if (t.isNotEmpty) return t;
    final d = description.trim();
    if (d.isEmpty) return 'Untitled draft';
    final line = d.split('\n').first.trim();
    if (line.length <= 40) return line;
    return '${line.substring(0, 37)}…';
  }
}

class MockListingDraftService extends ChangeNotifier {
  MockListingDraftService._();
  static final MockListingDraftService instance = MockListingDraftService._();

  final List<ListingDraft> _drafts = [];

  List<ListingDraft> get all => List.unmodifiable(_drafts);

  List<ListingDraft> get readyToPost =>
      _drafts.where((d) => d.isReadyToPost).toList();

  List<ListingDraft> get incomplete =>
      _drafts.where((d) => !d.isReadyToPost).toList();

  ListingDraft save(ListingDraft draft) {
    final i = _drafts.indexWhere((d) => d.id == draft.id);
    draft.updatedAt = DateTime.now();
    if (i >= 0) {
      _drafts[i] = draft;
    } else {
      _drafts.insert(0, draft);
    }
    notifyListeners();
    return draft;
  }

  void remove(String id) {
    _drafts.removeWhere((d) => d.id == id);
    notifyListeners();
  }

  ListingDraft? byId(String id) {
    for (final d in _drafts) {
      if (d.id == id) return d;
    }
    return null;
  }
}
