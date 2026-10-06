# FripCash i18n Rollout Checklist (en + fr)

Goal: ensure every user-visible string is localized in English and French.

## How we will work

- Add keys to `lib/l10n/app_en.arb` and `lib/l10n/app_fr.arb`.
- Replace hardcoded text with `AppLocalizations.of(context)!`.
- Run app and verify both locales screen-by-screen.
- Mark each item status only when reviewed on UI.

Status legend:
- `[ ]` not started
- `[/]` in progress
- `[x]` done and verified in app

## Foundation

- [x] Localization dependencies and setup (`pubspec.yaml`, `main.dart`, ARB files)
- [ ] Locale switch strategy (system locale only or in-app language selector)
- [ ] String formatting rules (currency, numbers, dates, plurals)

## Screens (page-by-page)

- [x] `lib/screens/splash_screen.dart`
- [x] `lib/screens/welcome_screen.dart`
- [x] `lib/screens/login_screen.dart`
- [x] `lib/screens/signup_screen.dart`
- [x] `lib/screens/forgot_password_screen.dart`
- [x] `lib/screens/reset_password_screen.dart`
- [x] `lib/screens/otp_verification_screen.dart`
- [x] `lib/screens/verification_loader_screen.dart`
- [x] `lib/screens/main_shell.dart`
- [x] `lib/screens/home_tab.dart`
- [x] `lib/screens/favorites_tab.dart`
- [x] `lib/screens/inbox_tab.dart`
- [x] `lib/screens/profile_tab.dart`
- [x] `lib/screens/create_listing_screen.dart`
- [x] `lib/screens/listing_publish_success_screen.dart`
- [x] `lib/screens/my_listings_screen.dart`
- [x] `lib/screens/sell_hub_screen.dart`
- [x] `lib/screens/shop_onboarding_screen.dart`
- [x] `lib/screens/seller_dashboard_screen.dart`
- [x] `lib/screens/seller_orders_screen.dart`
- [x] `lib/screens/seller_offers_screen.dart`
- [x] `lib/screens/shop_dashboard_screen.dart`
- [x] `lib/screens/excel_import_screen.dart`
- [x] `lib/screens/orders_hub_screen.dart`
- [x] `lib/screens/order_detail_screen.dart`
- [x] `lib/screens/rate_order_screen.dart`
- [x] `lib/screens/notifications_screen.dart`
- [x] `lib/screens/product_detail_screen.dart`
- [x] `lib/screens/buyer_offers_screen.dart`
- [x] `lib/screens/checkout_address_screen.dart`
- [x] `lib/screens/checkout_summary_screen.dart`
- [x] `lib/screens/order_confirmation_screen.dart`
- [x] `lib/screens/orange_money_payment_screen.dart`
- [x] `lib/screens/wallet_screen.dart`
- [x] `lib/screens/help_screen.dart`
- [x] `lib/screens/settings_screen.dart`
- [x] `lib/screens/edit_profile_screen.dart`
- [x] `lib/screens/change_password_screen.dart`
- [x] `lib/screens/public_profile_screen.dart`
- [x] `lib/screens/vacation_mode_screen.dart`
- [x] `lib/screens/bundle_discount_screen.dart`
- [x] `lib/screens/badges_screen.dart`
- [x] `lib/screens/support_chat_screen.dart`
- [x] `lib/screens/chat_screen.dart`
- [x] `lib/screens/courier_login_screen.dart`
- [x] `lib/screens/courier_home_screen.dart`
- [x] `lib/screens/courier_missions_screen.dart`
- [x] `lib/screens/courier_mission_detail_screen.dart`
- [x] `lib/screens/courier_earnings_screen.dart`

## Shared widgets with user text

- [x] `lib/widgets/auth_layout.dart`
- [x] `lib/widgets/auth_text_field.dart`
- [x] `lib/widgets/cart_sheet.dart`
- [x] `lib/widgets/consent_checkboxes.dart`
- [x] `lib/widgets/empty_state_view.dart`
- [x] `lib/widgets/make_offer_sheet.dart`
- [x] `lib/widgets/order_timeline.dart`
- [x] `lib/widgets/otp_input.dart`
- [x] `lib/widgets/pill_button.dart`
- [x] `lib/widgets/product_card.dart`
- [x] `lib/widgets/seller_gate.dart`
- [x] `lib/widgets/seller_stock_adjust_sheet.dart`

## Validation checklist

- [ ] Launch app in English and run core flows (auth, home, sell, checkout, profile)
- [ ] Launch app in French and run core flows (auth, home, sell, checkout, profile)
- [ ] No hardcoded UI copy left (search audit)
- [ ] No layout overflows caused by translation length
- [ ] i18n smoke test documented
