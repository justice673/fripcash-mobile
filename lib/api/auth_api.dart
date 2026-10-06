import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:frip_cash/api/api_client.dart';
import 'package:frip_cash/api/cloudinary_upload.dart';

class AuthTokenResult {
  const AuthTokenResult({
    required this.token,
    this.accessToken,
    this.user,
    this.mustChangePassword = false,
  });

  /// Session bearer used on every product call (`Authorization: Bearer …`).
  final String token;

  /// Same session value as [token] when the API returns both fields.
  final String? accessToken;

  final Map<String, dynamic>? user;

  /// Courier first-login / admin reset — force change before missions.
  final bool mustChangePassword;

  /// Prefer `accessToken` (handoff), fall back to `token` / snake_case aliases.
  factory AuthTokenResult.fromJson(Map<String, dynamic> json) {
    final access = (json['accessToken'] ?? json['access_token'] ?? '').toString();
    final legacy = (json['token'] ?? json['sessionToken'] ?? '').toString();
    final token = access.isNotEmpty ? access : legacy;
    final user = json['user'] ?? json['courier'];
    return AuthTokenResult(
      token: token,
      accessToken: access.isNotEmpty ? access : (legacy.isNotEmpty ? legacy : null),
      user: user is Map ? Map<String, dynamic>.from(user) : null,
      mustChangePassword: json['mustChangePassword'] == true,
    );
  }
}

/// Discriminated `POST /auth/courier/login` (+ OTP verify) response.
sealed class CourierLoginResult {
  const CourierLoginResult();

  factory CourierLoginResult.fromJson(Map<String, dynamic> json) {
    final status = (json['status'] ?? '').toString();
    if (status == 'phone_verification_required') {
      return CourierPhoneVerificationRequired(
        preAuthToken: (json['preAuthToken'] ?? '').toString(),
        phoneMasked: (json['phoneMasked'] ?? '').toString(),
        expiresInSec: json['expiresInSec'] is int
            ? json['expiresInSec'] as int
            : int.tryParse('${json['expiresInSec']}') ?? 600,
        otpLength: json['otpLength'] is int
            ? json['otpLength'] as int
            : int.tryParse('${json['otpLength']}') ?? 6,
        otpSent: json['otpSent'] != false,
      );
    }
    // Default / authenticated — also tolerate legacy { token } without status.
    final auth = AuthTokenResult.fromJson(json);
    return CourierAuthenticated(
      token: auth.token,
      user: auth.user,
      mustChangePassword: auth.mustChangePassword,
    );
  }
}

class CourierAuthenticated extends CourierLoginResult {
  const CourierAuthenticated({
    required this.token,
    this.user,
    this.mustChangePassword = false,
  });

  final String token;
  final Map<String, dynamic>? user;
  final bool mustChangePassword;
}

class CourierPhoneVerificationRequired extends CourierLoginResult {
  const CourierPhoneVerificationRequired({
    required this.preAuthToken,
    required this.phoneMasked,
    this.expiresInSec = 600,
    this.otpLength = 6,
    this.otpSent = true,
  });

  final String preAuthToken;
  final String phoneMasked;
  final int expiresInSec;
  final int otpLength;
  final bool otpSent;
}

class AuthApi {
  AuthApi._();
  static final AuthApi instance = AuthApi._();

  final _client = ApiClient.instance;

  Future<void> requestOtp({
    required String phone,
    required String purpose,
  }) async {
    try {
      await _client.post(
        '/auth/otp/request',
        data: {'phone': phone, 'purpose': purpose},
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Returns `registrationSessionId` or `resetToken` depending on purpose.
  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String code,
    required String purpose,
  }) async {
    try {
      final res = await _client.post<Map<String, dynamic>>(
        '/auth/otp/verify',
        data: {'phone': phone, 'code': code, 'purpose': purpose},
      );
      return Map<String, dynamic>.from(res.data ?? {});
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<AuthTokenResult> register(Map<String, dynamic> body) async {
    try {
      final res = await _client.post<Map<String, dynamic>>(
        '/auth/register',
        data: body,
      );
      return AuthTokenResult.fromJson(Map<String, dynamic>.from(res.data ?? {}));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<AuthTokenResult> login({
    required String phone,
    required String password,
    required bool termsAccepted,
  }) async {
    try {
      final res = await _client.post<Map<String, dynamic>>(
        '/auth/login',
        data: {
          'phone': phone,
          'password': password,
          'termsAccepted': termsAccepted,
        },
      );
      return AuthTokenResult.fromJson(Map<String, dynamic>.from(res.data ?? {}));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<CourierLoginResult> courierLogin({
    required String phone,
    required String password,
  }) async {
    try {
      final res = await _client.post<Map<String, dynamic>>(
        '/auth/courier/login',
        data: {'phone': phone, 'password': password},
      );
      return CourierLoginResult.fromJson(
        Map<String, dynamic>.from(res.data ?? {}),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> courierOtpSend({required String preAuthToken}) async {
    try {
      await _client.post(
        '/auth/courier/otp/send',
        data: {},
        headers: {'Authorization': 'Bearer $preAuthToken'},
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<CourierLoginResult> courierOtpVerify({
    required String preAuthToken,
    required String code,
  }) async {
    try {
      final res = await _client.post<Map<String, dynamic>>(
        '/auth/courier/otp/verify',
        data: {'code': code},
        headers: {'Authorization': 'Bearer $preAuthToken'},
      );
      return CourierLoginResult.fromJson(
        Map<String, dynamic>.from(res.data ?? {}),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> courierChangePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _client.post(
        '/auth/courier/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> forgotPassword(String phone) async {
    try {
      await _client.post('/auth/password/forgot', data: {'phone': phone});
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> resetPassword({
    required String phone,
    required String resetToken,
    required String password,
  }) async {
    try {
      await _client.post(
        '/auth/password/reset',
        data: {
          'phone': phone,
          'resetToken': resetToken,
          'password': password,
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _client.post(
        '/auth/password/change',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> signOut() async {
    try {
      await _client.post('/auth/sign-out');
    } on DioException catch (e) {
      // Still clear local session even if remote fails.
      if (e.response?.statusCode != 401) {
        throw ApiException.fromDio(e);
      }
    }
  }

  /// Cloudinary unsigned/signed upload for shop logo during register.
  Future<String> uploadRegisterLogo({
    required String phone,
    required String registrationSessionId,
    required List<int> bytes,
    String filename = 'logo.jpg',
  }) async {
    try {
      final signRes = await _client.post<Map<String, dynamic>>(
        '/auth/media/register-cloudinary-sign',
        data: {
          'phone': phone,
          'registrationSessionId': registrationSessionId,
        },
      );
      final sign = Map<String, dynamic>.from(signRes.data ?? {});
      final uploaded = await uploadCloudinarySigned(
        sign: sign,
        bytes: bytes is Uint8List ? bytes : Uint8List.fromList(bytes),
        filename: filename,
      );
      return uploaded.publicId;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
