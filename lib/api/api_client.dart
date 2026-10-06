import 'package:dio/dio.dart';
import 'package:frip_cash/services/app_locale_service.dart';
import 'package:frip_cash/services/token_store.dart';

/// Nest API error with stable `code`.
class ApiException implements Exception {
  ApiException({
    required this.code,
    required this.message,
    this.statusCode,
    this.correlationId,
    this.details,
  });

  final String code;
  final String message;
  final int? statusCode;
  final String? correlationId;
  final List<String>? details;

  factory ApiException.fromDio(DioException e) {
    final data = e.response?.data;
    final status = e.response?.statusCode;
    if (data is Map) {
      final code = (data['code'] ?? data['error'] ?? 'UNKNOWN').toString();
      var message = (data['message'] ?? e.message ?? code).toString();
      List<String>? details;
      final rawDetails = data['details'];
      if (rawDetails is List) {
        details = rawDetails.map((e) => e.toString()).toList();
      } else if (message.contains(' · ')) {
        details = message.split(' · ').map((s) => s.trim()).toList();
      }
      // Nest class-validator: "property X should not exist" / "X must be…"
      if (details != null && details.isNotEmpty) {
        message = _humanizeValidation(details);
      }
      return ApiException(
        code: code,
        message: message,
        statusCode: status,
        correlationId: data['correlationId']?.toString(),
        details: details,
      );
    }
    // Empty / non-JSON bodies (e.g. Nest 500 with no payload).
    if (status != null && status >= 500) {
      return ApiException(
        code: 'INTERNAL_SERVER_ERROR',
        message: 'Server error — please try again',
        statusCode: status,
      );
    }
    if (status == 401) {
      return ApiException(
        code: 'UNAUTHORIZED',
        message: 'Authentication required',
        statusCode: status,
      );
    }
    if (status == 403) {
      return ApiException(
        code: 'FORBIDDEN',
        message: 'Access denied',
        statusCode: status,
      );
    }
    if (status == 409) {
      return ApiException(
        code: 'CONFLICT',
        message: 'Conflict',
        statusCode: status,
      );
    }
    return ApiException(
      code: e.type.name.toUpperCase(),
      message: _shortDioMessage(e),
      statusCode: status,
    );
  }

  static String _humanizeValidation(List<String> details) {
    final mapped = <String>[];
    for (final d in details) {
      final lower = d.toLowerCase();
      if (lower.contains('should not exist')) {
        final prop = RegExp(r'property (\w+)', caseSensitive: false)
            .firstMatch(d)
            ?.group(1);
        mapped.add(
          prop == null
              ? d
              : 'Champ non accepté : ${_fieldLabel(prop)}',
        );
      } else if (lower.contains('must be') ||
          lower.contains('should not be empty') ||
          lower.contains('must be a string') ||
          lower.contains('must be an enum')) {
        final prop = RegExp(r'(\w+) must', caseSensitive: false)
                .firstMatch(d)
                ?.group(1) ??
            RegExp(r'(\w+) should', caseSensitive: false)
                .firstMatch(d)
                ?.group(1);
        mapped.add(
          prop == null
              ? d
              : 'Champ invalide / manquant : ${_fieldLabel(prop)}',
        );
      } else {
        mapped.add(d);
      }
    }
    return mapped.join('\n');
  }

  static String _fieldLabel(String prop) {
    const labels = {
      'shopKind': 'Type de boutique (shopKind)',
      'name': 'Nom de la boutique',
      'description': 'Description',
      'shopName': 'Nom de la boutique',
      'shopDescription': 'Description',
      'signupPath': 'Type de vendeur',
      'zoneId': 'Zone',
      'address': 'Adresse',
      'deliverySla': 'Délai de livraison',
      'shopCategoryId': 'Catégorie',
      'logoMediaId': 'Logo',
      'displayName': 'Nom affiché',
      'bio': 'Bio',
    };
    return labels[prop] ?? prop;
  }

  static String _shortDioMessage(DioException e) {
    final raw = e.message ?? '';
    if (raw.contains('status code of')) {
      final code = e.response?.statusCode;
      return code != null ? 'Request failed ($code)' : 'Request failed';
    }
    if (raw.isNotEmpty && raw.length < 120) return raw;
    return 'Network error';
  }

  @override
  String toString() => 'ApiException($code): $message';
}

class ApiClient {
  ApiClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: const String.fromEnvironment(
          'API_URL',
          defaultValue: 'http://localhost:3010',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Keep explicit Authorization (e.g. courier preAuthToken for OTP).
          final existing = options.headers['Authorization']?.toString() ?? '';
          if (existing.isEmpty) {
            final token = await TokenStore.instance.readToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          final locale =
              AppLocaleService.instance.locale?.languageCode ?? 'fr';
          options.headers['x-locale'] = locale == 'en' ? 'EN' : 'FR';
          handler.next(options);
        },
        onError: (e, handler) async {
          final status = e.response?.statusCode;
          final path = e.requestOptions.path;
          // Never wipe session on auth challenge failures (login / OTP).
          final isAuthChallenge = path.contains('/auth/');
          final data = e.response?.data;
          final code = data is Map
              ? (data['code'] ?? data['error'] ?? '').toString()
              : '';
          final otpChallenge = code.startsWith('OTP_') ||
              code == 'PRE_AUTH_EXPIRED' ||
              code == 'INVALID_CREDENTIALS';
          if (status == 401 && !isAuthChallenge && !otpChallenge) {
            await TokenStore.instance.clear();
          }
          handler.next(e);
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._();

  late final Dio _dio;

  Dio get dio => _dio;

  /// Prefix all product routes with `/api/v1`.
  String v1(String path) {
    if (path.startsWith('/api/v1')) return path;
    if (path.startsWith('/')) return '/api/v1$path';
    return '/api/v1/$path';
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get<T>(
      v1(path),
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? headers,
  }) {
    return _dio.post<T>(
      v1(path),
      data: data,
      options: headers == null ? null : Options(headers: headers),
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? headers,
  }) {
    return _dio.put<T>(
      v1(path),
      data: data,
      options: headers == null ? null : Options(headers: headers),
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? headers,
  }) {
    return _dio.patch<T>(
      v1(path),
      data: data,
      options: headers == null ? null : Options(headers: headers),
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? headers,
  }) {
    return _dio.delete<T>(
      v1(path),
      data: data,
      options: headers == null ? null : Options(headers: headers),
    );
  }
}
