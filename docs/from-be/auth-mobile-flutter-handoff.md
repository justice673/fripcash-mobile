# Auth handoff — Flutter (mobile)

**Audience:** Flutter team (marketplace + courier)  
**API base:** `http://localhost:3000` (dev) · prefix `/api/v1`  
**Related:** [01-auth.md](./01-auth.md) · [03-users.md](./03-users.md) · [07-sellers.md](./07-sellers.md) · [auth-be-handoff.md](./auth-be-handoff.md)

This is the contract for the **mobile client**. Backend is live for these routes. Replace mock OTP / in-memory sessions with this.

---

## What changed (vs OTP-only mock)

| Before (mock / old BA-only) | Now (ship this) |
|-----------------------------|-----------------|
| Phone → OTP → instant session | **Register:** OTP → password + `signupPath` → session |
| Login = OTP every time | **Login:** phone + **password** + terms (no OTP) |
| Role cards local only | `signupPath` creates buyer / seller on server |
| Logo = “selected” bool | Real Cloudinary upload → `logoMediaId` |
| Courier via marketplace OTP | Separate `POST /auth/courier/login` |

Dev OTP remains **`000000`**. Resend cooldown **60 seconds**. OTP TTL **5 minutes**, max **3** bad attempts.

---

## Mobile client assumptions (BE designed for this)

- **Bearer auth:** login/register returns `token` and `accessToken` (same session value). Store in `flutter_secure_storage`; send `Authorization: Bearer <accessToken>` on every product call. Cookies are optional; mobile must not rely on them.
- **Phone UI:** country chip `+224` + local digits; send any of `624…`, `0624…`, `+224…` — server normalizes to E.164.
- **Two apps / shells:** marketplace `MainShell` (`CONSUMER`) vs courier shell (`COURIER`). Never reuse a courier token on marketplace routes (and vice versa).
- **Gate UI from `GET /me`**, not from a local “role” enum you persist forever.
- **Confirm password** is client-only; API only accepts `password`.

---

## Cold start

```
1. Read token from secure storage
2. Missing → Auth stack (login / register)
3. GET /api/v1/me
4. Route:
   - WRONG_AUTH_SURFACE / FORBIDDEN_AUDIENCE → correct shell
   - me.seller.verificationStatus == pending → pending banner
   - else MainShell / CourierHome
```

---

## Dio sketch

```dart
final dio = Dio(BaseOptions(
  baseUrl: const String.fromEnvironment('API_URL', defaultValue: 'http://localhost:3000'),
  headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
));

dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) async {
    final token = await secureStorage.read(key: 'access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['x-locale'] = locale == 'en' ? 'EN' : 'FR';
    handler.next(options);
  },
  onError: (e, handler) async {
    if (e.response?.statusCode == 401) {
      await secureStorage.delete(key: 'access_token');
      // navigate to LoginScreen
    }
    handler.next(e);
  },
));
```

Auth error body (Better Auth / plugin):

```json
{ "code": "INVALID_CREDENTIALS", "message": "…" }
```

Nest product errors:

```json
{ "code": "FORBIDDEN_AUDIENCE", "message": "…", "correlationId": "…" }
```

Map `code` first, then `message`.

---

## 1. Register (marketplace)

### Screens → API

```
SignUpRole cards          → signupPath
Account (name/phone/pwd)  → displayName, phone, password
Shop / zone step          → zoneId, address, deliverySla, …
OTP 6 boxes               → otp/request + otp/verify
Terms + marketing         → termsAccepted, marketingOptIn
Logo tap                  → register-cloudinary-sign → logoMediaId
```

### Sequence

```http
POST /api/v1/auth/otp/request
{ "phone": "620123456", "purpose": "register" }

POST /api/v1/auth/otp/verify
{ "phone": "620123456", "code": "000000", "purpose": "register" }
→ { "registrationSessionId": "…" }

# Shops only — upload logo before register:
POST /api/v1/auth/media/register-cloudinary-sign
{ "phone": "620123456", "registrationSessionId": "…" }
→ Cloudinary sign → upload → keep public_id as logoMediaId

POST /api/v1/auth/register
{ …fields below… }
→ { "token": "…", "accessToken": "…", "user": { … } }

GET /api/v1/me
→ persist token → onboarding slides → MainShell
```

### `signupPath` values (Flutter `SignUpRole`)

| Flutter card | `signupPath` | Extra required fields |
|--------------|--------------|------------------------|
| Acheteur | `acheteur` | displayName, phone, password, termsAccepted |
| Particulier | `particulier` | + zoneId, address, deliverySla `24h`\|`48h` |
| Boutique | `boutique` | + shopName, zoneId, address, deliverySla (`24h`\|`48h`\|`72h`\|`1_semaine`), shopDescription, logoMediaId |
| Commerce local | `commerceLocal` | + shopName, zoneId, address, **shopCategoryId**, shopDescription, logoMediaId — **no** deliverySla |
| Grande surface | `grandeSurface` | + shopName, zoneId, address, deliverySla, shopDescription, logoMediaId |

### Proximité categories (`shopCategoryId`)

Send **slugs**, not French labels:

| UI label (FR) | API |
|---------------|-----|
| Épicerie sèche | `epicerie_seche` |
| Boutique de proximité | `boutique_de_proximite` |
| Boissons & snacks | `boissons_snacks` |
| Produits du quotidien | `produits_du_quotidien` |

Zones: `GET /api/v1/catalog/zones` → use returned `id` as `zoneId` (not hard-coded `zone_1` unless seed matches).

