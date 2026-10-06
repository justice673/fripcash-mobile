# Authentication surfaces (app · web dashboard · admin · courier)

**Purpose:** FripCash has **several distinct auth entry points**. They must not share one vague “login” in the API. This doc is the SRS/BE source for who logs in where, with what credentials, and what token/session they get.

Related: [03-auth-and-onboarding.md](./03-auth-and-onboarding.md) (upgrade / OTP product rules).

**Backend contract:** [Auth surfaces](../from-be/auth-mobile-flutter-handoff.md) · live OpenAPI

---

## 1. Summary matrix

| Surface | Client | Entry UI | Identifier | Credential | Session / token audience | Lands on |
|---------|--------|----------|------------|------------|--------------------------|----------|
| **A. Marketplace (mobile)** | Flutter | Welcome → Connexion / Inscription | Phone `+224…` | Password (+ SMS OTP) | `audience: consumer` (or equivalent claim) | `MainShell` (home / sell / inbox / profile) |
| **B. Web account dashboard** | Next.js | `/connexion`, `/inscription` | Phone (same consumer account) | Password (+ OTP as BE requires) | **Same consumer account** as mobile | `/dashboard/*` (thin account) |
| **C. Admin console** | Next.js | `/admin-login` only | **Email** | Password | `audience: admin` — **separate** from consumer | `/admin/*` |
| **D. Courier (livreur)** | Flutter | “Espace livreur” → courier login | Phone | Password | `audience: courier` **or** consumer token with `role=livreur` + hard route guard | `CourierHomeScreen` shell only |

**Hard rule:** A consumer token must **never** authorize `/admin/*` APIs. An admin token must **never** be enough to act as a buyer/seller on marketplace endpoints unless explicitly designed (default: no).

---

## 2. Surface A — Mobile marketplace (Flutter)

### 2.1 Flows
| Flow | Steps |
|------|--------|
| Register | Phone, password, profile, optional `SignUpRole` path → OTP → account created |
| Login | Phone + password → token + user |
| OTP verify | SMS code; gate trusted actions (exact gate: see open questions) |
| Forgot password | Phone → OTP → set new password |
| Logout | Clear local session; invalidate refresh if used |

### 2.2 After auth
- Buyer → browse/buy; sell CTA opens **Devenir vendeur** (upgrade), not free role switch.  
- Seller → `MainShell` with seller capabilities from `GET /me`.  
- Same `user.id` forever across upgrades.

### 2.3 Suggested endpoints
| Method | Path | Notes |
|--------|------|-------|
| POST | `/auth/register` | Consumer; body includes signup path |
| POST | `/auth/login` | Phone + password |
| POST | `/auth/otp/request` | |
| POST | `/auth/otp/verify` | |
| POST | `/auth/password/forgot` | |
| POST | `/auth/password/reset` | |
| POST | `/auth/logout` | Optional if JWT-only |
| GET | `/me` | Consumer capability snapshot |

### 2.4 Client today (mock)
`MockSession` in Flutter; OTP UI exists; no real SMS until BE + provider.

---

## 3. Surface B — Web consumer + dashboard

### 3.1 Intent
Same **people** as mobile marketplace (buyers / particuliers). Web is a **thin** account area, not a second identity system.

### 3.2 Entry
| Route | Purpose |
|-------|---------|
| `/connexion` | Consumer login |
| `/inscription` | Consumer register |
| `/mot-de-passe-oublie` | Reset |
| `/dashboard/*` | Guarded by consumer token (`fripcash-token` in localStorage today) |

### 3.3 Auth rules
- Use **same consumer auth API** as mobile (`/auth/login`, `/auth/register`, …).  
- Token = consumer audience.  
- After login: `/dashboard` (overview, orders, favoris, messages, paramètres, light sell).  
- Boutique / proximité / enseigne / livreur advanced flows → app CTA (not a different web login).

### 3.4 Must not
- Reuse `/admin-login` for normal users.  
- Treat “logged into dashboard” as admin.

### 3.5 Client today (mock)
`hooks/use-auth.ts` + `localStorage fripcash-token`; upgrade store for demo particulier.

---

## 4. Surface C — Admin console (web)

### 4.1 Intent
**Staff only.** Separate product surface from marketplace accounts.

### 4.2 Entry
| Route | Purpose |
|-------|---------|
| `/admin-login` | Admin email + password only |
| `/admin/*` | Layout guards: no admin session → redirect `/admin-login` |

### 4.3 Credentials
- **Email + password** (not phone OTP consumer flow).  
- Optional later: 2FA for staff.

### 4.4 Session model (required in production)
Prefer **separate token** (or clearly claimed JWT):

```json
{
  "sub": "admin_…",
  "aud": "admin",
  "role": "admin",
  "email": "…"
}
```

