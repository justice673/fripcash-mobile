# Admin ops — Next.js web

**Audience:** Next.js `/admin`  
**API base:** `/api/v1` · Admin JWT only  
**Status:** Shipped on Nest  
**Related:** [admin-fe-handoff.md](./admin-fe-handoff.md) · [15-admin.md](./15-admin.md)

Replace hardcoded KPI zeros and stub lists with these contracts. Sidebar identity from `GET /admin/me`.

---

## Auth

```http
POST /api/v1/auth/admin/login   { "email", "password" }
GET  /api/v1/admin/me
```

Better Auth user ops remain under `/api/v1/auth/admin/*` (list/ban/sessions/…).

---

## Dashboard

```http
GET /api/v1/admin/finance/overview
→ { gmvGnf, escrowGmvGnf, escrowHoldCount, platformCommissionGnf,
    openDisputeCount, activeDeliveries, pendingValidations,
    pendingListings, usersTotal, platform? }

GET /api/v1/admin/stats/timeseries?metric=gmv|commission|orders|users&from=&to=
GET /api/v1/admin/sessions?q=&role=&status=active|expired
GET /api/v1/admin/audit-logs?actorId=&entityType=&action=&from=&to=
```

Lists return `{ items, total, limit, offset }` where noted.

---

## Validations

```http
GET  /admin/seller-verifications?status=pending|approved|rejected&shopKind=
POST /admin/seller-verifications/:id/approve  { reviewerNote? }
POST /admin/seller-verifications/:id/reject   { reviewerNote }  // required

GET  /admin/kyc/individuals|organizations
POST …/approve | …/reject | …/request-resubmission
```

---

## Catalogue & orders

```http
GET/PATCH /admin/listings?status=&q=
GET /admin/orders?status=&fulfillmentMode=&q=
GET /admin/orders/:id
POST /admin/orders/:id/force-status  { status, reason }

GET /admin/shipping-rates
PUT /admin/shipping-rates  { rates: [{ fromZoneId, toZoneId, feeGnf }] }
PATCH /admin/shipping-rates/:id  { feeGnf }
```

Categories/zones: existing `/catalog/categories|zones` (admin write).

**Proximity shop types** (Commerce local — not listing taxonomy):

```http
GET  /catalog/shop-categories?kind=PROXIMITE          # public, anonymous
GET  /admin/catalog/shop-categories                  # incl. inactive + sellersCount
POST /admin/catalog/shop-categories
PATCH /admin/catalog/shop-categories/:id
POST …/:id/activate | …/:id/deactivate
DELETE /admin/catalog/shop-categories/:id
PUT  /admin/catalog/shop-categories/reorder
```

Full contract: [shop-categories-mobile-flutter-handoff.md](./shop-categories-mobile-flutter-handoff.md).  
Admin UI: Catalog → **Proximity shop types**.

---

## Disputes (litiges)

```http
GET /admin/disputes?status=open|under_review|resolved&q=
GET /admin/disputes/:id
PATCH /admin/disputes/:id  { "status": "under_review" }
POST /admin/disputes/:id/resolve
{
  "outcome": "refund_buyer" | "partial_refund" | "release_seller",
  "buyerRefundGnf"?, "sellerReleaseGnf"?, "notes"?
}
```

Do **not** send only `resolved_buyer` / `resolved_seller` — use SRS outcomes + amounts for partial.

---

## Signalements / partners / settings

```http
GET  /admin/reports?type=listing|user|message&status=
POST /admin/reports/:id/resolve  { action: "resolve"|"dismiss", note? }

GET/POST/PATCH /admin/partners

GET/PATCH /admin/platform-settings
{ commissionRateStandard, commissionRateProximite, minWithdrawalGnf,
  maxListingPhotos, disputeWindowHours, maintenanceMode }
```

---

## Couriers / wallets

**Full livreur provisioning + OTP contract:** [courier-admin-provision-handoff.md](../from-be/courier-admin-provision-handoff.md)

```http
POST /admin/couriers                    # create (server temp password once)
GET  /admin/couriers?q=&active=&phoneVerified=&verificationStatus=&zoneId=&page=
GET  /admin/couriers/:userId
PATCH /admin/couriers/:id               { displayName?, zoneIds?, vehicleType?, active?, notesAdmin? }
PATCH /admin/couriers/:id/verification  { status: APPROVED|REJECTED|PENDING, reviewerNote? }
POST /admin/couriers/:id/reset-password { sendSms?, requirePhoneReverify? }
POST /admin/couriers/:id/resend-invite
GET /admin/missions?status=&zoneId=
POST /admin/missions/:id/reassign  { courierId, reason }

GET /admin/wallets · /wallets/:userId · /ledger
POST /admin/wallets/:userId/adjust  { amountGnf, direction, bucket?, reason }
GET /admin/withdrawals?status=
```

---

## Errors

| Code | When |
|------|------|
| `WRONG_AUTH_SURFACE` / `NOT_ADMIN` | Bad audience |
| `REVIEWER_NOTE_REQUIRED` | Reject without note |
| `INVALID_RESOLUTION` | Bad dispute outcome |
| `ADJUST_REASON_REQUIRED` | Wallet adjust |
| `ENTITY_NOT_FOUND` | Missing row |

---

## Do not copy from UI stubs

Hardcoded `0` KPIs, demo empty states, client-only `isAdmin` flags, resolve enums without amounts, sidebar name without `/admin/me`.