### Example — proximité

```json
{
  "registrationSessionId": "…",
  "signupPath": "commerceLocal",
  "phone": "+224623001122",
  "password": "••••••••",
  "displayName": "Épicerie Kipé",
  "shopName": "Épicerie Kipé",
  "zoneId": "<zone cuid from catalog>",
  "address": "Kipé, marché central",
  "shopCategoryId": "epicerie_seche",
  "shopDescription": "Épicerie de quartier…",
  "logoMediaId": "fripcash/shops/…/logo",
  "termsAccepted": true,
  "marketingOptIn": true,
  "locale": "fr"
}
```

After register, proximité lands with `me.seller.verificationStatus === "pending"` → `createListing: false`, but `productLibrary` / `excelImport` may be true. Show pending banner; Product Library CTA is OK.

---

## 2. Login (marketplace)

```http
POST /api/v1/auth/login
{
  "phone": "620123456",
  "password": "••••••••",
  "termsAccepted": true
}
```

→ `{ token, user }` → `GET /me` → MainShell.

| Code | UX |
|------|-----|
| `INVALID_CREDENTIALS` | Shake password / generic error |
| `TERMS_REQUIRED` | Force terms checkbox |
| `WRONG_AUTH_SURFACE` | “Use the courier app” / admin — do not open MainShell |

**Do not** send courier phones through marketplace login expecting MainShell.

---

## 3. Forgot / change password

```
ForgotPasswordScreen
  POST /auth/password/forgot { phone }     // always 200
OtpVerificationScreen(purpose: resetPassword)
  POST /auth/otp/verify { phone, code, purpose: "reset_password" }
  → { resetToken }
ResetPasswordScreen
  POST /auth/password/reset { phone, resetToken, password }
→ Login + success toast

ChangePasswordScreen (authenticated)
  POST /auth/password/change
  { "currentPassword": "…", "newPassword": "…" }
```

---

## 4. Become seller (already logged in)

Same `user.id` — **not** a new account. No password/phone again.

| Flutter | API |
|---------|-----|
| Become particulier | `POST /api/v1/me/seller/particulier` |
| Become boutique (any shopKind) | `POST /api/v1/me/seller/shop` |

Bodies match register field matrix (zone, address, SLA/category, logo) — see [07-sellers.md](./07-sellers.md).  
Then invalidate `me` and refetch.

---

## 5. Courier app

```http
POST /api/v1/auth/courier/login
{ "phone": "620…", "password": "••••••••" }
```

→ store token → `GET /api/v1/courier/me` → **CourierHomeScreen only**.

- Accounts are **admin-provisioned** (no marketplace `signupPath: livreur` in v1).
- Marketplace OTP/login for a courier phone → `WRONG_AUTH_SURFACE`.

---

## 6. `GET /api/v1/me` — gate the shell

Call after every auth success and on resume.

Important fields:

| Field | Use |
|-------|-----|
| `canBuy` | Hide buy for courier |
| `role` | Hint only (`acheteur` / `vendeurParticulier` / `boutique` / …) |
| `seller.capabilities.createListing` | Sell / publish CTA |
| `seller.capabilities.productLibrary` | Proximité library |
| `seller.capabilities.excelImport` | Excel import |
| `seller.verificationStatus` | Pending / rejected banners |
| `zoneId` / `address` | Profile display |

Phone is **not** editable via `PATCH /me`.

---

## 7. Logout

```http
POST /api/v1/auth/sign-out
```

Clear secure storage; go to login.

---

## Flutter UI ↔ API field map

| Flutter widget | API field |
|----------------|-----------|
| `PhoneNumberField` (+224) | `phone` |
| Name / shop name | `displayName` / `shopName` |
| Password / confirm | `password` (confirm client-only) |
| Zone dropdown | `zoneId` |
| Address | `address` |
| Delivery delay | `deliverySla` (`1 semaine` UI → `1_semaine`) |
| Proximity category | `shopCategoryId` (slug) |
| Logo | `logoMediaId` |
| Shop description | `shopDescription` |
| Marketing checkbox | `marketingOptIn` |
| Terms checkbox | `termsAccepted` (must be `true`) |
| OTP 6 boxes | `code` on `/otp/verify` |
| `SignUpRole` | `signupPath` |

---

## Error cheat sheet

| `code` | HTTP | Screen action |
|--------|------|---------------|
| `VALIDATION_ERROR` | 400 | Field errors |
| `TERMS_REQUIRED` | 400 | Check terms |
| `OTP_INVALID` / `OTP_EXPIRED` | 401 | Retry / resend OTP |
| `OTP_RATE_LIMITED` | 429 | Disable resend 60s |
| `PHONE_ALREADY_REGISTERED` | 409 | Offer login |
| `INVALID_CREDENTIALS` | 401 | Bad password |
| `WRONG_AUTH_SURFACE` | 403 | Switch app |
| `FORBIDDEN_AUDIENCE` | 403 | Wrong shell |

---

## Checklist for Flutter

- [ ] Replace mock OTP with `/otp/request` + `/otp/verify`
- [ ] Register with password + all 5 `signupPath`s
- [ ] Login phone + password + terms
- [ ] Persist bearer in secure storage
- [ ] `GET /me` drives navigation + seller capabilities
- [ ] Logo upload via register Cloudinary sign
- [ ] Courier login isolated
- [ ] `WRONG_AUTH_SURFACE` copy + routing
- [ ] Forgot / reset / change password
- [ ] Become seller → `/me/seller/particulier` | `/shop`
