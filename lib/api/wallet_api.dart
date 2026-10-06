import 'package:dio/dio.dart';
import 'package:frip_cash/api/api_client.dart';
import 'package:frip_cash/api/checkout_api.dart';
import 'package:frip_cash/mock/mock_wallet_transactions.dart';

int _int(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.round();
  return int.tryParse('$v') ?? 0;
}

/// GET `/wallet` (and `/wallet/balance` alias).
class WalletBalance {
  const WalletBalance({
    required this.ownerUserId,
    required this.role,
    required this.currency,
    required this.availableGnf,
    required this.pendingEscrowGnf,
    required this.minWithdrawalGnf,
    this.defaultPayoutMsisdn,
  });

  final String ownerUserId;
  final String role;
  final String currency;
  final int availableGnf;
  final int pendingEscrowGnf;
  final int minWithdrawalGnf;
  final String? defaultPayoutMsisdn;

  bool get canWithdraw => availableGnf >= minWithdrawalGnf;

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    return WalletBalance(
      ownerUserId: (json['ownerUserId'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      currency: (json['currency'] ?? 'GNF').toString(),
      availableGnf: _int(json['availableGnf'] ?? json['balanceGnf']),
      pendingEscrowGnf: _int(json['pendingEscrowGnf'] ?? json['escrowGnf']),
      minWithdrawalGnf: _int(json['minWithdrawalGnf'] ?? 10000),
      defaultPayoutMsisdn: json['defaultPayoutMsisdn']?.toString() ??
          json['orangeMoneyPhone']?.toString(),
    );
  }
}

/// Single ledger row from GET `/wallet/ledger`.
class LedgerEntry {
  const LedgerEntry({
    required this.id,
    required this.type,
    required this.direction,
    required this.amountGnf,
    required this.label,
    required this.createdAt,
    this.balanceBucket,
    this.orderId,
    this.withdrawalId,
    this.idempotencyKey,
  });

  final String id;
  final String type;
  final String direction;
  final int amountGnf;
  final String label;
  final String createdAt;
  final String? balanceBucket;
  final String? orderId;
  final String? withdrawalId;
  final String? idempotencyKey;

  bool get isCredit => direction.toLowerCase() == 'credit';

