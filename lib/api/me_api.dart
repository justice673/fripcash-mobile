import 'package:dio/dio.dart';
import 'package:frip_cash/api/api_client.dart';
import 'package:frip_cash/models/me_response.dart';
import 'package:frip_cash/models/seller_dashboard.dart';

class MeApi {
  MeApi._();
  static final MeApi instance = MeApi._();

  final _client = ApiClient.instance;

  Future<MeResponse> fetchMe() async {
    try {
      final res = await _client.get<Map<String, dynamic>>('/me');
      return MeResponse.fromJson(Map<String, dynamic>.from(res.data ?? {}));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<MeResponse> fetchCourierMe() async {
    try {
      final res = await _client.get<Map<String, dynamic>>('/courier/me');
      final data = Map<String, dynamic>.from(res.data ?? {});
      // Normalize courier payload so MeResponse marks livreur.
      data['role'] = data['role'] ?? 'livreur';
      data['audience'] = 'COURIER';
      if (data['courierId'] == null && data['id'] != null) {
        data['courierId'] = data['id'];
      }
      return MeResponse.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<MeResponse> becomeParticulier(Map<String, dynamic> body) async {
    try {
      final res = await _client.post<Map<String, dynamic>>(
        '/me/seller/particulier',
        data: body,
      );
      if (res.data != null && res.data!.isNotEmpty) {
        return MeResponse.fromJson(Map<String, dynamic>.from(res.data!));
      }
      return fetchMe();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<MeResponse> becomeShop(Map<String, dynamic> body) async {
    try {
      final res = await _client.post<Map<String, dynamic>>(
        '/me/seller/shop',
        data: body,
      );
      if (res.data != null && res.data!.isNotEmpty) {
        return MeResponse.fromJson(Map<String, dynamic>.from(res.data!));
      }
      return fetchMe();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<SellerDashboard> fetchSellerDashboard() async {
    try {
      final res = await _client.get<Map<String, dynamic>>(
        '/me/seller/dashboard',
      );
      return SellerDashboard.fromJson(Map<String, dynamic>.from(res.data ?? {}));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<MeResponse> patchMe(Map<String, dynamic> body) async {
    try {
      final res = await _client.patch<Map<String, dynamic>>(
        '/me',
        data: body,
      );
      if (res.data != null && res.data!.isNotEmpty) {
        return MeResponse.fromJson(Map<String, dynamic>.from(res.data!));
      }
      return fetchMe();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> patchSellerProfile(Map<String, dynamic> body) async {
    try {
      await _client.patch<Map<String, dynamic>>(
        '/me/seller/profile',
        data: body,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Map<String, dynamic>> fetchPreferences() async {
    try {
      final res = await _client.get<Map<String, dynamic>>('/me/preferences');
      return Map<String, dynamic>.from(res.data ?? {});
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Map<String, dynamic>> patchPreferences(
    Map<String, dynamic> body,
  ) async {
    try {
      final res = await _client.patch<Map<String, dynamic>>(
        '/me/preferences',
        data: body,
      );
      return Map<String, dynamic>.from(res.data ?? body);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<SellerDashboardShare> fetchSellerShare() async {
    try {
      final res = await _client.get<Map<String, dynamic>>('/me/seller/share');
      return SellerDashboardShare.fromJson(
        Map<String, dynamic>.from(res.data ?? {}),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<List<CatalogZone>> fetchZones() async {
    try {
      final res = await _client.get<dynamic>('/catalog/zones');
      final data = res.data;
      final list = data is List
          ? data
          : (data is Map ? (data['items'] ?? data['zones'] ?? []) : []);
      return [
        for (final z in list as List)
          if (z is Map)
            CatalogZone(
              id: (z['id'] ?? z['code'] ?? '').toString(),
              code: (z['code'] ?? z['id'] ?? '').toString(),
              nameFr: (z['nameFr'] ?? z['name'] ?? z['name_fr'] ?? '')
                  .toString(),
              nameEn: (z['nameEn'] ?? z['name'] ?? z['name_en'] ?? '')
                  .toString(),
            ),
      ];
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

class CatalogZone {
  const CatalogZone({
    required this.id,
    required this.code,
    required this.nameFr,
    required this.nameEn,
  });

  final String id;
  final String code;
  final String nameFr;
  final String nameEn;

  String label({required bool french}) => french ? nameFr : nameEn;
}
