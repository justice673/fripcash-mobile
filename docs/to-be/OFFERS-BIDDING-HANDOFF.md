# Flutter → Nest — Offers / bidding (“Faire une offre”) handoff

**From:** Flutter mobile  
**To:** Nest BE  
**Date:** 2026-10-02  
**Priority:** High — buyer make-offer + seller inbox are **100% in-memory** (`OffersStore`); seed mocks cleared  
**Env:** `http://62.84.179.126:3010`  
**Base path:** `/api/v1`  
**Auth:** consumer Bearer  
**Locale:** `x-locale: FR` | `EN`

**Related:**  
- SRS `docs/srs/08-offers-and-messaging.md` §8.1  
- `docs/to-be/SELLER-DASHBOARD-KPIS-HANDOFF.md` (`offersPendingCount`)  
- `docs/to-be/MESSAGING-SELLERS-SUPPORT-HANDOFF.md` (optional notify in chat — not required for v1)  
- Checkout / listings handoffs for accepted-price lock

**Flutter surfaces today:**  
- PDP → `MakeOfferSheet`  
- Buyer → My offers (`BuyerOffersScreen`)  
- Seller → Received offers (`SellerOffersScreen`) + dashboard “Offers to handle”

---

## 0. Why this exists

Product: buyer proposes a **lower** price; seller **accepts** or **refuses**. On accept, negotiated price must be usable at checkout (token/lock — you define).

OpenAPI / from-be currently has **no** offers module Flutter can call. Please ship the contract below and publish `docs/from-be/offers-mobile-flutter-handoff.md`.

---

## 1. Product rules (non-negotiable)

1. Offers only on listings where negotiation is allowed (`negotiable=true` **or** seller type allows offers).  
2. **Enseigne / partner brands:** offers **disabled** — `403 OFFERS_DISABLED` (same spirit as messaging disabled).  
3. Offered amount must be **strictly less** than current **buyer display price** (`displayPriceGnf` / listed price shown on PDP).  
4. Offered amount ≥ **1 GNF** integer; no decimals.  
5. One **PENDING** offer per `(buyerUserId, listingId)` — new submit replaces or rejects with `OFFER_ALREADY_PENDING` (pick one; prefer **replace** with audit).  
6. Seller can accept **one** PENDING offer per listing at a time; accepting auto-refuses other PENDING on same listing **or** leaves them (document — prefer auto-refuse).  
7. Accepted offer expires after TTL (proposal: **24h** or until stock/price change) → `EXPIRED`.  
8. AuthZ: buyer sees own offers; seller sees offers on own listings; admin read for disputes.  
9. Push / in-app notification on create / accept / refuse.  
10. Currency GNF integers; timestamps ISO-8601 `Z`.

---

## 2. Domain model

```ts
type OfferStatus =
  | "PENDING"
  | "ACCEPTED"
  | "REFUSED"
  | "CANCELLED"   // buyer cancelled
  | "EXPIRED"
  | "CONSUMED";   // used in a paid order

type Offer = {
  id: string;
  listingId: string;
  listingTitle: string;
  listingImageUrl: string | null;
  listedPriceGnf: number;       // display price at time of offer (snapshot)
  offeredPriceGnf: number;
  status: OfferStatus;

  buyerUserId: string;
  buyerDisplayName: string | null;

  sellerProfileId: string;
  sellerDisplayName: string | null;

  /** Present when ACCEPTED — checkout must send this */
  checkoutToken: string | null;
  acceptedAt: string | null;
  expiresAt: string | null;

  createdAt: string;
  updatedAt: string;

  /** Viewer helpers */
  isMine: boolean;              // current user is buyer
  canAccept: boolean;           // seller + PENDING
  canRefuse: boolean;
  canCancel: boolean;           // buyer + PENDING
};
```

---

## 3. Buyer APIs

### 3.1 Create offer (PDP)

```http
POST /api/v1/listings/:listingId/offers
{
  "offeredPriceGnf": 38000
}
```

| Rule | Code |
|------|------|
| Not logged in | `UNAUTHORIZED` 401 |
| Listing not found / not published | `NOT_FOUND` 404 |
| Offers disabled (enseigne / !negotiable) | `OFFERS_DISABLED` 403 |
| `offeredPriceGnf >= listedDisplayPrice` | `OFFER_NOT_LOWER` 400 |
| `offeredPriceGnf < 1` | `VALIDATION_ERROR` 400 |
| Buyer is the seller | `CANNOT_OFFER_OWN_LISTING` 403 |
| Rate limit | `RATE_LIMITED` 429 |

**201**

```json
{ /* Offer status=PENDING */ }
```

### 3.2 List my offers (buyer)

```http
GET /api/v1/me/offers?status=PENDING|ACCEPTED|REFUSED|ALL&cursor=&limit=30
```

**200** `{ "items": Offer[], "nextCursor": null }`

Maps to `BuyerOffersScreen`.

### 3.3 Cancel my pending offer

```http
POST /api/v1/offers/:id/cancel
```

Buyer only; `PENDING` → `CANCELLED`.

---

## 4. Seller APIs

### 4.1 List received offers

```http
GET /api/v1/me/seller/offers?status=PENDING|ACCEPTED|ALL&listingId=&cursor=&limit=30
```

