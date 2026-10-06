import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/mock/mock_users.dart';
import 'package:frip_cash/models/listing_catalog.dart';
import 'package:frip_cash/models/product.dart';
import 'package:frip_cash/models/seller_type.dart';
import 'package:frip_cash/screens/copy_listing_screen.dart';
import 'package:frip_cash/screens/drafts_screen.dart';
import 'package:frip_cash/screens/listing_publish_success_screen.dart';
import 'package:frip_cash/screens/become_seller_screen.dart';
import 'package:frip_cash/screens/photo_tips_screen.dart';
import 'package:frip_cash/api/api_client.dart';
import 'package:frip_cash/api/listings_api.dart';
import 'package:frip_cash/api/media_api.dart';
import 'package:frip_cash/api/platform_api.dart';
import 'package:frip_cash/services/listings_repository.dart';
import 'package:frip_cash/services/mock_listing_draft_service.dart';
import 'package:frip_cash/services/mock_session.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/utils/commission_calculator.dart';
import 'package:frip_cash/utils/price_formatter.dart';
import 'package:frip_cash/utils/seller_access.dart';
import 'package:frip_cash/widgets/add_photos_sheet.dart';
import 'package:frip_cash/widgets/condition_sheet.dart';
import 'package:frip_cash/widgets/product_card.dart';
import 'package:frip_cash/widgets/safe_network_image.dart';
import 'package:frip_cash/models/catalog_category.dart';
import 'package:frip_cash/services/catalog_repository.dart';
import 'package:frip_cash/utils/sell_category_taxonomy.dart';
import 'package:frip_cash/widgets/sell_category_sheet.dart';
import 'package:frip_cash/widgets/sell_category_step.dart';
import 'package:frip_cash/widgets/sell_listing_stepper.dart';
import 'package:frip_cash/theme/app_typography.dart';
import 'package:image_picker/image_picker.dart';

String sellColorLabel(String color, AppLocalizations t) {
  return switch (color.toLowerCase()) {
    'white' => t.colorWhite,
    'black' => t.colorBlack,
    'brown' => t.colorBrown,
    'grey' => t.colorGrey,
    'beige' => t.colorBeige,
    'pink' => t.colorPink,
    'purple' => t.colorPurple,
    'red' => t.colorRed,
    'yellow' => t.colorYellow,
    'blue' => t.colorBlue,
    'green' => t.colorGreen,
    'orange' => t.colorOrange,
    _ => color,
  };
}

