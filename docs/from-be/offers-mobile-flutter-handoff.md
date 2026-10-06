# Offers / bidding — Flutter mobile handoff

**Status:** Shipped (P0)  
**Base:** `/api/v1`  
**Auth:** Consumer Bearer  
**Locale:** `x-locale: FR` | `EN`  
**Currency:** GNF integers  
**Timestamps:** ISO-8601 UTC `Z`

Product: buyer proposes a **lower** price; seller **accepts** or **refuses**. On accept, Nest mints a `checkoutToken` (24h). Checkout applies negotiated price via cart `offerId` / `checkoutToken` (Option A).

---

## Status enum (API — uppercase)

| Status | DB | Meaning |
|--------|-----|---------|
| `PENDING` | `pending` | Awaiting seller |
| `ACCEPTED` | `accepted` | Seller accepted; `checkoutToken` live until `expiresAt` |
| `REFUSED` | `refused` | Seller refused (or auto-refused when another offer accepted) |
| `CANCELLED` | `canceled` | Buyer cancelled |
| `EXPIRED` | `expired` | Accept token TTL elapsed |
| `CONSUMED` | `consumed` | Used in a paid order |

**Policy picks:**
1. New submit from same buyer on same listing **replaces** prior `PENDING` (old → `CANCELLED`).
2. Accepting one offer **auto-refuses** other `PENDING` on the same listing.
3. Accept TTL = **24h** from `acceptedAt`.
4. Listing price changes after accept do **not** raise the locked offer price.

---

## Offer DTO

```ts
type Offer = {
  id: string;
  listingId: string;
  listingTitle: string;
  listingImageUrl: string | null;
  listedPriceGnf: number;       // snapshot at submit
  offeredPriceGnf: number;
  status: "PENDING" | "ACCEPTED" | "REFUSED" | "CANCELLED" | "EXPIRED" | "CONSUMED";
  buyerUserId: string;
  buyerDisplayName: string | null;
  sellerProfileId: string;
  sellerDisplayName: string | null;
  checkoutToken: string | null; // set when ACCEPTED
  acceptedAt: string | null;
  expiresAt: string | null;
  createdAt: string;
  updatedAt: string;
  isMine: boolean;
  canAccept: boolean;
  canRefuse: boolean;
  canCancel: boolean;
  message?: string | null;
};
```

Legacy aliases still present: `amountGnf`, `buyerId`, `productId`, `product`.

---

## Buyer APIs

### Create (PDP)

```http
POST /api/v1/listings/:listingId/offers
Authorization: Bearer …
Content-Type: application/json
x-locale: FR

{ "offeredPriceGnf": 38000 }
```

Also accepts deprecated `amountGnf`.

| Rule | Code | HTTP |
|------|------|------|
| Not logged in | `UNAUTHORIZED` | 401 |
| Listing missing | `NOT_FOUND` | 404 |
| Enseigne / `!negotiable` | `OFFERS_DISABLED` | 403 |
| Buyer is seller | `CANNOT_OFFER_OWN_LISTING` | 403 |
| `offeredPriceGnf >= listedDisplayPrice` | `OFFER_NOT_LOWER` | 400 |
| `< 1` / non-int | `VALIDATION_ERROR` | 400 |
| Listing inactive / OOS on accept path | `LISTING_UNAVAILABLE` | 409 |

**201/200** → Offer `status=PENDING`

Legacy: `POST /api/v1/offers/listings/:listingId`

### List mine

```http
GET /api/v1/me/offers?status=PENDING|ACCEPTED|REFUSED|ALL&limit=30
```

**200**

```json
{ "items": [ /* Offer */ ], "nextCursor": null }
```

Legacy: `GET /api/v1/offers/mine`

### Cancel

```http
POST /api/v1/offers/:id/cancel
```

Buyer only; `PENDING` → `CANCELLED`.

Legacy: `POST /api/v1/offers/:id/withdraw`

---

## Seller APIs

### Inbox

```http
GET /api/v1/me/seller/offers?status=PENDING|ACCEPTED|ALL&listingId=
```

**200**

```json
{
  "items": [ /* Offer */ ],
  "nextCursor": null,
  "pendingCount": 3
}
```

Tabs:
- To handle → `status=PENDING`
- Accepted → `status=ACCEPTED` (include `CONSUMED` via `ALL` or separate filters)

