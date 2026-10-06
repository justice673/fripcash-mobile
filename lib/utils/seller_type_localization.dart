import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/models/seller_type.dart';

extension SellerTypeLocalization on SellerType {
  String localizedLabel(AppLocalizations t) => switch (this) {
        SellerType.particulier => t.individualSellerRole,
        SellerType.boutique => t.shopRole,
        SellerType.enseigne => t.partnerBrandLabel,
      };
}
