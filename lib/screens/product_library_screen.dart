import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frip_cash/api/listings_api.dart';
import 'package:frip_cash/api/platform_api.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/mock/mock_product_library.dart';
import 'package:frip_cash/screens/main_shell.dart';
import 'package:frip_cash/services/mock_session.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/utils/commission_calculator.dart';
import 'package:frip_cash/utils/price_formatter.dart';
import 'package:frip_cash/utils/seller_access.dart';
import 'package:frip_cash/widgets/capability_gate.dart';
import 'package:frip_cash/widgets/pill_button.dart';
import 'package:frip_cash/widgets/safe_network_image.dart';

class ProductLibraryScreen extends StatefulWidget {
  const ProductLibraryScreen({super.key, this.fromSignup = false});

  final bool fromSignup;

  @override
  State<ProductLibraryScreen> createState() => _ProductLibraryScreenState();
}

class _ProductLibraryScreenState extends State<ProductLibraryScreen> {
  final _searchController = TextEditingController();
  final Set<String> _selectedIds = {};
  final Map<String, TextEditingController> _priceControllers = {};
  final Map<String, TextEditingController> _stockControllers = {};
  final Map<String, bool> _availableFlags = {};

  String _query = '';
  List<LibraryProduct> _library = [];
  bool _loading = true;
  String? _error;
  bool _publishing = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
    _loadLibrary();
    PlatformApi.instance.fetchCommissionRates().then((_) {}, onError: (_) {});
  }

  Future<void> _loadLibrary() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await ListingsApi.instance.productLibrary();
      _library = [
        for (final row in rows)
          LibraryProduct(
            id: (row['id'] ?? row['libraryProductId'] ?? '').toString(),
            name: (row['name'] ?? row['title'] ?? '').toString(),
            imageUrl: (row['imageUrl'] ??
                    row['coverUrl'] ??
                    row['image'] ??
                    '')
                .toString(),
            unitLabel: (row['unitLabel'] ?? row['unit'] ?? '').toString(),
            defaultCategoryId:
                (row['categoryId'] ?? row['defaultCategoryId'] ?? 'grocery')
                    .toString(),
          ),
      ].where((p) => p.id.isNotEmpty).toList();
    } catch (e) {
      _library = [];
      _error = e.toString();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    for (final c in _priceControllers.values) {
      c.dispose();
    }
    for (final c in _stockControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  List<LibraryProduct> get _filtered {
    if (_query.isEmpty) return _library;
    return _library
        .where(
          (p) =>
              p.name.toLowerCase().contains(_query) ||
              p.unitLabel.toLowerCase().contains(_query),
        )
        .toList();
  }

  void _toggle(LibraryProduct product) {
    setState(() {
      if (_selectedIds.contains(product.id)) {
        _selectedIds.remove(product.id);
      } else {
        _selectedIds.add(product.id);
        _priceControllers.putIfAbsent(
          product.id,
          () => TextEditingController(),
        );
        _stockControllers.putIfAbsent(
          product.id,
          () => TextEditingController(text: '10'),
        );
        _availableFlags.putIfAbsent(product.id, () => false);
      }
    });
  }

  bool get _canPublish {
    if (_selectedIds.isEmpty || _publishing) return false;
    for (final id in _selectedIds) {
      final price = int.tryParse(
        _priceControllers[id]?.text.trim().replaceAll(' ', '') ?? '',
      );
      if (price == null || price <= 0) return false;
      final available = _availableFlags[id] == true;
      if (!available) {
        final stock = int.tryParse(_stockControllers[id]?.text.trim() ?? '');
        if (stock == null || stock < 0) return false;
      }
    }
    return true;
  }

  void _exit() {
    if (widget.fromSignup) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const MainShell()),
        (route) => false,
      );
      return;
    }
    Navigator.of(context).pop();
  }

  Future<void> _publish() async {
    if (!_canPublish) return;
    setState(() => _publishing = true);
    final items = <Map<String, dynamic>>[];
    for (final id in _selectedIds) {
      final net = int.parse(
        _priceControllers[id]!.text.trim().replaceAll(' ', ''),
      );
      final available = _availableFlags[id] == true;
      final stock = available
          ? availableStockSentinel
          : int.parse(_stockControllers[id]!.text.trim());
      items.add({
        'libraryProductId': id,
        'netPriceGnf': net,
        'stock': stock,
        'alwaysAvailable': available,
      });
    }

    var created = items.length;
    try {
      final res = await ListingsApi.instance.publishLibrary(items);
      created = (res['created'] ?? res['published'] ?? items.length) as int;
    } catch (e) {
      if (!mounted) return;
      setState(() => _publishing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!mounted) return;
    final t = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t.libraryItemsPublished(created)),
        behavior: SnackBarBehavior.floating,
      ),
    );
    setState(() => _publishing = false);
    _exit();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final items = _filtered;
    final isProximity = MockSession.instance.user.isProximityShop;
    final rates = PlatformApi.instance.cached;
    final ratePct = rates != null
        ? rates.effectivePercent.round()
        : ((isProximity ? proximityCommissionRate : commissionRate) * 100)
            .round();

    return CapabilityGate(
      allowed: canAccessProductLibrary,
      title: t.sellerOnlyAreaTitle,
      message: t.addFromLibrarySubtitle,
      child: PopScope(
        canPop: !widget.fromSignup,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && widget.fromSignup) _exit();
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: _exit,
            ),
            title: Text(
              t.productLibraryTitle,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: t.searchLibraryHint,
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  t.libraryCommissionHint(ratePct.toString()),
                  style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : items.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                _error ?? t.noListings,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          )
                        : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final product = items[index];
                          final selected = _selectedIds.contains(product.id);
                          return _LibraryTile(
                            product: product,
                            selected: selected,
                            onToggle: () => _toggle(product),
                            priceController: _priceControllers[product.id],
                            stockController: _stockControllers[product.id],
                            available: _availableFlags[product.id] ?? false,
                            onAvailableChanged: selected
                                ? (v) => setState(
                                      () => _availableFlags[product.id] = v,
                                    )
                                : null,
                            onFieldsChanged: () => setState(() {}),
                            isProximity: isProximity,
                          );
                        },
                      ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  12 + MediaQuery.paddingOf(context).bottom,
                ),
                child: PillPrimaryButton(
                  label: t.publishSelectedItems(_selectedIds.length),
                  onPressed: _canPublish ? _publish : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LibraryTile extends StatelessWidget {
  const _LibraryTile({
    required this.product,
    required this.selected,
    required this.onToggle,
    required this.priceController,
    required this.stockController,
    required this.available,
    required this.onAvailableChanged,
    required this.onFieldsChanged,
    required this.isProximity,
  });

  final LibraryProduct product;
  final bool selected;
  final VoidCallback onToggle;
  final TextEditingController? priceController;
  final TextEditingController? stockController;
  final bool available;
  final ValueChanged<bool>? onAvailableChanged;
  final VoidCallback onFieldsChanged;
  final bool isProximity;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final net = int.tryParse(
      priceController?.text.trim().replaceAll(' ', '') ?? '',
    );
    final display = net != null && net > 0
        ? displayPriceFromNet(net, isProximity: isProximity)
        : null;

    return Material(
      color: selected
          ? AppColors.primary.withValues(alpha: 0.06)
          : Colors.grey.shade50,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  Checkbox(
                    value: selected,
                    onChanged: (_) => onToggle(),
                    activeColor: AppColors.primary,
                  ),
                  SafeNetworkImage(
                    url: product.imageUrl,
                    width: 56,
                    height: 56,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          product.unitLabel,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (selected && priceController != null) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          labelText: t.netPriceLabel,
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (_) => onFieldsChanged(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: available
                          ? InputDecorator(
                              decoration: InputDecoration(
                                labelText: t.stockLabel,
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(t.availableToggle),
                            )
                          : TextField(
                              controller: stockController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                labelText: t.stockLabel,
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onChanged: (_) => onFieldsChanged(),
                            ),
                    ),
                  ],
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(t.availableToggle),
                  subtitle: Text(t.availableToggleHint),
                  value: available,
                  onChanged: onAvailableChanged,
                  activeThumbColor: AppColors.primary,
                ),
                if (display != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${t.displayPricePrefix} : ${formatPrice(display)} GNF',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
