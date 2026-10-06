import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_typography.dart';

/// Public share URLs (demo deep links for WhatsApp / social).
abstract final class FripShareLinks {
  static const base = 'https://fripcash.app';

  static String listing(String productId) => '$base/listing/$productId';

  static String shop(String sellerId) => '$base/shop/$sellerId';

  static String listingMessage({
    required String title,
    required String productId,
    String? priceLabel,
    String? linkOverride,
  }) {
    final price = priceLabel == null ? '' : ' — $priceLabel';
    final link = (linkOverride != null && linkOverride.isNotEmpty)
        ? linkOverride
        : listing(productId);
    return '$title$price\n$link\n\nVoir sur FripCash';
  }

  static String shopMessage({
    required String shopName,
    required String sellerId,
  }) {
    return '$shopName sur FripCash\n${shop(sellerId)}\n\nDécouvre la boutique';
  }
}

Future<void> showShareLinkSheet(
  BuildContext context, {
  required String title,
  required String link,
  required String whatsAppMessage,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      final t = AppLocalizations.of(context)!;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  t.share,
                  style: AppTypography.style(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.style(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.link_rounded, color: AppColors.primary),
                title: Text(t.copyShareLink),
                subtitle: Text(
                  link,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.style(fontSize: 12),
                ),
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: link));
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(t.shareLinkCopied),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.chat_rounded, color: Color(0xFF25D366)),
                title: Text(t.copyWhatsAppMessage),
                subtitle: Text(t.copyWhatsAppMessageHint),
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: whatsAppMessage));
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(t.whatsAppMessageCopied),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> shareListing(
  BuildContext context, {
  required String productId,
  required String title,
  String? priceLabel,
  String? publicUrl,
}) async {
  final t = AppLocalizations.of(context);
  final link = publicUrl?.trim();
  if (link == null || link.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t.shareLinkSoon),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }
  return showShareLinkSheet(
    context,
    title: title,
    link: link,
    whatsAppMessage: FripShareLinks.listingMessage(
      title: title,
      productId: productId,
      priceLabel: priceLabel,
      linkOverride: link,
    ),
  );
}

Future<void> shareShop(
  BuildContext context, {
  required String sellerId,
  required String shopName,
  String? publicUrl,
}) async {
  final t = AppLocalizations.of(context);
  final link = publicUrl?.trim();
  if (link == null || link.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t.shareLinkSoon),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }
  return showShareLinkSheet(
    context,
    title: shopName,
    link: link,
    whatsAppMessage: '$shopName sur FripCash\n$link\n\nDécouvre la boutique',
  );
}
