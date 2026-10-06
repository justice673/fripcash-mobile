# Flutter → Nest — Seller profile, settings, Excel import & share handoff

**From:** Flutter mobile (My shop header → account/settings + Excel + Share)  
**To:** Nest BE  
**Date:** 2026-10-02  
**Priority:** High — profile/settings mostly **local**; Excel was sending **hardcoded fake rows** (now blocked client-side)  
**Env:** `http://62.84.179.126:3010`  
**Base path:** `/api/v1`  
**Auth:** consumer Bearer  
**Locale:** `x-locale: FR` | `EN`

**Related:**  
- `docs/from-be/auth-mobile-flutter-handoff.md` (`GET /me`, become seller)  
- `docs/from-be/listings-mobile-flutter-handoff.md` (`POST …/excel-import` rows JSON, vacation POST exists but incomplete)  
- `docs/to-be/SELLER-DASHBOARD-KPIS-HANDOFF.md` (`share.publicShopUrl`)

---

## 0b. My account screen matrix (Flutter cleaned 2026-10-02)

Source: `MyAccountScreen`. Removed from UI: **Boost Shop**, duplicate **Personalization** (same as Preferences), **2FA** (not in phone+password product).

| Row | Audience | Destination | Nest status | Covered in handoff? |
|-----|----------|-------------|-------------|---------------------|
| FripCash Balance | all | WalletScreen | **LIVE** `GET/POST /wallet*` | from-be wallet |
| Become seller / Create shop | gated | BecomeSellerScreen | **LIVE** become seller | from-be auth |
| My offers | all | BuyerOffersScreen | **MISSING** | **OFFERS-BIDDING-HANDOFF** |
| Bundles | sellers w/ tools | BundleDiscountScreen | **MISSING** (local toggle) | **§4 this doc** |
| Sold item issues | all | HelpScreen (FAQ) | no API (static + support later) | messaging support optional |
| Help and support | all | HelpScreen | support chat → messaging handoff | MESSAGING handoff |
| Account details | all | PublicProfileScreen | listings cache; profile PATCH missing | **§1 PATCH /me** |
| Payment settings | all | WalletScreen | **LIVE** | from-be wallet |
| Preferences | all | SettingsScreen (edit profile, change password, push) | password **LIVE**; profile/push **MISSING** | **§1 + §2** |
| Vacation mode | sellers w/ tools | VacationModeScreen | stub POST; dates local | **§3** |
| Privacy | all | local policy dialog | no API | N/A (legal copy) |
| Sign out | all | `POST /auth/sign-out` | **LIVE** | from-be auth |

**Bundles product meaning:** automatic % off when a buyer buys **2+ items from the same seller**. Keep in product; BE must persist + apply at checkout (§4). Until then UI is local-only.

**Not requesting BE for:** Boost Shop, consumer 2FA, Personalization row.

From **My shop** chrome and nested screens:

| Control | Flutter today | Need |
|---------|---------------|------|
| Share | Hardcoded `https://fripcash.app/shop/{id}` | Server-owned public URL/slug |
| Edit profile | `MockSession.updateProfile` only | `PATCH /me` (or documented equivalent) |
| Push notifications toggle | Local bool | Persist prefs |
| Bundle discount | Local bool | Seller tools API |
| Vacation mode | Local dates + best-effort vacation POST | Full DTO with dates + GET state |
| Excel template download | Snackbar “simulation” | Real template file URL or bytes |
| Excel choose file | Was posting **hardcoded** SKU rows — **removed** | Multipart **or** documented JSON after client parse + template columns |
| Approve shop demo | Local verification hack | Real admin verification only (no client self-approve in prod) |

Please ship / complete the endpoints below. Reply with `docs/from-be/seller-settings-mobile-flutter-handoff.md` (or fold into auth + listings from-be).

---

## 1. Patch consumer profile

Auth handoff already notes phone is **not** editable via `PATCH /me`. Flutter Edit profile still needs:

```http
PATCH /api/v1/me
{
  "displayName": "Aïssatou Bah",
  "zoneId": "<cuid>",
  "address": "Kaloum, près du marché"
}
```

| Field | Editable | Notes |
|-------|----------|-------|
| `displayName` | yes | Buyer name / public |
| `zoneId` | yes | Must exist in `GET /catalog/zones` |
| `address` | yes | Free text |
| `phone` | **no** | Return `PHONE_IMMUTABLE` if sent |
| `avatar` | optional | Cloudinary publicId/url pattern like listings |

**200** → full `Me` DTO (same shape as `GET /me`).

If endpoint already exists under another path, document canonical path in from-be and OpenAPI — Flutter will wire it.

### 1.1 Shop display fields (seller)

```http
PATCH /api/v1/me/seller/profile
{
  "shopName": "Aminata Vintage",
  "shopDescription": "…",
  "logoPublicId": "…",
  "logoUrl": "https://res.cloudinary.com/…"
}
```

Used when seller edits boutique branding (become-seller already collects some of this).

---

## 2. Notification preferences

