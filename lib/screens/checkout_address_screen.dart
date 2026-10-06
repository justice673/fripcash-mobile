import 'package:flutter/material.dart';
import 'package:frip_cash/api/checkout_api.dart' show CheckoutApi, DeliveryZone;
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/models/checkout_address.dart';
import 'package:frip_cash/models/fulfillment_mode.dart';
import 'package:frip_cash/screens/checkout_summary_screen.dart';
import 'package:frip_cash/services/checkout_store.dart';
import 'package:frip_cash/services/mock_session.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/widgets/auth_text_field.dart';
import 'package:frip_cash/widgets/pill_button.dart';

const _otherZoneOption = 'Autre zone';

class CheckoutAddressScreen extends StatefulWidget {
  const CheckoutAddressScreen({super.key});

  @override
  State<CheckoutAddressScreen> createState() => _CheckoutAddressScreenState();
}

class _CheckoutAddressScreenState extends State<CheckoutAddressScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _manualAddressController;
  late final TextEditingController _landmarkController;

  String? _zoneId;
  String? _quartier;
  late FulfillmentMode _fulfillmentMode;
  List<DeliveryZone> _zones = const [];
  bool _zonesLoading = true;
  String? _zonesError;

  @override
  void initState() {
    super.initState();
    final user = MockSession.instance.user;
    final checkout = CheckoutStore.instance;
    _nameController = TextEditingController(text: user.name);
    _phoneController = TextEditingController(text: user.phone);
    _manualAddressController = TextEditingController(text: user.address ?? '');
    _landmarkController = TextEditingController();
    _zoneId = user.zoneId;
    _fulfillmentMode = checkout.isProximityCheckout
        ? FulfillmentMode.pickup
        : FulfillmentMode.courier;
    _loadZones();

    for (final controller in [
      _nameController,
      _phoneController,
      _manualAddressController,
      _landmarkController,
    ]) {
      controller.addListener(() => setState(() {}));
    }
  }

  Future<void> _loadZones() async {
    setState(() {
      _zonesLoading = true;
      _zonesError = null;
    });
    try {
      final zones = await CheckoutApi.instance.fetchDeliveryZones();
      if (!mounted) return;
      setState(() {
        _zones = zones;
        _zonesLoading = false;
        if (_zoneId == null || !zones.any((z) => z.id == _zoneId)) {
          _zoneId = zones.isNotEmpty ? zones.first.id : null;
          _quartier = null;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _zones = const [];
        _zonesLoading = false;
        _zonesError = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _manualAddressController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  bool get _isProximity => CheckoutStore.instance.isProximityCheckout;

  bool get _isOtherZone => _zoneId == 'other';

  bool get _isGeoZone {
    if (_zoneId == null || _isOtherZone) return false;
    // Logical legacy ids are zone_1 / zone_2; geo cuids are longer.
    return _zoneId != 'zone_1' && _zoneId != 'zone_2';
  }

  bool get _needsDeliveryAddress =>
      !_isProximity || _fulfillmentMode == FulfillmentMode.shopLocalDelivery;

  List<String> get _quartierOptions {
    if (_zoneId == null || _isOtherZone || _isGeoZone) return const [];
    for (final z in _zones) {
      if (z.id == _zoneId) return z.quartiers;
    }
    return const [];
  }

  bool get _canContinue {
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty) {
      return false;
    }
    if (!_needsDeliveryAddress) {
      return true;
    }
    if (_zoneId == null) return false;
    if (_isOtherZone) {
      return _manualAddressController.text.trim().isNotEmpty &&
          _landmarkController.text.trim().isNotEmpty;
    }
    // Geo zones (admin tarifs matrix): zone pick is enough; street optional.
    if (_isGeoZone) return true;
    // Legacy logical zone_1 / zone_2: quartier required when listed.
    if (_quartierOptions.isEmpty) return true;
    return _quartier != null;
  }

  void _continue() {
    if (_zoneId == null && _needsDeliveryAddress) return;
    final street = _manualAddressController.text.trim();
    final address = CheckoutAddress(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      zoneId: _zoneId ?? '',
      quartier: (_isOtherZone || _isGeoZone || !_needsDeliveryAddress)
          ? null
          : _quartier,
      manualAddress: !_needsDeliveryAddress
          ? null
          : (_isOtherZone || street.isNotEmpty ? street : null),
      landmark: _isOtherZone && _needsDeliveryAddress
          ? _landmarkController.text.trim()
          : (_landmarkController.text.trim().isEmpty
              ? null
              : _landmarkController.text.trim()),
    );

    final checkout = CheckoutStore.instance;
    checkout.setFulfillmentMode(_fulfillmentMode);
    checkout.setAddress(address);
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const CheckoutSummaryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Text(
          _isProximity ? t.fulfillmentTitle : t.deliveryAddressTitle,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_isProximity) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.rosePoudre.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.storefront_outlined,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          t.proximityPickupOnlyHint,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.35,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              AuthFieldLabel(t.fullName),
              const SizedBox(height: 8),
              AuthTextField(
                controller: _nameController,
                hintText: t.yourName,
                prefixIcon: Icon(
                  Icons.person_outline,
                  color: AppColors.textPrimary,
                  size: 22,
                ),
              ),
              const SizedBox(height: 20),
              AuthFieldLabel(t.phone),
              const SizedBox(height: 8),
              AuthTextField(
                controller: _phoneController,
                hintText: t.phoneNumberHint224,
                keyboardType: TextInputType.phone,
                inputFormatters: [phoneNumberInputFormatter],
                prefixIcon: Icon(
                  Icons.phone_outlined,
                  color: AppColors.textPrimary,
                  size: 22,
                ),
              ),
              if (_needsDeliveryAddress) ...[
                const SizedBox(height: 20),
                AuthFieldLabel(t.zone),
                const SizedBox(height: 8),
                if (_zonesLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_zonesError != null && _zones.isEmpty)
                  Text(
                    _zonesError!,
                    style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                  )
                else
                  AuthDropdownField<String>(
                    value: _zoneId,
                    hintText: t.chooseYourZone,
                    items: [
                      ..._zones.map(
                        (zone) => DropdownMenuItem(
                          value: zone.id,
                          child: Text(zone.name),
                        ),
                      ),
                      // Legacy logical bands only — don't mix "other" into geo matrix.
                      if (!_zones.any((z) => z.id.length > 16) &&
                          !_zones.any((z) => z.id == 'other'))
                        const DropdownMenuItem(
                          value: 'other',
                          child: Text(_otherZoneOption),
                        ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _zoneId = value;
                        _quartier = null;
                      });
                    },
                  ),
                if (!_isOtherZone &&
                    _zoneId != null &&
                    _quartierOptions.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  AuthFieldLabel(t.neighborhood),
                  const SizedBox(height: 8),
                  AuthDropdownField<String>(
                    value: _quartier,
                    hintText: t.chooseNeighborhood,
                    items: _quartierOptions
                        .map(
                          (q) => DropdownMenuItem(value: q, child: Text(q)),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _quartier = value),
                  ),
                ],
                if (_isOtherZone || _isGeoZone) ...[
                  const SizedBox(height: 20),
                  AuthFieldLabel(t.detailedAddress),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: _manualAddressController,
                    hintText: t.streetSectorCommune,
                    prefixIcon: Icon(
                      Icons.location_on_outlined,
                      color: AppColors.textPrimary,
                      size: 22,
                    ),
                  ),
                  if (_isOtherZone) ...[
                    const SizedBox(height: 20),
                    AuthFieldLabel(t.landmark),
                    const SizedBox(height: 8),
                    AuthTextField(
                      controller: _landmarkController,
                      hintText: t.landmarkHint,
                      prefixIcon: Icon(
                        Icons.place_outlined,
                        color: AppColors.textPrimary,
                        size: 22,
                      ),
                    ),
                  ],
                ],
              ],
              const SizedBox(height: 32),
              PillPrimaryButton(
                label: t.continueAction,
                onPressed: _canContinue ? _continue : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FulfillmentTile extends StatelessWidget {
  const _FulfillmentTile({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primary.withValues(alpha: 0.08)
          : Colors.grey.shade50,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primary : Colors.grey.shade300,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: selected ? AppColors.primary : AppColors.textPrimary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: selected ? AppColors.primary : AppColors.textPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
