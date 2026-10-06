import 'package:frip_cash/models/chat_types.dart';
import 'package:frip_cash/models/seller_type.dart';

class MockMessage {
  const MockMessage({
    required this.id,
    required this.isMine,
    required this.sentAtLabel,
    this.kind = ChatMessageKind.text,
    this.text = '',
    this.imageUrl,
    this.card,
  });

  final String id;
  final ChatMessageKind kind;
  final String text;
  final String? imageUrl;
  final ChatCardPayload? card;
  final bool isMine;
  final String sentAtLabel;
}

class MockConversation {
  const MockConversation({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.sellerType,
    required this.messages,
    this.isSupport = false,
    this.unreadCount = 0,
    this.productId,
    this.sellerId,
    this.orderId,
  });

  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final SellerType? sellerType;
  final List<MockMessage> messages;
  final bool isSupport;
  final int unreadCount;
  final String? productId;
  final String? sellerId;
  final String? orderId;
}

const mockConversations = <MockConversation>[
  MockConversation(
    id: 'conv_support',
    title: 'Support FripCash',
    subtitle: 'Comment pouvons-nous t\'aider ?',
    imageUrl: 'assets/images/logo.png',
    sellerType: null,
    isSupport: true,
    unreadCount: 1,
    messages: [
      MockMessage(
        id: 'm1',
        text: 'Bonjour ! Une question sur une commande ?',
        isMine: false,
        sentAtLabel: '10:30',
      ),
    ],
  ),
  MockConversation(
    id: 'conv_aminata',
    title: 'aminata_v',
    subtitle: 'Robe fleurie vintage',
    imageUrl:
        'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=100&h=100&fit=crop',
    sellerType: SellerType.particulier,
    sellerId: 'seller_aminata',
    productId: '1',
    messages: [
      MockMessage(
        id: 'm2',
        text: 'Bonjour, la robe est-elle toujours disponible ?',
        isMine: true,
        sentAtLabel: '09:15',
      ),
      MockMessage(
        id: 'm3',
        text: 'Oui, elle est en très bon état ! 👍',
        isMine: false,
        sentAtLabel: '09:20',
      ),
    ],
  ),
  MockConversation(
    id: 'conv_ibrahim',
    title: 'ibrahim_shop',
    subtitle: 'Baskets blanches',
    imageUrl:
        'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=100&h=100&fit=crop',
    sellerType: SellerType.boutique,
    sellerId: 'seller_ibrahim',
    productId: '2',
    orderId: 'ord_1007',
    unreadCount: 2,
    messages: [
      MockMessage(
        id: 'm4',
        text: 'Quelle est la pointure exacte ?',
        isMine: true,
        sentAtLabel: 'Hier',
      ),
      MockMessage(
        id: 'm5',
        kind: ChatMessageKind.card,
        isMine: false,
        sentAtLabel: 'Hier',
        card: ChatCardPayload(
          kind: ChatCardKind.orderSummary,
          orderId: 'ord_1007',
          productTitle: 'Baskets blanches',
          productImage:
              'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=200&h=200&fit=crop',
          amountGnf: 85000,
        ),
      ),
      MockMessage(
        id: 'm6',
        kind: ChatMessageKind.card,
        isMine: false,
        sentAtLabel: 'Hier',
        card: ChatCardPayload(
          kind: ChatCardKind.escrowHeld,
          orderId: 'ord_1007',
          amountGnf: 85000,
        ),
      ),
      MockMessage(
        id: 'm7',
        kind: ChatMessageKind.card,
        isMine: false,
        sentAtLabel: '10:05',
        card: ChatCardPayload(
          kind: ChatCardKind.outForDelivery,
          orderId: 'ord_1007',
          deliveryMethod: 'Livreur',
        ),
      ),
      MockMessage(
        id: 'm8',
        kind: ChatMessageKind.card,
        isMine: false,
        sentAtLabel: '10:12',
        card: ChatCardPayload(
          kind: ChatCardKind.confirmReceipt,
          orderId: 'ord_1007',
          amountGnf: 85000,
        ),
      ),
      MockMessage(
        id: 'm9',
        text: 'Colis remis — confirmez la réception quand vous avez vérifié 📦',
        isMine: false,
        sentAtLabel: '10:12',
      ),
    ],
  ),
];
