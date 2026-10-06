# Messaging handoff — Flutter (mobile)

**Status:** Shipped on Nest (redeploy required for new admin/unread routes)  
**Audience:** Flutter Messages tab (Support + Sellers)  
**Auth:** `Authorization: Bearer <consumer accessToken>` · `x-locale: FR|EN`  
**Related:** [messaging-admin-web-handoff.md](./messaging-admin-web-handoff.md) · SRS offers/messaging

Drop `MockChatService`. Dual-role: same user can be buyer **or** shop owner in `tab=sellers` threads.

---

## Principles

| Rule | Behaviour |
|------|-----------|
| Kinds | `SELLER` \| `SUPPORT` (API uppercase; DB stores lowercase) |
| Destination | Never client-set; enseigne threads return `messagingDisabled: true` |
| Off-platform | Seller threads only → `MESSAGE_BLOCKED` |
| Support filter | **Not** applied (agents may share links) |
| System cards | Server-only from order/payment/dispute hooks |
| CLOSED support | User send **auto-reopens** → `PENDING_AGENT` |

---

## Endpoints

### Inbox

```http
GET /api/v1/conversations?tab=sellers|support&limit=30
→ { "items": Conversation[], "nextCursor": null, "unreadTotal": 2 }

GET /api/v1/conversations/unread-count
→ { "sellers": 3, "support": 1, "total": 4 }
```

`tab=sellers` includes threads where you are **buyer or shop owner**. Use `myRoleInThread`: `BUYER` \| `SELLER`.

### Support singleton

```http
GET /api/v1/conversations/support
```

Get-or-create + localized welcome system text.

### Open seller chat (PDP Demander)

```http
POST /api/v1/conversations
{ "sellerProfileId": "…", "listingId": "…" }
```

Aliases: `sellerId`, `productId`. Enseigne → conversation with `messagingDisabled: true` (sends fail with `MESSAGING_DISABLED`).

### Messages

```http
GET /api/v1/conversations/:id/messages?after=&cursor=&limit=50
→ { "items": Message[], "nextCursor": null, "serverNow": "…Z" }

POST /api/v1/conversations/:id/messages
{ "kind": "text", "text": "Bonjour" }

POST /api/v1/conversations/:id/messages/images
{ "publicId": "fripcash/chat/…", "url": "https://res.cloudinary.com/…", "mimeType": "image/jpeg" }

POST /api/v1/conversations/:id/read
→ { "ok": true, "unreadCount": 0 }
```

`after` is **optional**. Images: `POST /media/cloudinary-sign` `{ "folder": "chat" }` then upload.

---

## Conversation DTO (viewer-relative)

```ts
{
  id, kind: "SELLER" | "SUPPORT",
  title, subtitle, imageUrl,
  buyerUserId, sellerProfileId, listingId, orderId,
  sellerType: "PARTICULIER" | "BOUTIQUE" | "ENSEIGNE" | null,
  messagingDisabled, myRoleInThread: "BUYER" | "SELLER" | "USER",
  unreadCount, lastMessageAt, lastMessagePreview,
  supportStatus?, assignedAgentId?, assignedAgentName?,
  createdAt, updatedAt
}
```

When you are the **seller**, `title` = buyer name (not your shop).

## Message DTO

```ts
{
  id, conversationId, kind: "text" | "image" | "card",
  senderRole: "BUYER" | "SELLER" | "SUPPORT_AGENT" | "SYSTEM",
  senderUserId, senderDisplayName, isMine,
  text, imageUrl, imagePublicId, card, createdAt, clientBlocked
}
```

Agent bubbles: `senderDisplayName = "Support FripCash"`.

---

## Flutter map

| UI | API |
|----|-----|
| Support tab | `?tab=support` |
| Sellers tab | `?tab=sellers` |
| Open support | `GET /conversations/support` |
| PDP Demander | `POST /conversations` |
| Badge | `GET /conversations/unread-count` |
| Poll | `GET …/messages?after=<lastCreatedAt>` |

Confirm receipt / dispute from cards → existing order APIs (not messaging).
