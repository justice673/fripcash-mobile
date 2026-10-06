import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'FripCash'**
  String get appTitle;

  /// No description provided for @welcomeBuySell.
  ///
  /// In en, this message translates to:
  /// **'Buy and sell across Guinea - fashion, home, electronics & more'**
  String get welcomeBuySell;

  /// No description provided for @trustBenefitNoCommissionLine1.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get trustBenefitNoCommissionLine1;

  /// No description provided for @trustBenefitNoCommissionLine2.
  ///
  /// In en, this message translates to:
  /// **'commission'**
  String get trustBenefitNoCommissionLine2;

  /// No description provided for @trustBenefitLocalCustomersLine1.
  ///
  /// In en, this message translates to:
  /// **'Customers from'**
  String get trustBenefitLocalCustomersLine1;

  /// No description provided for @trustBenefitLocalCustomersLine2.
  ///
  /// In en, this message translates to:
  /// **'your city'**
  String get trustBenefitLocalCustomersLine2;

  /// No description provided for @trustBenefitCodLine1.
  ///
  /// In en, this message translates to:
  /// **'Paid on'**
  String get trustBenefitCodLine1;

  /// No description provided for @trustBenefitCodLine2.
  ///
  /// In en, this message translates to:
  /// **'delivery'**
  String get trustBenefitCodLine2;

  /// No description provided for @signUpButton.
  ///
  /// In en, this message translates to:
  /// **'Sign up for FripCash'**
  String get signUpButton;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get alreadyHaveAccount;

  /// No description provided for @aboutFripCashPrefix.
  ///
  /// In en, this message translates to:
  /// **'About FripCash: '**
  String get aboutFripCashPrefix;

  /// No description provided for @ourPlatform.
  ///
  /// In en, this message translates to:
  /// **'Our platform'**
  String get ourPlatform;

  /// No description provided for @sellAnItem.
  ///
  /// In en, this message translates to:
  /// **'Sell an item'**
  String get sellAnItem;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @brand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brand;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @condition.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get condition;

  /// No description provided for @sizes.
  ///
  /// In en, this message translates to:
  /// **'Sizes'**
  String get sizes;

  /// No description provided for @colours.
  ///
  /// In en, this message translates to:
  /// **'Colours'**
  String get colours;

  /// No description provided for @viewSizeGuide.
  ///
  /// In en, this message translates to:
  /// **'View size guide'**
  String get viewSizeGuide;

  /// No description provided for @openSizeGuide.
  ///
  /// In en, this message translates to:
  /// **'Open size guide'**
  String get openSizeGuide;

  /// No description provided for @allSizes.
  ///
  /// In en, this message translates to:
  /// **'All sizes'**
  String get allSizes;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get backToHome;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeBack;

  /// No description provided for @homeHelloName.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String homeHelloName(String name);

  /// No description provided for @homeWelcomeReady.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back,\nReady to Continue'**
  String get homeWelcomeReady;

  /// No description provided for @homeExploreTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get homeExploreTitle;

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'A dress, rice, a shop...'**
  String get homeSearchHint;

  /// No description provided for @homeSearchUniversesHint.
  ///
  /// In en, this message translates to:
  /// **'Search across all four universes at once'**
  String get homeSearchUniversesHint;

  /// No description provided for @homeLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'{zone} - {quartier}'**
  String homeLocationLabel(String zone, String quartier);

  /// No description provided for @homeModeSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Fashion'**
  String get homeModeSectionTitle;

  /// No description provided for @homeModeSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'clothes, bags, shoes'**
  String get homeModeSectionSubtitle;

  /// No description provided for @homeCoursesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get homeCoursesSectionTitle;

  /// No description provided for @homeCoursesSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'food and home essentials'**
  String get homeCoursesSectionSubtitle;

  /// No description provided for @homeUniverseSecondeMainSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Between individuals'**
  String get homeUniverseSecondeMainSubtitle;

  /// No description provided for @homeUniverseArticlesNeufsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Shops and merchants'**
  String get homeUniverseArticlesNeufsSubtitle;

  /// No description provided for @homeUniverseQuartierSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pickup by code'**
  String get homeUniverseQuartierSubtitle;

  /// No description provided for @homeUniverseEnseignesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'City delivery'**
  String get homeUniverseEnseignesSubtitle;

  /// No description provided for @homeUniverseArticlesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String homeUniverseArticlesCount(int count);

  /// No description provided for @homeUniverseQuartierCount.
  ///
  /// In en, this message translates to:
  /// **'{count} in {quartier}'**
  String homeUniverseQuartierCount(int count, String quartier);

  /// No description provided for @homeUniverseEnseignesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} near you'**
  String homeUniverseEnseignesCount(int count);

  /// No description provided for @homeNouveautesTitle.
  ///
  /// In en, this message translates to:
  /// **'New arrivals'**
  String get homeNouveautesTitle;

  /// No description provided for @homeTwoUniversesTitle.
  ///
  /// In en, this message translates to:
  /// **'Two universes, never mixed.'**
  String get homeTwoUniversesTitle;

  /// No description provided for @homeTwoUniversesBody.
  ///
  /// In en, this message translates to:
  /// **'Fashion and groceries never cross paths — except in search.'**
  String get homeTwoUniversesBody;

  /// No description provided for @homeBigSaleTitle.
  ///
  /// In en, this message translates to:
  /// **'Big Sale'**
  String get homeBigSaleTitle;

  /// No description provided for @homeBigSaleOffer.
  ///
  /// In en, this message translates to:
  /// **'Up to 50%'**
  String get homeBigSaleOffer;

  /// No description provided for @homeBigSaleNow.
  ///
  /// In en, this message translates to:
  /// **'Happening Now'**
  String get homeBigSaleNow;

  /// No description provided for @homeSearchHintShort.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get homeSearchHintShort;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account to continue.'**
  String get loginSubtitle;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPasswordQuestion.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPasswordQuestion;

  /// No description provided for @yourPassword.
  ///
  /// In en, this message translates to:
  /// **'Your password'**
  String get yourPassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @courierSpaceDemo.
  ///
  /// In en, this message translates to:
  /// **'Courier space (demo)'**
  String get courierSpaceDemo;

  /// No description provided for @noAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccountPrompt;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @joinFripCash.
  ///
  /// In en, this message translates to:
  /// **'Join FripCash'**
  String get joinFripCash;

  /// No description provided for @signUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Three steps and you\'re off.'**
  String get signUpSubtitle;

  /// No description provided for @signUpStepAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get signUpStepAccountTitle;

  /// No description provided for @signUpStepAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Who you are'**
  String get signUpStepAccountSubtitle;

  /// No description provided for @signUpStepProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get signUpStepProfileTitle;

  /// No description provided for @signUpStepProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your info'**
  String get signUpStepProfileSubtitle;

  /// No description provided for @signUpStepLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get signUpStepLoginTitle;

  /// No description provided for @signUpStepLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Login info'**
  String get signUpStepLoginSubtitle;

  /// No description provided for @signUpStepCommerceTitle.
  ///
  /// In en, this message translates to:
  /// **'Your business'**
  String get signUpStepCommerceTitle;

  /// No description provided for @signUpStepCommerceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Service area'**
  String get signUpStepCommerceSubtitle;

  /// No description provided for @signUpStepInfosTitle.
  ///
  /// In en, this message translates to:
  /// **'Your info'**
  String get signUpStepInfosTitle;

  /// No description provided for @signUpStepInfosSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Account & shop'**
  String get signUpStepInfosSubtitle;

  /// No description provided for @signUpStepSellerTitle.
  ///
  /// In en, this message translates to:
  /// **'Seller'**
  String get signUpStepSellerTitle;

  /// No description provided for @signUpStepSellerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Selling info'**
  String get signUpStepSellerSubtitle;

  /// No description provided for @signUpContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get signUpContinue;

  /// No description provided for @iSignUpAs.
  ///
  /// In en, this message translates to:
  /// **'I sign up as'**
  String get iSignUpAs;

  /// No description provided for @shopNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Shop name'**
  String get shopNameLabel;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @shopNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your shop name'**
  String get shopNameHint;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your full name'**
  String get fullNameHint;

  /// No description provided for @zone.
  ///
  /// In en, this message translates to:
  /// **'Zone'**
  String get zone;

  /// No description provided for @chooseYourZone.
  ///
  /// In en, this message translates to:
  /// **'Choose your zone'**
  String get chooseYourZone;

  /// No description provided for @detailedAddress.
  ///
  /// In en, this message translates to:
  /// **'Detailed address'**
  String get detailedAddress;

  /// No description provided for @addressHint.
  ///
  /// In en, this message translates to:
  /// **'Street, neighborhood, landmark'**
  String get addressHint;

  /// No description provided for @maxDeliveryDelay.
  ///
  /// In en, this message translates to:
  /// **'Maximum delivery delay'**
  String get maxDeliveryDelay;

  /// No description provided for @chooseDelay.
  ///
  /// In en, this message translates to:
  /// **'Choose a delay'**
  String get chooseDelay;

  /// No description provided for @shopLogo.
  ///
  /// In en, this message translates to:
  /// **'Shop logo'**
  String get shopLogo;

  /// No description provided for @logoAddedPreview.
  ///
  /// In en, this message translates to:
  /// **'Logo added (preview)'**
  String get logoAddedPreview;

  /// No description provided for @addLogo.
  ///
  /// In en, this message translates to:
  /// **'Add a logo'**
  String get addLogo;

  /// No description provided for @shopDescription.
  ///
  /// In en, this message translates to:
  /// **'Shop description'**
  String get shopDescription;

  /// No description provided for @describeBusiness.
  ///
  /// In en, this message translates to:
  /// **'Describe your activity'**
  String get describeBusiness;

  /// No description provided for @choosePassword.
  ///
  /// In en, this message translates to:
  /// **'Choose a password'**
  String get choosePassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @confirmYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirmYourPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordStrengthWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get passwordStrengthWeak;

  /// No description provided for @passwordStrengthFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get passwordStrengthFair;

  /// No description provided for @passwordStrengthGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get passwordStrengthGood;

  /// No description provided for @passwordStrengthStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get passwordStrengthStrong;

  /// No description provided for @passwordStrengthHintMin.
  ///
  /// In en, this message translates to:
  /// **'At least {count} characters needed'**
  String passwordStrengthHintMin(int count);

  /// No description provided for @passwordStrengthHintOk.
  ///
  /// In en, this message translates to:
  /// **'Looks good — keep going'**
  String get passwordStrengthHintOk;

  /// No description provided for @passwordRuleMinLength.
  ///
  /// In en, this message translates to:
  /// **'{count}+ characters'**
  String passwordRuleMinLength(int count);

  /// No description provided for @passwordRuleLetter.
  ///
  /// In en, this message translates to:
  /// **'A letter'**
  String get passwordRuleLetter;

  /// No description provided for @passwordRuleDigit.
  ///
  /// In en, this message translates to:
  /// **'A number'**
  String get passwordRuleDigit;

  /// No description provided for @needHelp.
  ///
  /// In en, this message translates to:
  /// **'Need help?'**
  String get needHelp;

  /// No description provided for @alreadyHaveAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccountPrompt;

  /// No description provided for @buyerRole.
  ///
  /// In en, this message translates to:
  /// **'Buyer'**
  String get buyerRole;

  /// No description provided for @individualSellerRole.
  ///
  /// In en, this message translates to:
  /// **'Individual seller'**
  String get individualSellerRole;

  /// No description provided for @shopRole.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shopRole;

  /// No description provided for @enseigneQuartierRole.
  ///
  /// In en, this message translates to:
  /// **'Neighborhood shop'**
  String get enseigneQuartierRole;

  /// No description provided for @signUpRoleBuyerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'I just want to buy'**
  String get signUpRoleBuyerSubtitle;

  /// No description provided for @signUpRoleSellerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'I sell clothes I no longer wear'**
  String get signUpRoleSellerSubtitle;

  /// No description provided for @signUpRoleSellerFootnote.
  ///
  /// In en, this message translates to:
  /// **'my listings go to Second-hand'**
  String get signUpRoleSellerFootnote;

  /// No description provided for @signUpRoleShopSubtitle.
  ///
  /// In en, this message translates to:
  /// **'I sell new items'**
  String get signUpRoleShopSubtitle;

  /// No description provided for @signUpRoleShopFootnote.
  ///
  /// In en, this message translates to:
  /// **'my listings go to New items'**
  String get signUpRoleShopFootnote;

  /// No description provided for @commerceLocalRole.
  ///
  /// In en, this message translates to:
  /// **'Local business'**
  String get commerceLocalRole;

  /// No description provided for @signUpRoleCommerceLocalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Grocery, education, small local shops'**
  String get signUpRoleCommerceLocalSubtitle;

  /// No description provided for @signUpRoleCommerceLocalFootnote.
  ///
  /// In en, this message translates to:
  /// **'my listings go to Neighborhood shops'**
  String get signUpRoleCommerceLocalFootnote;

  /// No description provided for @grandeSurfaceRole.
  ///
  /// In en, this message translates to:
  /// **'Large specialized retailer'**
  String get grandeSurfaceRole;

  /// No description provided for @signUpRoleGrandeSurfaceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Major brands and large companies'**
  String get signUpRoleGrandeSurfaceSubtitle;

  /// No description provided for @signUpRoleGrandeSurfaceFootnote.
  ///
  /// In en, this message translates to:
  /// **'manual validation by our team'**
  String get signUpRoleGrandeSurfaceFootnote;

  /// No description provided for @signUpPerimeterTitle.
  ///
  /// In en, this message translates to:
  /// **'What area do you serve?'**
  String get signUpPerimeterTitle;

  /// No description provided for @signUpPerimeterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This one question changes everything: it decides where your shop appears on the home screen.'**
  String get signUpPerimeterSubtitle;

  /// No description provided for @signUpPerimeterQuartierTitle.
  ///
  /// In en, this message translates to:
  /// **'My neighborhood'**
  String get signUpPerimeterQuartierTitle;

  /// No description provided for @signUpPerimeterQuartierBody.
  ///
  /// In en, this message translates to:
  /// **'Grocery, food, corner shop. My customers live nearby and can pick up in person.'**
  String get signUpPerimeterQuartierBody;

  /// No description provided for @signUpPerimeterVilleTitle.
  ///
  /// In en, this message translates to:
  /// **'The whole city'**
  String get signUpPerimeterVilleTitle;

  /// No description provided for @signUpPerimeterVilleBody.
  ///
  /// In en, this message translates to:
  /// **'Store or brand. I deliver across several districts of Conakry.'**
  String get signUpPerimeterVilleBody;

  /// No description provided for @signUpPerimeterQuartierHintTitle.
  ///
  /// In en, this message translates to:
  /// **'My neighborhood'**
  String get signUpPerimeterQuartierHintTitle;

  /// No description provided for @signUpPerimeterQuartierHintBody.
  ///
  /// In en, this message translates to:
  /// **'One neighborhood to fill in, pickup by code enabled, storefront in Neighborhood shops.'**
  String get signUpPerimeterQuartierHintBody;

  /// No description provided for @signUpPerimeterVilleHintTitle.
  ///
  /// In en, this message translates to:
  /// **'The whole city'**
  String get signUpPerimeterVilleHintTitle;

  /// No description provided for @signUpPerimeterVilleHintBody.
  ///
  /// In en, this message translates to:
  /// **'Store address, delivery zones and delays, storefront in Partner brands.'**
  String get signUpPerimeterVilleHintBody;

  /// No description provided for @listingDestinationSecondeMain.
  ///
  /// In en, this message translates to:
  /// **'Second-hand'**
  String get listingDestinationSecondeMain;

  /// No description provided for @listingDestinationArticlesNeufs.
  ///
  /// In en, this message translates to:
  /// **'New items'**
  String get listingDestinationArticlesNeufs;

  /// No description provided for @listingDestinationQuartier.
  ///
  /// In en, this message translates to:
  /// **'Neighborhood shops'**
  String get listingDestinationQuartier;

  /// No description provided for @listingDestinationEnseignes.
  ///
  /// In en, this message translates to:
  /// **'Partner brands'**
  String get listingDestinationEnseignes;

  /// No description provided for @listingPublishedInSection.
  ///
  /// In en, this message translates to:
  /// **'Your listing is live in the {section} section.'**
  String listingPublishedInSection(String section);

  /// No description provided for @addSellerProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a seller profile'**
  String get addSellerProfileTitle;

  /// No description provided for @addSellerProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep the same account — no need to sign up again.'**
  String get addSellerProfileSubtitle;

  /// No description provided for @addSellerProfileDestinationHint.
  ///
  /// In en, this message translates to:
  /// **'Your listings will appear in Second-hand.'**
  String get addSellerProfileDestinationHint;

  /// No description provided for @addSellerProfileConfirm.
  ///
  /// In en, this message translates to:
  /// **'Activate seller profile'**
  String get addSellerProfileConfirm;

  /// No description provided for @addSellerProfileSuccess.
  ///
  /// In en, this message translates to:
  /// **'Seller profile activated. You can list from the Sell tab.'**
  String get addSellerProfileSuccess;

  /// No description provided for @addSellerProfileSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sell second-hand without creating a new account'**
  String get addSellerProfileSettingsSubtitle;

  /// No description provided for @becomeSellerTitle.
  ///
  /// In en, this message translates to:
  /// **'Become a seller'**
  String get becomeSellerTitle;

  /// No description provided for @becomeSellerChooseType.
  ///
  /// In en, this message translates to:
  /// **'What kind of seller do you want to be?'**
  String get becomeSellerChooseType;

  /// No description provided for @becomeSellerStepTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Seller profile'**
  String get becomeSellerStepTypeTitle;

  /// No description provided for @becomeSellerStepTypeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how you sell'**
  String get becomeSellerStepTypeSubtitle;

  /// No description provided for @becomeSellerStepDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get becomeSellerStepDetailsTitle;

  /// No description provided for @becomeSellerStepDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Shop & delivery info'**
  String get becomeSellerStepDetailsSubtitle;

  /// No description provided for @becomeSellerDestinationHint.
  ///
  /// In en, this message translates to:
  /// **'Your listings will appear in {section}.'**
  String becomeSellerDestinationHint(String section);

  /// No description provided for @becomeSellerSuccess.
  ///
  /// In en, this message translates to:
  /// **'Seller profile activated. You can list from the Sell tab.'**
  String get becomeSellerSuccess;

  /// No description provided for @becomeSellerAccountTile.
  ///
  /// In en, this message translates to:
  /// **'Become a seller'**
  String get becomeSellerAccountTile;

  /// No description provided for @becomeSellerAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Same account — pick how you want to sell'**
  String get becomeSellerAccountSubtitle;

  /// No description provided for @becomeSellerActivate.
  ///
  /// In en, this message translates to:
  /// **'Activate seller profile'**
  String get becomeSellerActivate;

  /// No description provided for @sellerPendingVerificationMessage.
  ///
  /// In en, this message translates to:
  /// **'Your shop will be visible after our team validates it.'**
  String get sellerPendingVerificationMessage;

  /// No description provided for @sellerAccountSection.
  ///
  /// In en, this message translates to:
  /// **'Seller profile'**
  String get sellerAccountSection;

  /// No description provided for @upgradeToShopSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to a shop, neighborhood store, or partner brand (review may apply).'**
  String get upgradeToShopSubtitle;

  /// No description provided for @upgradeToShopChooseType.
  ///
  /// In en, this message translates to:
  /// **'What kind of shop do you want to create?'**
  String get upgradeToShopChooseType;

  /// No description provided for @sellerVerificationPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification pending'**
  String get sellerVerificationPendingTitle;

  /// No description provided for @sellerVerificationPendingBody.
  ///
  /// In en, this message translates to:
  /// **'Your application is under review. You can publish once approved.'**
  String get sellerVerificationPendingBody;

  /// No description provided for @sellerProfileActiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Seller profile active'**
  String get sellerProfileActiveTitle;

  /// No description provided for @becomeSellerRequiredHint.
  ///
  /// In en, this message translates to:
  /// **'Activate a seller profile to access this area. Your purchases stay on the same account.'**
  String get becomeSellerRequiredHint;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get backToLogin;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number to receive a verification code.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCode;

  /// No description provided for @smsCodeInfo.
  ///
  /// In en, this message translates to:
  /// **'You will receive an SMS with a 6-digit code.'**
  String get smsCodeInfo;

  /// No description provided for @passwordUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully.'**
  String get passwordUpdatedSuccess;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @newPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordTitle;

  /// No description provided for @newPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password for your account.'**
  String get newPasswordSubtitle;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordLabel;

  /// No description provided for @resetPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPasswordButton;

  /// No description provided for @accountCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully. Sign in now.'**
  String get accountCreatedSuccess;

  /// No description provided for @newCodeSent.
  ///
  /// In en, this message translates to:
  /// **'A new code has been sent.'**
  String get newCodeSent;

  /// No description provided for @verificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get verificationTitle;

  /// No description provided for @enterCodeSentTo.
  ///
  /// In en, this message translates to:
  /// **'Enter the code sent to'**
  String get enterCodeSentTo;

  /// No description provided for @resendCodeIn.
  ///
  /// In en, this message translates to:
  /// **'Resend code in'**
  String get resendCodeIn;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @deviceVerification.
  ///
  /// In en, this message translates to:
  /// **'Device verification'**
  String get deviceVerification;

  /// No description provided for @contentAvailableAfterVerification.
  ///
  /// In en, this message translates to:
  /// **'Requested content will be available after verification.'**
  String get contentAvailableAfterVerification;

  /// No description provided for @marketingConsentText.
  ///
  /// In en, this message translates to:
  /// **'I would like to receive personalized offers and updates from FripCash by email.'**
  String get marketingConsentText;

  /// No description provided for @termsPrefix.
  ///
  /// In en, this message translates to:
  /// **'By signing up, I confirm that I accept the '**
  String get termsPrefix;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsAndConditions;

  /// No description provided for @termsMiddle.
  ///
  /// In en, this message translates to:
  /// **' of FripCash, that I have read the '**
  String get termsMiddle;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsSuffix.
  ///
  /// In en, this message translates to:
  /// **', and that I am at least 18 years old.'**
  String get termsSuffix;

  /// No description provided for @sellTitle.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get sellTitle;

  /// No description provided for @sellerDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Seller dashboard'**
  String get sellerDashboardTitle;

  /// No description provided for @sellerDashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Orders, offers, stock and sales history.'**
  String get sellerDashboardSubtitle;

  /// No description provided for @publishQuickly.
  ///
  /// In en, this message translates to:
  /// **'List your item in just a few minutes.'**
  String get publishQuickly;

  /// No description provided for @sellAsIndividual.
  ///
  /// In en, this message translates to:
  /// **'Sell as an individual'**
  String get sellAsIndividual;

  /// No description provided for @sellAsIndividualSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Resell items you no longer use.'**
  String get sellAsIndividualSubtitle;

  /// No description provided for @createShop.
  ///
  /// In en, this message translates to:
  /// **'Create a shop'**
  String get createShop;

  /// No description provided for @createShopSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your professional shop and sell across Guinea.'**
  String get createShopSubtitle;

  /// No description provided for @myListings.
  ///
  /// In en, this message translates to:
  /// **'My listings'**
  String get myListings;

  /// No description provided for @manageListingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your items, stock and prices.'**
  String get manageListingsSubtitle;

  /// No description provided for @importExcelCatalog.
  ///
  /// In en, this message translates to:
  /// **'Import Excel catalog'**
  String get importExcelCatalog;

  /// No description provided for @importExcelSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Bulk update for shops and brands.'**
  String get importExcelSubtitle;

  /// No description provided for @listingPublishedTitle.
  ///
  /// In en, this message translates to:
  /// **'Listing published!'**
  String get listingPublishedTitle;

  /// No description provided for @listingPublishedSubtitleSuffix.
  ///
  /// In en, this message translates to:
  /// **'is now visible on FripCash.'**
  String get listingPublishedSubtitleSuffix;

  /// No description provided for @displayPricePrefix.
  ///
  /// In en, this message translates to:
  /// **'Displayed price'**
  String get displayPricePrefix;

  /// No description provided for @publishAnotherItem.
  ///
  /// In en, this message translates to:
  /// **'List another item'**
  String get publishAnotherItem;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @noListings.
  ///
  /// In en, this message translates to:
  /// **'No listings'**
  String get noListings;

  /// No description provided for @noListingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Publish your first item to start selling.'**
  String get noListingsSubtitle;

  /// No description provided for @createListingAction.
  ///
  /// In en, this message translates to:
  /// **'Create listing'**
  String get createListingAction;

  /// No description provided for @outOfStockInactive.
  ///
  /// In en, this message translates to:
  /// **'Out of stock - listing inactive'**
  String get outOfStockInactive;

  /// No description provided for @lowStockPrefix.
  ///
  /// In en, this message translates to:
  /// **'Almost out of stock'**
  String get lowStockPrefix;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'remaining'**
  String get remaining;

  /// No description provided for @stock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stock;

  /// No description provided for @views.
  ///
  /// In en, this message translates to:
  /// **'views'**
  String get views;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get outOfStock;

  /// No description provided for @editListing.
  ///
  /// In en, this message translates to:
  /// **'Edit listing'**
  String get editListing;

  /// No description provided for @editPrice.
  ///
  /// In en, this message translates to:
  /// **'Edit price'**
  String get editPrice;

  /// No description provided for @addStock.
  ///
  /// In en, this message translates to:
  /// **'Add stock'**
  String get addStock;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @newNetPrice.
  ///
  /// In en, this message translates to:
  /// **'New net price'**
  String get newNetPrice;

  /// No description provided for @amountInGnf.
  ///
  /// In en, this message translates to:
  /// **'Amount in GNF'**
  String get amountInGnf;

  /// No description provided for @gnf.
  ///
  /// In en, this message translates to:
  /// **'GNF'**
  String get gnf;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @quantityToAdd.
  ///
  /// In en, this message translates to:
  /// **'Quantity to add'**
  String get quantityToAdd;

  /// No description provided for @deleteListingQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete listing?'**
  String get deleteListingQuestion;

  /// No description provided for @irreversibleAction.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get irreversibleAction;

  /// No description provided for @listingPreview.
  ///
  /// In en, this message translates to:
  /// **'Listing preview'**
  String get listingPreview;

  /// No description provided for @listingUpdated.
  ///
  /// In en, this message translates to:
  /// **'Listing updated.'**
  String get listingUpdated;

  /// No description provided for @addUpTo20Photos.
  ///
  /// In en, this message translates to:
  /// **'Add up to 20 photos. '**
  String get addUpTo20Photos;

  /// No description provided for @seePhotoTips.
  ///
  /// In en, this message translates to:
  /// **'See photo tips.'**
  String get seePhotoTips;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @titleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. White COS Jumper'**
  String get titleHint;

  /// No description provided for @describeYourItem.
  ///
  /// In en, this message translates to:
  /// **'Describe your item'**
  String get describeYourItem;

  /// No description provided for @describeItemHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. small grey Nike t-shirt, only worn a few times'**
  String get describeItemHint;

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size;

  /// No description provided for @stockQuantity.
  ///
  /// In en, this message translates to:
  /// **'Stock quantity'**
  String get stockQuantity;

  /// No description provided for @priceGnf.
  ///
  /// In en, this message translates to:
  /// **'Price (GNF)'**
  String get priceGnf;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @publishListing.
  ///
  /// In en, this message translates to:
  /// **'Publish listing'**
  String get publishListing;

  /// No description provided for @uploadPhotos.
  ///
  /// In en, this message translates to:
  /// **'Upload photos'**
  String get uploadPhotos;

  /// No description provided for @vintedSizesInfoPrefix.
  ///
  /// In en, this message translates to:
  /// **'Vinted uses International / UK sizes as defaults. '**
  String get vintedSizesInfoPrefix;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @homeSellerPillIndividuals.
  ///
  /// In en, this message translates to:
  /// **'Individuals'**
  String get homeSellerPillIndividuals;

  /// No description provided for @homeSellerPillShops.
  ///
  /// In en, this message translates to:
  /// **'Shops'**
  String get homeSellerPillShops;

  /// No description provided for @homeSellerPillEnseignes.
  ///
  /// In en, this message translates to:
  /// **'Partner stores'**
  String get homeSellerPillEnseignes;

  /// No description provided for @findABrand.
  ///
  /// In en, this message translates to:
  /// **'Find a brand'**
  String get findABrand;

  /// No description provided for @noBrandUnbranded.
  ///
  /// In en, this message translates to:
  /// **'No brand / Unbranded'**
  String get noBrandUnbranded;

  /// No description provided for @noBrandValue.
  ///
  /// In en, this message translates to:
  /// **'No brand'**
  String get noBrandValue;

  /// No description provided for @useCustomBrand.
  ///
  /// In en, this message translates to:
  /// **'Use custom brand'**
  String get useCustomBrand;

  /// No description provided for @suggestedBrands.
  ///
  /// In en, this message translates to:
  /// **'Suggested brands'**
  String get suggestedBrands;

  /// No description provided for @chooseUpTo2Colours.
  ///
  /// In en, this message translates to:
  /// **'Choose up to 2 colours'**
  String get chooseUpTo2Colours;

  /// No description provided for @customColour.
  ///
  /// In en, this message translates to:
  /// **'Custom colour'**
  String get customColour;

  /// No description provided for @addCustomColour.
  ///
  /// In en, this message translates to:
  /// **'Add custom colour'**
  String get addCustomColour;

  /// No description provided for @customColourHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Mint, Wine, Nude'**
  String get customColourHint;

  /// No description provided for @mensClothingSizeGuide.
  ///
  /// In en, this message translates to:
  /// **'Men\'s clothing size guide'**
  String get mensClothingSizeGuide;

  /// No description provided for @sizeGuideDescription.
  ///
  /// In en, this message translates to:
  /// **'These measurements don\'t necessarily fit all brands, but you can still use them for reference. For precise measurements, please see an individual item\'s description.'**
  String get sizeGuideDescription;

  /// No description provided for @homeNav.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeNav;

  /// No description provided for @favoritesNav.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesNav;

  /// No description provided for @browseNav.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get browseNav;

  /// No description provided for @browseSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search items or members'**
  String get browseSearchHint;

  /// No description provided for @browseHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Find your next favorite'**
  String get browseHeroTitle;

  /// No description provided for @browseHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Swipe into Conakry\'s best closets, shops and finds.'**
  String get browseHeroSubtitle;

  /// No description provided for @browseCategoriesHeading.
  ///
  /// In en, this message translates to:
  /// **'CATEGORIES'**
  String get browseCategoriesHeading;

  /// No description provided for @browseFeaturedHint.
  ///
  /// In en, this message translates to:
  /// **'Fashion, street & everyday looks'**
  String get browseFeaturedHint;

  /// No description provided for @browseCategoryWomen.
  ///
  /// In en, this message translates to:
  /// **'Women'**
  String get browseCategoryWomen;

  /// No description provided for @browseCategoryMen.
  ///
  /// In en, this message translates to:
  /// **'Men'**
  String get browseCategoryMen;

  /// No description provided for @browseCategoryPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium picks'**
  String get browseCategoryPremium;

  /// No description provided for @browseCategoryKids.
  ///
  /// In en, this message translates to:
  /// **'Kids & family'**
  String get browseCategoryKids;

  /// No description provided for @browseCategoryHome.
  ///
  /// In en, this message translates to:
  /// **'Home & décor'**
  String get browseCategoryHome;

  /// No description provided for @browseCategoryTech.
  ///
  /// In en, this message translates to:
  /// **'Tech & gadgets'**
  String get browseCategoryTech;

  /// No description provided for @browseCategoryBooks.
  ///
  /// In en, this message translates to:
  /// **'Books & media'**
  String get browseCategoryBooks;

  /// No description provided for @browseCategoryHobbies.
  ///
  /// In en, this message translates to:
  /// **'Hobbies & crafts'**
  String get browseCategoryHobbies;

  /// No description provided for @browseCategorySports.
  ///
  /// In en, this message translates to:
  /// **'Sports & outdoors'**
  String get browseCategorySports;

  /// No description provided for @browseCategoryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get browseCategoryEmptyTitle;

  /// No description provided for @browseCategoryEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check back soon or explore other categories.'**
  String get browseCategoryEmptySubtitle;

  /// No description provided for @sellNav.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get sellNav;

  /// No description provided for @messagesNav.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messagesNav;

  /// No description provided for @profileNav.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileNav;

  /// No description provided for @popularItemsTitle.
  ///
  /// In en, this message translates to:
  /// **'Popular items'**
  String get popularItemsTitle;

  /// No description provided for @popularItemsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Most loved items right now'**
  String get popularItemsSubtitle;

  /// No description provided for @newArrivalsTitle.
  ///
  /// In en, this message translates to:
  /// **'New arrivals'**
  String get newArrivalsTitle;

  /// No description provided for @newArrivalsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Latest items added on FripCash'**
  String get newArrivalsSubtitle;

  /// No description provided for @popularShopsTitle.
  ///
  /// In en, this message translates to:
  /// **'Popular shops'**
  String get popularShopsTitle;

  /// No description provided for @popularShopsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Trusted professional sellers'**
  String get popularShopsSubtitle;

  /// No description provided for @showcaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Showcase'**
  String get showcaseTitle;

  /// No description provided for @seeMore.
  ///
  /// In en, this message translates to:
  /// **'See more'**
  String get seeMore;

  /// No description provided for @follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// No description provided for @following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get following;

  /// No description provided for @filterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filterTitle;

  /// No description provided for @filterSort.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get filterSort;

  /// No description provided for @filterSellerType.
  ///
  /// In en, this message translates to:
  /// **'Seller type'**
  String get filterSellerType;

  /// No description provided for @filterCondition.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get filterCondition;

  /// No description provided for @filterPriceRange.
  ///
  /// In en, this message translates to:
  /// **'Price range'**
  String get filterPriceRange;

  /// No description provided for @filterPriceRangeValue.
  ///
  /// In en, this message translates to:
  /// **'{min} - {max} GNF'**
  String filterPriceRangeValue(String min, String max);

  /// No description provided for @filterInStockOnly.
  ///
  /// In en, this message translates to:
  /// **'In stock only'**
  String get filterInStockOnly;

  /// No description provided for @filterApply.
  ///
  /// In en, this message translates to:
  /// **'Apply filters'**
  String get filterApply;

  /// No description provided for @filterReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get filterReset;

  /// No description provided for @sortRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get sortRecommended;

  /// No description provided for @sortPriceLow.
  ///
  /// In en, this message translates to:
  /// **'Price: low to high'**
  String get sortPriceLow;

  /// No description provided for @sortPriceHigh.
  ///
  /// In en, this message translates to:
  /// **'Price: high to low'**
  String get sortPriceHigh;

  /// No description provided for @sortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get sortNewest;

  /// No description provided for @sellerNotFound.
  ///
  /// In en, this message translates to:
  /// **'Seller not found'**
  String get sellerNotFound;

  /// No description provided for @reviewsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} reviews'**
  String reviewsCount(int count);

  /// No description provided for @listingsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String listingsCount(int count);

  /// No description provided for @partnerBrandsTitle.
  ///
  /// In en, this message translates to:
  /// **'Partner brands'**
  String get partnerBrandsTitle;

  /// No description provided for @partnerBrandsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Top brands - express delivery'**
  String get partnerBrandsSubtitle;

  /// No description provided for @enseignesTitle.
  ///
  /// In en, this message translates to:
  /// **'Partner stores'**
  String get enseignesTitle;

  /// No description provided for @enseignesDeliveryTo.
  ///
  /// In en, this message translates to:
  /// **'DELIVER TO'**
  String get enseignesDeliveryTo;

  /// No description provided for @enseignesDeliverHereCount.
  ///
  /// In en, this message translates to:
  /// **'{count} stores deliver here'**
  String enseignesDeliverHereCount(int count);

  /// No description provided for @enseignesChangeLocation.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get enseignesChangeLocation;

  /// No description provided for @enseignesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} stores'**
  String enseignesCount(int count);

  /// No description provided for @enseignesSortDeliveryAsc.
  ///
  /// In en, this message translates to:
  /// **'Fastest delivery'**
  String get enseignesSortDeliveryAsc;

  /// No description provided for @enseignesDeliveredIn.
  ///
  /// In en, this message translates to:
  /// **'Delivered in {hours} h'**
  String enseignesDeliveredIn(int hours);

  /// No description provided for @enseignesTwoFiltersTitle.
  ///
  /// In en, this message translates to:
  /// **'Two filters, not one'**
  String get enseignesTwoFiltersTitle;

  /// No description provided for @enseignesTwoFiltersBody.
  ///
  /// In en, this message translates to:
  /// **'Sub-category (what they sell) and delivery zone (whether they come to you). Both are set when the store registers.'**
  String get enseignesTwoFiltersBody;

  /// No description provided for @enseignesEmptyForZone.
  ///
  /// In en, this message translates to:
  /// **'No partner stores deliver to this area yet. Try another neighborhood.'**
  String get enseignesEmptyForZone;

  /// No description provided for @enseigneCategoryGrocery.
  ///
  /// In en, this message translates to:
  /// **'Grocery'**
  String get enseigneCategoryGrocery;

  /// No description provided for @enseigneCategoryAppliances.
  ///
  /// In en, this message translates to:
  /// **'Appliances'**
  String get enseigneCategoryAppliances;

  /// No description provided for @enseigneCategoryLighting.
  ///
  /// In en, this message translates to:
  /// **'Lighting'**
  String get enseigneCategoryLighting;

  /// No description provided for @enseigneCategoryHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get enseigneCategoryHome;

  /// No description provided for @enseigneCategoryMode.
  ///
  /// In en, this message translates to:
  /// **'Fashion'**
  String get enseigneCategoryMode;

  /// No description provided for @quartierBoutiquesTitle.
  ///
  /// In en, this message translates to:
  /// **'Neighborhood shops'**
  String get quartierBoutiquesTitle;

  /// No description provided for @quartierBoutiquesYourNeighborhood.
  ///
  /// In en, this message translates to:
  /// **'YOUR NEIGHBORHOOD'**
  String get quartierBoutiquesYourNeighborhood;

  /// No description provided for @quartierBoutiquesChangeNeighborhood.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get quartierBoutiquesChangeNeighborhood;

  /// No description provided for @quartierBoutiquesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} shops in {quartier}'**
  String quartierBoutiquesCount(int count, String quartier);

  /// No description provided for @quartierBoutiquesSortNearest.
  ///
  /// In en, this message translates to:
  /// **'Nearest first'**
  String get quartierBoutiquesSortNearest;

  /// No description provided for @quartierBoutiquesProductCount.
  ///
  /// In en, this message translates to:
  /// **'{count} products'**
  String quartierBoutiquesProductCount(int count);

  /// No description provided for @quartierBoutiquesWalkTime.
  ///
  /// In en, this message translates to:
  /// **'{street} · {minutes} min'**
  String quartierBoutiquesWalkTime(String street, int minutes);

  /// No description provided for @quartierBoutiquesPickupByCode.
  ///
  /// In en, this message translates to:
  /// **'Pickup by code'**
  String get quartierBoutiquesPickupByCode;

  /// No description provided for @quartierBoutiquesOpensAt.
  ///
  /// In en, this message translates to:
  /// **'Opens at {hour} h'**
  String quartierBoutiquesOpensAt(int hour);

  /// No description provided for @quartierBoutiquesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No neighborhood shops in this area yet. Try another neighborhood.'**
  String get quartierBoutiquesEmpty;

  /// No description provided for @quartierBoutiquesReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Your shop isn\'t listed?'**
  String get quartierBoutiquesReportTitle;

  /// No description provided for @quartierBoutiquesReportBody.
  ///
  /// In en, this message translates to:
  /// **'Report it — the FripCash team will list it within 48 hours.'**
  String get quartierBoutiquesReportBody;

  /// No description provided for @quartierBoutiquesReportAck.
  ///
  /// In en, this message translates to:
  /// **'Thanks! We\'ll review your report within 48 hours.'**
  String get quartierBoutiquesReportAck;

  /// No description provided for @articlesNeufsTitle.
  ///
  /// In en, this message translates to:
  /// **'New items'**
  String get articlesNeufsTitle;

  /// No description provided for @articlesNeufsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{shopCount} shops · {articleCount} new items'**
  String articlesNeufsSubtitle(int shopCount, int articleCount);

  /// No description provided for @articlesNeufsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Shop, brand, item...'**
  String get articlesNeufsSearchHint;

  /// No description provided for @articlesNeufsShopCount.
  ///
  /// In en, this message translates to:
  /// **'{count} shops for {gender}'**
  String articlesNeufsShopCount(int count, String gender);

  /// No description provided for @articlesNeufsSortBestRated.
  ///
  /// In en, this message translates to:
  /// **'Best rated'**
  String get articlesNeufsSortBestRated;

  /// No description provided for @articlesNeufsArticleCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String articlesNeufsArticleCount(int count);

  /// No description provided for @articlesNeufsDeliveredIn.
  ///
  /// In en, this message translates to:
  /// **'Delivered in {sla}'**
  String articlesNeufsDeliveredIn(String sla);

  /// No description provided for @articlesNeufsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No shops match your search.'**
  String get articlesNeufsEmpty;

  /// No description provided for @articlesNeufsInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Browse by shop, not by item'**
  String get articlesNeufsInfoTitle;

  /// No description provided for @articlesNeufsInfoBody.
  ///
  /// In en, this message translates to:
  /// **'Each merchant has a full storefront — enter the shop to see their entire new-in-stock catalog.'**
  String get articlesNeufsInfoBody;

  /// No description provided for @secondeMainTitle.
  ///
  /// In en, this message translates to:
  /// **'Second hand'**
  String get secondeMainTitle;

  /// No description provided for @secondeMainSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} items sold by individuals'**
  String secondeMainSubtitle(int count);

  /// No description provided for @secondeMainSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Dress, jeans, sneakers...'**
  String get secondeMainSearchHint;

  /// No description provided for @secondeMainCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items for {gender}'**
  String secondeMainCount(int count, String gender);

  /// No description provided for @catalogShopSortMostProducts.
  ///
  /// In en, this message translates to:
  /// **'Most items'**
  String get catalogShopSortMostProducts;

  /// No description provided for @catalogShopSortNameAz.
  ///
  /// In en, this message translates to:
  /// **'Name A-Z'**
  String get catalogShopSortNameAz;

  /// No description provided for @secondeMainSortRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get secondeMainSortRecent;

  /// No description provided for @secondeMainEmpty.
  ///
  /// In en, this message translates to:
  /// **'No listings match your search.'**
  String get secondeMainEmpty;

  /// No description provided for @secondeMainIndividualBadge.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get secondeMainIndividualBadge;

  /// No description provided for @secondeMainInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'One filter level visible'**
  String get secondeMainInfoTitle;

  /// No description provided for @secondeMainInfoBody.
  ///
  /// In en, this message translates to:
  /// **'Main categories (Women / Men / Kids) stay up front — the rest lives in the menus below.'**
  String get secondeMainInfoBody;

  /// No description provided for @catalogGenderFemme.
  ///
  /// In en, this message translates to:
  /// **'Women'**
  String get catalogGenderFemme;

  /// No description provided for @catalogGenderHomme.
  ///
  /// In en, this message translates to:
  /// **'Men'**
  String get catalogGenderHomme;

  /// No description provided for @catalogGenderEnfant.
  ///
  /// In en, this message translates to:
  /// **'Kids'**
  String get catalogGenderEnfant;

  /// No description provided for @homeFooterTagline.
  ///
  /// In en, this message translates to:
  /// **'FripCash - Your trusted platform for buying and selling.'**
  String get homeFooterTagline;

  /// No description provided for @whatAreYouLookingFor.
  ///
  /// In en, this message translates to:
  /// **'What are you looking for?'**
  String get whatAreYouLookingFor;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results match your search'**
  String get searchNoResults;

  /// No description provided for @searchResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Search results'**
  String get searchResultsTitle;

  /// No description provided for @searchResultsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} result(s)'**
  String searchResultsCount(int count);

  /// No description provided for @oneSize.
  ///
  /// In en, this message translates to:
  /// **'One size'**
  String get oneSize;

  /// No description provided for @includedSuffix.
  ///
  /// In en, this message translates to:
  /// **'incl.'**
  String get includedSuffix;

  /// No description provided for @noFavoritesYet.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavoritesYet;

  /// No description provided for @noFavoritesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save items you like to find them here.'**
  String get noFavoritesSubtitle;

  /// No description provided for @discoverItemsAction.
  ///
  /// In en, this message translates to:
  /// **'Discover items'**
  String get discoverItemsAction;

  /// No description provided for @supportFripCash.
  ///
  /// In en, this message translates to:
  /// **'FripCash Support'**
  String get supportFripCash;

  /// No description provided for @sellers.
  ///
  /// In en, this message translates to:
  /// **'Sellers'**
  String get sellers;

  /// No description provided for @noSupportMessages.
  ///
  /// In en, this message translates to:
  /// **'No support messages'**
  String get noSupportMessages;

  /// No description provided for @noSupportMessagesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Contact the FripCash team for any question.'**
  String get noSupportMessagesSubtitle;

  /// No description provided for @noMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages'**
  String get noMessages;

  /// No description provided for @noMessagesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your conversations with sellers will appear here.'**
  String get noMessagesSubtitle;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @courierRole.
  ///
  /// In en, this message translates to:
  /// **'Courier'**
  String get courierRole;

  /// No description provided for @adminRole.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get adminRole;

  /// No description provided for @badges.
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get badges;

  /// No description provided for @myWallet.
  ///
  /// In en, this message translates to:
  /// **'My wallet'**
  String get myWallet;

  /// No description provided for @mySalesAndPurchases.
  ///
  /// In en, this message translates to:
  /// **'My sales and purchases'**
  String get mySalesAndPurchases;

  /// No description provided for @myOffers.
  ///
  /// In en, this message translates to:
  /// **'My offers'**
  String get myOffers;

  /// No description provided for @customization.
  ///
  /// In en, this message translates to:
  /// **'Customization'**
  String get customization;

  /// No description provided for @bundleDiscount.
  ///
  /// In en, this message translates to:
  /// **'Bundle discount'**
  String get bundleDiscount;

  /// No description provided for @vacationMode.
  ///
  /// In en, this message translates to:
  /// **'Vacation mode'**
  String get vacationMode;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @viewMyProfile.
  ///
  /// In en, this message translates to:
  /// **'View my profile'**
  String get viewMyProfile;

  /// No description provided for @sellYourItems.
  ///
  /// In en, this message translates to:
  /// **'Sell your items'**
  String get sellYourItems;

  /// No description provided for @sellPromoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set your price — commission is added for buyers (8%, or 5% for neighborhood shops). You keep your full price.'**
  String get sellPromoSubtitle;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add an item'**
  String get addItem;

  /// No description provided for @editMyProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit my profile'**
  String get editMyProfile;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get pushNotifications;

  /// No description provided for @ordersMessagesOffers.
  ///
  /// In en, this message translates to:
  /// **'Orders, messages and offers'**
  String get ordersMessagesOffers;

  /// No description provided for @sellerMode.
  ///
  /// In en, this message translates to:
  /// **'Seller mode'**
  String get sellerMode;

  /// No description provided for @sellerModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try seller dashboard without changing account'**
  String get sellerModeSubtitle;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated.'**
  String get profileUpdated;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @nameOrUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name or username'**
  String get nameOrUsernameHint;

  /// No description provided for @phoneCannotBeEditedHere.
  ///
  /// In en, this message translates to:
  /// **'Phone number cannot be edited here.'**
  String get phoneCannotBeEditedHere;

  /// No description provided for @chooseZone.
  ///
  /// In en, this message translates to:
  /// **'Choose a zone'**
  String get chooseZone;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @addressHintShort.
  ///
  /// In en, this message translates to:
  /// **'Neighborhood, landmark...'**
  String get addressHintShort;

  /// No description provided for @passwordUpdatedSimulation.
  ///
  /// In en, this message translates to:
  /// **'Password updated (simulation).'**
  String get passwordUpdatedSimulation;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @confirmPasswordShort.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordShort;

  /// No description provided for @myPublicProfile.
  ///
  /// In en, this message translates to:
  /// **'My public profile'**
  String get myPublicProfile;

  /// No description provided for @profileRatingSummary.
  ///
  /// In en, this message translates to:
  /// **'4.8 · 24 reviews'**
  String get profileRatingSummary;

  /// No description provided for @listings.
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get listings;

  /// No description provided for @noPublicListings.
  ///
  /// In en, this message translates to:
  /// **'No public listings.'**
  String get noPublicListings;

  /// No description provided for @vacationModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Temporarily hide your listings. Buyers will not be able to place orders during this period.'**
  String get vacationModeDescription;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get endDate;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @vacationModeUpdated.
  ///
  /// In en, this message translates to:
  /// **'Vacation mode updated.'**
  String get vacationModeUpdated;

  /// No description provided for @hideListingsOnVacation.
  ///
  /// In en, this message translates to:
  /// **'Hide published listings'**
  String get hideListingsOnVacation;

  /// No description provided for @bundleDiscountDescription.
  ///
  /// In en, this message translates to:
  /// **'Offer an automatic discount when a buyer purchases multiple items from your shop.'**
  String get bundleDiscountDescription;

  /// No description provided for @bundleDiscountSimulatedRule.
  ///
  /// In en, this message translates to:
  /// **'Discount: -10% from 2 items from the same seller.'**
  String get bundleDiscountSimulatedRule;

  /// No description provided for @bundleMinItemsLabel.
  ///
  /// In en, this message translates to:
  /// **'Minimum items'**
  String get bundleMinItemsLabel;

  /// No description provided for @bundleMinItemsHelper.
  ///
  /// In en, this message translates to:
  /// **'Buyer must take at least this many items from your shop (2–20).'**
  String get bundleMinItemsHelper;

  /// No description provided for @bundleMinItemsInvalid.
  ///
  /// In en, this message translates to:
  /// **'Minimum items must be between 2 and 20.'**
  String get bundleMinItemsInvalid;

  /// No description provided for @bundlePercentLabel.
  ///
  /// In en, this message translates to:
  /// **'Discount %'**
  String get bundlePercentLabel;

  /// No description provided for @bundlePercentHelper.
  ///
  /// In en, this message translates to:
  /// **'Percent off those items at checkout (1–50).'**
  String get bundlePercentHelper;

  /// No description provided for @bundlePercentInvalid.
  ///
  /// In en, this message translates to:
  /// **'Discount must be between 1% and 50%.'**
  String get bundlePercentInvalid;

  /// No description provided for @bundleRulePreview.
  ///
  /// In en, this message translates to:
  /// **'-{percent}% from {minItems} items from your shop.'**
  String bundleRulePreview(int percent, int minItems);

  /// No description provided for @bundleRuleSavedLocal.
  ///
  /// In en, this message translates to:
  /// **'Bundle rule saved.'**
  String get bundleRuleSavedLocal;

  /// No description provided for @badgeFirstSaleTitle.
  ///
  /// In en, this message translates to:
  /// **'First sale'**
  String get badgeFirstSaleTitle;

  /// No description provided for @badgeFirstSaleDescription.
  ///
  /// In en, this message translates to:
  /// **'You sold your first item on FripCash.'**
  String get badgeFirstSaleDescription;

  /// No description provided for @badgeFastShipperTitle.
  ///
  /// In en, this message translates to:
  /// **'Fast shipping'**
  String get badgeFastShipperTitle;

  /// No description provided for @badgeFastShipperDescription.
  ///
  /// In en, this message translates to:
  /// **'5 parcels prepared in less than 24h.'**
  String get badgeFastShipperDescription;

  /// No description provided for @badgeTopRatedTitle.
  ///
  /// In en, this message translates to:
  /// **'5-star seller'**
  String get badgeTopRatedTitle;

  /// No description provided for @badgeTopRatedDescription.
  ///
  /// In en, this message translates to:
  /// **'10 reviews with an average rating of 5/5.'**
  String get badgeTopRatedDescription;

  /// No description provided for @badgeEcoSellerTitle.
  ///
  /// In en, this message translates to:
  /// **'Eco-friendly'**
  String get badgeEcoSellerTitle;

  /// No description provided for @badgeEcoSellerDescription.
  ///
  /// In en, this message translates to:
  /// **'20 second-hand items sold.'**
  String get badgeEcoSellerDescription;

  /// No description provided for @purchasesTab.
  ///
  /// In en, this message translates to:
  /// **'Purchases'**
  String get purchasesTab;

  /// No description provided for @salesTab.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get salesTab;

  /// No description provided for @noPurchases.
  ///
  /// In en, this message translates to:
  /// **'No purchases'**
  String get noPurchases;

  /// No description provided for @noSales.
  ///
  /// In en, this message translates to:
  /// **'No sales'**
  String get noSales;

  /// No description provided for @orderLabel.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get orderLabel;

  /// No description provided for @deliverWithin.
  ///
  /// In en, this message translates to:
  /// **'Deliver within'**
  String get deliverWithin;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'overdue'**
  String get overdue;

  /// No description provided for @orderStatusUpdated.
  ///
  /// In en, this message translates to:
  /// **'Order status updated'**
  String get orderStatusUpdated;

  /// No description provided for @ratingSavedThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you, your review has been saved.'**
  String get ratingSavedThanks;

  /// No description provided for @orderNotFound.
  ///
  /// In en, this message translates to:
  /// **'Order not found'**
  String get orderNotFound;

  /// No description provided for @stepLabel.
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get stepLabel;

  /// No description provided for @orderTracking.
  ///
  /// In en, this message translates to:
  /// **'Order tracking'**
  String get orderTracking;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @sellerRoleGeneric.
  ///
  /// In en, this message translates to:
  /// **'Seller'**
  String get sellerRoleGeneric;

  /// No description provided for @deliveryZone.
  ///
  /// In en, this message translates to:
  /// **'Delivery zone'**
  String get deliveryZone;

  /// No description provided for @awaitingAssignment.
  ///
  /// In en, this message translates to:
  /// **'Awaiting assignment'**
  String get awaitingAssignment;

  /// No description provided for @parcelReady.
  ///
  /// In en, this message translates to:
  /// **'Parcel ready'**
  String get parcelReady;

  /// No description provided for @parcelDelivered.
  ///
  /// In en, this message translates to:
  /// **'Parcel delivered'**
  String get parcelDelivered;

  /// No description provided for @rateSeller.
  ///
  /// In en, this message translates to:
  /// **'Rate seller'**
  String get rateSeller;

  /// No description provided for @thanksForReview.
  ///
  /// In en, this message translates to:
  /// **'Thanks for your review!'**
  String get thanksForReview;

  /// No description provided for @experienceWithSellerQuestion.
  ///
  /// In en, this message translates to:
  /// **'How was your experience with'**
  String get experienceWithSellerQuestion;

  /// No description provided for @commentOptional.
  ///
  /// In en, this message translates to:
  /// **'Comment (optional)'**
  String get commentOptional;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit my review'**
  String get submitReview;

  /// No description provided for @deliveryAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'Delivery address'**
  String get deliveryAddressTitle;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get yourName;

  /// No description provided for @phoneNumberHint224.
  ///
  /// In en, this message translates to:
  /// **'+224 6XX XXX XXX'**
  String get phoneNumberHint224;

  /// No description provided for @neighborhood.
  ///
  /// In en, this message translates to:
  /// **'Neighborhood'**
  String get neighborhood;

  /// No description provided for @chooseNeighborhood.
  ///
  /// In en, this message translates to:
  /// **'Choose your neighborhood'**
  String get chooseNeighborhood;

  /// No description provided for @streetSectorCommune.
  ///
  /// In en, this message translates to:
  /// **'Street, sector, commune'**
  String get streetSectorCommune;

  /// No description provided for @landmark.
  ///
  /// In en, this message translates to:
  /// **'Landmark'**
  String get landmark;

  /// No description provided for @landmarkHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: near market, blue building'**
  String get landmarkHint;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @serviceFeesTitle.
  ///
  /// In en, this message translates to:
  /// **'Service fees (8%)'**
  String get serviceFeesTitle;

  /// No description provided for @serviceFeesDescription.
  ///
  /// In en, this message translates to:
  /// **'Displayed price already includes service fees: 1% for Orange Money and 7% for FripCash. No hidden fees at payment.'**
  String get serviceFeesDescription;

  /// No description provided for @summaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summaryTitle;

  /// No description provided for @buyerProtectionIncluded.
  ///
  /// In en, this message translates to:
  /// **'Buyer protection included for this purchase.'**
  String get buyerProtectionIncluded;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @deliveryFees.
  ///
  /// In en, this message translates to:
  /// **'Delivery fees'**
  String get deliveryFees;

  /// No description provided for @serviceFeesIncluded.
  ///
  /// In en, this message translates to:
  /// **'Service fees included'**
  String get serviceFeesIncluded;

  /// No description provided for @payWithOrangeMoney.
  ///
  /// In en, this message translates to:
  /// **'Pay with Orange Money'**
  String get payWithOrangeMoney;

  /// No description provided for @qtyShort.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get qtyShort;

  /// No description provided for @orderConfirmedTitle.
  ///
  /// In en, this message translates to:
  /// **'Order confirmed!'**
  String get orderConfirmedTitle;

  /// No description provided for @orderConfirmedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Order confirmed. Stay reachable, the courier will contact you.'**
  String get orderConfirmedSubtitle;

  /// No description provided for @estimatedDelivery24to48h.
  ///
  /// In en, this message translates to:
  /// **'Estimated delivery within 24-48h'**
  String get estimatedDelivery24to48h;

  /// No description provided for @orderTrackingSoon.
  ///
  /// In en, this message translates to:
  /// **'Order tracking available soon.'**
  String get orderTrackingSoon;

  /// No description provided for @trackMyOrder.
  ///
  /// In en, this message translates to:
  /// **'Track my order'**
  String get trackMyOrder;

  /// No description provided for @withdrawToOrangeMoney.
  ///
  /// In en, this message translates to:
  /// **'Withdraw to Orange Money'**
  String get withdrawToOrangeMoney;

  /// No description provided for @confirmWithdrawalPrefix.
  ///
  /// In en, this message translates to:
  /// **'Confirm withdrawal of'**
  String get confirmWithdrawalPrefix;

  /// No description provided for @confirmWithdrawalSuffix.
  ///
  /// In en, this message translates to:
  /// **'to your Orange Money account?'**
  String get confirmWithdrawalSuffix;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @withdrawalInitiatedSimulation.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal initiated (simulation).'**
  String get withdrawalInitiatedSimulation;

  /// No description provided for @availableBalance.
  ///
  /// In en, this message translates to:
  /// **'Available balance'**
  String get availableBalance;

  /// No description provided for @walletEscrowInfo.
  ///
  /// In en, this message translates to:
  /// **'Sales funds remain locked until the \"Parcel delivered\" step. They are then released to your wallet.'**
  String get walletEscrowInfo;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsYet;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllRead;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @missingAddressRestartOrder.
  ///
  /// In en, this message translates to:
  /// **'Missing address. Please restart checkout.'**
  String get missingAddressRestartOrder;

  /// No description provided for @paymentCancelled.
  ///
  /// In en, this message translates to:
  /// **'Payment cancelled.'**
  String get paymentCancelled;

  /// No description provided for @orangeMoney.
  ///
  /// In en, this message translates to:
  /// **'Orange Money'**
  String get orangeMoney;

  /// No description provided for @securePayment.
  ///
  /// In en, this message translates to:
  /// **'Secure payment'**
  String get securePayment;

  /// No description provided for @orangeMoneyNumber.
  ///
  /// In en, this message translates to:
  /// **'Orange Money number'**
  String get orangeMoneyNumber;

  /// No description provided for @paymentConfirmationPrompt.
  ///
  /// In en, this message translates to:
  /// **'You will receive a confirmation request on your phone.'**
  String get paymentConfirmationPrompt;

  /// No description provided for @confirmPayment.
  ///
  /// In en, this message translates to:
  /// **'Confirm payment'**
  String get confirmPayment;

  /// No description provided for @shopOnboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Present your shop to buyers across Guinea.'**
  String get shopOnboardingSubtitle;

  /// No description provided for @shopNameExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. Mode Plus GN'**
  String get shopNameExample;

  /// No description provided for @shopDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Your specialty, your commitments...'**
  String get shopDescriptionHint;

  /// No description provided for @preparationDelay.
  ///
  /// In en, this message translates to:
  /// **'Preparation delay'**
  String get preparationDelay;

  /// No description provided for @sellerDeliverySla.
  ///
  /// In en, this message translates to:
  /// **'Seller delivery SLA'**
  String get sellerDeliverySla;

  /// No description provided for @createMyShop.
  ///
  /// In en, this message translates to:
  /// **'Create my shop'**
  String get createMyShop;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @myShop.
  ///
  /// In en, this message translates to:
  /// **'My shop'**
  String get myShop;

  /// No description provided for @salesToday.
  ///
  /// In en, this message translates to:
  /// **'Today\'s sales'**
  String get salesToday;

  /// No description provided for @offersToHandle.
  ///
  /// In en, this message translates to:
  /// **'Offers to handle'**
  String get offersToHandle;

  /// No description provided for @shopVisits.
  ///
  /// In en, this message translates to:
  /// **'Shop visits'**
  String get shopVisits;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get quickActions;

  /// No description provided for @newListing.
  ///
  /// In en, this message translates to:
  /// **'New listing'**
  String get newListing;

  /// No description provided for @viewOrders.
  ///
  /// In en, this message translates to:
  /// **'View orders'**
  String get viewOrders;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'pending'**
  String get pending;

  /// No description provided for @toHandle.
  ///
  /// In en, this message translates to:
  /// **'To handle'**
  String get toHandle;

  /// No description provided for @lastImport.
  ///
  /// In en, this message translates to:
  /// **'Last import'**
  String get lastImport;

  /// No description provided for @noRecentImport.
  ///
  /// In en, this message translates to:
  /// **'No recent import'**
  String get noRecentImport;

  /// No description provided for @itemsLowStockAlert.
  ///
  /// In en, this message translates to:
  /// **'item(s) low stock alert'**
  String get itemsLowStockAlert;

  /// No description provided for @adjust.
  ///
  /// In en, this message translates to:
  /// **'Adjust'**
  String get adjust;

  /// No description provided for @salesHistory.
  ///
  /// In en, this message translates to:
  /// **'Sales history'**
  String get salesHistory;

  /// No description provided for @noDeliveredSalesYet.
  ///
  /// In en, this message translates to:
  /// **'No delivered sales yet.'**
  String get noDeliveredSalesYet;

  /// No description provided for @sellerDemoModeBanner.
  ///
  /// In en, this message translates to:
  /// **'Seller mode (demo) - sample data'**
  String get sellerDemoModeBanner;

  /// No description provided for @clientPrice.
  ///
  /// In en, this message translates to:
  /// **'Client price'**
  String get clientPrice;

  /// No description provided for @yourNetPrice.
  ///
  /// In en, this message translates to:
  /// **'Your net price'**
  String get yourNetPrice;

  /// No description provided for @fripCashCommission.
  ///
  /// In en, this message translates to:
  /// **'FripCash commission'**
  String get fripCashCommission;

  /// No description provided for @sellerOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'Seller orders'**
  String get sellerOrdersTitle;

  /// No description provided for @noOrdersInCategory.
  ///
  /// In en, this message translates to:
  /// **'No orders in this category'**
  String get noOrdersInCategory;

  /// No description provided for @clientLabel.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get clientLabel;

  /// No description provided for @parcelMarkedReady.
  ///
  /// In en, this message translates to:
  /// **'Parcel marked as ready'**
  String get parcelMarkedReady;

  /// No description provided for @receivedOffers.
  ///
  /// In en, this message translates to:
  /// **'Received offers'**
  String get receivedOffers;

  /// No description provided for @accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// No description provided for @noPendingOffers.
  ///
  /// In en, this message translates to:
  /// **'No pending offers'**
  String get noPendingOffers;

  /// No description provided for @noAcceptedOffers.
  ///
  /// In en, this message translates to:
  /// **'No accepted offers'**
  String get noAcceptedOffers;

  /// No description provided for @offerLabel.
  ///
  /// In en, this message translates to:
  /// **'Offer'**
  String get offerLabel;

  /// No description provided for @offerRefused.
  ///
  /// In en, this message translates to:
  /// **'Offer refused'**
  String get offerRefused;

  /// No description provided for @refuse.
  ///
  /// In en, this message translates to:
  /// **'Refuse'**
  String get refuse;

  /// No description provided for @offerAcceptedBuyerNotified.
  ///
  /// In en, this message translates to:
  /// **'Offer accepted - buyer notified'**
  String get offerAcceptedBuyerNotified;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @excelImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Excel import'**
  String get excelImportTitle;

  /// No description provided for @excelImportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Import your product catalog in .xlsx format to update stock and prices in bulk.'**
  String get excelImportSubtitle;

  /// No description provided for @excelImportAwaitingBackend.
  ///
  /// In en, this message translates to:
  /// **'Download the template, then import your .xlsx file.'**
  String get excelImportAwaitingBackend;

  /// No description provided for @excelImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Import done: {imported} created, {updated} updated, {failed} failed.'**
  String excelImportSuccess(int imported, int updated, int failed);

  /// No description provided for @excelTemplateSaved.
  ///
  /// In en, this message translates to:
  /// **'Template saved: {path}'**
  String excelTemplateSaved(String path);

  /// No description provided for @excelLastImport.
  ///
  /// In en, this message translates to:
  /// **'Last import: {label}'**
  String excelLastImport(String label);

  /// No description provided for @noFileSelected.
  ///
  /// In en, this message translates to:
  /// **'No file selected'**
  String get noFileSelected;

  /// No description provided for @templateDownloadedSimulation.
  ///
  /// In en, this message translates to:
  /// **'Template downloaded.'**
  String get templateDownloadedSimulation;

  /// No description provided for @downloadExcelTemplate.
  ///
  /// In en, this message translates to:
  /// **'Download Excel template'**
  String get downloadExcelTemplate;

  /// No description provided for @dragOrSelectFile.
  ///
  /// In en, this message translates to:
  /// **'Drag your file or select it'**
  String get dragOrSelectFile;

  /// No description provided for @importInProgress.
  ///
  /// In en, this message translates to:
  /// **'Import in progress...'**
  String get importInProgress;

  /// No description provided for @chooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose a file'**
  String get chooseFile;

  /// No description provided for @rowsUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Rows updated successfully.'**
  String get rowsUpdatedSuccess;

  /// No description provided for @previewSimulation.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get previewSimulation;

  /// No description provided for @noOffersYet.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t made any offer yet.'**
  String get noOffersYet;

  /// No description provided for @noOffersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find an item you like and tap Make an offer on the product page.'**
  String get noOffersSubtitle;

  /// No description provided for @priceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceLabel;

  /// No description provided for @helpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find a quick answer or contact our support team.'**
  String get helpSubtitle;

  /// No description provided for @faqTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequently asked questions'**
  String get faqTitle;

  /// No description provided for @contactUsTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get contactUsTitle;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get contactSupport;

  /// No description provided for @supportOpeningSoon.
  ///
  /// In en, this message translates to:
  /// **'Support opening soon.'**
  String get supportOpeningSoon;

  /// No description provided for @conversationNotFound.
  ///
  /// In en, this message translates to:
  /// **'Conversation not found'**
  String get conversationNotFound;

  /// No description provided for @messagingUnavailableForBrand.
  ///
  /// In en, this message translates to:
  /// **'Messaging is unavailable for this brand'**
  String get messagingUnavailableForBrand;

  /// No description provided for @askSupportQuestion.
  ///
  /// In en, this message translates to:
  /// **'Ask your question to FripCash support.'**
  String get askSupportQuestion;

  /// No description provided for @sendMessageToSeller.
  ///
  /// In en, this message translates to:
  /// **'Send a message to the seller.'**
  String get sendMessageToSeller;

  /// No description provided for @writeMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Write a message...'**
  String get writeMessageHint;

  /// No description provided for @courierSpaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Courier space'**
  String get courierSpaceTitle;

  /// No description provided for @courierLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Demo login - missions and FripCash deliveries'**
  String get courierLoginSubtitle;

  /// No description provided for @fripCashCourier.
  ///
  /// In en, this message translates to:
  /// **'FripCash Courier'**
  String get fripCashCourier;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @unavailableShort.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailableShort;

  /// No description provided for @courierUnavailableBanner.
  ///
  /// In en, this message translates to:
  /// **'You are unavailable - no new mission will be assigned to you.'**
  String get courierUnavailableBanner;

  /// No description provided for @missions.
  ///
  /// In en, this message translates to:
  /// **'Missions'**
  String get missions;

  /// No description provided for @earnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earnings;

  /// No description provided for @courierDeliveryHistory.
  ///
  /// In en, this message translates to:
  /// **'Delivery history'**
  String get courierDeliveryHistory;

  /// No description provided for @courierHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'All completed rides on your account.'**
  String get courierHistorySubtitle;

  /// No description provided for @courierTotalDeliveries.
  ///
  /// In en, this message translates to:
  /// **'Total deliveries'**
  String get courierTotalDeliveries;

  /// No description provided for @courierTotalEarned.
  ///
  /// In en, this message translates to:
  /// **'Total earned'**
  String get courierTotalEarned;

  /// No description provided for @noDeliveryHistoryYet.
  ///
  /// In en, this message translates to:
  /// **'No completed deliveries yet.'**
  String get noDeliveryHistoryYet;

  /// No description provided for @courierThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get courierThisWeek;

  /// No description provided for @courierPaidToWallet.
  ///
  /// In en, this message translates to:
  /// **'Paid to your FripCash wallet'**
  String get courierPaidToWallet;

  /// No description provided for @courierPayoutDetails.
  ///
  /// In en, this message translates to:
  /// **'Payout details'**
  String get courierPayoutDetails;

  /// No description provided for @fripCashWallet.
  ///
  /// In en, this message translates to:
  /// **'FripCash Wallet'**
  String get fripCashWallet;

  /// No description provided for @courierWeeklyGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Set a weekly earnings goal'**
  String get courierWeeklyGoalTitle;

  /// No description provided for @courierWeeklyGoalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stay motivated and track your progress each week.'**
  String get courierWeeklyGoalSubtitle;

  /// No description provided for @courierGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get courierGetStarted;

  /// No description provided for @courierEarningsHistory.
  ///
  /// In en, this message translates to:
  /// **'Earnings history'**
  String get courierEarningsHistory;

  /// No description provided for @courierViewAllHistory.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get courierViewAllHistory;

  /// No description provided for @courierWeekCurrent.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get courierWeekCurrent;

  /// No description provided for @courierWeekJun29Jul5.
  ///
  /// In en, this message translates to:
  /// **'Jun 29 - Jul 5'**
  String get courierWeekJun29Jul5;

  /// No description provided for @courierWeekJun8Jun14.
  ///
  /// In en, this message translates to:
  /// **'Jun 8 - Jun 14'**
  String get courierWeekJun8Jun14;

  /// No description provided for @courierWeekMay18May24.
  ///
  /// In en, this message translates to:
  /// **'May 18 - May 24'**
  String get courierWeekMay18May24;

  /// No description provided for @courierWeekApr27May3.
  ///
  /// In en, this message translates to:
  /// **'Apr 27 - May 3'**
  String get courierWeekApr27May3;

  /// No description provided for @courierWeekApr6Apr12.
  ///
  /// In en, this message translates to:
  /// **'Apr 6 - Apr 12'**
  String get courierWeekApr6Apr12;

  /// No description provided for @courierProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'My profile'**
  String get courierProfileTitle;

  /// No description provided for @courierPersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get courierPersonalInfo;

  /// No description provided for @courierVehicleInfo.
  ///
  /// In en, this message translates to:
  /// **'Vehicle information'**
  String get courierVehicleInfo;

  /// No description provided for @courierSubmittedDocuments.
  ///
  /// In en, this message translates to:
  /// **'Submitted documents'**
  String get courierSubmittedDocuments;

  /// No description provided for @courierDocumentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Documents you submitted during registration.'**
  String get courierDocumentsSubtitle;

  /// No description provided for @courierVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get courierVerified;

  /// No description provided for @courierIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Courier ID'**
  String get courierIdLabel;

  /// No description provided for @courierVehicleType.
  ///
  /// In en, this message translates to:
  /// **'Vehicle type'**
  String get courierVehicleType;

  /// No description provided for @courierVehicleMotorcycle.
  ///
  /// In en, this message translates to:
  /// **'Motorcycle'**
  String get courierVehicleMotorcycle;

  /// No description provided for @courierPlateNumber.
  ///
  /// In en, this message translates to:
  /// **'Plate number'**
  String get courierPlateNumber;

  /// No description provided for @courierMemberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since'**
  String get courierMemberSince;

  /// No description provided for @courierDocNationalId.
  ///
  /// In en, this message translates to:
  /// **'National ID'**
  String get courierDocNationalId;

  /// No description provided for @courierDocDriversLicense.
  ///
  /// In en, this message translates to:
  /// **'Driver\'s license'**
  String get courierDocDriversLicense;

  /// No description provided for @courierDocVehicleRegistration.
  ///
  /// In en, this message translates to:
  /// **'Vehicle registration'**
  String get courierDocVehicleRegistration;

  /// No description provided for @courierDocInsurance.
  ///
  /// In en, this message translates to:
  /// **'Insurance certificate'**
  String get courierDocInsurance;

  /// No description provided for @courierDocProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get courierDocProfilePhoto;

  /// No description provided for @courierDocStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get courierDocStatusApproved;

  /// No description provided for @courierDocStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending review'**
  String get courierDocStatusPending;

  /// No description provided for @courierDocStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get courierDocStatusRejected;

  /// No description provided for @courierSubmittedOn.
  ///
  /// In en, this message translates to:
  /// **'Submitted on {date}'**
  String courierSubmittedOn(String date);

  /// No description provided for @courierViewDocument.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get courierViewDocument;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get inProgress;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @courierFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get courierFilterAll;

  /// No description provided for @courierFilterActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get courierFilterActive;

  /// No description provided for @courierSearchMissionsHint.
  ///
  /// In en, this message translates to:
  /// **'Search mission'**
  String get courierSearchMissionsHint;

  /// No description provided for @courierDeliverTo.
  ///
  /// In en, this message translates to:
  /// **'Deliver to'**
  String get courierDeliverTo;

  /// No description provided for @courierPickupZone.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get courierPickupZone;

  /// No description provided for @courierDeliveryZone.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get courierDeliveryZone;

  /// No description provided for @courierDeliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Fee'**
  String get courierDeliveryFee;

  /// No description provided for @courierShippedBy.
  ///
  /// In en, this message translates to:
  /// **'Shipped by'**
  String get courierShippedBy;

  /// No description provided for @courierExpectedOn.
  ///
  /// In en, this message translates to:
  /// **'Expected on'**
  String get courierExpectedOn;

  /// No description provided for @courierStatusHeroCollect.
  ///
  /// In en, this message translates to:
  /// **'Collect the parcel from the seller'**
  String get courierStatusHeroCollect;

  /// No description provided for @courierStatusHeroDeliver.
  ///
  /// In en, this message translates to:
  /// **'Deliver the parcel to the buyer'**
  String get courierStatusHeroDeliver;

  /// No description provided for @courierStatusHeroDone.
  ///
  /// In en, this message translates to:
  /// **'This mission is complete'**
  String get courierStatusHeroDone;

  /// No description provided for @courierSenderDetails.
  ///
  /// In en, this message translates to:
  /// **'Sender details'**
  String get courierSenderDetails;

  /// No description provided for @courierRecipientDetails.
  ///
  /// In en, this message translates to:
  /// **'Recipient details'**
  String get courierRecipientDetails;

  /// No description provided for @courierPackageDetails.
  ///
  /// In en, this message translates to:
  /// **'Package details'**
  String get courierPackageDetails;

  /// No description provided for @courierMyMissions.
  ///
  /// In en, this message translates to:
  /// **'My missions'**
  String get courierMyMissions;

  /// No description provided for @courierWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get courierWelcomeBack;

  /// No description provided for @courierWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ready for today\'s deliveries'**
  String get courierWelcomeSubtitle;

  /// No description provided for @courierHelloName.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String courierHelloName(String name);

  /// No description provided for @courierBannerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ready for today\'s deliveries'**
  String get courierBannerSubtitle;

  /// No description provided for @courierTodayEarnings.
  ///
  /// In en, this message translates to:
  /// **'Today\'s earnings'**
  String get courierTodayEarnings;

  /// No description provided for @courierActiveCount.
  ///
  /// In en, this message translates to:
  /// **'{count} active'**
  String courierActiveCount(int count);

  /// No description provided for @courierQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get courierQuantity;

  /// No description provided for @courierDistanceLabel.
  ///
  /// In en, this message translates to:
  /// **'distance'**
  String get courierDistanceLabel;

  /// No description provided for @courierTimeLeftLabel.
  ///
  /// In en, this message translates to:
  /// **'Time left'**
  String get courierTimeLeftLabel;

  /// No description provided for @courierArrivalLabel.
  ///
  /// In en, this message translates to:
  /// **'Arrival'**
  String get courierArrivalLabel;

  /// No description provided for @courierDeliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery address'**
  String get courierDeliveryAddress;

  /// No description provided for @courierCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get courierCustomer;

  /// No description provided for @courierOrderCost.
  ///
  /// In en, this message translates to:
  /// **'Order cost'**
  String get courierOrderCost;

  /// No description provided for @courierCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get courierCreated;

  /// No description provided for @courierTypeOfOrder.
  ///
  /// In en, this message translates to:
  /// **'Type of order'**
  String get courierTypeOfOrder;

  /// No description provided for @courierPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get courierPaymentMethod;

  /// No description provided for @courierPaymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get courierPaymentStatus;

  /// No description provided for @courierTypeOwnTerms.
  ///
  /// In en, this message translates to:
  /// **'FripCash delivery'**
  String get courierTypeOwnTerms;

  /// No description provided for @courierPaymentPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get courierPaymentPaid;

  /// No description provided for @courierChatWithSupport.
  ///
  /// In en, this message translates to:
  /// **'Chat with support'**
  String get courierChatWithSupport;

  /// No description provided for @courierSlideToCollect.
  ///
  /// In en, this message translates to:
  /// **'Slide to confirm pickup'**
  String get courierSlideToCollect;

  /// No description provided for @courierSlideToDeliver.
  ///
  /// In en, this message translates to:
  /// **'Slide to confirm the delivery'**
  String get courierSlideToDeliver;

  /// No description provided for @courierMockDistance.
  ///
  /// In en, this message translates to:
  /// **'4.2 km'**
  String get courierMockDistance;

  /// No description provided for @courierMockTimeLeft.
  ///
  /// In en, this message translates to:
  /// **'18 min'**
  String get courierMockTimeLeft;

  /// No description provided for @courierMockArrival.
  ///
  /// In en, this message translates to:
  /// **'17:30'**
  String get courierMockArrival;

  /// No description provided for @courierMockWindow.
  ///
  /// In en, this message translates to:
  /// **'16:00 – 18:00'**
  String get courierMockWindow;

  /// No description provided for @noActiveMissions.
  ///
  /// In en, this message translates to:
  /// **'No active mission'**
  String get noActiveMissions;

  /// No description provided for @enableAvailabilityForMissions.
  ///
  /// In en, this message translates to:
  /// **'Enable availability to receive missions'**
  String get enableAvailabilityForMissions;

  /// No description provided for @noCompletedMissions.
  ///
  /// In en, this message translates to:
  /// **'No completed mission'**
  String get noCompletedMissions;

  /// No description provided for @newMission.
  ///
  /// In en, this message translates to:
  /// **'New mission'**
  String get newMission;

  /// No description provided for @pickup.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get pickup;

  /// No description provided for @delivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get delivery;

  /// No description provided for @callLabel.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get callLabel;

  /// No description provided for @demoLabel.
  ///
  /// In en, this message translates to:
  /// **'demo'**
  String get demoLabel;

  /// No description provided for @transferToAnotherCourier.
  ///
  /// In en, this message translates to:
  /// **'Transfer to another courier'**
  String get transferToAnotherCourier;

  /// No description provided for @availableCouriers.
  ///
  /// In en, this message translates to:
  /// **'Available couriers'**
  String get availableCouriers;

  /// No description provided for @missionTransferredTo.
  ///
  /// In en, this message translates to:
  /// **'Mission transferred to'**
  String get missionTransferredTo;

  /// No description provided for @noOtherCourierInZone.
  ///
  /// In en, this message translates to:
  /// **'No other courier in this zone.'**
  String get noOtherCourierInZone;

  /// No description provided for @missionNotFound.
  ///
  /// In en, this message translates to:
  /// **'Mission not found'**
  String get missionNotFound;

  /// No description provided for @deliveryConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Delivery confirmed'**
  String get deliveryConfirmed;

  /// No description provided for @callAction.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get callAction;

  /// No description provided for @earningsToday.
  ///
  /// In en, this message translates to:
  /// **'Today\'s earnings'**
  String get earningsToday;

  /// No description provided for @ridesToday.
  ///
  /// In en, this message translates to:
  /// **'ride(s) today'**
  String get ridesToday;

  /// No description provided for @todaysRides.
  ///
  /// In en, this message translates to:
  /// **'Today\'s rides'**
  String get todaysRides;

  /// No description provided for @noRideCompletedToday.
  ///
  /// In en, this message translates to:
  /// **'No ride completed today.'**
  String get noRideCompletedToday;

  /// No description provided for @toPrepare.
  ///
  /// In en, this message translates to:
  /// **'To prepare'**
  String get toPrepare;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ready;

  /// No description provided for @delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivered;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @otherZone.
  ///
  /// In en, this message translates to:
  /// **'Other zone'**
  String get otherZone;

  /// No description provided for @parcelCollected.
  ///
  /// In en, this message translates to:
  /// **'Parcel collected'**
  String get parcelCollected;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @shareLinkSoon.
  ///
  /// In en, this message translates to:
  /// **'Share link coming soon.'**
  String get shareLinkSoon;

  /// No description provided for @shareListingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Copy listing link'**
  String get shareListingSubtitle;

  /// No description provided for @shareShopSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Copy shop link'**
  String get shareShopSubtitle;

  /// No description provided for @copyShareLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get copyShareLink;

  /// No description provided for @shareLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied to clipboard.'**
  String get shareLinkCopied;

  /// No description provided for @copyWhatsAppMessage.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp message'**
  String get copyWhatsAppMessage;

  /// No description provided for @copyWhatsAppMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Title + link ready to paste'**
  String get copyWhatsAppMessageHint;

  /// No description provided for @whatsAppMessageCopied.
  ///
  /// In en, this message translates to:
  /// **'Message copied — paste it in WhatsApp.'**
  String get whatsAppMessageCopied;

  /// No description provided for @reportListing.
  ///
  /// In en, this message translates to:
  /// **'Report listing'**
  String get reportListing;

  /// No description provided for @reportSent.
  ///
  /// In en, this message translates to:
  /// **'Report sent.'**
  String get reportSent;

  /// No description provided for @outOfStockDetailBanner.
  ///
  /// In en, this message translates to:
  /// **'Out of stock - this item is no longer available.'**
  String get outOfStockDetailBanner;

  /// No description provided for @acceptedPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Accepted price'**
  String get acceptedPriceLabel;

  /// No description provided for @buyerProtection.
  ///
  /// In en, this message translates to:
  /// **'Buyer protection'**
  String get buyerProtection;

  /// No description provided for @availableStock.
  ///
  /// In en, this message translates to:
  /// **'Available stock'**
  String get availableStock;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'less'**
  String get showLess;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'... more'**
  String get showMore;

  /// No description provided for @askAction.
  ///
  /// In en, this message translates to:
  /// **'Ask'**
  String get askAction;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @buyerProtectionFeesTitle.
  ///
  /// In en, this message translates to:
  /// **'Buyer Protection fee'**
  String get buyerProtectionFeesTitle;

  /// No description provided for @buyerProtectionFeesDescription.
  ///
  /// In en, this message translates to:
  /// **'For any purchase via \"Buy\", fees apply to cover Buyer Protection and the refund policy.'**
  String get buyerProtectionFeesDescription;

  /// No description provided for @fromLabel.
  ///
  /// In en, this message translates to:
  /// **'from'**
  String get fromLabel;

  /// No description provided for @memberItemsTab.
  ///
  /// In en, this message translates to:
  /// **'Member items'**
  String get memberItemsTab;

  /// No description provided for @similarItemsTab.
  ///
  /// In en, this message translates to:
  /// **'Similar items'**
  String get similarItemsTab;

  /// No description provided for @bundleBuyTitle.
  ///
  /// In en, this message translates to:
  /// **'Buy a bundle'**
  String get bundleBuyTitle;

  /// No description provided for @bundleBuySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save on shipping'**
  String get bundleBuySubtitle;

  /// No description provided for @createBundle.
  ///
  /// In en, this message translates to:
  /// **'Create bundle'**
  String get createBundle;

  /// No description provided for @makeOfferAction.
  ///
  /// In en, this message translates to:
  /// **'Make an offer'**
  String get makeOfferAction;

  /// No description provided for @buyAction.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buyAction;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// No description provided for @phoneNumberHintLocal.
  ///
  /// In en, this message translates to:
  /// **'6XX XXX XXX'**
  String get phoneNumberHintLocal;

  /// No description provided for @myCart.
  ///
  /// In en, this message translates to:
  /// **'My cart'**
  String get myCart;

  /// No description provided for @removeOutOfStockToContinue.
  ///
  /// In en, this message translates to:
  /// **'Remove out-of-stock items to continue.'**
  String get removeOutOfStockToContinue;

  /// No description provided for @emptyCartTitle.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get emptyCartTitle;

  /// No description provided for @emptyCartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse items and find what you love!'**
  String get emptyCartSubtitle;

  /// No description provided for @estimatedDeliveryFees.
  ///
  /// In en, this message translates to:
  /// **'Delivery fees (estimated)'**
  String get estimatedDeliveryFees;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place order'**
  String get placeOrder;

  /// No description provided for @offerMustBeLower.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount lower than the displayed price.'**
  String get offerMustBeLower;

  /// No description provided for @offerSentToSeller.
  ///
  /// In en, this message translates to:
  /// **'Offer sent to seller.'**
  String get offerSentToSeller;

  /// No description provided for @yourOfferGnf.
  ///
  /// In en, this message translates to:
  /// **'Your offer (GNF)'**
  String get yourOfferGnf;

  /// No description provided for @sendOffer.
  ///
  /// In en, this message translates to:
  /// **'Send offer'**
  String get sendOffer;

  /// No description provided for @sellerOnlyAreaTitle.
  ///
  /// In en, this message translates to:
  /// **'Seller-only area'**
  String get sellerOnlyAreaTitle;

  /// No description provided for @enableSellerModeInCustomization.
  ///
  /// In en, this message translates to:
  /// **'Activate a seller profile from Account or Settings.'**
  String get enableSellerModeInCustomization;

  /// No description provided for @adjustStocksTitle.
  ///
  /// In en, this message translates to:
  /// **'Adjust stock'**
  String get adjustStocksTitle;

  /// No description provided for @itemsInAlertOrOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'Items in alert or out of stock'**
  String get itemsInAlertOrOutOfStock;

  /// No description provided for @noItemInStockAlert.
  ///
  /// In en, this message translates to:
  /// **'No item in stock alert.'**
  String get noItemInStockAlert;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @partnerBrandLabel.
  ///
  /// In en, this message translates to:
  /// **'Partner brand'**
  String get partnerBrandLabel;

  /// No description provided for @orderStatusOrdered.
  ///
  /// In en, this message translates to:
  /// **'Order confirmed'**
  String get orderStatusOrdered;

  /// No description provided for @orderStatusPaid.
  ///
  /// In en, this message translates to:
  /// **'Payment confirmed'**
  String get orderStatusPaid;

  /// No description provided for @orderStatusSellerNotified.
  ///
  /// In en, this message translates to:
  /// **'Seller notified'**
  String get orderStatusSellerNotified;

  /// No description provided for @orderStatusPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get orderStatusPreparing;

  /// No description provided for @orderStatusReadyForPickup.
  ///
  /// In en, this message translates to:
  /// **'Parcel ready'**
  String get orderStatusReadyForPickup;

  /// No description provided for @orderStatusCourierAssigned.
  ///
  /// In en, this message translates to:
  /// **'Courier assigned'**
  String get orderStatusCourierAssigned;

  /// No description provided for @orderStatusCollected.
  ///
  /// In en, this message translates to:
  /// **'Parcel collected'**
  String get orderStatusCollected;

  /// No description provided for @orderStatusInTransit.
  ///
  /// In en, this message translates to:
  /// **'In transit'**
  String get orderStatusInTransit;

  /// No description provided for @orderStatusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Parcel delivered'**
  String get orderStatusDelivered;

  /// No description provided for @orderStatusFundsReleased.
  ///
  /// In en, this message translates to:
  /// **'Seller payment released'**
  String get orderStatusFundsReleased;

  /// No description provided for @orderStatusFeedbackPending.
  ///
  /// In en, this message translates to:
  /// **'To review'**
  String get orderStatusFeedbackPending;

  /// No description provided for @courierStepToCollect.
  ///
  /// In en, this message translates to:
  /// **'To collect'**
  String get courierStepToCollect;

  /// No description provided for @courierStepInTransit.
  ///
  /// In en, this message translates to:
  /// **'In transit'**
  String get courierStepInTransit;

  /// No description provided for @categoryMode.
  ///
  /// In en, this message translates to:
  /// **'Fashion & Accessories'**
  String get categoryMode;

  /// No description provided for @categoryShoes.
  ///
  /// In en, this message translates to:
  /// **'Shoes'**
  String get categoryShoes;

  /// No description provided for @categoryBeauty.
  ///
  /// In en, this message translates to:
  /// **'Beauty & Cosmetics'**
  String get categoryBeauty;

  /// No description provided for @categoryBaby.
  ///
  /// In en, this message translates to:
  /// **'Baby & Maternity'**
  String get categoryBaby;

  /// No description provided for @categoryGrocery.
  ///
  /// In en, this message translates to:
  /// **'Grocery & Breakfast'**
  String get categoryGrocery;

  /// No description provided for @categoryHome.
  ///
  /// In en, this message translates to:
  /// **'Home & Decor'**
  String get categoryHome;

  /// No description provided for @categoryElectronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics - Appliances'**
  String get categoryElectronics;

  /// No description provided for @categorySecondhand.
  ///
  /// In en, this message translates to:
  /// **'Second hand'**
  String get categorySecondhand;

  /// No description provided for @categoryElectronicsShort.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get categoryElectronicsShort;

  /// No description provided for @categoryBeautyShort.
  ///
  /// In en, this message translates to:
  /// **'Beauty'**
  String get categoryBeautyShort;

  /// No description provided for @categoryGroceryShort.
  ///
  /// In en, this message translates to:
  /// **'Grocery'**
  String get categoryGroceryShort;

  /// No description provided for @subcategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Subcategory'**
  String get subcategoryLabel;

  /// No description provided for @subcategoryWomen.
  ///
  /// In en, this message translates to:
  /// **'Women'**
  String get subcategoryWomen;

  /// No description provided for @subcategoryMen.
  ///
  /// In en, this message translates to:
  /// **'Men'**
  String get subcategoryMen;

  /// No description provided for @subcategoryKids.
  ///
  /// In en, this message translates to:
  /// **'Children'**
  String get subcategoryKids;

  /// No description provided for @subcategoryAccessories.
  ///
  /// In en, this message translates to:
  /// **'Accessories'**
  String get subcategoryAccessories;

  /// No description provided for @subcategoryPhones.
  ///
  /// In en, this message translates to:
  /// **'Phones & tablets'**
  String get subcategoryPhones;

  /// No description provided for @subcategoryTvs.
  ///
  /// In en, this message translates to:
  /// **'TVs'**
  String get subcategoryTvs;

  /// No description provided for @subcategoryComputers.
  ///
  /// In en, this message translates to:
  /// **'Computers'**
  String get subcategoryComputers;

  /// No description provided for @subcategoryAppliances.
  ///
  /// In en, this message translates to:
  /// **'Home appliances'**
  String get subcategoryAppliances;

  /// No description provided for @subcategoryBabyClothes.
  ///
  /// In en, this message translates to:
  /// **'Baby clothes'**
  String get subcategoryBabyClothes;

  /// No description provided for @subcategoryMaternity.
  ///
  /// In en, this message translates to:
  /// **'Maternity'**
  String get subcategoryMaternity;

  /// No description provided for @subcategoryBabyGear.
  ///
  /// In en, this message translates to:
  /// **'Baby gear'**
  String get subcategoryBabyGear;

  /// No description provided for @subcategoryFurniture.
  ///
  /// In en, this message translates to:
  /// **'Furniture'**
  String get subcategoryFurniture;

  /// No description provided for @subcategoryDecor.
  ///
  /// In en, this message translates to:
  /// **'Decor'**
  String get subcategoryDecor;

  /// No description provided for @subcategoryKitchen.
  ///
  /// In en, this message translates to:
  /// **'Kitchen'**
  String get subcategoryKitchen;

  /// No description provided for @subcategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get subcategoryOther;

  /// No description provided for @sizeScreenInches.
  ///
  /// In en, this message translates to:
  /// **'Screen size'**
  String get sizeScreenInches;

  /// No description provided for @sizeStorage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get sizeStorage;

  /// No description provided for @sizeShoeEu.
  ///
  /// In en, this message translates to:
  /// **'Shoe size (EU)'**
  String get sizeShoeEu;

  /// No description provided for @sizeAge.
  ///
  /// In en, this message translates to:
  /// **'Age / size'**
  String get sizeAge;

  /// No description provided for @selectSubcategoryFirst.
  ///
  /// In en, this message translates to:
  /// **'Select a subcategory first'**
  String get selectSubcategoryFirst;

  /// No description provided for @brandCatalogHint.
  ///
  /// In en, this message translates to:
  /// **'Brands are managed by FripCash. Pick one from the list, or type a custom brand if yours is missing.'**
  String get brandCatalogHint;

  /// No description provided for @platformBrands.
  ///
  /// In en, this message translates to:
  /// **'Platform brands'**
  String get platformBrands;

  /// No description provided for @faqCreateAccountQ.
  ///
  /// In en, this message translates to:
  /// **'How do I create an account?'**
  String get faqCreateAccountQ;

  /// No description provided for @faqCreateAccountA.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Sign up\", enter your phone number, choose a password, accept the terms, then confirm the SMS code.'**
  String get faqCreateAccountA;

  /// No description provided for @faqOtpNotReceivedQ.
  ///
  /// In en, this message translates to:
  /// **'I did not receive the OTP code'**
  String get faqOtpNotReceivedQ;

  /// No description provided for @faqOtpNotReceivedA.
  ///
  /// In en, this message translates to:
  /// **'Check that your number is correct and you have network. Wait 60 seconds then tap \"Resend code\". If the issue persists, contact support.'**
  String get faqOtpNotReceivedA;

  /// No description provided for @faqForgotPasswordQ.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get faqForgotPasswordQ;

  /// No description provided for @faqForgotPasswordA.
  ///
  /// In en, this message translates to:
  /// **'On the login screen, tap \"Forgot password?\", enter your number, validate the OTP code and set a new password.'**
  String get faqForgotPasswordA;

  /// No description provided for @faqAccountBlockedQ.
  ///
  /// In en, this message translates to:
  /// **'Why is my account blocked?'**
  String get faqAccountBlockedQ;

  /// No description provided for @faqAccountBlockedA.
  ///
  /// In en, this message translates to:
  /// **'An account may be temporarily suspended for suspicious activity or rule violations. Contact support for details.'**
  String get faqAccountBlockedA;

  /// No description provided for @faqDeliveryTimesQ.
  ///
  /// In en, this message translates to:
  /// **'What are the delivery times?'**
  String get faqDeliveryTimesQ;

  /// No description provided for @faqDeliveryTimesA.
  ///
  /// In en, this message translates to:
  /// **'Sellers choose a maximum delay (24h to 1 week for shops). Partner brands offer express delivery (2h or 4h).'**
  String get faqDeliveryTimesA;

  /// No description provided for @faqCommissionQ.
  ///
  /// In en, this message translates to:
  /// **'How does commission work?'**
  String get faqCommissionQ;

  /// No description provided for @faqCommissionA.
  ///
  /// In en, this message translates to:
  /// **'FripCash applies 8% on the seller net price (1% for Orange Money and 7% for the platform). The displayed price already includes these fees.'**
  String get faqCommissionA;

  /// No description provided for @faqOrangeMoneyQ.
  ///
  /// In en, this message translates to:
  /// **'Can I pay with Orange Money?'**
  String get faqOrangeMoneyQ;

  /// No description provided for @faqOrangeMoneyA.
  ///
  /// In en, this message translates to:
  /// **'Yes, all purchases are made in the app via Orange Money. Payment is secured before the parcel is sent.'**
  String get faqOrangeMoneyA;

  /// No description provided for @emailContact.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailContact;

  /// No description provided for @phoneContact.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneContact;

  /// No description provided for @whatsappContact.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsappContact;

  /// No description provided for @responseWithin24h.
  ///
  /// In en, this message translates to:
  /// **'Response within 24h'**
  String get responseWithin24h;

  /// No description provided for @weekdayHours.
  ///
  /// In en, this message translates to:
  /// **'Mon – Fri, 8am – 6pm'**
  String get weekdayHours;

  /// No description provided for @fastAssistance.
  ///
  /// In en, this message translates to:
  /// **'Fast assistance'**
  String get fastAssistance;

  /// No description provided for @skipTutorial.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipTutorial;

  /// No description provided for @tourSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get tourSearchTitle;

  /// No description provided for @tourSearchDescription.
  ///
  /// In en, this message translates to:
  /// **'Find items, sellers or shops in a snap.'**
  String get tourSearchDescription;

  /// No description provided for @tourNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get tourNotificationsTitle;

  /// No description provided for @tourNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Track your orders, messages and important alerts here.'**
  String get tourNotificationsDescription;

  /// No description provided for @tourCartTitle.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get tourCartTitle;

  /// No description provided for @tourCartDescription.
  ///
  /// In en, this message translates to:
  /// **'Review and confirm your purchases before paying.'**
  String get tourCartDescription;

  /// No description provided for @tourCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get tourCategoriesTitle;

  /// No description provided for @tourCategoriesDescription.
  ///
  /// In en, this message translates to:
  /// **'Filter by item type — thrift, shops, partner brands…'**
  String get tourCategoriesDescription;

  /// No description provided for @tourHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tourHomeTitle;

  /// No description provided for @tourHomeDescription.
  ///
  /// In en, this message translates to:
  /// **'Discover trending items and new arrivals.'**
  String get tourHomeDescription;

  /// No description provided for @tourFavoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get tourFavoritesTitle;

  /// No description provided for @tourFavoritesDescription.
  ///
  /// In en, this message translates to:
  /// **'Find the items you saved.'**
  String get tourFavoritesDescription;

  /// No description provided for @tourBrowseTitle.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get tourBrowseTitle;

  /// No description provided for @tourBrowseDescription.
  ///
  /// In en, this message translates to:
  /// **'Explore categories and discover items by type.'**
  String get tourBrowseDescription;

  /// No description provided for @tourSellTitle.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get tourSellTitle;

  /// No description provided for @tourSellDescription.
  ///
  /// In en, this message translates to:
  /// **'List an item or manage your seller space.'**
  String get tourSellDescription;

  /// No description provided for @tourMessagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get tourMessagesTitle;

  /// No description provided for @tourMessagesDescription.
  ///
  /// In en, this message translates to:
  /// **'Chat with buyers, sellers and couriers.'**
  String get tourMessagesDescription;

  /// No description provided for @tourProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tourProfileTitle;

  /// No description provided for @tourProfileDescription.
  ///
  /// In en, this message translates to:
  /// **'Settings, orders and account information.'**
  String get tourProfileDescription;

  /// No description provided for @greetingWithName.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String greetingWithName(String name);

  /// No description provided for @greetingDefault.
  ///
  /// In en, this message translates to:
  /// **'Hi!'**
  String get greetingDefault;

  /// No description provided for @joinFripCashTodayFree.
  ///
  /// In en, this message translates to:
  /// **'Join FripCash today for free'**
  String get joinFripCashTodayFree;

  /// No description provided for @joinAction.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get joinAction;

  /// No description provided for @promoFlashTitle.
  ///
  /// In en, this message translates to:
  /// **'Flash Sale'**
  String get promoFlashTitle;

  /// No description provided for @promoFlashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Discount'**
  String get promoFlashSubtitle;

  /// No description provided for @promoFlashOffer.
  ///
  /// In en, this message translates to:
  /// **'40-50% off'**
  String get promoFlashOffer;

  /// No description provided for @promoFlashCta.
  ///
  /// In en, this message translates to:
  /// **'See all items'**
  String get promoFlashCta;

  /// No description provided for @flashSaleAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get flashSaleAll;

  /// No description provided for @flashSaleDiscountLabel.
  ///
  /// In en, this message translates to:
  /// **'{percent}% Discount'**
  String flashSaleDiscountLabel(int percent);

  /// No description provided for @flashSaleEndsIn.
  ///
  /// In en, this message translates to:
  /// **'Ends in'**
  String get flashSaleEndsIn;

  /// No description provided for @promoNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New arrivals'**
  String get promoNewTitle;

  /// No description provided for @promoNewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Latest items added this week'**
  String get promoNewSubtitle;

  /// No description provided for @promoNewOffer.
  ///
  /// In en, this message translates to:
  /// **'From 5,000 F'**
  String get promoNewOffer;

  /// No description provided for @promoNewCta.
  ///
  /// In en, this message translates to:
  /// **'Discover new arrivals'**
  String get promoNewCta;

  /// No description provided for @promoWomenTitle.
  ///
  /// In en, this message translates to:
  /// **'Women\'s fashion'**
  String get promoWomenTitle;

  /// No description provided for @promoWomenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Dresses, bags and trendy accessories'**
  String get promoWomenSubtitle;

  /// No description provided for @promoWomenOffer.
  ///
  /// In en, this message translates to:
  /// **'Up to -30%'**
  String get promoWomenOffer;

  /// No description provided for @promoWomenCta.
  ///
  /// In en, this message translates to:
  /// **'See the collection'**
  String get promoWomenCta;

  /// No description provided for @tutorialsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tutorials'**
  String get tutorialsTitle;

  /// No description provided for @tutorialsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn how to sell on FripCash'**
  String get tutorialsSubtitle;

  /// No description provided for @tutorialSellIndividual.
  ///
  /// In en, this message translates to:
  /// **'Sell as an individual'**
  String get tutorialSellIndividual;

  /// No description provided for @tutorialCreateShop.
  ///
  /// In en, this message translates to:
  /// **'Create a shop'**
  String get tutorialCreateShop;

  /// No description provided for @tutorialBecomePartner.
  ///
  /// In en, this message translates to:
  /// **'Become a FripCash partner'**
  String get tutorialBecomePartner;

  /// No description provided for @videoDuration2min.
  ///
  /// In en, this message translates to:
  /// **'Video · 2 min'**
  String get videoDuration2min;

  /// No description provided for @videoDuration3min.
  ///
  /// In en, this message translates to:
  /// **'Video · 3 min'**
  String get videoDuration3min;

  /// No description provided for @textGuideLabel.
  ///
  /// In en, this message translates to:
  /// **'Text guide'**
  String get textGuideLabel;

  /// No description provided for @contentComingSoon.
  ///
  /// In en, this message translates to:
  /// **'{title} — coming soon.'**
  String contentComingSoon(String title);

  /// No description provided for @supportFaqOrderWhere.
  ///
  /// In en, this message translates to:
  /// **'Where is my order?'**
  String get supportFaqOrderWhere;

  /// No description provided for @supportFaqPaymentIssue.
  ///
  /// In en, this message translates to:
  /// **'Orange Money payment issue'**
  String get supportFaqPaymentIssue;

  /// No description provided for @supportFaqCommissionFees.
  ///
  /// In en, this message translates to:
  /// **'Commission and service fees'**
  String get supportFaqCommissionFees;

  /// No description provided for @supportFaqContactCourier.
  ///
  /// In en, this message translates to:
  /// **'Contact a courier'**
  String get supportFaqContactCourier;

  /// No description provided for @chatEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Write a message.'**
  String get chatEmptyMessage;

  /// No description provided for @chatBlockedMessage.
  ///
  /// In en, this message translates to:
  /// **'This message is not allowed. Exchanges must stay on FripCash.'**
  String get chatBlockedMessage;

  /// No description provided for @examplePrefix.
  ///
  /// In en, this message translates to:
  /// **'Ex:'**
  String get examplePrefix;

  /// No description provided for @exploreCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore categories'**
  String get exploreCategoriesTitle;

  /// No description provided for @homeCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get homeCategoriesTitle;

  /// No description provided for @recentlyAddedTitle.
  ///
  /// In en, this message translates to:
  /// **'Recently added'**
  String get recentlyAddedTitle;

  /// No description provided for @sponsoredSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Featured promotions'**
  String get sponsoredSectionTitle;

  /// No description provided for @sponsoredBadge.
  ///
  /// In en, this message translates to:
  /// **'Promo'**
  String get sponsoredBadge;

  /// No description provided for @viewProduct.
  ///
  /// In en, this message translates to:
  /// **'View product'**
  String get viewProduct;

  /// No description provided for @shopNow.
  ///
  /// In en, this message translates to:
  /// **'Shop now'**
  String get shopNow;

  /// No description provided for @homeDiscountsPromoteCta.
  ///
  /// In en, this message translates to:
  /// **'Promote a listing'**
  String get homeDiscountsPromoteCta;

  /// No description provided for @homeDiscountsPromoteHint.
  ///
  /// In en, this message translates to:
  /// **'Chat with FripCash admin to arrange a featured discount. Payment is handled off-platform; admin publishes the promo here.'**
  String get homeDiscountsPromoteHint;

  /// No description provided for @homeDiscountsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No promotions yet. Contact admin to feature your discount.'**
  String get homeDiscountsEmpty;

  /// No description provided for @viewShop.
  ///
  /// In en, this message translates to:
  /// **'View shop'**
  String get viewShop;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get addToCart;

  /// No description provided for @addedToCart.
  ///
  /// In en, this message translates to:
  /// **'Added to cart'**
  String get addedToCart;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @recommendedForYou.
  ///
  /// In en, this message translates to:
  /// **'Recommended for you'**
  String get recommendedForYou;

  /// No description provided for @homeCtaTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to clear out your closet?'**
  String get homeCtaTitle;

  /// No description provided for @homeCtaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join thousands of sellers on FripCash. It\'s free, fast and secure.'**
  String get homeCtaSubtitle;

  /// No description provided for @homeCtaButton.
  ///
  /// In en, this message translates to:
  /// **'Start selling'**
  String get homeCtaButton;

  /// No description provided for @offerStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get offerStatusPending;

  /// No description provided for @offerStatusRefused.
  ///
  /// In en, this message translates to:
  /// **'Refused'**
  String get offerStatusRefused;

  /// No description provided for @partnerDeliveryWithin.
  ///
  /// In en, this message translates to:
  /// **'Delivery within {sla}'**
  String partnerDeliveryWithin(String sla);

  /// No description provided for @sellerDeliversWithin.
  ///
  /// In en, this message translates to:
  /// **'Delivers within {sla}'**
  String sellerDeliversWithin(String sla);

  /// No description provided for @shippingFeesCalculatedAtCheckout.
  ///
  /// In en, this message translates to:
  /// **'Shipping fees are calculated at checkout.'**
  String get shippingFeesCalculatedAtCheckout;

  /// No description provided for @notifPackageReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Package ready for pickup'**
  String get notifPackageReadyTitle;

  /// No description provided for @notifOrderDeliveredTitle.
  ///
  /// In en, this message translates to:
  /// **'Your order has been delivered'**
  String get notifOrderDeliveredTitle;

  /// No description provided for @notifFundsReleasedTitle.
  ///
  /// In en, this message translates to:
  /// **'Seller payment unlocked'**
  String get notifFundsReleasedTitle;

  /// No description provided for @notifGiveFeedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave your review'**
  String get notifGiveFeedbackTitle;

  /// No description provided for @notifOrderUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Order update'**
  String get notifOrderUpdateTitle;

  /// No description provided for @notifStayReachableBody.
  ///
  /// In en, this message translates to:
  /// **'Stay reachable, the courier will contact you.'**
  String get notifStayReachableBody;

  /// No description provided for @notifCourierCanPickupBody.
  ///
  /// In en, this message translates to:
  /// **'A courier can pick up the package from the seller.'**
  String get notifCourierCanPickupBody;

  /// No description provided for @notifRateSellerBody.
  ///
  /// In en, this message translates to:
  /// **'Thank you for rating your seller.'**
  String get notifRateSellerBody;

  /// No description provided for @notifFundsCreditedBody.
  ///
  /// In en, this message translates to:
  /// **'Funds have been credited to the seller\'s wallet.'**
  String get notifFundsCreditedBody;

  /// No description provided for @notifHowWasExperienceBody.
  ///
  /// In en, this message translates to:
  /// **'How was your experience?'**
  String get notifHowWasExperienceBody;

  /// No description provided for @notifJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get notifJustNow;

  /// No description provided for @notifOfferAcceptedTitle.
  ///
  /// In en, this message translates to:
  /// **'Offer accepted'**
  String get notifOfferAcceptedTitle;

  /// No description provided for @notifOfferRefusedTitle.
  ///
  /// In en, this message translates to:
  /// **'Offer refused'**
  String get notifOfferRefusedTitle;

  /// No description provided for @notifOfferAcceptedBody.
  ///
  /// In en, this message translates to:
  /// **'Your offer on \"{productTitle}\" was accepted at {price} GNF.'**
  String notifOfferAcceptedBody(String productTitle, String price);

  /// No description provided for @notifOfferRefusedBody.
  ///
  /// In en, this message translates to:
  /// **'Your offer on \"{productTitle}\" was refused.'**
  String notifOfferRefusedBody(String productTitle);

  /// No description provided for @commissionPercent.
  ///
  /// In en, this message translates to:
  /// **'Commission {percent} %'**
  String commissionPercent(String percent);

  /// No description provided for @shopPreparationSla.
  ///
  /// In en, this message translates to:
  /// **'Ready within {sla} — shown on your shop profile'**
  String shopPreparationSla(String sla);

  /// No description provided for @mockConversionRate.
  ///
  /// In en, this message translates to:
  /// **'Mock conversion rate: 4.2%'**
  String get mockConversionRate;

  /// No description provided for @orderNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'No. {id}'**
  String orderNumberLabel(String id);

  /// No description provided for @orderItemsSummary.
  ///
  /// In en, this message translates to:
  /// **'{count} item(s) · {price} GNF'**
  String orderItemsSummary(int count, String price);

  /// No description provided for @conditionNewWithTag.
  ///
  /// In en, this message translates to:
  /// **'New with tags'**
  String get conditionNewWithTag;

  /// No description provided for @conditionNewWithTagDescription.
  ///
  /// In en, this message translates to:
  /// **'Brand new item with tags.'**
  String get conditionNewWithTagDescription;

  /// No description provided for @conditionNewWithoutTag.
  ///
  /// In en, this message translates to:
  /// **'New without tags'**
  String get conditionNewWithoutTag;

  /// No description provided for @conditionNewWithoutTagDescription.
  ///
  /// In en, this message translates to:
  /// **'Brand new item without tags.'**
  String get conditionNewWithoutTagDescription;

  /// No description provided for @conditionVeryGood.
  ///
  /// In en, this message translates to:
  /// **'Very good condition'**
  String get conditionVeryGood;

  /// No description provided for @conditionVeryGoodDescription.
  ///
  /// In en, this message translates to:
  /// **'Worn very little, in very good condition.'**
  String get conditionVeryGoodDescription;

  /// No description provided for @conditionGood.
  ///
  /// In en, this message translates to:
  /// **'Good condition'**
  String get conditionGood;

  /// No description provided for @conditionGoodDescription.
  ///
  /// In en, this message translates to:
  /// **'Minor signs of wear are possible.'**
  String get conditionGoodDescription;

  /// No description provided for @conditionSatisfactory.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get conditionSatisfactory;

  /// No description provided for @conditionSatisfactoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Frequently used, visible wear.'**
  String get conditionSatisfactoryDescription;

  /// No description provided for @notifHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String notifHoursAgo(int hours);

  /// No description provided for @notifYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get notifYesterday;

  /// No description provided for @notifNewOrderReceivedTitle.
  ///
  /// In en, this message translates to:
  /// **'New order received'**
  String get notifNewOrderReceivedTitle;

  /// No description provided for @notifPrepareParcelBody.
  ///
  /// In en, this message translates to:
  /// **'Prepare your parcel then tap \"Parcel ready\" on the received order.'**
  String get notifPrepareParcelBody;

  /// No description provided for @notifPickupParcelOrderBody.
  ///
  /// In en, this message translates to:
  /// **'Pick up the parcel at the seller - order #{orderId}.'**
  String notifPickupParcelOrderBody(String orderId);

  /// No description provided for @notifSlaReminderLateTitle.
  ///
  /// In en, this message translates to:
  /// **'SLA reminder - delayed delivery'**
  String get notifSlaReminderLateTitle;

  /// No description provided for @notifSlaReminderLateBody.
  ///
  /// In en, this message translates to:
  /// **'Order #{orderId} exceeds the {sla} delay. Please prepare the parcel.'**
  String notifSlaReminderLateBody(String orderId, String sla);

  /// No description provided for @timeToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get timeToday;

  /// No description provided for @timeYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get timeYesterday;

  /// No description provided for @timeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} day(s) ago'**
  String timeDaysAgo(int count);

  /// No description provided for @timeWeeksAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} week(s) ago'**
  String timeWeeksAgo(int count);

  /// No description provided for @onboardingPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your privacy preferences'**
  String get onboardingPrivacyTitle;

  /// No description provided for @onboardingPrivacyBody1.
  ///
  /// In en, this message translates to:
  /// **'We may process information that you actively provide when using our services, such as your account details, listings and messages.'**
  String get onboardingPrivacyBody1;

  /// No description provided for @onboardingPrivacyBody2Prefix.
  ///
  /// In en, this message translates to:
  /// **'We use cookies and similar technologies to improve your experience. See our '**
  String get onboardingPrivacyBody2Prefix;

  /// No description provided for @onboardingPrivacyBody2Suffix.
  ///
  /// In en, this message translates to:
  /// **' for more details.'**
  String get onboardingPrivacyBody2Suffix;

  /// No description provided for @cookiePolicy.
  ///
  /// In en, this message translates to:
  /// **'Cookie policy'**
  String get cookiePolicy;

  /// No description provided for @onboardingDataPurposesTitle.
  ///
  /// In en, this message translates to:
  /// **'We process data for the following purposes:'**
  String get onboardingDataPurposesTitle;

  /// No description provided for @onboardingDataPurposeSecurity.
  ///
  /// In en, this message translates to:
  /// **'Provide a safe and secure service'**
  String get onboardingDataPurposeSecurity;

  /// No description provided for @onboardingDataPurposeAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analyse user activity and run analytics'**
  String get onboardingDataPurposeAnalytics;

  /// No description provided for @onboardingDataPurposeMessaging.
  ///
  /// In en, this message translates to:
  /// **'Send personalised messages related to our services'**
  String get onboardingDataPurposeMessaging;

  /// No description provided for @acceptAll.
  ///
  /// In en, this message translates to:
  /// **'Accept all'**
  String get acceptAll;

  /// No description provided for @rejectAll.
  ///
  /// In en, this message translates to:
  /// **'Reject all'**
  String get rejectAll;

  /// No description provided for @manageCookies.
  ///
  /// In en, this message translates to:
  /// **'Manage cookies'**
  String get manageCookies;

  /// No description provided for @onboardingSlide1Title.
  ///
  /// In en, this message translates to:
  /// **'Turn closets into cash'**
  String get onboardingSlide1Title;

  /// No description provided for @onboardingSlide1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Sell the clothes you no longer wear to buyers across Guinea.'**
  String get onboardingSlide1Subtitle;

  /// No description provided for @onboardingSlide2Title.
  ///
  /// In en, this message translates to:
  /// **'Selling is free'**
  String get onboardingSlide2Title;

  /// No description provided for @onboardingSlide2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'No listing fees. Keep more of what you earn on every sale.'**
  String get onboardingSlide2Subtitle;

  /// No description provided for @onboardingSlide3Title.
  ///
  /// In en, this message translates to:
  /// **'Delivered to your door'**
  String get onboardingSlide3Title;

  /// No description provided for @onboardingSlide3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'FripCash couriers bring your finds across Guinea — fast and reliable.'**
  String get onboardingSlide3Subtitle;

  /// No description provided for @onboardingSlide4Title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to FripCash'**
  String get onboardingSlide4Title;

  /// No description provided for @onboardingSlide4Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Buy, sell and discover fashion, home and more in one place.'**
  String get onboardingSlide4Subtitle;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingGetStarted;

  /// No description provided for @listAnItem.
  ///
  /// In en, this message translates to:
  /// **'List an item'**
  String get listAnItem;

  /// No description provided for @shopTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Shop type'**
  String get shopTypeLabel;

  /// No description provided for @shopKindProximite.
  ///
  /// In en, this message translates to:
  /// **'Neighborhood shop'**
  String get shopKindProximite;

  /// No description provided for @shopKindProximiteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Grocery-style store — 5% commission, pickup codes, no FripCash courier'**
  String get shopKindProximiteSubtitle;

  /// No description provided for @shopKindStandard.
  ///
  /// In en, this message translates to:
  /// **'Classic boutique'**
  String get shopKindStandard;

  /// No description provided for @shopKindStandardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fashion & general shop — 8% commission with FripCash delivery'**
  String get shopKindStandardSubtitle;

  /// No description provided for @shopCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Shop category'**
  String get shopCategoryLabel;

  /// No description provided for @chooseShopCategory.
  ///
  /// In en, this message translates to:
  /// **'Choose a category'**
  String get chooseShopCategory;

  /// No description provided for @shopAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Street, neighborhood, landmark'**
  String get shopAddressHint;

  /// No description provided for @proximitySellSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add products via Excel, the FripCash library, or manually'**
  String get proximitySellSubtitle;

  /// No description provided for @addFromLibrary.
  ///
  /// In en, this message translates to:
  /// **'FripCash library'**
  String get addFromLibrary;

  /// No description provided for @addFromLibrarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick staples, set your net price and stock'**
  String get addFromLibrarySubtitle;

  /// No description provided for @addManually.
  ///
  /// In en, this message translates to:
  /// **'Add manually'**
  String get addManually;

  /// No description provided for @addManuallySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a listing for items not in the library'**
  String get addManuallySubtitle;

  /// No description provided for @productLibraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Product library'**
  String get productLibraryTitle;

  /// No description provided for @searchLibraryHint.
  ///
  /// In en, this message translates to:
  /// **'Search products…'**
  String get searchLibraryHint;

  /// No description provided for @libraryCommissionHint.
  ///
  /// In en, this message translates to:
  /// **'Buyer price includes {percent}% service fees'**
  String libraryCommissionHint(String percent);

  /// No description provided for @netPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Your net price (GNF)'**
  String get netPriceLabel;

  /// No description provided for @stockLabel.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stockLabel;

  /// No description provided for @availableToggle.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get availableToggle;

  /// No description provided for @availableToggleHint.
  ///
  /// In en, this message translates to:
  /// **'Mark as in stock without a fixed quantity'**
  String get availableToggleHint;

  /// No description provided for @publishSelectedItems.
  ///
  /// In en, this message translates to:
  /// **'Publish {count} item(s)'**
  String publishSelectedItems(int count);

  /// No description provided for @libraryItemsPublished.
  ///
  /// In en, this message translates to:
  /// **'{count} product(s) published'**
  String libraryItemsPublished(int count);

  /// No description provided for @mixedCartBlocked.
  ///
  /// In en, this message translates to:
  /// **'You cannot mix neighborhood-shop items with courier delivery items in one checkout. Please checkout separately.'**
  String get mixedCartBlocked;

  /// No description provided for @fulfillmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Pickup or local delivery'**
  String get fulfillmentTitle;

  /// No description provided for @fulfillmentModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Fulfillment'**
  String get fulfillmentModeLabel;

  /// No description provided for @fulfillmentPickup.
  ///
  /// In en, this message translates to:
  /// **'In-store pickup'**
  String get fulfillmentPickup;

  /// No description provided for @fulfillmentPickupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Collect at the shop with your order code — free'**
  String get fulfillmentPickupSubtitle;

  /// No description provided for @fulfillmentShopLocal.
  ///
  /// In en, this message translates to:
  /// **'Shop local delivery'**
  String get fulfillmentShopLocal;

  /// No description provided for @fulfillmentShopLocalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The merchant delivers nearby — free, share your address'**
  String get fulfillmentShopLocalSubtitle;

  /// No description provided for @freeDeliveryLabel.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get freeDeliveryLabel;

  /// No description provided for @serviceFeesTitleProximity.
  ///
  /// In en, this message translates to:
  /// **'Service fees (5%)'**
  String get serviceFeesTitleProximity;

  /// No description provided for @serviceFeesDescriptionProximity.
  ///
  /// In en, this message translates to:
  /// **'Displayed price already includes 5% FripCash service fees for neighborhood shops. No hidden fees at payment.'**
  String get serviceFeesDescriptionProximity;

  /// No description provided for @orderConfirmedProximitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show this code to the shop to collect your order or confirm delivery.'**
  String get orderConfirmedProximitySubtitle;

  /// No description provided for @pickupCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Pickup code'**
  String get pickupCodeLabel;

  /// No description provided for @pickupCodeHintPickup.
  ///
  /// In en, this message translates to:
  /// **'Present this code at the shop to pick up your order.'**
  String get pickupCodeHintPickup;

  /// No description provided for @pickupCodeHintDelivery.
  ///
  /// In en, this message translates to:
  /// **'Share this code with the shop for local delivery handoff.'**
  String get pickupCodeHintDelivery;

  /// No description provided for @orderReadyForHandoff.
  ///
  /// In en, this message translates to:
  /// **'Order ready'**
  String get orderReadyForHandoff;

  /// No description provided for @orderMarkedReadyProximity.
  ///
  /// In en, this message translates to:
  /// **'Order marked ready — buyer can use the code'**
  String get orderMarkedReadyProximity;

  /// No description provided for @confirmHandoff.
  ///
  /// In en, this message translates to:
  /// **'Confirm handoff'**
  String get confirmHandoff;

  /// No description provided for @handoffConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Order handed over'**
  String get handoffConfirmed;

  /// No description provided for @confirmReceiptTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm receipt'**
  String get confirmReceiptTitle;

  /// No description provided for @confirmReceiptBody.
  ///
  /// In en, this message translates to:
  /// **'Only confirm once the package is with you and looks right. Payment then goes to the seller.'**
  String get confirmReceiptBody;

  /// No description provided for @confirmReceiptButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm receipt'**
  String get confirmReceiptButton;

  /// No description provided for @confirmReceiptDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm you’ve received this order?'**
  String get confirmReceiptDialogTitle;

  /// No description provided for @confirmReceiptDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Confirm you’ve received this order in good condition. Payment will go to the seller and can’t be undone.'**
  String get confirmReceiptDialogBody;

  /// No description provided for @confirmReceiptYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, release payment'**
  String get confirmReceiptYes;

  /// No description provided for @confirmReceiptNotYet.
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get confirmReceiptNotYet;

  /// No description provided for @confirmReceiptSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payment released to the seller. Thank you!'**
  String get confirmReceiptSuccess;

  /// No description provided for @confirmReceiptAlreadyDone.
  ///
  /// In en, this message translates to:
  /// **'This order was already confirmed.'**
  String get confirmReceiptAlreadyDone;

  /// No description provided for @confirmReceiptNotReady.
  ///
  /// In en, this message translates to:
  /// **'This order is not ready to confirm yet.'**
  String get confirmReceiptNotReady;

  /// No description provided for @confirmReceiptNotFound.
  ///
  /// In en, this message translates to:
  /// **'Order not found.'**
  String get confirmReceiptNotFound;

  /// No description provided for @escrowHeldBuyer.
  ///
  /// In en, this message translates to:
  /// **'Held safely until you confirm receipt'**
  String get escrowHeldBuyer;

  /// No description provided for @escrowReleasedBuyer.
  ///
  /// In en, this message translates to:
  /// **'Payment sent to seller'**
  String get escrowReleasedBuyer;

  /// No description provided for @awaitingConfirmHint.
  ///
  /// In en, this message translates to:
  /// **'Confirm receipt when the package is in your hands to release payment.'**
  String get awaitingConfirmHint;

  /// No description provided for @confirmReceiptDisputeLocked.
  ///
  /// In en, this message translates to:
  /// **'Payment is locked while the dispute is open.'**
  String get confirmReceiptDisputeLocked;

  /// No description provided for @orderStatusDisputed.
  ///
  /// In en, this message translates to:
  /// **'Dispute open'**
  String get orderStatusDisputed;

  /// No description provided for @escrowDisputeLocked.
  ///
  /// In en, this message translates to:
  /// **'Payment locked while dispute is open'**
  String get escrowDisputeLocked;

  /// No description provided for @disputeSomethingWrongTitle.
  ///
  /// In en, this message translates to:
  /// **'Something wrong?'**
  String get disputeSomethingWrongTitle;

  /// No description provided for @disputeSomethingWrongBody.
  ///
  /// In en, this message translates to:
  /// **'Open a dispute if the item never arrived, is damaged, or doesn’t match the listing. Your payment stays locked and FripCash admin reviews your chat, delivery proof, and payment history.'**
  String get disputeSomethingWrongBody;

  /// No description provided for @disputeButton.
  ///
  /// In en, this message translates to:
  /// **'Dispute'**
  String get disputeButton;

  /// No description provided for @disputeReportLink.
  ///
  /// In en, this message translates to:
  /// **'A problem? Report'**
  String get disputeReportLink;

  /// No description provided for @disputeDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Open a dispute with the seller?'**
  String get disputeDialogTitle;

  /// No description provided for @disputeDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Tell admin what went wrong on {orderId}. Your payment stays locked while FripCash reviews chat, delivery proof, and payment history.'**
  String disputeDialogBody(String orderId);

  /// No description provided for @disputeSendToAdmin.
  ///
  /// In en, this message translates to:
  /// **'Send to admin'**
  String get disputeSendToAdmin;

  /// No description provided for @disputeWhatHappened.
  ///
  /// In en, this message translates to:
  /// **'What happened?'**
  String get disputeWhatHappened;

  /// No description provided for @disputeReasonHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Item arrived damaged, wrong colour, never delivered…'**
  String get disputeReasonHint;

  /// No description provided for @disputeReasonFooter.
  ///
  /// In en, this message translates to:
  /// **'This message is sent to FripCash admin with your order.'**
  String get disputeReasonFooter;

  /// No description provided for @disputeOpenBanner.
  ///
  /// In en, this message translates to:
  /// **'Dispute open — your payment stays locked until an admin reviews.'**
  String get disputeOpenBanner;

  /// No description provided for @disputeYourMessage.
  ///
  /// In en, this message translates to:
  /// **'Your message to admin: “{reason}”'**
  String disputeYourMessage(String reason);

  /// No description provided for @disputeOpenedToast.
  ///
  /// In en, this message translates to:
  /// **'Dispute sent to admin. Payment stays locked.'**
  String get disputeOpenedToast;

  /// No description provided for @disputeOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open dispute for this order.'**
  String get disputeOpenFailed;

  /// No description provided for @adminDisputesTitle.
  ///
  /// In en, this message translates to:
  /// **'Disputes (admin)'**
  String get adminDisputesTitle;

  /// No description provided for @adminDisputesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mock queue — refund buyer or release to seller'**
  String get adminDisputesSubtitle;

  /// No description provided for @adminDisputesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No open disputes right now.'**
  String get adminDisputesEmpty;

  /// No description provided for @adminDisputeRefund.
  ///
  /// In en, this message translates to:
  /// **'Refund buyer'**
  String get adminDisputeRefund;

  /// No description provided for @adminDisputeRelease.
  ///
  /// In en, this message translates to:
  /// **'Release to seller'**
  String get adminDisputeRelease;

  /// No description provided for @adminDisputePartial.
  ///
  /// In en, this message translates to:
  /// **'Partial refund'**
  String get adminDisputePartial;

  /// No description provided for @adminDisputeResolved.
  ///
  /// In en, this message translates to:
  /// **'Dispute resolved.'**
  String get adminDisputeResolved;

  /// No description provided for @adminDisputeOpenSince.
  ///
  /// In en, this message translates to:
  /// **'Opened {when}'**
  String adminDisputeOpenSince(String when);

  /// No description provided for @notifDisputeOpenedTitle.
  ///
  /// In en, this message translates to:
  /// **'Dispute opened'**
  String get notifDisputeOpenedTitle;

  /// No description provided for @notifDisputeOpenedBody.
  ///
  /// In en, this message translates to:
  /// **'Payment is locked while FripCash reviews your dispute.'**
  String get notifDisputeOpenedBody;

  /// No description provided for @orderStatusRefunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get orderStatusRefunded;

  /// No description provided for @escrowRefundedBuyer.
  ///
  /// In en, this message translates to:
  /// **'Payment closed · refunded after admin review'**
  String get escrowRefundedBuyer;

  /// No description provided for @refundResolvedBanner.
  ///
  /// In en, this message translates to:
  /// **'Refund issued — this dispute was closed by FripCash admin.'**
  String get refundResolvedBanner;

  /// No description provided for @notifRefundIssuedTitle.
  ///
  /// In en, this message translates to:
  /// **'Refund issued'**
  String get notifRefundIssuedTitle;

  /// No description provided for @notifRefundIssuedBody.
  ///
  /// In en, this message translates to:
  /// **'Admin closed your dispute with a refund.'**
  String get notifRefundIssuedBody;

  /// No description provided for @chatEmoji.
  ///
  /// In en, this message translates to:
  /// **'Emoji'**
  String get chatEmoji;

  /// No description provided for @chatCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get chatCamera;

  /// No description provided for @chatGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get chatGallery;

  /// No description provided for @chatPhotoCapturedMock.
  ///
  /// In en, this message translates to:
  /// **'Photo captured (mock).'**
  String get chatPhotoCapturedMock;

  /// No description provided for @chatPhotoPickedMock.
  ///
  /// In en, this message translates to:
  /// **'Photo added from gallery (mock).'**
  String get chatPhotoPickedMock;

  /// No description provided for @chatCardEscrowHeldTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment held in escrow'**
  String get chatCardEscrowHeldTitle;

  /// No description provided for @chatCardEscrowHeldBody.
  ///
  /// In en, this message translates to:
  /// **'Funds for {orderId} are held safely until the buyer confirms receipt.'**
  String chatCardEscrowHeldBody(String orderId);

  /// No description provided for @chatCardWaitingTitle.
  ///
  /// In en, this message translates to:
  /// **'Waiting for confirmation'**
  String get chatCardWaitingTitle;

  /// No description provided for @chatCardWaitingBody.
  ///
  /// In en, this message translates to:
  /// **'Seller is waiting for the buyer to confirm receipt of {orderId}.'**
  String chatCardWaitingBody(String orderId);

  /// No description provided for @chatCardReleasedTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment released'**
  String get chatCardReleasedTitle;

  /// No description provided for @chatCardReleasedBody.
  ///
  /// In en, this message translates to:
  /// **'Payment for {orderId} was released to the seller.'**
  String chatCardReleasedBody(String orderId);

  /// No description provided for @chatCardDisputeTitle.
  ///
  /// In en, this message translates to:
  /// **'Dispute locked'**
  String get chatCardDisputeTitle;

  /// No description provided for @chatCardDisputeBody.
  ///
  /// In en, this message translates to:
  /// **'Payment for {orderId} is locked while FripCash reviews the dispute.'**
  String chatCardDisputeBody(String orderId);

  /// No description provided for @chatCardOfdTitle.
  ///
  /// In en, this message translates to:
  /// **'Out for delivery'**
  String get chatCardOfdTitle;

  /// No description provided for @chatCardOfdBody.
  ///
  /// In en, this message translates to:
  /// **'{orderId} is on the way. Confirm receipt when the package is with you.'**
  String chatCardOfdBody(String orderId);

  /// No description provided for @chatCardOrderLabel.
  ///
  /// In en, this message translates to:
  /// **'Order {orderId}'**
  String chatCardOrderLabel(String orderId);

  /// No description provided for @chatCardReceivedTitle.
  ///
  /// In en, this message translates to:
  /// **'RECEIVED YOUR ORDER?'**
  String get chatCardReceivedTitle;

  /// No description provided for @chatCardReceivedBody.
  ///
  /// In en, this message translates to:
  /// **'Confirm only after you’ve checked the package for {orderId}{amount}. Payment then goes to the seller.'**
  String chatCardReceivedBody(String orderId, String amount);

  /// No description provided for @chatCardReceiptDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Receipt confirmed'**
  String get chatCardReceiptDoneTitle;

  /// No description provided for @chatCardReceiptDoneBody.
  ///
  /// In en, this message translates to:
  /// **'You confirmed {orderId}. Payment is going to the seller.'**
  String chatCardReceiptDoneBody(String orderId);

  /// No description provided for @startPreparing.
  ///
  /// In en, this message translates to:
  /// **'Start preparing'**
  String get startPreparing;

  /// No description provided for @paymentLocked.
  ///
  /// In en, this message translates to:
  /// **'Payment locked'**
  String get paymentLocked;

  /// No description provided for @needsActionFilter.
  ///
  /// In en, this message translates to:
  /// **'Needs action'**
  String get needsActionFilter;

  /// No description provided for @disputedFilter.
  ///
  /// In en, this message translates to:
  /// **'Disputed'**
  String get disputedFilter;

  /// No description provided for @refundedFilter.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get refundedFilter;

  /// No description provided for @openOrdersKpi.
  ///
  /// In en, this message translates to:
  /// **'Open orders'**
  String get openOrdersKpi;

  /// No description provided for @awaitingConfirmationKpi.
  ///
  /// In en, this message translates to:
  /// **'Awaiting confirmation'**
  String get awaitingConfirmationKpi;

  /// No description provided for @escrowOnHoldKpi.
  ///
  /// In en, this message translates to:
  /// **'On hold'**
  String get escrowOnHoldKpi;

  /// No description provided for @completedOrdersKpi.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedOrdersKpi;

  /// No description provided for @searchOrdersHint.
  ///
  /// In en, this message translates to:
  /// **'Search orders, buyers…'**
  String get searchOrdersHint;

  /// No description provided for @disputesBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'{count} open dispute(s)'**
  String disputesBannerTitle(int count);

  /// No description provided for @viewDisputes.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get viewDisputes;

  /// No description provided for @buyerActiveOrdersKpi.
  ///
  /// In en, this message translates to:
  /// **'Active orders'**
  String get buyerActiveOrdersKpi;

  /// No description provided for @buyerEscrowHeldKpi.
  ///
  /// In en, this message translates to:
  /// **'Escrow held'**
  String get buyerEscrowHeldKpi;

  /// No description provided for @buyerCompletedKpi.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get buyerCompletedKpi;

  /// No description provided for @allPurchasesFilter.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allPurchasesFilter;

  /// No description provided for @compareAtPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Previous price (GNF)'**
  String get compareAtPriceLabel;

  /// No description provided for @compareAtPriceHint.
  ///
  /// In en, this message translates to:
  /// **'Price before discount'**
  String get compareAtPriceHint;

  /// No description provided for @compareAtPriceInvalid.
  ///
  /// In en, this message translates to:
  /// **'Previous price must be higher than the sale price.'**
  String get compareAtPriceInvalid;

  /// No description provided for @discountToggleLabel.
  ///
  /// In en, this message translates to:
  /// **'Apply a discount'**
  String get discountToggleLabel;

  /// No description provided for @negotiableToggleLabel.
  ///
  /// In en, this message translates to:
  /// **'Accept offers'**
  String get negotiableToggleLabel;

  /// No description provided for @maxPhotosReached.
  ///
  /// In en, this message translates to:
  /// **'Maximum 8 photos per listing.'**
  String get maxPhotosReached;

  /// No description provided for @listingSoldOut.
  ///
  /// In en, this message translates to:
  /// **'Sold out'**
  String get listingSoldOut;

  /// No description provided for @listingActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get listingActive;

  /// No description provided for @sellerActionStartedPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparation started'**
  String get sellerActionStartedPreparing;

  /// No description provided for @disputesBannerBody.
  ///
  /// In en, this message translates to:
  /// **'Payment stays locked until FripCash admin reviews.'**
  String get disputesBannerBody;

  /// No description provided for @draftsTitle.
  ///
  /// In en, this message translates to:
  /// **'Drafts'**
  String get draftsTitle;

  /// No description provided for @draftsReadyToPost.
  ///
  /// In en, this message translates to:
  /// **'Ready to post'**
  String get draftsReadyToPost;

  /// No description provided for @draftsIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Incomplete'**
  String get draftsIncomplete;

  /// No description provided for @draftsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your drafts live here'**
  String get draftsEmptyTitle;

  /// No description provided for @draftsEmptyReadySubtitle.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any drafts ready to post right now.'**
  String get draftsEmptyReadySubtitle;

  /// No description provided for @draftsEmptyIncompleteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any incomplete drafts right now.'**
  String get draftsEmptyIncompleteSubtitle;

  /// No description provided for @savedToDrafts.
  ///
  /// In en, this message translates to:
  /// **'Saved to drafts'**
  String get savedToDrafts;

  /// No description provided for @saveToDrafts.
  ///
  /// In en, this message translates to:
  /// **'Save to drafts'**
  String get saveToDrafts;

  /// No description provided for @postListing.
  ///
  /// In en, this message translates to:
  /// **'Post listing'**
  String get postListing;

  /// No description provided for @copyAListing.
  ///
  /// In en, this message translates to:
  /// **'Copy a listing'**
  String get copyAListing;

  /// No description provided for @copyListingEmpty.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any listings to copy right now'**
  String get copyListingEmpty;

  /// No description provided for @addPhotosTitle.
  ///
  /// In en, this message translates to:
  /// **'Add photos'**
  String get addPhotosTitle;

  /// No description provided for @upToPhotos.
  ///
  /// In en, this message translates to:
  /// **'Up to {count}'**
  String upToPhotos(int count);

  /// No description provided for @viewPhotoGuide.
  ///
  /// In en, this message translates to:
  /// **'View photo guide'**
  String get viewPhotoGuide;

  /// No description provided for @editPhotos.
  ///
  /// In en, this message translates to:
  /// **'Edit photos'**
  String get editPhotos;

  /// No description provided for @addAtLeastOnePhoto.
  ///
  /// In en, this message translates to:
  /// **'Please add at least 1 photo or video.'**
  String get addAtLeastOnePhoto;

  /// No description provided for @infoSection.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get infoSection;

  /// No description provided for @addCategoryChip.
  ///
  /// In en, this message translates to:
  /// **'+ Category'**
  String get addCategoryChip;

  /// No description provided for @addBrandChip.
  ///
  /// In en, this message translates to:
  /// **'+ Brand'**
  String get addBrandChip;

  /// No description provided for @addConditionChip.
  ///
  /// In en, this message translates to:
  /// **'+ Condition'**
  String get addConditionChip;

  /// No description provided for @addSizeChip.
  ///
  /// In en, this message translates to:
  /// **'+ Size'**
  String get addSizeChip;

  /// No description provided for @quantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantityLabel;

  /// No description provided for @priceSection.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceSection;

  /// No description provided for @shippingSection.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get shippingSection;

  /// No description provided for @domesticShippingPrice.
  ///
  /// In en, this message translates to:
  /// **'Domestic shipping price'**
  String get domesticShippingPrice;

  /// No description provided for @locationChip.
  ///
  /// In en, this message translates to:
  /// **'Location: {location}'**
  String locationChip(String location);

  /// No description provided for @worldwideShippingOptional.
  ///
  /// In en, this message translates to:
  /// **'+ Worldwide (optional)'**
  String get worldwideShippingOptional;

  /// No description provided for @hashtagsCount.
  ///
  /// In en, this message translates to:
  /// **'Hashtags: {count}'**
  String hashtagsCount(int count);

  /// No description provided for @yourPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Your price (what you receive)'**
  String get yourPriceLabel;

  /// No description provided for @commissionFeeLabel.
  ///
  /// In en, this message translates to:
  /// **'FripCash commission ({percent}%)'**
  String commissionFeeLabel(String percent);

  /// No description provided for @buyerSeesPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price buyers will see'**
  String get buyerSeesPriceLabel;

  /// No description provided for @commissionSellerHint.
  ///
  /// In en, this message translates to:
  /// **'Buyers only see the total price. The commission is included automatically.'**
  String get commissionSellerHint;

  /// No description provided for @listingPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Listing preview'**
  String get listingPreviewTitle;

  /// No description provided for @createNewListing.
  ///
  /// In en, this message translates to:
  /// **'Create new listing'**
  String get createNewListing;

  /// No description provided for @listFromTemplate.
  ///
  /// In en, this message translates to:
  /// **'List from template'**
  String get listFromTemplate;

  /// No description provided for @editDraftListings.
  ///
  /// In en, this message translates to:
  /// **'Edit draft listings'**
  String get editDraftListings;

  /// No description provided for @repostAnItem.
  ///
  /// In en, this message translates to:
  /// **'Repost an item'**
  String get repostAnItem;

  /// No description provided for @nowWithPhotos.
  ///
  /// In en, this message translates to:
  /// **'Now with photos'**
  String get nowWithPhotos;

  /// No description provided for @sellPromoTitle.
  ///
  /// In en, this message translates to:
  /// **'Transparent pricing'**
  String get sellPromoTitle;

  /// No description provided for @niceItsListed.
  ///
  /// In en, this message translates to:
  /// **'Nice, it\'s listed!'**
  String get niceItsListed;

  /// No description provided for @itemsListedProgress.
  ///
  /// In en, this message translates to:
  /// **'{count}/5 items listed'**
  String itemsListedProgress(int count);

  /// No description provided for @listFiveItemsHint.
  ///
  /// In en, this message translates to:
  /// **'Nice work. Try listing at least 5 items to help buyers find your shop.'**
  String get listFiveItemsHint;

  /// No description provided for @boostYourListing.
  ///
  /// In en, this message translates to:
  /// **'Boost your listing'**
  String get boostYourListing;

  /// No description provided for @boostListingBody.
  ///
  /// In en, this message translates to:
  /// **'Promote your item in search to help it sell faster. Pay a 12% boosting fee, only if you sell.'**
  String get boostListingBody;

  /// No description provided for @enhanceYourListing.
  ///
  /// In en, this message translates to:
  /// **'Enhance your listing'**
  String get enhanceYourListing;

  /// No description provided for @enhanceListingBody.
  ///
  /// In en, this message translates to:
  /// **'Help buyers find your item by tagging it with extra info.'**
  String get enhanceListingBody;

  /// No description provided for @extraInfo.
  ///
  /// In en, this message translates to:
  /// **'Extra info'**
  String get extraInfo;

  /// No description provided for @listedBadge.
  ///
  /// In en, this message translates to:
  /// **'LISTED'**
  String get listedBadge;

  /// No description provided for @photoTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Photo tips'**
  String get photoTipsTitle;

  /// No description provided for @getCoverShotTitle.
  ///
  /// In en, this message translates to:
  /// **'Get a cover shot'**
  String get getCoverShotTitle;

  /// No description provided for @getCoverShotBody.
  ///
  /// In en, this message translates to:
  /// **'Show off your item by using a clear flat lay or model shot as your cover photo.'**
  String get getCoverShotBody;

  /// No description provided for @captureAnglesTitle.
  ///
  /// In en, this message translates to:
  /// **'Capture different angles'**
  String get captureAnglesTitle;

  /// No description provided for @captureAnglesBody.
  ///
  /// In en, this message translates to:
  /// **'Front, back, and side views help buyers understand the fit and shape.'**
  String get captureAnglesBody;

  /// No description provided for @showTagsTitle.
  ///
  /// In en, this message translates to:
  /// **'Show tags and labels'**
  String get showTagsTitle;

  /// No description provided for @showTagsBody.
  ///
  /// In en, this message translates to:
  /// **'Include brand tags, size labels, and care instructions when you can.'**
  String get showTagsBody;

  /// No description provided for @showDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Show the details'**
  String get showDetailsTitle;

  /// No description provided for @showDetailsBody.
  ///
  /// In en, this message translates to:
  /// **'Close-ups of fabric, prints, hardware, and any wear help buyers feel confident.'**
  String get showDetailsBody;

  /// No description provided for @profileTabShop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get profileTabShop;

  /// No description provided for @profileTabSold.
  ///
  /// In en, this message translates to:
  /// **'Sold items'**
  String get profileTabSold;

  /// No description provided for @profileTabPurchased.
  ///
  /// In en, this message translates to:
  /// **'Purchased'**
  String get profileTabPurchased;

  /// No description provided for @profileTabLikes.
  ///
  /// In en, this message translates to:
  /// **'Likes'**
  String get profileTabLikes;

  /// No description provided for @followersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} followers'**
  String followersCount(int count);

  /// No description provided for @followingCount.
  ///
  /// In en, this message translates to:
  /// **'{count} following'**
  String followingCount(int count);

  /// No description provided for @noReviews.
  ///
  /// In en, this message translates to:
  /// **'no reviews'**
  String get noReviews;

  /// No description provided for @shopStats.
  ///
  /// In en, this message translates to:
  /// **'Shop Stats'**
  String get shopStats;

  /// No description provided for @trackProgress.
  ///
  /// In en, this message translates to:
  /// **'Track progress'**
  String get trackProgress;

  /// No description provided for @boostingFeesChanging.
  ///
  /// In en, this message translates to:
  /// **'Boosting fees are changing'**
  String get boostingFeesChanging;

  /// No description provided for @boostingFeesChangingBody.
  ///
  /// In en, this message translates to:
  /// **'From March 23, the fee for boosting a listing will be 12%.'**
  String get boostingFeesChangingBody;

  /// No description provided for @learnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn more'**
  String get learnMore;

  /// No description provided for @activeListingsCount.
  ///
  /// In en, this message translates to:
  /// **'Active ({count} listings)'**
  String activeListingsCount(int count);

  /// No description provided for @startSellingBuildShop.
  ///
  /// In en, this message translates to:
  /// **'Start selling to build your shop'**
  String get startSellingBuildShop;

  /// No description provided for @activeListingsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your active listings will show up here'**
  String get activeListingsEmpty;

  /// No description provided for @bulkActions.
  ///
  /// In en, this message translates to:
  /// **'Bulk actions'**
  String get bulkActions;

  /// No description provided for @filterToShip.
  ///
  /// In en, this message translates to:
  /// **'To ship'**
  String get filterToShip;

  /// No description provided for @filterInTransit.
  ///
  /// In en, this message translates to:
  /// **'In transit'**
  String get filterInTransit;

  /// No description provided for @filterCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get filterCancelled;

  /// No description provided for @emptySoldToShip.
  ///
  /// In en, this message translates to:
  /// **'Items to ship will show up here'**
  String get emptySoldToShip;

  /// No description provided for @emptySoldInTransit.
  ///
  /// In en, this message translates to:
  /// **'Items in transit will show up here'**
  String get emptySoldInTransit;

  /// No description provided for @emptySoldCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled sales will show up here'**
  String get emptySoldCancelled;

  /// No description provided for @emptySoldCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed sales will show up here'**
  String get emptySoldCompleted;

  /// No description provided for @emptySoldAll.
  ///
  /// In en, this message translates to:
  /// **'Sold items will show up here'**
  String get emptySoldAll;

  /// No description provided for @emptyPurchasedOrders.
  ///
  /// In en, this message translates to:
  /// **'Your orders will show up here'**
  String get emptyPurchasedOrders;

  /// No description provided for @outfits.
  ///
  /// In en, this message translates to:
  /// **'Outfits'**
  String get outfits;

  /// No description provided for @likedItems.
  ///
  /// In en, this message translates to:
  /// **'Liked items'**
  String get likedItems;

  /// No description provided for @likesInterestHint.
  ///
  /// In en, this message translates to:
  /// **'Missed out on a liked item? Tap ‘Show interest’ and we’ll let the new owner know you’d like to buy it. '**
  String get likesInterestHint;

  /// No description provided for @seeMyLikes.
  ///
  /// In en, this message translates to:
  /// **'See my likes'**
  String get seeMyLikes;

  /// No description provided for @emptyLikesMessage.
  ///
  /// In en, this message translates to:
  /// **'Items you like will show up here. Head to Browse to find your next great fit.'**
  String get emptyLikesMessage;

  /// No description provided for @myAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'My account'**
  String get myAccountTitle;

  /// No description provided for @fripCashBalance.
  ///
  /// In en, this message translates to:
  /// **'FripCash Balance'**
  String get fripCashBalance;

  /// No description provided for @sellMoreSection.
  ///
  /// In en, this message translates to:
  /// **'Sell more'**
  String get sellMoreSection;

  /// No description provided for @boostShop.
  ///
  /// In en, this message translates to:
  /// **'Boost Shop'**
  String get boostShop;

  /// No description provided for @boostShopLocked.
  ///
  /// In en, this message translates to:
  /// **'Start selling to unlock Boost Shop'**
  String get boostShopLocked;

  /// No description provided for @bundles.
  ///
  /// In en, this message translates to:
  /// **'Bundles'**
  String get bundles;

  /// No description provided for @badgeNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get badgeNew;

  /// No description provided for @bundlesSellersOnly.
  ///
  /// In en, this message translates to:
  /// **'Bundles are available for sellers'**
  String get bundlesSellersOnly;

  /// No description provided for @supportSection.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportSection;

  /// No description provided for @soldItemIssues.
  ///
  /// In en, this message translates to:
  /// **'Sold item issues'**
  String get soldItemIssues;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help and support'**
  String get helpAndSupport;

  /// No description provided for @settingsSection.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsSection;

  /// No description provided for @accountDetails.
  ///
  /// In en, this message translates to:
  /// **'Account details'**
  String get accountDetails;

  /// No description provided for @paymentSettings.
  ///
  /// In en, this message translates to:
  /// **'Payment settings'**
  String get paymentSettings;

  /// No description provided for @personalization.
  ///
  /// In en, this message translates to:
  /// **'Personalization'**
  String get personalization;

  /// No description provided for @twoFactorAuth.
  ///
  /// In en, this message translates to:
  /// **'Two-factor authentication'**
  String get twoFactorAuth;

  /// No description provided for @twoFactorComingSoon.
  ///
  /// In en, this message translates to:
  /// **'2FA coming soon'**
  String get twoFactorComingSoon;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @appVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'FripCash version {version}'**
  String appVersionLabel(String version);

  /// No description provided for @yourFripCashBalance.
  ///
  /// In en, this message translates to:
  /// **'Your fripcash balance'**
  String get yourFripCashBalance;

  /// No description provided for @pendingAmountGnf.
  ///
  /// In en, this message translates to:
  /// **'{amount} GNF pending'**
  String pendingAmountGnf(String amount);

  /// No description provided for @noBalanceToWithdraw.
  ///
  /// In en, this message translates to:
  /// **'No balance to withdraw'**
  String get noBalanceToWithdraw;

  /// No description provided for @latestTransactions.
  ///
  /// In en, this message translates to:
  /// **'Latest transactions'**
  String get latestTransactions;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @noTransactionsHint.
  ///
  /// In en, this message translates to:
  /// **'Once you make a sale, your earnings will show up here.'**
  String get noTransactionsHint;

  /// No description provided for @cameraLabel.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get cameraLabel;

  /// No description provided for @sellConditionBrandNew.
  ///
  /// In en, this message translates to:
  /// **'Brand new'**
  String get sellConditionBrandNew;

  /// No description provided for @sellConditionBrandNewDesc.
  ///
  /// In en, this message translates to:
  /// **'Unused with original packaging or tags'**
  String get sellConditionBrandNewDesc;

  /// No description provided for @sellConditionLikeNew.
  ///
  /// In en, this message translates to:
  /// **'Like new'**
  String get sellConditionLikeNew;

  /// No description provided for @sellConditionLikeNewDesc.
  ///
  /// In en, this message translates to:
  /// **'Mint condition pre-owned or new without tags'**
  String get sellConditionLikeNewDesc;

  /// No description provided for @sellConditionExcellent.
  ///
  /// In en, this message translates to:
  /// **'Used - Excellent'**
  String get sellConditionExcellent;

  /// No description provided for @sellConditionExcellentDesc.
  ///
  /// In en, this message translates to:
  /// **'Lightly used but no noticeable flaws'**
  String get sellConditionExcellentDesc;

  /// No description provided for @sellConditionGoodUsed.
  ///
  /// In en, this message translates to:
  /// **'Used - Good'**
  String get sellConditionGoodUsed;

  /// No description provided for @sellConditionGoodUsedDesc.
  ///
  /// In en, this message translates to:
  /// **'Minor flaws or signs of wear, to be noted in the description or photos'**
  String get sellConditionGoodUsedDesc;

  /// No description provided for @sellConditionFair.
  ///
  /// In en, this message translates to:
  /// **'Used - Fair'**
  String get sellConditionFair;

  /// No description provided for @sellConditionFairDesc.
  ///
  /// In en, this message translates to:
  /// **'Obvious flaws or signs of wear, to be noted in the description or photos'**
  String get sellConditionFairDesc;

  /// No description provided for @colorWhite.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get colorWhite;

  /// No description provided for @colorBlack.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get colorBlack;

  /// No description provided for @colorBrown.
  ///
  /// In en, this message translates to:
  /// **'Brown'**
  String get colorBrown;

  /// No description provided for @colorGrey.
  ///
  /// In en, this message translates to:
  /// **'Grey'**
  String get colorGrey;

  /// No description provided for @colorBeige.
  ///
  /// In en, this message translates to:
  /// **'Beige'**
  String get colorBeige;

  /// No description provided for @colorPink.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get colorPink;

  /// No description provided for @colorPurple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get colorPurple;

  /// No description provided for @colorRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get colorRed;

  /// No description provided for @colorYellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get colorYellow;

  /// No description provided for @colorBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get colorBlue;

  /// No description provided for @colorGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get colorGreen;

  /// No description provided for @colorOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get colorOrange;

  /// No description provided for @sellStepCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get sellStepCategory;

  /// No description provided for @sellStepPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get sellStepPhotos;

  /// No description provided for @sellStepDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get sellStepDetails;

  /// No description provided for @sellStepPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get sellStepPrice;

  /// No description provided for @sellStep1CalloutTitle.
  ///
  /// In en, this message translates to:
  /// **'Step 1 of 4 — start with the category'**
  String get sellStep1CalloutTitle;

  /// No description provided for @sellStep1CalloutBody.
  ///
  /// In en, this message translates to:
  /// **'The right department from the start: fewer misfiled listings, more sales.'**
  String get sellStep1CalloutBody;

  /// No description provided for @chooseACategory.
  ///
  /// In en, this message translates to:
  /// **'Choose a category'**
  String get chooseACategory;

  /// No description provided for @sellContinueToPhotos.
  ///
  /// In en, this message translates to:
  /// **'Continue to photos'**
  String get sellContinueToPhotos;

  /// No description provided for @sellContinueToDetails.
  ///
  /// In en, this message translates to:
  /// **'Continue to details'**
  String get sellContinueToDetails;

  /// No description provided for @sellContinueToPrice.
  ///
  /// In en, this message translates to:
  /// **'Continue to price'**
  String get sellContinueToPrice;

  /// No description provided for @sellVisualHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get sellVisualHome;

  /// No description provided for @sellVisualPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get sellVisualPremium;

  /// No description provided for @sellSubDresses.
  ///
  /// In en, this message translates to:
  /// **'Dresses'**
  String get sellSubDresses;

  /// No description provided for @sellSubTops.
  ///
  /// In en, this message translates to:
  /// **'Tops'**
  String get sellSubTops;

  /// No description provided for @sellSubBottoms.
  ///
  /// In en, this message translates to:
  /// **'Bottoms'**
  String get sellSubBottoms;

  /// No description provided for @sellSubShoes.
  ///
  /// In en, this message translates to:
  /// **'Shoes'**
  String get sellSubShoes;

  /// No description provided for @sellSubAccessories.
  ///
  /// In en, this message translates to:
  /// **'Accessories'**
  String get sellSubAccessories;

  /// No description provided for @sellSubFurniture.
  ///
  /// In en, this message translates to:
  /// **'Furniture'**
  String get sellSubFurniture;

  /// No description provided for @sellSubDecor.
  ///
  /// In en, this message translates to:
  /// **'Decor'**
  String get sellSubDecor;

  /// No description provided for @sellSubKitchen.
  ///
  /// In en, this message translates to:
  /// **'Kitchen'**
  String get sellSubKitchen;

  /// No description provided for @sellSubPhones.
  ///
  /// In en, this message translates to:
  /// **'Phones'**
  String get sellSubPhones;

  /// No description provided for @sellSubComputers.
  ///
  /// In en, this message translates to:
  /// **'Computers'**
  String get sellSubComputers;

  /// No description provided for @sellSubTvs.
  ///
  /// In en, this message translates to:
  /// **'TVs'**
  String get sellSubTvs;

  /// No description provided for @sellSubOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get sellSubOther;

  /// No description provided for @availableForWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Available for withdrawal'**
  String get availableForWithdrawal;

  /// No description provided for @withdrawOnOrangeMoney.
  ///
  /// In en, this message translates to:
  /// **'Withdraw via Orange Money'**
  String get withdrawOnOrangeMoney;

  /// No description provided for @escrowBarLabel.
  ///
  /// In en, this message translates to:
  /// **'{amount} GNF in escrow · {count} orders'**
  String escrowBarLabel(String amount, int count);

  /// No description provided for @shopTabBoutique.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shopTabBoutique;

  /// No description provided for @shopTabShipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get shopTabShipped;

  /// No description provided for @ordersToPrepareBefore.
  ///
  /// In en, this message translates to:
  /// **'{count} orders to prepare before {time}'**
  String ordersToPrepareBefore(int count, String time);

  /// No description provided for @courierTipTitle.
  ///
  /// In en, this message translates to:
  /// **'The courier comes when you mark “Parcel ready”'**
  String get courierTipTitle;

  /// No description provided for @courierTipBody.
  ///
  /// In en, this message translates to:
  /// **'They are notified automatically. Prepare the parcel before tapping.'**
  String get courierTipBody;

  /// No description provided for @youReceive.
  ///
  /// In en, this message translates to:
  /// **'You receive'**
  String get youReceive;

  /// No description provided for @noOrdersToPrepare.
  ///
  /// In en, this message translates to:
  /// **'No orders to prepare right now.'**
  String get noOrdersToPrepare;

  /// No description provided for @noShippedOrders.
  ///
  /// In en, this message translates to:
  /// **'No shipments in progress.'**
  String get noShippedOrders;

  /// No description provided for @noSoldOrdersYet.
  ///
  /// In en, this message translates to:
  /// **'No completed sales yet.'**
  String get noSoldOrdersYet;

  /// No description provided for @pickupInStoreTitle.
  ///
  /// In en, this message translates to:
  /// **'In-store pickup'**
  String get pickupInStoreTitle;

  /// No description provided for @sharePickupCode.
  ///
  /// In en, this message translates to:
  /// **'Share the code'**
  String get sharePickupCode;

  /// No description provided for @pickupOrderPaidLine.
  ///
  /// In en, this message translates to:
  /// **'Order {id} · already paid'**
  String pickupOrderPaidLine(String id);

  /// No description provided for @yourOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Your order'**
  String get yourOrderTitle;

  /// No description provided for @paidViaOrangeMoney.
  ///
  /// In en, this message translates to:
  /// **'Paid via Orange Money'**
  String get paidViaOrangeMoney;

  /// No description provided for @pickupAnyoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Anyone can collect with this code'**
  String get pickupAnyoneTitle;

  /// No description provided for @pickupAnyoneBody.
  ///
  /// In en, this message translates to:
  /// **'Give it to your child or a neighbour. The shopkeeper checks the code and hands over the order.'**
  String get pickupAnyoneBody;

  /// No description provided for @pickupCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code {code} copied — share it with whoever will pick up.'**
  String pickupCodeCopied(String code);

  /// No description provided for @proximityPickupOnlyHint.
  ///
  /// In en, this message translates to:
  /// **'Neighborhood shops: no delivery. Pay with Orange Money, get a pickup code, and collect in store.'**
  String get proximityPickupOnlyHint;

  /// No description provided for @sellerPickupCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Same code as the customer — verify it before handing over.'**
  String get sellerPickupCodeHint;

  /// No description provided for @retryAction.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryAction;

  /// No description provided for @catalogLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load data from the server. Please try again.'**
  String get catalogLoadError;

  /// No description provided for @walletLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your wallet. Please try again.'**
  String get walletLoadError;

  /// No description provided for @courierUseCourierLogin.
  ///
  /// In en, this message translates to:
  /// **'Courier accounts use Courier space. Sign in there instead of the marketplace.'**
  String get courierUseCourierLogin;

  /// No description provided for @approveShopDemo.
  ///
  /// In en, this message translates to:
  /// **'Approve shop (demo)'**
  String get approveShopDemo;

  /// No description provided for @shopApprovedDemo.
  ///
  /// In en, this message translates to:
  /// **'Shop approved — you can publish listings.'**
  String get shopApprovedDemo;

  /// No description provided for @legalTermsBody.
  ///
  /// In en, this message translates to:
  /// **'FripCash Terms of Use (demo). By using the app you agree to marketplace rules, escrow release, and anti-circumvention policies. Full legal copy will ship with production.'**
  String get legalTermsBody;

  /// No description provided for @legalPrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'FripCash Privacy Policy (demo). We process phone number and order data to operate the marketplace. Full policy will ship with production.'**
  String get legalPrivacyBody;

  /// No description provided for @searchScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchScreenTitle;

  /// No description provided for @searchScreenHint.
  ///
  /// In en, this message translates to:
  /// **'Search products, brands, categories…'**
  String get searchScreenHint;

  /// No description provided for @bulkActionsHint.
  ///
  /// In en, this message translates to:
  /// **'Manage stock and prices from My listings.'**
  String get bulkActionsHint;

  /// No description provided for @listingFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter listings'**
  String get listingFilterTitle;

  /// No description provided for @showInStockOnly.
  ///
  /// In en, this message translates to:
  /// **'In stock only'**
  String get showInStockOnly;

  /// No description provided for @challengeJoinedDemo.
  ///
  /// In en, this message translates to:
  /// **'Challenge tracked for this demo session.'**
  String get challengeJoinedDemo;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
