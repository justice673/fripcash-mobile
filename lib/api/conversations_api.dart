import 'package:dio/dio.dart';
import 'package:frip_cash/api/api_client.dart';
import 'package:frip_cash/models/conversation_models.dart';

class ConversationsApi {
  ConversationsApi._();
  static final ConversationsApi instance = ConversationsApi._();

  final _client = ApiClient.instance;

  Future<ConversationsPage> list({
    required String tab,
    String? cursor,
    int limit = 30,
  }) async {
    try {
      final res = await _client.get<Map<String, dynamic>>(
        '/conversations',
        queryParameters: {
          'tab': tab,
          'limit': limit.clamp(1, 50),
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        },
      );
      final data = Map<String, dynamic>.from(res.data ?? {});
      final raw = data['items'];
      final items = <ApiConversation>[];
      if (raw is List) {
        for (final row in raw) {
          if (row is! Map) continue;
          final c = ApiConversation.fromJson(Map<String, dynamic>.from(row));
          if (c.id.isEmpty) continue;
          items.add(c);
        }
      }
      return ConversationsPage(
        items: items,
        nextCursor: data['nextCursor']?.toString(),
        unreadTotal: data['unreadTotal'] is num
            ? (data['unreadTotal'] as num).toInt()
            : int.tryParse('${data['unreadTotal']}') ?? 0,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<UnreadCounts> unreadCount() async {
    try {
      final res = await _client.get<Map<String, dynamic>>(
        '/conversations/unread-count',
      );
      return UnreadCounts.fromJson(Map<String, dynamic>.from(res.data ?? {}));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<ApiConversation> getSupport() async {
    try {
      final res = await _client.get<Map<String, dynamic>>(
        '/conversations/support',
      );
      return ApiConversation.fromJson(Map<String, dynamic>.from(res.data ?? {}));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<ApiConversation> getById(String id) async {
    try {
      final res = await _client.get<Map<String, dynamic>>(
        '/conversations/$id',
      );
      return ApiConversation.fromJson(Map<String, dynamic>.from(res.data ?? {}));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<ApiConversation> openSeller({
    required String sellerProfileId,
    String? listingId,
    String? orderId,
  }) async {
    try {
      final res = await _client.post<Map<String, dynamic>>(
        '/conversations',
        data: {
          'sellerProfileId': sellerProfileId,
          if (listingId != null && listingId.isNotEmpty) 'listingId': listingId,
          if (orderId != null && orderId.isNotEmpty) 'orderId': orderId,
        },
      );
      return ApiConversation.fromJson(Map<String, dynamic>.from(res.data ?? {}));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<MessagesPage> listMessages(
    String conversationId, {
    String? after,
    String? cursor,
    int limit = 50,
  }) async {
    try {
      final res = await _client.get<Map<String, dynamic>>(
        '/conversations/$conversationId/messages',
        queryParameters: {
          'limit': limit.clamp(1, 100),
          if (after != null && after.isNotEmpty) 'after': after,
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        },
      );
      final data = Map<String, dynamic>.from(res.data ?? {});
      final raw = data['items'];
      final items = <ApiChatMessage>[];
      if (raw is List) {
        for (final row in raw) {
          if (row is! Map) continue;
          final m = ApiChatMessage.fromJson(Map<String, dynamic>.from(row));
          if (m.id.isEmpty) continue;
          items.add(m);
        }
      }
      return MessagesPage(
        items: items,
        nextCursor: data['nextCursor']?.toString(),
        serverNow: data['serverNow']?.toString(),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<ApiChatMessage> sendText(String conversationId, String text) async {
    try {
      final res = await _client.post<Map<String, dynamic>>(
        '/conversations/$conversationId/messages',
        data: {
          'kind': 'text',
          'text': text,
        },
      );
      return ApiChatMessage.fromJson(Map<String, dynamic>.from(res.data ?? {}));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<ApiChatMessage> sendImage(
    String conversationId, {
    required String publicId,
    required String url,
    String mimeType = 'image/jpeg',
  }) async {
    try {
      final res = await _client.post<Map<String, dynamic>>(
        '/conversations/$conversationId/messages/images',
        data: {
          'publicId': publicId,
          'url': url,
          'mimeType': mimeType,
        },
      );
      return ApiChatMessage.fromJson(Map<String, dynamic>.from(res.data ?? {}));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> markRead(String conversationId) async {
    try {
      await _client.post<Map<String, dynamic>>(
        '/conversations/$conversationId/read',
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
