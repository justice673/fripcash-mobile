# Courier missions — Flutter (mobile)

**Audience:** Flutter livreur shell  
**API base:** `/api/v1` · Bearer from courier login (`aud: courier`)  
**Status:** Shipped on Nest  
**Related:** [courier-fe-handoff.md](./courier-fe-handoff.md) · [auth-mobile-flutter-handoff.md](./auth-mobile-flutter-handoff.md) · [wallet-mobile-flutter-handoff.md](./wallet-mobile-flutter-handoff.md)

Replace mock missions / filtered orders with first-class `Mission` resources. **Accept is required** before collect.

---

## Auth

**Provisioning + first-login OTP:** [courier-admin-provision-handoff.md](../from-be/courier-admin-provision-handoff.md)

```http
POST /api/v1/auth/courier/login
{ "phone": "+224…", "password": "…" }
→ status=authenticated | phone_verification_required
```

Only store a full courier session when `status=authenticated` (after OTP if needed). Send `Authorization: Bearer …` on all `/courier/*` and `/missions/*` calls.

**Gates before online / accept:** `phoneVerifiedAt` set + `verificationStatus=approved` + `mustChangePassword=false` + `active`. Else `PHONE_NOT_VERIFIED` / `COURIER_NOT_VERIFIED`.

---

## Profile

```http
GET  /api/v1/courier/me
PATCH /api/v1/courier/me/availability   { "isAvailable": true }
PATCH /api/v1/courier/me/profile        { "displayName"?, "address"? }
POST /api/v1/courier/me/documents       { "type", "fileUrl" }
```

| Field | Notes |
|-------|--------|
| `zoneId` | Primary zone (`zoneIds[0]`) — open pool matches **pickup** zone |
| `isAvailable=false` | Hides **open** pool; **keeps** assigned in-progress missions |
| `verificationStatus` | Prefer `approved` before accept |
| `documents[]` | `nationalId` \| `driversLicense` \| … |

---

## Missions list

```http
GET /api/v1/missions?filter=open|active|completed|all&q=
```

| `filter` | Meaning |
|----------|---------|
| `open` | Unassigned, ready, in my zone; only if available |
| `active` | Open-in-zone (if available) **OR** assigned to me & not delivered |
| `completed` | Delivered by me |
| `all` | active ∪ completed |

Legacy aliases: `GET /courier/missions`, `GET /courier/missions/open`.

### Card fields

`id`, `orderId`, `status` (`open`\|`assigned`\|`collected`\|`in_transit`\|`delivered`\|`cancelled`), `pickupZoneId`, `deliveryZoneId`, `deliveryFeeGnf`, `sellerName`, `createdAt`.

---

## Detail & actions

```http
GET  /api/v1/missions/:id
POST /api/v1/missions/:id/accept
POST /api/v1/missions/:id/collected
POST /api/v1/missions/:id/in-transit
POST /api/v1/missions/:id/delivered   { "proofPhotoUrl"? }
POST /api/v1/missions/:id/transfer    { "toCourierId" }
GET  /api/v1/courier/peers?zoneId=
```

| Step | Gate |
|------|------|
| Accept | Available + verified + open + zone |
| Collect | Assigned to me |
| In-transit | Collected |
| Deliver | Prefer in_transit (collected also allowed) → credits fee |
| Transfer | Same zone peer; fee goes to courier who **delivers** |

Ids accept **mission id or order id**.

Legacy: `POST /courier/missions/:orderId/progress` with `{ "status": "COLLECTED"|"IN_TRANSIT"|"DELIVERED" }`.

---

## Earnings / wallet

```http
GET  /api/v1/courier/earnings?from=&to=
GET  /api/v1/wallet
POST /api/v1/wallet/withdraw
```

`earnings`: `todayGnf`, `periodGnf`, `missionCount`, `availableGnf`, `series[]`.  
Fee ledger: idempotent `delivery_fee:{orderId}` on deliver.

---

## Notifications (courier)

| Type | When |
|------|------|
| `MISSION_OPEN` | New open in zone |
| `COURIER_MISSION_ASSIGNED` | Accept confirm |
| `MISSION_TRANSFERRED_IN` / `_OUT` | Transfer |
| `WALLET_DELIVERY_FEE` | Fee credited |
| `COURIER_MISSION_UPDATED` | Status progress |

Deep link: `missionId` (+ `orderId`).

---

## Errors

| Code | When |
|------|------|
| `COURIER_UNAVAILABLE` | Accept while offline |
| `COURIER_NOT_VERIFIED` | Not approved |
| `MISSION_NOT_IN_ZONE` | Wrong zone |
| `MISSION_ALREADY_ASSIGNED` | Taken |
| `NOT_MISSION_COURIER` | Not assignee |
| `INVALID_MISSION_TRANSITION` | Bad step |
| `NO_PEER_IN_ZONE` / `TRANSFER_NOT_ALLOWED` | Transfer |
| `MISSION_CANCELLED` | Dispute/refund mid-flight |

---

## Flutter mock gaps — do not copy

| Gap | Correct |
|-----|---------|
| No accept / collect on open | Require accept |
| Skip in-transit | Call `/in-transit` |
| Availability hides assigned | Keep in-progress |
| Zone via string `"2"` | Real `zoneId` / `pickupZoneId` |
| Fake earnings padding | Use `/courier/earnings` |
| Shared marketplace inbox | Courier-targeted types |
