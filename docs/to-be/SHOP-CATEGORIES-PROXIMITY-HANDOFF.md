# Flutter → Nest — Proximity shop categories (commerce local) handoff

**From:** Flutter mobile (signup + become-seller “Commerce local”) + Admin Next.js catalog ops  
**To:** Nest BE (+ Admin web surfaces)  
**Date:** 2026-10-02  
**Priority:** **P0** — signup dropdown is **hardcoded**; product needs **admin-managed** categories in DB  
**Env:** `http://62.84.179.126:3010`  
**Base path:** `/api/v1`  
**Locales:** `x-locale: FR` | `EN`  
**Auth:**  
- Public / consumer read: optional Bearer (same as zones — **anonymous GET allowed**)  
- Admin write: Admin JWT only  

**Reply pack expected:**  
`docs/from-be/shop-categories-mobile-flutter-handoff.md`  
(+ short admin web notes, or fold into `admin-web-nextjs-handoff.md`)

**Related (do not conflate):**  
- `docs/from-be/auth-mobile-flutter-handoff.md` — `signupPath=commerceLocal`, field `shopCategoryId`  
- `docs/from-be/listings-mobile-flutter-handoff.md` — **listing** taxonomy (`categoryId` / `subcategoryId` on products)  
- `docs/from-be/admin-web-nextjs-handoff.md` — admin catalog write today is **listing** categories + zones  
- SRS `docs/srs/02-actors-and-roles.md` — commerceLocal → proximite → quartierBoutiques  

---

## 0. Why this exists (read first)

### 0.1 Product problem

When a user registers or upgrades as **Commerce local** (neighborhood / proximité shop), Flutter asks for a **shop category** (“Épicerie sèche”, “Boissons & snacks”, …).

**Today:**

| Layer | Reality |
|-------|---------|
| Flutter | Hardcoded FR labels in `signup_screen.dart` / `become_seller_screen.dart` |
| Flutter → API | Maps labels → fixed slugs via `AuthFieldMap.proximityCategorySlugs` |
| Nest auth handoff | Documents the **same four hard-coded slugs** |
| Admin | **No** CRUD UI / API for these shop types |
| Catalog | `GET /catalog/listing-taxonomy` returns **product** categories (Mode, …) — **wrong domain** |
| Probed | `GET /catalog/shop-categories` → **404** |

Ops / growth need to **add, rename, deactivate** proximity shop types **without an app release**. That requires a **DB-backed catalog** + **admin CRUD** + **public list** for mobile.

### 0.2 Critical domain split (do not miss)

There are **two different “category” concepts**. Mixing them will break signup, Excel import, and discovery.

| Concept | Who uses it | Example | Storage today |
|---------|-------------|---------|---------------|
| **Listing category / subcategory** | Product listings, Excel columns `categoryId` | Mode → Hommes | `GET /catalog/listing-taxonomy` |
| **Shop category (proximity type)** | Commerce local **seller profile** at signup / become-shop | Épicerie sèche | Hardcoded slugs |

**Shop category answers:** “What kind of neighborhood shop is this?”  
**Listing category answers:** “What product aisle is this SKU in?”

A proximité épicerie may later list items under many **listing** categories (rice, soap, …). Shop category stays on the **seller/shop** record.

### 0.3 Scope of this handoff

**In scope**

1. Nest model + migrations for proximity shop categories  
2. Public catalog list for Flutter (and future web)  
3. Admin CRUD (create / update / deactivate / reorder)  
4. Validation on `POST /auth/register` (`signupPath=commerceLocal`) and `POST /me/seller/shop` (`shopKind=PROXIMITE`)  
5. Seed of the current four values + **backward-compatible** slug acceptance  
6. Admin UI contract (section under catalog — not a separate “local store app”)  
7. Errors, OpenAPI, acceptance tests, curl matrix  

**Out of scope (explicit)**

- Changing listing taxonomy / Excel `categoryId` product columns  
- Buyer browse filters by shop category (nice-to-have later — optional §12)  
- Multi-select shop categories (v1 = **exactly one** required for proximité)  
- Categories for `boutique` STANDARD or `ENSEIGNE` (v1 = **PROXIMITE only**)  
- Flutter implementation (Flutter will wire after `from-be` reply)

---

## 1. Product rules (non-negotiable)