```http
GET  /api/v1/me/preferences
PATCH /api/v1/me/preferences
{
  "pushEnabled": true,
  "emailEnabled": false,
  "smsEnabled": false,
  "offerAlerts": true,
  "orderAlerts": true,
  "marketing": false
}
```

Flutter Settings “Push notifications” maps to `pushEnabled` at minimum.

---

## 3. Vacation mode (complete the existing stub)

Listings handoff already has:

```http
POST /api/v1/me/seller/tools/vacation
```

### 3.1 Required contract

```http
GET /api/v1/me/seller/tools/vacation
```

```json
{
  "enabled": false,
  "startsAt": null,
  "endsAt": null,
  "hideListings": true,
  "autoReplyMessage": null
}
```

```http
PUT /api/v1/me/seller/tools/vacation
{
  "enabled": true,
  "startsAt": "2026-10-10T00:00:00.000Z",
  "endsAt": "2026-10-20T23:59:59.000Z",
  "hideListings": true,
  "autoReplyMessage": "Je suis en congé, réponses au retour."
}
```

| Rule | |
|------|--|
| `endsAt` > `startsAt` when both set | |
| When `enabled` + `hideListings` | public discovery hides listings; seller still sees them in `/me/listings` |
| Orders already paid | still fulfillable |
| Disable | `enabled: false` clears or keeps dates (document) |

Flutter `VacationModeScreen` will stop saving dates only locally.

---

## 4. Bundle / volume discount (seller tool)

### 4.1 Flutter UI (v1) — seller configures the rule

Screen: `BundleDiscountScreen` (My account → Bundles).

| UI element | Behavior |
|------------|----------|
| Title | “Bundle discount” |
| Description | Automatic discount when buyer buys multiple items from this shop |
| Toggle | On / Off |
| **Minimum items** (number input) | Integer **2–20** (default `2`) |
| **Discount %** (number input) | Integer **1–50** (default `10`) |
| Live preview | e.g. “-10% from 2 items from your shop.” |
| Save | Persists via Nest `PUT` (Flutter local until endpoint live) |

Scope: cart lines from **the same seller** only. Delivery fees **excluded** from the discount base.

When Off, checkout applies **0** bundle discount for that seller.

```http
GET /api/v1/me/seller/tools/bundles
PUT /api/v1/me/seller/tools/bundles
```

**GET / PUT body:**

```json
{
  "enabled": true,
  "minItems": 2,
  "discountPercent": 10
}
```

| Field | Required | Validation |
|-------|----------|------------|
| `enabled` | yes | bool |
| `minItems` | yes when `enabled` | int 2–20 |
| `discountPercent` | yes when `enabled` | int 1–50 |

```http
PUT /api/v1/me/seller/tools/bundles
{
  "enabled": true,
  "minItems": 3,
  "discountPercent": 15
}
```

**Checkout:** when `enabled` and buyer cart has ≥ `minItems` purchasable lines from this seller, apply `discountPercent` off the **sum of those items’ display prices**.

| Rule | |
|------|--|
| Only sellers with boutique+ tools capability | `403 CAPABILITY_DENIED` otherwise |
| Particulier | no Bundles row in Flutter |
| Persist per `sellerProfileId` | |
| Reject out-of-range with `VALIDATION_ERROR` | |

### 4.2 Optional later (not in Flutter UI yet)

Multi-tier editor — **do not block v1**:

```json
{
  "enabled": true,
  "tiers": [
    { "minItems": 2, "discountPercent": 5 },
    { "minItems": 3, "discountPercent": 10 }
  ]
}
```

---

## 5. Public shop share

Header Share must not invent URLs.

**Preferred:** included on `GET /me/seller/dashboard` → `share` (see KPI handoff).

Also:

```http
GET /api/v1/me/seller/share
→ {
  "sellerProfileId": "…",
  "slug": "aminata-vintage",
  "url": "https://fripcash.app/shop/aminata-vintage",
  "webPath": "/shop/aminata-vintage"
}
```

Public resolve (optional for web):

```http
GET /api/v1/shops/:slug
→ public shop card + listings cursor
```

Slug rules: unique, lowercase kebab, immutable after first set **or** allow rename with 301 — document.

---

## 6. Excel import — replace dummy path

### 6.1 Problem

`POST /me/seller/tools/excel-import` with JSON `rows[]` exists, but Flutter had **hardcoded** sample rows (Robe wax, Sandales, …). That path is **disabled** on client until a real file flow exists.

### 6.2 Template download (missing)

```http
GET /api/v1/me/seller/tools/excel-template
```

**200** options (pick one):

**A.** Binary

```http
Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
Content-Disposition: attachment; filename="fripcash_catalogue_template.xlsx"
```

**B.** JSON redirect

```json
{ "url": "https://…/fripcash_catalogue_template.xlsx", "version": "2026-10-02", "expiresAt": "…" }
```

Flutter “Download Excel template” uses this — no simulation snackbar.

### 6.3 Column contract (must match template)