/// Sell-form palette — FripCash light + green accents.
abstract final class _SellColors {
  static const bg = AppColors.background;
  static const border = AppColors.border;
  static const muted = AppColors.textSecondary;
  static const divider = Color(0xFFEDE0D8);
  static const chip = AppColors.rosePoudre;
  static const fieldFill = Color(0xFFF7EDE7);
}

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key, this.product, this.draft});

  /// When set, the screen works in edit mode.
  final Product? product;

  /// Resume an unfinished draft.
  final ListingDraft? draft;

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _titleController = TextEditingController();
  final _netPriceController = TextEditingController();
  final _compareAtPriceController = TextEditingController();
  final _stockController = TextEditingController(text: '1');
  final _colorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _sizeController = TextEditingController();
  final _brandController = TextEditingController();
  final _shippingController = TextEditingController(text: '5000');

  final List<String> _photos = [];
  String? _categoryId;
  String? _subcategoryId;
  String? _categoryPathLabel;
  String? _condition;
  String? _conditionId;
  String? _draftId;
  final List<String> _selectedColors = [];
  bool _discountEnabled = false;
  bool _negotiable = false;
  bool _worldwideShipping = false;
  bool _showPhotoError = false;

  /// Wizard: 0 category → 1 photos → 2 details → 3 price.
  int _step = 0;

  static const _maxPhotos = 8;
  static const _maxDescription = 1000;

  static const _brands = [
    '2(x)ist',
    '21 Men',
    'Adidas',
    'Apple',
    'Bershka',
    'Calvin Klein',
    'Chanel',
    'Cos',
    'Diesel',
    'Gap',
    'Gucci',
    'H&M',
    'Huawei',
    'Levi\'s',
    'LG',
    'Mango',
    'New Look',
    'Next',
    'Nike',
    'Primark',
    'Puma',
    'Pull&Bear',
    'Samsung',
    'Shein',
    'Sony',
    'Uniqlo',
    'Zara',
  ];

  static const _allColors = [
    'White',
    'Black',
    'Brown',
    'Grey',
    'Beige',
    'Pink',
    'Purple',
    'Red',
    'Yellow',
    'Blue',
    'Green',
    'Orange',
  ];

  static const _placeholderPhotos = [
    'https://images.unsplash.com/photo-1445205170230-053b83016050?w=600&h=600&fit=crop',
    'https://images.unsplash.com/photo-1489987707025-afc232f7ea0f?w=600&h=600&fit=crop',
    'https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=600&h=600&fit=crop',
    'https://images.unsplash.com/photo-1469334031218-e382a71b716b?w=600&h=600&fit=crop',
  ];

  bool get _isEdit => widget.product != null;

  CatalogCategory? get _selectedRootCategory =>
      _categoryId == null ? null : CatalogRepository.instance.byId(_categoryId!);

  CatalogCategory? get _selectedSubCategory => _subcategoryId == null
      ? null
      : CatalogRepository.instance.byId(_subcategoryId!);

  /// All Nest root categories — destination is still server-owned on publish.
  List<CatalogCategory> get _sellRoots =>
      CatalogRepository.instance.rootCategories;

  List<CatalogCategory> get _sellSubcategories => _categoryId == null
      ? const []
      : CatalogRepository.instance.childrenOf(_categoryId!);

  ListingCategoryNode? get _categoryNode {
    final root = _selectedRootCategory;
    if (root == null) return null;
    return listingTaxonomyForCatalogSlug(root.slug);
  }

  String? get _taxonomySubId {
    final sub = _selectedSubCategory;
    if (sub == null) return null;
    return taxonomySubIdForCatalogSlug(sub.slug);
  }

  ListingSizeSchema get _sizeSchema =>
      _categoryNode?.sizeSchemaFor(_taxonomySubId) ?? ListingSizeSchema.none;

  bool get _needsSubcategory => _sellSubcategories.isNotEmpty;

  bool get _needsSize => _sizeSchema != ListingSizeSchema.none;

  bool get _needsColors {
    final root = _selectedRootCategory;
    if (root == null) return true;
    final tax = taxonomyRootIdForCatalogSlug(root.slug);
    return tax != 'grocery' && tax != 'electronics';
  }

  int? get _netPrice => int.tryParse(_netPriceController.text.trim());

  int? get _compareAtPrice =>
      int.tryParse(_compareAtPriceController.text.trim());

  String get _resolvedTitle {
    final titled = _titleController.text.trim();
    if (titled.isNotEmpty) return titled;
    final desc = _descriptionController.text.trim();
    if (desc.isEmpty) return '';
    final firstLine = desc.split('\n').first.trim();
    if (firstLine.length <= 60) return firstLine;
    return '${firstLine.substring(0, 57)}…';
  }

  int get _hashtagCount {
    final matches =
        RegExp(r'#\w+').allMatches(_descriptionController.text);
    return matches.length;
  }

  bool get _canSubmit {
    if (_titleController.text.trim().length < 3) return false;
    if (_resolvedTitle.isEmpty) return false;
    if (_netPrice == null || _netPrice! < 1) return false;
    if (!_discountValid) return false;
    if (int.tryParse(_stockController.text.trim()) == null) {
      return false;
    }
    if (_descriptionController.text.trim().isEmpty) return false;
    if (_categoryId == null) return false;
    if (_condition == null) return false;
    if (_photos.isEmpty) return false;
    return true;
  }

  bool get _canContinueFromCategory {
    if (_categoryId == null) return false;
    if (_needsSubcategory && _subcategoryId == null) return false;
    return true;
  }

  bool get _canContinueFromPhotos => _photos.isNotEmpty;

  bool get _canContinueFromDetails =>
      _titleController.text.trim().length >= 3 &&
      _descriptionController.text.trim().isNotEmpty &&
      _condition != null;

  bool get _discountValid {
    if (!_discountEnabled) return true;
    final compare = _compareAtPrice;
    final net = _netPrice;
    if (compare == null || net == null || net < 1) return false;
    final display = displayPriceFromNet(
      net,
      isProximity: MockSession.instance.user.isProximityShop,
    );
    return compare > display;
  }

  void _goBack() {
    if (_step <= 0) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _step -= 1);
  }

  void _goNext() {
    if (_step >= 3) return;
    if (_step == 0 && !_canContinueFromCategory) return;
    if (_step == 1) {
      if (!_canContinueFromPhotos) {
        setState(() => _showPhotoError = true);
        return;
      }
      setState(() => _showPhotoError = false);
    }
    if (_step == 2 && !_canContinueFromDetails) return;
    setState(() => _step += 1);
  }

  void _onRootCategorySelected(CatalogCategory root) {
    final locale = Localizations.localeOf(context).languageCode;
    setState(() {
      _categoryId = root.id;
      _subcategoryId = null;
      _categoryPathLabel = root.labelForLocale(locale);
      _sizeController.clear();
    });
  }

  void _onSubCategorySelected(CatalogCategory sub) {
    final locale = Localizations.localeOf(context).languageCode;
    final root = _selectedRootCategory;
    setState(() {
      _subcategoryId = sub.id;
      final rootLabel = root?.labelForLocale(locale) ?? '';
      _categoryPathLabel = '$rootLabel · ${sub.labelForLocale(locale)}';
      _sizeController.clear();
    });
  }

  void _syncCategoryPathLabel() {
    if (_categoryId == null) return;
    final locale = Localizations.localeOf(context).languageCode;
    final root = CatalogRepository.instance.byId(_categoryId!);
    if (root == null) return;
    if (_subcategoryId != null) {
      final sub = CatalogRepository.instance.byId(_subcategoryId!);
      if (sub != null) {
        _categoryPathLabel =
            '${root.labelForLocale(locale)} · ${sub.labelForLocale(locale)}';
        return;
      }
    }
    _categoryPathLabel = root.labelForLocale(locale);
  }

  Future<void> _loadSellCategories() async {
    await CatalogRepository.instance.refreshCategories(force: true);
    if (!mounted) return;
    setState(_syncCategoryPathLabel);
  }

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    final draft = widget.draft;
    if (product != null) {
      _titleController.text = product.title;
      _netPriceController.text = '${product.sellerNetPrice}';
      _stockController.text = '${product.stock}';
      _descriptionController.text = product.description ?? '';
      _sizeController.text = product.size;
      _brandController.text = product.brand ?? '';
      _categoryId = product.categoryId;
      _categoryPathLabel = product.categoryId;
      _condition = product.condition;
      _conditionId = _conditionIdFromValue(product.condition);
      _negotiable = product.negotiable;
      _shippingController.text = '${product.shippingCost}';
      if (product.compareAtPrice != null) {
        _discountEnabled = true;
        _compareAtPriceController.text = '${product.compareAtPrice}';
      }
      _photos.addAll(product.images ?? [product.image]);
      final colorMatch = RegExp(r'(?:Couleur|Color):\s*(.+)$', multiLine: true)
          .firstMatch(product.description ?? '');
      if (colorMatch != null) {
        _colorController.text = colorMatch.group(1)!.trim();
        _selectedColors
          ..clear()
          ..addAll(
            _colorController.text
                .split(',')
                .map((v) => v.trim())
                .where((v) => v.isNotEmpty),
          );
      }
    } else if (draft != null) {
      _draftId = draft.id;
      _titleController.text = draft.title;
      _descriptionController.text = draft.description;
      _photos.addAll(draft.photos);
      _categoryId = draft.categoryId;
      _subcategoryId = draft.subcategoryId;
      _categoryPathLabel = draft.categoryPathLabel;
      _brandController.text = draft.brand ?? '';
      _condition = draft.condition;
      _conditionId = _conditionIdFromValue(draft.condition);
      _sizeController.text = draft.size ?? '';
      _selectedColors
        ..clear()
        ..addAll(draft.colors);
      _colorController.text = draft.colors.join(', ');
      if (draft.netPrice != null) {
        _netPriceController.text = '${draft.netPrice}';
      }
      if (draft.shippingCost != null) {
        _shippingController.text = '${draft.shippingCost}';
      }
      _stockController.text = '${draft.stock}';
      _worldwideShipping = draft.worldwideShipping;
    } else if (MockSession.instance.user.isProximityShop) {
      _shippingController.text = '0';
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSellCategories());

    for (final c in [
      _titleController,
      _netPriceController,
      _compareAtPriceController,
      _stockController,
      _colorController,
      _descriptionController,
      _sizeController,
      _brandController,
      _shippingController,
    ]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _netPriceController.dispose();
    _compareAtPriceController.dispose();
    _stockController.dispose();
    _colorController.dispose();
    _descriptionController.dispose();
    _sizeController.dispose();
    _brandController.dispose();
    _shippingController.dispose();
    super.dispose();
  }

  Future<String?> _dataUrlFromXFile(XFile file) async {
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) return null;
    final mime = file.mimeType ?? 'image/jpeg';
    return 'data:$mime;base64,${base64Encode(bytes)}';
  }

  Future<void> _addPhoto() async {
    final t = AppLocalizations.of(context)!;
    if (_photos.length >= _maxPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.maxPhotosReached),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final remaining = _maxPhotos - _photos.length;
    final picked = await showAddPhotosSheet(context, maxPhotos: remaining);
    if (picked == null || picked.isEmpty || !mounted) return;

    final sources = <String>[];
    for (final file in picked.take(remaining)) {
      final source = await _dataUrlFromXFile(file);
      if (source != null) sources.add(source);
    }
    if (sources.isEmpty || !mounted) return;

    setState(() {
      _photos.addAll(sources);
      _showPhotoError = false;
    });
  }

  void _removePhoto(int index) {
    setState(() {
      _photos.removeAt(index);
      if (_photos.isEmpty) _showPhotoError = true;
    });
  }

  Future<void> _selectCategory() async {
    final selected = await showSellCategorySheet(context);
    if (selected == null) return;
    setState(() {
      _categoryId = selected.listingCategoryId;
      _subcategoryId = selected.listingSubcategoryId;
      _categoryPathLabel = selected.displayLabel;
      _sizeController.clear();
      if (!_needsColors) {
        _selectedColors.clear();
        _colorController.clear();
      }
    });
  }

  Future<void> _selectBrand() async {
    final selected = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => _BrandPickerScreen(
          suggestedBrands: _brands,
          selectedBrand: _brandController.text.trim().isEmpty
              ? null
              : _brandController.text.trim(),
        ),
      ),
    );
    if (selected == null) return;
    setState(() => _brandController.text = selected);
  }

  Future<void> _selectCondition() async {
    final selectedId = await showConditionSheet(
      context,
      selectedId: _conditionId,
    );
    if (selectedId == null) return;
    setState(() {
      _conditionId = selectedId;
      _condition = _conditionValueFromId(selectedId);
    });
  }

  Future<void> _selectSize() async {
    final t = AppLocalizations.of(context)!;
    if (!_needsSize) return;
    if (_needsSubcategory && _subcategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.selectSubcategoryFirst),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final options = sizeOptionsForSchema(_sizeSchema, t);
    final selected = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => _SingleChoicePickerScreen(
          title: sizeFieldLabel(_sizeSchema, t),
          options: options,
          selected: _sizeController.text.trim().isEmpty
              ? null
              : _sizeController.text.trim(),
        ),
      ),
    );
    if (selected == null) return;
    setState(() => _sizeController.text = selected);
  }

  Future<void> _selectColors() async {
    final selected = await Navigator.of(context).push<List<String>>(
      MaterialPageRoute(
        builder: (_) => _ColorPickerScreen(
          selectedColors: _selectedColors,
          allColors: _allColors,
        ),
      ),
    );
    if (selected == null) return;
    setState(() {
      _selectedColors
        ..clear()
        ..addAll(selected);
      _colorController.text = _selectedColors.join(', ');
    });
  }

  Product _buildDraftProduct() {
    final t = AppLocalizations.of(context)!;
    final user = MockSession.instance.user;
    final net = _netPrice ?? 0;
    final display = displayPriceFromNet(net, isProximity: user.isProximityShop);
    final baseDescription = _descriptionController.text.trim();
    final details = <String>[];
    if (_subcategoryId != null) {
      final locale = Localizations.localeOf(context).languageCode;
      final sub = CatalogRepository.instance.byId(_subcategoryId!);
      details.add(
        '${t.subcategoryLabel}: ${sub?.labelForLocale(locale) ?? _subcategoryId!}',
      );
    }
    if (_needsColors && _colorController.text.trim().isNotEmpty) {
      details.add('${t.colours}: ${_colorController.text.trim()}');
    }
    final description = [
      baseDescription,
      if (details.isNotEmpty) details.join('\n'),
    ].where((line) => line.isNotEmpty).join('\n\n');

    return Product(
      id: widget.product?.id ?? 'preview',
      title: _resolvedTitle,
      price: display,
      netPrice: net,
      image: _photos.first,
      images: List<String>.from(_photos),
      size: _sizeController.text.trim().isEmpty
          ? t.oneSize
          : _sizeController.text.trim(),
      categoryId: _categoryId!,
      sellerId: user.sellerId,
      sellerType: user.sellerType ?? SellerType.particulier,
      stock: int.parse(_stockController.text.trim()),
      brand: _brandController.text.trim().isEmpty
          ? null
          : _brandController.text.trim(),
      condition: _condition!,
      description: description,
      shippingCost: int.tryParse(_shippingController.text.trim()) ??
          (user.isProximityShop ? 0 : 5000),
      compareAtPrice: _discountEnabled ? _compareAtPrice : null,
      negotiable: _negotiable,
    );
  }

  void _saveDraft() {
    final draft = ListingDraft(
      id: _draftId ?? 'draft_${DateTime.now().millisecondsSinceEpoch}',
      updatedAt: DateTime.now(),
      title: _resolvedTitle,
      description: _descriptionController.text.trim(),
      photos: List<String>.from(_photos),
      categoryId: _categoryId,
      subcategoryId: _subcategoryId,
      categoryPathLabel: _categoryPathLabel,
      brand: _brandController.text.trim().isEmpty
          ? null
          : _brandController.text.trim(),
      condition: _condition,
      size: _sizeController.text.trim().isEmpty
          ? null
          : _sizeController.text.trim(),
      colors: List<String>.from(_selectedColors),
      netPrice: _netPrice,
      shippingCost: int.tryParse(_shippingController.text.trim()),
      stock: int.tryParse(_stockController.text.trim()) ?? 1,
      worldwideShipping: _worldwideShipping,
    );
    MockListingDraftService.instance.save(draft);
    _draftId = draft.id;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.savedToDrafts),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
      ),
    );
  }

  void _openDrafts() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const DraftsScreen()),
    );
  }

  void _openCopyListing() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const CopyListingScreen()),
    );
  }

  void _showPhotoGuide() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const PhotoTipsScreen(),
      ),
    );
  }

  String _conditionIdFromValue(String? value) {
    if (value == null) return 'veryGood';
    final normalized = value.toLowerCase().trim();
    if (normalized.contains('étiquette') ||
        normalized.contains('brand new') ||
        normalized.contains('new with')) {
      return 'newWithTag';
    }
    if (normalized.contains('sans') ||
        normalized.contains('like new') ||
        normalized.contains('without')) {
      return 'newWithoutTag';
    }
    if (normalized.contains('très') ||
        normalized.contains('excellent') ||
        normalized.contains('very good')) {
      return 'veryGood';
    }
    if (normalized.contains('fair') ||
        normalized.contains('satisfaisant') ||
        normalized.contains('satisfactory')) {
      return 'satisfactory';
    }
    if (normalized.contains('good') || normalized.contains('bon')) {
      return 'good';
    }
    for (final option in sellConditionOptions) {
      if (option.id.toLowerCase() == normalized) return option.id;
    }
    return 'veryGood';
  }

  String _conditionChipLabel(AppLocalizations t) {
    if (_conditionId != null) {
      return sellConditionTitle(_conditionId!, t);
    }
    if (_condition == null) return t.addConditionChip;
    return _conditionLabel(_condition!, t);
  }

  bool _submitting = false;

  Future<void> _submit() async {
    if (_photos.isEmpty) {
      setState(() => _showPhotoError = true);
      return;
    }
    if (!_canSubmit || _submitting) return;
    final t = AppLocalizations.of(context)!;
    var user = MockSession.instance.user;
    if (!user.role.isSeller) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const BecomeSellerScreen(),
        ),
      );
      return;
    }
    if (isSellerVerificationPending) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.sellerVerificationPendingBody),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    final draft = _buildDraftProduct();
    final conditionCode = _conditionId ?? _conditionCodeFromLabel(draft.condition);
    final colors = _selectedColors.isNotEmpty
        ? List<String>.from(_selectedColors)
        : (_colorController.text.trim().isEmpty
            ? <String>[]
            : _colorController.text
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList());

    try {
      await PlatformApi.instance.fetchCommissionRates();

      if (_isEdit) {
        final existing = widget.product!;
        try {
          final patched = await ListingsApi.instance.patch(existing.id, {
            'title': draft.title,
            'description': draft.description,
            'categoryId': draft.categoryId,
            if (_subcategoryId != null) 'subcategoryId': _subcategoryId,
            'conditionCode': conditionCode,
            if (draft.brand != null) 'brand': draft.brand,
            'size': draft.size,
            if (colors.isNotEmpty) 'colors': colors,
            'netPriceGnf': draft.netPrice ?? _netPrice!,
            'stock': draft.stock,
            'shippingCostGnf': draft.shippingCost,
            'worldwideShipping': _worldwideShipping,
            'negotiable': _negotiable,
            'discountEnabled': _discountEnabled && draft.compareAtPrice != null,
            if (draft.compareAtPrice != null)
              'compareAtPriceGnf': draft.compareAtPrice,
          });
          final product = productFromListingJson(patched);
          ListingsRepository.instance.upsert(product);
        } catch (e) {
          if (!mounted) return;
          final message = e is ApiException ? e.message : e.toString();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.listingUpdated),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      late final Product product;
      try {
        // Never send destination — server assigns from seller profile.
        final created = await ListingsApi.instance.create({
          'title': draft.title,
          'description': draft.description ?? '',
          'categoryId': draft.categoryId,
          if (_subcategoryId != null) 'subcategoryId': _subcategoryId,
          'conditionCode': conditionCode,
          if (draft.brand != null) 'brand': draft.brand,
          'size': draft.size,
          if (colors.isNotEmpty) 'colors': colors,
          'netPriceGnf': draft.netPrice ?? _netPrice!,
          'stock': draft.stock,
          'shippingCostGnf': draft.shippingCost,
          'worldwideShipping': _worldwideShipping,
          'negotiable': _negotiable,
          'discountEnabled': _discountEnabled && draft.compareAtPrice != null,
          if (draft.compareAtPrice != null)
            'compareAtPriceGnf': draft.compareAtPrice,
          'publish': false,
        });
        final listingId = (created['id'] ?? '').toString();
        if (listingId.isEmpty) {
          throw ApiException(code: 'LISTING_CREATE_FAILED', message: 'No id');
        }

        var sort = 0;
        for (final photo in _photos) {
          try {
            final media = await MediaApi.instance.uploadPhotoSource(photo);
            if (media == null) continue;
            await ListingsApi.instance.addMedia(
              listingId,
              publicId: media.publicId,
              url: media.url,
              mimeType: media.mimeType,
              sortOrder: sort++,
            );
          } catch (_) {
            // Keep going; publish may fail with PHOTOS_REQUIRED.
          }
        }

        product = await ListingsApi.instance.publish(listingId);
        ListingsRepository.instance.upsert(product);
      } catch (e) {
        if (!mounted) return;
        final message = e is ApiException ? e.message : e.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      if (_draftId != null) {
        MockListingDraftService.instance.remove(_draftId!);
      }

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => ListingPublishSuccessScreen(product: product),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final message = e is ApiException ? e.message : e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _conditionCodeFromLabel(String condition) {
    final normalized = condition.toLowerCase().trim();
    if (normalized.contains('étiquette') || normalized.contains('tag')) {
      return 'newWithTag';
    }
    if (normalized.contains('neuf') || normalized.contains('new')) {
      return 'newWithoutTag';
    }
    if (normalized.contains('satisfaisant') ||
        normalized.contains('satisfactory') ||
        normalized.contains('fair')) {
      return 'satisfactory';
    }
    if (normalized.contains('bon') || normalized.contains('good')) {
      return 'good';
    }
    return 'veryGood';
  }

  String _conditionValueFromId(String id) => switch (id) {
        'newWithTag' => 'Neuf avec étiquette',
        'newWithoutTag' => 'Neuf sans étiquette',
        'veryGood' => 'Très bon état',
        'good' => 'Bon état',
        'satisfactory' => 'Satisfaisant',
        _ => 'Très bon état',
      };

  String _conditionLabel(String conditionValue, AppLocalizations t) {
    final normalized = conditionValue.toLowerCase().trim();
    if (normalized == 'new with tags' || normalized == 'neuf avec étiquette') {
      return t.conditionNewWithTag;
    }
    if (normalized == 'new without tags' || normalized == 'neuf sans étiquette') {
      return t.conditionNewWithoutTag;
    }
    if (normalized == 'very good condition' || normalized == 'très bon état') {
      return t.conditionVeryGood;
    }
    if (normalized == 'good condition' || normalized == 'bon état') {
      return t.conditionGood;
    }
    if (normalized == 'fair' || normalized == 'satisfaisant') {
      return t.conditionSatisfactory;
    }
    return conditionValue;
  }



  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final user = MockSession.instance.user;
    final zoneName = user.zoneId ?? '';
    final locationLabel = user.address?.trim().isNotEmpty == true
        ? user.address!.trim()
        : '$zoneName, Guinea';
    final brandValue = _brandController.text.trim();
    final descLen = _descriptionController.text.characters.length
        .clamp(0, _maxDescription);

    return Scaffold(
      backgroundColor: _SellColors.bg,
      appBar: AppBar(
        backgroundColor: _SellColors.bg,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(_step == 0 ? Icons.close : Icons.arrow_back),
          onPressed: _goBack,
        ),
        title: Text(
          t.sellAnItem,
          style: AppTypography.display(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: t.copyAListing,
            onPressed: _openCopyListing,
            icon: const Icon(
              Icons.copy_all_outlined,
              color: AppColors.textPrimary,
            ),
          ),
          IconButton(
            tooltip: t.draftsTitle,
            onPressed: _openDrafts,
            icon: const Icon(
              Icons.folder_outlined,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SellListingStepper(
            currentStep: _step,
            labels: [
              t.sellStepCategory,
              t.sellStepPhotos,
              t.sellStepDetails,
              t.sellStepPrice,
            ],
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: CatalogRepository.instance,
              builder: (context, _) {
                return KeyedSubtree(
                  key: ValueKey<int>(_step),
                  child: _step == 0
                      ? SellCategoryStep(
                          roots: _sellRoots,
                          subcategories: _sellSubcategories,
                          selectedRootId: _categoryId,
                          selectedSubId: _subcategoryId,
                          loading:
                              CatalogRepository.instance.isCategoriesLoading,
                          error: CatalogRepository.instance.error,
                          onRetry: _loadSellCategories,
                          onRootSelected: _onRootCategorySelected,
                          onSubSelected: _onSubCategorySelected,
                        )
                      : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                if (_step == 1) ...[
                _sectionHeader(
                  title: t.addPhotosTitle,
                  trailing: t.upToPhotos(_maxPhotos),
                  actionLabel: t.viewPhotoGuide,
                  onAction: _showPhotoGuide,
                ),
                const SizedBox(height: 14),
                _PhotoStrip(
                  photos: _photos,
                  maxPhotos: _maxPhotos,
                  onAdd: _addPhoto,
                  onRemove: _removePhoto,
                ),
                if (_photos.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _addPhoto,
                      style: FilledButton.styleFrom(
                        backgroundColor: _SellColors.chip,
                        foregroundColor: AppColors.textPrimary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        t.editPhotos,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: null,
                      style: FilledButton.styleFrom(
                        disabledBackgroundColor: _SellColors.chip,
                        disabledForegroundColor: _SellColors.muted,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        t.editPhotos,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  if (_showPhotoError) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 18,
                          color: Colors.red.shade600,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            t.addAtLeastOnePhoto,
                            style: TextStyle(
                              color: Colors.red.shade600,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
                ],
                if (_step == 2) ...[
                Text(
                  t.title,
                  style: AppTypography.display(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                _LabeledField(
                  label: t.title,
                  child: TextField(
                    controller: _titleController,
                    maxLength: 120,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                    ),
                    cursorColor: AppColors.primary,
                    decoration: InputDecoration(
                      hintText: t.titleHint,
                      hintStyle: const TextStyle(
                        color: _SellColors.muted,
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      counterText: '',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const _SellDivider(),
                const SizedBox(height: 18),
                Text(
                  t.description,
                  style: AppTypography.display(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: _SellColors.fieldFill,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _SellColors.border),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _descriptionController,
                        maxLength: _maxDescription,
                        maxLines: 5,
                        minLines: 4,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          height: 1.35,
                        ),
                        cursorColor: AppColors.primary,
                        decoration: InputDecoration(
                          hintText: t.describeItemHint,
                          hintStyle: const TextStyle(
                            color: _SellColors.muted,
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          counterText: '',
                          contentPadding:
                              const EdgeInsets.fromLTRB(14, 14, 14, 8),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                        child: Row(
                          children: [
                            Text(
                              t.hashtagsCount(_hashtagCount),
                              style: const TextStyle(
                                color: _SellColors.muted,
                                fontSize: 13,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '$descLen / $_maxDescription',
                              style: const TextStyle(
                                color: _SellColors.muted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                const _SellDivider(),
                const SizedBox(height: 18),
                Text(
                  t.infoSection,
                  style: AppTypography.display(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_categoryPathLabel != null) ...[
                      _InfoChip(
                        label: _categoryPathLabel!,
                        selected: true,
                        showCheck: true,
                        onTap: () => setState(() => _step = 0),
                      ),
                      const SizedBox(height: 10),
                    ],
                    _InfoChip(
                      label: brandValue.isEmpty ? t.addBrandChip : brandValue,
                      selected: brandValue.isNotEmpty,
                      onTap: _selectBrand,
                    ),
                    const SizedBox(height: 10),
                    _InfoChip(
                      label: _condition == null
                          ? t.addConditionChip
                          : _conditionChipLabel(t),
                      selected: _condition != null,
                      onTap: _selectCondition,
                    ),
                    if (_needsSize) ...[
                      const SizedBox(height: 10),
                      _InfoChip(
                        label: _sizeController.text.trim().isEmpty
                            ? t.addSizeChip
                            : _sizeController.text.trim(),
                        selected: _sizeController.text.trim().isNotEmpty,
                        onTap: _selectSize,
                      ),
                    ],
                    if (_needsColors) ...[
                      const SizedBox(height: 10),
                      _InfoChip(
                        label: _selectedColors.isEmpty
                            ? '+ ${t.colours}'
                            : _selectedColors
                                .map((c) => sellColorLabel(c, t))
                                .join(', '),
                        selected: _selectedColors.isNotEmpty,
                        onTap: _selectColors,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 14),
                _LabeledField(
                  label: t.quantityLabel,
                  child: TextField(
                    controller: _stockController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                    ),
                    cursorColor: AppColors.primary,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                ],
                if (_step == 3) ...[
                Text(
                  t.priceSection,
                  style: AppTypography.display(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t.yourPriceLabel,
                  style: TextStyle(
                    color: AppColors.textPrimary.withValues(alpha: 0.65),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                _MoneyField(
                  controller: _netPriceController,
                  hint: '00',
                  prefix: 'GNF',
                ),
                const SizedBox(height: 16),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    t.discountToggleLabel,
                    style: AppTypography.style(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  value: _discountEnabled,
                  activeThumbColor: AppColors.primary,
                  onChanged: (v) => setState(() {
                    _discountEnabled = v;
                    if (!v) _compareAtPriceController.clear();
                  }),
                ),
                if (_discountEnabled) ...[
                  const SizedBox(height: 4),
                  Text(
                    t.compareAtPriceLabel,
                    style: TextStyle(
                      color: AppColors.textPrimary.withValues(alpha: 0.65),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _MoneyField(
                    controller: _compareAtPriceController,
                    hint: t.compareAtPriceHint,
                    prefix: 'GNF',
                  ),
                  if (_netPrice != null &&
                      _netPrice! > 0 &&
                      _compareAtPrice != null &&
                      !_discountValid) ...[
                    const SizedBox(height: 8),
                    Text(
                      t.compareAtPriceInvalid,
                      style: AppTypography.style(
                        fontSize: 12,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                ],
                if (_netPrice != null && _netPrice! > 0) ...[
                  const SizedBox(height: 14),
                  _CommissionBreakdown(
                    netPrice: _netPrice!,
                    isProximity: user.isProximityShop,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    t.listingPreviewTitle,
                    style: TextStyle(
                      color: AppColors.textPrimary.withValues(alpha: 0.75),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 168,
                    child: ProductCard(
                      product: Product(
                        id: 'preview',
                        title: _resolvedTitle.isEmpty
                            ? t.titleHint
                            : _resolvedTitle,
                        price: displayPriceFromNet(
                          _netPrice!,
                          isProximity: user.isProximityShop,
                        ),
                        netPrice: _netPrice,
                        compareAtPrice:
                            _discountEnabled ? _compareAtPrice : null,
                        image: _photos.isNotEmpty
                            ? _photos.first
                            : _placeholderPhotos.first,
                        size: _sizeController.text.trim().isEmpty
                            ? t.oneSize
                            : _sizeController.text.trim(),
                        categoryId: _categoryId ?? '',
                        sellerId: user.sellerId,
                        sellerType:
                            user.sellerType ?? SellerType.particulier,
                        stock: int.tryParse(_stockController.text.trim()) ?? 1,
                        brand: _brandController.text.trim().isEmpty
                            ? null
                            : _brandController.text.trim(),
                        shippingCost:
                            int.tryParse(_shippingController.text.trim()) ??
                                (user.isProximityShop ? 0 : 5000),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                const _SellDivider(),
                const SizedBox(height: 18),
                Text(
                  t.shippingSection,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  t.domesticShippingPrice,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                _MoneyField(
                  controller: _shippingController,
                  hint: '00',
                  prefix: 'GNF',
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _InfoChip(
                        label: t.locationChip(locationLabel),
                        selected: true,
                        showCheck: true,
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _SellColors.chip,
                        shape: BoxShape.circle,
                        border: Border.all(color: _SellColors.border),
                      ),
                      child: Icon(
                        Icons.chevron_right,
                        color: AppColors.textPrimary.withValues(alpha: 0.5),
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _InfoChip(
                    label: t.worldwideShippingOptional,
                    selected: _worldwideShipping,
                    onTap: () => setState(
                      () => _worldwideShipping = !_worldwideShipping,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ],
              ],
            ),
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                child: _step < 3
                    ? SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: (_step == 0 && _canContinueFromCategory) ||
                                  (_step == 1 && _canContinueFromPhotos) ||
                                  (_step == 2 && _canContinueFromDetails)
                              ? _goNext
                              : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            disabledBackgroundColor: _SellColors.chip,
                            foregroundColor: Colors.white,
                            disabledForegroundColor: _SellColors.muted,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: const StadiumBorder(),
                          ),
                          child: Text(
                            switch (_step) {
                              0 => t.sellContinueToPhotos,
                              1 => t.sellContinueToDetails,
                              _ => t.sellContinueToPrice,
                            },
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      )
                    : Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isEdit ? null : _saveDraft,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(
                            color: AppColors.textPrimary,
                            width: 1.2,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          t.saveToDrafts,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _canSubmit ? _submit : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: _SellColors.chip,
                          foregroundColor: Colors.white,
                          disabledForegroundColor: _SellColors.muted,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          _isEdit ? t.save : t.postListing,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader({
    required String title,
    required String trailing,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text.rich(
            TextSpan(
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
              ),
              children: [
                TextSpan(
                  text: title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(
                  text: ' ($trailing)',
                  style: const TextStyle(color: _SellColors.muted),
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: onAction,
          child: Text(
            actionLabel,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}


class _CommissionBreakdown extends StatelessWidget {
  const _CommissionBreakdown({
    required this.netPrice,
    required this.isProximity,
  });

  final int netPrice;
  final bool isProximity;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final rate = commissionRateFor(isProximity: isProximity);
    final percent = (rate * 100).round().toString();
    final fee = commissionAmountFromNet(netPrice, isProximity: isProximity);
    final buyerPrice = displayPriceFromNet(netPrice, isProximity: isProximity);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _SellColors.border),
      ),
      child: Column(
        children: [
          _CommissionRow(
            label: t.yourPriceLabel,
            value: '${formatPrice(netPrice)} GNF',
          ),
          const SizedBox(height: 10),
          _CommissionRow(
            label: t.commissionFeeLabel(percent),
            value: '+ ${formatPrice(fee)} GNF',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: _SellColors.border),
          ),
          _CommissionRow(
            label: t.buyerSeesPriceLabel,
            value: '${formatPrice(buyerPrice)} GNF',
            emphasize: true,
          ),
          const SizedBox(height: 10),
          Text(
            t.commissionSellerHint,
            style: TextStyle(
              fontSize: 12,
              height: 1.35,
              color: AppColors.textPrimary.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommissionRow extends StatelessWidget {
  const _CommissionRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: emphasize ? 14 : 13,
              fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
              color: AppColors.textPrimary.withValues(
                alpha: emphasize ? 0.9 : 0.65,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: TextStyle(
            fontSize: emphasize ? 15 : 13,
            fontWeight: FontWeight.w700,
            color: emphasize ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _SellDivider extends StatelessWidget {
  const _SellDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: _SellColors.divider);
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _SellColors.fieldFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _SellColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Text(
              label,
              style: const TextStyle(
                color: _SellColors.muted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _MoneyField extends StatelessWidget {
  const _MoneyField({
    required this.controller,
    required this.hint,
    required this.prefix,
  });

  final TextEditingController controller;
  final String hint;
  final String prefix;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: _SellColors.fieldFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _SellColors.border),
      ),
      child: Row(
        children: [
          Text(
            prefix,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: _SellColors.muted),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.onTap,
    this.selected = false,
    this.showCheck = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;
  final bool showCheck;

  @override
  Widget build(BuildContext context) {
    final filled = selected;
    final fg = filled ? Colors.white : AppColors.textPrimary;
    final bg = filled ? AppColors.primary : Colors.white;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: filled ? AppColors.primary : _SellColors.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (filled || showCheck) ...[
                    Icon(Icons.check, size: 16, color: fg),
                    const SizedBox(width: 6),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: fg,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (filled && !showCheck) ...[
          const SizedBox(width: 6),
          Material(
            color: _SellColors.chip,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _SellColors.border),
                ),
                child: Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppColors.textPrimary.withValues(alpha: 0.55),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _PhotoStrip extends StatelessWidget {
  const _PhotoStrip({
    required this.photos,
    required this.maxPhotos,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> photos;
  final int maxPhotos;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;

  @override
  Widget build(BuildContext context) {
    final emptySlots = (4 - photos.length).clamp(0, 4);
    final showAdd = photos.length < maxPhotos;

    return SizedBox(
      height: 118,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (var i = 0; i < photos.length; i++) ...[
            _FilledPhotoSlot(
              url: photos[i],
              onRemove: () => onRemove(i),
            ),
            const SizedBox(width: 10),
          ],
          if (showAdd)
            for (var i = 0; i < (photos.isEmpty ? 4 : emptySlots.clamp(1, 3)); i++) ...[
              _DashedAddSlot(onTap: onAdd),
              const SizedBox(width: 10),
            ],
        ],
      ),
    );
  }
}

class _DashedAddSlot extends StatelessWidget {
  const _DashedAddSlot({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedRRectPainter(
          color: AppColors.primary.withValues(alpha: 0.45),
          radius: 12,
        ),
        child: SizedBox(
          width: 88,
          height: 118,
          child: Center(
            child: Icon(
              Icons.add,
              color: AppColors.primary,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}

class _FilledPhotoSlot extends StatelessWidget {
  const _FilledPhotoSlot({required this.url, required this.onRemove});

  final String url;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SafeNetworkImage(
            url: url,
            width: 88,
            height: 118,
            fit: BoxFit.cover,
            iconSize: 28,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      const dash = 5.0;
      const gap = 4.0;
      while (distance < metric.length) {
        final next = (distance + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}


class _SingleChoicePickerScreen extends StatefulWidget {
  const _SingleChoicePickerScreen({
    required this.title,
    required this.options,
    required this.selected,
    this.descriptions = const {},
  });

  final String title;
  final List<String> options;
  final String? selected;
  final Map<String, String> descriptions;

  @override
  State<_SingleChoicePickerScreen> createState() => _SingleChoicePickerScreenState();
}

class _SingleChoicePickerScreenState extends State<_SingleChoicePickerScreen> {
  late String? _selected = widget.selected;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        title: Text(widget.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(_selected),
            child: Text(t.done),
          ),
        ],
      ),
      body: ListView(
        children: [
          if (widget.title == t.sizes) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Column(
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        height: 1.35,
                      ),
                      children: [
                        TextSpan(text: t.vintedSizesInfoPrefix),
                        TextSpan(
                          text: t.viewSizeGuide,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const _SizeGuideScreen(),
                        ),
                      );
                    },
                    child: Text(t.openSizeGuide),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                t.allSizes,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          if (widget.title == t.category) ...[
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                t.all,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          ...widget.options.map((option) {
            final selected = _selected == option;
            final description = widget.descriptions[option];
            return Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: ListTile(
                leading: widget.title == t.category
                    ? Icon(_categoryIcon(option), color: AppColors.primary)
                    : null,
                title: Text(
                  option,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: description == null ? null : Text(description),
                trailing: Icon(
                  selected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: selected ? AppColors.primary : AppColors.textPrimary,
                ),
                onTap: () => setState(() => _selected = option),
              ),
            );
          }),
        ],
      ),
    );
  }

  IconData _categoryIcon(String label) {
    final lower = label.toLowerCase();
    if (lower.contains('mode') ||
        lower.contains('fashion') ||
        lower.contains('accessoires') ||
        lower.contains('accessories')) {
      return Icons.checkroom_outlined;
    }
    if (lower.contains('chaussures') || lower.contains('shoes')) {
      return Icons.shopping_bag_outlined;
    }
    if (lower.contains('bébé') ||
        lower.contains('maternité') ||
        lower.contains('baby') ||
        lower.contains('maternity')) {
      return Icons.child_care_outlined;
    }
    if (lower.contains('beauté') ||
        lower.contains('cosmétique') ||
        lower.contains('beauty') ||
        lower.contains('cosmetic')) {
      return Icons.spa_outlined;
    }
    if (lower.contains('maison') ||
        lower.contains('décoration') ||
        lower.contains('home') ||
        lower.contains('decor')) {
      return Icons.chair_outlined;
    }
    if (lower.contains('électronique') || lower.contains('electronics')) {
      return Icons.devices_outlined;
    }
    return Icons.category_outlined;
  }
}

class _BrandPickerScreen extends StatefulWidget {
  const _BrandPickerScreen({
    required this.suggestedBrands,
    required this.selectedBrand,
  });

  final List<String> suggestedBrands;
  final String? selectedBrand;

  @override
  State<_BrandPickerScreen> createState() => _BrandPickerScreenState();
}

class _BrandPickerScreenState extends State<_BrandPickerScreen> {
  late final TextEditingController _searchController;
  late String? _selected = widget.selectedBrand;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final query = _searchController.text.trim().toLowerCase();
    final filtered = widget.suggestedBrands
        .where((b) => b.toLowerCase().contains(query))
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        title: Text(t.brand),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                t.brandCatalogHint,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: t.findABrand,
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: Text(t.noBrandUnbranded),
                  trailing: Icon(
                    _selected == t.noBrandValue
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: _selected == t.noBrandValue
                        ? AppColors.primary
                        : Colors.grey.shade400,
                  ),
                  onTap: () {
                    setState(() => _selected = t.noBrandValue);
                    Navigator.of(context).pop(t.noBrandValue);
                  },
                ),
                if (query.isNotEmpty)
                  ListTile(
                    title: Text('${t.useCustomBrand} "$query"'),
                    trailing: const Icon(Icons.add, color: AppColors.primary),
                    onTap: () {
                      final custom = _searchController.text.trim();
                      Navigator.of(context).pop(custom);
                    },
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Text(
                    t.platformBrands,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                for (final brand in filtered)
                  ListTile(
                    title: Text(brand),
                    trailing: Icon(
                      _selected == brand
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: _selected == brand
                          ? AppColors.primary
                          : Colors.grey.shade400,
                    ),
                    onTap: () {
                      setState(() => _selected = brand);
                      Navigator.of(context).pop(_selected);
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorPickerScreen extends StatefulWidget {
  const _ColorPickerScreen({
    required this.selectedColors,
    required this.allColors,
  });

  final List<String> selectedColors;
  final List<String> allColors;

  @override
  State<_ColorPickerScreen> createState() => _ColorPickerScreenState();
}

class _ColorPickerScreenState extends State<_ColorPickerScreen> {
  late final Set<String> _selected = widget.selectedColors.toSet();
  final List<String> _customColors = [];

  Color _dotColor(String color) {
    switch (color.toLowerCase()) {
      case 'white':
        return Colors.white;
      case 'black':
        return Colors.black;
      case 'brown':
        return const Color(0xFF7A4A00);
      case 'grey':
        return Colors.grey;
      case 'beige':
        return const Color(0xFFE9DCCB);
      case 'pink':
        return Colors.pink;
      case 'purple':
        return Colors.purple;
      case 'red':
        return Colors.red;
      case 'yellow':
        return Colors.yellow;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _colorLabel(String color, AppLocalizations t) =>
      sellColorLabel(color, t);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        title: Text(t.colours),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(_selected.toList()),
            child: Text(t.done),
          ),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: Text(
              t.chooseUpTo2Colours,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline, color: AppColors.primary),
            title: Text(t.customColour),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final custom = await _showCustomColorDialog(context);
              if (custom == null) return;
              setState(() {
                if (!_customColors.contains(custom)) {
                  _customColors.add(custom);
                }
                if (_selected.length < 2) {
                  _selected.add(custom);
                }
              });
            },
          ),
          for (final color in widget.allColors)
            ListTile(
              leading: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: _dotColor(color),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300),
                ),
              ),
              title: Text(_colorLabel(color, t)),
              trailing: Checkbox(
                value: _selected.contains(color),
                activeColor: AppColors.primary,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      if (_selected.length < 2) _selected.add(color);
                    } else {
                      _selected.remove(color);
                    }
                  });
                },
              ),
            ),
          for (final color in _customColors)
            ListTile(
              leading: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary),
                ),
                child: const Center(
                  child: Icon(Icons.edit, size: 14, color: AppColors.primary),
                ),
              ),
              title: Text(color),
              trailing: Checkbox(
                value: _selected.contains(color),
                activeColor: AppColors.primary,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      if (_selected.length < 2) _selected.add(color);
                    } else {
                      _selected.remove(color);
                    }
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<String?> _showCustomColorDialog(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(t.addCustomColour),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: t.customColourHint),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(t.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text.trim()),
              child: Text(t.add),
            ),
          ],
        );
      },
    );
    if (result == null || result.isEmpty) return null;
    return result;
  }
}

class _SizeGuideScreen extends StatelessWidget {
  const _SizeGuideScreen();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    const rows = [
      ['XS', '30-32', '40-42'],
      ['S', '34-36', '44-46'],
      ['M', '38-40', '48-50'],
      ['L', '42-44', '52-54'],
      ['XL', '46', '56'],
      ['XXL', '48', '58'],
      ['XXXL', '50', '60'],
      ['4XL', '52', '62'],
      ['5XL', '54', '64'],
      ['6XL', '56', '66'],
      ['7XL', '58', '68'],
      ['8XL', '60', '70'],
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        children: [
          Text(
            t.mensClothingSizeGuide,
            style: TextStyle(fontSize: 38 / 2, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Text(
            t.sizeGuideDescription,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Table(
            border: TableBorder.all(color: AppColors.textPrimary),
            columnWidths: const {
              0: FlexColumnWidth(1.6),
              1: FlexColumnWidth(1.2),
              2: FlexColumnWidth(1.0),
            },
            children: [
              const TableRow(
                children: [
                  _GuideCell(text: 'International', isHeader: true),
                  _GuideCell(text: 'UK/US', isHeader: true),
                  _GuideCell(text: 'EU', isHeader: true),
                ],
              ),
              ...rows.map(
                (row) => TableRow(
                  children: [
                    _GuideCell(text: row[0]),
                    _GuideCell(text: row[1]),
                    _GuideCell(text: row[2]),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GuideCell extends StatelessWidget {
  const _GuideCell({required this.text, this.isHeader = false});

  final String text;
  final bool isHeader;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          fontWeight: isHeader ? FontWeight.w600 : FontWeight.w400,
          color: Colors.black87,
        ),
      ),
    );
  }
}
