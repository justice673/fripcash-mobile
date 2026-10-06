# Checkout handoff — Flutter (mobile)

**Audience:** Flutter checkout / cart / Orange Money  
**API base:** `/api/v1` · Consumer Bearer required for cart + checkout  
**Status:** Shipped on Nest  
**Related:** [checkout-web-nextjs-handoff.md](./checkout-web-nextjs-handoff.md) · [listings-mobile-flutter-handoff.md](./listings-mobile-flutter-handoff.md) · [09-commerce.md](./09-commerce.md)

Replace in-memory cart + mock OM success with these contracts. **Server owns totals** — never trust client `subtotal` / `deliveryFee` / `grandTotal` for pay.

---

## Flow

```
PDP add → GET/POST cart
  → POST /cart/validate
  → address (+ fulfillment when proximity picker ships)
  → POST /checkout/quote
  → POST /checkout/payments (+ Idempotency-Key)
  → poll GET /checkout/payments/:id until succeeded|failed|…
  → confirmation (pickup code OR courier)
```

Clear cart only after **`succeeded`** (webhook). Do not invent a “paid” status from the client.

---

## Cart

| Method | Path | Notes |
|--------|------|--------|
| GET | `/cart` | Full cart + estimates |
| POST | `/cart/items` | `{ listingId, quantity? }` — **increments** same listing |
| PATCH | `/cart/items/:id` | `{ quantity }` — `≤ 0` deletes |
| DELETE | `/cart/items/:id` | Remove line |
| DELETE | `/cart` | Clear |
| POST | `/cart/validate` | Stock, mix, price drift |

### Response shape (GET /cart)

```json
{
  "id": "…",
  "buyerUserId": "…",
  "revision": "rev_12",
  "currency": "GNF",
  "items": [
    {
      "id": "…",
      "listingId": "…",
      "sellerProfileId": "…",
      "sellerName": "…",
      "shopKind": "courier",
      "destination": "SECONDE_MAIN",
      "title": "…",
      "brand": null,
      "coverUrl": "…",
      "unitDisplayPriceGnf": 45000,
      "quantity": 2,
      "stockAvailable": 5,
      "inStock": true,
      "shippingCostGnf": 5000
    }
  ],
  "subtotalEstimateGnf": 90000,
  "shippingEstimateGnf": 10000,
  "grandEstimateGnf": 100000,
  "updatedAt": "…"
}
```

`shippingEstimateGnf` may use listing postage — **checkout quote matrix wins**.

### Validate

```http
POST /api/v1/cart/validate
```

```json
{
  "ok": false,
  "revision": "rev_12",
  "issues": [
    { "code": "OUT_OF_STOCK", "listingId": "…", "itemId": "…" },
    { "code": "PRICE_CHANGED", "oldPrice": 45000, "newPrice": 48000 },
    { "code": "MIXED_PROXIMITY_COURIER" },
    { "code": "QTY_EXCEEDS_STOCK", "stock": 2, "quantity": 5 }
  ],
  "cart": { }
}
```

Block checkout CTA while any hard issue remains. Mixed proximité + courier → API reject (not snackbar-only).

---

## Delivery zones & rates (public)

```http
GET /api/v1/catalog/delivery-zones
GET /api/v1/catalog/shipping-rates
```

Zones: `zone_1` | `zone_2` | `other` + quartiers.  
Matrix fees (GNF): same-zone **5000**, cross **8000**, either `other` **12000**.

---

## Fulfillment

| Mode | When | Delivery fee | Pickup code |
|------|------|--------------|-------------|
| `courier` | Non-proximité cart | Zone matrix | No |
| `pickup` | Proximité default | 0 | Yes (4 digits on paid) |
| `shopLocalDelivery` | Proximité optional | 0 | Yes |

Until UI ships a picker, send `pickup` for proximité. API still accepts `shopLocalDelivery`.

---

## Quote

```http
POST /api/v1/checkout/quote
Authorization: Bearer …
```

