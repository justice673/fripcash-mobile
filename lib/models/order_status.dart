enum OrderStatus {
  ordered,
  paid,
  sellerNotified,
  preparing,
  readyForPickup,
  courierAssigned,
  collected,
  inTransit,
  delivered,
  fundsReleased,
  feedbackPending,
  /// Terminal — payment locked pending admin review (not on happy-path timeline).
  disputed,
  /// Terminal — admin refunded buyer (full or partial).
  refunded;

  /// Fulfillment steps shown on the order timeline (excludes dispute/refund).
  static const List<OrderStatus> timelineSteps = [
    ordered,
    paid,
    sellerNotified,
    preparing,
    readyForPickup,
    courierAssigned,
    collected,
    inTransit,
    delivered,
    fundsReleased,
    feedbackPending,
  ];

  bool get isDisputed => this == OrderStatus.disputed;

  bool get isRefunded => this == OrderStatus.refunded;

  bool get isTerminalException => isDisputed || isRefunded;

  bool get isPaymentReleased =>
      this == OrderStatus.fundsReleased || this == OrderStatus.feedbackPending;
}
