import 'package:flutter/material.dart';
import 'package:frip_cash/api/api_client.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/models/product.dart';
import 'package:frip_cash/services/offers_repository.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/utils/price_formatter.dart';

void showMakeOfferSheet(
  BuildContext context, {
  required Product product,
  required String sellerName,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => MakeOfferSheet(
      product: product,
      sellerName: sellerName,
    ),
  );
}

class MakeOfferSheet extends StatefulWidget {
  const MakeOfferSheet({
    super.key,
    required this.product,
    required this.sellerName,
  });

  final Product product;
  final String sellerName;

  @override
  State<MakeOfferSheet> createState() => _MakeOfferSheetState();
}

class _MakeOfferSheetState extends State<MakeOfferSheet> {
  final _offerController = TextEditingController();
  String? _error;
  bool _submitting = false;

  int? get _offeredPrice => int.tryParse(_offerController.text.trim());

  bool get _canSubmit {
    final price = _offeredPrice;
    if (price == null || price <= 0 || _submitting) return false;
    return price < widget.product.price;
  }

  Future<void> _submit() async {
    final t = AppLocalizations.of(context);
    final price = _offeredPrice;
    if (price == null || price <= 0 || price >= widget.product.price) {
      setState(() => _error = t.offerMustBeLower);
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await OffersRepository.instance.submitOffer(
        product: widget.product,
        sellerName: widget.sellerName,
        offeredPrice: price,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.offerSentToSeller),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _offerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            t.makeOfferAction,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.product.title,
            style: TextStyle(fontSize: 15, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t.displayPricePrefix,
                style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
              ),
              Text(
                '${formatPrice(widget.product.price)} GNF',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _offerController,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() => _error = null),
            decoration: InputDecoration(
              labelText: t.yourOfferGnf,
              hintText:
                  '${t.examplePrefix} ${formatPrice((widget.product.price * 0.85).round())}',
              errorText: _error,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _canSubmit ? _submit : null,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: _submitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    t.sendOffer,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ],
      ),
    );
  }
}