  factory LedgerEntry.fromJson(Map<String, dynamic> json) {
    return LedgerEntry(
      id: (json['id'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      direction: (json['direction'] ?? '').toString(),
      amountGnf: _int(json['amountGnf']),
      label: (json['label'] ?? json['type'] ?? '').toString(),
      createdAt: (json['createdAt'] ?? '').toString(),
      balanceBucket: json['balanceBucket']?.toString(),
      orderId: json['orderId']?.toString(),
      withdrawalId: json['withdrawalId']?.toString(),
      idempotencyKey: json['idempotencyKey']?.toString(),
    );
  }

  WalletTransaction toWalletTransaction() {
    return WalletTransaction(
      id: id,
      type: ledgerTypeToWalletTransactionType(type),
      amountGnf: amountGnf,
      label: label,
      dateLabel: _isoToDateLabel(createdAt),
      isCredit: isCredit ||
          type == 'escrow_release' ||
          type == 'delivery_fee_credit' ||
          type == 'refund' ||
          type == 'partial_refund',
    );
  }
}

WalletTransactionType ledgerTypeToWalletTransactionType(String raw) {
  switch (raw.toLowerCase()) {
    case 'escrow_hold':
      return WalletTransactionType.escrowHold;
    case 'escrow_release':
      return WalletTransactionType.escrowRelease;
    case 'platform_commission':
      return WalletTransactionType.platformCommission;
    case 'delivery_fee_credit':
      return WalletTransactionType.deliveryFee;
    case 'withdrawal':
    case 'withdrawal_fee':
      return WalletTransactionType.withdrawal;
    case 'refund':
      return WalletTransactionType.refund;
    case 'partial_refund':
      return WalletTransactionType.partialRefund;
    case 'adjustment':
      return WalletTransactionType.adjustment;
    default:
      return WalletTransactionType.adjustment;
  }
}

String _isoToDateLabel(String iso) {
  if (iso.isEmpty) return '';
  final dt = DateTime.tryParse(iso)?.toLocal();
  if (dt == null) return iso;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(dt.year, dt.month, dt.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return "Aujourd'hui";
  if (diff == 1) return 'Hier';
  const months = [
    'jan',
    'fév',
    'mar',
    'avr',
    'mai',
    'juin',
    'juil',
    'aoû',
    'sep',
    'oct',
    'nov',
    'déc',
  ];
  return '${dt.day} ${months[dt.month - 1]}';
}

class LedgerPage {
  const LedgerPage({
    required this.items,
    this.nextCursor,
  });

  final List<LedgerEntry> items;
  final String? nextCursor;

  factory LedgerPage.fromJson(dynamic data) {
    if (data is List) {
      return LedgerPage(
        items: [
          for (final e in data)
            if (e is Map)
              LedgerEntry.fromJson(Map<String, dynamic>.from(e)),
        ],
      );
    }
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final raw = map['items'] ?? map['entries'] ?? map['ledger'];
      final items = <LedgerEntry>[];
      if (raw is List) {
        for (final e in raw) {
          if (e is Map) {
            items.add(LedgerEntry.fromJson(Map<String, dynamic>.from(e)));
          }
        }
      }
      return LedgerPage(
        items: items,
        nextCursor: map['nextCursor']?.toString() ?? map['cursor']?.toString(),
      );
    }
    return const LedgerPage(items: []);
  }
}

enum WithdrawalStatus {
  pending,
  succeeded,
  failed,
  cancelled,
  unknown,
}

WithdrawalStatus withdrawalStatusFromApi(String? raw) {
  switch ((raw ?? '').toLowerCase()) {
    case 'pending':
      return WithdrawalStatus.pending;
    case 'succeeded':
    case 'success':
      return WithdrawalStatus.succeeded;
    case 'failed':
      return WithdrawalStatus.failed;
    case 'cancelled':
    case 'canceled':
      return WithdrawalStatus.cancelled;
    default:
      return WithdrawalStatus.unknown;
  }
}

class Withdrawal {
  const Withdrawal({
    required this.withdrawalId,
    required this.status,
    required this.amountGnf,
    required this.orangeMoneyPhone,
    this.createdAt,
  });

  final String withdrawalId;
  final WithdrawalStatus status;
  final int amountGnf;
  final String orangeMoneyPhone;
  final String? createdAt;

  factory Withdrawal.fromJson(Map<String, dynamic> json) {
    return Withdrawal(
      withdrawalId:
          (json['withdrawalId'] ?? json['id'] ?? '').toString(),
      status: withdrawalStatusFromApi(json['status']?.toString()),
      amountGnf: _int(json['amountGnf']),
      orangeMoneyPhone: (json['orangeMoneyPhone'] ?? '').toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }
}

/// Series point for courier earnings history.
class CourierEarningsEntry {
  const CourierEarningsEntry({
    required this.label,
    required this.amountGnf,
    this.date,
  });

  final String label;
  final int amountGnf;
  final String? date;

  factory CourierEarningsEntry.fromJson(Map<String, dynamic> json) {
    return CourierEarningsEntry(
      label: (json['label'] ?? json['period'] ?? json['date'] ?? '').toString(),
      amountGnf: _int(json['amountGnf'] ?? json['totalGnf'] ?? json['gnf']),
      date: json['date']?.toString(),
    );
  }
}

/// GET `/courier/earnings`.
class CourierEarnings {
  const CourierEarnings({
    required this.todayGnf,
    required this.weekGnf,
    required this.totalGnf,
    required this.availableGnf,
    this.missionCount,
    this.entries = const [],
  });

  final int todayGnf;
  final int weekGnf;
  final int totalGnf;
  final int availableGnf;
  final int? missionCount;
  final List<CourierEarningsEntry> entries;

  factory CourierEarnings.fromJson(Map<String, dynamic> json) {
    final raw = json['entries'] ?? json['series'];
    final entries = <CourierEarningsEntry>[];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map) {
          entries.add(
            CourierEarningsEntry.fromJson(Map<String, dynamic>.from(e)),
          );
        } else if (e is num) {
          entries.add(
            CourierEarningsEntry(label: '', amountGnf: e.round()),
          );
        }
      }
    }
    return CourierEarnings(
      todayGnf: _int(json['todayGnf']),
      weekGnf: _int(json['weekGnf'] ?? json['periodGnf']),
      totalGnf: _int(json['totalGnf']),
      availableGnf: _int(json['availableGnf']),
      missionCount: json['missionCount'] != null
          ? _int(json['missionCount'])
          : null,
      entries: entries,
    );
  }
}

class WalletApi {
  WalletApi._();
  static final WalletApi instance = WalletApi._();