| Column | Required | Type | Notes |
|--------|----------|------|-------|
| `sku` | yes | string | Unique per seller |
| `title` | yes | string | |
| `netPriceGnf` | yes | int | Seller net |
| `stock` | yes | int ≥ 0 | |
| `categoryId` | yes | Nest category CUID **or** stable code you document |
| `subcategoryId` | no | | |
| `description` | no | | |
| `brand` | no | | |
| `size` | no | | |
| `conditionCode` | no | enum | |
| `compareAtPriceGnf` | no | | |
| `barcode` | no | | |

Return validation errors **per row**.

### 6.4 Import endpoints

**Keep JSON** (after client parse) — already sketched:

```http
POST /api/v1/me/seller/tools/excel-import
{
  "rows": [ { "sku": "…", "title": "…", "netPriceGnf": 45000, "stock": 12, "categoryId": "…" } ]
}
```

**Add multipart** (preferred for large files / server-side parse):

```http
POST /api/v1/me/seller/tools/excel-import/upload
Content-Type: multipart/form-data
file: <xlsx>
```

**200**

```json
{
  "jobId": "…",
  "imported": 40,
  "updated": 2,
  "failed": 0,
  "errors": [
    { "row": 12, "sku": "SKU-012", "code": "CATEGORY_NOT_FOUND", "message": "…" }
  ],
  "lastImportAt": "2026-10-02T09:00:00.000Z"
}
```

Async optional:

```http
GET /api/v1/me/seller/tools/excel-import/jobs/:jobId
```

### 6.5 Last import metadata

```http
GET /api/v1/me/seller/tools/excel-import/meta
→ { "lastImportAt": "…", "lastFileName": "catalogue.xlsx", "lastSummary": { "imported": 40, "updated": 2, "failed": 0 } }
```

Replace Flutter’s local `lastExcelImportLabel` fake date.

---

## 7. Seller verification (remove client self-approve)

Flutter shows “Approve shop demo” for pending proximité/enseigne — **local only**.

**Prod path:**

- Admin approves via existing admin APIs  
- Flutter only reads `GET /me` → `seller.verificationStatus`  
- No consumer endpoint to self-approve  

Please confirm admin approve route in from-be admin handoff. Flutter will remove demo approve button when verification is real.

---

## 8. Errors (shared)

| Code | HTTP | When |
|------|------|------|
| `UNAUTHORIZED` | 401 | |
| `NOT_A_SELLER` | 403 | Seller-only routes |
| `PHONE_IMMUTABLE` | 400 | |
| `ZONE_NOT_FOUND` | 400 | |
| `VALIDATION_ERROR` | 400 | |
| `CATEGORY_NOT_FOUND` | 400 | Excel row |
| `EXCEL_INVALID` | 400 | Bad file / columns |
| `CAPABILITY_DENIED` | 403 | Excel/bundles not allowed for seller kind |

---

## 9. Flutter UI ↔ API map

| UI | API |
|----|-----|
| Edit profile save | `PATCH /me` |
| Shop name / logo (if exposed) | `PATCH /me/seller/profile` |
| Push toggle | `PATCH /me/preferences` |
| Vacation screen | `GET/PUT …/vacation` |
| Bundles screen | `GET/PUT …/bundles` |
| Share icon | `GET …/share` or dashboard `share` |
| Download template | `GET …/excel-template` |
| Choose file / import | `POST …/excel-import/upload` or JSON rows from parsed file |
| Last import label | `…/excel-import/meta` |
| Verification banner | `GET /me` only |

---

## 10. Acceptance checklist

- [ ] Profile edits survive reinstall (server truth)  
- [ ] Vacation dates round-trip; listings hide when enabled  
- [ ] Template downloads a real xlsx  
- [ ] Import never accepts silent demo rows from FE  
- [ ] Share URL opens public shop (or documented deep link)  
- [ ] No consumer self-approve verification  
- [ ] OpenAPI + from-be update  

---

## 11. Example cURLs

```bash
HOST=http://62.84.179.126:3010
TOKEN=…

curl -sS -X PATCH "$HOST/api/v1/me" \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"displayName":"Aïssatou","zoneId":"…","address":"Kaloum"}'

curl -sS -X PUT "$HOST/api/v1/me/seller/tools/vacation" \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"enabled":true,"startsAt":"2026-10-10T00:00:00.000Z","endsAt":"2026-10-20T23:59:59.000Z","hideListings":true}'

curl -sS -OJ "$HOST/api/v1/me/seller/tools/excel-template" \
  -H "Authorization: Bearer $TOKEN"

curl -sS -X POST "$HOST/api/v1/me/seller/tools/excel-import/upload" \
  -H "Authorization: Bearer $TOKEN" \
  -F "file=@catalogue_boutique.xlsx"
```

---

## 12. Priority

| P0 | `PATCH /me` + vacation GET/PUT with dates |
| P0 | Excel template + real import (multipart or strict JSON) + meta |
| P1 | Share slug/URL |
| P1 | Preferences push toggle |
| P2 | Bundles tiers |
| P2 | Remove dependence on client verification demo |

Once P0 lands, Flutter wires settings/excel for real and keeps My shop free of dummy catalog posts.
