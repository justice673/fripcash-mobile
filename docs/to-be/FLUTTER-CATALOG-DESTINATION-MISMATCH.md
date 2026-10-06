# Flutter → Nest — Catalog categories vs listing destination

**From:** Flutter mobile  
**To:** Nest BE  
**Date:** 2026-10-02  
**Env:** `http://62.84.179.126:3010`  
**Base path:** `/api/v1`  
**Endpoint:** `GET /api/v1/catalog/categories`  
**Auth:** public (no bearer required for this GET)

**Related:**  
- `docs/from-be/listings-mobile-flutter-handoff.md`  
- `docs/from-be/listings-mobile-flutter-handoff.md`  
- `docs/from-be/auth-mobile-flutter-handoff.md` (seller → destination)

---

## Summary

Seeded catalog roots are tagged **1:1 with a listing destination**. That conflates two different concepts:

| Concept | Owned by | Meaning |
|---------|----------|---------|
| **Listing destination** | Seller profile (`shopKind` / role) | Where the listing appears on home (`SECONDE_MAIN`, `ARTICLES_NEUFS`, `QUARTIER_BOUTIQUES`, `ENSEIGNES`) |
| **Category** | Product taxonomy | What the item *is* (Fashion, Electronics, Home, …) |

Today, a **boutique** seller (`shopKind=STANDARD` → destination `ARTICLES_NEUFS`) only has **Electronics** available if Flutter filters sell categories by destination — because only that root is tagged `ARTICLES_NEUFS` in the catalog.

That is incorrect product behaviour. A boutique sells **brand-new items**; they should still be able to pick Fashion / Home / Sports (etc.) as categories. Destination stays server-owned from the seller profile.

Please adjust catalog seed + validation so categories are **not** destination-exclusive.

---

## Observed live data (`GET /api/v1/catalog/categories`)

Four roots, each locked to a different destination:

| Root slug | nameEn | `destination` | Children |
|-----------|--------|---------------|----------|
| `fashion` | Fashion | `SECONDE_MAIN` | Men, Women, Kids |
| `electronics` | Electronics | `ARTICLES_NEUFS` | Phones, Accessories |
| `home` | Home | `QUARTIER_BOUTIQUES` | Decor, Kitchen |
| `sports-leisure` | Sports and Entertainment | `ENSEIGNES` | *(none)* |

Children inherit the same destination as their parent.

### Seller → destination (already correct)

| Seller | `shopKind` / role | Destination (server-set on listing) |
|--------|-------------------|-------------------------------------|
| Particulier | — | `SECONDE_MAIN` |
| Boutique | `STANDARD` | `ARTICLES_NEUFS` |
| Commerce local | `PROXIMITE` | `QUARTIER_BOUTIQUES` |
| Grande surface | `ENSEIGNE` | `ENSEIGNES` |

### What breaks if FE filters sell cats by `destination`

| Seller type | Roots available today |
|-------------|------------------------|
| Particulier | Fashion only |
| Boutique | Electronics only |
| Proximité | Home only |
| Enseigne | Sports only |

Flutter temporarily shows **all roots** on Sell Step 1 so sellers can publish. That is a workaround until Nest fixes the catalog model / seed.

---

## Expected product rules

1. **Destination is independent of category.**  
   Listing `destination` comes from the seller profile. Client **never** sends `destination` on create/update (already in handoffs).

2. **Any active category may be used by any seller type**, unless Nest explicitly documents a restriction (e.g. grocery-only for proximité).  
   Default: full taxonomy for all marketplace sellers.

3. **Category `destination` field (if kept)** should mean one of:
   - **A)** optional *browse hint* / default filter for home discovery — **not** an exclusive allow-list for create; or  
   - **B)** removed / null on roots used for sell taxonomy; destination filtering for discovery stays on `GET /listings?destination=…`.

4. **Create listing validation** must accept:
   - boutique + `categoryId` = Fashion (or Home, Sports, …) → listing still gets `destination=ARTICLES_NEUFS`
   - particulier + Electronics → still `SECONDE_MAIN`
   - etc.

5. Seed should grow toward a rich shared taxonomy (Fashion, Electronics, Home, Beauty, Baby, Grocery, Sports, …) with children — **shared across destinations**, not one root per destination.

---

## Suggested Nest changes

### A. Seed / admin catalog (required)

- Stop assigning exclusive destinations 1:1 to roots for sell purposes.
- Prefer either:
  - set root/child `destination` to **`null`**, or  
  - allow **multiple destinations** per category if the schema supports it, or  
  - drop `destination` from category and keep destination only on listings / seller profile.
- Ensure boutique / particulier / proximité / enseigne can all resolve valid `categoryId` / `subcategoryId` CUIDs from the same tree.

### B. Create listing validation (required)

On `POST /api/v1/listings` (and draft publish):

- Validate `categoryId` / `subcategoryId` exist and are active.
- Validate subcategory belongs to parent.
- **Do not** reject because `category.destination !== seller.destination`.
- Set listing `destination` from seller profile only.

### C. Discovery (optional, keep as today)

- `GET /listings?destination=ARTICLES_NEUFS` continues to filter by **listing** destination.
- Home category chips may still filter by destination *if* you want destination-specific browse trees — but that must be a deliberate product choice, not an accidental seed side-effect that empties sell UX.

### D. Document the contract (required)

Please confirm in a short reply / handoff update:

| Question | Needed answer |
|----------|----------------|
| May any seller use any active category? | Yes / No + exceptions |
| What does `CatalogCategory.destination` mean? | browse hint / exclusive / unused |
| Should Flutter filter sell Step 1 by destination? | **No** (expected) / Yes + rules |
| Canonical taxonomy source for sell? | `GET /catalog/categories` and/or `GET /catalog/listing-taxonomy` |

---

## Flutter behaviour after your fix

Once Nest is adjusted:

1. Flutter will keep loading sell categories from `GET /catalog/categories`.
2. We will **not** filter roots by seller destination (unless you document a real allow-list).
3. Publish will continue to send Nest **CUIDs** as `categoryId` / `subcategoryId` (never visual mock ids like `femmes` / `mode`).
4. Destination remains omit-on-create; Nest sets it from the seller.

---

## Reproduce

```bash
HOST=http://62.84.179.126:3010

curl -sS "$HOST/api/v1/catalog/categories" | jq '[.[] | select(.parentId == null) | {slug, nameEn, destination}]'
```

Current result: 4 roots, 4 different destinations — one each.

---

## Acceptance checklist

- [ ] Boutique (`ARTICLES_NEUFS`) can create a listing with Fashion / Home / Sports category ids  
- [ ] Particulier (`SECONDE_MAIN`) can create with Electronics / Home / Sports  
- [ ] Listing response `destination` still matches seller profile, not category tag  
- [ ] Seed/docs no longer imply “one root category per destination” for sell  
- [ ] Written confirmation of `CatalogCategory.destination` semantics for FE

---

## Out of scope for this ticket

- Flutter GlobalKey / card layout polish on Sell Step 1  
- Cloudinary logo upload  
- Expanding taxonomy richness beyond unblocking shared roots (Beauty, Grocery, etc. can be a follow-up seed)
