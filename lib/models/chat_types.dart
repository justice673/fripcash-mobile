enum ChatMessageKind { text, image, card }

enum ChatCardKind {
  orderSummary,
  escrowHeld,
  waitingConfirmation,
  paymentReleased,
  disputeLocked,
  outForDelivery,
  confirmReceipt,
}

class ChatCardPayload {
  const ChatCardPayload({
    required this.kind,
    this.orderId,
    this.productTitle,
    this.productImage,
    this.amountGnf,
    this.deliveryMethod,
    this.confirmed = false,
  });

  final ChatCardKind kind;
  final String? orderId;
  final String? productTitle;
  final String? productImage;
  final int? amountGnf;
  final String? deliveryMethod;
  final bool confirmed;

  ChatCardPayload copyWith({bool? confirmed}) {
    return ChatCardPayload(
      kind: kind,
      orderId: orderId,
      productTitle: productTitle,
      productImage: productImage,
      amountGnf: amountGnf,
      deliveryMethod: deliveryMethod,
      confirmed: confirmed ?? this.confirmed,
    );
  }
}

/// Unicode emoji set matching thriftcash Apple picker.
const chatEmojiPicker = <String>[
  '😁',
  '😂',
  '😍',
  '🔥',
  '👍',
  '👏',
  '👌',
  '🙏',
  '👋',
  '✅',
  '🎉',
  '👀',
  '🤔',
  '💬',
  '📦',
  '🔑',
  '🔔',
  '🚚',
  '🛍️',
  '💳',
];
