import 'package:flutter/foundation.dart';
import 'package:frip_cash/api/api_client.dart';
import 'package:frip_cash/api/conversations_api.dart';
import 'package:frip_cash/api/media_api.dart';
import 'package:frip_cash/models/chat_types.dart';
import 'package:frip_cash/models/conversation_models.dart';
import 'package:frip_cash/models/seller_type.dart';
import 'package:frip_cash/utils/chat_message_guard.dart';
import 'package:image_picker/image_picker.dart';

class ChatThread {
  ChatThread({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.messages,
    this.sellerType,
    this.isSupport = false,
    this.unreadCount = 0,
    this.productId,
    this.sellerId,
    this.orderId,
    this.messagingDisabled = false,
    this.myRoleInThread,
  });

  final String id;
  String title;
  String subtitle;
  final String imageUrl;
  final SellerType? sellerType;
  final bool isSupport;
  int unreadCount;
  final String? productId;
  final String? sellerId;
  final String? orderId;
  final bool messagingDisabled;
  final String? myRoleInThread;
  final List<ChatMessage> messages;

  factory ChatThread.fromApi(
    ApiConversation c, {
    List<ChatMessage> messages = const [],
  }) {
    final preview = c.lastMessagePreview;
    var subtitle = c.subtitle;
    if (subtitle.isEmpty && preview != null) {
      subtitle = switch (preview.kind) {
        'image' => '📷 Photo',
        'card' => preview.text ?? 'Update',
        _ => preview.text ?? '',
      };
    }
    return ChatThread(
      id: c.id,
      title: c.title,
      subtitle: subtitle,
      imageUrl: c.imageUrl ?? '',
      sellerType: c.sellerTypeEnum,
      isSupport: c.isSupport,
      unreadCount: c.unreadCount,
      productId: c.listingId,
      sellerId: c.sellerProfileId,
      orderId: c.orderId,
      messagingDisabled: c.messagingDisabled,
      myRoleInThread: c.myRoleInThread,
      messages: List<ChatMessage>.from(messages),
    );
  }
}

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.isMine,
    required this.sentAtLabel,
    this.kind = ChatMessageKind.text,
    this.text = '',
    this.imageUrl,
    this.card,
    this.createdAtIso,
  });

  final String id;
  final ChatMessageKind kind;
  final String text;
  final String? imageUrl;
  ChatCardPayload? card;
  final bool isMine;
  final String sentAtLabel;
  final String? createdAtIso;

  String get previewText {
    return switch (kind) {
      ChatMessageKind.text => text,
      ChatMessageKind.image => '📷 Photo',
      ChatMessageKind.card => switch (card?.kind) {
          ChatCardKind.confirmReceipt => 'Confirm receipt',
          ChatCardKind.escrowHeld => 'Escrow held',
          ChatCardKind.disputeLocked => 'Dispute',
          ChatCardKind.paymentReleased => 'Payment released',
          ChatCardKind.outForDelivery => 'Out for delivery',
          ChatCardKind.waitingConfirmation => 'Waiting confirmation',
          ChatCardKind.orderSummary => 'Order',
          null => 'Update',
        },
    };
  }

  factory ChatMessage.fromApi(ApiChatMessage m) {
    return ChatMessage(
      id: m.id,
      kind: m.messageKind,
      text: m.text ?? '',
      imageUrl: m.imageUrl,
      card: m.card,
      isMine: m.isMine,
      sentAtLabel: _formatSentLabel(m.createdAt),
      createdAtIso: m.createdAt,
    );
  }
}

String _formatSentLabel(String? iso) {
  if (iso == null || iso.isEmpty) return TimeOfDayNow.label;
  final dt = DateTime.tryParse(iso)?.toLocal();
  if (dt == null) return TimeOfDayNow.label;
  final now = DateTime.now();
  final sameDay =
      dt.year == now.year && dt.month == now.month && dt.day == now.day;
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  if (sameDay) return '$h:$m';
  return '${dt.day}/${dt.month} $h:$m';
}

/// Live Nest conversations — replaces MockChatService.
class ConversationsRepository extends ChangeNotifier {
  ConversationsRepository._();

