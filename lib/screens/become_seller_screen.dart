import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:frip_cash/api/catalog_api.dart';
import 'package:frip_cash/api/me_api.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/models/delivery_perimeter.dart';
import 'package:frip_cash/models/listing_destination.dart';
import 'package:frip_cash/models/shop_category.dart';
import 'package:frip_cash/models/shop_kind.dart';
import 'package:frip_cash/screens/main_shell.dart';
import 'package:frip_cash/services/app_locale_service.dart';
import 'package:frip_cash/services/mock_session.dart';
import 'package:frip_cash/services/seller_verification_service.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_typography.dart';
import 'package:frip_cash/utils/auth_error_message.dart';
import 'package:frip_cash/utils/listing_destination_labels.dart';
import 'package:frip_cash/utils/listing_routing.dart';
import 'package:frip_cash/widgets/add_photos_sheet.dart';
import 'package:frip_cash/widgets/auth_step_actions.dart';
import 'package:frip_cash/widgets/auth_stepper.dart';
import 'package:frip_cash/widgets/auth_text_field.dart';
import 'package:frip_cash/widgets/role_illustrations.dart';
import 'package:image_picker/image_picker.dart';

/// Buyer upgrades to a seller role, or particulier applies for a boutique.
/// Same account — never a free role swap.
class BecomeSellerScreen extends StatefulWidget {
  const BecomeSellerScreen({
    super.key,
    this.initialRole,
    this.shopOnly = false,
  });

  /// Skip the role step when opened from a specific Sell-tab shortcut.
  final SignUpRole? initialRole;

  /// When true (particulier → boutique), hide the particulier option.
  final bool shopOnly;

  @override
  State<BecomeSellerScreen> createState() => _BecomeSellerScreenState();
}

class _BecomeSellerScreenState extends State<BecomeSellerScreen> {
  late SignUpRole _role;
  late int _step;

  String? _zoneId;
  String? _deliverySla;
  bool _logoSelected = false;
  Uint8List? _logoBytes;
  String? _logoFileName;
  String? _shopCategoryId;
  bool _submitting = false;
  List<CatalogZone> _apiZones = const [];
  List<ShopCategory> _shopCategories = const [];
  bool _shopCategoriesLoading = false;
  String? _shopCategoriesError;

  final _shopNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _shopDescriptionController = TextEditingController();

  static const _particulierSlaOptions = ['24h', '48h'];
  static const _boutiqueSlaOptions = ['24h', '48h', '72h', '1 semaine'];

  @override
  void initState() {
    super.initState();
    final user = MockSession.instance.user;
    var role = widget.initialRole ??
        (widget.shopOnly ? SignUpRole.boutique : SignUpRole.particulier);
    if (widget.shopOnly && !role.isShopProfile) {
      role = SignUpRole.boutique;
    }
    _role = role;
    _step = widget.initialRole != null ? 1 : 0;
    // Prefer real catalog zone ids — mock `zone_1` is rejected by Nest.
    final existingZone = user.zoneId;
    if (existingZone != null &&
        existingZone.isNotEmpty &&
        !existingZone.startsWith('zone_')) {
      _zoneId = existingZone;
    }
    _addressController.text = user.address ?? '';
    _shopNameController.text = user.shopName ?? user.name;
    for (final controller in [
      _shopNameController,
      _addressController,
      _shopDescriptionController,
    ]) {
      controller.addListener(() => setState(() {}));
    }
    _loadZones();
    _loadShopCategories();
  }

  Future<void> _loadZones() async {
    try {
      final zones = await MeApi.instance.fetchZones();
      if (!mounted || zones.isEmpty) return;
      setState(() {
        _apiZones = zones;
        if (_zoneId != null && !zones.any((z) => z.id == _zoneId)) {
          _zoneId = null;
        }
      });
    } catch (_) {
      // Keep empty until zones load successfully.
    }
  }

