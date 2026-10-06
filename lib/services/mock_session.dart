import 'package:flutter/foundation.dart';
import 'package:frip_cash/api/api_client.dart';
import 'package:frip_cash/api/auth_api.dart';
import 'package:frip_cash/api/auth_field_map.dart';
import 'package:frip_cash/api/me_api.dart';
import 'package:frip_cash/api/media_api.dart';
import 'package:frip_cash/mock/mock_users.dart';
import 'package:frip_cash/models/delivery_perimeter.dart';
import 'package:frip_cash/models/me_response.dart';
import 'package:frip_cash/models/shop_kind.dart';
import 'package:frip_cash/services/mock_seller_api.dart';
import 'package:frip_cash/services/seller_verification_service.dart';
import 'package:frip_cash/services/token_store.dart';

/// App session — auth against Nest; UI still consumes [MockUser].
class MockSession extends ChangeNotifier {
  MockSession._();

  static final MockSession instance = MockSession._();

  MockUser? _user;
  MeResponse? _me;
  RegistrationDraft? _draft;
  bool _restoring = false;
  String? _audience;

  /// Pending reset token after OTP verify (forgot password).
  String? pendingResetToken;

  /// Seller ids known to be neighborhood shops (session + mocks).
  final Set<String> _proximitySellerIds = {};

  /// Guest stub when unsigned — not a seeded demo account.
  static const _unsigned = MockUser(
    id: '',
    name: '',
    phone: '',
    role: UserRole.acheteur,
  );

  MockUser get user => _user ?? _unsigned;

  MeResponse? get me => _me;

  bool get isSignedIn => _user != null;

  bool get isRestoring => _restoring;

  bool get isCourierSession =>
      _audience == AuthAudience.courier || user.role == UserRole.livreur;

  bool isProximitySeller(String sellerId) {
    if (_user != null && _user!.sellerId == sellerId) {
      return _user!.isProximityShop;
    }
    return _proximitySellerIds.contains(sellerId);
  }

  void registerProximitySeller(String sellerId) {
    _proximitySellerIds.add(sellerId);
  }

  RegistrationDraft? get registrationDraft => _draft;

  void setRegistrationDraft(RegistrationDraft draft) {
    _draft = draft;
  }

  Future<void> restore() async {
    _restoring = true;
    notifyListeners();
    try {
      final token = await TokenStore.instance.readToken();
      if (token == null || token.isEmpty) {
        _user = null;
        _me = null;
        _audience = null;
        mustChangePassword = false;
        return;
      }
      _audience = await TokenStore.instance.readAudience();
      if (_audience == AuthAudience.courier) {
        await _applyMe(await MeApi.instance.fetchCourierMe());
      } else {
        try {
          await _applyMe(await MeApi.instance.fetchMe());
          _audience = AuthAudience.consumer;
        } on ApiException catch (e) {
          if (e.code == 'WRONG_AUTH_SURFACE' ||
              e.code == 'FORBIDDEN_AUDIENCE') {
            await _applyMe(await MeApi.instance.fetchCourierMe());
            _audience = AuthAudience.courier;
            await TokenStore.instance.write(
              token: token,
              audience: AuthAudience.courier,
            );
          } else {
            rethrow;
          }
        }
      }
      mustChangePassword = _me?.raw['mustChangePassword'] == true;
    } catch (_) {
      await TokenStore.instance.clear();
      _user = null;
      _me = null;
      _audience = null;
      mustChangePassword = false;
      courierPreAuthToken = null;
      courierOtpPhoneMasked = null;
    } finally {
      _restoring = false;
      notifyListeners();
    }
  }

  Future<void> refreshMe() async {
    if (_audience == AuthAudience.courier) {
      await _applyMe(await MeApi.instance.fetchCourierMe());
    } else {
      await _applyMe(await MeApi.instance.fetchMe());
    }
    notifyListeners();
  }

  Future<void> _applyMe(MeResponse me) async {
    _me = me;
    _user = me.toMockUser();
    if (me.isProximityShopLike || _user!.isProximityShop) {
      _proximitySellerIds.add(_user!.sellerId);
    }
    if (me.isVerificationPending && _user!.role.isSeller) {
      SellerVerificationService.instance.markPending(_user!.sellerId);
    }
    MockSellerApi.provisionAccount(_user!);
  }

