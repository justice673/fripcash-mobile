# Flutter / Admin → Nest — Messaging handoff (Sellers + Support FripCash)

**From:** Flutter mobile + Admin web (product / FE)  
**To:** Nest BE  
**Date:** 2026-10-02  
**Priority:** High — Messages tab UI is built; Flutter still on **mocks**  
**Env:** `http://62.84.179.126:3010`  
**Base path:** `/api/v1`  
**Locales:** `x-locale: FR` | `EN`

**Related product:** SRS `docs/srs/08-offers-and-messaging.md`  
**Out of scope for this doc:** Offers/bids full checkout token flow (separate follow-up if needed). This doc is **conversations + messages + admin support inbox**.

---

## 0. Why this exists

Flutter **Messages** has two tabs that match the product:

| Tab | Purpose |
|-----|---------|
| **FripCash Support** | User ↔ platform agents (singleton support thread per consumer) |
| **Sellers** | Buyer ↔ seller threads (optionally tied to a listing / order) |

Today Flutter uses `MockChatService` / `mock_messages.dart`. Nest OpenAPI already lists some **consumer** conversation routes, but:

1. Response DTOs are underspecified (empty `200` descriptions).  
2. **Admin support inbox / agent reply APIs are missing** from OpenAPI.  
3. We need a **single production contract** Flutter + Admin dashboard can both implement against.

Please treat this file as the source of truth. Ship or complete endpoints so FE can drop mocks. Reply with a short `docs/from-be/messaging-*-handoff.md` once live.

---

## 1. Product principles (non-negotiable)

1. **AuthZ:** only participants (buyer, seller, or assigned support agent / admin with permission) can read/write a conversation.  
2. **Two conversation kinds only:** `SELLER` | `SUPPORT`.  
3. **One account, two hats (critical — dual role):** becoming a shop owner does **not** create a second login. The same consumer user can:
   - Message **other** shops (they act as **buyer** in those threads)
   - Receive messages **on their own shop** (they act as **seller** in those threads)  
   Both appear in the mobile **Messages → Sellers** tab (same `kind=SELLER` list). There is **no** separate “Buyers” tab in v1.  
   Viewer-relative fields (`title`, `subtitle`, `imageUrl`, `isMine`, `unreadCount`) must flip for the current user — e.g. when you are the seller, `title` = **buyer display name**, not your own shop name.  
4. **Enseigne / partner brands:** buyer↔seller messaging disabled (`messagingDisabled=true`); reject sends with `MESSAGING_DISABLED`.  
5. **Off-platform filter** on **seller** threads (phones, emails, WhatsApp, Telegram, social, bare URLs) → `MESSAGE_BLOCKED`. Support threads may skip this (agents need contact flexibility) — confirm.  
6. **System cards** (order/escrow/confirm/dispute) are **server-authored** from order events. Clients never invent them.  
7. **Support** is a **singleton** thread per consumer user (`GET /conversations/support` get-or-create).  
8. **Admin dashboard** is the agent workspace for `SUPPORT` threads (list, open, reply, assign, close). Seller threads are visible to admin only for moderation / dispute (read or intervene with audit).  
9. Currency on cards / amounts: **GNF integers**. Timestamps: **ISO-8601 UTC with `Z`**.  
10. Images: Cloudinary (or documented upload) — same pattern as listings; no silent MinIO localhost URLs in browser.

### 1.1 Role switching — what it is / isn’t

| Concept | Meaning |
|---------|---------|
| **Become seller** | Adds a `SellerProfile` on the **same** user. Account stays one. |
| **Seller mode / Sell hub** | UI for listings, orders, wallet tools — **not** a second messaging identity. |
| **Messages → Sellers** | All `kind=SELLER` threads where **you** are either the buyer **or** the shop owner. Empty copy today is buyer-biased (“conversations with sellers”); product may later rename to “Chats” / “Inbox”. |
| **Messages → Support** | You ↔ FripCash agents only. Same whether you sell or not. |
| **Admin `/admin/support`** | Agents answer Support threads. Not where shop owners reply to buyers. |

