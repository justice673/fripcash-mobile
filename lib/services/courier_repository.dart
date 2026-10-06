import 'package:flutter/foundation.dart';
import 'package:frip_cash/api/api_client.dart';
import 'package:frip_cash/api/courier_api.dart';
import 'package:frip_cash/api/me_api.dart';
import 'package:frip_cash/api/wallet_api.dart';
import 'package:frip_cash/models/courier_earnings_week.dart';
import 'package:frip_cash/services/mock_session.dart';
import 'package:frip_cash/services/token_store.dart';
import 'package:frip_cash/utils/auth_error_message.dart';

/// Courier missions / profile / earnings — Nest API only.
///
/// Only calls courier endpoints when session audience is [AuthAudience.courier].
/// On failure: empty lists / error — never invents missions or earnings.
class CourierRepository extends ChangeNotifier {
  CourierRepository._();

  static final CourierRepository instance = CourierRepository._();

  bool _useApi = false;
  bool _loading = false;
  String? _error;
  List<CourierMission> _missions = const [];
  CourierMission? _selected;
  CourierEarnings? _earnings;
  CourierMeProfile? _profile;
  bool _isAvailable = false;
  final Map<String, String> _zoneLabels = {};

  bool get usingApi => _useApi;
  bool get isLoading => _loading;
  String? get error => _error;
  List<CourierMission> get missions => List.unmodifiable(_missions);
  CourierMission? get selected => _selected;
  CourierEarnings? get earnings => _earnings;
  CourierMeProfile? get profile => _profile;

  bool get isAvailable => _profile?.isAvailable ?? _isAvailable;

  String get courierId =>
      _profile?.courierId ??
      MockSession.instance.user.courierId ??
      '';

  String get zoneId =>
      _profile?.zoneId ?? MockSession.instance.user.zoneId ?? '';

  Future<bool> get _canUseApi async {
    if (!MockSession.instance.isCourierSession) return false;
    final aud = await TokenStore.instance.readAudience();
    if (aud != null && aud != AuthAudience.courier) return false;
    final token = await TokenStore.instance.readToken();
    return token != null && token.isNotEmpty;
  }

  /// Geo catalog labels (same as admin / seller zones).
  String zoneLabel(String id) {
    if (id.isEmpty) return '—';
    return _zoneLabels[id] ?? _zoneLabels[id.toUpperCase()] ?? id;
  }

  Future<void> _ensureZoneLabels() async {
    if (_zoneLabels.isNotEmpty) return;
    try {
      final zones = await MeApi.instance.fetchZones();
      for (final z in zones) {
        if (z.id.isNotEmpty) _zoneLabels[z.id] = z.nameFr;
        if (z.code.isNotEmpty) _zoneLabels[z.code] = z.nameFr;
      }
    } catch (_) {
      // Labels stay as raw ids until catalog loads.
    }
  }

  Future<void> bootstrap() async {
    await Future.wait([
      _ensureZoneLabels(),
      refreshProfile(),
      refreshMissions(filter: 'active'),
      refreshEarnings(),
    ]);
  }

  Future<void> refreshProfile() async {
    if (!await _canUseApi) {
      _profile = null;
      _error = 'Not authenticated as courier';
      notifyListeners();
      return;
    }
    try {
      final me = await CourierApi.instance.fetchMe();
      _profile = me;
      _isAvailable = me.isAvailable;
      MockSession.instance.mustChangePassword = me.mustChangePassword;
      _useApi = true;
      _error = null;
    } catch (e) {
      _error = authErrorMessage(e);
      _profile = null;
    }
    notifyListeners();
  }

