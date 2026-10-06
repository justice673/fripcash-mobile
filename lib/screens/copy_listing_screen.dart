import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/mock/mock_users.dart';
import 'package:frip_cash/models/product.dart';
import 'package:frip_cash/screens/create_listing_screen.dart';
import 'package:frip_cash/services/listings_repository.dart';
import 'package:frip_cash/services/mock_listing_service.dart';
import 'package:frip_cash/services/mock_session.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/widgets/safe_network_image.dart';
import 'package:frip_cash/widgets/sell_empty_illustrations.dart';

/// Pick an existing listing to duplicate into a **new** draft via API copy.
class CopyListingScreen extends StatefulWidget {
  const CopyListingScreen({super.key});

  @override
  State<CopyListingScreen> createState() => _CopyListingScreenState();
}

class _CopyListingScreenState extends State<CopyListingScreen> {
  bool _grid = false;
  bool _loading = true;
  String? _error;
  List<Product> _listings = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = MockSession.instance.user;
    if (!user.role.isSeller) {
      setState(() {
        _listings = [];
        _loading = false;
        _error = null;
      });
      return;
    }
    try {
      final items = await ListingsRepository.instance.fetchMyListings();
      if (!mounted) return;
      setState(() {
        _listings = items;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _listings = [];
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _openCopy(Product product) async {
    try {
      final draft =
          await MockListingService.instance.copyListingAsync(product.id);
      if (!mounted) return;
      if (draft == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.noListings),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => CreateListingScreen(product: draft),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          t.copyAListing,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        actions: [
          IconButton(
            icon: Icon(_grid ? Icons.view_list_outlined : Icons.grid_view_outlined),
            onPressed: () => setState(() => _grid = !_grid),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _listings.isEmpty
              ? _CopyEmptyState(error: _error)
              : _grid
                  ? GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.78,
                      ),
                      itemCount: _listings.length,
                      itemBuilder: (context, index) {
                        final product = _listings[index];
                        return _CopyGridTile(
                          product: product,
                          onTap: () => _openCopy(product),
                        );
                      },
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: _listings.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final product = _listings[index];
                        return _CopyListTile(
                          product: product,
                          onTap: () => _openCopy(product),
                        );
                      },
                    ),
    );
  }
}

class _CopyListTile extends StatelessWidget {
  const _CopyListTile({required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF7F7F7),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SafeNetworkImage(
                  url: product.image,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  iconSize: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _CopyGridTile extends StatelessWidget {
  const _CopyGridTile({required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF7F7F7),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SafeNetworkImage(
                    url: product.image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CopyEmptyState extends StatelessWidget {
  const _CopyEmptyState({this.error});

  final String? error;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SellEmptyIllustrations.copy,
            const SizedBox(height: 16),
            Text(
              error ?? t.noListings,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary.withValues(alpha: 0.65),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
