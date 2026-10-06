# 06 — Cart, checkout, payments

**Backend contract:** [Checkout](../from-be/checkout-mobile-flutter-handoff.md) · live OpenAPI

## 6.1 Cart
- Buyer can add items from one or multiple sellers.  
- UI may group by seller.  
- Validate stock and listing status at checkout time (server).

## 6.2 Checkout steps
1. Confirm / enter delivery address (zone + detailed address).  
2. Choose fulfillment when applicable (`courier` | `pickup` | `shopLocalDelivery`).  
3. Order summary (subtotal, shipping, total GNF).  
4. Pay via **Orange Money** (phone).  
5. Confirmation; proximity orders show a **4-digit pickup code** (code de retrait) — buyer + shop; not used for courier deliveries.

### Orange Money
- App collects OM phone + confirm (mock).  
- Real **OM PIN** is via Orange Money / PSP — FripCash must not store it.  
- See [19-codes-and-pins.md](./19-codes-and-pins.md).

## 6.3 Fulfillment defaults
| Shop kind | Default |
|-----------|---------|
| proximite | Pickup / shop local delivery (no FripCash courier by default) |
| other | FripCash courier |

## 6.4 Orange Money
- Primary payment rail in product UX.  
- BE integrates real PSP / Orange Money APIs.  
- On success → order moves to paid / escrow held.  
- On failure → order not paid; user can retry.

## 6.5 Fee messaging (product)
Displayed buyer price accounts for platform take. FAQ-style split referenced in UI: Orange Money fee component + FripCash fee (totals align with commission rates in wallet SRS). Exact split must be confirmed in BE pricing module — **server authoritative**.

## 6.6 Multi-seller carts
If cart spans sellers, BE must define: single payment split into multiple orders **or** one order with multiple seller lines. Recommend: **one checkout → N seller orders** sharing payment intent (document chosen approach in API).
