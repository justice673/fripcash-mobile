# Proximity shop categories (Commerce local)

**Status:** Shipped (Phase A+B)  
**Base:** `/api/v1`  
**Public read:** anonymous OK  
**Admin write:** Admin JWT  
**Kind v1:** `PROXIMITE` only  

**Domain split:** this is **shop type** (what kind of neighborhood shop), **not** listing product taxonomy (`GET /catalog/listing-taxonomy`).

---

## Decisions (confirmed)

| Decision | Choice |
|----------|--------|
| Primary key Flutter sends | **CUID `id`** |
| Legacy slug support | **Yes** (≥1 release): `epicerie_seche`, … |
| Public path | `GET /catalog/shop-categories` |
| Admin prefix | `/admin/catalog/shop-categories` |
| Response envelope | `{ items: [...] }` |
| Slug mutable? | **No** → `SHOP_CATEGORY_SLUG_IMMUTABLE` |
| Delete | Soft (`isActive=false` + `deletedAt`); hard-ref → `SHOP_CATEGORY_IN_USE` |
| GET /me nested category | **Yes** |

**Storage today:** `ShopDetails.shopCategoryId` was slug; migration backfills to seed CUIDs + FK.

---

## Seed (fixed IDs)

| id | sortOrder | slug | nameFr | nameEn |
|----|-----------|------|--------|--------|
| `cmkshopcat0epicerieseche` | 10 | `epicerie_seche` | Épicerie sèche | Dry grocery |
| `cmkshopcat0boutiquedeprox` | 20 | `boutique_de_proximite` | Boutique de proximité | Neighborhood shop |
| `cmkshopcat0boissonssnacks` | 30 | `boissons_snacks` | Boissons & snacks | Drinks & snacks |
| `cmkshopcat0produitsquotid` | 40 | `produits_du_quotidien` | Produits du quotidien | Everyday essentials |

Idempotent via migrate SQL + `seedShopCategories`.

---

## Public API

```http
GET /api/v1/catalog/shop-categories?kind=PROXIMITE
x-locale: FR
```

**200** `{ "items": [ { id, kind, slug, nameFr, nameEn, descriptionFr, descriptionEn, iconKey, sortOrder, isActive } ] }`

Inactive / soft-deleted **omitted**. Sort: `sortOrder ASC`, then `nameFr ASC`.

```http
GET /api/v1/catalog/shop-categories/:id
```

Active only; else `404 SHOP_CATEGORY_NOT_FOUND`.

### Resolve order (register / become-shop / PATCH profile)

1. Match `id` (CUID) where `kind=PROXIMITE`, not deleted  
2. Else match `slug` (legacy)  
3. Persist **CUID** on `ShopDetails.shopCategoryId`

| Case | Code |
|------|------|
| Missing on proximité | `SHOP_CATEGORY_REQUIRED` |
| Unknown | `SHOP_CATEGORY_NOT_FOUND` |
| Inactive | `SHOP_CATEGORY_INACTIVE` |
| Wrong kind | `SHOP_CATEGORY_INVALID` |
| Sent on non-proximité | `SHOP_CATEGORY_NOT_ALLOWED` |

---

## Auth / become-seller

```http
POST /auth/register  { "signupPath":"commerceLocal", "shopCategoryId":"<cuid|slug>", … }
POST /me/seller/shop { "shopKind":"PROXIMITE", "shopCategoryId":"<cuid|slug>", … }
PATCH /me/seller/profile { "shopCategoryId":"<cuid|slug>" }  // PROXIMITE only
```

### GET /me

```json
{
  "seller": {
    "shopKind": "PROXIMITE",
    "shopCategoryId": "cmkshopcat0epicerieseche",
    "shopCategory": {
      "id": "cmkshopcat0epicerieseche",
      "slug": "epicerie_seche",
      "nameFr": "Épicerie sèche",
      "nameEn": "Dry grocery"
    }
  }
}
```

---

## Admin API

```http
GET    /admin/catalog/shop-categories?kind=PROXIMITE&q=&isActive=
POST   /admin/catalog/shop-categories
PATCH  /admin/catalog/shop-categories/:id
POST   /admin/catalog/shop-categories/:id/activate|deactivate
DELETE /admin/catalog/shop-categories/:id
PUT    /admin/catalog/shop-categories/reorder
       { "kind":"PROXIMITE", "orderedIds":["…"] }
```

Create body: `kind?`, `slug`, `nameFr`, `nameEn`, `description*`, `iconKey`, `sortOrder`, `isActive`.  
List returns `sellersCount` per row.

### Admin UI (Next.js)

Under **Catalog** → **Proximity shop types** (sibling of Zones + Listing categories).  
Not a separate app. Show label (not raw slug) on seller verification screens.

---

## Flutter wire

| UI | Call |
|----|------|
| Signup / become-seller dropdown | `GET /catalog/shop-categories?kind=PROXIMITE` |
| Submit | `shopCategoryId: item.id` (CUID) |
| Empty list | block submit — do not invent labels |

Legacy slug still accepted until Flutter ships CUID (compat ≥1 release).

---

## Errors

| Code | HTTP |
|------|------|
| `SHOP_CATEGORY_REQUIRED` | 400 |
| `SHOP_CATEGORY_NOT_FOUND` | 400/404 |
| `SHOP_CATEGORY_INACTIVE` | 400 |
| `SHOP_CATEGORY_INVALID` | 400 |
| `SHOP_CATEGORY_NOT_ALLOWED` | 400 |
| `SHOP_CATEGORY_SLUG_EXISTS` | 409 |
| `SHOP_CATEGORY_SLUG_IMMUTABLE` | 400 |
| `SHOP_CATEGORY_IN_USE` | 409 |

---

## Curl

```bash
HOST=http://62.84.179.126:3010

curl -sS "$HOST/api/v1/catalog/shop-categories?kind=PROXIMITE" -H 'x-locale: FR'

curl -sS -X POST "$HOST/api/v1/admin/catalog/shop-categories" \
  -H "Authorization: Bearer $ADMIN_TOKEN" -H 'Content-Type: application/json' \
  -d '{
    "kind":"PROXIMITE",
    "slug":"pharmacie_de_quartier",
    "nameFr":"Pharmacie de quartier",
    "nameEn":"Neighborhood pharmacy",
    "sortOrder":50,
    "isActive":true
  }'
```

---

## Answers to BE questions

1. **Was slug:** `ShopDetails.shopCategoryId` stored slug strings; now FK CUID (backfilled).  
2. **Envelope:** `{ items: [] }`.  
3. **Soft delete:** `isActive` + `deletedAt`.  
4. **Admin UI:** same Next admin Catalog section (sibling route).  
5. **Region:** national list for v1; no Conakry-only filter.
