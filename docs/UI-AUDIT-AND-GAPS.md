# FripCash Flutter — UI Audit & Gaps (Mock-Only)

**Date:** 2026-09-30  
**Scope:** Flutter app at `/home/justice/frip_cash` — **no backend**. All data is in-memory mock.  
**Related:** [SRS roles](./srs/02-actors-and-roles.md) · [Admin / web companion](file:///home/justice/Desktop/Projects/fripcash/docs/UI-AUDIT-ADMIN-WEB.md) (`~/Desktop/Projects/fripcash/docs/UI-AUDIT-ADMIN-WEB.md`)

---

## 0. Verdict

> **Update 2026-09-30:** Mock UI gaps from this audit were addressed in code (courier OTP block, seller My Account, forgot password, SearchScreen, stub wiring, orphan cleanup, demo shop approve). Re-verify against section 8 before calling the mock “done.”

**Baseline (pre-fix):** Roughly 90% of screens were built and looked complete, but:

| Category | Approx. | Meaning |
|----------|---------|---------|
| Complete & reachable | ~55 | Usable end-to-end in mock |
| Complete but **orphan** | 7 | Built, **no in-app navigation** |
| Stub / empty handlers | ~10 spots | Visible control, `onPressed: () {}` or “coming soon” |
| **Role bugs** | 2 critical | Courier can enter marketplace shell; sellers lose My Account shortcuts |
| Deferred copy | 4 | 2FA, support contact, tutorials, boost locked |

For **demo / UI review**, the app is largely usable. For a **production-shaped mock**, wire orphans, fix role routing, and clear stub buttons before claiming completion.

**Capability source of truth:** `lib/utils/seller_access.dart`  
**Shell:** `lib/screens/main_shell.dart` (tab 4 = `ProfileTab` for buyers, `SellerDashboardScreen` for sellers)

---

## 1. Architecture (mock)

```text
SplashScreen
  ├─ signed out → Welcome → Login / SignUp (OTP any 6 digits)
  │     Login OTP → MainShell (always — bug for livreur phone)
  │     SignUp OTP → OnboardingPrivacy → OnboardingSlides → MainShell
  │         (proximité → ProductLibraryScreen first)
  │     “Espace livreur” → CourierLogin → CourierHomeShell
  └─ signed in → MainShell

MainShell tabs: Home | Browse | Sell | Messages | Profile/Boutique
Courier shell: Missions | Earnings | History | Profile
```

Session: `MockSession` — no persisted token. OTP accepts any 6-digit code. Catalog/listings from `mockProducts` via `ListingsRepository` / `CatalogRepository`.

---

## 2. Roles & capabilities

### 2.1 Runtime model

| Concept | Values |
|---------|--------|
| `UserRole` | `acheteur` · `vendeurParticulier` · `boutique` · `livreur` · `admin` |
| `ShopKind` (boutique only) | `standard` · `proximite` · `enseigne` |
| `SignUpRole` | `acheteur` · `particulier` · `boutique` · `commerceLocal` · `grandeSurface` |

Mapping (`mock_session.dart` / `listing_routing.dart`):

| Signup path | UserRole | ShopKind | Home universe | Manual validation |
|-------------|----------|----------|---------------|-------------------|
| acheteur | acheteur | — | — | No |
| particulier | vendeurParticulier | — | secondeMain | No |
| boutique | boutique | standard | articlesNeufs | No |
| commerceLocal | boutique | **proximite** | **quartierBoutiques** | **Yes** |
| grandeSurface | boutique | enseigne | enseignes | **Yes** |

### 2.2 Permission matrix (SRS §2.4 vs app)

| Capability | Acheteur | Particulier | Boutique std | Proximité | Enseigne | Livreur |
|------------|----------|-------------|--------------|-----------|----------|---------|
| MainShell tabs 0–3 | Yes | Yes | Yes | Yes | Yes | **Should be No** (bug) |
| Tab 4 | Profile | Boutique | Boutique | Boutique | Boutique | N/A |
| Browse / buy | Yes | Yes | Yes | Yes | Yes | Should be No |
| Nav (+) | → Become seller | → Create listing | → Create listing | Blocked if pending | Blocked if pending | Bug: full shell |
| Offers on listing | Yes* | Yes* | Yes* | Yes* | **No** on enseigne items | — |
| Seller dashboard | No | Yes | Yes | Yes | Yes | No |
| Excel import | No | No | Yes | Yes | Yes | No |
| Product library | No | No | No | **Yes only** | No | No |
| Courier shell | No | No | No | No | No | **Yes** (via courier login) |
| Admin disputes (mobile) | No | No | No | No | No | No (orphan screen) |

\*Except enseigne listings — “Demander” hidden on PDP when seller type is enseigne.

Gates: `SellerGate`, `CapabilityGate`, `hasSellerAccess`, `canAccessExcelImport`, `canAccessProductLibrary`, `canPublishListings`, `isSellerVerificationPending` in `seller_access.dart`.

---

## 3. Quartier / proximité shop — what only they get

When someone signs up as **commerce local** (or upgrades to proximité):

1. `UserRole.boutique` + `ShopKind.proximite`
2. Listings land in **Quartier boutiques** (`ListingDestination.quartierBoutiques`)
3. **Manual verification pending** — publish blocked until approved (`SellerVerificationService`)
4. After onboarding slides → **`ProductLibraryScreen(fromSignup: true)`** (other roles skip this)
5. Seller dashboard quick action **“Add from library”** (`seller_dashboard_screen.dart`)
6. **Excel import** (also shared with standard / enseigne shops — not particulier)
7. **Pickup codes** on seller order cards + buyer **`ProximityPickupScreen`** after payment
8. **5% commission** path in library (vs ~8% elsewhere)
9. Shop **hidden from directory** until verification approved
10. **No delivery SLA** required at registration (neighborhood pickup model)

**Mock login:** `+224 623 00 11 22` (`epicerie_kipé`) in `lib/mock/mock_users.dart`

**What they do *not* get vs enseigne:** enseigne destination / partner branding.  
**What they do *not* get vs particulier:** seconde-main-only listing path; they get shop tools (Excel + library).

---

## 4. Account creation — what each path gets after signup

Common: `SignUpScreen` → OTP (`OtpPurpose.signUp`) → `OnboardingPrivacyScreen` → `OnboardingSlidesScreen` → destination.

| Path | After OTP | Landing | Publish |
|------|-----------|---------|---------|
| Acheteur | Buyer `MockUser` | MainShell, Profile tab | N/A |
| Particulier | `vendeurParticulier` | MainShell, Boutique tab | Immediate |
| Boutique standard | `boutique` + standard | MainShell, Boutique tab | Immediate |
| Commerce local | `boutique` + proximite, pending | **Product library** then MainShell | Blocked while pending |
| Grande surface | `boutique` + enseigne, pending | MainShell | Blocked while pending |

**Upgrade (existing buyer):** `BecomeSellerScreen` → `upgradeBuyerToSeller()` → MainShell (no onboarding slides).

Password fields on signup are collected but ignored in mock OTP.

---

## 5. Dashboard-by-dashboard

### 5.1 MainShell tabs

| Tab | Buyer sees | Seller sees | Gaps |
|-----|------------|-------------|------|
| **Home** | Universes, carousels, inline search, notif / favorites / cart | Same | No dedicated `SearchScreen`; gift icon noop; home CTA noop; hardcoded `Réessayer` |
| **Browse** | Categories + search | Same | OK |
| **Sell** | Upgrade cards (individual / shop) | Immediately `SellerDashboardScreen` | Role-specific sell cards become dead code once seller |
| **Messages** | Inbox + threads + support entry | Same | `SupportChatScreen` orphan (support may use `ChatScreen` directly) |
| **Profile / Boutique** | `ProfileTab` (Shop / Sold / Purchased / Likes) + hamburger → My Account | **Only** `SellerDashboardScreen` | Sellers lose Profile panes + MyAccount menu path |

**Nav (+) (`main_shell.dart`):**
- Non-seller → `BecomeSellerScreen`
- Seller + pending verification → snackbar, no navigation
- Seller approved → `CreateListingScreen`

### 5.2 Buyer — ProfileTab + MyAccountScreen

**ProfileTab:** Shop | Sold | Purchased | Likes. Header: sell sheet, menu → `MyAccountScreen`.  
Stub: listing filter icon, bulk actions (`onPressed: () {}`).

**MyAccountScreen rows** (hamburger — buyers primarily; sellers rarely reach this):

| Row | Buyer | Particulier* | Shop* | Notes |
|-----|-------|--------------|-------|-------|
| Wallet | Yes | — | — | Sellers use dashboard balance card |
| Become seller | Yes | Hidden | Hidden | |
| Create shop | Hidden | Yes | Hidden | `canCreateOrUpgradeShop` |
| Boost shop | Locked snackbar | Opens dashboard if seller | Same | |
| Bundles | Locked snackbar | Open if tools | Open if tools | *Need MyAccount access |
| Help / sold issues | Yes | — | — | |
| Account details | Yes | — | — | |
| Payment settings | Yes | — | — | |
| 2FA | Coming soon | — | — | |
| Preferences / privacy | Yes | — | — | |
| Vacation mode | Hidden | Yes if tools | Yes if tools | *Need MyAccount |
| Sign out | Yes | — | — | |

\*Sellers’ tab 4 is the dashboard — they reach Settings via gear on dashboard, but **bundles / vacation / MyAccount** are easy to miss.

### 5.3 Seller dashboard (`SellerDashboardScreen`)

Entry: tab 4 (sellers), Sell tab, wallet CTAs, long-press Sell.

**Sections:** balance → wallet · orders · quick actions · share · settings gear.

**Quick actions by profile:**

| Action | Particulier | Std shop | Proximité | Enseigne |
|--------|-------------|----------|-----------|----------|
| New listing | Yes | Yes | Yes* | Yes* |
| Add from library | No | No | **Yes** | No |
| Excel import | No | Yes | Yes | Yes |
| My listings | Yes | Yes | Yes | Yes |
| Received offers | Yes | Yes | Yes | Yes |

\*Blocked when `isSellerVerificationPending`.

**Orphan:** `seller_orders_screen.dart` — full filtered orders UI exists; dashboard shows orders inline instead.

### 5.4 Sell / listing tools

| Screen | Status | Notes |
|--------|--------|-------|
| `create_listing_screen.dart` | Complete | Large wizard; destination from role; pending blocks submit |
| `my_listings_screen.dart` | Complete | `SellerGate` |
| `drafts_screen.dart` | Complete | |
| `copy_listing_screen.dart` | Mostly | App bar grid `onPressed: () {}` |
| `excel_import_screen.dart` | Mock complete | Fake upload + preview rows; `CapabilityGate` |
| `product_library_screen.dart` | Complete | Proximité only |
| `become_seller_screen.dart` | Complete | Upgrade |
| `shop_onboarding_screen.dart` | **Orphan** | Superseded by signup / become-seller |
| `listing_publish_success_screen.dart` | Complete | |
| `photo_tips_screen.dart` | Complete | |
| `bundle_discount_screen.dart` | Complete | Mock toggle |
| `vacation_mode_screen.dart` | Complete | Mock |
| `badges_screen.dart` | Mostly | Hardcoded French badge copy |

### 5.5 Checkout / orders / disputes

| Screen | Status |
|--------|--------|
| Cart sheet + `checkout_address` / `checkout_summary` | Complete mock |
| `orange_money_payment_screen` | Simulated delay → mock order |
| `order_confirmation_screen` | Complete |
| `proximity_pickup_screen` | Complete (proximity fulfillment) |
| `order_detail_screen` | Complete — timeline, dispute, rate |
| `rate_order_screen` | Complete |
| `orders_hub_screen` | **Orphan** — Profile Purchased/Sold replaced this for buyers |
| `buyer_offers_screen` | **Orphan** — offers also via PDP / seller side |

Buyer dispute → mock escrow lock works in `MockOrderService`. Flutter `admin_disputes_screen` resolves mocks but is **unreachable** (admin belongs on Next.js per SRS).

### 5.6 Discovery

| Screen | Status |
|--------|--------|
| `home_tab` / universe sections | Complete |
| `seconde_main` / `articles_neufs` / `quartier_boutiques` / `enseignes` | Complete |
| `browse_tab` / `browse_category` | Complete |
| `product_detail` | Complete — cart, offer, chat, enseigne offer hidden |
| `seller_profile` / `showcase` | Complete |
| Dedicated `SearchScreen` | **Missing** — home/browse use inline filter |

### 5.7 Courier shell

Entry: Login → “Espace livreur” → `CourierLoginScreen` → `CourierHomeScreen`.

| Tab | Status |
|-----|--------|
| Missions + mission detail | Complete |
| Earnings | Mostly — challenge button noop |
| History | Complete |
| Profile + sign out | Complete |

**Bug:** OTP login with courier phone (`+224 628 88 99 00`) still opens **MainShell**, not courier shell. Livreur can browse/buy/sell in mock.

### 5.8 Admin (mobile)

`admin_disputes_screen.dart` — full mock queue (refund / release / partial). **No nav, no admin mock user, no gate.** Per SRS §3.7 / §12, admin is **web-only**. Treat as dead code or remove; ops live in Next.js admin.

---

## 6. Screen inventory

Status: **OK** = complete & reachable · **ORPHAN** = built, no nav · **STUB** = partial / noop · **GAP** = missing feature

### Auth & onboarding

| File | Status | Remaining |
|------|--------|-----------|
| `splash_screen.dart` | OK | — |
| `welcome_screen.dart` | OK | — |
| `login_screen.dart` | STUB | No link to forgot password; terms taps empty |
| `signup_screen.dart` | OK | Category labels FR hardcoded |
| `otp_verification_screen.dart` | STUB | Always MainShell after sign-in (courier leak) |
| `verification_loader_screen.dart` | OK | — |
| `forgot_password_screen.dart` | ORPHAN | Wire from login |
| `reset_password_screen.dart` | ORPHAN† | Only via forgot OTP |
| `courier_login_screen.dart` | OK | — |
| `onboarding/onboarding_privacy_screen.dart` | OK | — |
| `onboarding/onboarding_slides_screen.dart` | OK | — |

†Reachable only if forgot password is wired.

### Shell tabs & account

| File | Status | Remaining |
|------|--------|-----------|
| `main_shell.dart` | OK | Seller Profile/MyAccount access |
| `home_tab.dart` | STUB | Gift icon; SearchScreen; i18n retry |
| `browse_tab.dart` | OK | — |
| `sell_hub_screen.dart` | OK | Seller early-return → dashboard |
| `inbox_tab.dart` | OK | — |
| `profile_tab.dart` | STUB | Filter / bulk noop; sellers don’t see tab |
| `favorites_tab.dart` | OK | Pushed from home |
| `my_account_screen.dart` | OK | Buyers only in practice |
| `settings_screen.dart` | OK | Gear from seller dashboard |
| `edit_profile_screen.dart` | OK | — |
| `change_password_screen.dart` | OK | Mock |
| `public_profile_screen.dart` | OK | — |
| `wallet_screen.dart` | OK | Mock |
| `help_screen.dart` | STUB | Contact support → coming soon |
| `notifications_screen.dart` | OK | — |

### Seller / listings

| File | Status | Remaining |
|------|--------|-----------|
| `seller_dashboard_screen.dart` | OK | — |
| `shop_dashboard_screen.dart` | OK | Thin wrapper |
| `create_listing_screen.dart` | OK | — |
| `my_listings_screen.dart` | OK | — |
| `seller_offers_screen.dart` | OK | — |
| `seller_orders_screen.dart` | ORPHAN | Link or delete |
| `excel_import_screen.dart` | OK | Mock only |
| `product_library_screen.dart` | OK | Proximité |
| `become_seller_screen.dart` | OK | — |
| `shop_onboarding_screen.dart` | ORPHAN | Delete or wire |
| `listing_publish_success_screen.dart` | OK | — |
| `drafts_screen.dart` | OK | — |
| `copy_listing_screen.dart` | STUB | Grid button noop |
| `photo_tips_screen.dart` | OK | — |
| `bundle_discount_screen.dart` | OK | Hard to reach for sellers |
| `vacation_mode_screen.dart` | OK | Hard to reach for sellers |
| `badges_screen.dart` | STUB | i18n |

### Discovery / PDP

| File | Status | Remaining |
|------|--------|-----------|
| `seconde_main_screen.dart` | OK | — |
| `articles_neufs_screen.dart` | OK | — |
| `quartier_boutiques_screen.dart` | OK | — |
| `enseignes_screen.dart` | OK | — |
| `browse_category_screen.dart` | OK | — |
| `showcase_screen.dart` | OK | — |
| `product_detail_screen.dart` | OK | — |
| `seller_profile_screen.dart` | OK | — |
| SearchScreen | **GAP** | Not created |

### Checkout / orders / chat

| File | Status | Remaining |
|------|--------|-----------|
| `checkout_address_screen.dart` | OK | — |
| `checkout_summary_screen.dart` | OK | — |
| `orange_money_payment_screen.dart` | OK | Simulated |
| `order_confirmation_screen.dart` | OK | — |
| `proximity_pickup_screen.dart` | OK | — |
| `order_detail_screen.dart` | OK | — |
| `orders_hub_screen.dart` | ORPHAN | Optional cleanup |
| `rate_order_screen.dart` | OK | — |
| `chat_screen.dart` | OK | — |
| `support_chat_screen.dart` | ORPHAN | Wire from help/inbox |
| `buyer_offers_screen.dart` | ORPHAN | Wire from profile/inbox |

### Courier

| File | Status | Remaining |
|------|--------|-----------|
| `courier_home_screen.dart` | OK | — |
| `courier_missions_screen.dart` | OK | — |
| `courier_mission_detail_screen.dart` | OK | — |
| `courier_earnings_screen.dart` | STUB | Challenge button |
| `courier_history_screen.dart` | OK | — |
| `courier_profile_screen.dart` | OK | — |

### Admin (should not be consumer)

| File | Status | Remaining |
|------|--------|-----------|
| `admin_disputes_screen.dart` | ORPHAN | Remove or mark dev-only; real admin = Next.js |

---

## 7. Stub buttons & “coming soon” (file evidence)

| Location | Behavior |
|----------|----------|
| `home_tab.dart` — gift / redeem header | `onTap: () {}` |
| Home CTA section | `onTap: () {}` |
| `profile_tab.dart` — filter | `onPressed: () {}` |
| `profile_tab.dart` — bulk actions | `onPressed: () {}` |
| `copy_listing_screen.dart` — grid | `onPressed: () {}` |
| `courier_earnings_screen.dart` — challenge | `onPressed: () {}` |
| `login_screen.dart` — terms / privacy | Empty taps |
| `my_account_screen.dart` — 2FA | `twoFactorComingSoon` snackbar |
| `help_screen.dart` — contact support | `supportOpeningSoon` |
| Home tutorials section | `contentComingSoon` |
| Boost shop (non-seller) | Locked snackbar (intentional) |

---

## 8. What’s left for mock-only to feel complete

### Done in mock UI completion pass (2026-09-30)

- Courier OTP blocked → courier login; MainShell redirects livreurs
- Seller dashboard: My Account icon + demo “Approve shop” + Seller orders quick action
- Login: forgot password + terms/privacy dialogs
- `SearchScreen` from home search bar; home CTA + wallet gift icon wired
- Help → SupportChat; My Account → My offers; profile filter/bulk wired
- Copy listing grid/list toggle; courier challenge demo snackbar
- Removed orphans: `admin_disputes_screen`, `shop_onboarding_screen`, `orders_hub_screen`

### Remaining polish (optional)

- Some create-listing chips are display-only (e.g. location chip)
- Badges / signup category copy still partly hardcoded FR
- 2FA remains “coming soon” by design

### Explicitly out of scope (needs BE later)

- Live Orange Money, SMS OTP, push (FCM/APNs), real escrow ledger  
- Photo object storage, Excel server parsing  
- Real cart/checkout/chat/wallet APIs  

---

## 9. Mock login cheat sheet

| Phone | Role |
|-------|------|
| `+224 620 12 34 56` | Acheteur |
| `+224 621 11 22 33` | Vendeur particulier |
| `+224 622 22 33 44` | Boutique standard |
| `+224 623 00 11 22` | Boutique **proximité** |
| `+224 628 88 99 00` | Livreur (use **Espace livreur**, not OTP) |
| Unknown phone | New session buyer |

OTP: any 6 digits. Session does not persist across app restarts.

---

## 10. SRS alignment (selected)

| SRS | App |
|-----|-----|
| §2.1–2.4 roles / permissions | Mostly implemented in `seller_access` + routing |
| §2.5 no free role switcher | OK |
| §3.4–3.5 upgrade + pending publish block | OK |
| §3.6 courier separate shell | Courier login OK; **OTP leak** |
| §3.7 / §12 admin web-only | Mobile admin orphan (correct intent, dead code) |
| §10 seller tools | Dashboard / Excel / library OK |
| §18 disputes | Buyer flow OK; admin resolve on **web**, not mobile |

---

## 11. Cross-links

- Product requirements: [docs/srs/](./srs/README.md) especially [02-actors-and-roles](./srs/02-actors-and-roles.md)
- Next.js public + admin audit: [`~/Desktop/Projects/fripcash/docs/UI-AUDIT-ADMIN-WEB.md`](file:///home/justice/Desktop/Projects/fripcash/docs/UI-AUDIT-ADMIN-WEB.md)