1. **Audience:** only `signupPath=commerceLocal` / `shopKind=PROXIMITE`. Other seller kinds must **not** send `shopCategoryId` (or Nest ignores / rejects — pick **reject with `SHOP_CATEGORY_NOT_ALLOWED`** if sent for non-proximité).  
2. **Required for proximité:** register + become-shop without a valid **active** shop category → `400 VALIDATION_ERROR` / `SHOP_CATEGORY_REQUIRED`.  
3. **Active only in mobile dropdown:** Flutter lists `isActive=true` only. Inactive categories remain on existing shops for history but **cannot** be newly selected.  
4. **Stable identity:** prefer **CUID `id`** as primary FK on seller profile; keep **unique `slug`** for human/debug and migration from today’s handoff.  
5. **Flutter migration:** accept **both** for a deprecation window:  
   - Preferred: `shopCategoryId` = CUID from catalog  
   - Legacy: slug string (`epicerie_seche`, …) still resolves to the seeded row  
   Document which field name stays (`shopCategoryId` already used — keep the name; value becomes CUID once Flutter ships).  
6. **i18n:** store `nameFr` + `nameEn`; Flutter picks via `x-locale`.  
7. **Slug rules:** lowercase snake_case `[a-z0-9_]+`, unique, **immutable after create** (or only changeable by admin with warning — prefer **immutable**).  
8. **Soft delete / deactivate:** never hard-delete rows referenced by sellers; set `isActive=false`.  
9. **Sort order:** admin-controlled `sortOrder` ascending; Flutter sorts by that then name.  
10. **Timestamps:** ISO-8601 `Z`. Currency N/A.  

---

## 2. Domain model

### 2.1 Entity `ShopCategory` (suggested Prisma / table name)

```ts
type ShopCategoryKind = "PROXIMITE"; // extensible later: STANDARD | ENSEIGNE

type ShopCategory = {
  id: string;                 // cuid
  kind: ShopCategoryKind;     // v1 always PROXIMITE
  slug: string;               // unique globally or unique per kind — prefer unique per kind
  nameFr: string;
  nameEn: string;
  descriptionFr: string | null;
  descriptionEn: string | null;
  iconKey: string | null;     // optional Material/asset key for admin+app later
  sortOrder: number;          // default 0
  isActive: boolean;          // default true
  createdAt: string;
  updatedAt: string;
};
```

### 2.2 Seller profile link

On proximity seller profile / shop details (wherever `shopCategoryId` lives today):

```ts
// SellerProfile or ShopDetails
shopCategoryId: string | null;  // FK → ShopCategory.id (CUID)
// Optional denormalized for admin lists:
// shopCategorySlug: string | null;
```

**Migration from current slug storage:**

| If BE today stores… | Do this |
|---------------------|---------|
| slug string column | Add FK column; backfill from seed by slug; keep slug column temporarily **or** replace value with CUID after dual-read |
| nothing / unused | Add FK; require on new proximité creates |
| enum | Expand to FK table; map enum → seed rows |

### 2.3 Seed data (must match current Flutter / auth handoff)

Insert on migrate (idempotent upsert by `slug` + `kind=PROXIMITE`):

| sortOrder | slug | nameFr | nameEn |
|-----------|------|--------|--------|
| 10 | `epicerie_seche` | Épicerie sèche | Dry grocery |
| 20 | `boutique_de_proximite` | Boutique de proximité | Neighborhood shop |
| 30 | `boissons_snacks` | Boissons & snacks | Drinks & snacks |
| 40 | `produits_du_quotidien` | Produits du quotidien | Everyday essentials |

These four **must** exist in every env (dev / staging / prod) so current app builds keep working during Flutter cutover.

---

## 3. Public catalog API (Flutter)

Mirror zones style: anonymous-friendly, locale-aware labels.

### 3.1 List active shop categories

```http
GET /api/v1/catalog/shop-categories?kind=PROXIMITE
x-locale: FR
```

**Query**

| Param | Required | Default | Notes |
|-------|----------|---------|-------|
| `kind` | no | `PROXIMITE` | Only supported value in v1 |
| `includeInactive` | no | `false` | Consumer clients must **not** set true |

**200**

```json
{
  "items": [
    {
      "id": "clxxxxxxxx",
      "kind": "PROXIMITE",
      "slug": "epicerie_seche",
      "nameFr": "Épicerie sèche",
      "nameEn": "Dry grocery",
      "descriptionFr": null,
      "descriptionEn": null,
      "iconKey": null,
      "sortOrder": 10,
      "isActive": true
    }
  ]
}
```

Also accept a bare array `[...]` **or** `{ "categories": [...] }` — pick **one** and document in from-be. Flutter will follow **`{ items: [...] }`** preferred (same as many admin lists).

**Sorting:** `sortOrder ASC`, then `nameFr ASC` (or locale name).

