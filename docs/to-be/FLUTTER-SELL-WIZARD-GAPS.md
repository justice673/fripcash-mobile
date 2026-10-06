# Flutter → Nest — Sell wizard gaps (title, discount, brands, taxonomy)

**From:** Flutter mobile  
**To:** Nest BE  
**Date:** 2026-10-02  
**Env:** `http://62.84.179.126:3010`  
**Base path:** `/api/v1`  
**Auth:** `Authorization: Bearer <consumer accessToken>`  
**Locale:** `x-locale: FR` | `EN`

**Related:**  
- `docs/from-be/listings-mobile-flutter-handoff.md`  
- `docs/from-be/listings-mobile-flutter-handoff.md`
- `docs/to-be/FLUTTER-CATALOG-DESTINATION-MISMATCH.md` (category × destination)

---

## Summary

Flutter’s **Sell an item** wizard (Category → Photos → Details → Price) is now wired to live Nest for:

- categories (`GET /catalog/categories`)
- listing create / media / publish (`POST /listings`, Cloudinary attach)
- commission rates
- `title`, `netPriceGnf`, `compareAtPriceGnf`, `discountEnabled` on create/patch (OpenAPI already documents these)

Several sell-form pieces are still **client mock / incomplete** because Nest endpoints or seeds are missing or mismatched. Please ship or confirm the items below so we can drop hardcoded lists.

---

## What Flutter sends today (create)

```http
POST /api/v1/listings
```

```json
{
  "title": "iPhone 14 Pro Max",
  "description": "…",
  "categoryId": "<Nest category CUID>",
  "subcategoryId": "<Nest subcategory CUID>",
  "conditionCode": "newWithTag",
  "brand": "Apple",
  "size": "512 GB",
  "colors": ["White"],
  "netPriceGnf": 300000,
  "discountEnabled": true,
  "compareAtPriceGnf": 400000,
  "shippingCostGnf": 5000,
  "worldwideShipping": false,
  "stock": 1,
  "negotiable": false,
  "publish": false
}
```

Then: Cloudinary upload → `POST /listings/:id/media` → `POST /listings/:id/publish`.

**Never send `destination`** — server sets from seller profile.

---

## Gap matrix

| Area | Flutter today | Nest today | Ask |
|------|---------------|------------|-----|
| **Title** | Required field (min 3 chars) on Details | `CreateListingDto.title` required — OK | Confirm validation messages / `VALIDATION_ERROR` details |
| **Discount** | Toggle → `discountEnabled` + `compareAtPriceGnf` (must be **> buyer display**) | Fields exist in OpenAPI | Confirm rule: `compareAtPriceGnf > displayPriceGnf` (display = net × (1+commission)); reject with clear code |
| **Brands** | Hardcoded list + free text | **No** `/catalog/brands*` in OpenAPI | Add suggest/list endpoint (below) |
| **Sizes / colors** | Hardcoded from local `listing_catalog.dart` | `GET /catalog/listing-taxonomy` **exists** | Align taxonomy ids with catalog CUIDs; Flutter will switch to live taxonomy |
| **Conditions** | Local enum matching OpenAPI | `conditionCode` enum — OK | Keep enum stable; return localized `condition` on listing DTO |
| **Categories** | Live `GET /catalog/categories` | Live, but destination-tagged 1:1 | See separate catalog destination doc |
| **Photos / thumbnail** | First photo = cover (`sortOrder: 0`) | Attach via Cloudinary publicId/url | Confirm cover = lowest `sortOrder` |

---

## 1. Brands (missing endpoint)

### Problem

UI copy says “Brands are managed by FripCash”, but Flutter uses a **static mock list** (`Adidas`, `Apple`, …). There is no Nest brand catalog in OpenAPI.

### Requested API

```http
GET /api/v1/catalog/brands?q=&limit=30
```

**Auth:** public or consumer bearer  
**Query:**

| Param | Required | Notes |
|-------|----------|-------|
| `q` | no | Case-insensitive prefix/contains |
| `limit` | no | Default 30, max 100 |

**Response `200`:**

```json
{
  "items": [
    { "id": "brand_apple", "name": "Apple", "slug": "apple" },
    { "id": "brand_adidas", "name": "Adidas", "slug": "adidas" }
  ]
}
```

Also allow free-text brand on create (`brand` string max 80) when user picks “custom / unbranded” — already in `CreateListingDto`.

Optional later:

```http
GET /api/v1/catalog/brands/suggest?q=ap
```

Same shape; used for typeahead.

### Acceptance

- [ ] Endpoint documented in OpenAPI  
- [ ] Seeded brand list (or empty list + free text only — say which)  
- [ ] Flutter can replace mock `_brands` array  

---

## 2. Listing taxonomy ↔ catalog CUIDs (mismatch)

### Problem

`GET /api/v1/catalog/listing-taxonomy` returns **slug-style** category ids:

```json
{ "id": "mode", "sizeSchema": "clothing", "subcategories": ["women", "men", …] }
```

