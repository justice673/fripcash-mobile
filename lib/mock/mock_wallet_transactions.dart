enum WalletTransactionType {
  saleCredit,
  withdrawal,
  deliveryFee,
  escrowHold,
  escrowRelease,
  refund,
  partialRefund,
  platformCommission,
  adjustment,
}

class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.type,
    required this.amountGnf,
    required this.label,
    required this.dateLabel,
    this.isCredit = false,
  });

  final String id;
  final WalletTransactionType type;
  final int amountGnf;
  final String label;
  final String dateLabel;
  final bool isCredit;
}

const mockWalletTransactionsBuyer = <WalletTransaction>[
  WalletTransaction(
    id: 'tx_b1',
    type: WalletTransactionType.escrowHold,
    amountGnf: 50000,
    label: 'Paiement commande #ord_1001 (en attente)',
    dateLabel: 'Aujourd\'hui',
  ),
];

const mockWalletTransactionsSeller = <WalletTransaction>[
  WalletTransaction(
    id: 'tx_s1',
    type: WalletTransactionType.saleCredit,
    amountGnf: 185000,
    label: 'Vente créditée — Robe fleurie vintage',
    dateLabel: 'Hier',
    isCredit: true,
  ),
  WalletTransaction(
    id: 'tx_s2',
    type: WalletTransactionType.escrowHold,
    amountGnf: 75000,
    label: 'Fonds bloqués — commande #ord_1002',
    dateLabel: 'Hier',
  ),
  WalletTransaction(
    id: 'tx_s3',
    type: WalletTransactionType.escrowRelease,
    amountGnf: 65000,
    label: 'Paiement débloqué — commande #ord_1003',
    dateLabel: '12 juin',
    isCredit: true,
  ),
  WalletTransaction(
    id: 'tx_s4',
    type: WalletTransactionType.withdrawal,
    amountGnf: 100000,
    label: 'Retrait Orange Money',
    dateLabel: '10 juin',
  ),
  WalletTransaction(
    id: 'tx_s5',
    type: WalletTransactionType.deliveryFee,
    amountGnf: 5000,
    label: 'Frais livraison (livreur)',
    dateLabel: '8 juin',
  ),
];
