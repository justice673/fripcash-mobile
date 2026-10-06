# 19 — Codes & PINs (from the live Flutter app)

Studied in `/home/justice/frip_cash`. Customer language often says “PIN”; the app implements **several different codes**. Do not merge them into one field.

**Backend contract:** [Checkout / codes](../from-be/checkout-mobile-flutter-handoff.md) · live OpenAPI

---

## 1. Inventory (what exists in the app today)

| Name in product | Digits | Where | Who sees it | Purpose |
|-----------------|--------|-------|-------------|---------|
| **SMS OTP** | 6 | Signup / login verify / forgot password | User | Prove phone ownership |
| **Code de retrait (pickup code)** | **4** | After pay for **proximité** orders; buyer + seller screens | Buyer shares; shop verifies | Handoff without FripCash courier |
| **Orange Money PIN** | OM’s own PIN | *Not an in-app pad today* | User on Orange Money | Authorize payment / withdraw |

There is **no** separate “FripCash wallet PIN” or “app lock PIN” in the current codebase.

---

## 2. SMS OTP (auth)

- UI: `otp_verification_screen.dart` + `otp_input.dart`  
- Copy: 6-digit SMS code  
- Needs **SMS provider** on BE  
- Flows: register, verify, password reset  

Documented further in [17-authentication-surfaces.md](./17-authentication-surfaces.md).

---

## 3. Code de retrait (the main “PIN-like” order code)

### Product rule (proximité / boutique de quartier)
1. Buyer pays with Orange Money.  
2. BE generates a **4-digit pickup code** (`MockOrderService._generatePickupCode()` → random 4 digits).  
3. Buyer screen (`ProximityPickupScreen`): big digit tiles, copy/share — “anyone can collect with this code”.  
4. Seller / shop sees the **same code** on order / dashboard — must verify before handing goods.  
5. Seller confirms handoff → order progresses (delivered path for proximity).

### When it is created
- Only if fulfillment **skips FripCash courier** (pickup / shop local) — `pickupCode` set on create.  
- Courier deliveries: **no** pickup code (courier flow instead).

### BE requirements
| Rule | Detail |
|------|--------|
| Generate | Cryptographically random 4-digit (or longer if product ups length) unique per open order |
| Show | Buyer + seller of that order only |
| Verify | Optional: seller enters code to confirm handoff (UI today mostly **displays** code; BE may require typed match) |
| Invalidate | After handoff / cancel / refund |
| Security | Not a password; treat as shared secret for physical pickup — rate-limit guessing if seller must type it |

UI widgets: `pickup_code_digits.dart`, labels `pickupCodeLabel` / `sellerPickupCodeHint`.

---

## 4. Orange Money “PIN”

### What the app does today
`OrangeMoneyPaymentScreen`:
- Asks for **Orange Money phone number**  
- Button **Confirmer le paiement**  
- Mock delay → create order  
- **No in-app PIN pad**

Checkout todo historically said: *“Simulate PIN pad **or** Confirmer le paiement”* — current build chose **confirm button**, not a PIN UI.

### What production should do
Orange Money PIN is normally entered in:
- Orange Money **USSD / push approval / PSP SDK**, not a fake PIN we store  

BE integrates the payment provider; FripCash must **not** store the user’s OM PIN.  
Optional later: in-app PIN pad **only** if the PSP SDK requires embedding it — still provider-owned.

Withdraw to Orange Money (`wallet_screen`): confirm dialog only (mock) — same rule: real withdraw uses OM auth, not a FripCash-stored PIN.

---

## 5. Mapping to SRS modules

| Code | Spec files |
|------|------------|
| SMS OTP | `03`, `17`, auth API |
| Pickup code | `06` checkout, `07` orders, this file |
| OM PIN / approval | `06` payments — external to FripCash secrets |

---

## 6. Acceptance checks for BE
- [ ] Proximity paid orders receive a pickup code; courier orders do not.  
- [ ] Buyer and seller can both read the code for that order.  
- [ ] Handoff/completion invalidates or freezes the code.  
- [ ] OTP is SMS 6-digit; separate from pickup code.  
- [ ] No FripCash database column storing Orange Money PINs.
