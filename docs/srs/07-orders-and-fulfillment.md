# 07 — Orders and fulfillment

**Backend contract:** [Orders](../from-be/orders-mobile-flutter-handoff.md) · live OpenAPI

## 7.1 Order status pipeline (happy path)
```
ordered → paid → sellerNotified → preparing → readyForPickup
  → courierAssigned → collected → inTransit → delivered
  → fundsReleased → feedbackPending
```

## 7.2 Exception statuses
| Status | Meaning |
|--------|---------|
| disputed | Buyer/seller opened dispute; funds locked |
| refunded | Resolved with refund (full or after partial) |

## 7.3 Actor actions
### Seller
- Start preparing  
- Mark ready for pickup  
- Confirm handoff to courier (when courier flow)  
- Proximity: manage pickup / local delivery + pickup code

### Courier
- Accept / view mission  
- Mark collected → in transit → delivered  
- Optional: transfer mission to peer in same zone

### Buyer
- Track status  
- Confirm receipt (triggers escrow release path)  
- Rate / leave feedback  
- Open dispute (rules TBD with ops: time window after delivery)

## 7.4 Views
- Buyer: “Mes achats”  
- Seller: “Mes ventes” / dashboard tabs (to prepare, shipped, sold)  
- Same user can see **both** after upgrade.

## 7.5 Proximity specifics
- Shared **pickup code** for buyer ↔ shop.  
- No default FripCash courier assignment.

## 7.6 Admin
- List/filter orders; intervene on disputes; audit status history.
