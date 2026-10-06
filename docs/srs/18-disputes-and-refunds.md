# 18 — Disputes, refunds & reports

**Status:** Product UI exists (app order/chat dispute + admin Litiges). This file is the **full end-to-end SRS** so BE does not guess.

**Backend contract:** [Orders / disputes](../from-be/orders-mobile-flutter-handoff.md) · live OpenAPI

Related: [08-offers-and-messaging.md](./08-offers-and-messaging.md), [09-wallet-escrow-commissions.md](./09-wallet-escrow-commissions.md), [12-admin.md](./12-admin.md).

---

## 0. Escrow money model (must be true)

```text
Buyer pays (Orange Money)
        ↓
Funds = ESCROW HELD (pending — NOT in seller withdrawable balance yet)
        ↓
Goods delivered / handed over
        ↓
Buyer confirms receipt  ──OR──  auto-confirm after policy window (if product adds it)
        ↓
Funds RELEASED → seller wallet (then seller can withdraw)
```

**Until release:** money is **pending / locked**. Seller sees “en séquestre”, not spendable cash.

| Event | Escrow |
|-------|--------|
| Payment success | Hold |
| Buyer confirms OK | Release → seller |
| Anyone opens litige | **Stay locked** (or re-lock if somehow mid-release) |
| Seller voluntary refund | Release → buyer (full or amount seller chose) |
| Admin resolve | Per outcome (refund / partial / release seller) |

This protects both sides: buyer isn’t charged-and-gone if goods are bad; seller isn’t unpaid if buyer “plays victim” after damaging goods — admin (and evidence) decide.

---

## 1. Concepts (do not mix)

| Concept | Who starts | Goal |
|---------|------------|------|
| **Offer / “bid”** | Buyer | Negotiate price with **seller** |
| **Chat seller** | Buyer / seller | Message each other |
| **Signalement** | Any user | Flag listing/user → admin moderation (**no escrow move**) |
| **Litige / dispute** | **Buyer or seller** | Escrow stays locked → investigation → money outcome |
| **Seller voluntary refund** | Seller only | Seller agrees to refund while funds still in escrow (no need to “win” a fight) |

---

## 2. Offers & chat (short)

See [08-offers-and-messaging.md](./08-offers-and-messaging.md).  
Dispute can be opened from order detail **or** from chat system cards (confirm receipt / dispute locked).

---

## 3. Who can open a litige (buyer AND seller)

### 3.1 Buyer reasons (examples)
- Never arrived  
- Damaged / not as described  
- Wrong item  

### 3.2 Seller reasons (examples) — **required**
Buyer may spoil / misuse the product then claim “it arrived broken” to get a refund. Seller must be able to:
- Open their **own claim** on the same order  
- Respond when admin asks “is there a problem?”  
- Attach **camera evidence** of condition at handoff / packaging / returned state  

### 3.3 Gates
- Order paid; escrow still relevant (held or dispute window).  
- Not already `resolved` / fully refunded.  
- Both parties can add claims/messages on an open dispute (thread under the litige).

---

## 4. Evidence: camera capture only (anti-fraud)

**Product rule for dispute evidence photos:**

| Allowed | Not allowed |
|---------|-------------|
| **Live camera snap** in-app (`ImageSource.camera`) | Gallery / file import / screenshots from device |
| Multiple snaps if needed | Pre-downloaded AI / stock / edited imports |

**Why:** Gallery makes it trivial to upload AI or old fraud images. Camera raises the bar (still not perfect — note in open questions: EXIF, liveness, watermark with order id — BE/client enhancements later).

Apply to:
- Buyer dispute evidence  
- Seller counter-claim evidence  
- Optional: admin-requested “take a photo now” step  

Client: dispute evidence picker = **camera only** (no gallery button).  
BE: store media with `source=camera`, `capturedAt`, `orderId`, `uploaderRole`; reject uploads that are not from the dispute evidence endpoint if possible.

Chat **general** images may still allow gallery (product decision); **litige evidence** = camera-only.

---