  Future<void> loginMarketplace({
    required String phone,
    required String password,
    required bool termsAccepted,
  }) async {
    final result = await AuthApi.instance.login(
      phone: phone,
      password: password,
      termsAccepted: termsAccepted,
    );
    if (result.token.isEmpty) {
      throw ApiException(
        code: 'INVALID_RESPONSE',
        message: 'Missing token',
      );
    }
    await TokenStore.instance.write(
      token: result.token,
      audience: AuthAudience.consumer,
    );
    _audience = AuthAudience.consumer;
    await _applyMeOrAuthUser(result.user);
    _draft = null;
    notifyListeners();
  }

  /// Pending courier first-login OTP (never a missions token).
  String? courierPreAuthToken;
  String? courierOtpPhoneMasked;
  bool mustChangePassword = false;

  /// Returns [CourierPhoneVerificationRequired] when OTP is needed; otherwise
  /// establishes a full courier session and returns [CourierAuthenticated].
  Future<CourierLoginResult> loginCourier({
    required String phone,
    required String password,
  }) async {
    final result = await AuthApi.instance.courierLogin(
      phone: phone,
      password: password,
    );
    if (result is CourierPhoneVerificationRequired) {
      if (result.preAuthToken.isEmpty) {
        throw ApiException(
          code: 'INVALID_RESPONSE',
          message: 'Missing preAuthToken',
        );
      }
      // Do not store pre-auth as a missions bearer.
      await TokenStore.instance.clear();
      courierPreAuthToken = result.preAuthToken;
      courierOtpPhoneMasked = result.phoneMasked;
      mustChangePassword = false;
      _audience = null;
      _user = null;
      _me = null;
      notifyListeners();
      return result;
    }
    if (result is! CourierAuthenticated || result.token.isEmpty) {
      throw ApiException(
        code: 'INVALID_RESPONSE',
        message: 'Missing courier token',
      );
    }
    await _establishCourierSession(
      token: result.token,
      user: result.user,
      mustChangePassword: result.mustChangePassword,
    );
    return result;
  }

  Future<CourierAuthenticated> verifyCourierOtp({
    required String code,
    String? preAuthToken,
  }) async {
    final token = preAuthToken ?? courierPreAuthToken;
    if (token == null || token.isEmpty) {
      throw ApiException(
        code: 'PRE_AUTH_EXPIRED',
        message: 'Session expired — sign in again',
      );
    }
    final result = await AuthApi.instance.courierOtpVerify(
      preAuthToken: token,
      code: code,
    );
    if (result is! CourierAuthenticated || result.token.isEmpty) {
      throw ApiException(
        code: 'INVALID_RESPONSE',
        message: 'Missing courier token after OTP',
      );
    }
    courierPreAuthToken = null;
    courierOtpPhoneMasked = null;
    await _establishCourierSession(
      token: result.token,
      user: result.user,
      mustChangePassword: result.mustChangePassword,
    );
    return result;
  }

  Future<void> resendCourierOtp({String? preAuthToken}) async {
    final token = preAuthToken ?? courierPreAuthToken;
    if (token == null || token.isEmpty) {
      throw ApiException(
        code: 'PRE_AUTH_EXPIRED',
        message: 'Session expired — sign in again',
      );
    }
    await AuthApi.instance.courierOtpSend(preAuthToken: token);
  }

  Future<void> _establishCourierSession({
    required String token,
    Map<String, dynamic>? user,
    bool mustChangePassword = false,
  }) async {
    await TokenStore.instance.write(
      token: token,
      audience: AuthAudience.courier,
    );
    _audience = AuthAudience.courier;
    this.mustChangePassword = mustChangePassword;
    try {
      await _applyMe(await MeApi.instance.fetchCourierMe());
    } on ApiException catch (e) {
      if (_isServerProfileError(e) && user != null) {
        final u = Map<String, dynamic>.from(user);
        u['role'] = 'livreur';
        u['audience'] = 'COURIER';
        await _applyMe(MeResponse.fromJson(u));
      } else {
        rethrow;
      }
    }
    final meMust =
        _me?.raw['mustChangePassword'] == true || mustChangePassword;
    this.mustChangePassword = meMust;
    _draft = null;
    notifyListeners();
  }

