# Seller dashboard KPIs — Flutter mobile handoff

**Status:** Shipped (P0)  
**Base:** `/api/v1`  
**Auth:** Consumer Bearer (seller-capable)  
**Locale:** `x-locale: FR` | `EN`  
**Currency:** GNF integers  
**Timezone for “today”:** `Africa/Conakry` (UTC+0, no DST)  
**Timestamps:** ISO-8601 UTC `Z`

No invented KPIs. Empty shop → zeros. Wallet fields mirror `GET /wallet`.

---

## Primary

```http
GET /api/v1/me/seller/dashboard
Authorization: Bearer …
x-locale: FR
```

**403** `NOT_A_SELLER` if no active seller profile.  
Dashboard still returns **200** when `verificationStatus=PENDING` (banner only).

### Response

```ts
type SellerDashboard = {
  sellerProfileId: string;
  shopName: string | null;
  /** Flutter shop kinds */
  shopKind: "PARTICULIER" | "BOUTIQUE" | "PROXIMITE" | "ENSEIGNE" | null;
  verificationStatus: "NONE" | "PENDING" | "APPROVED" | "REJECTED";

  wallet: {
    availableGnf: number;
    pendingEscrowGnf: number;   // seller nets in escrow
    minWithdrawalGnf: number;
    defaultPayoutMsisdn: string | null;
    currency: "GNF";
  };

  kpis: {
    /** Buyer item subtotal (excludes delivery fee), Conakry today, paidAt in day, not REFUNDED */
    todaySalesGnf: number;
    /** Seller net for same orders — prefer this for the sales card */
    todaySalesNetGnf: number;
    /** Listing.status = ACTIVE (published / visible) */
    listingsActiveCount: number;
    listingsDraftCount: number;     // DRAFT
    listingsTotalCount: number;     // not ARCHIVED, not soft-deleted
    toPrepareCount: number;         // same set as filter=to_prepare
    shippedCount: number;           // filter=shipped
    soldCount: number;              // filter=sold
    offersPendingCount: number;     // Offer.status=pending
    openEscrowOrderCount: number;   // paid+ holding seller escrow
    lowStockCount: number;          // ACTIVE, 0 < qty ≤ 2
  };

  analytics: {
    shopVisitsToday: null;          // not instrumented yet
    shopVisits7d: null;
    shopVisits30d: null;
  };

  badges: {
    toPrepare: number;
    shipped: number;
    sold: number;
    offers: number;
  };

  share: {
    publicShopSlug: string | null;
    publicShopUrl: string | null;   // `${PUBLIC_SHOP_BASE_URL|/https://fripcash.app}/shop/{slug}`
    sellerProfileId: string;
  };

  serverNow: string;
  timezone: "Africa/Conakry";
};
```

### KPI definitions (exact)

| Field | Definition |
|-------|------------|
| `todaySalesGnf` | Σ `order.subtotalGnf` (line items / buyer merchandise — **excludes** `deliveryFeeGnf`) where `paidAt` ∈ Conakry today and `status ≠ REFUNDED`. |
| `todaySalesNetGnf` | Σ `order.sellerNetTotalGnf` for the same order set. Flutter should prefer this for “Today’s sales”. |
| `listingsActiveCount` | `status=ACTIVE`, `deletedAt=null`. (DB uses `ACTIVE`, not `PUBLISHED`.) |
| `listingsDraftCount` | `status=DRAFT`. |
| `listingsTotalCount` | `deletedAt=null` and `status ≠ ARCHIVED` (includes ACTIVE, DRAFT, HIDDEN, SOLD_OUT, …). |
| `toPrepareCount` | Seller orders with status ∈ `{PAID, SELLER_NOTIFIED, PREPARING}` (paid+, before `READY_FOR_PICKUP`; excludes unpaid `ORDERED`, `REFUNDED`, `DISPUTED`). |
| `shippedCount` | Rank ≥ `READY_FOR_PICKUP` and < `DELIVERED`, non-terminal. |
| `soldCount` | Rank ≥ `DELIVERED` **or** funds released; excludes refunded/disputed. |
| `offersPendingCount` | `Offer.status=pending` on this seller’s listings. |
| `openEscrowOrderCount` | Distinct orders still holding seller escrow (paid+, `fundsReleasedAt=null`, not refunded / funds-released / feedback-pending). |
| `lowStockCount` | `ACTIVE` listings with `1 ≤ quantity ≤ 2`. |

---

## Badges (lightweight)

```http
GET /api/v1/me/seller/dashboard/badges
→ { "toPrepare": 2, "offers": 1, "shipped": 0, "sold": 0 }
```

Same counts as `badges` / matching KPI fields — no wallet payload.

---

## Order tabs ↔ filters

```http
GET /api/v1/orders?as=seller&filter=to_prepare
GET /api/v1/orders?as=seller&filter=shipped
GET /api/v1/orders?as=seller&filter=sold
```

| Tab | `filter` aliases |
|-----|------------------|
| To prepare | `to_prepare`, `toPrepare` |
| Shipped | `shipped` |
| Sold | `sold` |

Status sets match dashboard KPI counts above.

### Seller list item fields

Each order DTO includes:

| Field | Notes |
|-------|--------|
| `sellerNetGnf` | Alias of `sellerNetTotalGnf` — use for “You receive” |
| `sellerNetTotalGnf` | Same value (legacy) |
| `buyerDisplayName` | Alias of `buyerName` |
| `listingTitle` | First line item title |
| `listingImageUrl` | First line item cover |
| `totalGnf` / `deliveryFeeGnf` / `pickupCode` / `status` / `createdAt` | Existing |

---

## Share URL

- Slug: organization `slug` when boutique exists; else slugified `shopName` / profile id.
- Absolute URL: `{PUBLIC_SHOP_BASE_URL \|\| https://fripcash.app}/shop/{slug}`  
  Override with env `PUBLIC_SHOP_BASE_URL` (no trailing slash).

---

## Flutter map

| UI | Field |
|----|--------|
| Wallet available | `wallet.availableGnf` |
| Escrow amount | `wallet.pendingEscrowGnf` |
| Escrow “N orders” | `kpis.openEscrowOrderCount` |
| Today’s sales | `kpis.todaySalesNetGnf ?? kpis.todaySalesGnf` |
| My listings | `kpis.listingsActiveCount` |
| To prepare | `kpis.toPrepareCount` |
| Offers | `kpis.offersPendingCount` |
| Tab badges | `badges.*` or `/dashboard/badges` |
| Share | `share.publicShopUrl` |
| Verification banner | `verificationStatus` |

---

## Errors

| Code | HTTP |
|------|------|
| `UNAUTHORIZED` | 401 |
| `NOT_A_SELLER` | 403 |
| `FORBIDDEN_AUDIENCE` | 403 |

---

## Example

```bash
HOST=http://62.84.179.126:3010
TOKEN=…

curl -sS "$HOST/api/v1/me/seller/dashboard" \
  -H "Authorization: Bearer $TOKEN" \
  -H "x-locale: FR"
```

---

## P1 / P2

- P1: stable public slug UX polish  
- P2: real `analytics.shopVisits*` (nullable until instrumented)
