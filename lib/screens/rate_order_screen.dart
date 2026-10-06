import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/services/mock_order_service.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/widgets/pill_button.dart';

class RateOrderScreen extends StatefulWidget {
  const RateOrderScreen({
    super.key,
    required this.orderId,
    required this.sellerName,
  });

  final String orderId;
  final String sellerName;

  @override
  State<RateOrderScreen> createState() => _RateOrderScreenState();
}

class _RateOrderScreenState extends State<RateOrderScreen> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _submitted = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0 || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final ok = await MockOrderService.instance.rateOrder(
      widget.orderId,
      stars: _rating,
      comment: _commentController.text,
    );
    if (!mounted) return;
    if (!ok) {
      setState(() {
        _busy = false;
        _error = AppLocalizations.of(context)!.orderNotFound;
      });
      return;
    }
    setState(() {
      _busy = false;
      _submitted = true;
    });
    Future<void>.delayed(const Duration(milliseconds: 600), () {
      if (mounted) Navigator.of(context).pop(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    if (_submitted) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                size: 64,
                color: AppColors.primary.withValues(alpha: 0.9),
              ),
              const SizedBox(height: 16),
              Text(
                t.thanksForReview,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Text(
          t.rateSeller,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${t.experienceWithSellerQuestion} ${widget.sellerName} ?',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final star = index + 1;
                return IconButton(
                  onPressed: _busy ? null : () => setState(() => _rating = star),
                  icon: Icon(
                    star <= _rating ? Icons.star : Icons.star_border,
                    size: 40,
                    color: star <= _rating
                        ? Colors.amber.shade600
                        : Colors.grey.shade400,
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _commentController,
              maxLines: 4,
              enabled: !_busy,
              decoration: InputDecoration(
                hintText: t.commentOptional,
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 13),
              ),
            ],
            const Spacer(),
            PillPrimaryButton(
              label: t.submitReview,
              onPressed: _rating > 0 && !_busy ? _submit : null,
            ),
          ],
        ),
      ),
    );
  }
}
