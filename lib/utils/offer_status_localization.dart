import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/models/offer.dart';

extension OfferStatusLocalization on OfferStatus {
  String localizedLabel(AppLocalizations t) => switch (this) {
        OfferStatus.pending => t.offerStatusPending,
        OfferStatus.accepted => t.accepted,
        OfferStatus.refused => t.offerStatusRefused,
        OfferStatus.cancelled => t.offerStatusRefused,
        OfferStatus.expired => t.offerStatusRefused,
        OfferStatus.consumed => t.accepted,
      };
}
