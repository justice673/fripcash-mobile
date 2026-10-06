// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'FripCash';

  @override
  String get welcomeBuySell =>
      'Achetez et vendez partout en Guinee - mode, maison, electronique et plus';

  @override
  String get trustBenefitNoCommissionLine1 => 'Aucune';

  @override
  String get trustBenefitNoCommissionLine2 => 'commission';

  @override
  String get trustBenefitLocalCustomersLine1 => 'Clientes de votre';

  @override
  String get trustBenefitLocalCustomersLine2 => 'ville';

  @override
  String get trustBenefitCodLine1 => 'Payée à la';

  @override
  String get trustBenefitCodLine2 => 'livraison';

  @override
  String get signUpButton => 'S\'inscrire sur FripCash';

  @override
  String get alreadyHaveAccount => 'J\'ai deja un compte';

  @override
  String get aboutFripCashPrefix => 'A propos de FripCash : ';

  @override
  String get ourPlatform => 'Notre plateforme';

  @override
  String get sellAnItem => 'Vendre un article';

  @override
  String get cancel => 'Annuler';

  @override
  String get done => 'Termine';

  @override
  String get brand => 'Marque';

  @override
  String get category => 'Categorie';

  @override
  String get condition => 'Etat';

  @override
  String get sizes => 'Tailles';

  @override
  String get colours => 'Couleurs';

  @override
  String get viewSizeGuide => 'Voir le guide des tailles';

  @override
  String get openSizeGuide => 'Ouvrir le guide des tailles';

  @override
  String get allSizes => 'Toutes les tailles';

  @override
  String get backToHome => 'Retour a l\'accueil';

  @override
  String get welcomeBack => 'Bon retour !';

  @override
  String homeHelloName(String name) {
    return 'Bonjour, $name';
  }

  @override
  String get homeWelcomeReady => 'Bon retour,\nPret a continuer';

  @override
  String get homeExploreTitle => 'Explorer';

  @override
  String get homeSearchHint => 'Une robe, du riz, une boutique...';

  @override
  String get homeSearchUniversesHint =>
      'Cherche dans les quatre univers à la fois';

  @override
  String homeLocationLabel(String zone, String quartier) {
    return '$zone - $quartier';
  }

  @override
  String get homeModeSectionTitle => 'Mode';

  @override
  String get homeModeSectionSubtitle => 'vêtements, sacs, chaussures';

  @override
  String get homeCoursesSectionTitle => 'Courses';

  @override
  String get homeCoursesSectionSubtitle => 'alimentaire et maison';

  @override
  String get homeUniverseSecondeMainSubtitle => 'Entre particuliers';

  @override
  String get homeUniverseArticlesNeufsSubtitle => 'Boutiques et commerçants';

  @override
  String get homeUniverseQuartierSubtitle => 'Retrait par code';

  @override
  String get homeUniverseEnseignesSubtitle => 'Livraison en ville';

  @override
  String homeUniverseArticlesCount(int count) {
    return '$count articles';
  }

  @override
  String homeUniverseQuartierCount(int count, String quartier) {
    return '$count à $quartier';
  }

  @override
  String homeUniverseEnseignesCount(int count) {
    return '$count chez toi';
  }

  @override
  String get homeNouveautesTitle => 'Nouveautés';

  @override
  String get homeTwoUniversesTitle => 'Deux univers, jamais mélangés.';

  @override
  String get homeTwoUniversesBody =>
      'La mode et l\'alimentaire ne se croisent nulle part, sauf dans la recherche.';

  @override
  String get homeBigSaleTitle => 'Grande vente';

  @override
  String get homeBigSaleOffer => 'Jusqu\'a 50%';

  @override
  String get homeBigSaleNow => 'En ce moment';

  @override
  String get homeSearchHintShort => 'Rechercher...';

  @override
  String get loginSubtitle => 'Connecte-toi a ton compte pour continuer.';

  @override
  String get phoneNumber => 'Numero de telephone';

  @override
  String get password => 'Mot de passe';

  @override
  String get forgotPasswordQuestion => 'Mot de passe oublie ?';

  @override
  String get yourPassword => 'Ton mot de passe';

  @override
  String get signIn => 'Se connecter';

  @override
  String get courierSpaceDemo => 'Espace livreur (demo)';

  @override
  String get noAccountPrompt => 'Tu n\'as pas de compte ? ';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get joinFripCash => 'Rejoins FripCash';

  @override
  String get signUpSubtitle => 'Trois etapes, et c\'est parti.';

  @override
  String get signUpStepAccountTitle => 'Role';

  @override
  String get signUpStepAccountSubtitle => 'Qui tu es';

  @override
  String get signUpStepProfileTitle => 'Details';

  @override
  String get signUpStepProfileSubtitle => 'Tes infos';

  @override
  String get signUpStepLoginTitle => 'Compte';

  @override
  String get signUpStepLoginSubtitle => 'Identifiants';

  @override
  String get signUpStepCommerceTitle => 'Ton commerce';

  @override
  String get signUpStepCommerceSubtitle => 'Perimetre';

  @override
  String get signUpStepInfosTitle => 'Tes infos';

  @override
  String get signUpStepInfosSubtitle => 'Compte & boutique';

  @override
  String get signUpStepSellerTitle => 'Vendeur';

  @override
  String get signUpStepSellerSubtitle => 'Infos vente';

  @override
  String get signUpContinue => 'Continuer';

  @override
  String get iSignUpAs => 'Je m\'inscris en tant que';

  @override
  String get shopNameLabel => 'Nom de la boutique';

  @override
  String get nameLabel => 'Nom';

  @override
  String get shopNameHint => 'Le nom de ta boutique';

  @override
  String get fullNameHint => 'Ton nom complet';

  @override
  String get zone => 'Zone';

  @override
  String get chooseYourZone => 'Choisis ta zone';

  @override
  String get detailedAddress => 'Adresse detaillee';

  @override
  String get addressHint => 'Rue, quartier, point de repere';

  @override
  String get maxDeliveryDelay => 'Delai de livraison maximal';

  @override
  String get chooseDelay => 'Choisis un delai';

  @override
  String get shopLogo => 'Logo de la boutique';

  @override
  String get logoAddedPreview => 'Logo ajoute (apercu)';

  @override
  String get addLogo => 'Ajouter un logo';

  @override
  String get shopDescription => 'Description de la boutique';

  @override
  String get describeBusiness => 'Decris ton activite';

  @override
  String get choosePassword => 'Choisis un mot de passe';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get confirmYourPassword => 'Confirme ton mot de passe';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas.';

  @override
  String get passwordStrengthWeak => 'Faible';

  @override
  String get passwordStrengthFair => 'Moyen';

  @override
  String get passwordStrengthGood => 'Bon';

  @override
  String get passwordStrengthStrong => 'Fort';

  @override
  String passwordStrengthHintMin(int count) {
    return 'Au moins $count caracteres requis';
  }

  @override
  String get passwordStrengthHintOk => 'C\'est bien parti';

  @override
  String passwordRuleMinLength(int count) {
    return '$count+ caracteres';
  }

  @override
  String get passwordRuleLetter => 'Une lettre';

  @override
  String get passwordRuleDigit => 'Un chiffre';

  @override
  String get needHelp => 'Besoin d\'aide ?';

  @override
  String get alreadyHaveAccountPrompt => 'Tu as deja un compte ? ';

  @override
  String get buyerRole => 'Acheteur';

  @override
  String get individualSellerRole => 'Particulier';

  @override
  String get shopRole => 'Boutique';

  @override
  String get enseigneQuartierRole => 'Enseigne / quartier';

  @override
  String get signUpRoleBuyerSubtitle => 'Je veux juste acheter';

  @override
  String get signUpRoleSellerSubtitle => 'Je vends ce que je ne porte plus';

  @override
  String get signUpRoleSellerFootnote => 'mes annonces vont dans Seconde main';

  @override
  String get signUpRoleShopSubtitle => 'Je vends des articles neufs';

  @override
  String get signUpRoleShopFootnote => 'mes annonces vont dans Articles neufs';

  @override
  String get commerceLocalRole => 'Commerce local';

  @override
  String get signUpRoleCommerceLocalSubtitle =>
      'Epicerie, education, petit commerce local';

  @override
  String get signUpRoleCommerceLocalFootnote =>
      'mes annonces vont dans Boutiques de quartier';

  @override
  String get grandeSurfaceRole => 'Grande surface specialisee';

  @override
  String get signUpRoleGrandeSurfaceSubtitle =>
      'Grosses enseignes et grandes entreprises';

  @override
  String get signUpRoleGrandeSurfaceFootnote =>
      'validation manuelle de l\'equipe';

  @override
  String get signUpPerimeterTitle => 'Tu sers quel perimetre ?';

  @override
  String get signUpPerimeterSubtitle =>
      'C\'est la seule question qui change tout : elle decide ou ta boutique apparaitra sur l\'accueil.';

  @override
  String get signUpPerimeterQuartierTitle => 'Mon quartier';

  @override
  String get signUpPerimeterQuartierBody =>
      'Epicerie, alimentation, boutique de proximite. Mes clients habitent a cote et peuvent venir retirer.';

  @override
  String get signUpPerimeterVilleTitle => 'Toute la ville';

  @override
  String get signUpPerimeterVilleBody =>
      'Magasin ou enseigne. Je livre dans plusieurs communes de Conakry.';

  @override
  String get signUpPerimeterQuartierHintTitle => 'Mon quartier';

  @override
  String get signUpPerimeterQuartierHintBody =>
      'Un seul quartier a renseigner, retrait par code active, vitrine dans Boutiques de quartier.';

  @override
  String get signUpPerimeterVilleHintTitle => 'Toute la ville';

  @override
  String get signUpPerimeterVilleHintBody =>
      'Adresse du magasin, communes livrees et delais, vitrine dans Enseignes.';

  @override
  String get listingDestinationSecondeMain => 'Seconde main';

  @override
  String get listingDestinationArticlesNeufs => 'Articles neufs';

  @override
  String get listingDestinationQuartier => 'Boutiques de quartier';

  @override
  String get listingDestinationEnseignes => 'Enseignes';

  @override
  String listingPublishedInSection(String section) {
    return 'Votre annonce est visible dans la section $section.';
  }

  @override
  String get addSellerProfileTitle => 'Ajouter un profil vendeur';

  @override
  String get addSellerProfileSubtitle =>
      'Vous gardez le même compte — pas besoin de vous réinscrire.';

  @override
  String get addSellerProfileDestinationHint =>
      'Vos annonces atterriront dans Seconde main.';

  @override
  String get addSellerProfileConfirm => 'Activer le profil vendeur';

  @override
  String get addSellerProfileSuccess =>
      'Profil vendeur activé. Vous pouvez publier depuis l\'onglet Vendre.';

  @override
  String get addSellerProfileSettingsSubtitle =>
      'Publier en seconde main sans recréer de compte';

  @override
  String get becomeSellerTitle => 'Devenir vendeur';

  @override
  String get becomeSellerChooseType => 'Quel type de vendeur veux-tu être ?';

  @override
  String get becomeSellerStepTypeTitle => 'Profil vendeur';

  @override
  String get becomeSellerStepTypeSubtitle => 'Choisis comment tu vends';

  @override
  String get becomeSellerStepDetailsTitle => 'Détails';

  @override
  String get becomeSellerStepDetailsSubtitle => 'Boutique & livraison';

  @override
  String becomeSellerDestinationHint(String section) {
    return 'Tes annonces iront dans $section.';
  }

  @override
  String get becomeSellerSuccess =>
      'Profil vendeur activé. Tu peux publier depuis l\'onglet Vendre.';

  @override
  String get becomeSellerAccountTile => 'Devenir vendeur';

  @override
  String get becomeSellerAccountSubtitle =>
      'Même compte — choisis ton type de vente';

  @override
  String get becomeSellerActivate => 'Activer le profil vendeur';

  @override
  String get sellerPendingVerificationMessage =>
      'Votre boutique sera visible après validation par notre équipe.';

  @override
  String get sellerAccountSection => 'Profil vendeur';

  @override
  String get upgradeToShopSubtitle =>
      'Passe en boutique, commerce local ou enseigne (validation possible).';

  @override
  String get upgradeToShopChooseType => 'Quel type de boutique veux-tu créer ?';

  @override
  String get sellerVerificationPendingTitle => 'Validation en cours';

  @override
  String get sellerVerificationPendingBody =>
      'Ton dossier est en revue. Tu pourras publier une fois approuvé.';

  @override
  String get sellerProfileActiveTitle => 'Profil vendeur actif';

  @override
  String get becomeSellerRequiredHint =>
      'Active un profil vendeur pour accéder à cet espace. Tes achats restent sur le même compte.';

  @override
  String get backToLogin => 'Retour a la connexion';

  @override
  String get forgotPasswordTitle => 'Mot de passe oublie';

  @override
  String get forgotPasswordSubtitle =>
      'Entre ton numero de telephone pour recevoir un code de verification.';

  @override
  String get sendCode => 'Envoyer le code';

  @override
  String get smsCodeInfo => 'Tu recevras un SMS avec un code a 6 chiffres.';

  @override
  String get passwordUpdatedSuccess => 'Mot de passe mis a jour avec succes.';

  @override
  String get back => 'Retour';

  @override
  String get newPasswordTitle => 'Nouveau mot de passe';

  @override
  String get newPasswordSubtitle =>
      'Choisis un nouveau mot de passe pour ton compte.';

  @override
  String get newPasswordLabel => 'Nouveau mot de passe';

  @override
  String get resetPasswordButton => 'Reinitialiser le mot de passe';

  @override
  String get accountCreatedSuccess =>
      'Compte cree avec succes. Connecte-toi maintenant.';

  @override
  String get newCodeSent => 'Un nouveau code a ete envoye.';

  @override
  String get verificationTitle => 'Verification';

  @override
  String get enterCodeSentTo => 'Entre le code envoye au';

  @override
  String get resendCodeIn => 'Renvoyer le code dans';

  @override
  String get resendCode => 'Renvoyer le code';

  @override
  String get verify => 'Verifier';

  @override
  String get deviceVerification => 'Verification de l\'appareil';

  @override
  String get contentAvailableAfterVerification =>
      'Le contenu demande sera disponible apres verification.';

  @override
  String get marketingConsentText =>
      'J\'aimerais recevoir des offres personnalisees et etre informe(e) des dernieres actualites de FripCash par e-mail.';

  @override
  String get termsPrefix => 'En m\'inscrivant, je confirme accepter les ';

  @override
  String get termsAndConditions => 'Conditions generales';

  @override
  String get termsMiddle => ' de FripCash, avoir lu la ';

  @override
  String get privacyPolicy => 'Politique de confidentialite';

  @override
  String get termsSuffix => ', et avoir au moins 18 ans.';

  @override
  String get sellTitle => 'Vendre';

  @override
  String get sellerDashboardTitle => 'Tableau de bord vendeur';

  @override
  String get sellerDashboardSubtitle =>
      'Commandes, offres, stocks et historique des ventes.';

  @override
  String get publishQuickly => 'Publie ton article en quelques minutes.';

  @override
  String get sellAsIndividual => 'Vendre en tant que particulier';

  @override
  String get sellAsIndividualSubtitle =>
      'Revendez facilement les articles que vous n\'utilisez plus.';

  @override
  String get createShop => 'Creer une boutique';

  @override
  String get createShopSubtitle =>
      'Creez votre boutique professionnelle et vendez partout en Guinee.';

  @override
  String get myListings => 'Mes annonces';

  @override
  String get manageListingsSubtitle => 'Gerer vos articles, stocks et prix.';

  @override
  String get importExcelCatalog => 'Importer un catalogue Excel';

  @override
  String get importExcelSubtitle =>
      'Mise a jour en masse pour boutiques et enseignes.';

  @override
  String get listingPublishedTitle => 'Annonce publiee !';

  @override
  String get listingPublishedSubtitleSuffix =>
      'est maintenant visible sur FripCash.';

  @override
  String get displayPricePrefix => 'Prix affiche';

  @override
  String get publishAnotherItem => 'Publier un autre article';

  @override
  String get add => 'Ajouter';

  @override
  String get noListings => 'Aucune annonce';

  @override
  String get noListingsSubtitle =>
      'Publiez votre premier article pour commencer a vendre.';

  @override
  String get createListingAction => 'Creer une annonce';

  @override
  String get outOfStockInactive => 'Rupture - annonce inactive';

  @override
  String get lowStockPrefix => 'Presque en rupture';

  @override
  String get remaining => 'restant';

  @override
  String get stock => 'Stock';

  @override
  String get views => 'vues';

  @override
  String get outOfStock => 'Rupture';

  @override
  String get editListing => 'Modifier l\'annonce';

  @override
  String get editPrice => 'Modifier le prix';

  @override
  String get addStock => 'Ajouter du stock';

  @override
  String get delete => 'Supprimer';

  @override
  String get newNetPrice => 'Nouveau prix net';

  @override
  String get amountInGnf => 'Montant en GNF';

  @override
  String get gnf => 'GNF';

  @override
  String get save => 'Enregistrer';

  @override
  String get quantityToAdd => 'Quantite a ajouter';

  @override
  String get deleteListingQuestion => 'Supprimer l\'annonce ?';

  @override
  String get irreversibleAction => 'Cette action est irreversible.';

  @override
  String get listingPreview => 'Apercu de l\'annonce';

  @override
  String get listingUpdated => 'Annonce mise a jour.';

  @override
  String get addUpTo20Photos => 'Ajoutez jusqu\'a 20 photos. ';

  @override
  String get seePhotoTips => 'Voir les conseils photo.';

  @override
  String get title => 'Titre';

  @override
  String get titleHint => 'ex. Pull COS blanc';

  @override
  String get describeYourItem => 'Decris ton article';

  @override
  String get describeItemHint =>
      'ex. petit t-shirt Nike gris, porté quelques fois seulement';

  @override
  String get size => 'Taille';

  @override
  String get stockQuantity => 'Quantite en stock';

  @override
  String get priceGnf => 'Prix (GNF)';

  @override
  String get preview => 'Apercu';

  @override
  String get publishListing => 'Publier l\'annonce';

  @override
  String get uploadPhotos => 'Telecharger des photos';

  @override
  String get vintedSizesInfoPrefix =>
      'Vinted utilise les tailles International / UK par defaut. ';

  @override
  String get all => 'Tout';

  @override
  String get homeSellerPillIndividuals => 'Particuliers';

  @override
  String get homeSellerPillShops => 'Boutiques';

  @override
  String get homeSellerPillEnseignes => 'Enseignes';

  @override
  String get findABrand => 'Trouver une marque';

  @override
  String get noBrandUnbranded => 'Sans marque / Non marque';

  @override
  String get noBrandValue => 'Sans marque';

  @override
  String get useCustomBrand => 'Utiliser une marque personnalisee';

  @override
  String get suggestedBrands => 'Marques suggerees';

  @override
  String get chooseUpTo2Colours => 'Choisir jusqu\'a 2 couleurs';

  @override
  String get customColour => 'Couleur personnalisee';

  @override
  String get addCustomColour => 'Ajouter une couleur personnalisee';

  @override
  String get customColourHint => 'ex. Menthe, Bordeaux, Nude';

  @override
  String get mensClothingSizeGuide => 'Guide des tailles vetements homme';

  @override
  String get sizeGuideDescription =>
      'Ces mesures ne correspondent pas forcement a toutes les marques, mais elles peuvent servir de reference. Pour des mesures precises, consultez la description de l\'article.';

  @override
  String get homeNav => 'Accueil';

  @override
  String get favoritesNav => 'Favoris';

  @override
  String get browseNav => 'Explorer';

  @override
  String get browseSearchHint => 'Rechercher des articles ou des membres';

  @override
  String get browseHeroTitle => 'Trouve ton prochain coup de coeur';

  @override
  String get browseHeroSubtitle =>
      'Explore les meilleurs placards, boutiques et trouvailles de Conakry.';

  @override
  String get browseCategoriesHeading => 'CATEGORIES';

  @override
  String get browseFeaturedHint => 'Mode, street et looks du quotidien';

  @override
  String get browseCategoryWomen => 'Femmes';

  @override
  String get browseCategoryMen => 'Hommes';

  @override
  String get browseCategoryPremium => 'Selection premium';

  @override
  String get browseCategoryKids => 'Enfants & famille';

  @override
  String get browseCategoryHome => 'Maison & deco';

  @override
  String get browseCategoryTech => 'High-tech';

  @override
  String get browseCategoryBooks => 'Livres & medias';

  @override
  String get browseCategoryHobbies => 'Loisirs & creations';

  @override
  String get browseCategorySports => 'Sport & plein air';

  @override
  String get browseCategoryEmptyTitle => 'Rien pour le moment';

  @override
  String get browseCategoryEmptySubtitle =>
      'Reviens bientot ou explore d\'autres categories.';

  @override
  String get sellNav => 'Vendre';

  @override
  String get messagesNav => 'Messages';

  @override
  String get profileNav => 'Profil';

  @override
  String get popularItemsTitle => 'Articles populaires';

  @override
  String get popularItemsSubtitle => 'Les articles les plus aimes en ce moment';

  @override
  String get newArrivalsTitle => 'Nouveautes';

  @override
  String get newArrivalsSubtitle =>
      'Les derniers articles ajoutes sur FripCash';

  @override
  String get popularShopsTitle => 'Boutiques populaires';

  @override
  String get popularShopsSubtitle => 'Commercants professionnels de confiance';

  @override
  String get showcaseTitle => 'Selection';

  @override
  String get seeMore => 'Voir plus';

  @override
  String get follow => 'Suivre';

  @override
  String get following => 'Abonne';

  @override
  String get filterTitle => 'Filtrer';

  @override
  String get filterSort => 'Trier par';

  @override
  String get filterSellerType => 'Type de vendeur';

  @override
  String get filterCondition => 'Etat';

  @override
  String get filterPriceRange => 'Fourchette de prix';

  @override
  String filterPriceRangeValue(String min, String max) {
    return '$min - $max GNF';
  }

  @override
  String get filterInStockOnly => 'En stock seulement';

  @override
  String get filterApply => 'Appliquer';

  @override
  String get filterReset => 'Reinitialiser';

  @override
  String get sortRecommended => 'Recommande';

  @override
  String get sortPriceLow => 'Prix croissant';

  @override
  String get sortPriceHigh => 'Prix decroissant';

  @override
  String get sortNewest => 'Plus recent';

  @override
  String get sellerNotFound => 'Vendeur introuvable';

  @override
  String reviewsCount(int count) {
    return '$count avis';
  }

  @override
  String listingsCount(int count) {
    return '$count articles';
  }

  @override
  String get partnerBrandsTitle => 'Enseignes partenaires';

  @override
  String get partnerBrandsSubtitle => 'Grandes marques - livraison express';

  @override
  String get enseignesTitle => 'Enseignes';

  @override
  String get enseignesDeliveryTo => 'LIVRAISON VERS';

  @override
  String enseignesDeliverHereCount(int count) {
    return '$count enseignes livrent ici';
  }

  @override
  String get enseignesChangeLocation => 'Changer';

  @override
  String enseignesCount(int count) {
    return '$count enseignes';
  }

  @override
  String get enseignesSortDeliveryAsc => 'Delai croissant';

  @override
  String enseignesDeliveredIn(int hours) {
    return 'Livre en $hours h';
  }

  @override
  String get enseignesTwoFiltersTitle => 'Deux filtres, pas un';

  @override
  String get enseignesTwoFiltersBody =>
      'La sous-categorie (ce qu\'elle vend) et la zone livree (si elle vient chez toi). Les deux se renseignent a l\'inscription de l\'enseigne.';

  @override
  String get enseignesEmptyForZone =>
      'Aucune enseigne ne livre dans ce quartier pour l\'instant. Essayez un autre lieu.';

  @override
  String get enseigneCategoryGrocery => 'Epicerie';

  @override
  String get enseigneCategoryAppliances => 'Electromenager';

  @override
  String get enseigneCategoryLighting => 'Luminaires';

  @override
  String get enseigneCategoryHome => 'Maison';

  @override
  String get enseigneCategoryMode => 'Mode';

  @override
  String get quartierBoutiquesTitle => 'Boutiques de quartier';

  @override
  String get quartierBoutiquesYourNeighborhood => 'TON QUARTIER';

  @override
  String get quartierBoutiquesChangeNeighborhood => 'Changer';

  @override
  String quartierBoutiquesCount(int count, String quartier) {
    return '$count boutiques à $quartier';
  }

  @override
  String get quartierBoutiquesSortNearest => 'Les plus proches';

  @override
  String quartierBoutiquesProductCount(int count) {
    return '$count produits';
  }

  @override
  String quartierBoutiquesWalkTime(String street, int minutes) {
    return '$street · $minutes min';
  }

  @override
  String get quartierBoutiquesPickupByCode => 'Retrait par code';

  @override
  String quartierBoutiquesOpensAt(int hour) {
    return 'Ouvre à $hour h';
  }

  @override
  String get quartierBoutiquesEmpty =>
      'Aucune boutique de quartier ici pour l\'instant. Essaie un autre quartier.';

  @override
  String get quartierBoutiquesReportTitle =>
      'Ta boutique n\'est pas dans la liste ?';

  @override
  String get quartierBoutiquesReportBody =>
      'Signale-la : l\'équipe FripCash passe la référencer sous 48 h.';

  @override
  String get quartierBoutiquesReportAck =>
      'Merci ! Nous traitons ton signalement sous 48 h.';

  @override
  String get articlesNeufsTitle => 'Articles neufs';

  @override
  String articlesNeufsSubtitle(int shopCount, int articleCount) {
    return '$shopCount boutiques · $articleCount articles neufs';
  }

  @override
  String get articlesNeufsSearchHint => 'Boutique, marque, article...';

  @override
  String articlesNeufsShopCount(int count, String gender) {
    return '$count boutiques pour $gender';
  }

  @override
  String get articlesNeufsSortBestRated => 'Mieux notées';

  @override
  String articlesNeufsArticleCount(int count) {
    return '$count articles';
  }

  @override
  String articlesNeufsDeliveredIn(String sla) {
    return 'Livré en $sla';
  }

  @override
  String get articlesNeufsEmpty =>
      'Aucune boutique ne correspond à ta recherche.';

  @override
  String get articlesNeufsInfoTitle =>
      'On entre par la boutique, pas par l\'article';

  @override
  String get articlesNeufsInfoBody =>
      'Le commerçant a sa vitrine complète — entre dans la boutique pour voir tout son catalogue neuf.';

  @override
  String get secondeMainTitle => 'Seconde main';

  @override
  String secondeMainSubtitle(int count) {
    return '$count articles vendus par des particuliers';
  }

  @override
  String get secondeMainSearchHint => 'Robe, jean, baskets...';

  @override
  String secondeMainCount(int count, String gender) {
    return '$count articles pour $gender';
  }

  @override
  String get catalogShopSortMostProducts => 'Plus d\'articles';

  @override
  String get catalogShopSortNameAz => 'Nom A-Z';

  @override
  String get secondeMainSortRecent => 'Récents';

  @override
  String get secondeMainEmpty => 'Aucun article ne correspond à ta recherche.';

  @override
  String get secondeMainIndividualBadge => 'Particulier';

  @override
  String get secondeMainInfoTitle => 'Un seul niveau de filtre visible';

  @override
  String get secondeMainInfoBody =>
      'Les grandes catégories (Femme / Homme / Enfant) restent en avant — le reste se trouve dans les menus en dessous.';

  @override
  String get catalogGenderFemme => 'Femme';

  @override
  String get catalogGenderHomme => 'Homme';

  @override
  String get catalogGenderEnfant => 'Enfant';

  @override
  String get homeFooterTagline =>
      'FripCash - Ta plateforme de confiance pour acheter et vendre.';

  @override
  String get whatAreYouLookingFor => 'Que recherchez-vous ?';

  @override
  String get searchNoResults => 'Aucun resultat pour votre recherche';

  @override
  String get searchResultsTitle => 'Resultats de recherche';

  @override
  String searchResultsCount(int count) {
    return '$count resultat(s)';
  }

  @override
  String get oneSize => 'Taille unique';

  @override
  String get includedSuffix => 'incl.';

  @override
  String get noFavoritesYet => 'Aucun favori pour l\'instant';

  @override
  String get noFavoritesSubtitle =>
      'Enregistre les articles que tu aimes pour les retrouver ici.';

  @override
  String get discoverItemsAction => 'Decouvrir les articles';

  @override
  String get supportFripCash => 'Support FripCash';

  @override
  String get sellers => 'Vendeurs';

  @override
  String get noSupportMessages => 'Aucun message support';

  @override
  String get noSupportMessagesSubtitle =>
      'Contacte l\'equipe FripCash pour toute question.';

  @override
  String get noMessages => 'Aucun message';

  @override
  String get noMessagesSubtitle =>
      'Tes conversations avec les vendeurs apparaitront ici.';

  @override
  String get enabled => 'Active';

  @override
  String get disabled => 'Desactive';

  @override
  String get courierRole => 'Livreur';

  @override
  String get adminRole => 'Admin';

  @override
  String get badges => 'Badges';

  @override
  String get myWallet => 'Mon porte-monnaie';

  @override
  String get mySalesAndPurchases => 'Mes ventes et achats';

  @override
  String get myOffers => 'Mes offres';

  @override
  String get customization => 'Personnalisation';

  @override
  String get bundleDiscount => 'Reduction sur les lots';

  @override
  String get vacationMode => 'Mode vacances';

  @override
  String get help => 'Aide';

  @override
  String get signOut => 'Se deconnecter';

  @override
  String get viewMyProfile => 'Voir mon profil';

  @override
  String get sellYourItems => 'Vends tes articles';

  @override
  String get sellPromoSubtitle =>
      'Fixez votre prix — une commission est ajoutée pour les acheteurs (8 %, ou 5 % pour les boutiques de proximité). Vous gardez tout votre prix.';

  @override
  String get addItem => 'Ajouter un article';

  @override
  String get editMyProfile => 'Modifier mon profil';

  @override
  String get changePassword => 'Changer le mot de passe';

  @override
  String get pushNotifications => 'Notifications push';

  @override
  String get ordersMessagesOffers => 'Commandes, messages et offres';

  @override
  String get sellerMode => 'Mode vendeur';

  @override
  String get sellerModeSubtitle =>
      'Tester le tableau de bord sans changer de compte';

  @override
  String get profileUpdated => 'Profil mis a jour.';

  @override
  String get phone => 'Telephone';

  @override
  String get nameOrUsernameHint => 'Ton nom ou pseudo';

  @override
  String get phoneCannotBeEditedHere =>
      'Le numero ne peut pas etre modifie ici.';

  @override
  String get chooseZone => 'Choisir une zone';

  @override
  String get address => 'Adresse';

  @override
  String get addressHintShort => 'Quartier, point de repere...';

  @override
  String get passwordUpdatedSimulation =>
      'Mot de passe mis a jour (simulation).';

  @override
  String get currentPassword => 'Mot de passe actuel';

  @override
  String get confirmPasswordShort => 'Confirme le mot de passe';

  @override
  String get myPublicProfile => 'Mon profil public';

  @override
  String get profileRatingSummary => '4,8 · 24 avis';

  @override
  String get listings => 'Annonces';

  @override
  String get noPublicListings => 'Aucune annonce publique.';

  @override
  String get vacationModeDescription =>
      'Masque temporairement tes annonces. Les acheteurs ne pourront pas passer commande pendant cette periode.';

  @override
  String get startDate => 'Debut';

  @override
  String get endDate => 'Fin';

  @override
  String get notSet => 'Non definie';

  @override
  String get vacationModeUpdated => 'Mode vacances mis a jour.';

  @override
  String get hideListingsOnVacation => 'Masquer les annonces publiees';

  @override
  String get bundleDiscountDescription =>
      'Propose une remise automatique quand un acheteur achete plusieurs articles de ta boutique.';

  @override
  String get bundleDiscountSimulatedRule =>
      'Remise : -10 % a partir de 2 articles du meme vendeur.';

  @override
  String get bundleMinItemsLabel => 'Nombre minimum d\'articles';

  @override
  String get bundleMinItemsHelper =>
      'L\'acheteur doit prendre au moins ce nombre d\'articles chez toi (2–20).';

  @override
  String get bundleMinItemsInvalid =>
      'Le minimum d\'articles doit etre entre 2 et 20.';

  @override
  String get bundlePercentLabel => 'Remise %';

  @override
  String get bundlePercentHelper =>
      'Pourcentage sur ces articles au checkout (1–50).';

  @override
  String get bundlePercentInvalid => 'La remise doit etre entre 1 % et 50 %.';

  @override
  String bundleRulePreview(int percent, int minItems) {
    return '-$percent % a partir de $minItems articles de ta boutique.';
  }

  @override
  String get bundleRuleSavedLocal => 'Regle de lot enregistree.';

  @override
  String get badgeFirstSaleTitle => 'Premiere vente';

  @override
  String get badgeFirstSaleDescription =>
      'Tu as vendu ton premier article sur FripCash.';

  @override
  String get badgeFastShipperTitle => 'Expedition rapide';

  @override
  String get badgeFastShipperDescription =>
      '5 colis prepares en moins de 24 h.';

  @override
  String get badgeTopRatedTitle => 'Vendeur 5 etoiles';

  @override
  String get badgeTopRatedDescription =>
      '10 avis avec une note moyenne de 5/5.';

  @override
  String get badgeEcoSellerTitle => 'Eco-responsable';

  @override
  String get badgeEcoSellerDescription => '20 articles seconde main vendus.';

  @override
  String get purchasesTab => 'Achats';

  @override
  String get salesTab => 'Ventes';

  @override
  String get noPurchases => 'Aucun achat';

  @override
  String get noSales => 'Aucune vente';

  @override
  String get orderLabel => 'Commande';

  @override
  String get deliverWithin => 'Livrer sous';

  @override
  String get overdue => 'en retard';

  @override
  String get orderStatusUpdated => 'Statut de commande mis a jour';

  @override
  String get ratingSavedThanks => 'Merci, votre avis a ete enregistre.';

  @override
  String get orderNotFound => 'Commande introuvable';

  @override
  String get stepLabel => 'Etape';

  @override
  String get orderTracking => 'Suivi de commande';

  @override
  String get items => 'Articles';

  @override
  String get sellerRoleGeneric => 'Vendeur';

  @override
  String get deliveryZone => 'Zone livraison';

  @override
  String get awaitingAssignment => 'En attente d\'assignation';

  @override
  String get parcelReady => 'Colis prêt';

  @override
  String get parcelDelivered => 'Colis livre';

  @override
  String get rateSeller => 'Noter le vendeur';

  @override
  String get thanksForReview => 'Merci pour votre avis !';

  @override
  String get experienceWithSellerQuestion =>
      'Comment s\'est passee votre experience avec';

  @override
  String get commentOptional => 'Commentaire (optionnel)';

  @override
  String get submitReview => 'Envoyer mon avis';

  @override
  String get deliveryAddressTitle => 'Adresse de livraison';

  @override
  String get fullName => 'Nom complet';

  @override
  String get yourName => 'Ton nom';

  @override
  String get phoneNumberHint224 => '+224 6XX XXX XXX';

  @override
  String get neighborhood => 'Quartier';

  @override
  String get chooseNeighborhood => 'Choisis ton quartier';

  @override
  String get streetSectorCommune => 'Rue, secteur, commune';

  @override
  String get landmark => 'Point de repere';

  @override
  String get landmarkHint => 'Ex: pres du marche, immeuble bleu';

  @override
  String get continueAction => 'Continuer';

  @override
  String get serviceFeesTitle => 'Frais de service (8 %)';

  @override
  String get serviceFeesDescription =>
      'Le prix affiche inclut deja les frais de service : 1 % pour Orange Money et 7 % pour FripCash. Aucun frais cache au paiement.';

  @override
  String get summaryTitle => 'Recapitulatif';

  @override
  String get buyerProtectionIncluded =>
      'Protection acheteur incluse sur cet achat.';

  @override
  String get subtotal => 'Sous-total';

  @override
  String get deliveryFees => 'Frais de livraison';

  @override
  String get serviceFeesIncluded => 'Frais de service inclus';

  @override
  String get payWithOrangeMoney => 'Payer avec Orange Money';

  @override
  String get qtyShort => 'Qte';

  @override
  String get orderConfirmedTitle => 'Commande confirmee !';

  @override
  String get orderConfirmedSubtitle =>
      'Commande confirmee. Restez joignable, le livreur vous contactera.';

  @override
  String get estimatedDelivery24to48h => 'Livraison estimee sous 24-48 h';

  @override
  String get orderTrackingSoon => 'Suivi de commande bientot disponible.';

  @override
  String get trackMyOrder => 'Suivre ma commande';

  @override
  String get withdrawToOrangeMoney => 'Retirer vers Orange Money';

  @override
  String get confirmWithdrawalPrefix => 'Confirmer le retrait de';

  @override
  String get confirmWithdrawalSuffix => 'vers votre compte Orange Money ?';

  @override
  String get confirm => 'Confirmer';

  @override
  String get withdrawalInitiatedSimulation => 'Retrait initie (simulation).';

  @override
  String get availableBalance => 'Solde disponible';

  @override
  String get walletEscrowInfo =>
      'Les fonds des ventes restent bloques jusqu\'a l\'etape \"Colis livre\". Ils sont ensuite debloques sur votre porte-monnaie.';

  @override
  String get history => 'Historique';

  @override
  String get noTransactionsYet => 'Aucune transaction pour le moment';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get markAllRead => 'Tout lire';

  @override
  String get noNotifications => 'Aucune notification';

  @override
  String get missingAddressRestartOrder =>
      'Adresse manquante. Recommence la commande.';

  @override
  String get paymentCancelled => 'Paiement annule.';

  @override
  String get orangeMoney => 'Orange Money';

  @override
  String get securePayment => 'Paiement securise';

  @override
  String get orangeMoneyNumber => 'Numero Orange Money';

  @override
  String get paymentConfirmationPrompt =>
      'Tu recevras une demande de confirmation sur ton telephone.';

  @override
  String get confirmPayment => 'Confirmer le paiement';

  @override
  String get shopOnboardingSubtitle =>
      'Presente ta boutique aux acheteurs partout en Guinee.';

  @override
  String get shopNameExample => 'ex. Mode Plus GN';

  @override
  String get shopDescriptionHint => 'Ta specialite, tes engagements...';

  @override
  String get preparationDelay => 'Delai de preparation';

  @override
  String get sellerDeliverySla => 'SLA livraison vendeur';

  @override
  String get createMyShop => 'Creer ma boutique';

  @override
  String get dashboardTitle => 'Tableau de bord';

  @override
  String get myShop => 'Ma boutique';

  @override
  String get salesToday => 'Ventes du jour';

  @override
  String get offersToHandle => 'Offres a traiter';

  @override
  String get shopVisits => 'Visites boutique';

  @override
  String get quickActions => 'Actions rapides';

  @override
  String get newListing => 'Nouvelle annonce';

  @override
  String get viewOrders => 'Voir les commandes';

  @override
  String get pending => 'en attente';

  @override
  String get toHandle => 'a traiter';

  @override
  String get lastImport => 'Dernier import';

  @override
  String get noRecentImport => 'Aucun import recent';

  @override
  String get itemsLowStockAlert => 'article(s) en alerte stock';

  @override
  String get adjust => 'Ajuster';

  @override
  String get salesHistory => 'Historique des ventes';

  @override
  String get noDeliveredSalesYet => 'Aucune vente livree pour le moment.';

  @override
  String get sellerDemoModeBanner => 'Mode vendeur (demo) - donnees d\'exemple';

  @override
  String get clientPrice => 'Prix client';

  @override
  String get yourNetPrice => 'Votre prix net';

  @override
  String get fripCashCommission => 'Commission FripCash';

  @override
  String get sellerOrdersTitle => 'Commandes vendeur';

  @override
  String get noOrdersInCategory => 'Aucune commande dans cette categorie';

  @override
  String get clientLabel => 'Client';

  @override
  String get parcelMarkedReady => 'Colis marque comme pret';

  @override
  String get receivedOffers => 'Offres recues';

  @override
  String get accepted => 'Acceptees';

  @override
  String get noPendingOffers => 'Aucune offre en attente';

  @override
  String get noAcceptedOffers => 'Aucune offre acceptee';

  @override
  String get offerLabel => 'Offre';

  @override
  String get offerRefused => 'Offre refusee';

  @override
  String get refuse => 'Refuser';

  @override
  String get offerAcceptedBuyerNotified => 'Offre acceptee - acheteur notifie';

  @override
  String get accept => 'Accepter';

  @override
  String get excelImportTitle => 'Import Excel';

  @override
  String get excelImportSubtitle =>
      'Importe ton catalogue produits au format .xlsx pour mettre a jour stocks et prix en masse.';

  @override
  String get excelImportAwaitingBackend =>
      'Telecharge le modele, puis importe ton fichier .xlsx.';

  @override
  String excelImportSuccess(int imported, int updated, int failed) {
    return 'Import termine : $imported crees, $updated mis a jour, $failed echecs.';
  }

  @override
  String excelTemplateSaved(String path) {
    return 'Modele enregistre : $path';
  }

  @override
  String excelLastImport(String label) {
    return 'Dernier import : $label';
  }

  @override
  String get noFileSelected => 'Aucun fichier selectionne';

  @override
  String get templateDownloadedSimulation => 'Modele telecharge.';

  @override
  String get downloadExcelTemplate => 'Telecharger le modele Excel';

  @override
  String get dragOrSelectFile => 'Glisse ton fichier ou selectionne-le';

  @override
  String get importInProgress => 'Import en cours...';

  @override
  String get chooseFile => 'Choisir un fichier';

  @override
  String get rowsUpdatedSuccess => 'Lignes mises a jour avec succes.';

  @override
  String get previewSimulation => 'Apercu';

  @override
  String get noOffersYet => 'Tu n\'as pas encore fait d\'offre.';

  @override
  String get noOffersSubtitle =>
      'Trouve un article et appuie sur Faire une offre sur la fiche produit.';

  @override
  String get priceLabel => 'Prix';

  @override
  String get helpSubtitle =>
      'Trouve une reponse rapide ou contacte notre equipe support.';

  @override
  String get faqTitle => 'Questions frequentes';

  @override
  String get contactUsTitle => 'Nous contacter';

  @override
  String get contactSupport => 'Contacter le support';

  @override
  String get supportOpeningSoon => 'Ouverture du support bientot disponible.';

  @override
  String get conversationNotFound => 'Conversation introuvable';

  @override
  String get messagingUnavailableForBrand =>
      'Messagerie non disponible pour cette enseigne';

  @override
  String get askSupportQuestion => 'Pose ta question au support FripCash.';

  @override
  String get sendMessageToSeller => 'Envoie un message au vendeur.';

  @override
  String get writeMessageHint => 'Ecris un message...';

  @override
  String get courierSpaceTitle => 'Espace livreur';

  @override
  String get courierLoginSubtitle =>
      'Connexion demo - missions et livraisons FripCash';

  @override
  String get fripCashCourier => 'FripCash Livreur';

  @override
  String get active => 'Actif';

  @override
  String get unavailableShort => 'Indispo.';

  @override
  String get courierUnavailableBanner =>
      'Vous etes indisponible - aucune nouvelle mission ne vous sera assignee.';

  @override
  String get missions => 'Missions';

  @override
  String get earnings => 'Gains';

  @override
  String get courierDeliveryHistory => 'Historique des livraisons';

  @override
  String get courierHistorySubtitle =>
      'Toutes vos courses terminees sur votre compte.';

  @override
  String get courierTotalDeliveries => 'Livraisons totales';

  @override
  String get courierTotalEarned => 'Total gagne';

  @override
  String get noDeliveryHistoryYet =>
      'Aucune livraison terminee pour le moment.';

  @override
  String get courierThisWeek => 'Cette semaine';

  @override
  String get courierPaidToWallet => 'Verse sur votre porte-monnaie FripCash';

  @override
  String get courierPayoutDetails => 'Details de paiement';

  @override
  String get fripCashWallet => 'Porte-monnaie FripCash';

  @override
  String get courierWeeklyGoalTitle =>
      'Fixez un objectif de gains hebdomadaire';

  @override
  String get courierWeeklyGoalSubtitle =>
      'Restez motive et suivez vos progres chaque semaine.';

  @override
  String get courierGetStarted => 'Commencer';

  @override
  String get courierEarningsHistory => 'Historique des gains';

  @override
  String get courierViewAllHistory => 'Tout voir';

  @override
  String get courierWeekCurrent => 'Cette semaine';

  @override
  String get courierWeekJun29Jul5 => '29 juin - 5 juil.';

  @override
  String get courierWeekJun8Jun14 => '8 - 14 juin';

  @override
  String get courierWeekMay18May24 => '18 - 24 mai';

  @override
  String get courierWeekApr27May3 => '27 avr. - 3 mai';

  @override
  String get courierWeekApr6Apr12 => '6 - 12 avril';

  @override
  String get courierProfileTitle => 'Mon profil';

  @override
  String get courierPersonalInfo => 'Informations personnelles';

  @override
  String get courierVehicleInfo => 'Informations vehicule';

  @override
  String get courierSubmittedDocuments => 'Documents soumis';

  @override
  String get courierDocumentsSubtitle =>
      'Documents que vous avez soumis lors de l\'inscription.';

  @override
  String get courierVerified => 'Verifie';

  @override
  String get courierIdLabel => 'ID livreur';

  @override
  String get courierVehicleType => 'Type de vehicule';

  @override
  String get courierVehicleMotorcycle => 'Moto';

  @override
  String get courierPlateNumber => 'Immatriculation';

  @override
  String get courierMemberSince => 'Membre depuis';

  @override
  String get courierDocNationalId => 'Carte d\'identite';

  @override
  String get courierDocDriversLicense => 'Permis de conduire';

  @override
  String get courierDocVehicleRegistration => 'Carte grise';

  @override
  String get courierDocInsurance => 'Attestation d\'assurance';

  @override
  String get courierDocProfilePhoto => 'Photo de profil';

  @override
  String get courierDocStatusApproved => 'Approuve';

  @override
  String get courierDocStatusPending => 'En cours de verification';

  @override
  String get courierDocStatusRejected => 'Refuse';

  @override
  String courierSubmittedOn(String date) {
    return 'Soumis le $date';
  }

  @override
  String get courierViewDocument => 'Voir';

  @override
  String get inProgress => 'En cours';

  @override
  String get completed => 'Terminees';

  @override
  String get courierFilterAll => 'Toutes';

  @override
  String get courierFilterActive => 'Actives';

  @override
  String get courierSearchMissionsHint => 'Rechercher une mission';

  @override
  String get courierDeliverTo => 'Livrer a';

  @override
  String get courierPickupZone => 'Collecte';

  @override
  String get courierDeliveryZone => 'Livraison';

  @override
  String get courierDeliveryFee => 'Frais';

  @override
  String get courierShippedBy => 'Expedie par';

  @override
  String get courierExpectedOn => 'Prevue le';

  @override
  String get courierStatusHeroCollect => 'Recupere le colis chez le vendeur';

  @override
  String get courierStatusHeroDeliver => 'Livre le colis a l\'acheteur';

  @override
  String get courierStatusHeroDone => 'Cette mission est terminee';

  @override
  String get courierSenderDetails => 'Details expediteur';

  @override
  String get courierRecipientDetails => 'Details destinataire';

  @override
  String get courierPackageDetails => 'Details du colis';

  @override
  String get courierMyMissions => 'Mes missions';

  @override
  String get courierWelcomeBack => 'Bon retour';

  @override
  String get courierWelcomeSubtitle => 'Pret pour les livraisons du jour';

  @override
  String courierHelloName(String name) {
    return 'Bonjour, $name';
  }

  @override
  String get courierBannerSubtitle => 'Pret pour les livraisons du jour';

  @override
  String get courierTodayEarnings => 'Gains du jour';

  @override
  String courierActiveCount(int count) {
    return '$count actives';
  }

  @override
  String get courierQuantity => 'Quantite';

  @override
  String get courierDistanceLabel => 'distance';

  @override
  String get courierTimeLeftLabel => 'Temps restant';

  @override
  String get courierArrivalLabel => 'Arrivee';

  @override
  String get courierDeliveryAddress => 'Adresse de livraison';

  @override
  String get courierCustomer => 'Client';

  @override
  String get courierOrderCost => 'Cout commande';

  @override
  String get courierCreated => 'Cree';

  @override
  String get courierTypeOfOrder => 'Type de commande';

  @override
  String get courierPaymentMethod => 'Mode de paiement';

  @override
  String get courierPaymentStatus => 'Statut';

  @override
  String get courierTypeOwnTerms => 'Livraison FripCash';

  @override
  String get courierPaymentPaid => 'Paye';

  @override
  String get courierChatWithSupport => 'Discuter avec le support';

  @override
  String get courierSlideToCollect => 'Glisser pour confirmer la collecte';

  @override
  String get courierSlideToDeliver => 'Glisser pour confirmer la livraison';

  @override
  String get courierMockDistance => '4,2 km';

  @override
  String get courierMockTimeLeft => '18 min';

  @override
  String get courierMockArrival => '17:30';

  @override
  String get courierMockWindow => '16:00 – 18:00';

  @override
  String get noActiveMissions => 'Aucune mission en cours';

  @override
  String get enableAvailabilityForMissions =>
      'Activez votre disponibilite pour recevoir des missions';

  @override
  String get noCompletedMissions => 'Aucune mission terminee';

  @override
  String get newMission => 'Nouvelle mission';

  @override
  String get pickup => 'Collecte';

  @override
  String get delivery => 'Livraison';

  @override
  String get callLabel => 'Appel';

  @override
  String get demoLabel => 'demo';

  @override
  String get transferToAnotherCourier => 'Transferer a un autre livreur';

  @override
  String get availableCouriers => 'Livreurs disponibles';

  @override
  String get missionTransferredTo => 'Mission transferee a';

  @override
  String get noOtherCourierInZone => 'Aucun autre livreur dans cette zone.';

  @override
  String get missionNotFound => 'Mission introuvable';

  @override
  String get deliveryConfirmed => 'Livraison confirmee';

  @override
  String get callAction => 'Appeler';

  @override
  String get earningsToday => 'Gains du jour';

  @override
  String get ridesToday => 'course(s) aujourd\'hui';

  @override
  String get todaysRides => 'Courses du jour';

  @override
  String get noRideCompletedToday => 'Aucune course terminee aujourd\'hui.';

  @override
  String get toPrepare => 'À préparer';

  @override
  String get ready => 'Pret';

  @override
  String get delivered => 'Livre';

  @override
  String get total => 'Total';

  @override
  String get otherZone => 'Autre zone';

  @override
  String get parcelCollected => 'Colis recupere';

  @override
  String get share => 'Partager';

  @override
  String get shareLinkSoon => 'Lien de partage bientot disponible.';

  @override
  String get shareListingSubtitle => 'Copier le lien de l\'annonce';

  @override
  String get shareShopSubtitle => 'Copier le lien de la boutique';

  @override
  String get copyShareLink => 'Copier le lien';

  @override
  String get shareLinkCopied => 'Lien copie dans le presse-papiers.';

  @override
  String get copyWhatsAppMessage => 'Message WhatsApp';

  @override
  String get copyWhatsAppMessageHint => 'Titre + lien pret a coller';

  @override
  String get whatsAppMessageCopied => 'Message copie — colle-le dans WhatsApp.';

  @override
  String get reportListing => 'Signaler l\'annonce';

  @override
  String get reportSent => 'Signalement envoye.';

  @override
  String get outOfStockDetailBanner =>
      'Rupture de stock - cet article n\'est plus disponible.';

  @override
  String get acceptedPriceLabel => 'Prix accepte';

  @override
  String get buyerProtection => 'Protection acheteur';

  @override
  String get availableStock => 'Stock disponible';

  @override
  String get description => 'Description';

  @override
  String get showLess => 'moins';

  @override
  String get showMore => '... plus';

  @override
  String get askAction => 'Demander';

  @override
  String get reviews => 'Avis';

  @override
  String get buyerProtectionFeesTitle => 'Frais de Protection acheteur';

  @override
  String get buyerProtectionFeesDescription =>
      'Pour tout achat via \"Acheter\", des frais s\'appliquent pour couvrir la Protection acheteur et la politique de remboursement.';

  @override
  String get fromLabel => 'a partir de';

  @override
  String get memberItemsTab => 'Articles du membre';

  @override
  String get similarItemsTab => 'Articles similaires';

  @override
  String get bundleBuyTitle => 'Acheter en lot';

  @override
  String get bundleBuySubtitle => 'Economise sur la livraison';

  @override
  String get createBundle => 'Creer un lot';

  @override
  String get makeOfferAction => 'Faire une offre';

  @override
  String get buyAction => 'Acheter';

  @override
  String get unavailable => 'Indisponible';

  @override
  String get phoneNumberHintLocal => '6XX XXX XXX';

  @override
  String get myCart => 'Mon panier';

  @override
  String get removeOutOfStockToContinue =>
      'Retire les articles en rupture de stock pour continuer.';

  @override
  String get emptyCartTitle => 'Ton panier est vide';

  @override
  String get emptyCartSubtitle =>
      'Parcours nos articles et trouve ton bonheur !';

  @override
  String get estimatedDeliveryFees => 'Frais de livraison (estimes)';

  @override
  String get placeOrder => 'Passer la commande';

  @override
  String get offerMustBeLower => 'Entre un montant inferieur au prix affiche.';

  @override
  String get offerSentToSeller => 'Offre envoyee au vendeur.';

  @override
  String get yourOfferGnf => 'Ton offre (GNF)';

  @override
  String get sendOffer => 'Envoyer l\'offre';

  @override
  String get sellerOnlyAreaTitle => 'Espace reserve aux vendeurs';

  @override
  String get enableSellerModeInCustomization =>
      'Active un profil vendeur depuis Compte ou Paramètres.';

  @override
  String get adjustStocksTitle => 'Ajuster les stocks';

  @override
  String get itemsInAlertOrOutOfStock => 'Articles en alerte ou rupture';

  @override
  String get noItemInStockAlert => 'Aucun article en alerte stock.';

  @override
  String get close => 'Fermer';

  @override
  String get partnerBrandLabel => 'Enseigne partenaire';

  @override
  String get orderStatusOrdered => 'Commande validee';

  @override
  String get orderStatusPaid => 'Paiement confirme';

  @override
  String get orderStatusSellerNotified => 'Vendeur notifie';

  @override
  String get orderStatusPreparing => 'Preparation en cours';

  @override
  String get orderStatusReadyForPickup => 'Colis pret';

  @override
  String get orderStatusCourierAssigned => 'Livreur assigne';

  @override
  String get orderStatusCollected => 'Colis recupere';

  @override
  String get orderStatusInTransit => 'En route';

  @override
  String get orderStatusDelivered => 'Colis livre';

  @override
  String get orderStatusFundsReleased => 'Paiement vendeur debloque';

  @override
  String get orderStatusFeedbackPending => 'A evaluer';

  @override
  String get courierStepToCollect => 'A recuperer';

  @override
  String get courierStepInTransit => 'En route';

  @override
  String get categoryMode => 'Mode & Accessoires';

  @override
  String get categoryShoes => 'Chaussures';

  @override
  String get categoryBeauty => 'Beaute & Cosmetique';

  @override
  String get categoryBaby => 'Bebe & Maternite';

  @override
  String get categoryGrocery => 'Epicerie & Petit-dejeuner';

  @override
  String get categoryHome => 'Maison & Decoration';

  @override
  String get categoryElectronics => 'Electronique - Electromenager';

  @override
  String get categorySecondhand => 'Seconde main';

  @override
  String get categoryElectronicsShort => 'Electronique';

  @override
  String get categoryBeautyShort => 'Beaute';

  @override
  String get categoryGroceryShort => 'Epicerie';

  @override
  String get subcategoryLabel => 'Sous-categorie';

  @override
  String get subcategoryWomen => 'Femmes';

  @override
  String get subcategoryMen => 'Hommes';

  @override
  String get subcategoryKids => 'Enfants';

  @override
  String get subcategoryAccessories => 'Accessoires';

  @override
  String get subcategoryPhones => 'Telephones & tablettes';

  @override
  String get subcategoryTvs => 'Televiseurs';

  @override
  String get subcategoryComputers => 'Ordinateurs';

  @override
  String get subcategoryAppliances => 'Electromenager';

  @override
  String get subcategoryBabyClothes => 'Vetements bebe';

  @override
  String get subcategoryMaternity => 'Maternite';

  @override
  String get subcategoryBabyGear => 'Equipement bebe';

  @override
  String get subcategoryFurniture => 'Meubles';

  @override
  String get subcategoryDecor => 'Decoration';

  @override
  String get subcategoryKitchen => 'Cuisine';

  @override
  String get subcategoryOther => 'Autre';

  @override
  String get sizeScreenInches => 'Taille d\'ecran';

  @override
  String get sizeStorage => 'Stockage';

  @override
  String get sizeShoeEu => 'Pointure (EU)';

  @override
  String get sizeAge => 'Age / taille';

  @override
  String get selectSubcategoryFirst => 'Choisis d\'abord une sous-categorie';

  @override
  String get brandCatalogHint =>
      'Les marques sont gerees par FripCash. Choisis-en une dans la liste, ou saisis une marque personnalisee si elle n\'y figure pas.';

  @override
  String get platformBrands => 'Marques de la plateforme';

  @override
  String get faqCreateAccountQ => 'Comment creer un compte ?';

  @override
  String get faqCreateAccountA =>
      'Appuie sur \"S\'inscrire\", entre ton numero de telephone, choisis un mot de passe, accepte les conditions, puis confirme le code recu par SMS.';

  @override
  String get faqOtpNotReceivedQ => 'Je n\'ai pas recu le code OTP';

  @override
  String get faqOtpNotReceivedA =>
      'Verifie que ton numero est correct et que tu as du reseau. Attends 60 secondes puis appuie sur \"Renvoyer le code\". Si le probleme persiste, contacte le support.';

  @override
  String get faqForgotPasswordQ => 'Mot de passe oublie ?';

  @override
  String get faqForgotPasswordA =>
      'Sur l\'ecran de connexion, appuie sur \"Mot de passe oublie ?\", entre ton numero, valide le code OTP et definis un nouveau mot de passe.';

  @override
  String get faqAccountBlockedQ => 'Pourquoi mon compte est bloque ?';

  @override
  String get faqAccountBlockedA =>
      'Un compte peut etre temporairement suspendu en cas d\'activite suspecte ou de non-respect des regles de la plateforme. Contacte le support pour plus de details.';

  @override
  String get faqDeliveryTimesQ => 'Quels sont les delais de livraison ?';

  @override
  String get faqDeliveryTimesA =>
      'Les vendeurs choisissent un delai maximal (24h a 1 semaine pour les boutiques). Les enseignes partenaires proposent la livraison express (2h ou 4h).';

  @override
  String get faqCommissionQ => 'Comment fonctionne la commission ?';

  @override
  String get faqCommissionA =>
      'FripCash applique 8 % sur le prix net du vendeur (dont 1 % pour Orange Money et 7 % pour la plateforme). Le prix affiche inclut automatiquement ces frais.';

  @override
  String get faqOrangeMoneyQ => 'Puis-je payer avec Orange Money ?';

  @override
  String get faqOrangeMoneyA =>
      'Oui, tous les achats se font dans l\'application via Orange Money. Le paiement est securise avant l\'envoi du colis.';

  @override
  String get emailContact => 'E-mail';

  @override
  String get phoneContact => 'Telephone';

  @override
  String get whatsappContact => 'WhatsApp';

  @override
  String get responseWithin24h => 'Reponse sous 24 h';

  @override
  String get weekdayHours => 'Lun – Ven, 8h – 18h';

  @override
  String get fastAssistance => 'Assistance rapide';

  @override
  String get skipTutorial => 'Passer';

  @override
  String get tourSearchTitle => 'Rechercher';

  @override
  String get tourSearchDescription =>
      'Trouve des articles, des vendeurs ou des boutiques en un clin d\'oeil.';

  @override
  String get tourNotificationsTitle => 'Notifications';

  @override
  String get tourNotificationsDescription =>
      'Suis tes commandes, messages et alertes importantes ici.';

  @override
  String get tourCartTitle => 'Panier';

  @override
  String get tourCartDescription =>
      'Consulte et valide tes achats avant de payer.';

  @override
  String get tourCategoriesTitle => 'Categories';

  @override
  String get tourCategoriesDescription =>
      'Filtre par type d\'article — friperie, boutiques, enseignes…';

  @override
  String get tourHomeTitle => 'Accueil';

  @override
  String get tourHomeDescription =>
      'Decouvre les articles tendance et les nouveautes.';

  @override
  String get tourFavoritesTitle => 'Favoris';

  @override
  String get tourFavoritesDescription =>
      'Retrouve les articles que tu as enregistres.';

  @override
  String get tourBrowseTitle => 'Explorer';

  @override
  String get tourBrowseDescription =>
      'Parcours les categories et decouvre les articles par type.';

  @override
  String get tourSellTitle => 'Vendre';

  @override
  String get tourSellDescription =>
      'Publie un article ou gere ton espace vendeur.';

  @override
  String get tourMessagesTitle => 'Messages';

  @override
  String get tourMessagesDescription =>
      'Echange avec acheteurs, vendeurs et livreurs.';

  @override
  String get tourProfileTitle => 'Profil';

  @override
  String get tourProfileDescription =>
      'Parametres, commandes et informations de ton compte.';

  @override
  String greetingWithName(String name) {
    return 'Salut, $name';
  }

  @override
  String get greetingDefault => 'Salut !';

  @override
  String get joinFripCashTodayFree =>
      'Rejoins FripCash aujourd\'hui gratuitement';

  @override
  String get joinAction => 'Rejoindre';

  @override
  String get promoFlashTitle => 'Vente Flash';

  @override
  String get promoFlashSubtitle => 'Choisissez votre remise';

  @override
  String get promoFlashOffer => '40-50% off';

  @override
  String get promoFlashCta => 'Voir tous les articles';

  @override
  String get flashSaleAll => 'Tout';

  @override
  String flashSaleDiscountLabel(int percent) {
    return 'Remise $percent%';
  }

  @override
  String get flashSaleEndsIn => 'Se termine dans';

  @override
  String get promoNewTitle => 'Nouveautes';

  @override
  String get promoNewSubtitle => 'Les derniers articles ajoutes cette semaine';

  @override
  String get promoNewOffer => 'Des 5 000 F';

  @override
  String get promoNewCta => 'Decouvrir les nouveautes';

  @override
  String get promoWomenTitle => 'Mode Femme';

  @override
  String get promoWomenSubtitle => 'Robes, sacs et accessoires tendance';

  @override
  String get promoWomenOffer => 'Jusqu\'a -30%';

  @override
  String get promoWomenCta => 'Voir la collection';

  @override
  String get tutorialsTitle => 'Tutoriels';

  @override
  String get tutorialsSubtitle => 'Apprends a vendre sur FripCash';

  @override
  String get tutorialSellIndividual => 'Vendre en tant que particulier';

  @override
  String get tutorialCreateShop => 'Creer une boutique';

  @override
  String get tutorialBecomePartner => 'Devenir partenaire FripCash';

  @override
  String get videoDuration2min => 'Video · 2 min';

  @override
  String get videoDuration3min => 'Video · 3 min';

  @override
  String get textGuideLabel => 'Guide texte';

  @override
  String contentComingSoon(String title) {
    return '$title — bientot disponible.';
  }

  @override
  String get supportFaqOrderWhere => 'Ou est ma commande ?';

  @override
  String get supportFaqPaymentIssue => 'Probleme de paiement Orange Money';

  @override
  String get supportFaqCommissionFees => 'Commission et frais de service';

  @override
  String get supportFaqContactCourier => 'Contacter un livreur';

  @override
  String get chatEmptyMessage => 'Ecris un message.';

  @override
  String get chatBlockedMessage =>
      'Ce message n\'est pas autorise. Les echanges doivent rester sur FripCash.';

  @override
  String get examplePrefix => 'Ex:';

  @override
  String get exploreCategoriesTitle => 'Explorer les categories';

  @override
  String get homeCategoriesTitle => 'Categories';

  @override
  String get recentlyAddedTitle => 'Ajoutes recemment';

  @override
  String get sponsoredSectionTitle => 'Promotions en vedette';

  @override
  String get sponsoredBadge => 'Promo';

  @override
  String get viewProduct => 'Voir le produit';

  @override
  String get shopNow => 'Acheter';

  @override
  String get homeDiscountsPromoteCta => 'Promouvoir un article';

  @override
  String get homeDiscountsPromoteHint =>
      'Discute avec l’admin FripCash pour placer une promo. Le paiement se fait hors site ; l’admin publie ensuite l’offre ici.';

  @override
  String get homeDiscountsEmpty =>
      'Aucune promo pour le moment. Contacte l’admin pour mettre en avant ta remise.';

  @override
  String get viewShop => 'Voir la boutique';

  @override
  String get addToCart => 'Ajouter au panier';

  @override
  String get addedToCart => 'Ajoute au panier';

  @override
  String get viewAll => 'Voir tout';

  @override
  String get recommendedForYou => 'Recommande pour toi';

  @override
  String get homeCtaTitle => 'Pret a vider ton placard ?';

  @override
  String get homeCtaSubtitle =>
      'Rejoins des milliers de vendeurs sur FripCash. C\'est gratuit, rapide et securise.';

  @override
  String get homeCtaButton => 'Commencer a vendre';

  @override
  String get offerStatusPending => 'En attente';

  @override
  String get offerStatusRefused => 'Refusee';

  @override
  String partnerDeliveryWithin(String sla) {
    return 'Livraison sous $sla';
  }

  @override
  String sellerDeliversWithin(String sla) {
    return 'Livre sous $sla';
  }

  @override
  String get shippingFeesCalculatedAtCheckout =>
      'Les frais de port sont calcules lors du paiement.';

  @override
  String get notifPackageReadyTitle => 'Colis pret a recuperer';

  @override
  String get notifOrderDeliveredTitle => 'Votre commande a ete livree';

  @override
  String get notifFundsReleasedTitle => 'Paiement vendeur debloque';

  @override
  String get notifGiveFeedbackTitle => 'Donnez votre avis';

  @override
  String get notifOrderUpdateTitle => 'Mise a jour commande';

  @override
  String get notifStayReachableBody =>
      'Restez joignable, le livreur vous contactera.';

  @override
  String get notifCourierCanPickupBody =>
      'Un livreur peut recuperer le colis chez le vendeur.';

  @override
  String get notifRateSellerBody => 'Merci de noter votre vendeur.';

  @override
  String get notifFundsCreditedBody =>
      'Les fonds ont ete credites sur le porte-monnaie vendeur.';

  @override
  String get notifHowWasExperienceBody =>
      'Comment s\'est passee votre experience ?';

  @override
  String get notifJustNow => 'A l\'instant';

  @override
  String get notifOfferAcceptedTitle => 'Offre acceptee';

  @override
  String get notifOfferRefusedTitle => 'Offre refusee';

  @override
  String notifOfferAcceptedBody(String productTitle, String price) {
    return 'Votre offre sur « $productTitle » a ete acceptee a $price GNF.';
  }

  @override
  String notifOfferRefusedBody(String productTitle) {
    return 'Votre offre sur « $productTitle » a ete refusee.';
  }

  @override
  String commissionPercent(String percent) {
    return 'Commission $percent %';
  }

  @override
  String shopPreparationSla(String sla) {
    return 'Preparation sous $sla — mentionne sur votre fiche boutique';
  }

  @override
  String get mockConversionRate => 'Taux de conversion mock : 4,2 %';

  @override
  String orderNumberLabel(String id) {
    return 'N° $id';
  }

  @override
  String orderItemsSummary(int count, String price) {
    return '$count article(s) · $price GNF';
  }

  @override
  String get conditionNewWithTag => 'Neuf avec etiquette';

  @override
  String get conditionNewWithTagDescription => 'Article neuf avec etiquette.';

  @override
  String get conditionNewWithoutTag => 'Neuf sans etiquette';

  @override
  String get conditionNewWithoutTagDescription =>
      'Article neuf sans etiquette.';

  @override
  String get conditionVeryGood => 'Tres bon etat';

  @override
  String get conditionVeryGoodDescription => 'Tres peu porte, tres bon etat.';

  @override
  String get conditionGood => 'Bon etat';

  @override
  String get conditionGoodDescription => 'Legeres traces d\'usage possibles.';

  @override
  String get conditionSatisfactory => 'Satisfaisant';

  @override
  String get conditionSatisfactoryDescription =>
      'Utilise frequemment, usure visible.';

  @override
  String notifHoursAgo(int hours) {
    return 'Il y a $hours h';
  }

  @override
  String get notifYesterday => 'Hier';

  @override
  String get notifNewOrderReceivedTitle => 'Nouvelle commande recue';

  @override
  String get notifPrepareParcelBody =>
      'Preparez votre colis puis cliquez sur \"Colis pret\" sur la commande recue.';

  @override
  String notifPickupParcelOrderBody(String orderId) {
    return 'Recuperez le colis chez le vendeur - commande #$orderId.';
  }

  @override
  String get notifSlaReminderLateTitle => 'Rappel SLA - livraison en retard';

  @override
  String notifSlaReminderLateBody(String orderId, String sla) {
    return 'La commande #$orderId depasse le delai de $sla. Preparez le colis.';
  }

  @override
  String get timeToday => 'Aujourd\'hui';

  @override
  String get timeYesterday => 'Hier';

  @override
  String timeDaysAgo(int count) {
    return 'Il y a $count jour(s)';
  }

  @override
  String timeWeeksAgo(int count) {
    return 'Il y a $count semaine(s)';
  }

  @override
  String get onboardingPrivacyTitle => 'Vos preferences de confidentialite';

  @override
  String get onboardingPrivacyBody1 =>
      'Nous pouvons traiter les informations que vous fournissez activement lors de l\'utilisation de nos services, comme vos informations de compte, annonces et messages.';

  @override
  String get onboardingPrivacyBody2Prefix =>
      'Nous utilisons des cookies et technologies similaires pour ameliorer votre experience. Consultez notre ';

  @override
  String get onboardingPrivacyBody2Suffix => ' pour plus de details.';

  @override
  String get cookiePolicy => 'Politique cookies';

  @override
  String get onboardingDataPurposesTitle =>
      'Nous traitons les donnees pour les finalites suivantes :';

  @override
  String get onboardingDataPurposeSecurity =>
      'Fournir un service sur et securise';

  @override
  String get onboardingDataPurposeAnalytics =>
      'Analyser l\'activite des utilisateurs et les statistiques';

  @override
  String get onboardingDataPurposeMessaging =>
      'Envoyer des messages personnalises lies a nos services';

  @override
  String get acceptAll => 'Tout accepter';

  @override
  String get rejectAll => 'Tout refuser';

  @override
  String get manageCookies => 'Gerer les cookies';

  @override
  String get onboardingSlide1Title => 'Transforme ton placard en argent';

  @override
  String get onboardingSlide1Subtitle =>
      'Vends les vetements que tu ne portes plus a des acheteurs partout en Guinee.';

  @override
  String get onboardingSlide2Title => 'Vendre, c\'est gratuit';

  @override
  String get onboardingSlide2Subtitle =>
      'Pas de frais de publication. Garde plus sur chaque vente.';

  @override
  String get onboardingSlide3Title => 'Livre chez toi';

  @override
  String get onboardingSlide3Subtitle =>
      'Les livreurs FripCash apportent tes trouvailles partout en Guinee — rapide et fiable.';

  @override
  String get onboardingSlide4Title => 'Bienvenue sur FripCash';

  @override
  String get onboardingSlide4Subtitle =>
      'Achete, vends et decouvre mode, maison et plus au meme endroit.';

  @override
  String get onboardingGetStarted => 'Commencer';

  @override
  String get listAnItem => 'Mettre un article en vente';

  @override
  String get shopTypeLabel => 'Type de boutique';

  @override
  String get shopKindProximite => 'Boutique de proximité';

  @override
  String get shopKindProximiteSubtitle =>
      'Épicerie de quartier — commission 5 %, code de retrait, sans livreur FripCash';

  @override
  String get shopKindStandard => 'Boutique classique';

  @override
  String get shopKindStandardSubtitle =>
      'Mode et commerce général — commission 8 % avec livraison FripCash';

  @override
  String get shopCategoryLabel => 'Catégorie de boutique';

  @override
  String get chooseShopCategory => 'Choisir une catégorie';

  @override
  String get shopAddressHint => 'Rue, quartier, point de repère';

  @override
  String get proximitySellSubtitle =>
      'Ajoutez des produits via Excel, la bibliothèque FripCash ou manuellement';

  @override
  String get addFromLibrary => 'Bibliothèque FripCash';

  @override
  String get addFromLibrarySubtitle =>
      'Choisissez des produits, fixez votre prix net et le stock';

  @override
  String get addManually => 'Ajouter manuellement';

  @override
  String get addManuallySubtitle =>
      'Créez une annonce pour un article hors bibliothèque';

  @override
  String get productLibraryTitle => 'Bibliothèque produits';

  @override
  String get searchLibraryHint => 'Rechercher un produit…';

  @override
  String libraryCommissionHint(String percent) {
    return 'Le prix acheteur inclut $percent % de frais de service';
  }

  @override
  String get netPriceLabel => 'Votre prix net (GNF)';

  @override
  String get stockLabel => 'Stock';

  @override
  String get availableToggle => 'Disponible';

  @override
  String get availableToggleHint => 'Marquer comme en stock sans quantité fixe';

  @override
  String publishSelectedItems(int count) {
    return 'Publier $count article(s)';
  }

  @override
  String libraryItemsPublished(int count) {
    return '$count produit(s) publié(s)';
  }

  @override
  String get mixedCartBlocked =>
      'Impossible de mélanger des articles de proximité et des articles avec livraison FripCash. Passez commande séparément.';

  @override
  String get fulfillmentTitle => 'Retrait ou livraison locale';

  @override
  String get fulfillmentModeLabel => 'Mode de remise';

  @override
  String get fulfillmentPickup => 'Retrait sur place';

  @override
  String get fulfillmentPickupSubtitle =>
      'Récupérez en boutique avec votre code — gratuit';

  @override
  String get fulfillmentShopLocal => 'Livraison de proximité (commerçant)';

  @override
  String get fulfillmentShopLocalSubtitle =>
      'Le commerçant livre près de chez vous — gratuit, indiquez votre adresse';

  @override
  String get freeDeliveryLabel => 'Gratuit';

  @override
  String get serviceFeesTitleProximity => 'Frais de service (5 %)';

  @override
  String get serviceFeesDescriptionProximity =>
      'Le prix affiché inclut déjà 5 % de frais FripCash pour les boutiques de proximité. Aucun frais caché au paiement.';

  @override
  String get orderConfirmedProximitySubtitle =>
      'Montrez ce code à la boutique pour récupérer votre commande ou confirmer la livraison.';

  @override
  String get pickupCodeLabel => 'Code de retrait';

  @override
  String get pickupCodeHintPickup =>
      'Présentez ce code en boutique pour retirer votre commande.';

  @override
  String get pickupCodeHintDelivery =>
      'Communiquez ce code au commerçant pour la remise en livraison locale.';

  @override
  String get orderReadyForHandoff => 'Commande prête';

  @override
  String get orderMarkedReadyProximity =>
      'Commande prête — l\'acheteur peut utiliser le code';

  @override
  String get confirmHandoff => 'Confirmer la remise';

  @override
  String get handoffConfirmed => 'Commande remise';

  @override
  String get confirmReceiptTitle => 'Confirmer la réception';

  @override
  String get confirmReceiptBody =>
      'Ne confirmez que lorsque le colis est entre vos mains et conforme. Le paiement est alors versé au vendeur.';

  @override
  String get confirmReceiptButton => 'Confirmer la réception';

  @override
  String get confirmReceiptDialogTitle =>
      'Confirmer que vous avez bien reçu cette commande ?';

  @override
  String get confirmReceiptDialogBody =>
      'Confirmez que vous avez reçu la commande en bon état. Le paiement sera versé au vendeur et cette action est définitive.';

  @override
  String get confirmReceiptYes => 'Oui, libérer le paiement';

  @override
  String get confirmReceiptNotYet => 'Pas encore';

  @override
  String get confirmReceiptSuccess => 'Paiement libéré au vendeur. Merci !';

  @override
  String get confirmReceiptAlreadyDone =>
      'Cette commande a déjà été confirmée.';

  @override
  String get confirmReceiptNotReady =>
      'Cette commande n’est pas encore prête à confirmer.';

  @override
  String get confirmReceiptNotFound => 'Commande introuvable.';

  @override
  String get escrowHeldBuyer =>
      'Conservé en sécurité jusqu’à confirmation de réception';

  @override
  String get escrowReleasedBuyer => 'Paiement envoyé au vendeur';

  @override
  String get awaitingConfirmHint =>
      'Confirmez la réception lorsque le colis est entre vos mains pour libérer le paiement.';

  @override
  String get confirmReceiptDisputeLocked =>
      'Le paiement est bloqué pendant le litige.';

  @override
  String get orderStatusDisputed => 'Litige ouvert';

  @override
  String get escrowDisputeLocked => 'Paiement bloqué pendant le litige';

  @override
  String get disputeSomethingWrongTitle => 'Un problème ?';

  @override
  String get disputeSomethingWrongBody =>
      'Ouvrez un litige si l’article n’est jamais arrivé, est endommagé ou ne correspond pas à l’annonce. Votre paiement reste bloqué et l’admin FripCash examine le chat, les preuves de livraison et l’historique de paiement.';

  @override
  String get disputeButton => 'Litige';

  @override
  String get disputeReportLink => 'Un problème ? Signaler';

  @override
  String get disputeDialogTitle => 'Ouvrir un litige avec le vendeur ?';

  @override
  String disputeDialogBody(String orderId) {
    return 'Expliquez à l’admin ce qui s’est passé pour $orderId. Votre paiement reste bloqué pendant l’examen FripCash (chat, preuves, paiements).';
  }

  @override
  String get disputeSendToAdmin => 'Envoyer à l’admin';

  @override
  String get disputeWhatHappened => 'Que s’est-il passé ?';

  @override
  String get disputeReasonHint =>
      'ex. Article endommagé, mauvaise couleur, jamais livré…';

  @override
  String get disputeReasonFooter =>
      'Ce message est envoyé à l’admin FripCash avec votre commande.';

  @override
  String get disputeOpenBanner =>
      'Litige ouvert — votre paiement reste bloqué jusqu’à l’examen admin.';

  @override
  String disputeYourMessage(String reason) {
    return 'Votre message à l’admin : « $reason »';
  }

  @override
  String get disputeOpenedToast =>
      'Litige envoyé à l’admin. Le paiement reste bloqué.';

  @override
  String get disputeOpenFailed =>
      'Impossible d’ouvrir un litige pour cette commande.';

  @override
  String get adminDisputesTitle => 'Litiges (admin)';

  @override
  String get adminDisputesSubtitle =>
      'File d’attente mock — rembourser ou libérer au vendeur';

  @override
  String get adminDisputesEmpty => 'Aucun litige ouvert pour le moment.';

  @override
  String get adminDisputeRefund => 'Rembourser l’acheteur';

  @override
  String get adminDisputeRelease => 'Libérer au vendeur';

  @override
  String get adminDisputePartial => 'Remboursement partiel';

  @override
  String get adminDisputeResolved => 'Litige traité.';

  @override
  String adminDisputeOpenSince(String when) {
    return 'Ouvert $when';
  }

  @override
  String get notifDisputeOpenedTitle => 'Litige ouvert';

  @override
  String get notifDisputeOpenedBody =>
      'Le paiement est bloqué pendant l’examen FripCash.';

  @override
  String get orderStatusRefunded => 'Remboursé';

  @override
  String get escrowRefundedBuyer =>
      'Paiement clos · remboursé après examen admin';

  @override
  String get refundResolvedBanner =>
      'Remboursement effectué — litige clos par l’admin FripCash.';

  @override
  String get notifRefundIssuedTitle => 'Remboursement effectué';

  @override
  String get notifRefundIssuedBody =>
      'L’admin a clos votre litige avec un remboursement.';

  @override
  String get chatEmoji => 'Emoji';

  @override
  String get chatCamera => 'Caméra';

  @override
  String get chatGallery => 'Galerie';

  @override
  String get chatPhotoCapturedMock => 'Photo capturée (mock).';

  @override
  String get chatPhotoPickedMock => 'Photo ajoutée depuis la galerie (mock).';

  @override
  String get chatCardEscrowHeldTitle => 'Paiement en séquestre';

  @override
  String chatCardEscrowHeldBody(String orderId) {
    return 'Les fonds pour $orderId sont sécurisés jusqu’à confirmation de réception.';
  }

  @override
  String get chatCardWaitingTitle => 'En attente de confirmation';

  @override
  String chatCardWaitingBody(String orderId) {
    return 'Le vendeur attend la confirmation de réception de $orderId.';
  }

  @override
  String get chatCardReleasedTitle => 'Paiement libéré';

  @override
  String chatCardReleasedBody(String orderId) {
    return 'Le paiement pour $orderId a été versé au vendeur.';
  }

  @override
  String get chatCardDisputeTitle => 'Litige bloqué';

  @override
  String chatCardDisputeBody(String orderId) {
    return 'Le paiement pour $orderId est bloqué pendant l’examen FripCash.';
  }

  @override
  String get chatCardOfdTitle => 'En cours de livraison';

  @override
  String chatCardOfdBody(String orderId) {
    return '$orderId est en route. Confirmez la réception quand le colis est entre vos mains.';
  }

  @override
  String chatCardOrderLabel(String orderId) {
    return 'Commande $orderId';
  }

  @override
  String get chatCardReceivedTitle => 'COMMANDE REÇUE ?';

  @override
  String chatCardReceivedBody(String orderId, String amount) {
    return 'Ne confirmez qu’après avoir vérifié le colis pour $orderId$amount. Le paiement va alors au vendeur.';
  }

  @override
  String get chatCardReceiptDoneTitle => 'Réception confirmée';

  @override
  String chatCardReceiptDoneBody(String orderId) {
    return 'Vous avez confirmé $orderId. Le paiement est versé au vendeur.';
  }

  @override
  String get startPreparing => 'Commencer la préparation';

  @override
  String get paymentLocked => 'Paiement bloqué';

  @override
  String get needsActionFilter => 'À traiter';

  @override
  String get disputedFilter => 'Litiges';

  @override
  String get refundedFilter => 'Remboursées';

  @override
  String get openOrdersKpi => 'Commandes ouvertes';

  @override
  String get awaitingConfirmationKpi => 'En attente de confirmation';

  @override
  String get escrowOnHoldKpi => 'En séquestre';

  @override
  String get completedOrdersKpi => 'Terminées';

  @override
  String get searchOrdersHint => 'Rechercher commandes, clients…';

  @override
  String disputesBannerTitle(int count) {
    return '$count litige(s) ouvert(s)';
  }

  @override
  String get viewDisputes => 'Voir';

  @override
  String get buyerActiveOrdersKpi => 'Commandes actives';

  @override
  String get buyerEscrowHeldKpi => 'Séquestre';

  @override
  String get buyerCompletedKpi => 'Terminées';

  @override
  String get allPurchasesFilter => 'Toutes';

  @override
  String get compareAtPriceLabel => 'Ancien prix (GNF)';

  @override
  String get compareAtPriceHint => 'Prix avant remise';

  @override
  String get compareAtPriceInvalid =>
      'L’ancien prix doit être supérieur au prix de vente.';

  @override
  String get discountToggleLabel => 'Appliquer une remise';

  @override
  String get negotiableToggleLabel => 'Accepter les offres';

  @override
  String get maxPhotosReached => 'Maximum 8 photos par annonce.';

  @override
  String get listingSoldOut => 'Épuisé';

  @override
  String get listingActive => 'Active';

  @override
  String get sellerActionStartedPreparing => 'Préparation démarrée';

  @override
  String get disputesBannerBody =>
      'Le paiement reste bloqué jusqu’à l’examen par FripCash.';

  @override
  String get draftsTitle => 'Brouillons';

  @override
  String get draftsReadyToPost => 'Prêts à publier';

  @override
  String get draftsIncomplete => 'Incomplets';

  @override
  String get draftsEmptyTitle => 'Vos brouillons sont ici';

  @override
  String get draftsEmptyReadySubtitle =>
      'Vous n’avez aucun brouillon prêt à publier pour le moment.';

  @override
  String get draftsEmptyIncompleteSubtitle =>
      'Vous n’avez aucun brouillon incomplet pour le moment.';

  @override
  String get savedToDrafts => 'Enregistré dans les brouillons';

  @override
  String get saveToDrafts => 'Enregistrer en brouillon';

  @override
  String get postListing => 'Publier l’annonce';

  @override
  String get copyAListing => 'Copier une annonce';

  @override
  String get copyListingEmpty =>
      'Vous n’avez aucune annonce à copier pour le moment';

  @override
  String get addPhotosTitle => 'Ajouter des photos';

  @override
  String upToPhotos(int count) {
    return 'Jusqu’à $count';
  }

  @override
  String get viewPhotoGuide => 'Voir le guide photo';

  @override
  String get editPhotos => 'Modifier les photos';

  @override
  String get addAtLeastOnePhoto => 'Ajoutez au moins 1 photo ou vidéo.';

  @override
  String get infoSection => 'Infos';

  @override
  String get addCategoryChip => '+ Catégorie';

  @override
  String get addBrandChip => '+ Marque';

  @override
  String get addConditionChip => '+ État';

  @override
  String get addSizeChip => '+ Taille';

  @override
  String get quantityLabel => 'Quantité';

  @override
  String get priceSection => 'Prix';

  @override
  String get shippingSection => 'Livraison';

  @override
  String get domesticShippingPrice => 'Prix de livraison nationale';

  @override
  String locationChip(String location) {
    return 'Lieu : $location';
  }

  @override
  String get worldwideShippingOptional => '+ Mondiale (optionnel)';

  @override
  String hashtagsCount(int count) {
    return 'Hashtags : $count';
  }

  @override
  String get yourPriceLabel => 'Votre prix (ce que vous recevez)';

  @override
  String commissionFeeLabel(String percent) {
    return 'Commission FripCash ($percent %)';
  }

  @override
  String get buyerSeesPriceLabel => 'Prix que les acheteurs verront';

  @override
  String get commissionSellerHint =>
      'Les acheteurs ne voient que le prix total. La commission est incluse automatiquement.';

  @override
  String get listingPreviewTitle => 'Aperçu de l’annonce';

  @override
  String get createNewListing => 'Créer une nouvelle annonce';

  @override
  String get listFromTemplate => 'Annonce depuis un modèle';

  @override
  String get editDraftListings => 'Modifier les brouillons';

  @override
  String get repostAnItem => 'Republier un article';

  @override
  String get nowWithPhotos => 'Avec photos';

  @override
  String get sellPromoTitle => 'Prix transparent';

  @override
  String get niceItsListed => 'Super, c’est en ligne !';

  @override
  String itemsListedProgress(int count) {
    return '$count/5 articles publiés';
  }

  @override
  String get listFiveItemsHint =>
      'Beau travail. Essayez de publier au moins 5 articles pour aider les acheteurs à trouver votre boutique.';

  @override
  String get boostYourListing => 'Booster votre annonce';

  @override
  String get boostListingBody =>
      'Mettez votre article en avant dans la recherche pour vendre plus vite. Frais de boost de 12 %, uniquement si vous vendez.';

  @override
  String get enhanceYourListing => 'Améliorer votre annonce';

  @override
  String get enhanceListingBody =>
      'Aidez les acheteurs à trouver votre article en ajoutant des infos.';

  @override
  String get extraInfo => 'Infos supplémentaires';

  @override
  String get listedBadge => 'EN LIGNE';

  @override
  String get photoTipsTitle => 'Conseils photo';

  @override
  String get getCoverShotTitle => 'Photo de couverture';

  @override
  String get getCoverShotBody =>
      'Montrez clairement votre article en flat lay ou sur mannequin pour la photo principale.';

  @override
  String get captureAnglesTitle => 'Plusieurs angles';

  @override
  String get captureAnglesBody =>
      'Face, dos et côtés aident les acheteurs à comprendre la coupe et la forme.';

  @override
  String get showTagsTitle => 'Étiquettes et labels';

  @override
  String get showTagsBody =>
      'Incluez les étiquettes de marque, de taille et d’entretien quand c’est possible.';

  @override
  String get showDetailsTitle => 'Montrez les détails';

  @override
  String get showDetailsBody =>
      'Des gros plans du tissu, des motifs, des fermoirs et de l’usure rassurent les acheteurs.';

  @override
  String get profileTabShop => 'Boutique';

  @override
  String get profileTabSold => 'Vendus';

  @override
  String get profileTabPurchased => 'Achats';

  @override
  String get profileTabLikes => 'Favoris';

  @override
  String followersCount(int count) {
    return '$count abonnés';
  }

  @override
  String followingCount(int count) {
    return '$count abonnements';
  }

  @override
  String get noReviews => 'aucun avis';

  @override
  String get shopStats => 'Stats boutique';

  @override
  String get trackProgress => 'Suivre les progrès';

  @override
  String get boostingFeesChanging => 'Les frais de boost changent';

  @override
  String get boostingFeesChangingBody =>
      'À partir du 23 mars, le frais pour booster une annonce sera de 12 %.';

  @override
  String get learnMore => 'En savoir plus';

  @override
  String activeListingsCount(int count) {
    return 'Actives ($count annonces)';
  }

  @override
  String get startSellingBuildShop =>
      'Commencez à vendre pour créer votre boutique';

  @override
  String get activeListingsEmpty => 'Vos annonces actives apparaîtront ici';

  @override
  String get bulkActions => 'Actions groupées';

  @override
  String get filterToShip => 'À expédier';

  @override
  String get filterInTransit => 'En transit';

  @override
  String get filterCancelled => 'Annulées';

  @override
  String get emptySoldToShip => 'Les articles à expédier apparaîtront ici';

  @override
  String get emptySoldInTransit => 'Les articles en transit apparaîtront ici';

  @override
  String get emptySoldCancelled => 'Les ventes annulées apparaîtront ici';

  @override
  String get emptySoldCompleted => 'Les ventes terminées apparaîtront ici';

  @override
  String get emptySoldAll => 'Les articles vendus apparaîtront ici';

  @override
  String get emptyPurchasedOrders => 'Vos commandes apparaîtront ici';

  @override
  String get outfits => 'Tenues';

  @override
  String get likedItems => 'Articles aimés';

  @override
  String get likesInterestHint =>
      'Vous avez raté un article aimé ? Appuyez sur « Montrer mon intérêt » et nous préviendrons le nouveau propriétaire. ';

  @override
  String get seeMyLikes => 'Voir mes favoris';

  @override
  String get emptyLikesMessage =>
      'Les articles que vous aimez apparaîtront ici. Allez dans Parcourir pour trouver votre prochain coup de cœur.';

  @override
  String get myAccountTitle => 'Mon compte';

  @override
  String get fripCashBalance => 'Solde FripCash';

  @override
  String get sellMoreSection => 'Vendre plus';

  @override
  String get boostShop => 'Booster la boutique';

  @override
  String get boostShopLocked =>
      'Commencez à vendre pour débloquer Boost Boutique';

  @override
  String get bundles => 'Lots';

  @override
  String get badgeNew => 'Nouveau';

  @override
  String get bundlesSellersOnly => 'Les lots sont réservés aux vendeurs';

  @override
  String get supportSection => 'Assistance';

  @override
  String get soldItemIssues => 'Problèmes d’articles vendus';

  @override
  String get helpAndSupport => 'Aide et support';

  @override
  String get settingsSection => 'Paramètres';

  @override
  String get accountDetails => 'Détails du compte';

  @override
  String get paymentSettings => 'Paramètres de paiement';

  @override
  String get personalization => 'Personnalisation';

  @override
  String get twoFactorAuth => 'Authentification à deux facteurs';

  @override
  String get twoFactorComingSoon => '2FA bientôt disponible';

  @override
  String get preferences => 'Préférences';

  @override
  String get privacy => 'Confidentialité';

  @override
  String appVersionLabel(String version) {
    return 'FripCash version $version';
  }

  @override
  String get yourFripCashBalance => 'Votre solde fripcash';

  @override
  String pendingAmountGnf(String amount) {
    return '$amount GNF en attente';
  }

  @override
  String get noBalanceToWithdraw => 'Aucun solde à retirer';

  @override
  String get latestTransactions => 'Dernières transactions';

  @override
  String get seeAll => 'Tout voir';

  @override
  String get noTransactionsHint =>
      'Dès que vous vendez, vos gains apparaîtront ici.';

  @override
  String get cameraLabel => 'Appareil photo';

  @override
  String get sellConditionBrandNew => 'Neuf';

  @override
  String get sellConditionBrandNewDesc =>
      'Non utiliséé, avec emballage ou étiquettes d’origine';

  @override
  String get sellConditionLikeNew => 'Comme neuf';

  @override
  String get sellConditionLikeNewDesc =>
      'État impeccable d’occasion ou neuf sans étiquette';

  @override
  String get sellConditionExcellent => 'Occasion - Excellent';

  @override
  String get sellConditionExcellentDesc => 'Peu porté, sans défaut visible';

  @override
  String get sellConditionGoodUsed => 'Occasion - Bon';

  @override
  String get sellConditionGoodUsedDesc =>
      'Petits défauts ou signes d’usure à noter dans la description ou les photos';

  @override
  String get sellConditionFair => 'Occasion - Correct';

  @override
  String get sellConditionFairDesc =>
      'Défauts ou usure visibles à noter dans la description ou les photos';

  @override
  String get colorWhite => 'Blanc';

  @override
  String get colorBlack => 'Noir';

  @override
  String get colorBrown => 'Marron';

  @override
  String get colorGrey => 'Gris';

  @override
  String get colorBeige => 'Beige';

  @override
  String get colorPink => 'Rose';

  @override
  String get colorPurple => 'Violet';

  @override
  String get colorRed => 'Rouge';

  @override
  String get colorYellow => 'Jaune';

  @override
  String get colorBlue => 'Bleu';

  @override
  String get colorGreen => 'Vert';

  @override
  String get colorOrange => 'Orange';

  @override
  String get sellStepCategory => 'Catégorie';

  @override
  String get sellStepPhotos => 'Photos';

  @override
  String get sellStepDetails => 'Détails';

  @override
  String get sellStepPrice => 'Prix';

  @override
  String get sellStep1CalloutTitle =>
      'Étape 1 sur 4 — on commence par la catégorie';

  @override
  String get sellStep1CalloutBody =>
      'Le bon rayon dès le départ : moins d\'annonces mal classées, plus de ventes.';

  @override
  String get chooseACategory => 'Choisis une catégorie';

  @override
  String get sellContinueToPhotos => 'Continuer vers les photos';

  @override
  String get sellContinueToDetails => 'Continuer vers les détails';

  @override
  String get sellContinueToPrice => 'Continuer vers le prix';

  @override
  String get sellVisualHome => 'Maison';

  @override
  String get sellVisualPremium => 'Premium';

  @override
  String get sellSubDresses => 'Robes';

  @override
  String get sellSubTops => 'Hauts';

  @override
  String get sellSubBottoms => 'Bas';

  @override
  String get sellSubShoes => 'Chaussures';

  @override
  String get sellSubAccessories => 'Accessoires';

  @override
  String get sellSubFurniture => 'Meubles';

  @override
  String get sellSubDecor => 'Déco';

  @override
  String get sellSubKitchen => 'Cuisine';

  @override
  String get sellSubPhones => 'Téléphones';

  @override
  String get sellSubComputers => 'Ordinateurs';

  @override
  String get sellSubTvs => 'TV';

  @override
  String get sellSubOther => 'Autre';

  @override
  String get availableForWithdrawal => 'Disponible pour retrait';

  @override
  String get withdrawOnOrangeMoney => 'Retirer sur Orange Money';

  @override
  String escrowBarLabel(String amount, int count) {
    return '$amount GNF en séquestre · $count commandes';
  }

  @override
  String get shopTabBoutique => 'Boutique';

  @override
  String get shopTabShipped => 'Expédiées';

  @override
  String ordersToPrepareBefore(int count, String time) {
    return '$count commandes à préparer avant $time';
  }

  @override
  String get courierTipTitle =>
      'Le livreur passe quand tu marques « Colis prêt »';

  @override
  String get courierTipBody =>
      'Il est prévenu automatiquement. Prépare le colis avant d\'appuyer.';

  @override
  String get youReceive => 'Tu reçois';

  @override
  String get noOrdersToPrepare => 'Aucune commande à préparer pour le moment.';

  @override
  String get noShippedOrders => 'Aucune expédition en cours.';

  @override
  String get noSoldOrdersYet => 'Aucune vente terminée pour le moment.';

  @override
  String get pickupInStoreTitle => 'Retrait en boutique';

  @override
  String get sharePickupCode => 'Partager le code';

  @override
  String pickupOrderPaidLine(String id) {
    return 'Commande $id · déjà payée';
  }

  @override
  String get yourOrderTitle => 'Ta commande';

  @override
  String get paidViaOrangeMoney => 'Payé via Orange Money';

  @override
  String get pickupAnyoneTitle => 'N\'importe qui peut récupérer avec ce code';

  @override
  String get pickupAnyoneBody =>
      'Donne-le à ton enfant ou à un voisin. Le boutiquier vérifie le code et remet la commande.';

  @override
  String pickupCodeCopied(String code) {
    return 'Code $code copié — partage-le avec la personne qui ira chercher.';
  }

  @override
  String get proximityPickupOnlyHint =>
      'Boutique de quartier : pas de livraison. Tu paies en Orange Money, tu reçois un code, tu retires en boutique.';

  @override
  String get sellerPickupCodeHint =>
      'Même code que le client — vérifie-le avant de remettre la commande.';

  @override
  String get retryAction => 'Réessayer';

  @override
  String get catalogLoadError =>
      'Impossible de charger les données du serveur. Réessaie.';

  @override
  String get walletLoadError =>
      'Impossible de charger ton portefeuille. Réessaie.';

  @override
  String get courierUseCourierLogin =>
      'Les comptes livreur utilisent l\'Espace livreur. Connecte-toi là-bas, pas sur la marketplace.';

  @override
  String get approveShopDemo => 'Approuver la boutique (démo)';

  @override
  String get shopApprovedDemo =>
      'Boutique approuvée — tu peux publier des annonces.';

  @override
  String get legalTermsBody =>
      'Conditions d\'utilisation FripCash (démo). En utilisant l\'app tu acceptes les règles marketplace, la libération d\'escrow et l\'anti-contournement. Le texte juridique complet arrivera en production.';

  @override
  String get legalPrivacyBody =>
      'Politique de confidentialité FripCash (démo). Nous traitons téléphone et données de commande pour opérer la marketplace. La politique complète arrivera en production.';

  @override
  String get searchScreenTitle => 'Recherche';

  @override
  String get searchScreenHint => 'Rechercher produits, marques, catégories…';

  @override
  String get bulkActionsHint => 'Gère stock et prix depuis Mes annonces.';

  @override
  String get listingFilterTitle => 'Filtrer les annonces';

  @override
  String get showInStockOnly => 'En stock seulement';

  @override
  String get challengeJoinedDemo => 'Défi suivi pour cette session démo.';
}