**Empty list:** `200 { "items": [] }` — **never** invent defaults in Nest after seed ships. Empty before seed = deploy bug.

### 3.2 Optional get-by-id (nice)

```http
GET /api/v1/catalog/shop-categories/:id
```

**404** `SHOP_CATEGORY_NOT_FOUND` if missing.  
**404** or **410** if inactive when called from public (prefer 404).

### 3.3 Resolve helper for register (internal)

Register / become-shop must resolve:

```
input shopCategoryId
  → if looks like cuid AND row exists (kind=PROXIMITE, isActive) → OK
  → else if matches slug of PROXIMITE row (active) → OK (legacy)
  → else → SHOP_CATEGORY_INVALID | SHOP_CATEGORY_INACTIVE | SHOP_CATEGORY_NOT_FOUND
```

Document the resolution order in from-be.

---

## 4. Wire into auth & become-seller (mandatory)

### 4.1 Register — commerceLocal

```http
POST /api/v1/auth/register
{
  "registrationSessionId": "…",
  "signupPath": "commerceLocal",
  "phone": "+224623001122",
  "password": "••••••••",
  "displayName": "Épicerie Kipé",
  "shopName": "Épicerie Kipé",
  "zoneId": "<zone cuid>",
  "address": "Kipé, marché central",
  "shopCategoryId": "<cuid OR legacy slug>",
  "shopDescription": "…",
  "logoMediaId": "fripcash/shops/…/logo",
  "termsAccepted": true,
  "marketingOptIn": true,
  "locale": "fr"
}
```

| Rule | Error |
|------|-------|
| Missing `shopCategoryId` | `400` `SHOP_CATEGORY_REQUIRED` |
| Unknown id/slug | `400` `SHOP_CATEGORY_NOT_FOUND` |
| Inactive category | `400` `SHOP_CATEGORY_INACTIVE` |
| Wrong kind (if somehow STANDARD) | `400` `SHOP_CATEGORY_INVALID` |
| Sent on `acheteur` / `particulier` / `boutique` / `grandeSurface` | `400` `SHOP_CATEGORY_NOT_ALLOWED` |

Persist **FK to CUID** even if client sent slug.

### 4.2 Become shop — PROXIMITE

```http
POST /api/v1/me/seller/shop
Authorization: Bearer …
{
  "shopKind": "PROXIMITE",
  "name": "Épicerie Kipé",
  "zoneId": "<cuid>",
  "address": "…",
  "logoMediaId": "…",
  "description": "…",
  "shopCategoryId": "<cuid OR slug>"
}
```

Same validation table as §4.1.  
`STANDARD` / `ENSEIGNE`: omit `shopCategoryId`; if present → `SHOP_CATEGORY_NOT_ALLOWED`.

### 4.3 GET /me exposure

```json
{
  "seller": {
    "shopKind": "PROXIMITE",
    "shopCategoryId": "clxxxxxxxx",
    "shopCategory": {
      "id": "clxxxxxxxx",
      "slug": "epicerie_seche",
      "nameFr": "Épicerie sèche",
      "nameEn": "Dry grocery"
    }
  }
}
```

Flutter needs at least `shopCategoryId` + display name for profile/settings later. Nested object preferred.

### 4.4 PATCH seller profile (optional but recommended)

If `PATCH /me/seller/profile` exists (settings handoff), allow changing category while active:

```http
PATCH /api/v1/me/seller/profile
{ "shopCategoryId": "<cuid>" }
```

Only for `PROXIMITE`; same validation. Inactive selection forbidden.

---

## 5. Admin API (CRUD)

All routes: **Admin JWT**. Pattern aligned with zones / listing categories.

### 5.1 List (admin — includes inactive)

```http
GET /api/v1/admin/catalog/shop-categories?kind=PROXIMITE&q=&isActive=
```

**200** `{ "items": ShopCategory[], "total": number }`

### 5.2 Create

```http
POST /api/v1/admin/catalog/shop-categories
{
  "kind": "PROXIMITE",
  "slug": "pharmacie_de_quartier",
  "nameFr": "Pharmacie de quartier",
  "nameEn": "Neighborhood pharmacy",
  "descriptionFr": "optional",
  "descriptionEn": "optional",
  "iconKey": null,
  "sortOrder": 50,
  "isActive": true
}
```

| Rule | Error |
|------|-------|
| Duplicate slug (same kind) | `409` `SHOP_CATEGORY_SLUG_EXISTS` |
| Invalid slug format | `400` `VALIDATION_ERROR` |
| Missing nameFr/nameEn | `400` `VALIDATION_ERROR` |

