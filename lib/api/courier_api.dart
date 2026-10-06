import 'package:dio/dio.dart';
import 'package:frip_cash/api/api_client.dart';
import 'package:frip_cash/api/wallet_api.dart';
import 'package:frip_cash/models/order_status.dart';

int _int(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.round();
  return int.tryParse('$v') ?? 0;
}

bool _bool(dynamic v, {bool fallback = false}) {
  if (v is bool) return v;
  if (v == null) return fallback;
  final s = '$v'.toLowerCase();
  if (s == 'true' || s == '1') return true;
  if (s == 'false' || s == '0') return false;
  return fallback;
}

String _str(dynamic v, [String fallback = '']) =>
    v == null ? fallback : v.toString();

Map<String, dynamic>? _map(dynamic v) {
  if (v is Map<String, dynamic>) return v;
  if (v is Map) return Map<String, dynamic>.from(v);
  return null;
}

dynamic _nested(Map<String, dynamic> json, String key, String nestedKey) {
  final m = _map(json[key]);
  return m?[nestedKey];
}

DateTime? _date(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  return DateTime.tryParse(v.toString());
}

String formatMissionCreatedLabel(DateTime? at) {
  if (at == null) return '';
  final now = DateTime.now();
  final local = at.toLocal();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(local.year, local.month, local.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  if (diff > 1 && diff < 7) return '$diff days ago';
  final dd = local.day.toString().padLeft(2, '0');
  final mm = local.month.toString().padLeft(2, '0');
  return '$dd/$mm/${local.year}';
}

/// Mission lifecycle on Nest (`open` … `cancelled`).
enum MissionStatus {
  open,
  assigned,
  collected,
  inTransit,
  delivered,
  cancelled;

  static MissionStatus fromApi(String? raw) {
    switch ((raw ?? '').toLowerCase().replaceAll('-', '_')) {
      case 'open':
        return MissionStatus.open;
      case 'assigned':
      case 'courier_assigned':
      case 'courierassigned':
        return MissionStatus.assigned;
      case 'collected':
        return MissionStatus.collected;
      case 'in_transit':
      case 'intransit':
        return MissionStatus.inTransit;
      case 'delivered':
        return MissionStatus.delivered;
      case 'cancelled':
      case 'canceled':
        return MissionStatus.cancelled;
      default:
        return MissionStatus.open;
    }
  }

  String get apiValue => switch (this) {
        MissionStatus.open => 'open',
        MissionStatus.assigned => 'assigned',
        MissionStatus.collected => 'collected',
        MissionStatus.inTransit => 'in_transit',
        MissionStatus.delivered => 'delivered',
        MissionStatus.cancelled => 'cancelled',
      };

  /// Map to marketplace [OrderStatus] for existing UI helpers.
  OrderStatus get asOrderStatus => switch (this) {
        MissionStatus.open => OrderStatus.readyForPickup,
        MissionStatus.assigned => OrderStatus.courierAssigned,
        MissionStatus.collected => OrderStatus.collected,
        MissionStatus.inTransit => OrderStatus.inTransit,
        MissionStatus.delivered => OrderStatus.delivered,
        MissionStatus.cancelled => OrderStatus.disputed,
      };

  static MissionStatus fromOrderStatus(OrderStatus status) {
    if (status.index >= OrderStatus.delivered.index) {
      return MissionStatus.delivered;
    }
    if (status.index >= OrderStatus.inTransit.index) {
      return MissionStatus.inTransit;
    }
    if (status.index >= OrderStatus.collected.index) {
      return MissionStatus.collected;
    }
    if (status.index >= OrderStatus.courierAssigned.index) {
      return MissionStatus.assigned;
    }
    return MissionStatus.open;
  }
}

class MissionLineSummary {
  const MissionLineSummary({
    required this.title,
    required this.qty,
    this.size,
    this.coverUrl,
  });

  final String title;
  final int qty;
  final String? size;
  final String? coverUrl;

  factory MissionLineSummary.fromJson(dynamic raw) {
    if (raw is! Map) {
      return const MissionLineSummary(title: '', qty: 1);
    }
    final json = Map<String, dynamic>.from(raw);
    return MissionLineSummary(
      title: _str(json['title'] ?? json['name']),
      qty: _int(json['qty'] ?? json['quantity'] ?? 1),
      size: json['size']?.toString(),
      coverUrl: json['coverUrl']?.toString() ?? json['imageUrl']?.toString(),
    );
  }
}

/// First-class courier mission (list card + detail).
class CourierMission {
  const CourierMission({
    required this.id,
    required this.orderId,
    required this.status,
    required this.pickupZoneId,
    required this.deliveryZoneId,
    required this.deliveryFeeGnf,
    required this.sellerName,
    required this.createdAtLabel,
    this.courierId,
    this.courierName,
    this.sellerId,
    this.sellerPhone,
    this.pickupAddress,
    this.buyerName,
    this.buyerPhone,
    this.buyerAddress,
    this.buyerLandmark,
    this.totalGnf = 0,
    this.lineSummary,
    this.createdAt,
    this.proofPhotoUrl,
    this.distanceLabel,
    this.etaLabel,
    this.arrivalLabel,
  });

  final String id;
  final String orderId;
  final MissionStatus status;
  final String pickupZoneId;
  final String deliveryZoneId;
  final int deliveryFeeGnf;
  final String sellerName;
  final String createdAtLabel;
  final String? courierId;
  final String? courierName;
  final String? sellerId;
  final String? sellerPhone;
  final String? pickupAddress;
  final String? buyerName;
  final String? buyerPhone;
  final String? buyerAddress;
  final String? buyerLandmark;
  final int totalGnf;
  final MissionLineSummary? lineSummary;
  final DateTime? createdAt;
  final String? proofPhotoUrl;
  final String? distanceLabel;
  final String? etaLabel;
  final String? arrivalLabel;

  bool get isOpen => status == MissionStatus.open;
  bool get isAssigned => status == MissionStatus.assigned;
  bool get isCompleted =>
      status == MissionStatus.delivered || status == MissionStatus.cancelled;
  bool get isActive => !isCompleted && status != MissionStatus.cancelled;

  OrderStatus get orderStatus => status.asOrderStatus;

  /// Prefer mission id for actions; Nest also accepts order id.
  String get actionId => id.isNotEmpty ? id : orderId;

  factory CourierMission.fromJson(Map<String, dynamic> json) {
    final created = _date(json['createdAt']);
    final line = json['lineSummary'] ?? json['line'];
    final order = _map(json['order']);
    return CourierMission(
      id: _str(json['id'] ?? json['missionId']),
      orderId: _str(json['orderId'] ?? order?['id'] ?? json['id']),
      status: MissionStatus.fromApi(
        json['status']?.toString() ?? json['missionStatus']?.toString(),
      ),
      pickupZoneId: _str(
        json['pickupZoneId'] ?? _nested(json, 'pickupZone', 'id'),
      ),
      deliveryZoneId: _str(
        json['deliveryZoneId'] ??
            _nested(json, 'deliveryZone', 'id') ??
            json['buyerZoneId'],
      ),
      deliveryFeeGnf: _int(
        json['deliveryFeeGnf'] ?? json['deliveryFee'] ?? json['feeGnf'],
      ),
      sellerName: _str(
        json['sellerName'] ??
            _nested(json, 'seller', 'name') ??
            _nested(json, 'seller', 'username'),
      ),
      createdAtLabel: _str(
        json['createdAtLabel'] ?? json['expectedLabel'],
        formatMissionCreatedLabel(created),
      ),
      courierId: json['courierId']?.toString(),
      courierName: json['courierName']?.toString(),
      sellerId: (json['sellerId'] ?? _nested(json, 'seller', 'id'))?.toString(),
      sellerPhone:
          (json['sellerPhone'] ?? _nested(json, 'seller', 'phone'))?.toString(),
      pickupAddress: json['pickupAddress']?.toString(),
      buyerName: json['buyerName']?.toString(),
      buyerPhone: json['buyerPhone']?.toString(),
      buyerAddress: (json['buyerAddressLine'] ??
              json['buyerAddress'] ??
              json['deliveryAddress'])
          ?.toString(),
      buyerLandmark: json['buyerLandmark']?.toString(),
      totalGnf: _int(json['totalGnf'] ?? json['orderTotalGnf']),
      lineSummary: line is Map
          ? MissionLineSummary.fromJson(Map<String, dynamic>.from(line))
          : null,
      createdAt: created,
      proofPhotoUrl: json['proofPhotoUrl']?.toString(),
      distanceLabel: () {
        final label = json['distanceLabel']?.toString();
        if (label != null && label.isNotEmpty) return label;
        final km = json['distanceKm'];
        if (km == null) return null;
        return '$km km';
      }(),
      etaLabel: () {
        final label = json['etaLabel']?.toString();
        if (label != null && label.isNotEmpty) return label;
        final mins = json['etaMinutes'];
        if (mins == null) return null;
        return '$mins min';
      }(),
      arrivalLabel: json['arrivalLabel']?.toString(),
    );
  }

  CourierMission copyWith({
    MissionStatus? status,
    String? courierId,
    String? courierName,
    String? proofPhotoUrl,
  }) {
    return CourierMission(
      id: id,
      orderId: orderId,
      status: status ?? this.status,
      pickupZoneId: pickupZoneId,
      deliveryZoneId: deliveryZoneId,
      deliveryFeeGnf: deliveryFeeGnf,
      sellerName: sellerName,
      createdAtLabel: createdAtLabel,
      courierId: courierId ?? this.courierId,
      courierName: courierName ?? this.courierName,
      sellerId: sellerId,
      sellerPhone: sellerPhone,
      pickupAddress: pickupAddress,
      buyerName: buyerName,
      buyerPhone: buyerPhone,
      buyerAddress: buyerAddress,
      buyerLandmark: buyerLandmark,
      totalGnf: totalGnf,
      lineSummary: lineSummary,
      createdAt: createdAt,
      proofPhotoUrl: proofPhotoUrl ?? this.proofPhotoUrl,
      distanceLabel: distanceLabel,
      etaLabel: etaLabel,
      arrivalLabel: arrivalLabel,
    );
  }
}

class CourierPeer {
  const CourierPeer({
    required this.id,
    required this.name,
    required this.phone,
    this.isAvailable = true,
  });

  final String id;
  final String name;
  final String phone;
  final bool isAvailable;

  factory CourierPeer.fromJson(Map<String, dynamic> json) {
    return CourierPeer(
      id: _str(json['id'] ?? json['courierId']),
      name: _str(json['name'] ?? json['displayName']),
      phone: _str(json['phone']),
      isAvailable: _bool(json['isAvailable'], fallback: true),
    );
  }
}

class CourierMeProfile {
  const CourierMeProfile({
    required this.courierId,
    required this.displayName,
    required this.phone,
    required this.zoneId,
    required this.isAvailable,
    required this.isVerified,
    required this.verificationStatus,
    this.userId,
    this.address,
    this.vehicleType,
    this.plateNumber,
    this.memberSince,
    this.documents = const [],
    this.phoneVerifiedAt,
    this.mustChangePassword = false,
    this.active = true,
  });

  final String? userId;
  final String courierId;
  final String displayName;
  final String phone;
  final String zoneId;
  final String? address;
  final bool isAvailable;
  final bool isVerified;
  final String verificationStatus;
  final String? vehicleType;
  final String? plateNumber;
  final String? memberSince;
  final List<CourierDocumentDto> documents;
  final String? phoneVerifiedAt;
  final bool mustChangePassword;
  final bool active;

  bool get phoneVerified =>
      phoneVerifiedAt != null && phoneVerifiedAt!.trim().isNotEmpty;

  bool get canGoOnline =>
      active &&
      phoneVerified &&
      !mustChangePassword &&
      verificationStatus.toUpperCase() == 'APPROVED';

  factory CourierMeProfile.fromJson(Map<String, dynamic> json) {
    final vehicle = _map(json['vehicle']);
    final zoneIds = json['zoneIds'];
    String zoneId = _str(json['zoneId']);
    if (zoneId.isEmpty && zoneIds is List && zoneIds.isNotEmpty) {
      zoneId = zoneIds.first.toString();
    }
    final docs = <CourierDocumentDto>[];
    final rawDocs = json['documents'];
    if (rawDocs is List) {
      for (final d in rawDocs) {
        if (d is Map) {
          docs.add(CourierDocumentDto.fromJson(Map<String, dynamic>.from(d)));
        }
      }
    }
    final phoneVerifiedAt = json['phoneVerifiedAt']?.toString();
    final verificationStatus = _str(json['verificationStatus'], 'none');
    return CourierMeProfile(
      userId: json['userId']?.toString(),
      courierId: _str(json['courierId'] ?? json['id']),
      displayName: _str(json['displayName'] ?? json['name']),
      phone: _str(json['phone']),
      zoneId: zoneId,
      address: json['address']?.toString(),
      isAvailable: _bool(json['isAvailable'], fallback: false),
      isVerified: _bool(
        json['isVerified'],
        fallback: verificationStatus.toLowerCase() == 'approved',
      ),
      verificationStatus: verificationStatus,
      vehicleType:
          (vehicle?['type'] ?? json['vehicleType'])?.toString(),
      plateNumber: (vehicle?['plateNumber'] ??
              json['plateNumber'] ??
              json['licensePlate'])
          ?.toString(),
      memberSince: (json['memberSince'] ?? json['createdAt'])?.toString(),
      documents: docs,
      phoneVerifiedAt: phoneVerifiedAt,
      mustChangePassword: json['mustChangePassword'] == true,
      active: json['active'] != false,
    );
  }
}

class CourierDocumentDto {
  const CourierDocumentDto({
    required this.type,
    required this.status,
    this.fileUrl,
    this.submittedAt,
    this.rejectionReason,
  });

  final String type;
  final String status;
  final String? fileUrl;
  final String? submittedAt;
  final String? rejectionReason;

  factory CourierDocumentDto.fromJson(Map<String, dynamic> json) {
    return CourierDocumentDto(
      type: _str(json['type']),
      status: _str(json['status'], 'pending'),
      fileUrl: json['fileUrl']?.toString(),
      submittedAt: json['submittedAt']?.toString(),
      rejectionReason: json['rejectionReason']?.toString(),
    );
  }
}

/// Nest courier / missions API (`aud: courier`).
class CourierApi {
  CourierApi._();
  static final CourierApi instance = CourierApi._();

  final _client = ApiClient.instance;

  List<CourierMission> _parseMissions(dynamic data) {
    final list = data is List
        ? data
        : (data is Map
            ? (data['items'] ?? data['missions'] ?? data['data'] ?? [])
            : []);
    final out = <CourierMission>[];
    if (list is! List) return out;
    for (final item in list) {
      if (item is Map) {
        out.add(CourierMission.fromJson(Map<String, dynamic>.from(item)));
      }
    }
    return out;
  }

  Future<CourierMeProfile> fetchMe() async {
    try {
      final res = await _client.get<Map<String, dynamic>>('/courier/me');
      return CourierMeProfile.fromJson(
        Map<String, dynamic>.from(res.data ?? {}),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<CourierMeProfile> setAvailability(bool isAvailable) async {
    try {
      final res = await _client.patch<Map<String, dynamic>>(
        '/courier/me/availability',
        data: {'isAvailable': isAvailable},
      );
      if (res.data != null && res.data!.isNotEmpty) {
        return CourierMeProfile.fromJson(
          Map<String, dynamic>.from(res.data!),
        );
      }
      return fetchMe();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<CourierMeProfile> updateProfile({
    String? displayName,
    String? address,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (displayName != null) body['displayName'] = displayName;
      if (address != null) body['address'] = address;
      final res = await _client.patch<Map<String, dynamic>>(
        '/courier/me/profile',
        data: body,
      );
      if (res.data != null && res.data!.isNotEmpty) {
        return CourierMeProfile.fromJson(
          Map<String, dynamic>.from(res.data!),
        );
      }
      return fetchMe();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> uploadDocument({
    required String type,
    required String fileUrl,
  }) async {
    try {
      await _client.post(
        '/courier/me/documents',
        data: {'type': type, 'fileUrl': fileUrl},
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<List<CourierMission>> listMissions({
    String filter = 'active',
    String? q,
  }) async {
    try {
      final res = await _client.get<dynamic>(
        '/missions',
        queryParameters: {
          'filter': filter,
          if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
        },
      );
      return _parseMissions(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<CourierMission> getMission(String id) async {
    try {
      final res = await _client.get<Map<String, dynamic>>('/missions/$id');
      return CourierMission.fromJson(
        Map<String, dynamic>.from(res.data ?? {}),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<CourierMission> accept(String id) async {
    try {
      final res = await _client.post<Map<String, dynamic>>(
        '/missions/$id/accept',
        data: const <String, dynamic>{},
      );
      if (res.data != null && res.data!.isNotEmpty) {
        return CourierMission.fromJson(Map<String, dynamic>.from(res.data!));
      }
      return getMission(id);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<CourierMission> collected(String id) async {
    try {
      final res = await _client.post<Map<String, dynamic>>(
        '/missions/$id/collected',
        data: const <String, dynamic>{},
      );
      if (res.data != null && res.data!.isNotEmpty) {
        return CourierMission.fromJson(Map<String, dynamic>.from(res.data!));
      }
      return getMission(id);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<CourierMission> inTransit(String id) async {
    try {
      final res = await _client.post<Map<String, dynamic>>(
        '/missions/$id/in-transit',
        data: const <String, dynamic>{},
      );
      if (res.data != null && res.data!.isNotEmpty) {
        return CourierMission.fromJson(Map<String, dynamic>.from(res.data!));
      }
      return getMission(id);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<CourierMission> delivered(
    String id, {
    String? proofPhotoUrl,
  }) async {
    try {
      final res = await _client.post<Map<String, dynamic>>(
        '/missions/$id/delivered',
        data: {
          if (proofPhotoUrl != null && proofPhotoUrl.isNotEmpty)
            'proofPhotoUrl': proofPhotoUrl,
        },
      );
      if (res.data != null && res.data!.isNotEmpty) {
        return CourierMission.fromJson(Map<String, dynamic>.from(res.data!));
      }
      return getMission(id);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<CourierMission> transfer({
    required String id,
    required String toCourierId,
  }) async {
    try {
      final res = await _client.post<Map<String, dynamic>>(
        '/missions/$id/transfer',
        data: {'toCourierId': toCourierId},
      );
      if (res.data != null && res.data!.isNotEmpty) {
        return CourierMission.fromJson(Map<String, dynamic>.from(res.data!));
      }
      return getMission(id);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<List<CourierPeer>> peers({String? zoneId}) async {
    try {
      final res = await _client.get<dynamic>(
        '/courier/peers',
        queryParameters: {
          if (zoneId != null && zoneId.isNotEmpty) 'zoneId': zoneId,
        },
      );
      final data = res.data;
      final list = data is List
          ? data
          : (data is Map ? (data['items'] ?? data['peers'] ?? []) : []);
      final out = <CourierPeer>[];
      if (list is! List) return out;
      for (final item in list) {
        if (item is Map) {
          out.add(CourierPeer.fromJson(Map<String, dynamic>.from(item)));
        }
      }
      return out;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Same contract as [WalletApi.getCourierEarnings] (`aud: courier`).
  Future<CourierEarnings> earnings({String? from, String? to}) {
    return WalletApi.instance.getCourierEarnings(from: from, to: to);
  }
}