  /// Prefer `GET /me`; if BE 500s, hydrate session from auth `user` payload.
  Future<void> _applyMeOrAuthUser(Map<String, dynamic>? authUser) async {
    try {
      if (_audience == AuthAudience.courier) {
        await _applyMe(await MeApi.instance.fetchCourierMe());
      } else {
        await _applyMe(await MeApi.instance.fetchMe());
      }
    } on ApiException catch (e) {
      if (_isServerProfileError(e) && authUser != null) {
        await _applyMe(MeResponse.fromJson(authUser));
        return;
      }
      rethrow;
    }
  }

  bool _isServerProfileError(ApiException e) =>
      e.statusCode == 500 ||
      e.code == 'INTERNAL_SERVER_ERROR' ||
      e.code == 'INTERNAL';

  Future<void> requestOtp({
    required String phone,
    required String purpose,
  }) {
    return AuthApi.instance.requestOtp(phone: phone, purpose: purpose);
  }

  /// Register OTP verify → then complete register from draft.
  Future<void> verifyRegisterOtpAndComplete({
    required String phone,
    required String code,
  }) async {
    final draft = _draft;
    if (draft == null) {
      throw ApiException(
        code: 'NO_REGISTRATION_DRAFT',
        message: 'Missing registration draft',
      );
    }

    final verified = await AuthApi.instance.verifyOtp(
      phone: phone,
      code: code,
      purpose: 'register',
    );
    final sessionId =
        (verified['registrationSessionId'] ?? verified['sessionId'] ?? '')
            .toString();
    if (sessionId.isEmpty) {
      throw ApiException(
        code: 'OTP_INVALID',
        message: 'Missing registrationSessionId',
      );
    }

    String? logoMediaId;
    if (draft.needsLogo) {
      final bytes = draft.logoBytes;
      if (bytes == null || bytes.isEmpty) {
        throw ApiException(
          code: 'LOGO_REQUIRED',
          message: 'Shop logo is required',
        );
      }
      logoMediaId = await AuthApi.instance.uploadRegisterLogo(
        phone: phone,
        registrationSessionId: sessionId,
        bytes: bytes,
        filename: draft.logoFileName ?? 'logo.jpg',
      );
    }

    final body = <String, dynamic>{
      'registrationSessionId': sessionId,
      'signupPath': draft.signupPath,
      'phone': phone,
      'password': draft.password,
      'displayName': draft.name,
      'termsAccepted': draft.termsAccepted,
      'marketingOptIn': draft.marketingOptIn,
      'locale': draft.locale,
    };
    if (draft.password.length < 8) {
      throw ApiException(
        code: 'VALIDATION_ERROR',
        message: 'Password must be at least 8 characters',
      );
    }
    if (draft.zoneId != null) body['zoneId'] = draft.zoneId;
    if (draft.address != null) body['address'] = draft.address;
    final sla = AuthFieldMap.deliverySlaApi(draft.deliverySla);
    if (sla != null) body['deliverySla'] = sla;
    if (draft.shopName != null) body['shopName'] = draft.shopName;
    if (draft.shopDescription != null) {
      body['shopDescription'] = draft.shopDescription;
    }
    final cat = AuthFieldMap.shopCategoryId(draft.shopCategory);
    if (cat != null) body['shopCategoryId'] = cat;
    if (logoMediaId != null) body['logoMediaId'] = logoMediaId;

    AuthTokenResult result;
    try {
      result = await AuthApi.instance.register(body);
    } on ApiException catch (e) {
      // BE currently returns empty 500 after creating the user — recover via login.
      if (e.statusCode != null && e.statusCode! >= 500) {
        try {
          result = await AuthApi.instance.login(
            phone: phone,
            password: draft.password,
            termsAccepted: draft.termsAccepted,
          );
        } on ApiException {
          throw ApiException(
            code: 'INTERNAL_SERVER_ERROR',
            message:
                'Registration failed on server. Try Sign in — account may already exist.',
            statusCode: e.statusCode,
            correlationId: e.correlationId,
          );
        }
      } else if (e.code == 'PHONE_ALREADY_REGISTERED') {
        rethrow;
      } else {
        rethrow;
      }
    }
    if (result.token.isEmpty) {
      // Last resort: login with the password just chosen.
      result = await AuthApi.instance.login(
        phone: phone,
        password: draft.password,
        termsAccepted: draft.termsAccepted,
      );
    }
    if (result.token.isEmpty) {
      throw ApiException(
        code: 'INVALID_RESPONSE',
        message: 'Missing token',
      );
    }
    await TokenStore.instance.write(
      token: result.token,
      audience: AuthAudience.consumer,
    );
    _audience = AuthAudience.consumer;
    await _applyMeOrAuthUser(result.user);
    _draft = null;
    notifyListeners();
  }

