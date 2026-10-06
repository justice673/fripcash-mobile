import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/models/browse_category.dart';
import 'package:frip_cash/models/product.dart';
import 'package:frip_cash/navigation/product_navigation.dart';
import 'package:frip_cash/services/listings_repository.dart';
import 'package:frip_cash/theme/app_breakpoints.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/utils/safe_notify.dart';
import 'package:frip_cash/widgets/empty_state_lottie.dart';
import 'package:frip_cash/widgets/empty_state_view.dart';
import 'package:frip_cash/widgets/product_card.dart';

class BrowseCategoryScreen extends StatefulWidget {
  const BrowseCategoryScreen({
    super.key,
    required this.category,
  });

  final BrowseCategory category;

  @override
  State<BrowseCategoryScreen> createState() => _BrowseCategoryScreenState();
}

class _BrowseCategoryScreenState extends State<BrowseCategoryScreen> {
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    ListingsRepository.instance.addListener(_onRepo);
    runAfterFrame(_ensureLoaded);
  }

  @override
  void dispose() {
    ListingsRepository.instance.removeListener(_onRepo);
    super.dispose();
  }

  void _onRepo() {
    if (!mounted) return;
    runAfterFrame(() {
      if (mounted) setState(() {});
    });
  }

  Future<void> _ensureLoaded() async {
    final cache = ListingsRepository.instance.allCached;
    if (cache.isNotEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    await ListingsRepository.instance.fetch();
    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = ListingsRepository.instance.error;
    });
  }

  List<Product> get _products {
    final all = ListingsRepository.instance.allCached;
    final ids = widget.category.matchingCategoryIds;
    if (ids.isEmpty) return all;
    return all.where((p) => ids.contains(p.categoryId)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final title = widget.category.labelForLocale(
      Localizations.localeOf(context).languageCode,
    );
    final products = _products;
    final isTablet = AppBreakpoints.isTablet(context);
    final sidePad = isTablet ? 24.0 : 16.0;
    final contentWidth = AppBreakpoints.homeMaxWidth(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? EmptyStateView(
                  illustration: const EmptyStateLottie(size: 160),
                  title: t.browseCategoryEmptyTitle,
                  subtitle: _error ?? t.browseCategoryEmptySubtitle,
                  actionLabel: t.discoverItemsAction,
                  onAction: () => Navigator.of(context).pop(),
                )
              : Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentWidth),
                    child: GridView.builder(
                      padding: EdgeInsets.fromLTRB(sidePad, 8, sidePad, 24),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            AppBreakpoints.productGridCrossAxisCount(context),
                        crossAxisSpacing: 12,
                        mainAxisSpacing:
                            AppBreakpoints.productGridMainAxisSpacing(context),
                        childAspectRatio:
                            AppBreakpoints.productGridChildAspectRatio(context),
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return ProductCard(
                          product: product,
                          onTap: () => openProductDetail(context, product),
                        );
                      },
                    ),
                  ),
                ),
    );
  }
}