Legacy: `GET /api/v1/seller/offers`

### Accept

```http
POST /api/v1/offers/:id/accept
Idempotency-Key: <uuid>
```

Effects: `ACCEPTED` + `checkoutToken` + `expiresAt` (+24h) + auto-refuse other PENDING on listing + notify buyer.

| Rule | Code | HTTP |
|------|------|------|
| Not owner | `NOT_FOUND` | 404 |
| Not PENDING | `OFFER_NOT_PENDING` | 409 |
| Listing unavailable | `LISTING_UNAVAILABLE` | 409 |

### Refuse

```http
POST /api/v1/offers/:id/refuse
{ "reason": "optional" }
```

→ `REFUSED` + notify buyer.

---

## Checkout bind (Option A)

Add accepted deal to cart:

```http
POST /api/v1/cart/items
{
  "listingId": "…",
  "quantity": 1,
  "offerId": "…",
  "checkoutToken": "…"
}
```

Either `offerId` or `checkoutToken` (or both). Server validates buyer + `ACCEPTED` + not expired → cart line `unitDisplayPriceGnf = offeredPriceGnf` and stores `offerId`.

Validate / quote / pay **skip `PRICE_CHANGED`** when `cart_item.offerId` is set. Snapshot prices are kept even if listing list price changes.

After Orange Money success webhook → offer `CONSUMED` (linked to `orderId`). Expired token at cart add → `OFFER_EXPIRED` 409.

---

## Dashboard KPI

```http
GET /api/v1/me/seller/dashboard
```

```json
{ "kpis": { "offersPendingCount": 3 } }
```

Matches `pendingCount` on `GET /me/seller/offers`.

---

## Notifications

| Event | Recipient | Type |
|-------|-----------|------|
| Created | Seller | `OFFER_RECEIVED` |
| Accepted | Buyer | `OFFER_ACCEPTED` |
| Refused | Buyer | `OFFER_REFUSED` |

---

## Flutter map

| Flutter | API |
|---------|-----|
| Make offer sheet | `POST /listings/:id/offers` `{ offeredPriceGnf }` |
| Buyer My offers | `GET /me/offers` |
| Seller To handle | `GET /me/seller/offers?status=PENDING` |
| Seller Accepted | `GET /me/seller/offers?status=ACCEPTED` |
| Accept / Refuse | `POST /offers/:id/accept` \| `refuse` |
| Cancel | `POST /offers/:id/cancel` |
| Checkout deal | cart item `offerId` + `checkoutToken` |
| Dashboard count | `GET /me/seller/dashboard` → `kpis.offersPendingCount` |

---

## Error catalogue

| Code | HTTP |
|------|------|
| `UNAUTHORIZED` | 401 |
| `FORBIDDEN` | 403 |
| `OFFERS_DISABLED` | 403 |
| `CANNOT_OFFER_OWN_LISTING` | 403 |
| `NOT_FOUND` | 404 |
| `OFFER_NOT_LOWER` | 400 |
| `OFFER_NOT_PENDING` | 409 |
| `LISTING_UNAVAILABLE` | 409 |
| `OFFER_EXPIRED` | 409 |
| `OFFER_TOKEN_INVALID` | 400 |
| `VALIDATION_ERROR` | 400 |
| `RATE_LIMITED` | 429 |

---

## Example cURL

```bash
HOST=http://62.84.179.126:3010
BUYER=…; SELLER=…; LISTING=…

curl -sS -X POST "$HOST/api/v1/listings/$LISTING/offers" \
  -H "Authorization: Bearer $BUYER" -H "Content-Type: application/json" \
  -H "x-locale: FR" \
  -d '{"offeredPriceGnf":38000}'

curl -sS "$HOST/api/v1/me/offers?status=ALL" \
  -H "Authorization: Bearer $BUYER" -H "x-locale: FR"

curl -sS "$HOST/api/v1/me/seller/offers?status=PENDING" \
  -H "Authorization: Bearer $SELLER" -H "x-locale: FR"

curl -sS -X POST "$HOST/api/v1/offers/$OFFER/accept" \
  -H "Authorization: Bearer $SELLER" -H "Idempotency-Key: $(uuidgen)"
```

---

## P1 / P2 (not in this ship)

- Expiry cron job + `offer.expired` push
- Chat system card “offer accepted”
