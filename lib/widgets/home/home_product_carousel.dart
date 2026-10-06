import 'package:flutter/material.dart';
import 'package:frip_cash/models/product.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_icons.dart';
import 'package:frip_cash/widgets/product_card.dart';

class HomeProductCarousel extends StatefulWidget {
  const HomeProductCarousel({
    super.key,
    required this.title,
    required this.subtitle,
    required this.products,
    this.topPadding = 28,
    this.onProductTap,
  });

  final String title;
  final String subtitle;
  final List<Product> products;
  final double topPadding;
  final ValueChanged<Product>? onProductTap;

  @override
  State<HomeProductCarousel> createState() => _HomeProductCarouselState();
}

class _HomeProductCarouselState extends State<HomeProductCarousel> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scroll(double offset) {
    _scrollController.animateTo(
      (_scrollController.offset + offset).clamp(
        0,
        _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: widget.topPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _CarouselArrow(
                  icon: AppIcons.chevronLeft,
                  onTap: () => _scroll(-220),
                ),
                const SizedBox(width: 8),
                _CarouselArrow(
                  icon: AppIcons.chevronRight,
                  onTap: () => _scroll(220),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 310,
            child: ListView.separated(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              itemCount: widget.products.length,
              separatorBuilder: (context, index) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                return SizedBox(
                  width: 180,
                  child: ProductCard(
                    product: widget.products[index],
                    onTap: widget.onProductTap == null
                        ? null
                        : () => widget.onProductTap!(widget.products[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CarouselArrow extends StatelessWidget {
  const _CarouselArrow({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: AppIcon(icon, size: 24, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