```json
{
  "cartRevision": "rev_12",
  "fulfillmentMode": "courier",
  "address": {
    "name": "Aïssatou Bah",
    "phone": "+224620000001",
    "zoneId": "zone_1",
    "quartier": "Kaloum",
    "manualAddress": null,
    "landmark": null
  }
}
```

**Proximity `pickup`:** name + phone only (omit zone / quartier).

```json
{
  "currency": "GNF",
  "subtotalGnf": 90000,
  "deliveryFeeGnf": 10000,
  "grandTotalGnf": 100000,
  "fulfillmentMode": "courier",
  "sellerGroups": [
    {
      "sellerId": "…",
      "sellerName": "…",
      "deliveryFeeGnf": 5000,
      "lines": [
        {
          "listingId": "…",
          "title": "…",
          "qty": 2,
          "unitDisplayPriceGnf": 45000,
          "lineTotalGnf": 90000,
          "coverUrl": "…"
        }
      ]
    }
  ],
  "blocks": [],
  "expiresAt": "…"
}
```

If `blocks` non-empty → cannot pay. Re-quote when cart revision or address changes.

Line prices are **buyer display** (`priceGnf`) — commission already inside. No separate commission line.

---

## Pay (Orange Money)

```http
POST /api/v1/checkout/payments
Authorization: Bearer …
Idempotency-Key: <uuid>
```

```json
{
  "cartRevision": "rev_12",
  "fulfillmentMode": "courier",
  "address": { },
  "orangeMoneyPhone": "+224620000099",
  "quoteGrandTotalGnf": 100000
}
```

| Response | |
|----------|--|
| `paymentIntentId` | Poll id |
| `status` | `pending_customer_approval` → … |
| `orderIds` | **N orders** (one per seller) |
| `clientAction.pollUrl` | `/api/v1/checkout/payments/:id` |

**Never collect / store OM PIN.** Prefill OM phone from address; allow change.

### Poll

```http
GET /api/v1/checkout/payments/:paymentIntentId
```

| Status | UX |
|--------|-----|
| `pending_customer_approval` / `processing` | Spinner — confirm on phone |
| `succeeded` | Confirmation; cart cleared server-side |
| `failed` / `cancelled` / `expired` | Error / retry (new intent) |

Stale quote → `TOTAL_CHANGED` (409) → re-quote.

---

## Confirmation

| Outcome | Screen |
|---------|--------|
| Success + proximity / shopLocal | Large **4-digit** `pickupCode` on order |
| Success + courier | Order id(s), total, ETA copy, track CTA |

Orders created at intent: status `ORDERED` until webhook → `PAID`. Fetch buyer orders for pickup codes after success.

---

## Errors (checkout-relevant)

| Code | HTTP |
|------|------|
| `CART_EMPTY` | 400 |
| `MIXED_PROXIMITY_COURIER` | 400 |
| `INVALID_FULFILLMENT` / `INVALID_ADDRESS` / `INVALID_ZONE` / `INVALID_OM_PHONE` | 400 |
| `OUT_OF_STOCK` / `QTY_EXCEEDS_STOCK` / `LISTING_UNAVAILABLE` / `PRICE_CHANGED` / `TOTAL_CHANGED` / `CART_REVISION_MISMATCH` | 409 |
| `IDEMPOTENCY_CONFLICT` | 409 |
| `UNAUTHORIZED` | 401 |

---

## Do not copy from mock

| Mock | Production |
|------|------------|
| In-memory cart | Server cart + `revision` |
| Always OM success | Poll + webhook |
| One order / first seller | N orders per payment |
| Guest fallback user | 401 without session |
| Jump to paid | Wait for `succeeded` |

---

## Checklist

- [ ] Persist cart revision; send on quote/pay  
- [ ] Validate before address  
- [ ] Zone / quartier matrix for courier  
- [ ] Idempotency-Key on every pay attempt  
- [ ] Poll until terminal status  
- [ ] Show pickup code only when present  
- [ ] Never store OM PIN  
