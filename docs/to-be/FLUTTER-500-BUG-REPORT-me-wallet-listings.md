# Flutter → Nest — 500 bug report (me / wallet / listings)

**From:** Flutter mobile  
**To:** Nest BE  
**Date:** 2026-09-30  
**Env:** `http://62.84.179.126:3010`  
**Base path:** `/api/v1`  
**Auth:** `Authorization: Bearer <consumer accessToken>`  
**Locale:** `x-locale: FR` (or `EN`)

---

## Summary

After login, Flutter calls three endpoints that your handoffs document as shipped. All three return **HTTP 500** with an **empty / non-JSON body**.

Flutter request shapes match your docs under `docs/from-be/` (`auth-mobile`, `wallet-mobile`, `listings-mobile`).

Please fix Nest so these return **200 + JSON** (or a documented 4xx with `{ code, message }`). Do **not** return empty 500s.

---

## Failing requests (observed in browser / Dio)

```http
GET /api/v1/me
→ 500 Internal Server Error

GET /api/v1/wallet
→ 500 Internal Server Error

GET /api/v1/listings?inStockOnly=true&sort=newest&limit=20
→ 500 Internal Server Error

GET /api/v1/listings?destination=ARTICLES_NEUFS&inStockOnly=true&sort=newest&limit=20
→ 500 Internal Server Error
```

Same pattern also seen for other destinations (`ENSEIGNES`, etc.) — same handler, same 500.

---

## Expected contracts (align both handoffs)

### 1. `GET /api/v1/me`

**Refs:** `from-be/auth-mobile-flutter-handoff.md` §6

**Expected:** `200` + consumer profile used to gate the shell.

Minimum fields Flutter reads:

| Field | Use |
|-------|-----|
| `canBuy` | Hide buy for courier |
| `role` | Display hint |
| `seller.capabilities.*` | Sell / Excel / library CTAs |
| `seller.verificationStatus` | Pending / rejected banners |
| `zoneId` / `address` | Home / profile location |

**Acceptable empty-seller case:** user with no seller profile → still **200**, `seller: null` or empty capabilities — **not** 500.

---

### 2. `GET /api/v1/wallet`

**Refs:** `from-be/wallet-mobile-flutter-handoff.md`

**Expected:** `200`

```json
{
  "ownerUserId": "…",
  "role": "seller",
  "currency": "GNF",
  "availableGnf": 0,
  "pendingEscrowGnf": 0,
  "minWithdrawalGnf": 10000,
  "defaultPayoutMsisdn": null,
  "balanceGnf": 0,
  "escrowGnf": 0
}
```

**Acceptable empty-wallet case:** new user with no ledger → **200** with zeros — **not** 500.  
Alias `GET /api/v1/wallet/balance` should behave the same.

---

### 3. `GET /api/v1/listings` (public discovery)

**Refs:** `from-be/listings-mobile-flutter-handoff.md` (Discovery)

**Flutter calls (all valid per your doc):**

```http
GET /api/v1/listings?inStockOnly=true&sort=newest&limit=20
GET /api/v1/listings?destination=ARTICLES_NEUFS&inStockOnly=true&sort=newest&limit=20
GET /api/v1/listings?destination=SECONDE_MAIN&inStockOnly=true&sort=newest&limit=20
GET /api/v1/listings?destination=QUARTIER_BOUTIQUES&inStockOnly=true&sort=newest&limit=20
GET /api/v1/listings?destination=ENSEIGNES&inStockOnly=true&sort=newest&limit=20
```

| Param | Flutter value | Contract |
|-------|---------------|----------|
| `destination` | optional; enum below | Optional filter |
| `inStockOnly` | `true` | Documented |
| `sort` | `newest` | `newest` \| `priceAsc` \| `priceDesc` \| `recommended` |
| `limit` | `20` | Documented |
| `cursor` | omitted on first page | Optional |

**Destination enum (both docs):**

| Value | Universe |
|-------|----------|
| `SECONDE_MAIN` | Seconde main |
| `ARTICLES_NEUFS` | Articles neufs |
| `QUARTIER_BOUTIQUES` | Quartier |
| `ENSEIGNES` | Enseignes |

**Expected:** `200`

```json
{
  "items": [],
  "nextCursor": null
}
```

Empty catalog must be **`items: []`**, not 500.  
Buyer cards use `displayPriceGnf` (never net).

---

## What is *not* a Flutter bug

| Claim | Reality |
|-------|---------|
| Wrong path | Paths are `/api/v1/me`, `/wallet`, `/listings` as documented |
| Bad destination enum | `ARTICLES_NEUFS` is in your destination table |
| Bad query params | Same example as your discovery line |
| Missing auth | Bearer + `x-locale` sent; wrong token should be **401/403**, not empty **500** |
| Client inventing destination on create | Create omits `destination` (server-owned) — unrelated to these GETs |

If a query were invalid, prefer **`400` + `{ "code", "message" }`**, not an empty 500.

---

## Ask for BE

1. Reproduce with a valid consumer Bearer against `62.84.179.126:3010` (or local Nest).
2. Check Nest / DB logs for stack traces on:
   - `GET /api/v1/me`
   - `GET /api/v1/wallet`
   - `GET /api/v1/listings`
3. Ensure wallet + me rows are created on register/login (or lazy-create on first GET with zeros).
4. Ensure listings discovery handles empty DB without throwing.
5. Always return JSON error bodies on failure, e.g.:

```json
{
  "code": "INTERNAL_SERVER_ERROR",
  "message": "…",
  "correlationId": "…"
}
```

---

## Curl checklist (for BE)

Replace `TOKEN` and host as needed.

```bash
HOST=http://62.84.179.126:3010
TOKEN='<accessToken>'

curl -i -H "Authorization: Bearer $TOKEN" -H "x-locale: FR" \
  "$HOST/api/v1/me"

curl -i -H "Authorization: Bearer $TOKEN" -H "x-locale: FR" \
  "$HOST/api/v1/wallet"

curl -i -H "Authorization: Bearer $TOKEN" -H "x-locale: FR" \
  "$HOST/api/v1/listings?inStockOnly=true&sort=newest&limit=20"

curl -i -H "Authorization: Bearer $TOKEN" -H "x-locale: FR" \
  "$HOST/api/v1/listings?destination=ARTICLES_NEUFS&inStockOnly=true&sort=newest&limit=20"
```

**Done when:** all four return `200` with the JSON shapes above (zeros / empty `items` OK).

---

## Flutter status (FYI)

Client already matches the contracts above. UI shows a retry state on these 500s; marketplace data stays empty until Nest is fixed. No Flutter request-shape change planned for these three endpoints unless you publish a **breaking** contract update.