  Future<void> _loadShopCategories() async {
    setState(() {
      _shopCategoriesLoading = true;
      _shopCategoriesError = null;
    });
    try {
      final items = await CatalogApi.instance.fetchShopCategories();
      if (!mounted) return;
      setState(() {
        _shopCategories = items;
        _shopCategoriesLoading = false;
        if (_shopCategoryId != null &&
            !items.any((c) => c.id == _shopCategoryId)) {
          _shopCategoryId = null;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _shopCategories = const [];
        _shopCategoriesLoading = false;
        _shopCategoriesError = e.toString();
      });
    }
  }

  List<DropdownMenuItem<String>> get _zoneDropdownItems {
    final french = AppLocaleService.instance.locale?.languageCode != 'en';
    return [
      for (final zone in _apiZones)
        DropdownMenuItem(
          value: zone.id,
          child: Text(zone.label(french: french)),
        ),
    ];
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _addressController.dispose();
    _shopDescriptionController.dispose();
    super.dispose();
  }

  bool get _isShop => _role.isShopProfile;

  ShopKind get _resolvedShopKind =>
      _role.shopKindFor(_effectivePerimeter) ?? ShopKind.standard;

  DeliveryPerimeter? get _effectivePerimeter => _role.defaultPerimeter;

  bool get _isProximityCommerce => _resolvedShopKind == ShopKind.proximite;

  int get _totalSteps => 2;

  List<String> get _slaOptions =>
      _isShop ? _boutiqueSlaOptions : _particulierSlaOptions;

  ListingDestination get _destination => listingDestinationForSignUpRole(_role);

  bool get _particulierDetailsValid =>
      _apiZones.isNotEmpty &&
      _zoneId != null &&
      _addressController.text.trim().isNotEmpty &&
      _deliverySla != null;

  bool get _shopDetailsValid {
    if (_apiZones.isEmpty) return false;
    if (_zoneId == null || _addressController.text.trim().isEmpty) return false;
    if (_logoBytes == null || _shopDescriptionController.text.trim().isEmpty) {
      return false;
    }
    if (_role.isGrandeSurface) return _deliverySla != null;
    if (_shopNameController.text.trim().isEmpty) return false;
    if (_isProximityCommerce) {
      return _shopCategoryId != null && _shopCategories.isNotEmpty;
    }
    return _deliverySla != null;
  }

  bool get _canSubmit =>
      !_submitting &&
      (_role == SignUpRole.particulier
          ? _particulierDetailsValid
          : _shopDetailsValid);

  void _onRoleChanged(SignUpRole role) {
    setState(() {
      _role = role;
      _shopCategoryId = null;
      if (!_slaOptions.contains(_deliverySla)) {
        _deliverySla = null;
      }
      final maxStep = _totalSteps - 1;
      if (_step > maxStep) _step = maxStep;
    });
  }

  void _goToStep(int step) {
    setState(() => _step = step.clamp(0, _totalSteps - 1));
  }

  void _goBack() {
    if (_step <= 0) {
      Navigator.of(context).pop();
      return;
    }
    _goToStep(_step - 1);
  }

  void _continueFromRole() => _goToStep(1);

  Future<void> _pickLogo() async {
    final picked = await showAddPhotosSheet(context, maxPhotos: 1);
    if (picked == null || picked.isEmpty) return;
    final XFile file = picked.first;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() {
      _logoBytes = bytes;
      _logoFileName = file.name;
      _logoSelected = true;
    });
  }