`GET /api/v1/catalog/categories` returns **CUIDs**:

```json
{ "id": "cmu62hs80000avi3drpfoh40i", "slug": "fashion", … }
```

Sell create must send **CUIDs**. Flutter maps CUID slug → local size schema with a fragile bridge. That breaks when new categories appear.

### Requested fix (pick one)

**Option A (preferred):** Extend taxonomy to use Nest category ids:

```json
{
  "categories": [
    {
      "id": "cmu62hs80000avi3drpfoh40i",
      "slug": "fashion",
      "sizeSchema": "clothing",
      "subcategories": [
        { "id": "cmu62hsnr000cvi3de0kv9ayy", "slug": "fashion-women", "sizeSchema": "clothing" }
      ]
    }
  ],
  "sizeOptions": { "clothing": ["XS", "S", "M", …], "phoneStorage": ["32 GB", …] },
  "colors": ["White", "Black", …]
}
```

**Option B:** Keep slug taxonomy, but document a stable `slug → sizeSchema` map and guarantee catalog slugs always match.

### Acceptance

- [ ] Flutter can derive size/color options from taxonomy using the same ids sent on create  
- [ ] No client-side hardcoded size lists required  

---

## 3. Discount / compare-at price (confirm contract)

### Flutter UX (shipped)

1. Seller enters **net** (“Your price — what you receive”).  
2. Toggle **“Apply a discount”**.  
3. When on, show **Previous / compare-at price** (`compareAtPriceGnf`).  
4. Client validates: `compareAtPriceGnf > displayPriceGnf` where  
   `displayPriceGnf = round(netPriceGnf × (1 + commissionRate))`.  
5. Payload includes `discountEnabled: true` and `compareAtPriceGnf`.

### Please confirm Nest rules

| Rule | Expected |
|------|----------|
| `compareAtPriceGnf` compared to | **Buyer display** (`displayPriceGnf`), not net |
| When `discountEnabled=false` | Ignore / null `compareAtPriceGnf` |
| When `discountEnabled=true` and compareAt missing/invalid | `400` + `VALIDATION_ERROR` with field detail |
| Listing card / PDP | Return `displayPriceGnf` + optional `compareAtPriceGnf` for strikethrough |

OpenAPI already has `discountEnabled` + `compareAtPriceGnf` on `CreateListingDto` — please ensure service validation matches the table above (not “compareAt > net”).

### Acceptance

- [ ] Create with discount succeeds when compareAt > display  
- [ ] Create fails clearly when compareAt ≤ display  
- [ ] GET listing returns both prices for buyer UI  

---

## 4. Title (confirm only)

`title` is required (min 3, max 120). Flutter now collects it explicitly on Details (no longer inferred-only from description).

Please confirm error payload includes field hints, e.g.:

```json
{
  "statusCode": 400,
  "code": "VALIDATION_ERROR",
  "message": "…",
  "details": ["title must be longer than or equal to 3 characters"]
}
```

---

## 5. Photos / cover thumbnail (confirm)

| Rule | Expected |
|------|----------|
| Min 1 / max 8 | Already in handoffs |
| Cover | First attached media (`sortOrder: 0`) |
| Upload path | Sign Cloudinary → upload → `POST /listings/:id/media` with `publicId`, `url`, `mimeType` |

Flutter listing preview uses the **first local photo** before publish; after publish it uses `media[0].url`.

Please confirm destroy/replace behaviour stays as in Cloudinary catalogue docs.

---

## 6. Already OK (no action unless broken)

| Item | Status |
|------|--------|
| `conditionCode` enum | Matches Flutter sheet |
| `netPriceGnf` + commission → `displayPriceGnf` | Documented |
| Omit `destination` on create | Flutter complies |
| `GET /catalog/listing-taxonomy` | Exists (needs id alignment — §2) |
| `GET /catalog/categories` | Exists (destination seed issue — separate MD) |

---

## Reproduce / smoke

```bash
HOST=http://62.84.179.126:3010

# Taxonomy (exists)
curl -sS "$HOST/api/v1/catalog/listing-taxonomy" | jq 'keys'

# Brands (expected missing today → 404)
curl -sS -o /dev/null -w "%{http_code}\n" "$HOST/api/v1/catalog/brands?q=ap"

# Categories (CUIDs)
curl -sS "$HOST/api/v1/catalog/categories" | jq '[.[] | select(.parentId==null) | {id,slug,destination}]'
```

---

## Priority

| Priority | Item |
|----------|------|
| P0 | Confirm discount validation vs **display** price |
| P0 | Taxonomy ids aligned with catalog CUIDs (§2) |
| P1 | `GET /catalog/brands` (or document “free text only, no suggest”) |
| P2 | Richer size/color seed if taxonomy expands |

---

## Flutter after your fixes

1. Drop hardcoded brand list → brands API (or free-text-only mode).  
2. Drop local size/color tables → live taxonomy keyed by category CUID.  
3. Keep title + discount toggle UX; rely on Nest validation codes for edge cases.  
4. Continue omitting `destination` on create.