Shop owners reply to customer DMs **in the same Flutter Messages tab** (as participant). Admin is only for platform Support.

---

## 2. Domain model

```
User (consumer)
 ├── Conversation(kind=SUPPORT)     ──1── Support agents (admin)
 └── Conversation(kind=SELLER)[]    ──N── SellerProfile (+ optional listingId, orderId)
         └── Message[]              text | image | card
```

### 2.1 Conversation

```ts
type ConversationKind = "SELLER" | "SUPPORT";

type Conversation = {
  id: string;
  kind: ConversationKind;

  /** Viewer-relative */
  title: string;                 // seller shop/display name OR "Support FripCash" / localized
  subtitle: string;              // last message preview OR product title
  imageUrl: string | null;       // avatar / product cover / support icon URL

  buyerUserId: string;
  sellerProfileId: string | null; // SELLER only
  listingId: string | null;       // optional product context
  orderId: string | null;         // optional order overlay

  sellerType: "PARTICULIER" | "BOUTIQUE" | "ENSEIGNE" | null;
  messagingDisabled: boolean;     // true for ENSEIGNE seller threads

  unreadCount: number;            // for current viewer
  lastMessageAt: string;          // ISO
  lastMessagePreview: {
    kind: "text" | "image" | "card";
    text: string | null;          // truncated; image → localized "Photo"; card → label
  } | null;

  /** SUPPORT only */
  supportStatus?: "OPEN" | "PENDING_AGENT" | "PENDING_USER" | "RESOLVED" | "CLOSED";
  assignedAgentId?: string | null;
  assignedAgentName?: string | null;

  createdAt: string;
  updatedAt: string;
};
```

### 2.2 Message

```ts
type MessageKind = "text" | "image" | "card";

type MessageSenderRole =
  | "BUYER"
  | "SELLER"
  | "SUPPORT_AGENT"
  | "SYSTEM";

type Message = {
  id: string;
  conversationId: string;
  kind: MessageKind;

  senderRole: MessageSenderRole;
  senderUserId: string | null;     // null for SYSTEM
  senderDisplayName: string | null;

  /** Viewer-relative: true if current auth user authored it */
  isMine: boolean;

  text: string | null;
  imageUrl: string | null;
  imagePublicId: string | null;

  card: ChatCardPayload | null;

  createdAt: string;               // ISO — clients format "Hier" / time locally
  clientBlocked: boolean;          // true if stored as blocked attempt (optional; prefer reject)
};
```

### 2.3 System card payload

```ts
type ChatCardKind =
  | "order_summary"
  | "escrow_held"
  | "waiting_confirmation"
  | "payment_released"
  | "dispute_locked"
  | "out_for_delivery"
  | "confirm_receipt";

type ChatCardPayload = {
  kind: ChatCardKind;
  orderId: string;
  productTitle?: string | null;
  productImageUrl?: string | null;
  amountGnf?: number | null;
  deliveryMethod?: string | null;
  confirmed?: boolean;             // confirm_receipt
};
```

| Order event (example) | Emit into buyer↔seller thread if exists |
|-----------------------|------------------------------------------|
| Paid | `order_summary` + `escrow_held` |
| Out for delivery / in transit | `out_for_delivery` |
| Delivered / await confirm | `confirm_receipt` (+ optional `waiting_confirmation`) |
| Receipt confirmed | update `confirmed=true` and/or `payment_released` |
| Dispute opened | `dispute_locked` |

`confirm_receipt` actions call **order APIs** (not messaging):

```http
POST /api/v1/orders/:orderId/confirm-receipt
POST /api/v1/orders/:orderId/disputes
{ "role": "buyer", "reason": "…", "reasonCode": "damaged", "openedVia": "chat" }
```

---

## 3. Consumer / Flutter APIs (mobile)

Auth: `Authorization: Bearer <consumer accessToken>`  
Audience: `CONSUMER`.

### 3.1 Inbox list

