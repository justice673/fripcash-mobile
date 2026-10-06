import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/mock/mock_sellers.dart';
import 'package:frip_cash/models/product.dart';
import 'package:frip_cash/models/seller.dart';
import 'package:frip_cash/models/seller_type.dart';
import 'package:frip_cash/navigation/product_navigation.dart';
import 'package:frip_cash/services/cart_store.dart';
import 'package:frip_cash/services/favorites_store.dart';
import 'package:frip_cash/screens/chat_screen.dart';
import 'package:frip_cash/services/conversations_repository.dart';
import 'package:frip_cash/services/listings_repository.dart';
import 'package:frip_cash/services/mock_listing_service.dart';
import 'package:frip_cash/services/mock_session.dart';
import 'package:frip_cash/services/offers_repository.dart';
import 'package:frip_cash/theme/app_breakpoints.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/utils/auth_error_message.dart';
import 'package:frip_cash/utils/price_formatter.dart';
import 'package:frip_cash/utils/safe_notify.dart';
import 'package:frip_cash/utils/share_links.dart';
import 'package:frip_cash/widgets/cart_sheet.dart';
import 'package:frip_cash/widgets/make_offer_sheet.dart';
import 'package:frip_cash/widgets/safe_network_image.dart';
import 'package:frip_cash/widgets/seller_type_badge.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  final _pageController = PageController();
  late final TabController _tabController;
  int _imageIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    runAfterFrame(_hydrateFromApi);
  }

  /// Pull full listing (all `media[]`) + related catalog rows from Nest.
  Future<void> _hydrateFromApi() async {
    final id = widget.product.id;
    if (id.isEmpty) return;
    await ListingsRepository.instance.fetchById(id);
    if (!mounted) return;
    final product =
        ListingsRepository.instance.productById(id) ?? widget.product;
    await Future.wait([
      OffersRepository.instance.refreshMine().catchError((_) {}),
      if (product.sellerId.isNotEmpty)
        ListingsRepository.instance.fetch(sellerId: product.sellerId),
      ListingsRepository.instance.fetch(
        categoryId: product.categoryId,
        destination: product.destination,
      ),
    ]);
    if (!mounted) return;
    setState(() => _imageIndex = 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  List<Product> get _sellerItems {
    final sellerId = widget.product.sellerId;
    final catalog = ListingsRepository.instance.allCached;
    final sameSeller = catalog
        .where(
          (product) =>
              product.id != widget.product.id && product.sellerId == sellerId,
        )
        .take(4)
        .toList();
    if (sameSeller.length >= 2) return sameSeller;
    return catalog
        .where((product) => product.id != widget.product.id)
        .take(4)
        .toList();
  }

  List<Product> get _similarItems {
    final current = widget.product;
    final catalog = ListingsRepository.instance.allCached;
    final sameKind = catalog.where((product) {
      if (product.id == current.id) return false;
      return product.categoryId == current.categoryId ||
          product.destination == current.destination;
    }).toList();
    if (sameKind.isNotEmpty) return sameKind.take(4).toList();
    return catalog
        .where((product) => product.id != current.id)
        .take(4)
        .toList();
  }

  void _selectColor(int index) {
    if (_imageIndex == index) return;
    setState(() => _imageIndex = index);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pageController.hasClients) return;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    });
  }

  /// Prefer Nest seller fields on the listing; fall back to mock map only
  /// for legacy seed product ids.
  SellerInfo _sellerFor(Product product) {
    final name = product.sellerName?.trim();
    if (name != null && name.isNotEmpty) {
      return SellerInfo(
        id: product.sellerId.isNotEmpty ? product.sellerId : 'seller_api',
        username: name,
        avatarUrl: product.sellerAvatarUrl?.isNotEmpty == true
            ? product.sellerAvatarUrl!
            : (product.sellerId.isNotEmpty
                ? 'https://i.pravatar.cc/150?u=${product.sellerId}'
                : ''),
        type: product.sellerType,
        rating: product.sellerRating ?? 0,
        reviewCount: product.sellerReviewCount ?? 0,
        badge: product.badge,
      );
    }
    return sellerForProduct(product.id);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final baseProduct = productById(widget.product.id) ?? widget.product;
    final seller = _sellerFor(baseProduct);
    final sizeLabel = baseProduct.size.toLowerCase() == 'unique'
        ? t.oneSize
        : baseProduct.size;

    return ListenableBuilder(
      listenable: Listenable.merge([
        OffersRepository.instance,
        MockListingService.instance,
        ListingsRepository.instance,
      ]),
      builder: (context, _) {
        final product = productById(widget.product.id) ?? baseProduct;
        final images = product.galleryImages;
        final acceptedPrice =
            OffersRepository.instance.acceptedPriceFor(product.id);
        final purchaseProduct = acceptedPrice != null
            ? product.copyWith(price: acceptedPrice)
            : product;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _ImageGallery(
                        images: images,
                        productId: product.id,
                        stock: product.stock,
                        imageIndex: _imageIndex,
                        pageController: _pageController,
                        onPageChanged: (index) {
                          if (_imageIndex == index) return;
                          setState(() => _imageIndex = index);
                        },
                        onSelectImage: _selectColor,
                        onBack: () => Navigator.of(context).pop(),
                        onMore: () => _showMoreMenu(context, product),
                      ),
                    ),
                    if (!product.inStock)
                      const SliverToBoxAdapter(child: _OutOfStockBanner()),
                    SliverToBoxAdapter(
                      child: _ProductInfoSection(
                        product: purchaseProduct,
                        sizeLabel: sizeLabel,
                        seller: seller,
                        acceptedPrice: acceptedPrice,
                      ),
                    ),
                    if (product.hasColorVariants)
                      SliverToBoxAdapter(
                        child: _ColorVariantsSection(
                          colors: product.colors!,
                          selectedIndex: _imageIndex.clamp(
                            0,
                            product.colors!.length - 1,
                          ),
                          onSelected: _selectColor,
                        ),
                      ),
                    SliverToBoxAdapter(child: _SectionDivider()),
                    SliverToBoxAdapter(
                      child: _DescriptionSection(
                        text: product.displayDescription,
                      ),
                    ),
                    SliverToBoxAdapter(child: _SectionDivider()),
                    SliverToBoxAdapter(
                      child: _SellerSection(seller: seller, product: product),
                    ),
                    SliverToBoxAdapter(child: _SectionDivider()),
                    SliverToBoxAdapter(
                      // Reviews come from Nest order ratings — no seeded PDP reviews.
                      child: const SizedBox.shrink(),
                    ),
                    SliverToBoxAdapter(child: _SectionDivider()),
                    const SliverToBoxAdapter(child: _BuyerProtectionSection()),
                    SliverToBoxAdapter(child: _SectionDivider()),
                    SliverToBoxAdapter(
                      child: _PostageSection(shippingCost: product.shippingCost),
                    ),
                    SliverToBoxAdapter(child: _SectionDivider()),
                    SliverToBoxAdapter(
                      child: _RelatedProductsSection(
                        tabController: _tabController,
                        sellerItems: _sellerItems,
                        similarItems: _similarItems,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  ],
                ),
              ),
              _BottomActionBar(
                product: purchaseProduct,
                inStock: product.inStock,
                canMakeOffer: product.negotiable &&
                    product.sellerType != SellerType.enseigne &&
                    product.sellerId.isNotEmpty &&
                    product.sellerId !=
                        MockSession.instance.user.sellerId &&
                    product.sellerId != MockSession.instance.user.id,
                onMakeOffer: () => showMakeOfferSheet(
                  context,
                  product: product,
                  sellerName: seller.username,
                ),
                onBuy: product.inStock
                    ? () async {
                        final deal = OffersRepository.instance
                            .acceptedOfferFor(product.id);
                        try {
                          await CartStore.instance.add(
                            purchaseProduct,
                            offerId: deal?.id,
                            checkoutToken: deal?.checkoutToken,
                          );
                          if (!context.mounted) return;
                          showCartSheet(context);
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(authErrorMessage(e)),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMoreMenu(BuildContext context, Product product) {
    final t = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.share_outlined),
                title: Text(t.share),
                subtitle: Text(t.shareListingSubtitle),
                onTap: () {
                  Navigator.pop(context);
                  shareListing(
                    context,
                    productId: product.id,
                    title: product.title,
                    priceLabel: '${formatPrice(product.price)} GNF',
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: Text(t.reportListing),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(t.reportSent),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 8, color: Colors.grey.shade100);
  }
}

class _OutOfStockBanner extends StatelessWidget {
  const _OutOfStockBanner();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.red.shade50,
      child: Row(
        children: [
          Icon(Icons.inventory_2_outlined, size: 18, color: Colors.red.shade700),
          const SizedBox(width: 8),
          Text(
            t.outOfStockDetailBanner,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageGallery extends StatelessWidget {
  const _ImageGallery({
    required this.images,
    required this.productId,
    required this.stock,
    required this.imageIndex,
    required this.pageController,
    required this.onPageChanged,
    required this.onSelectImage,
    required this.onBack,
    required this.onMore,
  });

  final List<String> images;
  final String productId;
  final int stock;
  final int imageIndex;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onSelectImage;
  final VoidCallback onBack;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final slides = images.isNotEmpty ? images : const <String>[];
    final safeIndex =
        slides.isEmpty ? 0 : imageIndex.clamp(0, slides.length - 1);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (slides.isEmpty)
                ColoredBox(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(Icons.image_outlined, size: 48),
                  ),
                )
              else if (slides.length == 1)
                SafeNetworkImage(
                  url: slides.first,
                  fit: BoxFit.cover,
                )
              else
                PageView.builder(
                  controller: pageController,
                  itemCount: slides.length,
                  onPageChanged: onPageChanged,
                  physics: const BouncingScrollPhysics(
                    parent: PageScrollPhysics(),
                  ),
                  itemBuilder: (context, index) {
                    return SafeNetworkImage(
                      key: ValueKey('pdp-slide-$index-${slides[index]}'),
                      url: slides[index],
                      fit: BoxFit.cover,
                    );
                  },
                ),
              Positioned(
                top: MediaQuery.paddingOf(context).top + 8,
                left: 8,
                child: _OverlayIconButton(
                  icon: Icons.arrow_back,
                  onTap: onBack,
                ),
              ),
              Positioned(
                top: MediaQuery.paddingOf(context).top + 8,
                right: 8,
                child: _OverlayIconButton(
                  icon: Icons.more_horiz,
                  onTap: onMore,
                ),
              ),
              if (stock <= 5)
                Positioned(
                  left: 12,
                  top: MediaQuery.paddingOf(context).top + 52,
                  child: StockBadge(stock: stock),
                ),
              if (slides.length > 1) ...[
                if (safeIndex > 0)
                  Positioned(
                    left: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: _OverlayIconButton(
                        icon: Icons.chevron_left,
                        onTap: () => onSelectImage(safeIndex - 1),
                      ),
                    ),
                  ),
                if (safeIndex < slides.length - 1)
                  Positioned(
                    right: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: _OverlayIconButton(
                        icon: Icons.chevron_right,
                        onTap: () => onSelectImage(safeIndex + 1),
                      ),
                    ),
                  ),
                Positioned(
                  left: 0,
                  right: 56,
                  bottom: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var index = 0; index < slides.length; index++)
                        Container(
                          width: index == safeIndex ? 8 : 6,
                          height: index == safeIndex ? 8 : 6,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(
                              alpha: index == safeIndex ? 1 : 0.55,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              Positioned(
                right: 12,
                bottom: 12,
                child: ListenableBuilder(
                  listenable: FavoritesStore.instance,
                  builder: (context, _) {
                    final liked = FavoritesStore.instance.isFavorite(productId);
                    return GestureDetector(
                      onTap: () => FavoritesStore.instance.toggle(productId),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          liked ? Icons.favorite : Icons.favorite_border,
                          size: 24,
                          color:
                              liked ? Colors.redAccent : AppColors.textPrimary,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        if (slides.length > 1)
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              itemCount: slides.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final selected = index == safeIndex;
                return GestureDetector(
                  onTap: () => onSelectImage(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : Colors.grey.shade300,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: SafeNetworkImage(
                        url: slides[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _OverlayIconButton extends StatelessWidget {
  const _OverlayIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.35),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

class _ProductInfoSection extends StatelessWidget {
  const _ProductInfoSection({
    required this.product,
    required this.sizeLabel,
    required this.seller,
    this.acceptedPrice,
  });

  final Product product;
  final String sizeLabel;
  final SellerInfo seller;
  final int? acceptedPrice;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final brand = product.brand;
    final title = brand != null ? '$brand - ${product.title}' : product.title;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
              children: [
                TextSpan(text: '$sizeLabel · ${product.condition}'),
                if (brand != null)
                  TextSpan(
                    text: ' · $brand',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (acceptedPrice != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${t.acceptedPriceLabel}: ${formatPrice(acceptedPrice!)} GNF',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            '${formatPrice(product.price)} GNF',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '${formatPrice(product.priceWithShipping)} GNF incl.',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
              Icon(
                Icons.verified_user_outlined,
                size: 15,
                color: AppColors.primary.withValues(alpha: 0.9),
              ),
              Text(
                t.buyerProtection,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${t.deliverWithin} ${seller.deliverySla}',
            style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
          ),
          if (product.inStock) ...[
            const SizedBox(height: 4),
            Text(
              '${t.availableStock}: ${product.stock}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: product.isLowStock
                    ? Colors.orange.shade800
                    : Colors.grey.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ColorVariantsSection extends StatelessWidget {
  const _ColorVariantsSection({
    required this.colors,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> colors;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static Color _swatchFor(String name) {
    final key = name.toLowerCase().trim();
    return switch (key) {
      'rouge' || 'red' => const Color(0xFFE53935),
      'noir' || 'black' => const Color(0xFF1A1A1A),
      'bleu' || 'blue' => const Color(0xFFA8C0E8),
      'vert' || 'green' => const Color(0xFF66BB6A),
      'jaune' || 'yellow' => const Color(0xFFE8D9A0),
      'rose' || 'pink' => const Color(0xFFF5B8C8),
      'blanc' || 'white' => const Color(0xFFF5F5F5),
      'bordeaux' => const Color(0xFF7B1E3A),
      'champagne' || 'beige' => const Color(0xFFE8D9A0),
      'gris' || 'gray' || 'grey' => const Color(0xFF9E9E9E),
      'marron' || 'brown' => const Color(0xFF8D6E63),
      'orange' => const Color(0xFFFB8C00),
      _ => AppColors.primary,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: List.generate(colors.length, (index) {
          final selected = index == selectedIndex;
          final swatch = _swatchFor(colors[index]);
          final isLight = swatch.computeLuminance() > 0.75;
          final ring = Color.lerp(swatch, const Color(0xFF1A1A1A), 0.22)!;
          return Padding(
            padding: EdgeInsets.only(right: index == colors.length - 1 ? 0 : 14),
            child: GestureDetector(
              onTap: () => onSelected(index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: selected
                      ? Border.all(color: ring, width: 1.6)
                      : Border.all(color: Colors.transparent, width: 1.6),
                ),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: swatch,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isLight
                          ? Colors.grey.shade400
                          : Colors.black.withValues(alpha: 0.06),
                      width: 0.8,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _DescriptionSection extends StatefulWidget {
  const _DescriptionSection({required this.text});

  final String text;

  @override
  State<_DescriptionSection> createState() => _DescriptionSectionState();
}

class _DescriptionSectionState extends State<_DescriptionSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.description,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.text,
            maxLines: _expanded ? null : 3,
            overflow: _expanded ? null : TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          if (widget.text.length > 120)
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _expanded ? t.showLess : t.showMore,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SellerSection extends StatelessWidget {
  const _SellerSection({required this.seller, required this.product});

  final SellerInfo seller;
  final Product product;

  @override
  Widget build(BuildContext context) {
    final hideDemander = seller.type == SellerType.enseigne;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey.shade200,
            child: ClipOval(
              child: Image.network(
                seller.avatarUrl,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.person, size: 24);
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  seller.username,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                SellerTypeBadge(type: seller.type),
                const SizedBox(height: 4),
                Row(
                  children: [
                    for (var index = 0; index < 5; index++)
                      Icon(
                        Icons.star,
                        size: 14,
                        color: index < seller.rating.floor()
                            ? const Color(0xFFFFB800)
                            : Colors.grey.shade300,
                      ),
                    const SizedBox(width: 4),
                    Text(
                      '(${seller.reviewCount})',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                if (seller.badge != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      seller.badge!,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!hideDemander)
            OutlinedButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final nav = Navigator.of(context);
                try {
                  final thread =
                      await ConversationsRepository.instance.openSellerThread(
                    sellerId: seller.id,
                    sellerName: seller.username,
                    productId: product.id,
                    productTitle: product.title,
                    productImage: product.image,
                    sellerType: seller.type,
                  );
                  await nav.push(
                    MaterialPageRoute<void>(
                      builder: (_) => ChatScreen(threadId: thread.id),
                    ),
                  );
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Text(AppLocalizations.of(context)!.askAction),
            ),
        ],
      ),
    );
  }
}

class _BuyerProtectionSection extends StatelessWidget {
  const _BuyerProtectionSection();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.buyerProtectionFeesTitle,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t.buyerProtectionFeesDescription,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PostageSection extends StatelessWidget {
  const _PostageSection({required this.shippingCost});

  final int shippingCost;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Text(
            t.delivery,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          Text(
            '${t.fromLabel} ${formatPrice(shippingCost)} GNF',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RelatedProductsSection extends StatelessWidget {
  const _RelatedProductsSection({
    required this.tabController,
    required this.sellerItems,
    required this.similarItems,
  });

  final TabController tabController;
  final List<Product> sellerItems;
  final List<Product> similarItems;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TabBar(
          controller: tabController,
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textPrimary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          tabs: [
            Tab(text: t.memberItemsTab),
            Tab(text: t.similarItemsTab),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final itemCount = sellerItems.length > similarItems.length
                ? sellerItems.length
                : similarItems.length;
            final rows = (itemCount / 2).ceil().clamp(1, 4);
            final cellWidth = (constraints.maxWidth - 32 - 12) / 2;
            const textBlockHeight = 44.0;
            final cellHeight = cellWidth + textBlockHeight;
            final gridHeight = rows * cellHeight + (rows - 1) * 12;

            return SizedBox(
              height: gridHeight,
              child: TabBarView(
                controller: tabController,
                children: [
                  _MiniProductGrid(products: sellerItems, cellHeight: cellHeight),
                  _MiniProductGrid(products: similarItems, cellHeight: cellHeight),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _MiniProductGrid extends StatelessWidget {
  const _MiniProductGrid({
    required this.products,
    required this.cellHeight,
  });

  final List<Product> products;
  final double cellHeight;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: AppBreakpoints.productGridCrossAxisCount(context),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: cellHeight,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return GestureDetector(
          onTap: () => openProductDetail(context, product),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox.expand(
                        child: SafeNetworkImage(
                          url: product.image,
                          fit: BoxFit.cover,
                          iconSize: 24,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 6,
                      bottom: 6,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.favorite_border, size: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                product.brand ?? product.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
              ),
              Text(
                '${formatPrice(product.price)} GNF',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.15,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.product,
    required this.inStock,
    required this.canMakeOffer,
    required this.onMakeOffer,
    required this.onBuy,
  });

  final Product product;
  final bool inStock;
  final bool canMakeOffer;
  final VoidCallback onMakeOffer;
  final VoidCallback? onBuy;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          if (canMakeOffer) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: inStock ? onMakeOffer : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  disabledForegroundColor: Colors.grey.shade400,
                  side: BorderSide(
                    color: inStock ? AppColors.primary : Colors.grey.shade300,
                    width: 1.5,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: Text(t.makeOfferAction),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: FilledButton(
              onPressed: onBuy,
              style: FilledButton.styleFrom(
                backgroundColor:
                    inStock ? AppColors.primary : Colors.grey.shade300,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                disabledForegroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Text(inStock ? t.buyAction : t.unavailable),
            ),
          ),
        ],
      ),
    );
  }
}
