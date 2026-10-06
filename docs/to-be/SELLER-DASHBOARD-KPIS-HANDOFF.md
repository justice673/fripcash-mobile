# Flutter → Nest — Seller dashboard KPIs & shop summary handoff

**From:** Flutter mobile (My shop / `SellerDashboardScreen`)  
**To:** Nest BE  
**Date:** 2026-10-02  
**Priority:** High — UI shows fake/local stats; dummy `85 000 GNF` removed client-side  
**Env:** `http://62.84.179.126:3010`  
**Base path:** `/api/v1`  
**Auth:** `Authorization: Bearer <consumer accessToken>` (seller-capable user)  
**Locale:** `x-locale: FR` | `EN`

**Related:**  
- `docs/from-be/wallet-mobile-flutter-handoff.md` (balances already live)  
- `docs/from-be/orders-mobile-flutter-handoff.md` (sales list already live)  
- `docs/from-be/listings-mobile-flutter-handoff.md` (`GET /me/listings` already live)  
- `docs/to-be/OFFERS-BIDDING-HANDOFF.md` (offers count depends on offers API)  
- SRS: `docs/srs/10-seller-tools.md`

**Out of scope:** Admin analytics, courier earnings (separate).

---

## 0. Why this exists

Flutter **My shop** shows four KPI cards + wallet escrow order count. Today:

| UI | Flutter today after dummy purge |
|----|----------------------------------|
| Today's sales | Client sum of loaded orders with “today” label heuristics → often **0 GNF** |
| My listings | Count from **discover cache**, not authoritative `GET /me/listings` |
| To prepare | Client filter of `GET /orders?as=seller` |
| Offers to handle | In-memory `OffersStore` (always 0 until offers API) |
| Escrow “N orders” | Client count of open seller orders |

We need **one authoritative summary endpoint** (plus optional visits) so the dashboard does not re-derive fragile client math and never invents numbers.

Please treat this file as source of truth. Reply with `docs/from-be/seller-dashboard-mobile-flutter-handoff.md` when live.

---

## 1. Product principles

1. **No invented KPIs.** Empty shop → zeros / empty lists. Never seed demo sales.  
2. **Currency:** GNF **integers**.  
3. **Timezone:** KPI “today” = **Africa/Conakry** (GMT+0, no DST) calendar day unless you document otherwise.  
4. **AuthZ:** only the seller who owns `sellerProfileId` (or admin with audit).  
5. **Wallet fields** stay on `GET /wallet` — dashboard may **embed** copies for one-round-trip convenience but must not diverge.  
6. **Offers pending count** = offers with `status=PENDING` for this seller (see offers handoff). Return `0` if offers module not shipped yet — do not fake.  
7. **Timestamps:** ISO-8601 UTC with `Z`.

---

## 2. Primary endpoint — shop summary

```http
GET /api/v1/me/seller/dashboard
x-locale: FR
```

**Audience:** `CONSUMER` with active seller profile.  
**403** if not a seller: `NOT_A_SELLER`.

### 2.1 Response DTO