  Future<void> _submit() async {
    final t = AppLocalizations.of(context)!;
    setState(() => _submitting = true);
    try {
      if (_role == SignUpRole.particulier) {
        await MockSession.instance.becomeParticulierSeller(
          zoneId: _zoneId!,
          address: _addressController.text.trim(),
          deliverySla: _deliverySla!,
        );
      } else {
        await MockSession.instance.becomeShopSeller(
          signupPath: _role.signupPath,
          shopName: _shopNameController.text.trim().isEmpty
              ? MockSession.instance.user.name
              : _shopNameController.text.trim(),
          zoneId: _zoneId!,
          address: _addressController.text.trim(),
          shopKind: _resolvedShopKind,
          deliverySla: _isProximityCommerce ? null : _deliverySla,
          shopCategoryId: _shopCategoryId,
          shopDescription: _shopDescriptionController.text.trim(),
          logoBytes: _logoBytes,
          logoFileName: _logoFileName,
        );
      }

      if (!mounted) return;
      final pending = MockSession.instance.me?.isVerificationPending == true ||
          (_role.requiresManualValidation &&
              SellerVerificationService.instance.requiresManualReview(
                MockSession.instance.user.sellerId,
              ));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            pending
                ? t.sellerPendingVerificationMessage
                : t.becomeSellerSuccess,
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const MainShell()),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authErrorMessage(e)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final destinationLabel = listingDestinationLabel(_destination, t);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          widget.shopOnly ? t.createShop : t.becomeSellerTitle,
          style: AppTypography.style(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            widget.shopOnly
                ? t.upgradeToShopSubtitle
                : t.addSellerProfileSubtitle,
            style: AppTypography.style(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          AuthStepper(
            currentStep: _step,
            steps: [
              AuthStepperStep(
                title: t.becomeSellerStepTypeTitle,
                subtitle: t.becomeSellerStepTypeSubtitle,
              ),
              AuthStepperStep(
                title: t.becomeSellerStepDetailsTitle,
                subtitle: t.becomeSellerStepDetailsSubtitle,
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_step == 0) ..._buildRoleStep(t),
          if (_step == 1) ..._buildDetailsStep(t, destinationLabel),
        ],
      ),
    );
  }

  List<Widget> _buildRoleStep(AppLocalizations t) {
    return [
      AuthFieldLabel(
        widget.shopOnly ? t.upgradeToShopChooseType : t.becomeSellerChooseType,
      ),
      const SizedBox(height: 10),
      if (!widget.shopOnly) ...[
        _SellerRoleCard(
          selected: _role == SignUpRole.particulier,
          illustration: RoleIllustrations.seller,
          title: t.individualSellerRole,
          subtitle: t.signUpRoleSellerSubtitle,
          footnote: t.signUpRoleSellerFootnote,
          onTap: () => _onRoleChanged(SignUpRole.particulier),
        ),
        const SizedBox(height: 12),
      ],
      _SellerRoleCard(
        selected: _role == SignUpRole.boutique,
        illustration: RoleIllustrations.shop,
        title: t.shopRole,
        subtitle: t.signUpRoleShopSubtitle,
        footnote: t.signUpRoleShopFootnote,
        onTap: () => _onRoleChanged(SignUpRole.boutique),
      ),
      const SizedBox(height: 12),
      _SellerRoleCard(
        selected: _role == SignUpRole.commerceLocal,
        illustration: RoleIllustrations.enseigne,
        title: t.commerceLocalRole,
        subtitle: t.signUpRoleCommerceLocalSubtitle,
        footnote: t.signUpRoleCommerceLocalFootnote,
        onTap: () => _onRoleChanged(SignUpRole.commerceLocal),
      ),
      const SizedBox(height: 12),
      _SellerRoleCard(
        selected: _role == SignUpRole.grandeSurface,
        illustration: RoleIllustrations.grandeSurface,
        title: t.grandeSurfaceRole,
        subtitle: t.signUpRoleGrandeSurfaceSubtitle,
        footnote: t.signUpRoleGrandeSurfaceFootnote,
        onTap: () => _onRoleChanged(SignUpRole.grandeSurface),
      ),
      const SizedBox(height: 28),
      AuthStepActions(
        onBack: _goBack,
        primaryLabel: t.signUpContinue,
        onPrimary: _continueFromRole,
      ),
    ];
  }

  List<Widget> _buildDetailsStep(
    AppLocalizations t,
    String destinationLabel,
  ) {
    return [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Text(
          t.becomeSellerDestinationHint(destinationLabel),
          style: AppTypography.style(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
            height: 1.35,
          ),
        ),
      ),
      const SizedBox(height: 20),
      if (_role == SignUpRole.particulier) ..._buildParticulierFields(t),
      if (_isShop) ..._buildShopFields(t),
      const SizedBox(height: 28),
      AuthStepActions(
        onBack: _goBack,
        primaryLabel: t.becomeSellerActivate,
        onPrimary: _canSubmit ? _submit : null,
      ),
    ];
  }

  List<Widget> _buildParticulierFields(AppLocalizations t) {
    return [
      AuthFieldLabel(t.zone),
      const SizedBox(height: 8),
      AuthDropdownField<String>(
        value: _zoneId,
        hintText: t.chooseYourZone,
        items: _zoneDropdownItems,
        onChanged: (value) => setState(() => _zoneId = value),
      ),
      const SizedBox(height: 20),
      AuthFieldLabel(t.detailedAddress),
      const SizedBox(height: 8),
      AuthTextField(
        controller: _addressController,
        hintText: t.addressHint,
        prefixIcon: Icon(
          Icons.location_on_outlined,
          color: AppColors.textPrimary,
          size: 22,
        ),
      ),
      const SizedBox(height: 20),
      AuthFieldLabel(t.maxDeliveryDelay),
      const SizedBox(height: 8),
      AuthDropdownField<String>(
        value: _deliverySla,
        hintText: t.chooseDelay,
        items: [
          for (final sla in _slaOptions)
            DropdownMenuItem(value: sla, child: Text(sla)),
        ],
        onChanged: (value) => setState(() => _deliverySla = value),
      ),
    ];
  }

