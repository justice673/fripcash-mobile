# Listings handoff — Flutter (mobile)

**Audience:** Flutter team (sell wizard, My listings, discovery, Excel, product library)  
**API base:** `/api/v1` · Bearer from secure storage  
**Status:** Shipped on Nest  
**Related:** [listings-destinations-fe-handoff.md](./listings-destinations-fe-handoff.md) · [listing-pricing-fe-handoff.md](./listing-pricing-fe-handoff.md) · [auth-mobile-flutter-handoff.md](./auth-mobile-flutter-handoff.md)

Replace mock sell flows with these contracts. Gate sell UI with `GET /me` → `seller.capabilities`.

---

## Breaking changes vs mock / old API

| Old / mock | Now |
|------------|-----|
| Client picks destination | **Never send `destination`** — server sets from seller profile |
| Buyer sees / stores net | Cards & PDP use **`displayPriceGnf` only** |
| Copy opens edit same id | `POST /listings/:id/copy` → **new** `draftId` |
| Hardcoded 8% / 5% | `GET /platform/commission-rates` → `effectiveForMe` |
| Colors only in description | Persist `colors: string[]` |
| No unpublish | `POST …/hide` → `HIDDEN` |
| Excel fake delay | `POST …/excel-import` with `rows[]` |

---

## Preload (after login / before sell)

```
GET /api/v1/me
GET /api/v1/catalog/categories          // sell Step 1 — all roots/children
GET /api/v1/catalog/listing-taxonomy    // sizes / colors / wizard labels
GET /api/v1/platform/commission-rates   // Authorization if seller
GET /api/v1/catalog/zones               // if needed for profile
```

| `me.seller.capabilities` | UI |
|--------------------------|-----|
| `createListing` | Sell tab / publish |
| `excelImport` | Boutique Excel screen |
| `productLibrary` | Proximité library |
| `verificationStatus == pending` | Banner; block publish |

---

## Destination (read-only for app)

| Seller | Destination (server) | Home universe |
|--------|----------------------|---------------|
| Particulier | `SECONDE_MAIN` | Seconde main |
| Boutique standard | `ARTICLES_NEUFS` | Articles neufs |
| Proximité | `QUARTIER_BOUTIQUES` | Quartier (+ badge `Proximité`) |
| Enseigne | `ENSEIGNES` | Enseignes |

Offers (“demander”): hide for enseigne even if toggle shown.

### Categories vs destination (sell Step 1)

| Question | Answer |
|----------|--------|
| May any seller use any active category? | **Yes** (no destination allow-list on categories) |
| What is `Category.destination`? | Optional **browse hint** only; seeded roots are `null` |
| Filter sell Step 1 by destination? | **No** |
| Canonical sell taxonomy? | `GET /catalog/categories` (CUIDs). `GET /catalog/listing-taxonomy` is sizes/colors/wizard labels only |

---

## Create wizard → API

### Recommended sequence

```
1. Visual category step → map to categoryId / subcategoryId (taxonomy)
2. Photos → create draft listing → POST /listings/:id/media (1…8)
3. Details → PATCH listing (or create with all fields)
4. Price → show breakdown from effectiveForMe → PATCH netPriceGnf / publish
```

**Minimal create (draft):**

```http
POST /api/v1/listings
Authorization: Bearer …
```

```json
{
  "title": "Robe fleurie vintage",
  "description": "Robe fleurie en excellent état.",
  "categoryId": "mode",
  "subcategoryId": "women",
  "conditionCode": "veryGood",
  "brand": "Zara",
  "size": "M",
  "colors": ["Red", "Black"],
  "netPriceGnf": 41667,
  "stock": 3,
  "shippingCostGnf": 5000,
  "worldwideShipping": false,
  "negotiable": true,
  "publish": false
}
```

Then:

```http
POST /api/v1/listings/{id}/media
{ "publicId": "…", "url": "https://…", "mimeType": "image/jpeg", "sortOrder": 0 }

POST /api/v1/listings/{id}/publish
```

Or set `"publish": true` on create after media exist (media usually attached after create).

### Field rules

