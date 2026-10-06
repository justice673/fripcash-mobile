# Seller profile, settings, Excel & share — Flutter mobile handoff

**Status:** Shipped (P0 + P1)  
**Base:** `/api/v1`  
**Auth:** Consumer Bearer  
**Locale:** `x-locale: FR` | `EN`

No consumer self-approve for shop verification — use admin  
`POST /admin/seller-verifications/:id/approve|reject` only.

---

## 1. Patch consumer profile

```http
PATCH /api/v1/me
{
  "displayName": "Aïssatou Bah",
  "zoneId": "<cuid>",
  "address": "Kaloum, près du marché",
  "avatarUrl": "https://res.cloudinary.com/…"
}
```

| Field | Editable |
|-------|----------|
| `displayName` | yes |
| `zoneId` | yes — must exist (`ZONE_NOT_FOUND`) |
| `address` | yes |
| `avatarUrl` / `avatarPublicId` | optional |
| `phone` | **no** → `PHONE_IMMUTABLE` 400 |

**200** → same shape as `GET /me`.

### Shop branding

```http
PATCH /api/v1/me/seller/profile
{
  "shopName": "Aminata Vintage",
  "shopDescription": "…",
  "logoPublicId": "…",
  "logoUrl": "https://…"
}
```

Updates `ShopDetails` (boutique) / `SellerProfile.displayName` + `bio` (particulier).

---

## 2. Preferences

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

Flutter Settings “Push notifications” → `pushEnabled`.  
(`marketing` syncs `user.marketingOptIn`.)

---

## 3. Vacation

```http
GET /api/v1/me/seller/tools/vacation
PUT /api/v1/me/seller/tools/vacation
```

```json
{
  "enabled": true,
  "startsAt": "2026-10-10T00:00:00.000Z",
  "endsAt": "2026-10-20T23:59:59.000Z",
  "hideListings": true,
  "autoReplyMessage": "Je suis en congé…"
}
```

| Rule | |
|------|--|
| `endsAt` > `startsAt` | else `INVALID_TIME_WINDOW` |
| `enabled` + `hideListings` | public listings → `HIDDEN`; seller still sees them in `/me/listings` |
| Disable (`enabled: false`) | restores previously hidden → `ACTIVE`; **keeps** stored dates |
| Paid orders | still fulfillable |

Legacy `POST …/vacation` still works.

---

## 4. Bundles (volume discount)

Boutique+ tools only (`CAPABILITY_DENIED` for particulier).

```http
GET /api/v1/me/seller/tools/bundles
PUT /api/v1/me/seller/tools/bundles
{
  "enabled": true,
  "minItems": 2,
  "discountPercent": 10
}
```

| Field | Range |
|-------|-------|
| `minItems` | 2–20 (required when enabled) |
| `discountPercent` | 1–50 (required when enabled) |

**Checkout:** if enabled and cart qty from that seller ≥ `minItems`, apply `%` off **merchandise** (display prices). Delivery fee excluded. Quote includes `bundleDiscountGnf`.

Legacy: `PATCH /me/seller/bundle-settings`.

---

## 5. Share

```http
GET /api/v1/me/seller/share
→ {
  "sellerProfileId": "…",
  "slug": "aminata-vintage",
  "url": "https://fripcash.app/shop/aminata-vintage",
  "webPath": "/shop/aminata-vintage"
}
```

Also on `GET /me/seller/dashboard` → `share.*`.  
Base URL: `PUBLIC_SHOP_BASE_URL` or `https://fripcash.app`.  
Slug: organization slug if present, else slugified shop name (mutable until org slug is set).

---

## 6. Excel import

### Template (binary)

```http
GET /api/v1/me/seller/tools/excel-template
Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
Content-Disposition: attachment; filename="fripcash_catalogue_template.xlsx"
```

### Columns

`sku*` · `title*` · `netPriceGnf*` · `stock*` · `categoryId*` (Nest category CUID) · `subcategoryId` · `description` · `brand` · `size` · `conditionCode` · `compareAtPriceGnf` · `barcode`

### Import

```http
POST /api/v1/me/seller/tools/excel-import
{ "rows": [ { "sku": "…", "title": "…", "netPriceGnf": 45000, "stock": 12, "categoryId": "…" } ] }

POST /api/v1/me/seller/tools/excel-import/upload
Content-Type: multipart/form-data
file: <xlsx>
```

**200**

```json
{
  "jobId": "excel_…",
  "imported": 40,
  "updated": 2,
  "failed": 0,
  "errors": [{ "row": 12, "sku": "SKU-012", "code": "CATEGORY_NOT_FOUND", "message": "…" }],
  "lastImportAt": "2026-10-02T09:00:00.000Z"
}
```

Creates/updates **DRAFT** listings by SKU (per seller). Bad file → `EXCEL_INVALID`.

### Meta

```http
GET /api/v1/me/seller/tools/excel-import/meta
→ {
  "lastImportAt": "…",
  "lastFileName": "catalogue.xlsx",
  "lastSummary": { "imported": 40, "updated": 2, "failed": 0 }
}
```

---

## 7. Verification

- Flutter reads `GET /me` → `seller.verificationStatus` only  
- Admin: `POST /api/v1/admin/seller-verifications/:id/approve` | `reject`  
- **No** consumer self-approve

---

## Errors

| Code | HTTP |
|------|------|
| `PHONE_IMMUTABLE` | 400 |
| `ZONE_NOT_FOUND` | 400 |
| `EXCEL_INVALID` | 400 |
| `CATEGORY_NOT_FOUND` | 400 (row / overall) |
| `CAPABILITY_DENIED` | 403 |
| `NOT_A_SELLER` | 403 |
| `INVALID_TIME_WINDOW` | 400 |

---

## Flutter map

| UI | API |
|----|-----|
| Edit profile | `PATCH /me` |
| Shop branding | `PATCH /me/seller/profile` |
| Push toggle | `PATCH /me/preferences` |
| Vacation | `GET/PUT …/vacation` |
| Bundles | `GET/PUT …/bundles` |
| Share | `GET …/share` or dashboard `share` |
| Template | `GET …/excel-template` |
| Import file | `POST …/excel-import/upload` |
| Last import | `GET …/excel-import/meta` |

---

## Example

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