  List<Widget> _buildShopFields(AppLocalizations t) {
    return [
      if (!_role.isGrandeSurface) ...[
        AuthFieldLabel(t.shopNameLabel),
        const SizedBox(height: 8),
        AuthTextField(
          controller: _shopNameController,
          hintText: t.shopNameHint,
          prefixIcon: Icon(
            Icons.store_outlined,
            color: AppColors.textPrimary,
            size: 22,
          ),
        ),
        const SizedBox(height: 20),
      ],
      AuthFieldLabel(t.zone),
      const SizedBox(height: 8),
      AuthDropdownField<String>(
        value: _zoneId,
        hintText: t.chooseYourZone,
        items: _zoneDropdownItems,
        onChanged: (value) => setState(() => _zoneId = value),
      ),
      const SizedBox(height: 20),
      AuthFieldLabel(t.detailedAddress),
      const SizedBox(height: 8),
      AuthTextField(
        controller: _addressController,
        hintText: t.addressHint,
        prefixIcon: Icon(
          Icons.location_on_outlined,
          color: AppColors.textPrimary,
          size: 22,
        ),
      ),
      if (_isProximityCommerce) ...[
        const SizedBox(height: 20),
        AuthFieldLabel(t.shopCategoryLabel),
        const SizedBox(height: 8),
        if (_shopCategoriesLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else if (_shopCategories.isEmpty) ...[
          Text(
            _shopCategoriesError != null
                ? 'Impossible de charger les catégories. Réessaie.'
                : 'Aucune catégorie disponible.',
            style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _loadShopCategories,
            child: const Text('Réessayer'),
          ),
        ] else
          AuthDropdownField<String>(
            value: _shopCategoryId,
            hintText: t.chooseShopCategory,
            items: [
              for (final c in _shopCategories)
                DropdownMenuItem(
                  value: c.id,
                  child: Text(
                    c.labelForLocale(
                      Localizations.localeOf(context).languageCode,
                    ),
                  ),
                ),
            ],
            onChanged: (value) => setState(() => _shopCategoryId = value),
          ),
      ] else ...[
        const SizedBox(height: 20),
        AuthFieldLabel(t.maxDeliveryDelay),
        const SizedBox(height: 8),
        AuthDropdownField<String>(
          value: _deliverySla,
          hintText: t.chooseDelay,
          items: [
            for (final sla in _slaOptions)
              DropdownMenuItem(value: sla, child: Text(sla)),
          ],
          onChanged: (value) => setState(() => _deliverySla = value),
        ),
      ],
      const SizedBox(height: 20),
      AuthFieldLabel(t.shopLogo),
      const SizedBox(height: 8),
      InkWell(
        onTap: _pickLogo,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              if (_logoBytes != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    _logoBytes!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Icon(
                  Icons.add_photo_alternate_outlined,
                  color: AppColors.textPrimary,
                  size: 28,
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _logoSelected ? t.logoAddedPreview : t.addLogo,
                      style: AppTypography.style(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _logoSelected
                          ? (_logoFileName ?? t.uploadPhotos)
                          : '${t.uploadPhotos} · ${t.cameraLabel}',
                      style: AppTypography.style(
                        fontSize: 12,
                        color: AppColors.textPrimary.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                _logoSelected ? Icons.check_circle : Icons.chevron_right,
                color: _logoSelected
                    ? AppColors.primary
                    : AppColors.textPrimary.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 20),
      AuthFieldLabel(t.shopDescription),
      const SizedBox(height: 8),
      AuthTextField(
        controller: _shopDescriptionController,
        hintText: t.describeBusiness,
        minLines: 5,
        maxLines: 8,
      ),
    ];
  }
}
class _SellerRoleCard extends StatelessWidget {
  const _SellerRoleCard({
    required this.selected,
    required this.illustration,
    required this.title,
    required this.subtitle,
    this.footnote,
    required this.onTap,
  });

  final bool selected;
  final Widget illustration;
  final String title;
  final String subtitle;
  final String? footnote;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primary.withValues(alpha: 0.07)
          : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primary : const Color(0xFFE6E6E6),
              width: selected ? 1.8 : 1.2,
            ),
          ),
          child: Row(
            children: [
              illustration,
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color:
                            selected ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: AppTypography.style(
                        fontSize: 12,
                        height: 1.35,
                        color: AppColors.textPrimary.withValues(alpha: 0.62),
                      ),
                    ),
                    if (footnote != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        footnote!,
                        style: TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          height: 1.3,
                          color: AppColors.textPrimary.withValues(alpha: 0.45),
                          fontFamily: AppTypography.fontFamily,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (selected)
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