| Field | Notes |
|-------|--------|
| `title` | Required, 3…120 — do **not** only derive from description |
| `description` | Required, max 1000 |
| `conditionCode` | `newWithTag` \| `newWithoutTag` \| `veryGood` \| `good` \| `satisfactory` |
| `stock` | Prefer over `quantity`; ≥ 0 |
| `shippingCostGnf` | Default 5000; **0** for proximité if omitted |
| `colors` | From taxonomy list (`White`, `Black`, …) |
| `size` | From taxonomy sizeOptions for category schema |
| `destination` | **Omit** |

Shops: server may force condition → Neuf (`newWithoutTag`).

### Seller response (trust these)

```json
{
  "id": "…",
  "destination": "SECONDE_MAIN",
  "status": "draft",
  "netPriceGnf": 41667,
  "displayPriceGnf": 45000,
  "commissionRate": 0.08,
  "commissionGnf": 3333,
  "condition": "Très bon état",
  "conditionCode": "veryGood",
  "stock": 3,
  "sellerType": "particulier",
  "badge": null,
  "media": [{ "mediaId": "…", "url": "…", "sortOrder": 0 }]
}
```

---

## Price step UI (seller)

```
GET /platform/commission-rates → effectiveForMe, effectivePercent

display = round(net * (1 + effectiveForMe))
commission = display - net
```

Show:

1. Votre prix = net  
2. Commission FripCash (X%) = +commission  
3. **L’acheteur voit** = display  

Buyer cards/PDP: **only display**. Never show net/commission on discovery.

After save, use API snapshotted `displayPriceGnf` / `commissionGnf` (admin rate changes don’t rewrite old listings until price edit).

---

## My listings

```http
GET /api/v1/me/listings?status=ACTIVE&cursor=&limit=20
GET /api/v1/me/listings/{id}
```

Statuses: `DRAFT` | `ACTIVE` | `SOLD_OUT` | `HIDDEN` | `ARCHIVED` …

| Action | Call |
|--------|------|
| Edit fields | `PATCH /listings/:id` |
| Quick price | `POST /listings/:id/price` `{ "netPriceGnf": 40000 }` |
| Stock ± | `POST /listings/:id/stock` `{ "delta": -1 }` or `{ "set": 10 }` |
| Unpublish | `POST /listings/:id/hide` |
| Publish draft | `POST /listings/:id/publish` |
| Copy | `POST /listings/:id/copy` → open **new** `draftId` |
| Delete | `DELETE /listings/:id` (409 if open orders) |

---

## Discovery (buyer)

```http
GET /api/v1/listings?destination=SECONDE_MAIN&q=&minPrice=&maxPrice=&inStockOnly=true&sort=newest&cursor=&limit=20
GET /api/v1/listings/{id}
```

Use `displayPriceGnf`, `badge`, `sellerType`, `media[0]`. Response: `{ items, nextCursor }`.

---

## Excel (boutique / proximité / enseigne)

1. Parse `catalogue_boutique.xlsx` on device → rows  
2. POST:

```json
POST /api/v1/me/seller/tools/excel-import
{
  "rows": [
    {
      "sku": "SKU-001",
      "title": "Eau 1.5L",
      "netPriceGnf": 3000,
      "stock": 50,
      "categoryId": "grocery"
    }
  ]
}
```

3. Show `{ imported, updated, failed, errors[] }`  
4. Drafts appear in `GET /me/listings?status=DRAFT` → attach photos → publish

---

## Product library (proximité only)

```http
GET  /me/seller/tools/library
POST /me/seller/tools/library
POST /me/seller/tools/library/publish
{
  "items": [
    {
      "libraryProductId": "…",
      "netPriceGnf": 3000,
      "stock": 120,
      "alwaysAvailable": false
    }
  ]
}
```

`alwaysAvailable: true` → stock `9999`. Creates live quartier listings (shipping 0, Neuf, badge Proximité).

---

## Vacation

```http
POST /me/seller/tools/vacation
{ "enabled": true }
```

Hides all `ACTIVE` → `HIDDEN`. Disable restores `ACTIVE`.

---

## Taxonomy cheat sheet

