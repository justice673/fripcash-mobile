import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/models/chat_types.dart';
import 'package:frip_cash/models/order_status.dart';
import 'package:frip_cash/services/mock_order_service.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/utils/price_formatter.dart';
import 'package:frip_cash/widgets/safe_network_image.dart';

class ChatSystemCard extends StatelessWidget {
  const ChatSystemCard({
    super.key,
    required this.card,
    this.onConfirmReceipt,
    this.onOpenDispute,
  });

  final ChatCardPayload card;
  final Future<bool> Function(String orderId)? onConfirmReceipt;
  final Future<bool> Function(String orderId)? onOpenDispute;

  @override
  Widget build(BuildContext context) {
    return switch (card.kind) {
      ChatCardKind.orderSummary => _OrderSummary(card: card),
      ChatCardKind.escrowHeld => _InfoCard(
          icon: Icons.shield_outlined,
          title: AppLocalizations.of(context)!.chatCardEscrowHeldTitle,
          body: AppLocalizations.of(context)!.chatCardEscrowHeldBody(
            card.orderId ?? '',
          ),
          color: AppColors.primary,
        ),
      ChatCardKind.waitingConfirmation => _InfoCard(
          icon: Icons.hourglass_top_rounded,
          title: AppLocalizations.of(context)!.chatCardWaitingTitle,
          body: AppLocalizations.of(context)!.chatCardWaitingBody(
            card.orderId ?? '',
          ),
          color: Colors.amber.shade800,
        ),
      ChatCardKind.paymentReleased => _InfoCard(
          icon: Icons.check_circle_outline,
          title: AppLocalizations.of(context)!.chatCardReleasedTitle,
          body: AppLocalizations.of(context)!.chatCardReleasedBody(
            card.orderId ?? '',
          ),
          color: AppColors.sage,
        ),
      ChatCardKind.disputeLocked => _InfoCard(
          icon: Icons.gavel_outlined,
          title: AppLocalizations.of(context)!.chatCardDisputeTitle,
          body: AppLocalizations.of(context)!.chatCardDisputeBody(
            card.orderId ?? '',
          ),
          color: const Color(0xFFB91C1C),
        ),
      ChatCardKind.outForDelivery => _InfoCard(
          icon: Icons.local_shipping_outlined,
          title: AppLocalizations.of(context)!.chatCardOfdTitle,
          body: AppLocalizations.of(context)!.chatCardOfdBody(
            card.orderId ?? '',
          ),
          color: Colors.lightBlue.shade700,
        ),
      ChatCardKind.confirmReceipt => _ConfirmReceiptCard(
          card: card,
          onConfirmReceipt: onConfirmReceipt,
          onOpenDispute: onOpenDispute,
        ),
    };
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child, this.borderColor, this.bgColor});

  final Widget child;
  final Color? borderColor;
  final Color? bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: bgColor ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor ?? Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.card});

  final ChatCardPayload card;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.grey.shade50,
            child: Row(
              children: [
                const Icon(Icons.inventory_2_outlined,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  t.chatCardOrderLabel(card.orderId ?? ''),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                if (card.productImage != null)
                  SafeNetworkImage(
                    url: card.productImage!,
                    width: 56,
                    height: 56,
                    borderRadius: BorderRadius.circular(8),
                  ),
                if (card.productImage != null) const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.productTitle ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      if (card.amountGnf != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${formatPrice(card.amountGnf!)} GNF',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      borderColor: color.withValues(alpha: 0.35),
      bgColor: color.withValues(alpha: 0.06),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: AppColors.textPrimary.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmReceiptCard extends StatefulWidget {
  const _ConfirmReceiptCard({
    required this.card,
    this.onConfirmReceipt,
    this.onOpenDispute,
  });

  final ChatCardPayload card;
  final Future<bool> Function(String orderId)? onConfirmReceipt;
  final Future<bool> Function(String orderId)? onOpenDispute;

  @override
  State<_ConfirmReceiptCard> createState() => _ConfirmReceiptCardState();
}

class _ConfirmReceiptCardState extends State<_ConfirmReceiptCard> {
  late bool _done = widget.card.confirmed;
  bool _disputed = false;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final orderId = widget.card.orderId;
    final order =
        orderId == null ? null : MockOrderService.instance.orderById(orderId);
    final status = order?.status;

    if (status?.isDisputed == true || _disputed) {
      return _InfoCard(
        icon: Icons.gavel_outlined,
        title: t.chatCardDisputeTitle,
        body: t.chatCardDisputeBody(orderId ?? ''),
        color: const Color(0xFFB91C1C),
      );
    }

    if (status?.isPaymentReleased == true ||
        status?.isRefunded == true ||
        _done) {
      return _InfoCard(
        icon: Icons.check_circle_outline,
        title: t.chatCardReceiptDoneTitle,
        body: t.chatCardReceiptDoneBody(orderId ?? ''),
        color: AppColors.sage,
      );
    }

    return _CardShell(
      borderColor: AppColors.primary.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            color: AppColors.primary.withValues(alpha: 0.06),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      t.chatCardReceivedTitle,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  t.chatCardReceivedBody(
                    orderId ?? '',
                    widget.card.amountGnf != null
                        ? '${formatPrice(widget.card.amountGnf!)} GNF'
                        : '',
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: AppColors.textPrimary.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: SizedBox(
              height: 42,
              child: FilledButton(
                onPressed: orderId == null
                    ? null
                    : () async {
                        final handler = widget.onConfirmReceipt;
                        if (handler == null) return;
                        final ok = await handler(orderId);
                        if (ok && mounted) {
                          setState(() => _done = true);
                        }
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(t.confirmReceiptButton),
              ),
            ),
          ),
          TextButton(
            onPressed: orderId == null || widget.onOpenDispute == null
                ? null
                : () async {
                    final ok = await widget.onOpenDispute!(orderId);
                    if (ok && mounted) {
                      setState(() => _disputed = true);
                    }
                  },
            child: Text(
              t.disputeReportLink,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
