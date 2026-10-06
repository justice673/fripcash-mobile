import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frip_cash/api/api_client.dart';
import 'package:frip_cash/api/listings_api.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/widgets/pill_button.dart';

class BundleDiscountScreen extends StatefulWidget {
  const BundleDiscountScreen({super.key});

  @override
  State<BundleDiscountScreen> createState() => _BundleDiscountScreenState();
}

class _BundleDiscountScreenState extends State<BundleDiscountScreen> {
  bool _enabled = false;
  late final TextEditingController _minItemsController;
  late final TextEditingController _percentController;
  String? _error;
  bool _loading = true;
  bool _saving = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _minItemsController = TextEditingController();
    _percentController = TextEditingController();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final b = await ListingsApi.instance.fetchBundles();
      if (!mounted) return;
      setState(() {
        _enabled = b.enabled;
        _minItemsController.text = b.minItems.toString();
        _percentController.text = b.discountPercent.toString();
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _minItemsController.dispose();
    _percentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final t = AppLocalizations.of(context);
    final minItems = int.tryParse(_minItemsController.text.trim());
    final percent = int.tryParse(_percentController.text.trim());

    if (_enabled) {
      if (minItems == null || minItems < 2 || minItems > 20) {
        setState(() => _error = t.bundleMinItemsInvalid);
        return;
      }
      if (percent == null || percent < 1 || percent > 50) {
        setState(() => _error = t.bundlePercentInvalid);
        return;
      }
    } else if (minItems == null || percent == null) {
      setState(() => _error = t.bundleMinItemsInvalid);
      return;
    }

    setState(() {
      _error = null;
      _saving = true;
    });
    try {
      final saved = await ListingsApi.instance.putBundles(
        enabled: _enabled,
        minItems: minItems!,
        discountPercent: percent!,
      );
      if (!mounted) return;
      setState(() {
        _enabled = saved.enabled;
        _minItemsController.text = saved.minItems.toString();
        _percentController.text = saved.discountPercent.toString();
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.bundleRuleSavedLocal),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _saving = false;
      });
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final minPreview = int.tryParse(_minItemsController.text.trim()) ?? 0;
    final pctPreview = int.tryParse(_percentController.text.trim()) ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Text(
          t.bundleDiscount,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_loadError!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        TextButton(onPressed: _load, child: Text(t.retryAction)),
                      ],
                    ),
                  ),
                )
              : SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          children: [
                            Text(
                              t.bundleDiscountDescription,
                              style: TextStyle(
                                fontSize: 15,
                                color: AppColors.textPrimary,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 20),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                t.bundleDiscount,
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle:
                                  Text(_enabled ? t.enabled : t.disabled),
                              value: _enabled,
                              activeThumbColor: AppColors.primary,
                              onChanged: _saving
                                  ? null
                                  : (v) => setState(() {
                                        _enabled = v;
                                        _error = null;
                                      }),
                            ),
                            if (_enabled) ...[
                              const SizedBox(height: 8),
                              Text(
                                t.bundleMinItemsLabel,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _minItemsController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onChanged: (_) =>
                                    setState(() => _error = null),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  helperText: t.bundleMinItemsHelper,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                t.bundlePercentLabel,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _percentController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onChanged: (_) =>
                                    setState(() => _error = null),
                                decoration: InputDecoration(
                                  suffixText: '%',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  helperText: t.bundlePercentHelper,
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (minPreview >= 2 && pctPreview >= 1)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    t.bundleRulePreview(
                                        pctPreview, minPreview),
                                    style: const TextStyle(
                                        fontSize: 14, height: 1.35),
                                  ),
                                ),
                            ],
                            if (_error != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                _error!,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: PillPrimaryButton(
                          label: _saving ? '…' : t.save,
                          onPressed: _saving ? null : _save,
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