```http
GET /api/v1/conversations?tab=sellers|support&cursor=&limit=30
x-locale: FR
```

| Param | Required | Notes |
|-------|----------|-------|
| `tab` | **yes** | `sellers` → `kind=SELLER`; `support` → `kind=SUPPORT` |
| `cursor` | no | Opaque pagination |
| `limit` | no | Default `30`, max `50` |

**`tab=sellers` query (dual role):** return every `SELLER` conversation where the auth user is **either**:

- `buyerUserId == me`, **or**
- `sellerProfileId` belongs to `me`

Do **not** filter to “buyer-only”. A shop owner with no outbound chats but inbound customer questions must still see those threads here.

For each item, set viewer-relative fields:

| You are… | `title` | `imageUrl` | `isMine` on your msgs |
|----------|---------|------------|------------------------|
| Buyer in thread | Shop / seller display name | Shop avatar or listing cover | true for your sends |
| Seller in thread | Buyer display name (or phone mask) | Buyer avatar if any | true for your sends |

Optional helper on Conversation: `myRoleInThread: "BUYER" | "SELLER"` so Flutter can tweak empty/CTA copy later.

**200**

```json
{
  "items": [ /* Conversation[] sorted by lastMessageAt desc */ ],
  "nextCursor": null,
  "unreadTotal": 2
}
```

`unreadTotal` for **this tab** (Flutter can sum both tabs for nav badge, or provide):

```http
GET /api/v1/conversations/unread-count
→ { "sellers": 3, "support": 1, "total": 4 }
```

(Preferred for Messages tab badge.)

### 3.2 Open or reuse seller conversation

```http
POST /api/v1/conversations
{
  "sellerProfileId": "<cuid>",
  "listingId": "<cuid>",
  "orderId": null
}
```

| Rule | Behavior |
|------|----------|
| Same buyer + seller + listing | **Reuse** existing thread (idempotent `200`/`201`) |
| listingId omitted | Reuse by buyer + seller only (document which key you choose — prefer **include listing** when opened from PDP) |
| Enseigne seller | Return conversation with `messagingDisabled=true` **or** `403 MESSAGING_DISABLED` — Flutter needs to show disabled state |
| Missing seller | `404 SELLER_NOT_FOUND` |

Aliases accepted for transition: `sellerId` = `sellerProfileId`, `productId` = `listingId` (OpenAPI today has both — pick one canonical and document).

### 3.3 Support singleton

```http
GET /api/v1/conversations/support
```

**Get or create** the user’s Support FripCash thread.

**200**

```json
{ /* Conversation kind=SUPPORT */ }
```

Optional first system welcome message on create (localized via `x-locale`).

### 3.4 Get conversation

```http
GET /api/v1/conversations/:id
```

403 if not participant (or admin with permission).

### 3.5 List messages

```http
GET /api/v1/conversations/:id/messages?cursor=&after=&limit=50
```

| Param | Notes |
|-------|-------|
| `after` | Message id or ISO — return messages **newer** than this (polling / realtime catch-up) |
| `cursor` | Page older history (scroll up) |
| `limit` | Default 50, max 100 |

**Important:** OpenAPI currently marks `after` as **required** — please make **`after` optional**. First open = latest page without `after`.

**200**

```json
{
  "items": [ /* Message[] ascending by createdAt */ ],
  "nextCursor": "…",
  "serverNow": "2026-10-02T08:00:00.000Z"
}
```

### 3.6 Send text

```http
POST /api/v1/conversations/:id/messages
{
  "kind": "text",
  "text": "Bonjour, toujours disponible ?"
}
```

Accept `body` as alias of `text` if needed for backward compat.

Emoji: plain Unicode in `text` is allowed (Flutter ships an emoji picker). No separate emoji endpoint.

| Validation | Code |
|------------|------|
| Empty / whitespace | `EMPTY_MESSAGE` 400 |
| Not participant | `FORBIDDEN` 403 |
| `messagingDisabled` | `MESSAGING_DISABLED` 403 |
| Off-platform content (seller threads) | `MESSAGE_BLOCKED` 400 |
| Support resolved/closed (optional) | `CONVERSATION_CLOSED` 400 |