```http
GET /api/v1/catalog/categories
GET /api/v1/catalog/listing-taxonomy
GET /api/v1/catalog/brands?q=ap&limit=30
```

### Listing taxonomy (CUID-aligned)

`GET /catalog/listing-taxonomy` returns **live category CUIDs** (same ids as `/catalog/categories`):

```json
{
  "categories": [
    {
      "id": "cmu62hs80000avi3drpfoh40i",
      "slug": "fashion",
      "nameFr": "Mode",
      "nameEn": "Fashion",
      "sizeSchema": "clothing",
      "subcategories": [
        {
          "id": "cmu62hsnr000cvi3de0kv9ayy",
          "slug": "fashion-women",
          "nameFr": "Femmes",
          "nameEn": "Women",
          "sizeSchema": "clothing"
        }
      ]
    }
  ],
  "sizeOptions": { "clothing": ["XS", "S", "M", "…"], "phoneStorage": ["32 GB", "…"], "none": [] },
  "colors": ["White", "Black", "…"]
}
```

Use `categories[].id` / `subcategories[].id` directly on create — **no slug→CUID bridge**.

### Brands

```http
GET /api/v1/catalog/brands?q=ap&limit=30
→ { "items": [{ "id": "brand_apple", "name": "Apple", "slug": "apple" }] }
```

Public. Platform-seeded suggest list (~25 brands). Create still accepts free-text `brand` (max 80) for custom / unbranded.

### Discount (confirmed)

| Rule | Nest behaviour |
|------|----------------|
| Compare-at vs | **`displayPriceGnf`** = `round(net × (1 + commissionRate))`, **not** net |
| `discountEnabled=false` | Forces `compareAtPriceGnf = null` |
| `discountEnabled=true` + missing/invalid compareAt | `400` `VALIDATION_ERROR` |
| Public listing DTO | `displayPriceGnf` + `compareAtPriceGnf` + `discountEnabled` for strikethrough |

### Title (confirmed)

Required min 3 / max 120. Class-validator failures return:

```json
{
  "statusCode": 400,
  "code": "VALIDATION_ERROR",
  "message": "…",
  "details": ["title must be longer than or equal to 3 characters"],
  "correlationId": "…",
  "locale": "FR"
}
```

### Photos / cover (confirmed)

| Rule | Behaviour |
|------|-----------|
| Min 1 / max 8 | Enforced on publish / attach |
| Cover | Lowest `sortOrder` (Flutter should send first photo as `sortOrder: 0`) |
| Path | Cloudinary sign → upload → `POST /listings/:id/media` |
| Replace | PATCH media destroys previous Cloudinary `publicId` when it changes |
| Delete | DELETE media destroys Cloudinary asset |

Sell Step 1: load **`/catalog/categories`**, show all active roots — **do not** filter by seller destination.  
Condition FR labels come back as `condition` on listing DTO.

---

## Errors to handle

| Code | UX |
|------|-----|
| `SELLER_VERIFICATION_PENDING` / `VERIFICATION_REJECTED` | Block publish; pending banner |
| `NOT_A_SELLER` | Become seller flow |
| `PHOTOS_REQUIRED` / `PHOTOS_LIMIT` | Photo step |
| `INVALID_NET_PRICE` / `INVALID_STOCK` | Price / stock fields |
| `LISTING_HAS_OPEN_ORDERS` | Soft message; use hide instead of delete |
| `EXCEL_NOT_ALLOWED` / `LIBRARY_NOT_ALLOWED` | Hide those tools |

---

## Flutter checklist

- [ ] Remove client `destination` from create/update  
- [ ] Wire `conditionCode`, `stock`, `colors[]`, `shippingCostGnf`  
- [ ] Price breakdown from `/platform/commission-rates`  
- [ ] Discovery cards = `displayPriceGnf` only  
- [ ] Seller inventory = `/me/listings`  
- [ ] Copy → new draft id (not same listing edit)  
- [ ] Hide / publish / stock / price shortcuts  
- [ ] Excel `rows[]` + library publish  
- [ ] Taxonomy-driven sizes/colors where possible  