**201** → created `ShopCategory`.

### 5.3 Update

```http
PATCH /api/v1/admin/catalog/shop-categories/:id
{
  "nameFr": "…",
  "nameEn": "…",
  "descriptionFr": "…",
  "descriptionEn": "…",
  "iconKey": "…",
  "sortOrder": 15,
  "isActive": false
}
```

| Field | Editable |
|-------|----------|
| `nameFr` / `nameEn` | yes |
| `description*` | yes |
| `iconKey` | yes |
| `sortOrder` | yes |
| `isActive` | yes |
| `slug` | **no** → `400` `SHOP_CATEGORY_SLUG_IMMUTABLE` if sent |
| `kind` | **no** |

**200** → updated row.

### 5.4 Deactivate shortcut (optional)

```http
POST /api/v1/admin/catalog/shop-categories/:id/deactivate
POST /api/v1/admin/catalog/shop-categories/:id/activate
```

Equivalent to PATCH `isActive`.

### 5.5 Delete

```http
DELETE /api/v1/admin/catalog/shop-categories/:id
```

| Condition | Behavior |
|-----------|----------|
| Zero sellers reference it | Soft-delete **or** hard-delete — prefer soft (`isActive=false` + `deletedAt`) |
| Sellers still reference it | `409` `SHOP_CATEGORY_IN_USE` — force deactivate instead |

**Do not** hard-delete seed rows in prod without migration plan.

### 5.6 Reorder (optional convenience)

```http
PUT /api/v1/admin/catalog/shop-categories/reorder
{
  "kind": "PROXIMITE",
  "orderedIds": ["id1", "id2", "id3", "id4"]
}
```

Assigns `sortOrder` = index * 10.

---

## 6. Admin UI placement (Next.js)

**Not** a separate “local store app.”  

In Admin → **Catalog** (alongside Zones + Listing categories):

```
Catalog
├── Zones
├── Listing categories          ← product taxonomy (existing)
└── Proximity shop types        ← NEW section (this handoff)
```

### 6.1 Screen: Proximity shop types

| Element | Behavior |
|---------|----------|
| Table | name (locale), slug, sortOrder, active, #sellers using (optional), updatedAt |
| Create | Modal/form §5.2 |
| Edit | Inline or drawer §5.3 |
| Toggle active | Confirm if `SHOP_CATEGORY_IN_USE` count > 0 (“existing shops keep the type; new signups cannot select”) |
| Empty state | “No types — seed missing?” + link to docs |

### 6.2 Seller verification / KYC screens

When reviewing proximité applications, show shop category label from FK (not raw slug).

---

## 7. Error catalog

| Code | HTTP | When |
|------|------|------|
| `SHOP_CATEGORY_REQUIRED` | 400 | Proximité create without category |
| `SHOP_CATEGORY_NOT_FOUND` | 400/404 | Unknown id/slug |
| `SHOP_CATEGORY_INACTIVE` | 400 | Selecting deactivated type |
| `SHOP_CATEGORY_INVALID` | 400 | Wrong kind / malformed |
| `SHOP_CATEGORY_NOT_ALLOWED` | 400 | Sent for non-proximité path |
| `SHOP_CATEGORY_SLUG_EXISTS` | 409 | Admin create duplicate |
| `SHOP_CATEGORY_SLUG_IMMUTABLE` | 400 | Admin tried to change slug |
| `SHOP_CATEGORY_IN_USE` | 409 | Hard-delete blocked |
| `CAPABILITY_DENIED` / `FORBIDDEN` | 403 | Non-admin on admin routes |
| `VALIDATION_ERROR` | 400 | Field rules |

Messages must honor `x-locale`.

---

## 8. Flutter contract (what we will wire after from-be)

| UI | Call |
|----|------|
| Signup step (commerce local) dropdown | `GET /catalog/shop-categories?kind=PROXIMITE` |
| Become seller (commerce local) dropdown | same |
| Submit register / become shop | `shopCategoryId: <item.id>` (CUID) |
| Fallback while BE ships | Keep current hardcoded list **only** until from-be says dual-read ready — then remove hardcode |

**Done when Flutter:** empty Nest list → empty dropdown + block submit (no invented cats).

---

## 9. OpenAPI / docs deliverables

Please publish:

1. `ShopCategory` schema  
2. Public `GET /catalog/shop-categories`  
3. Admin CRUD paths  
4. Updated `RegisterDto` / `CreateShopDto` notes for `shopCategoryId` (CUID preferred, slug legacy)  
5. Updated auth from-be § Proximité categories → **point to catalog**, deprecate static table  
6. Seed checklist in deploy runbook  