**Blocked patterns (seller threads)** — mirror Flutter `lib/utils/chat_message_guard.dart` **server-side** (client filter alone is not enough):

| Pattern | Examples |
|---------|----------|
| Phone-like digit runs | `+224 620…`, `620 00 00 00` |
| Email | `a@b.com` |
| WhatsApp | `whatsapp`, `wa.me` |
| Telegram | `telegram`, `t.me` |
| Social | `facebook`, `fb.com`, `instagram`, `instagr.am` |
| Bare URLs | `http(s)://…` |

Return:

```json
{
  "statusCode": 400,
  "code": "MESSAGE_BLOCKED",
  "message": "…",
  "details": ["Off-platform contact is not allowed"]
}
```

**Support threads:** do **not** apply this filter (agents may share help links / ask for order ids). Confirm in `from-be`.

### 3.7 Send image

```http
POST /api/v1/conversations/:id/messages/images
```

**Preferred flow (align with catalogue media):**

1. `POST /api/v1/media/cloudinary-sign` `{ "folder": "chat" }` **or** reuse `listings` / dedicated `chat` folder  
2. Upload to Cloudinary  
3. `POST …/messages/images` with JSON:

```json
{
  "publicId": "fripcash/chat/…",
  "url": "https://res.cloudinary.com/…",
  "mimeType": "image/jpeg"
}
```

OpenAPI note today: “JSON body with imageUrl for now” — fine for v1 if documented; still validate URL host allowlist (your Cloudinary cloud).

| Rule | Detail |
|------|--------|
| Types | jpeg / png / webp |
| Max size | Document (e.g. 8 MB) |
| Gallery + camera | Allowed in general chat |
| Litige evidence | **Separate** dispute evidence API (camera-only) — not this endpoint |

### 3.8 Mark read

```http
POST /api/v1/conversations/:id/read
```

Clears `unreadCount` for **current viewer**. Idempotent.

**200** `{ "ok": true, "unreadCount": 0 }`

### 3.9 Realtime (v1)

| Option | Notes |
|--------|-------|
| Polling | `GET …/messages?after=<lastId>` every N seconds while chat open — **acceptable v1** |
| Pusher / WS | Preferred later: event `chat.message` with `conversationId` |

Push notification:

```json
{
  "type": "chat.message",
  "conversationId": "…",
  "title": "…",
  "body": "…"
}
```

---

## 4. Admin dashboard APIs (Support inbox) — **must ship**

Auth: admin Bearer. Permission suggestion: `support:*` or reuse `catalog:*` / dedicated `messaging.support`.

Flutter Support tab is useless if agents cannot answer from **Admin web**.

### 4.1 List support conversations

```http
GET /api/v1/admin/support/conversations
  ?status=OPEN|PENDING_AGENT|PENDING_USER|RESOLVED|CLOSED|ALL
  &assignedTo=me|unassigned|<agentUserId>
  &q=
  &cursor=
  &limit=20
```

**200**

```json
{
  "items": [
    {
      "id": "conv_…",
      "kind": "SUPPORT",
      "title": "Aïssatou Bah",
      "subtitle": "Problème de livraison…",
      "imageUrl": null,
      "buyerUserId": "…",
      "buyerPhone": "+2246…",
      "buyerDisplayName": "Aïssatou Bah",
      "supportStatus": "PENDING_AGENT",
      "assignedAgentId": null,
      "assignedAgentName": null,
      "unreadCount": 2,
      "lastMessageAt": "2026-10-02T07:55:00.000Z",
      "lastMessagePreview": { "kind": "text", "text": "…" },
      "createdAt": "…",
      "updatedAt": "…"
    }
  ],
  "nextCursor": null,
  "counts": {
    "OPEN": 12,
    "PENDING_AGENT": 5,
    "PENDING_USER": 4,
    "RESOLVED": 40,
    "CLOSED": 10,
    "unassigned": 5
  }
}
```

