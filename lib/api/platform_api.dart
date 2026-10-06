import 'package:dio/dio.dart';
import 'package:frip_cash/api/api_client.dart';

class CommissionRates {
  const CommissionRates({
    required this.standard,
    required this.proximite,
    required this.effectiveForMe,
    required this.effectivePercent,
  });

  final double standard;
  final double proximite;
  final double effectiveForMe;
  final double effectivePercent;

  factory CommissionRates.fromJson(Map<String, dynamic> json) {
    final standard = _d(json['standard'] ?? json['commissionRateStandard']);
    final proximite = _d(json['proximite'] ?? json['commissionRateProximite']);
    final effective = _d(json['effectiveForMe'] ?? standard);
    final percent = _d(
      json['effectivePercent'] ?? (effective * 100),
    );
    return CommissionRates(
      standard: standard,
      proximite: proximite,
      effectiveForMe: effective,
      effectivePercent: percent,
    );
  }

  static double _d(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse('$v') ?? 0;
  }
}

class PlatformApi {
  PlatformApi._();
  static final PlatformApi instance = PlatformApi._();

  final _client = ApiClient.instance;
  CommissionRates? _cached;

  CommissionRates? get cached => _cached;

  Future<CommissionRates> fetchCommissionRates() async {
    try {
      final res =
          await _client.get<Map<String, dynamic>>('/platform/commission-rates');
      _cached =
          CommissionRates.fromJson(Map<String, dynamic>.from(res.data ?? {}));
      return _cached!;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