```ts
type SellerDashboard = {
  sellerProfileId: string;
  shopName: string | null;
  shopKind: "PARTICULIER" | "BOUTIQUE" | "PROXIMITE" | "ENSEIGNE" | null;
  verificationStatus: "NONE" | "PENDING" | "APPROVED" | "REJECTED";

  /** Wallet snapshot (must match GET /wallet for same user) */
  wallet: {
    availableGnf: number;
    pendingEscrowGnf: number;   // seller nets in escrow, not gross
    minWithdrawalGnf: number;
    defaultPayoutMsisdn: string | null;
    currency: "GNF";
  };

  /** KPI cards on Shop tab */
  kpis: {
    /** Gross buyer-paid amount for orders paid+ today (Conakry day), or seller net — DOCUMENT WHICH */
    todaySalesGnf: number;
    /** Preferred: seller net credited-basis for today */
    todaySalesNetGnf?: number;
    listingsActiveCount: number;      // published + in stock (or all non-deleted — document)
    listingsDraftCount: number;
    listingsTotalCount: number;
    toPrepareCount: number;           // orders needing seller prep (status < readyForPickup)
    shippedCount: number;             // in transit / shipped bucket used by UI tab
    soldCount: number;                // delivered / payment released bucket
    offersPendingCount: number;       // PENDING offers
    openEscrowOrderCount: number;     // orders contributing to pendingEscrowGnf
    lowStockCount: number;            // optional
  };

  /** Optional analytics — return null/0 until instrumented; never invent */
  analytics?: {
    shopVisitsToday: number | null;
    shopVisits7d: number | null;
    shopVisits30d: number | null;
  };

  /** Tab badge hints */
  badges: {
    toPrepare: number;
    shipped: number;
    sold: number;
    offers: number;
  };

  /** Public share target for header Share button */
  share: {
    publicShopSlug: string | null;     // e.g. "aminata-v"
    publicShopUrl: string | null;      // absolute https URL Nest owns OR documented web base
    sellerProfileId: string;
  };

  serverNow: string;                   // ISO
  timezone: "Africa/Conakry";
};
```

### 2.2 Example 200 (empty new shop)

```json
{
  "sellerProfileId": "clx…",
  "shopName": "Ma boutique",
  "shopKind": "BOUTIQUE",
  "verificationStatus": "APPROVED",
  "wallet": {
    "availableGnf": 0,
    "pendingEscrowGnf": 0,
    "minWithdrawalGnf": 10000,
    "defaultPayoutMsisdn": null,
    "currency": "GNF"
  },
  "kpis": {
    "todaySalesGnf": 0,
    "todaySalesNetGnf": 0,
    "listingsActiveCount": 0,
    "listingsDraftCount": 0,
    "listingsTotalCount": 0,
    "toPrepareCount": 0,
    "shippedCount": 0,
    "soldCount": 0,
    "offersPendingCount": 0,
    "openEscrowOrderCount": 0,
    "lowStockCount": 0
  },
  "analytics": {
    "shopVisitsToday": null,
    "shopVisits7d": null,
    "shopVisits30d": null
  },
  "badges": {
    "toPrepare": 0,
    "shipped": 0,
    "sold": 0,
    "offers": 0
  },
  "share": {
    "publicShopSlug": "ma-boutique",
    "publicShopUrl": "https://fripcash.app/shop/ma-boutique",
    "sellerProfileId": "clx…"
  },
  "serverNow": "2026-10-02T08:00:00.000Z",
  "timezone": "Africa/Conakry"
}
```

### 2.3 KPI definitions (must be exact)

| Field | Definition |
|-------|------------|
| `todaySalesGnf` | Sum of **buyer-facing order item totals** (exclude delivery fee **or** include — **pick one and document**) for orders with `paidAt` (or status ≥ `PAID`) where `paidAt` falls in Conakry **today**. Cancelled/refunded excluded. |
| `todaySalesNetGnf` | Sum of **seller net** for same orders (preferred for “what I earned today”). Flutter will prefer this for the card if present. |
| `listingsActiveCount` | Listings with `status=PUBLISHED` and visible (not vacation-hidden). |
| `listingsDraftCount` | `status=DRAFT`. |
| `listingsTotalCount` | Active + draft + hidden (exclude soft-deleted). |
| `toPrepareCount` | Seller sales where status ∈ `{PAID, PREPARING, …}` before `READY_FOR_PICKUP` / `SHIPPED` — **align with Flutter tab `_BoutiqueTab.toPrepare`** / `GET /orders?as=seller&filter=to_prepare` if that filter exists. |
| `shippedCount` | Align with Shipped tab filter. |
| `soldCount` | Align with Sold tab (delivered / released). |
| `offersPendingCount` | Count of `Offer.status=PENDING` where `sellerProfileId=me`. |
| `openEscrowOrderCount` | Distinct orders still holding seller escrow. |
| `lowStockCount` | Listings with `stock > 0 && stock ≤ lowStockThreshold` (threshold e.g. 2 — document). |

**Critical:** Status enums must match orders handoff. If filter query params already exist on `GET /orders?as=seller&filter=`, reuse the **same** status sets for counts.