### 4.2 Get support conversation + user context

```http
GET /api/v1/admin/support/conversations/:id
```

Include sidebar context for agents:

```json
{
  "conversation": { /* Conversation */ },
  "buyer": {
    "id": "…",
    "displayName": "…",
    "phone": "…",
    "locale": "FR",
    "createdAt": "…"
  },
  "recentOrders": [
    { "id": "…", "status": "…", "totalGnf": 0, "createdAt": "…" }
  ]
}
```

### 4.3 List / send messages (agent)

```http
GET  /api/v1/admin/support/conversations/:id/messages?cursor=&after=&limit=50
POST /api/v1/admin/support/conversations/:id/messages
{
  "kind": "text",
  "text": "Bonjour, nous regardons votre dossier…"
}
```

Agent image send: same as consumer image attach (Cloudinary → JSON).

`senderRole` on agent messages = `SUPPORT_AGENT`.

### 4.4 Assign / status

```http
POST /api/v1/admin/support/conversations/:id/assign
{ "agentUserId": "<adminUserId>" | null }

POST /api/v1/admin/support/conversations/:id/status
{ "status": "OPEN" | "PENDING_AGENT" | "PENDING_USER" | "RESOLVED" | "CLOSED" }
```

| Transition | Notes |
|------------|-------|
| User sends | → `PENDING_AGENT` (if was PENDING_USER / RESOLVED reopen policy — document) |
| Agent sends | → `PENDING_USER` |
| Resolve / close | Agent only; optional auto-close after N days |

### 4.5 Mark read (agent)

```http
POST /api/v1/admin/support/conversations/:id/read
```

### 4.6 Optional: admin view of seller threads (moderation)

```http
GET /api/v1/admin/conversations/:id
GET /api/v1/admin/conversations/:id/messages
```

Read-only by default. Write only with elevated permission + audit log. Needed for dispute investigation.

### 4.7 Internal notes (agent-only, not visible to consumer)

```http
GET  /api/v1/admin/support/conversations/:id/notes
POST /api/v1/admin/support/conversations/:id/notes
{ "text": "Client a déjà ouvert un litige #…" }
```

```ts
type SupportNote = {
  id: string;
  conversationId: string;
  authorAgentId: string;
  authorName: string;
  text: string;
  createdAt: string;
};
```

Notes **never** appear in consumer `GET …/messages`. Separate table / `visibility=INTERNAL`.

### 4.8 Permissions & roles

| Permission | Ability |
|------------|---------|
| `support.read` | List + open SUPPORT threads |
| `support.reply` | Send messages as agent |
| `support.assign` | Assign / unassign agents |
| `support.status` | Change status / resolve / close |
| `support.notes` | Read/write internal notes |
| `messaging.moderate` | Read seller threads (dispute) |
| `messaging.intervene` | Rare: post as SYSTEM / force-close seller thread (audit required) |

Admin JWT must carry these (or a single `support:*` super-permission for v1). Return `403 FORBIDDEN` with clear `code` if missing.

Suggested agent identity on messages:

```json
{
  "senderRole": "SUPPORT_AGENT",
  "senderUserId": "<adminUserId>",
  "senderDisplayName": "Support FripCash",
  "isMine": true
}
```

Consumer Flutter always shows agent bubbles as **Support FripCash** (not personal agent name) unless product decides otherwise — keep `senderDisplayName` stable for mobile.

### 4.9 Status machine (support) — exact rules

```
                  user creates / opens
                         │
                         ▼
              ┌──── OPEN / PENDING_AGENT ◄──── user message (reopen)
              │              │
              │         agent replies
              │              ▼
              │        PENDING_USER
              │              │
              │         user replies
              │              ▼
              │        PENDING_AGENT
              │
              ├── agent → RESOLVED  (thread still readable; new user msg → PENDING_AGENT)
              └── agent → CLOSED    (optional: reject new user msgs with CONVERSATION_CLOSED
                                     OR auto-reopen — **pick one and document in from-be**)
```