  Future<void> setAvailability(bool value) async {
    if (!await _canUseApi) {
      throw ApiException(
        code: 'UNAUTHORIZED',
        message: 'Not authenticated as courier',
      );
    }
    if (value) {
      if (MockSession.instance.mustChangePassword ||
          (_profile?.mustChangePassword ?? false)) {
        throw ApiException(
          code: 'MUST_CHANGE_PASSWORD',
          message: 'Change your password before going online',
        );
      }
      final p = _profile;
      if (p != null) {
        if (!p.phoneVerified) {
          throw ApiException(
            code: 'PHONE_NOT_VERIFIED',
            message: 'Verify your phone before going online',
          );
        }
        if (p.verificationStatus.toUpperCase() != 'APPROVED') {
          throw ApiException(
            code: 'COURIER_NOT_VERIFIED',
            message: 'Courier account not verified yet',
          );
        }
        if (!p.active) {
          throw ApiException(
            code: 'COURIER_DISABLED',
            message: 'Courier account disabled',
          );
        }
      }
    }
    try {
      final me = await CourierApi.instance.setAvailability(value);
      _profile = me;
      _isAvailable = me.isAvailable;
      MockSession.instance.mustChangePassword = me.mustChangePassword;
      _useApi = true;
      _error = null;
      notifyListeners();
      await refreshMissions(filter: 'active');
    } on ApiException catch (e) {
      _error = authErrorMessage(e);
      notifyListeners();
      rethrow;
    } catch (e) {
      _error = authErrorMessage(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<List<CourierMission>> refreshMissions({
    String filter = 'active',
    String? q,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      if (!await _canUseApi) {
        _missions = const [];
        _error = 'Not authenticated as courier';
        return List.unmodifiable(_missions);
      }
      var list = await CourierApi.instance.listMissions(
        filter: filter,
        q: q,
      );
      // Offline: hide open pool; keep assigned in-progress.
      if (!_isAvailable || !(_profile?.isAvailable ?? _isAvailable)) {
        list = list
            .where((m) => m.status != MissionStatus.open)
            .toList(growable: false);
      }
      _missions = list;
      _useApi = true;
      return List.unmodifiable(_missions);
    } catch (e) {
      _error = authErrorMessage(e);
      _missions = const [];
      return List.unmodifiable(_missions);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<CourierMission?> loadMission(String id) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      if (!await _canUseApi) {
        _selected = null;
        _error = 'Not authenticated as courier';
        return null;
      }
      final mission = await CourierApi.instance.getMission(id);
      _selected = mission;
      _upsert(mission);
      _useApi = true;
      return mission;
    } catch (e) {
      _error = e.toString();
      _selected = null;
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<CourierMission> accept(String id) =>
      _mutate(id, (actionId) => CourierApi.instance.accept(actionId));

  Future<CourierMission> markCollected(String id) =>
      _mutate(id, (actionId) async {
        final collected = await CourierApi.instance.collected(actionId);
        try {
          return await CourierApi.instance.inTransit(actionId);
        } on ApiException catch (e) {
          if (e.code == 'INVALID_MISSION_TRANSITION') return collected;
          rethrow;
        }
      });

  Future<CourierMission> markInTransit(String id) =>
      _mutate(id, (actionId) => CourierApi.instance.inTransit(actionId));

  Future<CourierMission> markDelivered(
    String id, {
    String? proofPhotoUrl,
  }) =>
      _mutate(
        id,
        (actionId) => CourierApi.instance.delivered(
          actionId,
          proofPhotoUrl: proofPhotoUrl,
        ),
      );

  Future<CourierMission> transfer({
    required String id,
    required String toCourierId,
  }) =>
      _mutate(
        id,
        (actionId) => CourierApi.instance.transfer(
          id: actionId,
          toCourierId: toCourierId,
        ),
      );

  Future<List<CourierPeer>> peers({String? zoneId}) async {
    final z = zoneId ?? this.zoneId;
    if (!await _canUseApi) {
      _error = 'Not authenticated as courier';
      return const [];
    }
    try {
      final list = await CourierApi.instance.peers(zoneId: z);
      _useApi = true;
      _error = null;
      return list;
    } catch (e) {
      _error = e.toString();
      return const [];
    }
  }

  Future<CourierEarnings> refreshEarnings({String? from, String? to}) async {
    if (!await _canUseApi) {
      _error = 'Not authenticated as courier';
      _earnings = null;
      notifyListeners();
      return const CourierEarnings(
        todayGnf: 0,
        weekGnf: 0,
        totalGnf: 0,
        availableGnf: 0,
        missionCount: 0,
        entries: [],
      );
    }
    try {
      final e = await CourierApi.instance.earnings(from: from, to: to);
      _earnings = e;
      _useApi = true;
      _error = null;
      notifyListeners();
      return e;
    } catch (err) {
      _error = err.toString();
      _earnings = null;
      notifyListeners();
      return const CourierEarnings(
        todayGnf: 0,
        weekGnf: 0,
        totalGnf: 0,
        availableGnf: 0,
        missionCount: 0,
        entries: [],
      );
    }
  }

  List<CourierEarningsWeek> weeklyChart({
    required String currentWeekLabel,
    required String week1Label,
    required String week2Label,
    required String week3Label,
    required String week4Label,
    required String week5Label,
  }) {
    final api = _earnings;
    if (api == null || api.entries.isEmpty) return const [];
    final labels = [
      currentWeekLabel,
      week1Label,
      week2Label,
      week3Label,
      week4Label,
      week5Label,
    ];
    return [
      for (var i = 0; i < api.entries.length && i < labels.length; i++)
        CourierEarningsWeek(
          label: api.entries[i].label.isNotEmpty
              ? api.entries[i].label
              : labels[i],
          amountGnf: api.entries[i].amountGnf,
          highlighted: i == 0,
        ),
    ];
  }

  Future<CourierMission> _mutate(
    String id,
    Future<CourierMission> Function(String actionId) run,
  ) async {
    try {
      if (!await _canUseApi) {
        throw ApiException(
          code: 'UNAUTHORIZED',
          message: 'Not authenticated as courier',
        );
      }
      final mission = await run(id);
      _upsert(mission);
      _selected = mission;
      _useApi = true;
      _error = null;
      notifyListeners();
      return mission;
    } on ApiException {
      rethrow;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void _upsert(CourierMission mission) {
    final i = _missions.indexWhere(
      (m) => m.id == mission.id || m.orderId == mission.orderId,
    );
    if (i >= 0) {
      _missions = [..._missions]..[i] = mission;
    } else {
      _missions = [mission, ..._missions];
    }
  }
}
