import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/models/listing_destination.dart';

String listingDestinationLabel(ListingDestination destination, AppLocalizations t) {
  return switch (destination) {
    ListingDestination.secondeMain => t.listingDestinationSecondeMain,
    ListingDestination.articlesNeufs => t.listingDestinationArticlesNeufs,
    ListingDestination.quartierBoutiques => t.listingDestinationQuartier,
    ListingDestination.enseignes => t.listingDestinationEnseignes,
  };
}