**Recommendation for FripCash:** `CLOSED` still allows user to send → auto-reopen to `PENDING_AGENT` + notify agents. `RESOLVED` same. Only hard-lock if account banned.

### 4.10 Admin UI contract (what Admin web will build)

**Route:** `/admin/support` (primary). Optional deep link `/admin/support/:conversationId`.

| Pane | Data source | Behavior |
|------|-------------|----------|
| Left inbox | `GET /admin/support/conversations` | Filters: status chips, `assignedTo=me\|unassigned`, search `q` (name/phone). Sort `lastMessageAt desc`. Badge = `counts.PENDING_AGENT` + unassigned |
| Center thread | `GET …/messages` + poll/`after` | Bubbles: user (left) vs agent (right). SYSTEM cards if any. Timestamp grouping. On open → `POST …/read` |
| Right context | `GET …/conversations/:id` | Buyer name, phone, locale, join date; last 5 orders with status + link to order admin; assign dropdown; status dropdown; notes panel |
| Composer | `POST …/messages` (+ images) | Text + image; disabled only if policy says so for CLOSED. Enter = send |
| Header actions | assign / status / resolve | Optimistic UI + toast on error |

**Realtime for admin (v1):** polling every 5–10s on list + open thread is OK. Later: same `chat.message` push / WS room `support:inbox`.

**Empty states:** no PENDING_AGENT → “Inbox zero”; search miss → “Aucun résultat”.

**i18n:** Admin can be FR-first; still honor `x-locale` on API errors.

### 4.11 Seed / test expectations for BE

Please seed at least:

1. One SUPPORT conversation with `PENDING_AGENT` + 2 unread user messages  
2. One `PENDING_USER` assigned to a demo admin  
3. One seller thread with a system `order_summary` card (for moderation path)  
4. One enseigne seller where consumer `POST /conversations` returns `messagingDisabled=true`

Credentials for admin reply testing belong in `from-be` reply doc (not here).

### 4.12 What admin does **not** do in this feature

- Offers / bid accept-refuse (seller tools / offers API)  
- Refund / release escrow (orders / disputes APIs — agents may **link** from context)  
- Listing moderation report queue (separate `admin/reports`)  
- Courier↔support chat (courier product surface — out of scope unless you already share SUPPORT kind)

---

## 5. Flutter UI ↔ API map

| Flutter surface | API |
|-----------------|-----|
| Messages → Support tab | `GET /conversations?tab=support` |
| Messages → Sellers tab | `GET /conversations?tab=sellers` |
| Empty support | Empty `items` → current empty state copy |
| Empty sellers | Empty `items` → “Discover items” CTA |
| Open support chat | `GET /conversations/support` then messages |
| PDP “Demander” | `POST /conversations` → chat screen |
| Chat send text | `POST …/messages` |
| Chat send image | Cloudinary + `POST …/messages/images` |
| Open thread | `POST …/read` + poll `messages?after=` |
| Enseigne | Show disabled banner when `messagingDisabled` |
| System cards | Render `card.kind`; confirm/dispute → order endpoints |
| Nav badge | `GET /conversations/unread-count` |

---

## 6. Error catalogue

| Code | HTTP | When |
|------|------|------|
| `UNAUTHORIZED` | 401 | Missing/invalid token |
| `FORBIDDEN` | 403 | Not a participant |
| `FORBIDDEN_AUDIENCE` | 403 | Wrong surface (courier token etc.) |
| `NOT_FOUND` | 404 | Conversation / seller missing |
| `EMPTY_MESSAGE` | 400 | Blank text |
| `MESSAGE_BLOCKED` | 400 | Off-platform content |
| `MESSAGING_DISABLED` | 403 | Enseigne / disabled thread |
| `CONVERSATION_CLOSED` | 400 | Support closed |
| `VALIDATION_ERROR` | 400 | Bad DTO |
| `RATE_LIMITED` | 429 | Spam protection |
| `MEDIA_INVALID` | 400 | Bad image |

