import 'package:frip_cash/models/chat_types.dart';
import 'package:frip_cash/models/seller_type.dart';

class ConversationPreview {
  const ConversationPreview({
    required this.kind,
    this.text,
  });

  final String kind; // text | image | card
  final String? text;

  factory ConversationPreview.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ConversationPreview(kind: 'text', text: null);
    }
    return ConversationPreview(
      kind: (json['kind'] ?? 'text').toString(),
      text: json['text']?.toString(),
    );
  }
}

class ApiConversation {
  const ApiConversation({
    required this.id,
    required this.kind,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.buyerUserId,
    this.sellerProfileId,
    this.listingId,
    this.orderId,
    this.sellerType,
    this.messagingDisabled = false,
    this.myRoleInThread,
    this.unreadCount = 0,
    this.lastMessageAt,
    this.lastMessagePreview,
    this.supportStatus,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String kind; // SELLER | SUPPORT
  final String title;
  final String subtitle;
  final String? imageUrl;
  final String? buyerUserId;
  final String? sellerProfileId;
  final String? listingId;
  final String? orderId;
  final String? sellerType;
  final bool messagingDisabled;
  final String? myRoleInThread;
  final int unreadCount;
  final String? lastMessageAt;
  final ConversationPreview? lastMessagePreview;
  final String? supportStatus;
  final String? createdAt;
  final String? updatedAt;

  bool get isSupport => kind.toUpperCase() == 'SUPPORT';

  SellerType? get sellerTypeEnum {
    switch ((sellerType ?? '').toUpperCase()) {
      case 'PARTICULIER':
        return SellerType.particulier;
      case 'BOUTIQUE':
        return SellerType.boutique;
      case 'ENSEIGNE':
        return SellerType.enseigne;
      default:
        return null;
    }
  }

  factory ApiConversation.fromJson(Map<String, dynamic> json) {
    final previewRaw = json['lastMessagePreview'];
    return ApiConversation(
      id: (json['id'] ?? '').toString(),
      kind: (json['kind'] ?? 'SELLER').toString().toUpperCase(),
      title: (json['title'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      imageUrl: json['imageUrl']?.toString(),
      buyerUserId: json['buyerUserId']?.toString(),
      sellerProfileId:
          (json['sellerProfileId'] ?? json['sellerId'])?.toString(),
      listingId: (json['listingId'] ?? json['productId'])?.toString(),
      orderId: json['orderId']?.toString(),
      sellerType: json['sellerType']?.toString(),
      messagingDisabled: json['messagingDisabled'] == true,
      myRoleInThread: json['myRoleInThread']?.toString(),
      unreadCount: (json['unreadCount'] is num)
          ? (json['unreadCount'] as num).toInt()
          : int.tryParse('${json['unreadCount']}') ?? 0,
      lastMessageAt: json['lastMessageAt']?.toString(),
      lastMessagePreview: previewRaw is Map
          ? ConversationPreview.fromJson(Map<String, dynamic>.from(previewRaw))
          : null,
      supportStatus: json['supportStatus']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }
}

class ApiChatMessage {
  const ApiChatMessage({
    required this.id,
    required this.conversationId,
    required this.kind,
    required this.isMine,
    this.senderRole,
    this.senderUserId,
    this.senderDisplayName,
    this.text,
    this.imageUrl,
    this.imagePublicId,
    this.card,
    this.createdAt,
    this.clientBlocked = false,
  });

  final String id;
  final String conversationId;
  final String kind; // text | image | card
  final bool isMine;
  final String? senderRole;
  final String? senderUserId;
  final String? senderDisplayName;
  final String? text;
  final String? imageUrl;
  final String? imagePublicId;
  final ChatCardPayload? card;
  final String? createdAt;
  final bool clientBlocked;

  factory ApiChatMessage.fromJson(Map<String, dynamic> json) {
    final cardRaw = json['card'];
    return ApiChatMessage(
      id: (json['id'] ?? '').toString(),
      conversationId: (json['conversationId'] ?? '').toString(),
      kind: (json['kind'] ?? 'text').toString().toLowerCase(),
      isMine: json['isMine'] == true,
      senderRole: json['senderRole']?.toString(),
      senderUserId: json['senderUserId']?.toString(),
      senderDisplayName: json['senderDisplayName']?.toString(),
      text: json['text']?.toString() ?? json['body']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      imagePublicId: json['imagePublicId']?.toString(),
      card: cardRaw is Map
          ? _parseCard(Map<String, dynamic>.from(cardRaw))
          : null,
      createdAt: json['createdAt']?.toString(),
      clientBlocked: json['clientBlocked'] == true,
    );
  }

  ChatMessageKind get messageKind {
    return switch (kind) {
      'image' => ChatMessageKind.image,
      'card' => ChatMessageKind.card,
      _ => ChatMessageKind.text,
    };
  }

  static ChatCardPayload? _parseCard(Map<String, dynamic> json) {
    final rawKind = (json['kind'] ?? '').toString();
    final kind = _cardKindFromApi(rawKind);
    if (kind == null) return null;
    return ChatCardPayload(
      kind: kind,
      orderId: json['orderId']?.toString(),
      productTitle: json['productTitle']?.toString(),
      productImage:
          (json['productImageUrl'] ?? json['productImage'])?.toString(),
      amountGnf: json['amountGnf'] is num
          ? (json['amountGnf'] as num).toInt()
          : int.tryParse('${json['amountGnf']}'),
      deliveryMethod: json['deliveryMethod']?.toString(),
      confirmed: json['confirmed'] == true,
    );
  }

  static ChatCardKind? _cardKindFromApi(String raw) {
    final k = raw.toLowerCase().replaceAll('-', '_');
    return switch (k) {
      'order_summary' || 'ordersummary' => ChatCardKind.orderSummary,
      'escrow_held' || 'escrowheld' => ChatCardKind.escrowHeld,
      'waiting_confirmation' || 'waitingconfirmation' =>
        ChatCardKind.waitingConfirmation,
      'payment_released' || 'paymentreleased' => ChatCardKind.paymentReleased,
      'dispute_locked' || 'disputelocked' => ChatCardKind.disputeLocked,
      'out_for_delivery' || 'outfordelivery' => ChatCardKind.outForDelivery,
      'confirm_receipt' || 'confirmreceipt' => ChatCardKind.confirmReceipt,
      _ => null,
    };
  }
}

class ConversationsPage {
  const ConversationsPage({
    required this.items,
    this.nextCursor,
    this.unreadTotal = 0,
  });

  final List<ApiConversation> items;
  final String? nextCursor;
  final int unreadTotal;
}

class MessagesPage {
  const MessagesPage({
    required this.items,
    this.nextCursor,
    this.serverNow,
  });

  final List<ApiChatMessage> items;
  final String? nextCursor;
  final String? serverNow;
}

class UnreadCounts {
  const UnreadCounts({
    this.sellers = 0,
    this.support = 0,
    this.total = 0,
  });

  final int sellers;
  final int support;
  final int total;

  factory UnreadCounts.fromJson(Map<String, dynamic> json) {
    int n(dynamic v) =>
        v is num ? v.toInt() : int.tryParse('$v') ?? 0;
    return UnreadCounts(
      sellers: n(json['sellers']),
      support: n(json['support']),
      total: n(json['total']),
    );
  }
}