Client today (demo):
- Token in `fripcash-token`  
- Extra flag `fripcash-admin-session=1` (`lib/admin-session.ts`)  
- Demo button `enableAdminDemoSession()` — **must not ship**

### 4.5 Suggested endpoints
| Method | Path | Notes |
|--------|------|-------|
| POST | `/auth/admin/login` | Email + password → admin token |
| POST | `/auth/admin/logout` | |
| GET | `/admin/me` | Staff profile + permissions |
| * | `/admin/**` | All other admin APIs require admin audience |

### 4.6 Authorization
- Consumer JWT → **403** on `/admin/**`.  
- Admin JWT → marketplace buy/sell APIs **403** by default.  
- Dispute resolve, shop approve/reject, commission settings = admin only.

---

## 5. Surface D — Courier (Flutter)

### 5.1 Intent
Delivery agents use a **dedicated shell** (missions, earnings), not the marketplace sell tab.

### 5.2 Entry
- From welcome/login area: **Espace livreur** → `CourierLoginScreen`  
- Phone + password → courier session → `CourierHomeScreen`

### 5.3 Account model (choose one — document in API)
| Option | Description | Recommendation |
|--------|-------------|----------------|
| **D1** | Separate courier users + `aud: courier` token | Clearest isolation |
| **D2** | Same user table, `role=livreur`, login returns courier claim; app routes to courier shell | OK if one phone cannot be buyer+courier at once without product rules |

Product today: mock `signInAsCourier()` → dedicated shell. Courier is **not** a Settings role switch on a buyer account.

### 5.4 Suggested endpoints
| Method | Path | Notes |
|--------|------|-------|
| POST | `/auth/courier/login` | Or `/auth/login` returning `role=livreur` |
| GET | `/courier/me` | |
| * | `/courier/missions/**` | Courier audience only |

### 5.5 Must not
- Let a normal buyer token list courier missions.  
- Put admin dispute tools in the courier app.

---

## 6. Token & storage rules (all clients)

| Concern | Rule |
|---------|------|
| Transport | HTTPS; `Authorization: Bearer <token>` |
| Consumer web | Store consumer token; dashboard guards on it |
| Admin web | Store **admin** token (or same key only if claim `aud=admin` is verified server-side); keep admin session distinct in UI |
| Mobile | Secure storage (Keychain / EncryptedSharedPreferences) |
| Logout | Clear tokens; admin logout must clear admin session flag |
| Refresh | Optional refresh tokens per audience |

### Anti-patterns
1. One login endpoint that returns admin powers based on a soft `role` string clients can spoof.  
2. Sharing admin session with `/connexion` consumer login.  
3. Shipping `enableAdminDemoSession` / mock courier ignore-password in production.  
4. Using consumer OTP flow for admin email accounts.

---

## 7. Who can access what after login

| API area | Consumer token | Admin token | Courier token |
|----------|----------------|-------------|---------------|
| Browse / cart / orders (as buyer) | ✅ | ❌ | ❌ |
| Seller listings / sales | ✅ if seller caps | ❌ | ❌ |
| `POST /me/seller/*` upgrade | ✅ | ❌ | ❌ |
| `/admin/**` | ❌ | ✅ | ❌ |
| `/courier/**` | ❌ | ❌ (unless ops tool separate) | ✅ |
| Dispute resolve / refund | ❌ | ✅ | ❌ |

Capabilities for consumer still come from `GET /me` (`seller.capabilities`, `verificationStatus`).

---

## 8. Password & OTP policy (baseline for BE)

| Actor | OTP SMS | Password |
|-------|---------|----------|
| Consumer (app + web) | Yes (register / reset; optionally login step-up) | Yes |
| Admin | No SMS OTP as primary (email + password; 2FA later) | Yes (strong) |
| Courier | Optional (product decide) | Yes |

Rate-limit all auth endpoints. Lockout / backoff on brute force.

---

## 9. Mapping to current UI (for implementers)

| Surface | Key paths |
|---------|-----------|
| Mobile auth | `lib/screens/login_screen.dart`, `signup_screen.dart`, `otp_verification_screen.dart`, `mock_session.dart` |
| Mobile courier | `lib/screens/courier_login_screen.dart`, `courier_home_screen.dart` |
| Web consumer | `app/(auth)/connexion`, `inscription`, `hooks/use-auth.ts`, `lib/api.ts` |
| Web admin | `app/admin-login/page.tsx`, `app/admin/layout.tsx`, `lib/admin-session.ts` |

---

## 10. Acceptance checks for BE

- [ ] Consumer login does not open `/admin`.  
- [ ] Admin login does not create a usable buyer cart session.  
- [ ] Courier login cannot call seller Excel import or admin validation.  
- [ ] Web dashboard and mobile app accept the **same** consumer tokens.  
- [ ] Admin routes reject consumer JWTs with 403.  
- [ ] Demo/admin bypass flags disabled in production builds.
