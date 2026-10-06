import 'package:flutter/material.dart';
import 'package:frip_cash/api/listings_api.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/models/product.dart';
import 'package:frip_cash/screens/create_listing_screen.dart';
import 'package:frip_cash/services/listings_repository.dart';
import 'package:frip_cash/services/mock_listing_service.dart';
import 'package:frip_cash/services/mock_session.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/utils/price_formatter.dart';
import 'package:frip_cash/utils/safe_notify.dart';
import 'package:frip_cash/widgets/empty_state_view.dart';
import 'package:frip_cash/widgets/seller_gate.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  List<Product> _listings = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    ListingsRepository.instance.addListener(_onLocalChange);
    runAfterFrame(_reload);
  }

  @override
  void dispose() {
    ListingsRepository.instance.removeListener(_onLocalChange);
    super.dispose();
  }

  void _onLocalChange() {
    if (_loading) return;
    runAfterFrame(() {
      if (mounted && !_loading) _reload();
    });
  }

  Future<void> _reload() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await ListingsRepository.instance.fetchMyListings();
      if (!mounted) return;
      setState(() {
        _listings = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
        _listings = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return SellerGate(
      child: ListenableBuilder(
        listenable: MockSession.instance,
        builder: (context, _) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.background,
              foregroundColor: AppColors.textPrimary,
              elevation: 0,
              title: Text(
                t.myListings,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loading ? null : _reload,
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const CreateListingScreen(),
                  ),
                );
                _reload();
              },
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: Text(t.add),
            ),
            body: _loading
                ? const Center(child: CircularProgressIndicator())
                : _listings.isEmpty
                    ? EmptyStateView(
                        illustration: Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: AppColors.textPrimary,
                        ),
                        title: t.noListings,
                        subtitle: _error ?? t.noListingsSubtitle,
                        actionLabel: t.createListingAction,
                        onAction: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const CreateListingScreen(),
                            ),
                          );
                          _reload();
                        },
                      )
                    : RefreshIndicator(
                        onRefresh: _reload,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                          itemCount: _listings.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return _ListingTile(
                              product: _listings[index],
                              onChanged: _reload,
                            );
                          },
                        ),
                      ),
          );
        },
      ),
    );
  }
}

class _ListingTile extends StatelessWidget {
  const _ListingTile({required this.product, required this.onChanged});

  final Product product;
  final VoidCallback onChanged;

  void _showActions(BuildContext context) {
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
                leading: const Icon(Icons.edit_outlined),
                title: Text(t.editListing),
                onTap: () async {
                  Navigator.of(context).pop();
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => CreateListingScreen(product: product),
                    ),
                  );
                  onChanged();
                },
              ),
              ListTile(
                leading: const Icon(Icons.payments_outlined),
                title: Text(t.editPrice),
                onTap: () {
                  Navigator.of(context).pop();
                  _showPriceDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_box_outlined),
                title: Text(t.addStock),
                onTap: () {
                  Navigator.of(context).pop();
                  _showStockDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.visibility_off_outlined),
                title: Text(t.vacationMode),
                onTap: () async {
                  Navigator.of(context).pop();
                  try {
                    await ListingsApi.instance.hide(product.id);
                  } catch (_) {}
                  onChanged();
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.red.shade700),
                title: Text(
                  t.delete,
                  style: TextStyle(color: Colors.red.shade700),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _confirmDelete(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPriceDialog(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final controller =
        TextEditingController(text: '${product.sellerNetPrice}');
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(t.newNetPrice),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: t.amountInGnf,
              suffixText: t.gnf,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(t.cancel),
            ),
            FilledButton(
              onPressed: () async {
                final net = int.tryParse(controller.text.trim());
                if (net == null || net < 1) return;
                try {
                  await MockListingService.instance
                      .updatePriceAsync(product.id, net);
                  if (context.mounted) Navigator.of(context).pop();
                  onChanged();
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: Text(t.save),
            ),
          ],
        );
      },
    );
  }

  void _showStockDialog(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: '1');
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(t.addStock),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: t.quantityToAdd,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(t.cancel),
            ),
            FilledButton(
              onPressed: () async {
                final amount = int.tryParse(controller.text.trim());
                if (amount == null || amount < 1) return;
                try {
                  await MockListingService.instance
                      .addStockAsync(product.id, amount);
                  if (context.mounted) Navigator.of(context).pop();
                  onChanged();
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: Text(t.add),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(t.deleteListingQuestion),
          content: Text(t.irreversibleAction),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(t.cancel),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  await MockListingService.instance
                      .deleteListingAsync(product.id);
                  if (context.mounted) Navigator.of(context).pop();
                  onChanged();
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700,
              ),
              child: Text(t.delete),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final service = MockListingService.instance;
    final views = service.viewsFor(product.id);
    final outOfStock = !product.inStock;
    final lowStock = product.isLowStock;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => _showActions(context),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (outOfStock)
                _StockBanner(
                  text: t.outOfStockInactive,
                  color: AppColors.textPrimary,
                  background: Colors.grey.shade100,
                )
              else if (lowStock)
                _StockBanner(
                  text:
                      '${t.lowStockPrefix} (${product.stock} ${t.remaining}${product.stock > 1 ? 's' : ''})',
                  color: Colors.orange.shade800,
                  background: Colors.orange.shade50,
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      product.image,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 72,
                        height: 72,
                        color: Colors.grey.shade200,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${formatPrice(product.price)} GNF · ${t.stock} ${product.stock}',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '$views ${t.views}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.isSoldOut
                              ? t.listingSoldOut
                              : t.listingActive,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: product.isSoldOut
                                ? Colors.grey.shade700
                                : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (outOfStock)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        t.outOfStock,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    )
                  else
                    Icon(Icons.more_horiz, color: AppColors.textPrimary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StockBanner extends StatelessWidget {
  const _StockBanner({
    required this.text,
    required this.color,
    required this.background,
  });

  final String text;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
