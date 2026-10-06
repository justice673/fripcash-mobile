# Wallet, escrow & commissions — Flutter (mobile)

**Audience:** Flutter seller/courier wallet & withdraw  
**API base:** `/api/v1`  
**Status:** Shipped on Nest  
**Related:** [wallet-web-nextjs-handoff.md](./wallet-web-nextjs-handoff.md) · [orders-mobile-flutter-handoff.md](./orders-mobile-flutter-handoff.md) · [12-wallet.md](./12-wallet.md)

Balances are ledger-backed. **Available ≠ escrow.** Seller pending = **seller nets held**, not gross order totals. Never store OM PIN.

---

## GET `/wallet`

```json
{
  "ownerUserId": "…",
  "role": "seller",
  "currency": "GNF",
  "availableGnf": 250000,
  "pendingEscrowGnf": 85500,
  "minWithdrawalGnf": 10000,
  "defaultPayoutMsisdn": "+224620000001",
  "balanceGnf": 250000,
  "escrowGnf": 85500
}
```

| Field | UI |
|-------|-----|
| `availableGnf` | Withdrawable |
| `pendingEscrowGnf` | “En séquestre” |
| Withdraw CTA | Enabled iff `availableGnf ≥ minWithdrawalGnf` |

Also: `GET /wallet/balance` (alias).

---

## Ledger

```http
GET /wallet/ledger?type=&cursor=&limit=
```

Types: `escrow_hold` | `escrow_release` | `platform_commission` | `delivery_fee_credit` | `withdrawal` | `refund` | `partial_refund` | `adjustment`.

---

## Withdraw

```http
POST /wallet/withdraw
Idempotency-Key: <uuid>
{
  "amountGnf": 50000,
  "orangeMoneyPhone": "+224620000001"
}
```

| Rule | |
|------|--|
| Amount | `≥ minWithdrawalGnf` and `≤ availableGnf` |
| Phone | Required GN E.164 |
| Status | `pending` → `succeeded` (PSP stub marks succeeded today) |

```http
GET /wallet/withdrawals/:id
PATCH /wallet/payout-msisdn
{ "orangeMoneyPhone": "+224…" }
```

**Do not** withdraw entire balance blindly / skip phone / ignore min.

---

## Money events (server — for understanding)

| Event | Effect |
|-------|--------|
| Pay succeeded | Hold **seller net** pending; platform commission pending; delivery fee liability |
| Confirm receipt | Net → available; commission → platform revenue |
| Courier delivered | `delivery_fee_credit` to courier available |
| Dispute | Locks release (no balance move) |
| Seller refund / admin resolve | Explicit amounts — no 50/50 |

Commission preview for listings: `GET /platform/commission-rates` (not wallet).

---

## Courier

```http
GET /courier/earnings?from=&to=
```

Returns `todayGnf`, `weekGnf`, `totalGnf`, `availableGnf`, entries. Withdraw via same `/wallet/withdraw`.

---

## Errors

| Code | When |
|------|------|
| `INSUFFICIENT_AVAILABLE` | Withdraw too large |
| `BELOW_MIN_WITHDRAWAL` | Below platform min |
| `INVALID_OM_PHONE` | Bad MSISDN |
| `WITHDRAWAL_PENDING` | Another pending withdraw |

---

## Checklist

- [ ] Show available + pending separately  
- [ ] Withdraw form: amount + OM phone  
- [ ] Idempotency-Key on withdraw  
- [ ] Ledger list from API  
- [ ] Courier earnings → wallet withdraw  