---

## 10. Acceptance tests (BE must pass)

### 10.1 Seed

- [ ] Fresh migrate → exactly the four seed rows exist, `isActive=true`  
- [ ] Re-running seed is idempotent (no duplicates)

### 10.2 Public list

- [ ] `GET /catalog/shop-categories` returns seeds sorted  
- [ ] Deactivated row **absent** from public list  
- [ ] `x-locale=EN` does not change payload shape (Flutter picks `nameEn`)

### 10.3 Register

- [ ] commerceLocal + valid CUID → 201/200 + `GET /me` shows category  
- [ ] commerceLocal + legacy slug `epicerie_seche` → succeeds (compat window)  
- [ ] commerceLocal without category → `SHOP_CATEGORY_REQUIRED`  
- [ ] commerceLocal + inactive id → `SHOP_CATEGORY_INACTIVE`  
- [ ] boutique + shopCategoryId → `SHOP_CATEGORY_NOT_ALLOWED`  

### 10.4 Admin

- [ ] Create new type → appears in public list  
- [ ] Deactivate → disappears from public list; existing seller still has FK  
- [ ] Duplicate slug → 409  
- [ ] Non-admin → 401/403  

### 10.5 Curl smoke (staging)

```bash
HOST=http://62.84.179.126:3010

# Public list
curl -sS "$HOST/api/v1/catalog/shop-categories?kind=PROXIMITE" -H 'x-locale: FR'

# Admin create (replace TOKEN)
curl -sS -X POST "$HOST/api/v1/admin/catalog/shop-categories" \
  -H "Authorization: Bearer $ADMIN_TOKEN" -H 'Content-Type: application/json' -H 'x-locale: FR' \
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

## 11. Migration & rollout plan

| Phase | BE | Flutter | Admin |
|-------|----|---------|-------|
| A | Table + seed + public GET + dual-resolve (CUID\|slug) on register/shop | unchanged (still sends slugs) | optional |
| B | Admin CRUD live | Switch dropdown to GET; send **CUID** | Catalog section ships |
| C | Stop accepting unknown free-text; slug compat optional keep 1 release | Remove hardcoded `_proximityCategories` | — |
| D | (optional) drop slug-only column if fully on FK | — | — |

**Compat window:** keep slug resolve ≥ **1 mobile release** after Flutter ships CUID.

---

## 12. Optional follow-ups (not blocking v1)

| Idea | Notes |
|------|-------|
| Filter quartier feed by shop category | `GET /listings?destination=QUARTIER_BOUTIQUES&shopCategoryId=` |
| Icon assets | `iconKey` → CDN mapping |
| Categories for STANDARD boutique | Separate `kind` — new handoff |
| Analytics | signup conversion by category |

---

## 13. Explicit non-goals / anti-patterns

1. **Do not** reuse `listing-taxonomy` rows as shop categories.  
2. **Do not** ask Flutter to keep inventing labels after Phase B.  
3. **Do not** allow consumer self-create of shop categories.  
4. **Do not** hard-delete categories that have sellers.  
5. **Do not** require OTP / payment changes for this feature.  
6. **Do not** change zone catalog in this ticket.  

---

## 14. Decision summary for BE (checklist)

| Decision | Our recommendation | Confirm in from-be |
|----------|--------------------|--------------------|
| Primary key sent by Flutter | **CUID `id`** | ☐ |
| Legacy slug support | **Yes**, ≥1 release | ☐ |
| Public path | `GET /catalog/shop-categories` | ☐ |
| Admin path prefix | `/admin/catalog/shop-categories` | ☐ |
| Kind enum v1 | `PROXIMITE` only | ☐ |
| Response envelope | `{ items: [] }` | ☐ |
| Slug mutable? | **No** | ☐ |
| Delete policy | Soft / deactivate; `IN_USE` on hard delete | ☐ |
| GET /me includes nested category | **Yes** | ☐ |

---

## 15. Questions for BE (answer in from-be)

1. Is `shopCategoryId` today stored as slug, enum, or unused?  
2. Preferred response envelope for public list?  
3. Soft-delete column (`deletedAt`) vs `isActive` only?  
4. Will admin listing-categories UI get a sibling route in the same Next app?  
5. Any plan to localize slug display differently per region (Conakry-only vs national)?  

---

**End of handoff.**  
Please implement Phase A+B, publish `docs/from-be/shop-categories-mobile-flutter-handoff.md`, and we will remove Flutter hardcoding and wire the live dropdown.