  static final ConversationsRepository instance = ConversationsRepository._();

  final _api = ConversationsApi.instance;
  final Map<String, ChatThread> _threadsById = {};
  List<ChatThread> _supportThreads = [];
  List<ChatThread> _sellerThreads = [];
  UnreadCounts _unread = const UnreadCounts();
  bool _loadingInbox = false;
  String? _inboxError;

  List<ChatThread> get supportThreads => List.unmodifiable(_supportThreads);
  List<ChatThread> get sellerThreads => List.unmodifiable(_sellerThreads);
  int get totalUnread => _unread.total;
  UnreadCounts get unreadCounts => _unread;
  bool get loadingInbox => _loadingInbox;
  String? get inboxError => _inboxError;

  ChatThread? threadById(String id) => _threadsById[id];

  void _upsertThread(ChatThread thread) {
    _threadsById[thread.id] = thread;
  }

  Future<void> refreshInbox() async {
    _loadingInbox = true;
    _inboxError = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _api.list(tab: 'support'),
        _api.list(tab: 'sellers'),
        _api.unreadCount(),
      ]);
      final supportPage = results[0] as ConversationsPage;
      final sellersPage = results[1] as ConversationsPage;
      _unread = results[2] as UnreadCounts;

      _supportThreads = [
        for (final c in supportPage.items) ChatThread.fromApi(c),
      ];
      _sellerThreads = [
        for (final c in sellersPage.items) ChatThread.fromApi(c),
      ];
      for (final t in [..._supportThreads, ..._sellerThreads]) {
        final existing = _threadsById[t.id];
        if (existing != null && existing.messages.isNotEmpty) {
          t.messages
            ..clear()
            ..addAll(existing.messages);
        }
        _upsertThread(t);
      }
      _loadingInbox = false;
      notifyListeners();
    } on ApiException catch (e) {
      _loadingInbox = false;
      _inboxError = e.message;
      notifyListeners();
      rethrow;
    } catch (e) {
      _loadingInbox = false;
      _inboxError = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> refreshUnread() async {
    try {
      _unread = await _api.unreadCount();
      notifyListeners();
    } catch (_) {
      // Badge best-effort.
    }
  }

  Future<ChatThread> openSupport() async {
    final c = await _api.getSupport();
    final thread = ChatThread.fromApi(c);
    final existing = _threadsById[c.id];
    if (existing != null) {
      thread.messages.addAll(existing.messages);
    }
    _upsertThread(thread);
    final idx = _supportThreads.indexWhere((t) => t.id == thread.id);
    if (idx >= 0) {
      _supportThreads[idx] = thread;
    } else {
      _supportThreads = [thread, ..._supportThreads];
    }
    notifyListeners();
    await loadMessages(thread.id);
    return _threadsById[thread.id]!;
  }

  Future<ChatThread> openSellerThread({
    required String sellerId,
    required String sellerName,
    required String productId,
    required String productTitle,
    required String productImage,
    required SellerType sellerType,
    String? orderId,
  }) async {
    final c = await _api.openSeller(
      sellerProfileId: sellerId,
      listingId: productId,
      orderId: orderId,
    );
    final thread = ChatThread.fromApi(c);
    if (thread.title.isEmpty) thread.title = sellerName;
    if (thread.subtitle.isEmpty) thread.subtitle = productTitle;
    final existing = _threadsById[c.id];
    if (existing != null) {
      thread.messages.addAll(existing.messages);
    }
    _upsertThread(thread);
    final idx = _sellerThreads.indexWhere((t) => t.id == thread.id);
    if (idx >= 0) {
      _sellerThreads[idx] = thread;
    } else {
      _sellerThreads = [thread, ..._sellerThreads];
    }
    notifyListeners();
    await loadMessages(thread.id);
    return _threadsById[thread.id]!;
  }

  Future<void> loadMessages(String threadId, {bool poll = false}) async {
    final thread = _threadsById[threadId];
    String? after;
    if (poll && thread != null && thread.messages.isNotEmpty) {
      after = thread.messages.last.createdAtIso;
    }
    final page = await _api.listMessages(
      threadId,
      after: after,
    );
    final mapped = page.items.map(ChatMessage.fromApi).toList();
    final current = _threadsById[threadId];
    if (current == null) {
      // Ensure header exists.
      try {
        final c = await _api.getById(threadId);
        final t = ChatThread.fromApi(c, messages: mapped);
        _upsertThread(t);
      } catch (_) {
        return;
      }
    } else if (poll && after != null) {
      final existingIds = current.messages.map((m) => m.id).toSet();
      for (final m in mapped) {
        if (!existingIds.contains(m.id)) current.messages.add(m);
      }
      if (mapped.isNotEmpty) {
        current.subtitle = mapped.last.previewText;
      }
    } else {
      current.messages
        ..clear()
        ..addAll(mapped);
      if (mapped.isNotEmpty) {
        current.subtitle = mapped.last.previewText;
      }
    }
    notifyListeners();
  }

  String? validateMessage(
    String text, {
    bool isSupport = false,
    required String emptyMessage,
    required String blockedMessage,
  }) {
    if (isSupport) {
      return text.trim().isEmpty ? emptyMessage : null;
    }
    return ChatMessageGuard.validate(
      text,
      emptyMessage: emptyMessage,
      blockedMessage: blockedMessage,
    );
  }

  Future<bool> sendMessage(
    String threadId,
    String text, {
    required String emptyMessage,
    required String blockedMessage,
  }) async {
    final thread = _threadsById[threadId];
    if (thread == null) return false;
    if (thread.messagingDisabled) {
      throw ApiException(
        code: 'MESSAGING_DISABLED',
        message: blockedMessage,
        statusCode: 403,
      );
    }

    final error = validateMessage(
      text,
      isSupport: thread.isSupport,
      emptyMessage: emptyMessage,
      blockedMessage: blockedMessage,
    );
    if (error != null) {
      throw ApiException(
        code: error == emptyMessage ? 'EMPTY_MESSAGE' : 'MESSAGE_BLOCKED',
        message: error,
        statusCode: 400,
      );
    }

    final trimmed = text.trim();
    final sent = await _api.sendText(threadId, trimmed);
    final msg = ChatMessage.fromApi(sent);
    thread.messages.add(msg);
    thread.subtitle = msg.previewText;
    notifyListeners();
    await refreshUnread();
    return true;
  }

  Future<bool> sendImageFromXFile(String threadId, XFile file) async {
    final thread = _threadsById[threadId];
    if (thread == null || thread.messagingDisabled) return false;

    final bytes = await file.readAsBytes();
    final name = file.name.toLowerCase();
    final mime = name.endsWith('.png')
        ? 'image/png'
        : name.endsWith('.webp')
            ? 'image/webp'
            : 'image/jpeg';
    final uploaded = await MediaApi.instance.uploadCloudinaryBytes(
      bytes: bytes,
      filename: file.name.isEmpty ? 'chat.jpg' : file.name,
      mimeType: mime,
      folder: 'chat',
    );
    final sent = await _api.sendImage(
      threadId,
      publicId: uploaded.publicId,
      url: uploaded.url,
      mimeType: uploaded.mimeType,
    );
    final msg = ChatMessage.fromApi(sent);
    thread.messages.add(msg);
    thread.subtitle = msg.previewText;
    notifyListeners();
    await refreshUnread();
    return true;
  }

  void markCardConfirmed(String threadId, String messageId) {
    final thread = _threadsById[threadId];
    if (thread == null) return;
    for (final msg in thread.messages) {
      if (msg.id == messageId && msg.card != null) {
        msg.card = msg.card!.copyWith(confirmed: true);
        notifyListeners();
        return;
      }
    }
  }

  Future<void> markRead(String threadId) async {
    final thread = _threadsById[threadId];
    try {
      await _api.markRead(threadId);
    } catch (_) {
      // Still clear local badge.
    }
    if (thread != null && thread.unreadCount != 0) {
      thread.unreadCount = 0;
      notifyListeners();
    }
    await refreshUnread();
  }
}

class TimeOfDayNow {
  static String get label {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

/// @Deprecated — use [ConversationsRepository.instance]
typedef MockChatService = ConversationsRepository;
