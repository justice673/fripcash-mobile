# Orders & fulfillment — Flutter (mobile)

**Audience:** Flutter orders / seller boutique / courier touchpoints  
**API base:** `/api/v1` · Bearer by audience  
**Status:** Shipped on Nest  
**Related:** [checkout-mobile-flutter-handoff.md](./checkout-mobile-flutter-handoff.md) · [orders-web-nextjs-handoff.md](./orders-web-nextjs-handoff.md) · [10-orders.md](./10-orders.md)

Orders are created at **payment intent** (status `ORDERED`) and become actionable after OM webhook → `PAID` → auto `SELLER_NOTIFIED`. **Server owns transitions** — use action endpoints, not client-faked status.

Status values in API: `ORDERED` | `PAID` | `SELLER_NOTIFIED` | `PREPARING` | `READY_FOR_PICKUP` | `COURIER_ASSIGNED` | `COLLECTED` | `IN_TRANSIT` | `DELIVERED` | `FUNDS_RELEASED` | `FEEDBACK_PENDING` | `DISPUTED` | `REFUNDED`.

---

## Reads

```http
GET /api/v1/orders?as=buyer|seller&filter=&q=&limit=
GET /api/v1/orders/:id
GET /api/v1/orders/:id/timeline
```

Legacy: `GET /orders/purchases`, `GET /orders/sales`.

### Buyer filters

| `filter` | Rule |
|----------|------|
| `all` | default |
| `inProgress` | status &lt; `DELIVERED`, not disputed/refunded |
| `cancelled` | `DISPUTED` \| `REFUNDED` |
| `completed` | ≥ `DELIVERED`, not terminal |

### Seller filters

| `filter` | Rule |
|----------|------|
| `toPrepare` / `needsAction` | before ready / has seller CTA |
| `ready` | `READY_FOR_PICKUP` |
| `shipped` | ready ≤ status &lt; delivered |
| `delivered` | delivered, escrow not released |
| `sold` | ≥ delivered or released |
| `disputed` / `refunded` | |

DTO includes **`nextActions`**: `startPreparing` | `markReadyForPickup` | `confirmHandoff` | `confirmReceipt` | `openDispute` | `rateSeller` | `sellerRefund`. Drive CTAs from this list.

Line snapshots: `lines[].qty`, `title`, `coverUrl`, `unitDisplayPriceGnf`, `unitNetPriceGnf`, `commissionRate` — do not re-fetch live listing for money UI.

---

## Seller actions

| Action | Endpoint | Body |
|--------|----------|------|
| Start preparing | `POST /orders/:id/prepare` | `{}` |
| Ready | `POST /orders/:id/ready` | `{}` |
| Confirm handoff (proximity) | `POST /orders/:id/confirm-handoff` | `{ "pickupCode": "4821" }` |
| Voluntary refund | `POST /orders/:id/seller-refund` | `{ "amountGnf": null }` |
| Open dispute | `POST /orders/:id/disputes` | see below |

**Pickup code required** on handoff — typed match, not one-tap. Mismatch → `PICKUP_CODE_MISMATCH`.

Courier orders at `READY_FOR_PICKUP`: no handoff — wait for courier.

---

## Buyer actions

| Action | Endpoint | Gate |
|--------|----------|------|
| Confirm receipt | `POST /orders/:id/confirm-receipt` | **Only from `DELIVERED`** (policy A) |
| Dispute | `POST /orders/:id/disputes` | Escrow held; not released |
| Rate | `POST /orders/:id/ratings` | After funds released; stars 1–5 |

Confirm while disputed → `DISPUTE_LOCKED`. Escrow release → seller net credited; response includes `escrow.state: "released"`.

```json
POST /orders/:id/disputes
{
  "role": "buyer",
  "reason": "Item arrived damaged",
  "reasonCode": "damaged",
  "openedVia": "order_page"
}
```

Empty reason → `REASON_REQUIRED`. Seller uses `"role": "seller"`.

```json
POST /orders/:id/ratings
{ "stars": 5, "comment": "Fast pickup" }
```

---

## Courier (order-facing)

| Endpoint | From |
|----------|------|
| `POST /courier/missions/:orderId/accept` | `READY_FOR_PICKUP` → `COURIER_ASSIGNED` |
| `POST /orders/:id/collected` | assigned |
| `POST /orders/:id/in-transit` | collected (support even if UI skips) |
| `POST /orders/:id/delivered` | `{ "proofPhotoUrl"? }` from collected/in-transit |

`delivered` alone does **not** release escrow — buyer must confirm.

---

## Escrow banner

| `escrow.state` | Meaning |
|---------------|---------|
| `held` | Money locked after pay |
| `locked` | Dispute open |
| `released` | Confirm / admin release |

---

## Do not copy from mock

| Mock | Production |
|------|------------|
| Qty always 1 | `lines[].qty` |
| One-tap handoff | Typed `pickupCode` |
| Confirm from `inTransit` | Only `DELIVERED` |
| Local-only rating | `POST …/ratings` |
| No seller dispute/refund | Both endpoints exist |
| Fake status client-side | Action endpoints only |

---

## Checklist

- [ ] Wire list filters + `nextActions`  
- [ ] Proximity handoff with code entry  
- [ ] Confirm receipt after delivered  
- [ ] Dispute + rate persisted  
- [ ] Track CTA → order detail  
