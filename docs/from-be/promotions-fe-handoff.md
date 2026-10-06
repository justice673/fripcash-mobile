# Featured promotions (home carousel)

**Status:** Shipped  
**Public response:** **locale-collapsed** (`title`, `subtitle`, …) via `x-locale: FR|EN`  
**Admin response:** bilingual (`titleFr` / `titleEn`, …)

Staff-only create/edit/delete. Consumers only **read** eligible promos. Checkout still uses live listing price — carousel prices are **display snapshots**.

## Datetime

- Wire format: ISO-8601 UTC with `Z` (e.g. `2026-10-01T18:00:00.000Z`)
- Window: **`startsAt <= now < endsAt`** (exclusive end)
- Public eligibility uses **server `now`**; payload includes `serverNow`

## Status

| Status | Meaning |
|--------|---------|
| `DRAFT` | Never public |
| `PAUSED` | Force-hide (`isActive=false` also treated as paused on admin view) |
| `SCHEDULED` / `LIVE` / `ENDED` | Derived from window when not DRAFT/PAUSED |

Public never returns DRAFT / PAUSED / ENDED / out-of-window.

## Public

```http
GET /api/v1/promotions?surface=HOME_APP&limit=12
x-locale: FR
```

| Param | Default | Notes |
|-------|---------|--------|
| `surface` | `HOME_WEB` | `HOME_APP` \| `HOME_WEB` — matches row `surface` or `BOTH` |
| `limit` | `12` | max `50` |

**200**

```json
{
  "items": [
    {
      "id": "…",
      "kind": "PRODUCT",
      "title": "…",
      "subtitle": "Offre flash",
      "description": "…",
      "badge": "-40 %",
      "ctaLabel": "Acheter",
      "listingId": "…",
      "sellerProfileId": null,
      "imageUrl": "https://…",
      "promoPriceGnf": 349920,
      "compareAtPriceGnf": 583200,
      "discountPercent": 40,
      "startsAt": "2026-10-01T10:00:00.000Z",
      "endsAt": "2026-10-02T04:00:00.000Z",
      "surface": "BOTH",
      "sortOrder": 10,
      "deepLink": { "type": "LISTING", "id": "…" }
    }
  ],
  "serverNow": "2026-10-01T18:05:12.441Z"
}
```

- `PRODUCT` → `deepLink.type = LISTING`
- `SHOP` → `deepLink.type = SHOP`
- Missing creative + PRODUCT → backfills listing cover media URL
- Unpublishable listing/shop → **omitted** (not 500)

Flutter: `surface=HOME_APP`. Website: `surface=HOME_WEB`.

## Admin

Auth: admin Bearer. Permission: `catalog:*` (same as categories).

| Method | Path |
|--------|------|
| GET | `/api/v1/admin/promotions` |
| GET | `/api/v1/admin/promotions/:id` |
| POST | `/api/v1/admin/promotions` |
| PATCH | `/api/v1/admin/promotions/:id` |
| DELETE | `/api/v1/admin/promotions/:id` → `{ "ok": true }` |

### Query (list)

`status`, `surface` (`ALL` or enum), `q`, `cursor`, `limit` (default 20, max 100)

### Create body (PRODUCT from article)

```json
{
  "kind": "PRODUCT",
  "status": "DRAFT",
  "titleFr": "…",
  "titleEn": "…",
  "subtitleFr": "Offre flash",
  "subtitleEn": "Flash deal",
  "badgeFr": "-40 %",
  "badgeEn": "-40%",
  "ctaLabelFr": "Acheter",
  "ctaLabelEn": "Shop now",
  "listingId": "<listingId>",
  "promoPriceGnf": 349920,
  "compareAtPriceGnf": 583200,
  "startsAt": "2026-10-01T18:00:00.000Z",
  "endsAt": "2026-10-03T23:59:00.000Z",
  "surface": "BOTH",
  "sortOrder": 10,
  "isActive": true,
  "internalNotes": "…"
}
```

### Errors

| Code | When |
|------|------|
| `INVALID_TIME_WINDOW` | `endsAt <= startsAt` |
| `LISTING_REQUIRED` / `SELLER_REQUIRED` | kind XOR target |
| `LISTING_NOT_FOUND` / `SELLER_NOT_FOUND` | unknown FK |
| `INVALID_PRICE` | negative or `compareAt < promo` |
| `LISTING_NOT_PUBLISHABLE` | activate when listing not `ACTIVE`/`SOLD_OUT` |
| `PROMOTION_NOT_FOUND` | missing id |

## Cloudinary

```http
POST /api/v1/media/cloudinary-sign
{ "folder": "promotions" }
```

Resolves under `fripcash/promotions/…`.

## Out of scope (v1)

Seller self-serve ads, checkout price binding to `promoPriceGnf`, impression analytics.

---

## Flutter mobile (this repo)

**Status:** Wired to public API only (`surface=HOME_APP`).

| File | Role |
|------|------|
| `lib/api/promotions_api.dart` | `GET /promotions` |
| `lib/models/promotion.dart` | Locale-collapsed item + `serverNow` feed |
| `lib/services/promotions_repository.dart` | Cache, locale re-fetch, countdown skew |
| `lib/widgets/home/home_sponsored_section.dart` | Home carousel |

- Uses `x-locale` from `ApiClient`
- Maps `badge` / `ctaLabel` / prices / `deepLink` (LISTING → PDP, SHOP → seller)
- Countdown uses `endsAt` against estimated server time from `serverNow`
- Empty eligible feed → section hidden (no dummy cards)
- Admin CRUD + `HOME_WEB` → website / admin repos