---

## 3. Flutter UI ↔ field map

| Flutter surface | Field |
|-----------------|-------|
| Wallet card available | `wallet.availableGnf` (or keep parallel `GET /wallet`) |
| Escrow bar amount | `wallet.pendingEscrowGnf` |
| Escrow “N orders” | `kpis.openEscrowOrderCount` |
| Today's sales card | `kpis.todaySalesNetGnf ?? kpis.todaySalesGnf` |
| My listings card | `kpis.listingsActiveCount` (or total — we prefer **active**) |
| To prepare card | `kpis.toPrepareCount` |
| Offers to handle card | `kpis.offersPendingCount` |
| Tab badges | `badges.*` |
| Share sheet URL | `share.publicShopUrl` (fallback deep link only if null) |
| Verification banner | `verificationStatus` |

Withdraw CTA stays on existing `POST /wallet/withdraw` — not part of dashboard POST.

---

## 4. Optional: lightweight poll / unread

```http
GET /api/v1/me/seller/dashboard/badges
→ { "toPrepare": 2, "offers": 1, "shipped": 0, "sold": 0 }
```

Use for bottom-nav / shop tab refresh without full wallet payload.

---

## 5. Order tab data (already mostly live)

Flutter already calls:

```http
GET /api/v1/orders?as=seller
GET /api/v1/orders?as=seller&filter=…
POST /api/v1/orders/:id/prepare
POST /api/v1/orders/:id/ready
POST /api/v1/orders/:id/confirm-handoff
```

**Ask:** Confirm documented `filter` values map 1:1 to dashboard tabs:

| Tab | Expected filter (proposal) |
|-----|----------------------------|
| To prepare | `to_prepare` |
| Shipped | `shipped` |
| Sold | `sold` |

Return **seller net** on each order line item (`sellerNetGnf`) so “You receive” on cards does not depend on client product cache.

```ts
type SellerOrderListItem = {
  id: string;
  status: string;
  totalGnf: number;
  deliveryFeeGnf: number;
  sellerNetGnf: number;          // REQUIRED for dashboard cards
  buyerDisplayName: string | null;
  listingTitle: string | null;
  listingImageUrl: string | null;
  pickupCode: string | null;
  createdAt: string;
  // …
};
```

---

## 6. Errors

| Code | HTTP | When |
|------|------|------|
| `UNAUTHORIZED` | 401 | Bad/missing token |
| `NOT_A_SELLER` | 403 | No seller profile |
| `FORBIDDEN_AUDIENCE` | 403 | Courier token etc. |
| `SELLER_PENDING_VERIFICATION` | 403 | Optional soft gate for some sub-actions (dashboard GET should still 200 with `verificationStatus`) |

Always JSON `{ statusCode, code, message, details?, correlationId, locale }`.

---

## 7. Acceptance checklist

- [ ] New empty boutique → all KPI zeros (no 85k)  
- [ ] After a paid order today → `todaySales*` updates within same Conakry day  
- [ ] Listing publish increments `listingsActiveCount`  
- [ ] `offersPendingCount` tracks offers API  
- [ ] `wallet.*` matches `GET /wallet`  
- [ ] `share.publicShopUrl` usable in native share sheet  
- [ ] OpenAPI schema filled  
- [ ] `docs/from-be/seller-dashboard-mobile-flutter-handoff.md` published  

---

## 8. Example cURL

```bash
HOST=http://62.84.179.126:3010
TOKEN=…

curl -sS "$HOST/api/v1/me/seller/dashboard" \
  -H "Authorization: Bearer $TOKEN" \
  -H "x-locale: FR"
```

---

## 9. Priority

| P0 | `GET /me/seller/dashboard` with accurate zeros + listing/order/offer counts |
| P0 | `sellerNetGnf` on seller order list items |
| P1 | `share.publicShopUrl` + stable slug |
| P2 | Real `analytics.shopVisits*` (nullable until instrumented) |

Once P0 is live, Flutter will replace `MockSellerDashboardService` KPI math with this DTO.