**200** `{ "items": Offer[], "nextCursor": null, "pendingCount": 3 }`

Maps to `SellerOffersScreen` tabs:
- **To handle** → `status=PENDING`
- **Accepted** → `status=ACCEPTED` (and optionally `CONSUMED`)

### 4.2 Accept

```http
POST /api/v1/offers/:id/accept
Idempotency-Key: <uuid>
```

Effects:

1. Offer → `ACCEPTED`  
2. Set `checkoutToken`, `acceptedAt`, `expiresAt`  
3. Optionally refuse other PENDING on same listing  
4. Notify buyer  
5. Return full Offer

| Rule | Code |
|------|------|
| Not seller owner | `FORBIDDEN` 403 |
| Not PENDING | `OFFER_NOT_PENDING` 409 |
| Listing sold out / unpublished | `LISTING_UNAVAILABLE` 409 |

### 4.3 Refuse

```http
POST /api/v1/offers/:id/refuse
{
  "reason": "optional free text"
}
```

→ `REFUSED` + notify buyer.

---

## 5. Checkout integration (required for accept to matter)

Document in from-be how accepted price is applied:

**Option A (preferred):** checkout line includes:

```json
{
  "listingId": "…",
  "quantity": 1,
  "offerId": "…",
  "offerCheckoutToken": "…"
}
```

Server validates token, status `ACCEPTED`, not expired, buyer matches → unit price = `offeredPriceGnf`.

**Option B:** short-lived price lock resource:

```http
POST /api/v1/price-locks
{ "offerId": "…" }
→ { "priceLockId", "unitPriceGnf", "expiresAt" }
```

Either way: after paid order, offer → `CONSUMED`.

If listing price changes after accept: **keep snapshot** `listedPriceGnf` / `offeredPriceGnf`; do not silently raise buyer price.

---

## 6. Notifications

| Event | Recipient | Payload hint |
|-------|-----------|--------------|
| Offer created | Seller | `type: offer.created`, `offerId`, `listingId` |
| Offer accepted | Buyer | `type: offer.accepted`, `checkoutToken` meta |
| Offer refused | Buyer | `type: offer.refused` |
| Offer expired | Buyer | `type: offer.expired` |

---

## 7. Dashboard KPI hook

`GET /me/seller/dashboard` → `kpis.offersPendingCount` = count PENDING for seller (see seller dashboard handoff).

---

## 8. Error catalogue

| Code | HTTP | When |
|------|------|------|
| `UNAUTHORIZED` | 401 | |
| `FORBIDDEN` | 403 | Not participant |
| `OFFERS_DISABLED` | 403 | Enseigne / non-negotiable |
| `CANNOT_OFFER_OWN_LISTING` | 403 | |
| `NOT_FOUND` | 404 | |
| `OFFER_NOT_LOWER` | 400 | |
| `OFFER_NOT_PENDING` | 409 | |
| `LISTING_UNAVAILABLE` | 409 | |
| `OFFER_EXPIRED` | 409 | Checkout with dead token |
| `VALIDATION_ERROR` | 400 | |
| `RATE_LIMITED` | 429 | |

---

## 9. Flutter UI ↔ API map

| Flutter | API |
|---------|-----|
| Make offer sheet send | `POST /listings/:id/offers` |
| Buyer My offers | `GET /me/offers` |
| Seller Received offers · To handle | `GET /me/seller/offers?status=PENDING` |
| Seller Accepted tab | `GET /me/seller/offers?status=ACCEPTED` |
| Accept / Refuse buttons | `POST /offers/:id/accept` \| `refuse` |
| Checkout with deal | offer token on cart/checkout (document) |
| Dashboard offers count | dashboard `offersPendingCount` |

---

## 10. Acceptance checklist

- [ ] Buyer can submit offer lower than display price  
- [ ] Enseigne / non-negotiable blocked  
- [ ] Seller accept/refuse persists across devices  
- [ ] Accepted price works at checkout until expiry  
- [ ] Dashboard pending count matches list  
- [ ] No client seed data required  
- [ ] OpenAPI + `from-be/offers-mobile-flutter-handoff.md`  

---

## 11. Example cURLs

```bash
HOST=http://62.84.179.126:3010
BUYER=…; SELLER=…; LISTING=…

# Buyer offers
curl -sS -X POST "$HOST/api/v1/listings/$LISTING/offers" \
  -H "Authorization: Bearer $BUYER" -H "Content-Type: application/json" \
  -H "x-locale: FR" \
  -d '{"offeredPriceGnf":38000}'

curl -sS "$HOST/api/v1/me/offers?status=ALL" \
  -H "Authorization: Bearer $BUYER" -H "x-locale: FR"

# Seller inbox
curl -sS "$HOST/api/v1/me/seller/offers?status=PENDING" \
  -H "Authorization: Bearer $SELLER" -H "x-locale: FR"

curl -sS -X POST "$HOST/api/v1/offers/$OFFER/accept" \
  -H "Authorization: Bearer $SELLER" -H "Idempotency-Key: $(uuidgen)"
```

---

## 12. Priority

| P0 | Create + list buyer + list seller + accept/refuse |
| P0 | Checkout bind (token or price-lock) |
| P1 | Expiry job + push notifications |
| P2 | Chat system card “offer accepted” |

Once P0 is live, Flutter deletes `OffersStore` mock path.
