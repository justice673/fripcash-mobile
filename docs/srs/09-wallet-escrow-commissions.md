# 09 — Wallet, escrow, commissions

**Listings / rates:** [listings handoff](../from-be/listings-mobile-flutter-handoff.md)

**Backend wallet contract:** [wallet-mobile-flutter-handoff.md](../from-be/wallet-mobile-flutter-handoff.md)

## 9.1 Commission (server-priced)
| Profile | Platform commission (defaults) |
|---------|---------------------|
| Proximité (`shop_kind=proximite`) | **5%** (`commissionRateProximite`) |
| Particulier / boutique standard / enseigne | **8%** (`commissionRateStandard`) |

Admins change rates via `/admin/platform-settings`. Clients may preview; **backend wins**. Listings **snapshot** the rate at create / net-price change.

## 9.2 Pricing model
- Seller sets **net** amount they want.  
- Buyer pays **gross** (net + commission and any fee components).  
- Document formula in API so app/web match.

## 9.3 Escrow (pending until goods OK)

**Core rule:** after payment, money is **held**. It is **not** credited to the seller’s withdrawable balance until release.

1. Payment success → `escrowHold` (pending).  
2. Delivery / pickup happens while funds stay held.  
3. **Buyer confirms receipt** (or policy auto-confirm) → `escrowRelease` → seller wallet.  
4. If **litige** opened (buyer **or** seller) → remain locked until resolve or seller voluntary refund.  
5. **Seller voluntary refund** allowed while held → funds back to buyer (full/partial).  
6. Admin outcomes: `refund_buyer` | `partial_refund` | `release_seller`.

See [18-disputes-and-refunds.md](./18-disputes-and-refunds.md) for camera evidence + investigation messaging.

## 9.4 Wallet transaction types
Examples to support: `saleCredit`, `withdrawal`, `deliveryFee`, `escrowHold`, `escrowRelease`, `refund`, `partialRefund`.

## 9.5 Withdrawals
- Seller (and courier earnings) withdraw to **Orange Money**.  
- Require verified phone / payout KYC as BE policy.

## 9.6 Admin finance
- View wallets, adjust commission settings (standard vs proximité), audit movements.
