# 08 — Offers (“bids”) and messaging

**Backend contract:** [Offers](../from-be/offers-mobile-flutter-handoff.md) · [Messaging](../from-be/messaging-mobile-flutter-handoff.md) · live OpenAPI
(Admin messaging is out of this Flutter app — see messaging-admin-web-handoff.md.)

## 8.1 Offers / negotiation (“Faire une offre” ≈ bid)
This is **buyer ↔ seller** price negotiation — **not** an admin flow.

1. Buyer opens product → **Faire une offre** (hidden for enseigne).  
2. Amount must be **lower** than display price.  
3. Offer stored as `pending`.  
4. Seller inbox: **accept** or **refuse**.  
5. On accept → negotiated price usable at checkout (BE defines lock/token).  
6. Notify both parties.

States: `pending` | `accepted` | `refused`.

## 8.2 Chat with seller
- Thread between buyer and seller (support/admin may read for disputes).  
- Message types: text, image.  
- System cards: order summary, escrow held, waiting confirmation, payment released, **dispute locked**, out for delivery, confirm receipt.  
- From order / confirm-receipt UI, buyer can jump to **open dispute** (see [18-disputes-and-refunds.md](./18-disputes-and-refunds.md)).  
- Enseigne: messaging / “demander” may be disabled.

## 8.3 What is *not* in this file
- Admin refund / partial / release → **file 18**  
- Listing signalement (report) → **file 18**

## 8.4 Requirements for BE
- AuthZ: only participants (or admin/support) read a thread.  
- Persist media for chat images.  
- Push / in-app notification on new message and offer events.