## 5. Investigation flow (admin ↔ parties)

### 5.1 Open
1. Buyer **or** seller opens litige + reason + camera evidence.  
2. Order → `disputed`.  
3. Escrow **locked**.  
4. Admin Litiges queue: `open`.

### 5.2 Admin contacts the other party
Admin can send an **official dispute message** (in-app / push), e.g. to seller:

> “Un litige a été ouvert sur la commande X. Y a-t-il un problème de ton côté ? Réponds Oui / Non et ajoute des preuves (caméra).”

| Seller reply | Next |
|--------------|------|
| **Oui** (acknowledges issue) | Admin may refund / partial (or ask seller to use **voluntary refund**) |
| **Non** + seller claim + camera proof | Admin keeps investigating both sides |
| No reply within SLA | Admin decides with available evidence |

Buyer can be asked the same way if **seller** opened the litige first.

### 5.3 Seller voluntary refund (while money still pending)
Because funds are still in escrow, **seller can choose to refund** without waiting for a “guilty” verdict:

| Action | Effect |
|--------|--------|
| Seller **Rembourser (total)** | Escrow → buyer; dispute/order closed as refunded |
| Seller **Rembourser (partial)** | Part → buyer; remainder → seller (or still held until confirm — BE documents) |
| Seller **Contester** | Stays disputed; admin decides |

Voluntary refund is a **seller** capability on disputed (or even pre-dispute delivered) orders while escrow held.  
Admin can still override if abuse is detected.

### 5.4 Admin final outcomes
| Outcome | Money |
|---------|--------|
| `refund_buyer` | Full escrow → buyer |
| `partial_refund` | Split per admin amount |
| `release_seller` | Escrow → seller (buyer claim rejected / seller claim upheld) |

Admin-only resolve API. Audited.

### 5.5 After resolve
- Notify buyer + seller  
- Wallet ledger entries  
- Chat/order system card  
- Dispute `resolved`

```text
Payment → ESCROW HELD (seller cannot withdraw yet)
                │
     ┌──────────┼──────────┐
     │          │          │
 Buyer OK   Litige      Seller voluntary
 confirm    (buyer or    refund
     │      seller)         │
     ▼          ▼          ▼
 Release    LOCKED      Refund path
 → seller   Admin asks other party
            + camera evidence
            + seller may refund
            Admin: full / partial / release
```

---

## 6. Signalements (separate)

Listing/user report → admin **Signalements**. Does **not** move escrow by itself.

---

## 7. API sketch (extended)

### Escrow lifecycle
Documented under orders/payments; release only on confirm or resolve/voluntary refund.

### Disputes
| Method | Path | Who |
|--------|------|-----|
| POST | `/orders/:id/disputes` | Buyer **or** seller (`reason`, role) |
| POST | `/disputes/:id/evidence` | Party — **camera capture upload only** |
| POST | `/disputes/:id/messages` | Party or admin (investigation thread) |
| POST | `/admin/disputes/:id/ask-party` | Admin prompts seller/buyer for Yes/No + evidence |
| POST | `/orders/:id/seller-refund` | Seller voluntary refund `{ amount: full \| number }` while escrow held |
| POST | `/admin/disputes/:id/resolve` | `{ outcome, amount?, notes? }` |

`outcome`: `refund_buyer` | `partial_refund` | `release_seller`

### Evidence upload
- Endpoint accepts dispute evidence with metadata proving capture session (client sends `captureMode=camera`).  
- Soft rule v1: client UI camera-only; harden later (server-side checks).

---

## 8. Acceptance checks
- [ ] Seller cannot withdraw sale proceeds until escrow release.  
- [ ] Buyer **and** seller can open / respond on a litige.  
- [ ] Dispute evidence UI is **camera-only** (no gallery).  
- [ ] Admin can message parties and collect Yes/No + counter-evidence.  
- [ ] Seller can voluntarily refund (full/partial) while escrow pending.  
- [ ] Admin can still full / partial / release_seller.  
- [ ] Signalement ≠ escrow movement.
