/// Home discovery section where a seller's listings appear.
enum ListingDestination {
  secondeMain,
  articlesNeufs,
  quartierBoutiques,
  enseignes,
}

extension ListingDestinationApi on ListingDestination {
  String get apiValue => switch (this) {
        ListingDestination.secondeMain => 'SECONDE_MAIN',
        ListingDestination.articlesNeufs => 'ARTICLES_NEUFS',
        ListingDestination.quartierBoutiques => 'QUARTIER_BOUTIQUES',
        ListingDestination.enseignes => 'ENSEIGNES',
      };
}