Always return JSON `{ statusCode, code, message, details?, correlationId, locale }` — never empty bodies.

---

## 7. What OpenAPI shows today (gap list)

| Area | Live OpenAPI | Need |
|------|--------------|------|
| `GET /conversations?tab=` | Present | Full `Conversation` DTO + pagination + unread |
| `POST /conversations` | Present | Canonical field names + enseigne rules |
| `GET /conversations/support` | Present | Get-or-create + welcome message |
| `GET/POST …/messages` | Present | Optional `after`; message DTO with `isMine`, cards |
| `POST …/messages/images` | Present | Cloudinary attach contract |
| `POST …/read` | Present | Document response |
| `GET /conversations/unread-count` | **Missing** | Add |
| Admin support list/reply/assign/status | **Missing** | Add §4 |
| System card emission from orders | Unknown | Implement + document |
| `from-be` handoff MD | **Missing** | Please publish after ship |

---

## 8. Acceptance checklist

### Consumer / Flutter

- [ ] Support tab loads live threads (or empty) — no mock seed  
- [ ] Sellers tab loads live threads  
- [ ] `GET /conversations/support` opens singleton chat  
- [ ] PDP Demander creates/reuses seller thread  
- [ ] Text + image send works; blocked content returns `MESSAGE_BLOCKED`  
- [ ] Enseigne shows disabled messaging  
- [ ] Unread badge matches server  
- [ ] System cards appear after order events (when thread exists)  
- [ ] Confirm receipt / dispute from card hit order APIs  

### Admin

- [ ] `/admin/support` (or equivalent) lists SUPPORT conversations  
- [ ] Agent can assign, reply, change status, mark read  
- [ ] User sees agent replies in Flutter Support tab  
- [ ] Audit log for admin reads of seller threads (if exposed)  

### Docs

- [ ] Publish `docs/from-be/messaging-mobile-flutter-handoff.md`  
- [ ] Publish `docs/from-be/messaging-admin-web-handoff.md`  
- [ ] OpenAPI schemas filled (not empty `200`)  

---

## 9. Example cURLs

```bash
HOST=http://62.84.179.126:3010
TOKEN=…          # consumer
ADMIN=…          # admin

# Inbox
curl -sS "$HOST/api/v1/conversations?tab=sellers&limit=30" \
  -H "Authorization: Bearer $TOKEN" -H "x-locale: FR"

curl -sS "$HOST/api/v1/conversations?tab=support&limit=30" \
  -H "Authorization: Bearer $TOKEN" -H "x-locale: FR"

# Support singleton
curl -sS "$HOST/api/v1/conversations/support" \
  -H "Authorization: Bearer $TOKEN" -H "x-locale: FR"

# Open seller chat from PDP
curl -sS -X POST "$HOST/api/v1/conversations" \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"sellerProfileId":"…","listingId":"…"}'

# Send
curl -sS -X POST "$HOST/api/v1/conversations/$CID/messages" \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"kind":"text","text":"Bonjour"}'

# Admin support inbox
curl -sS "$HOST/api/v1/admin/support/conversations?status=PENDING_AGENT" \
  -H "Authorization: Bearer $ADMIN" -H "x-locale: FR"

curl -sS -X POST "$HOST/api/v1/admin/support/conversations/$CID/messages" \
  -H "Authorization: Bearer $ADMIN" -H "Content-Type: application/json" \
  -d '{"kind":"text","text":"Nous traitons votre demande."}'
```

---

## 10. Priority

| P0 | Complete consumer conversation DTOs + optional `after` + unread-count |
| P0 | Admin support inbox + agent reply/assign/status |
| P1 | Cloudinary chat image attach (no localhost MinIO) |
| P1 | System cards from order lifecycle |
| P2 | Realtime (Pusher) / push notifications for `chat.message` |

Once P0 is live, Flutter will replace `MockChatService` and Admin will ship `/admin/support`.
