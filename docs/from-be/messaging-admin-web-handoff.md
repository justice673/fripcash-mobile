# Messaging handoff — Admin web (Support inbox)

**Status:** Shipped on Nest  
**Audience:** Admin Next.js `/admin/support`  
**Auth:** `Authorization: Bearer <admin accessToken>`  
**Permission:** `message:*` (LIST/READ/CREATE/UPDATE/MANAGE)

Shop owners reply to buyers in **Flutter Messages**, not here. Admin is **platform Support** (+ read-only seller thread moderation).

---

## Status machine

```
user message → PENDING_AGENT
agent reply → PENDING_USER
RESOLVED / CLOSED → user message auto-reopens to PENDING_AGENT
```

---

## Endpoints

```http
GET  /api/v1/admin/support/conversations?status=PENDING_AGENT&assignedTo=me|unassigned|&q=&cursor=&limit=20
GET  /api/v1/admin/support/conversations/:id
     → { conversation, buyer, recentOrders[] }

GET  /api/v1/admin/support/conversations/:id/messages?after=&limit=50
POST /api/v1/admin/support/conversations/:id/messages
     { "kind": "text", "text": "…" }

POST /api/v1/admin/support/conversations/:id/assign
     { "agentUserId": "<id>" | null }

POST /api/v1/admin/support/conversations/:id/status
     { "status": "OPEN"|"PENDING_AGENT"|"PENDING_USER"|"RESOLVED"|"CLOSED" }

POST /api/v1/admin/support/conversations/:id/read

GET  /api/v1/admin/support/conversations/:id/notes
POST /api/v1/admin/support/conversations/:id/notes
     { "text": "…" }

# Moderation (read-only seller threads)
GET /api/v1/admin/conversations/:id
GET /api/v1/admin/conversations/:id/messages
```

List response includes `counts`: `OPEN`, `PENDING_AGENT`, `PENDING_USER`, `RESOLVED`, `CLOSED`, `unassigned`.

Internal notes **never** appear on consumer message list.

Agent display name on consumer side: always **Support FripCash**.

---

## UI contract

| Pane | Source |
|------|--------|
| Left inbox | `GET …/support/conversations` |
| Center thread | messages + poll `after` |
| Right context | `GET …/conversations/:id` (buyer + recentOrders) |
| Composer | `POST …/messages` (+ Cloudinary `folder: chat` for images) |

v1 realtime = poll 5–10s.