  final _client = ApiClient.instance;

  Future<WalletBalance> getWallet() async {
    try {
      final res = await _client.get<Map<String, dynamic>>('/wallet');
      return WalletBalance.fromJson(Map<String, dynamic>.from(res.data ?? {}));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Alias for [getWallet].
  Future<WalletBalance> getBalance() async {
    try {
      final res = await _client.get<Map<String, dynamic>>('/wallet/balance');
      return WalletBalance.fromJson(Map<String, dynamic>.from(res.data ?? {}));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<LedgerPage> getLedger({
    String? type,
    String? cursor,
    int? limit,
  }) async {
    try {
      final query = <String, dynamic>{};
      if (type != null && type.isNotEmpty) query['type'] = type;
      if (cursor != null && cursor.isNotEmpty) query['cursor'] = cursor;
      if (limit != null) query['limit'] = limit;
      final res = await _client.get<dynamic>(
        '/wallet/ledger',
        queryParameters: query.isEmpty ? null : query,
      );
      return LedgerPage.fromJson(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Withdrawal> withdraw({
    required int amountGnf,
    required String orangeMoneyPhone,
    String? idempotencyKey,
  }) async {
    try {
      final key = idempotencyKey ?? newIdempotencyKey();
      final res = await _client.post<Map<String, dynamic>>(
        '/wallet/withdraw',
        data: {
          'amountGnf': amountGnf,
          'orangeMoneyPhone': orangeMoneyPhone,
        },
        headers: {'Idempotency-Key': key},
      );
      return Withdrawal.fromJson(Map<String, dynamic>.from(res.data ?? {}));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Withdrawal> getWithdrawal(String id) async {
    try {
      final res =
          await _client.get<Map<String, dynamic>>('/wallet/withdrawals/$id');
      return Withdrawal.fromJson(Map<String, dynamic>.from(res.data ?? {}));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<WalletBalance> updatePayoutMsisdn(String orangeMoneyPhone) async {
    try {
      final res = await _client.patch<Map<String, dynamic>>(
        '/wallet/payout-msisdn',
        data: {'orangeMoneyPhone': orangeMoneyPhone},
      );
      final data = res.data;
      if (data == null || data.isEmpty) return getWallet();
      return WalletBalance.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<CourierEarnings> getCourierEarnings({
    String? from,
    String? to,
  }) async {
    try {
      final query = <String, dynamic>{};
      if (from != null && from.isNotEmpty) query['from'] = from;
      if (to != null && to.isNotEmpty) query['to'] = to;
      final res = await _client.get<Map<String, dynamic>>(
        '/courier/earnings',
        queryParameters: query.isEmpty ? null : query,
      );
      return CourierEarnings.fromJson(
        Map<String, dynamic>.from(res.data ?? {}),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
