import 'package:flutter/foundation.dart';
import 'package:frip_cash/api/api_client.dart';
import 'package:frip_cash/api/wallet_api.dart';
import 'package:frip_cash/mock/mock_users.dart';
import 'package:frip_cash/mock/mock_wallet_transactions.dart';
import 'package:frip_cash/utils/safe_notify.dart';

/// Seller/courier wallet: Nest API only — no invented demo balances.
class MockWalletService extends ChangeNotifier with SafeNotify {
  MockWalletService._();

  static final MockWalletService instance = MockWalletService._();

  bool _usingApi = false;
  bool _loading = false;
  String? _error;

  int _availableGnf = 0;
  int _pendingEscrowGnf = 0;
  int _minWithdrawalGnf = 10000;
  String? _defaultPayoutMsisdn;
  String _currency = 'GNF';
  String? _role;

  final List<WalletTransaction> _transactions = [];
  CourierEarnings? _courierEarnings;

  /// Available / withdrawable balance (server `availableGnf` when API).
  int get balanceGnf => _availableGnf;
  int get availableGnf => _availableGnf;
  int get pendingEscrowGnf => _pendingEscrowGnf;
  int get minWithdrawalGnf => _minWithdrawalGnf;
  String? get defaultPayoutMsisdn => _defaultPayoutMsisdn;
  String get currency => _currency;
  String? get role => _role;

  bool get usingApi => _usingApi;
  bool get loading => _loading;
  String? get error => _error;

  bool get canWithdraw => _availableGnf >= _minWithdrawalGnf;

  List<WalletTransaction> get transactions => List.unmodifiable(_transactions);
  CourierEarnings? get courierEarnings => _courierEarnings;

  void _applyBalance(WalletBalance wallet) {
    _availableGnf = wallet.availableGnf;
    _pendingEscrowGnf = wallet.pendingEscrowGnf;
    _minWithdrawalGnf = wallet.minWithdrawalGnf;
    _defaultPayoutMsisdn = wallet.defaultPayoutMsisdn;
    _currency = wallet.currency;
    _role = wallet.role;
  }

  void _applyLedger(LedgerPage page) {
    _transactions
      ..clear()
      ..addAll(page.items.map((e) => e.toWalletTransaction()));
  }

  void _resetToZeros() {
    _availableGnf = 0;
    _pendingEscrowGnf = 0;
    _minWithdrawalGnf = 10000;
    _defaultPayoutMsisdn = null;
    _currency = 'GNF';
    _role = null;
    _courierEarnings = null;
    _transactions.clear();
  }

  /// Sync wallet for [user] from Nest. Starts/stays at zeros until API succeeds.
  Future<void> syncForUser(MockUser user) async {
    await refresh(isCourier: user.role == UserRole.livreur);
  }

  /// Refresh from Nest. On failure keeps last successful server state, or zeros
  /// if never synced — never invents demo balances.
  Future<void> refresh({bool isCourier = false}) async {
    _loading = true;
    _error = null;
    safeNotifyListeners();
    try {
      final wallet = await WalletApi.instance.getWallet();
      final ledger = await WalletApi.instance.getLedger(limit: 50);
      _applyBalance(wallet);
      _applyLedger(ledger);
      _usingApi = true;

      if (isCourier || wallet.role == 'courier') {
        try {
          _courierEarnings = await WalletApi.instance.getCourierEarnings();
        } catch (_) {
          // Earnings optional; wallet already loaded.
        }
      }
    } catch (e) {
      _error = e.toString();
      if (!_usingApi) {
        _resetToZeros();
      }
      // Else keep previous successful server snapshot.
    } finally {
      _loading = false;
      safeNotifyListeners();
    }
  }

  /// Withdraw [amountGnf] to [orangeMoneyPhone]. API only.
  Future<Withdrawal?> withdrawToOrangeMoney(
    int amountGnf, {
    required String orangeMoneyPhone,
  }) async {
    if (amountGnf <= 0) return null;
    if (amountGnf > _availableGnf) {
      throw ApiException(
        code: 'INSUFFICIENT_AVAILABLE',
        message: 'Insufficient available balance',
      );
    }
    if (amountGnf < _minWithdrawalGnf) {
      throw ApiException(
        code: 'BELOW_MIN_WITHDRAWAL',
        message: 'Below minimum withdrawal',
      );
    }
    final phone = orangeMoneyPhone.trim();
    if (phone.isEmpty) {
      throw ApiException(
        code: 'INVALID_OM_PHONE',
        message: 'Orange Money phone required',
      );
    }

    final result = await WalletApi.instance.withdraw(
      amountGnf: amountGnf,
      orangeMoneyPhone: phone,
    );
    await refresh(isCourier: _role == 'courier');
    return result;
  }

  Future<void> updatePayoutMsisdn(String orangeMoneyPhone) async {
    final phone = orangeMoneyPhone.trim();
    if (phone.isEmpty) return;
    final wallet = await WalletApi.instance.updatePayoutMsisdn(phone);
    _applyBalance(wallet);
    _usingApi = true;
    _error = null;
    safeNotifyListeners();
  }
}