  Future<String> verifyResetOtp({
    required String phone,
    required String code,
  }) async {
    final verified = await AuthApi.instance.verifyOtp(
      phone: phone,
      code: code,
      purpose: 'reset_password',
    );
    final token =
        (verified['resetToken'] ?? verified['token'] ?? '').toString();
    if (token.isEmpty) {
      throw ApiException(
        code: 'OTP_INVALID',
        message: 'Missing resetToken',
      );
    }
    pendingResetToken = token;
    return token;
  }

  Future<void> resetPassword({
    required String phone,
    required String password,
  }) async {
    final token = pendingResetToken;
    if (token == null || token.isEmpty) {
      throw ApiException(
        code: 'RESET_TOKEN_MISSING',
        message: 'Verify OTP first',
      );
    }
    await AuthApi.instance.resetPassword(
      phone: phone,
      resetToken: token,
      password: password,
    );
    pendingResetToken = null;
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (isCourierSession) {
      await AuthApi.instance.courierChangePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      mustChangePassword = false;
      notifyListeners();
      return;
    }
    await AuthApi.instance.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  Future<void> forgotPassword(String phone) {
    return AuthApi.instance.forgotPassword(phone);
  }

  /// @deprecated Prefer [loginMarketplace]. Kept for rare mock demos.
  Future<void> sendOtp(String phoneNumber) =>
      requestOtp(phone: phoneNumber, purpose: 'register');

  void signIn(MockUser user) {
    _user = user;
    _draft = null;
    if (user.isProximityShop) {
      _proximitySellerIds.add(user.sellerId);
    }
    MockSellerApi.provisionAccount(user);
    notifyListeners();
  }

  void signInWithPhone(String phone, {String? fallbackName}) {
    final normalized = _normalizePhone(phone);
    for (final candidate in mockUsers) {
      if (_normalizePhone(candidate.phone) == normalized) {
        signIn(candidate);
        return;
      }
    }
    signInAsBuyer(name: fallbackName);
  }

  void signInAsBuyer({String? name}) {
    signIn(
      MockUser(
        id: 'user_session',
        name: name ?? mockUsers.first.name,
        phone: mockUsers.first.phone,
        role: UserRole.acheteur,
        zoneId: mockUsers.first.zoneId,
        address: mockUsers.first.address,
      ),
    );
  }

  void signInAsParticulier([MockUser? seller]) {
    signIn(
      seller ??
          mockUsers.firstWhere(
            (u) => u.role == UserRole.vendeurParticulier,
          ),
    );
  }

  void signInAsCourier([MockUser? courier]) {
    signIn(courier ?? mockUsers.last);
  }

  Future<void> becomeParticulierSeller({
    required String zoneId,
    required String address,
    required String deliverySla,
    String? displayName,
  }) async {
    // Remote CreateParticulierDto requires zoneId + address + deliverySla.
    final sla = AuthFieldMap.deliverySlaApi(deliverySla) ?? deliverySla;
    await MeApi.instance.becomeParticulier({
      'zoneId': zoneId,
      'address': address,
      'deliverySla': sla,
      if (displayName != null && displayName.trim().isNotEmpty)
        'displayName': displayName.trim(),
    });
    await refreshMe();
  }

  Future<void> becomeShopSeller({
    required String signupPath,
    required String shopName,
    required String zoneId,
    required String address,
    required ShopKind shopKind,
    String? deliverySla,
    String? shopCategoryId,
    String? shopDescription,
    String? logoMediaId,
    Uint8List? logoBytes,
    String? logoFileName,
  }) async {
    // Remote CreateShopDto (OpenAPI): shopKind, name, zoneId, address,
    // logoMediaId required; description / deliverySla / shopCategoryId optional.
    var mediaId = logoMediaId;
    if ((mediaId == null || mediaId.isEmpty) && logoBytes != null) {
      mediaId = await MediaApi.instance.uploadShopLogo(
        bytes: logoBytes,
        filename: logoFileName ?? 'logo.jpg',
      );
    }
    if (mediaId == null || mediaId.isEmpty) {
      throw ApiException(
        code: 'LOGO_REQUIRED',
        message: 'Shop logo is required',
      );
    }

    final body = <String, dynamic>{
      'shopKind': AuthFieldMap.shopKindApi(shopKind),
      'name': shopName,
      'zoneId': zoneId,
      'address': address,
      'logoMediaId': mediaId,
      if (shopDescription != null && shopDescription.trim().isNotEmpty)
        'description': shopDescription.trim(),
    };
    final sla = AuthFieldMap.deliverySlaApi(deliverySla);
    if (sla != null) body['deliverySla'] = sla;
    final cat = AuthFieldMap.shopCategoryId(shopCategoryId);
    if (cat != null) body['shopCategoryId'] = cat;

    await MeApi.instance.becomeShop(body);
    await refreshMe();
  }

  void addSellerProfileParticulier({
    String? zoneId,
    String? address,
    String? deliverySla,
  }) {
    upgradeBuyerToSeller(
      role: SignUpRole.particulier,
      zoneId: zoneId,
      address: address,
      deliverySla: deliverySla,
    );
  }

  /// Local-only upgrade fallback when API not used yet.
  void upgradeBuyerToSeller({
    required SignUpRole role,
    DeliveryPerimeter? perimeter,
    String? zoneId,
    String? address,
    String? deliverySla,
    String? shopName,
    String? shopCategory,
  }) {
    final current = user;
    if (current.role == UserRole.boutique) return;
    if (current.role == UserRole.vendeurParticulier && !role.isShopProfile) {
      return;
    }
    if (current.role == UserRole.acheteur && role == SignUpRole.acheteur) {
      return;
    }

    final effectivePerimeter = role.defaultPerimeter ?? perimeter;
    final shopKind = role.shopKindFor(effectivePerimeter);

    if (role == SignUpRole.particulier) {
      if (current.role != UserRole.acheteur) return;
      signIn(
        MockUser(
          id: current.id,
          name: current.name,
          phone: current.phone,
          role: UserRole.vendeurParticulier,
          zoneId: zoneId ?? current.zoneId ?? 'zone_1',
          address: address ?? current.address,
          deliverySla: deliverySla ?? current.deliverySla ?? '48h',
          sellerProfileId: current.sellerProfileId,
          canBuy: current.canBuy,
          canCreateListing: true,
        ),
      );
      return;
    }

    if (role.isShopProfile) {
      final resolvedShopName = shopName?.trim();
      signIn(
        MockUser(
          id: current.id,
          name: resolvedShopName?.isNotEmpty == true
              ? resolvedShopName!
              : current.name,
          phone: current.phone,
          role: UserRole.boutique,
          zoneId: zoneId ?? current.zoneId ?? 'zone_1',
          address: address ?? current.address,
          deliverySla: shopKind == ShopKind.proximite
              ? null
              : (deliverySla ?? current.deliverySla ?? '48h'),
          shopName: resolvedShopName?.isNotEmpty == true
              ? resolvedShopName
              : current.name,
          shopKind: shopKind,
          shopCategory: shopCategory,
          sellerProfileId: current.sellerProfileId,
          canBuy: current.canBuy,
          canCreateListing: true,
        ),
      );
      _applyVerificationForNewSeller();
    }
  }

  void becomeIndividualSeller({
    String? zoneId,
    String? address,
    String? deliverySla,
  }) {
    upgradeBuyerToSeller(
      role: SignUpRole.particulier,
      zoneId: zoneId,
      address: address,
      deliverySla: deliverySla,
    );
  }

  void _applyVerificationForNewSeller() {
    final current = user;
    if (!current.role.isSeller) return;
    if (current.isProximityShop || current.isPartnerEnseigne) {
      SellerVerificationService.instance.markPending(current.sellerId);
    }
  }

  Future<void> signOut({bool remote = true}) async {
    if (remote) {
      try {
        await AuthApi.instance.signOut();
      } catch (_) {}
    }
    await TokenStore.instance.clear();
    _user = null;
    _me = null;
    _draft = null;
    _audience = null;
    pendingResetToken = null;
    courierPreAuthToken = null;
    courierOtpPhoneMasked = null;
    mustChangePassword = false;
    notifyListeners();
  }

  void completeShopOnboarding({
    required String shopName,
    String? shopDescription,
    String? deliverySla,
    ShopKind shopKind = ShopKind.standard,
    String? shopCategory,
    String? zoneId,
    String? address,
  }) {
    final current = user;
    signIn(
      MockUser(
        id: current.id,
        name: current.name,
        phone: current.phone,
        role: UserRole.boutique,
        zoneId: zoneId ?? current.zoneId,
        address: address ?? current.address,
        deliverySla: deliverySla ?? current.deliverySla ?? '48h',
        shopName: shopName,
        shopKind: shopKind,
        shopCategory: shopCategory,
        sellerProfileId: current.sellerProfileId,
        canBuy: current.canBuy,
        canCreateListing: current.canCreateListing,
      ),
    );
  }

  Future<void> updateProfile({
    String? name,
    String? zoneId,
    String? address,
  }) async {
    final current = user;
    signIn(
      MockUser(
        id: current.id,
        name: name ?? current.name,
        phone: current.phone,
        role: current.role,
        zoneId: zoneId ?? current.zoneId,
        address: address ?? current.address,
        deliverySla: current.deliverySla,
        shopName: current.shopName,
        shopKind: current.shopKind,
        shopCategory: current.shopCategory,
        sellerProfileId: current.sellerProfileId,
        canBuy: current.canBuy,
        canCreateListing: current.canCreateListing,
      ),
    );
  }

  static String _normalizePhone(String phone) =>
      phone.replaceAll(RegExp(r'[^\d+]'), '');
}

extension on MeResponse {
  bool get isProximityShopLike =>
      shopKind == ShopKind.proximite ||
      (role == UserRole.boutique && shopKind == ShopKind.proximite);
}

class RegistrationDraft {
  const RegistrationDraft({
    required this.signupPath,
    required this.role,
    required this.name,
    required this.phone,
    required this.password,
    required this.termsAccepted,
    this.marketingOptIn = false,
    this.locale = 'fr',
    this.zoneId,
    this.address,
    this.deliverySla,
    this.shopName,
    this.shopDescription,
    this.shopKind,
    this.shopCategory,
    this.logoBytes,
    this.logoFileName,
  });

