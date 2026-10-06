import 'dart:typed_data';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:frip_cash/api/catalog_api.dart';
import 'package:frip_cash/api/me_api.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/models/delivery_perimeter.dart';
import 'package:frip_cash/models/shop_category.dart';
import 'package:frip_cash/models/shop_kind.dart';
import 'package:frip_cash/screens/help_screen.dart';
import 'package:frip_cash/screens/login_screen.dart';
import 'package:frip_cash/screens/otp_verification_screen.dart';
import 'package:frip_cash/services/app_locale_service.dart';
import 'package:frip_cash/services/mock_session.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_typography.dart';
import 'package:frip_cash/utils/auth_error_message.dart';
import 'package:frip_cash/widgets/add_photos_sheet.dart';
import 'package:frip_cash/widgets/auth_step_actions.dart';
import 'package:frip_cash/widgets/auth_stepper.dart';
import 'package:frip_cash/widgets/auth_text_field.dart';
import 'package:frip_cash/widgets/consent_checkboxes.dart';
import 'package:frip_cash/widgets/password_strength_meter.dart';
import 'package:frip_cash/widgets/role_illustrations.dart';
import 'package:frip_cash/widgets/tablet_constrained_content.dart';
import 'package:image_picker/image_picker.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addressController = TextEditingController();
  final _shopDescriptionController = TextEditingController();

  int _step = 0;
  SignUpRole _role = SignUpRole.acheteur;
  String? _zoneId;
  String? _deliverySla;
  bool _logoSelected = false;
  Uint8List? _logoBytes;
  String? _logoFileName;
  /// Selected proximity shop category **CUID** (not FR label).
  String? _shopCategoryId;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _marketingAccepted = false;
  bool _termsAccepted = false;
  bool _submitting = false;
  List<CatalogZone> _apiZones = const [];
  List<ShopCategory> _shopCategories = const [];
  bool _shopCategoriesLoading = false;
  String? _shopCategoriesError;

  static const _particulierSlaOptions = ['24h', '48h'];
  static const _boutiqueSlaOptions = ['24h', '48h', '72h', '1 semaine'];

  @override
  void initState() {
    super.initState();
    for (final controller in [
      _nameController,
      _phoneController,
      _passwordController,
      _confirmPasswordController,
      _addressController,
      _shopDescriptionController,
    ]) {
      controller.addListener(_onFormChanged);
    }
    _loadZones();
    _loadShopCategories();
  }

  Future<void> _loadZones() async {
    try {
      final zones = await MeApi.instance.fetchZones();
      if (!mounted || zones.isEmpty) return;
      setState(() => _apiZones = zones);
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

  void _onFormChanged() => setState(() {});

  @override
  void dispose() {
    for (final controller in [
      _nameController,
      _phoneController,
      _passwordController,
      _confirmPasswordController,
      _addressController,
      _shopDescriptionController,
    ]) {
      controller.removeListener(_onFormChanged);
      controller.dispose();
    }
    super.dispose();
  }

  bool get _isShop => _role.isShopProfile;

  ShopKind get _resolvedShopKind =>
      _role.shopKindFor(_effectivePerimeter) ?? ShopKind.standard;

  DeliveryPerimeter? get _effectivePerimeter => _role.defaultPerimeter;

  bool get _isProximityCommerce =>
      _resolvedShopKind == ShopKind.proximite;

  bool get _isSeller =>
      _role == SignUpRole.particulier || _role.isShopProfile;

  static const _passwordMinLength = 8;

  bool get _passwordsMatch =>
      _passwordController.text == _confirmPasswordController.text;

  bool get _showPasswordMismatch =>
      _confirmPasswordController.text.isNotEmpty && !_passwordsMatch;

  bool get _passwordLongEnough =>
      _passwordController.text.length >= _passwordMinLength;

  bool get _sellerFieldsValid {
    if (!_isSeller) return true;
    if (_zoneId == null || _addressController.text.trim().isEmpty) {
      return false;
    }
    if (_isShop) {
      if (_isProximityCommerce) {
        return _shopDescriptionController.text.trim().isNotEmpty &&
            _logoSelected &&
            _shopCategoryId != null &&
            _shopCategories.isNotEmpty;
      }
      return _shopDescriptionController.text.trim().isNotEmpty &&
          _logoSelected &&
          _deliverySla != null;
    }
    if (_deliverySla == null) return false;
    return true;
  }

  bool get _accountFieldsValid =>
      _nameController.text.trim().isNotEmpty &&
      _phoneController.text.trim().isNotEmpty &&
      _passwordLongEnough &&
      _confirmPasswordController.text.isNotEmpty &&
      _passwordsMatch;

  bool get _canSubmit =>
      !_submitting &&
      _termsAccepted &&
      _accountFieldsValid &&
      _sellerFieldsValid;

  int get _totalSteps => _isShop ? 3 : (_isSeller ? 3 : 2);

  List<String> get _slaOptions =>
      _isShop ? _boutiqueSlaOptions : _particulierSlaOptions;

  void _openLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
    );
  }

  void _onRoleChanged(SignUpRole role) {
    setState(() {
      _role = role;
      _shopCategoryId = null;
      if (!_slaOptions.contains(_deliverySla)) {
        _deliverySla = null;
      }
      final maxStep = role.isShopProfile || role == SignUpRole.particulier
          ? 2
          : 1;
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

  Future<void> _submitSignUp() async {
    final shopKind = _resolvedShopKind;
    final phone = _phoneController.text.trim();
    final locale =
        AppLocaleService.instance.locale?.languageCode == 'en' ? 'en' : 'fr';

    MockSession.instance.setRegistrationDraft(
      RegistrationDraft(
        signupPath: _role.signupPath,
        role: _role.userRole,
        name: _nameController.text.trim(),
        phone: phone,
        password: _passwordController.text,
        termsAccepted: _termsAccepted,
        marketingOptIn: _marketingAccepted,
        locale: locale,
        zoneId: _zoneId,
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        deliverySla: _isShop && shopKind == ShopKind.proximite
            ? null
            : _deliverySla,
        shopName: _isShop ? _nameController.text.trim() : null,
        shopDescription:
            _isShop ? _shopDescriptionController.text.trim() : null,
        shopKind: _isShop ? shopKind : null,
        shopCategory: _isShop && shopKind == ShopKind.proximite
            ? _shopCategoryId
            : null,
        logoBytes: _logoBytes,
        logoFileName: _logoFileName,
      ),
    );

    setState(() => _submitting = true);
    try {
      await MockSession.instance.requestOtp(
        phone: phone,
        purpose: 'register',
      );
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => OtpVerificationScreen(
            phoneNumber: phone,
            purpose: OtpPurpose.signUp,
          ),
        ),
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
    final nameLabel = _isShop ? t.shopNameLabel : t.nameLabel;
    final nameHint = _isShop ? t.shopNameHint : t.fullNameHint;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: TabletAuthScrollBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                t.joinFripCash,
                style: AppTypography.display(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t.signUpSubtitle,
                style: AppTypography.style(
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              AuthStepper(
                currentStep: _step,
                steps: _isShop
                    ? [
                        AuthStepperStep(
                          title: t.signUpStepAccountTitle,
                          subtitle: t.signUpStepAccountSubtitle,
                        ),
                        AuthStepperStep(
                          title: t.signUpStepLoginTitle,
                          subtitle: t.signUpStepLoginSubtitle,
                        ),
                        AuthStepperStep(
                          title: t.signUpStepInfosTitle,
                          subtitle: t.signUpStepInfosSubtitle,
                        ),
                      ]
                    : _isSeller
                        ? [
                            AuthStepperStep(
                              title: t.signUpStepAccountTitle,
                              subtitle: t.signUpStepAccountSubtitle,
                            ),
                            AuthStepperStep(
                              title: t.signUpStepLoginTitle,
                              subtitle: t.signUpStepLoginSubtitle,
                            ),
                            AuthStepperStep(
                              title: t.signUpStepSellerTitle,
                              subtitle: t.signUpStepSellerSubtitle,
                            ),
                          ]
                        : [
                            AuthStepperStep(
                              title: t.signUpStepAccountTitle,
                              subtitle: t.signUpStepAccountSubtitle,
                            ),
                            AuthStepperStep(
                              title: t.signUpStepProfileTitle,
                              subtitle: t.signUpStepProfileSubtitle,
                            ),
                          ],
              ),
              const SizedBox(height: 28),
              if (_step == 0)
                ..._buildRoleStep(t)
              else if (_isShop && _step == 1)
                ..._buildAccountStep(
                  t: t,
                  nameLabel: t.shopNameLabel,
                  nameHint: t.shopNameHint,
                )
              else if (_isSeller && _step == 1)
                ..._buildAccountStep(
                  t: t,
                  nameLabel: nameLabel,
                  nameHint: nameHint,
                )
              else if (_isShop && _step == 2)
                ...(_role.isGrandeSurface
                    ? _buildGrandeSurfaceDetailsStep(t)
                    : _buildShopInfosStep(t))
              else if (_isSeller && _step == 2)
                ..._buildIndividualSellerDetailsStep(t)
              else
                ..._buildBuyerDetailsStep(
                  t: t,
                  nameLabel: nameLabel,
                  nameHint: nameHint,
                ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const HelpScreen(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    t.needHelp,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                      fontFamily: AppTypography.fontFamily,
                    ),
                    children: [
                      TextSpan(text: t.alreadyHaveAccountPrompt),
                      TextSpan(
                        text: t.signIn,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = _openLogin,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRoleStep(AppLocalizations t) {
    return [
      AuthFieldLabel(t.iSignUpAs),
      const SizedBox(height: 10),
      _RoleSelector(role: _role, onChanged: _onRoleChanged),
      const SizedBox(height: 28),
      AuthStepActions(
        onBack: _goBack,
        primaryLabel: t.signUpContinue,
        onPrimary: () => _goToStep(1),
      ),
    ];
  }

  List<Widget> _buildPasswordFields(AppLocalizations t) {
    return [
      AuthFieldLabel(t.password),
      const SizedBox(height: 8),
      AuthTextField(
        controller: _passwordController,
        hintText: t.choosePassword,
        obscureText: _obscurePassword,
        prefixIcon: Icon(
          Icons.lock_outline,
          color: AppColors.textPrimary,
          size: 22,
        ),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: AppColors.textPrimary,
            size: 22,
          ),
        ),
      ),
      PasswordStrengthMeter(
        password: _passwordController.text,
        minLength: _passwordMinLength,
      ),
      const SizedBox(height: 20),
      AuthFieldLabel(t.confirmPassword),
      const SizedBox(height: 8),
      AuthTextField(
        controller: _confirmPasswordController,
        hintText: t.confirmYourPassword,
        obscureText: _obscureConfirmPassword,
        prefixIcon: Icon(
          Icons.lock_outline,
          color: AppColors.textPrimary,
          size: 22,
        ),
        suffixIcon: IconButton(
          onPressed: () {
            setState(
              () => _obscureConfirmPassword = !_obscureConfirmPassword,
            );
          },
          icon: Icon(
            _obscureConfirmPassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: AppColors.textPrimary,
            size: 22,
          ),
        ),
      ),
      if (_showPasswordMismatch) ...[
        const SizedBox(height: 8),
        Text(
          t.passwordsDoNotMatch,
          style: TextStyle(
            fontSize: 13,
            color: Colors.red.shade600,
          ),
        ),
      ],
    ];
  }

  List<Widget> _buildConsentBlock(AppLocalizations t) {
    return [
      ConsentCheckboxes(
        marketingAccepted: _marketingAccepted,
        termsAccepted: _termsAccepted,
        onMarketingChanged: (value) {
          setState(() => _marketingAccepted = value);
        },
        onTermsChanged: (value) {
          setState(() => _termsAccepted = value);
        },
        onTermsTap: () {},
        onPrivacyTap: () {},
      ),
    ];
  }

  /// Seller step 2: name / phone / passwords.
  List<Widget> _buildAccountStep({
    required AppLocalizations t,
    required String nameLabel,
    required String nameHint,
  }) {
    return [
      AuthFieldLabel(nameLabel),
      const SizedBox(height: 8),
      AuthTextField(
        controller: _nameController,
        hintText: nameHint,
        prefixIcon: Icon(
          _isShop ? Icons.store_outlined : Icons.person_outline,
          color: AppColors.textPrimary,
          size: 22,
        ),
      ),
      const SizedBox(height: 20),
      AuthFieldLabel(t.phoneNumber),
      const SizedBox(height: 8),
      PhoneNumberField(controller: _phoneController),
      const SizedBox(height: 20),
      ..._buildPasswordFields(t),
      const SizedBox(height: 28),
      AuthStepActions(
        onBack: _goBack,
        primaryLabel: t.signUpContinue,
        onPrimary: _accountFieldsValid ? () => _goToStep(2) : null,
      ),
    ];
  }

  /// Individual seller step 3: zone / address / SLA + consents.
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

  List<Widget> _buildIndividualSellerDetailsStep(AppLocalizations t) {
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
        items: _slaOptions
            .map(
              (sla) => DropdownMenuItem(
                value: sla,
                child: Text(sla),
              ),
            )
            .toList(),
        onChanged: (value) => setState(() => _deliverySla = value),
      ),
      const SizedBox(height: 28),
      ..._buildConsentBlock(t),
      const SizedBox(height: 28),
      AuthStepActions(
        onBack: _goBack,
        primaryLabel: t.signUp,
        onPrimary: _canSubmit ? _submitSignUp : null,
      ),
    ];
  }

  List<Widget> _buildShopInfosStep(AppLocalizations t) {
    return [
      AuthFieldLabel(t.shopNameLabel),
      const SizedBox(height: 8),
      AuthTextField(
        controller: _nameController,
        hintText: t.shopNameHint,
        prefixIcon: Icon(
          Icons.store_outlined,
          color: AppColors.textPrimary,
          size: 22,
        ),
      ),
      const SizedBox(height: 20),
      AuthFieldLabel(t.phoneNumber),
      const SizedBox(height: 8),
      PhoneNumberField(controller: _phoneController),
      const SizedBox(height: 20),
      ..._buildPasswordFields(t),
      const SizedBox(height: 20),
      ..._buildShopLocationFields(t),
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
          items: _slaOptions
              .map(
                (sla) => DropdownMenuItem(
                  value: sla,
                  child: Text(sla),
                ),
              )
              .toList(),
          onChanged: (value) => setState(() => _deliverySla = value),
        ),
      ],
      const SizedBox(height: 20),
      ..._buildShopBrandFields(t),
      const SizedBox(height: 28),
      ..._buildConsentBlock(t),
      const SizedBox(height: 28),
      AuthStepActions(
        onBack: _goBack,
        primaryLabel: t.signUp,
        onPrimary: _canSubmit ? _submitSignUp : null,
      ),
    ];
  }

  List<Widget> _buildGrandeSurfaceDetailsStep(AppLocalizations t) {
    return [
      ..._buildShopLocationFields(t),
      const SizedBox(height: 20),
      AuthFieldLabel(t.maxDeliveryDelay),
      const SizedBox(height: 8),
      AuthDropdownField<String>(
        value: _deliverySla,
        hintText: t.chooseDelay,
        items: _slaOptions
            .map(
              (sla) => DropdownMenuItem(
                value: sla,
                child: Text(sla),
              ),
            )
            .toList(),
        onChanged: (value) => setState(() => _deliverySla = value),
      ),
      const SizedBox(height: 20),
      ..._buildShopBrandFields(t),
      const SizedBox(height: 28),
      ..._buildConsentBlock(t),
      const SizedBox(height: 28),
      AuthStepActions(
        onBack: _goBack,
        primaryLabel: t.signUp,
        onPrimary: _canSubmit ? _submitSignUp : null,
      ),
    ];
  }

  List<Widget> _buildShopLocationFields(AppLocalizations t) {
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
    ];
  }

  List<Widget> _buildShopBrandFields(AppLocalizations t) {
    return [
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

  /// Buyer step 2: all details in one screen.
  List<Widget> _buildBuyerDetailsStep({
    required AppLocalizations t,
    required String nameLabel,
    required String nameHint,
  }) {
    return [
      AuthFieldLabel(nameLabel),
      const SizedBox(height: 8),
      AuthTextField(
        controller: _nameController,
        hintText: nameHint,
        prefixIcon: Icon(
          Icons.person_outline,
          color: AppColors.textPrimary,
          size: 22,
        ),
      ),
      const SizedBox(height: 20),
      AuthFieldLabel(t.phoneNumber),
      const SizedBox(height: 8),
      PhoneNumberField(controller: _phoneController),
      const SizedBox(height: 20),
      ..._buildPasswordFields(t),
      const SizedBox(height: 28),
      ..._buildConsentBlock(t),
      const SizedBox(height: 28),
      AuthStepActions(
        onBack: _goBack,
        primaryLabel: t.signUp,
        onPrimary: _canSubmit ? _submitSignUp : null,
      ),
    ];
  }
}

class _RoleSelector extends StatelessWidget {
  const _RoleSelector({required this.role, required this.onChanged});

  final SignUpRole role;
  final ValueChanged<SignUpRole> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Column(
      children: [
        _RoleOptionCard(
          selected: role == SignUpRole.acheteur,
          illustration: RoleIllustrations.buyer,
          title: t.buyerRole,
          subtitle: t.signUpRoleBuyerSubtitle,
          onTap: () => onChanged(SignUpRole.acheteur),
        ),
        const SizedBox(height: 12),
        _RoleOptionCard(
          selected: role == SignUpRole.particulier,
          illustration: RoleIllustrations.seller,
          title: t.individualSellerRole,
          subtitle: t.signUpRoleSellerSubtitle,
          footnote: t.signUpRoleSellerFootnote,
          onTap: () => onChanged(SignUpRole.particulier),
        ),
        const SizedBox(height: 12),
        _RoleOptionCard(
          selected: role == SignUpRole.boutique,
          illustration: RoleIllustrations.shop,
          title: t.shopRole,
          subtitle: t.signUpRoleShopSubtitle,
          footnote: t.signUpRoleShopFootnote,
          onTap: () => onChanged(SignUpRole.boutique),
        ),
        const SizedBox(height: 12),
        _RoleOptionCard(
          selected: role == SignUpRole.commerceLocal,
          illustration: RoleIllustrations.enseigne,
          title: t.commerceLocalRole,
          subtitle: t.signUpRoleCommerceLocalSubtitle,
          footnote: t.signUpRoleCommerceLocalFootnote,
          onTap: () => onChanged(SignUpRole.commerceLocal),
        ),
        const SizedBox(height: 12),
        _RoleOptionCard(
          selected: role == SignUpRole.grandeSurface,
          illustration: RoleIllustrations.grandeSurface,
          title: t.grandeSurfaceRole,
          subtitle: t.signUpRoleGrandeSurfaceSubtitle,
          footnote: t.signUpRoleGrandeSurfaceFootnote,
          onTap: () => onChanged(SignUpRole.grandeSurface),
        ),
      ],
    );
  }
}

class _RoleOptionCard extends StatelessWidget {
  const _RoleOptionCard({
    required this.selected,
    this.illustration,
    this.icon,
    required this.title,
    required this.subtitle,
    this.footnote,
    required this.onTap,
  }) : assert(illustration != null || icon != null);

  final bool selected;
  final Widget? illustration;
  final IconData? icon;
  final String title;
  final String subtitle;
  final String? footnote;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasArt = illustration != null;

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
          padding: EdgeInsets.symmetric(
            horizontal: hasArt ? 14 : 14,
            vertical: hasArt ? 14 : 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primary : const Color(0xFFE6E6E6),
              width: selected ? 1.8 : 1.2,
            ),
          ),
          child: Row(
            children: [
              if (illustration != null)
                illustration!
              else
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary.withValues(alpha: 0.14)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 22,
                    color: selected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
              SizedBox(width: hasArt ? 16 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: hasArt ? 16 : 15,
                        fontWeight: FontWeight.w700,
                        color: selected
                            ? AppColors.primary
                            : AppColors.textPrimary,
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