  final String signupPath;
  final UserRole role;
  final String name;
  final String phone;
  final String password;
  final bool termsAccepted;
  final bool marketingOptIn;
  final String locale;
  final String? zoneId;
  final String? address;
  final String? deliverySla;
  final String? shopName;
  final String? shopDescription;
  final ShopKind? shopKind;
  final String? shopCategory;
  final List<int>? logoBytes;
  final String? logoFileName;

  bool get needsLogo =>
      shopKind == ShopKind.standard ||
      shopKind == ShopKind.proximite ||
      shopKind == ShopKind.enseigne;
}

enum SignUpRole { acheteur, particulier, boutique, commerceLocal, grandeSurface }

extension SignUpRoleX on SignUpRole {
  String get signupPath => name;

  UserRole get userRole => switch (this) {
        SignUpRole.acheteur => UserRole.acheteur,
        SignUpRole.particulier => UserRole.vendeurParticulier,
        SignUpRole.boutique => UserRole.boutique,
        SignUpRole.commerceLocal => UserRole.boutique,
        SignUpRole.grandeSurface => UserRole.boutique,
      };

  ShopKind? shopKindFor(DeliveryPerimeter? perimeter) => switch (this) {
        SignUpRole.boutique => ShopKind.standard,
        SignUpRole.commerceLocal => ShopKind.proximite,
        SignUpRole.grandeSurface => ShopKind.enseigne,
        _ => null,
      };

  bool get isShopProfile =>
      this == SignUpRole.boutique ||
      this == SignUpRole.commerceLocal ||
      this == SignUpRole.grandeSurface;

  bool get isCommerceLocal => this == SignUpRole.commerceLocal;

  bool get isGrandeSurface => this == SignUpRole.grandeSurface;

  bool get isBoutique => this == SignUpRole.boutique;

  bool get forcesCityWidePerimeter => isBoutique || isGrandeSurface;

  bool get forcesNeighborhoodPerimeter => isCommerceLocal;

  DeliveryPerimeter? get defaultPerimeter {
    if (forcesCityWidePerimeter) return DeliveryPerimeter.touteLaVille;
    if (forcesNeighborhoodPerimeter) return DeliveryPerimeter.monQuartier;
    return null;
  }

  bool get requiresManualValidation => isCommerceLocal || isGrandeSurface;
}
