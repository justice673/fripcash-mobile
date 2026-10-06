# Admin + Flutter → Nest — Courier (livreur) provisioning & first-login phone OTP

**From:** Admin Next.js (`/admin/livreurs`) + Flutter courier shell  
**To:** Nest BE  
**Date:** 2026-10-04  
**Priority:** **P0** — product requires admin-created courier credentials + phone proof before missions  
**Env:** `http://62.84.179.126:3010`  
**Base path:** `/api/v1`  
**Locales:** `x-locale: FR` | `EN`  
**Auth surfaces:**  
- Admin JWT (`aud: admin`) — create / list / patch / verify couriers  
- Courier JWT (`aud: courier`) — login, OTP verify, missions  
- Consumer JWT — **must never** create or manage couriers  

**Reply pack expected:**  
- `docs/from-be/courier-admin-provision-handoff.md` (or fold into `admin-web-nextjs-handoff.md` + `auth-mobile-flutter-handoff.md` + `courier-mobile-flutter-handoff.md`)  
- OpenAPI paths + error codes  
- Seed / migration notes for `CourierProfile` fields below  

**Related (do not conflate):**  
- `docs/from-be/auth-mobile-flutter-handoff.md` — `POST /auth/courier/login`, `WRONG_AUTH_SURFACE`  
- `docs/from-be/courier-mobile-flutter-handoff.md` — missions / availability / earnings  
- `docs/from-be/admin-web-nextjs-handoff.md` — stub list `GET /admin/couriers` (not create)  
- `docs/from-be/courier-web-nextjs-handoff.md` — marketplace web has **no** livreur shell  
- SRS `docs/srs/03-auth-and-onboarding.md` §3.6 · `docs/srs/17-authentication-surfaces.md` Surface D · `docs/srs/11-courier.md`  
- Nest today: `POST /admin/users/:id/provision-audience` `{ audience: "COURIER" }` only (needs **existing** user id — **not** enough for ops)

---

## 0. Why this exists (read first)

### 0.1 Product problem

Couriers (**livreurs**) do **not** self-register on the marketplace.

| Step | Product intent | Today |
|------|----------------|-------|
| 1 | Admin creates courier account (phone + password) in **Admin → Livreurs** | Admin page is an **empty stub** (“endpoint admin livreurs indisponible”) |
| 2 | Prove the phone is real (SMS OTP) | **Missing** for courier surface |
| 3 | Courier opens **mobile app** → same Sign in UI → courier shell | Login API exists; first-login OTP gate **missing** |
| 4 | Courier goes online and takes missions | Missions APIs exist; blocked until verified (desired) |

Marketplace web **never** hosts a courier dashboard. Only the **Flutter app** does.

### 0.2 What Nest has today (gaps)

| Capability | Status |
|------------|--------|
| `POST /auth/courier/login` | Exists |
| `GET /courier/me`, missions, availability | Exists |
| `POST /admin/users/:id/provision-audience` `{ "audience": "COURIER" }` | Exists — **upgrade existing user only** |
| `POST /admin/couriers` create with phone + password | **Missing** |
| `GET /admin/couriers` list / filter | Documented in from-be handoff; **not wired** to Admin UI |
| Phone OTP on first courier login | **Missing** |
| Temp password / force change | **Missing** (recommended below) |

### 0.3 Identifier rule (non-negotiable)

| Actor | Identifier | Credential |
|-------|------------|------------|
| Buyer / seller (app + web) | **Phone** (+224) | Password / OTP (marketplace rules) |
| **Courier (app)** | **Phone** (+224) | Password + **first-login SMS OTP** |
| Admin (web) | **Email** | Password |

**Do not** use email for courier login or courier OTP. Guinea livreurs are phone-first.

### 0.4 Scope of this handoff

**In scope**

1. Nest model fields for courier phone verification + account lifecycle  
2. Admin **create courier** (phone, display name, zone(s), password policy)  
3. Admin **list / get / patch / deactivate / verification status**  
4. Optional: admin **resend setup OTP** / **reset password**  
5. Flutter **first-login OTP** after successful password check  
6. Subsequent logins (password only once phone verified)  
7. Marketplace login of a courier phone → still `WRONG_AUTH_SURFACE` (Flutter already retries courier login)  
8. Errors, OpenAPI, acceptance tests, curl matrix, Admin + Flutter UI contracts  

**Out of scope (explicit)**

- Courier self-signup / “Become livreur” in marketplace  
- Courier web dashboard  
- Admin email OTP for couriers  
- Full KYC document pipeline redesign (keep existing `verificationStatus` + docs APIs if already shipped)  
- Mission assignment algorithm changes  
- SMS provider choice (document interface; reuse consumer OTP pipeline if possible)

---

## 1. Product rules (non-negotiable)

1. **Admin-only create.** No `signupPath: livreur`. No public register as courier.  
2. **One phone → one user.** Same E.164 uniqueness as marketplace users. Creating a courier with a phone that already belongs to a **CONSUMER** or **ADMIN** → `PHONE_IN_USE` (do **not** silently convert a buyer).  
3. **Password is always server-generated.** Admin UI has **no** manual password field / dropdown — only copy that Nest will generate a temporary password. Response includes `temporaryPassword` **only at create** (or admin reset). Never return password on GET.  

4. **Phone unverified until OTP.** After create, `phoneVerifiedAt = null`. Courier **cannot** accept missions / go available until phone verified.  
5. **First login sequence (app):**  
   `phone + password` → if password OK and phone not verified → **challenge OTP** (no full courier session yet, or short-lived `pre_auth` token) → verify OTP → **full courier JWT** + set `phoneVerifiedAt`.  
6. **Later logins:** `phone + password` → full courier JWT (no OTP), unless policy re-challenge (password reset, admin “require re-verify”).  
7. **OTP channel:** SMS to the courier’s phone. Same 6-digit pattern as marketplace register OTP where possible (`000000` allowed in **dev/staging only**).  
8. **OTP purpose enum:** distinct from consumer register/reset — e.g. `COURIER_PHONE_VERIFY` (or `courier_first_login`). Do not accept a consumer register OTP for courier verify.  
9. **Temp password (required):** on create, Nest **always** generates a strong temp password; `mustChangePassword=true`. Admin never types a password at create. After first successful OTP (or next login), Flutter forces **change password** before missions.  

10. **Admin “Approve” ≠ phone verify.**  
    - `phoneVerifiedAt` = owns the SIM  
    - `CourierProfile.verificationStatus` = ops KYC / docs (`NONE` \| `PENDING` \| `APPROVED` \| `REJECTED`)  
    Missions require **both** phone verified **and** `verificationStatus=APPROVED` (or document a softer v1: phone verified + `active=true` only). **Pick one and stick to it in from-be.** Recommendation: **phone verified + APPROVED** before `isAvailable=true` / accept mission.  
11. **Active flag.** Soft disable: `active=false` → login fails with `COURIER_DISABLED` (or password OK but missions blocked — prefer **login fail** for clarity).  
12. **Audit.** Every create / password reset / verification change / deactivate writes `AuditLog` with admin actor id.  
13. **Timestamps:** ISO-8601 `Z`. Phones stored/normalized E.164 (`+224…`).  

---

## 2. Domain model

### 2.1 User (identity) — courier-relevant fields

Existing user already has `userKind`, `authAudience`, phone, password hash.

**Add (or confirm):**

```ts
type UserCourierAuthFields = {
  // existing
  id: string;
  phone: string;                 // E.164 unique
  passwordHash: string;
  userKind: "COURIER";
  authAudience: "COURIER";
  displayName: string | null;

  // NEW / confirm
  phoneVerifiedAt: string | null;     // null until first OTP success
  mustChangePassword: boolean;        // true after admin create / reset
  active: boolean;                    // default true; admin can disable
  // optional
  passwordChangedAt: string | null;
};
```

If `phoneVerifiedAt` already lives elsewhere, document the canonical field — Flutter only needs it on login / `courier/me`.

### 2.2 `CourierProfile` (extend)

Current Prisma (`identity.CourierProfile`):

```
id, userId, verificationStatus, vehicleType, licensePlate,
isAvailable, zoneIds[], createdAt, updatedAt
```

**Add:**

```ts
type CourierProfile = {
  id: string;
  userId: string;
  verificationStatus: "NONE" | "PENDING" | "APPROVED" | "REJECTED";
  vehicleType: string | null;
  licensePlate: string | null;
  isAvailable: boolean;          // forced false until phone verified + approved
  zoneIds: string[];             // catalog zone cuids — at least one required at create
  // NEW
  notesAdmin: string | null;     // internal ops note
  createdByAdminId: string | null;
  disabledAt: string | null;
  disabledReason: string | null;
  createdAt: string;
  updatedAt: string;
};
```

### 2.3 OTP challenge (reuse or new table)

Prefer **same OTP infrastructure** as consumer auth with a distinct `purpose`:

```ts
type OtpPurpose =
  | "REGISTER"           // existing consumer
  | "PASSWORD_RESET"     // existing
  | "COURIER_PHONE_VERIFY"; // NEW

type OtpChallenge = {
  id: string;
  phone: string;
  purpose: OtpPurpose;
  codeHash: string;
  expiresAt: string;
  attempts: number;
  maxAttempts: number;       // e.g. 5
  consumedAt: string | null;
  // optional bind to login attempt
  courierUserId: string | null;
  preAuthTokenHash: string | null;
};
```

### 2.4 Login response states (critical for Flutter)

Courier password login must **not** always return a full mission-capable token.

```ts
type CourierLoginResponse =
  | {
      status: "authenticated";
      accessToken: string;
      refreshToken?: string;
      aud: "courier";
      mustChangePassword: boolean;
      courier: CourierMeSummary;
    }
  | {
      status: "phone_verification_required";
      // Short-lived token ONLY for OTP verify / resend (not missions)
      preAuthToken: string;
      expiresInSec: number;          // e.g. 600
      phoneMasked: string;           // "+224 •• •• •• 89"
      otpLength: 6;
      // OTP already sent on this response (or Flutter calls resend)
      otpSent: boolean;
    };
```

**Rule:** `preAuthToken` audience/claim = `courier_pre_auth` (or equivalent).  
`GET /courier/missions` with pre-auth → `403 FORBIDDEN_AUDIENCE`.

---

## 3. Admin API — create & manage couriers

All routes: **Admin Bearer**. Base: `/api/v1/admin`.

### 3.1 Create courier (primary ops action)

```http
POST /api/v1/admin/couriers
Authorization: Bearer <admin>
Content-Type: application/json
Idempotency-Key: <uuid>            # strongly recommended
```

```json
{
  "phone": "+224620123456",
  "displayName": "Mamadou Diallo",
  "zoneIds": ["zone_cuid_kaloum"],
  "vehicleType": "moto",
  "licensePlate": "GN-1234-AB",
  "sendSmsInvite": true,
  "notesAdmin": "Recruté Kaloum mars 2026",
  "verificationStatus": "PENDING"
}
```

| Field | Required | Notes |
|-------|----------|-------|
| `phone` | yes | Normalize to E.164; Guinea default +224 |
| `displayName` | yes | Shown in admin + courier profile |
| `zoneIds` | yes | ≥1 valid catalog zone ids |
| `vehicleType` | no | e.g. `moto` \| `voiture` \| `velo` \| free string — document enum |
| `licensePlate` | no | |
| `sendSmsInvite` | no | default `true` — SMS with temp password **or** “download app + sign in” copy (never send OTP as the password) |
| `notesAdmin` | no | Internal |
| `verificationStatus` | no | default `PENDING` (ops still reviews docs later) |

**Password (server-only)**

| Rule | Behavior |
|------|----------|
| Create | Nest **always** generates a random temp password (e.g. 10–12 chars); return once in `201`; `mustChangePassword=true` |
| Admin UI | **No** `passwordMode` / manual password input — informational copy only (“sera généré automatiquement”) |
| Reject body fields | If client sends `temporaryPassword` / `passwordMode` → ignore **or** `400 VALIDATION_ERROR` (prefer **reject** to keep contract clean) |

**Side effects on 201**

1. Create `User` with `userKind=COURIER`, `authAudience=COURIER`, `active=true`, `phoneVerifiedAt=null`, `mustChangePassword=true`  
2. Upsert `CourierProfile` with zones / vehicle / `isAvailable=false`  
3. Audit `courier.create`  
4. If `sendSmsInvite`: enqueue SMS (template below)  
5. **Do not** mark phone verified  
6. **Optional v1:** also send first OTP immediately — **not required**; OTP is triggered at first app login (preferred)

**201 response**

```json
{
  "id": "user_cuid",
  "courierProfileId": "cprof_cuid",
  "phone": "+224620123456",
  "displayName": "Mamadou Diallo",
  "zoneIds": ["zone_cuid_kaloum"],
  "verificationStatus": "PENDING",
  "phoneVerifiedAt": null,
  "mustChangePassword": true,
  "active": true,
  "temporaryPassword": "xK9m-2pQq",
  "inviteSmsQueued": true,
  "createdAt": "2026-10-04T07:00:00.000Z"
}
```

**UI note:** Admin must show a **one-time copy dialog** for `temporaryPassword` (“Won’t be shown again”). Provide **Copy**. Create form must **not** ask the admin to choose or type a password — Nest generates it.

### 3.2 List couriers

```http
GET /api/v1/admin/couriers?q=&active=&verificationStatus=&zoneId=&phoneVerified=&page=&pageSize=
```

```json
{
  "items": [
    {
      "id": "user_cuid",
      "courierProfileId": "cprof_cuid",
      "displayName": "Mamadou Diallo",
      "phone": "+224620123456",
      "phoneMasked": "+224 •• •• •• 56",
      "phoneVerifiedAt": null,
      "mustChangePassword": true,
      "active": true,
      "verificationStatus": "PENDING",
      "isAvailable": false,
      "zoneIds": ["zone_cuid_kaloum"],
      "zoneNames": ["Kaloum"],
      "vehicleType": "moto",
      "createdAt": "2026-10-04T07:00:00.000Z",
      "lastLoginAt": null
    }
  ],
  "page": 1,
  "pageSize": 20,
  "total": 1
}
```

### 3.3 Get one

```http
GET /api/v1/admin/couriers/:userId
```

Full detail + admin notes + audit summary (optional).

### 3.4 Patch courier

```http
PATCH /api/v1/admin/couriers/:userId
{
  "displayName": "Mamadou D.",
  "zoneIds": ["zone_cuid_kaloum", "zone_cuid_dixinn"],
  "vehicleType": "moto",
  "licensePlate": "GN-1234-AB",
  "active": true,
  "notesAdmin": "…"
}
```

- **Cannot** change `phone` via PATCH in v1 → `PHONE_IMMUTABLE` (force create new + disable old if wrong number).  
- Setting `active=false` sets `isAvailable=false` and `disabledAt`.

### 3.5 Verification (ops KYC) — keep / align

```http
PATCH /api/v1/admin/couriers/:userId/verification
{
  "status": "APPROVED",
  "reviewerNote": "Permis OK"
}
```

`status`: `APPROVED` \| `REJECTED` \| `PENDING`.  
Reject without note → `REVIEWER_NOTE_REQUIRED` (same pattern as sellers).

### 3.6 Reset password (admin)

```http
POST /api/v1/admin/couriers/:userId/reset-password
{
  "sendSms": true
}
```

Nest **always** generates a new temp password (same as create — no manual password in body).  

**200** → `{ temporaryPassword, mustChangePassword: true }`.  
Also clears sessions / refresh tokens for that courier (recommended).  
Does **not** clear `phoneVerifiedAt` unless `requirePhoneReverify: true` (optional flag).

### 3.7 Resend invite SMS (admin)

```http
POST /api/v1/admin/couriers/:userId/resend-invite
```

Re-sends “your account is ready” SMS. Does **not** reveal password again unless paired with reset-password.

### 3.8 Deprecated / secondary path

Keep for migrations only:

```http
POST /api/v1/admin/users/:id/provision-audience
{ "audience": "COURIER" }
```

Document: **do not use for new hires** when phone already belongs to a buyer. Prefer `POST /admin/couriers`. If you keep it, require `phoneVerifiedAt` still null → force OTP on next courier login.

---

## 4. SMS copy (invite)

**FR (suggested):**

> FripCash Livreurs — Ton compte est prêt.  
> Téléphone: {phone}  
> Mot de passe temporaire: {temporaryPassword}  
> 1) Installe l’app FripCash  
> 2) Connexion avec ce numéro et ce mot de passe  
> 3) Entre le code SMS pour activer ton compte  
> Change ton mot de passe après connexion.

**EN** equivalent via `x-locale` / dual SMS if needed — FR-first for GN.

**Security:** SMS is insecure; temp password + forced change + OTP is the mitigation.

---

## 5. Flutter / courier auth API

### 5.1 Login (password)

```http
POST /api/v1/auth/courier/login
Content-Type: application/json

{
  "phone": "+224620123456",
  "password": "xK9m-2pQq"
}
```

**Branch A — phone already verified**

```json
{
  "status": "authenticated",
  "accessToken": "…",
  "aud": "courier",
  "mustChangePassword": false,
  "courier": {
    "id": "cprof_…",
    "userId": "user_…",
    "displayName": "Mamadou Diallo",
    "phoneVerifiedAt": "2026-10-04T08:00:00.000Z",
    "verificationStatus": "APPROVED",
    "isAvailable": false
  }
}
```

→ Flutter: store courier token → if `mustChangePassword` → Change password screen → else `CourierHomeScreen`.

**Branch B — first login / phone not verified**

```json
{
  "status": "phone_verification_required",
  "preAuthToken": "…",
  "expiresInSec": 600,
  "phoneMasked": "+224 •• •• •• 56",
  "otpLength": 6,
  "otpSent": true
}
```

→ Flutter: **do not** open missions shell. Navigate to **Courier OTP screen** (reuse UI pattern from `OtpVerificationScreen`, courier branding).

If password wrong → `401 INVALID_CREDENTIALS` (same as consumer).  
If `active=false` → `403 COURIER_DISABLED`.

### 5.2 Resend OTP

```http
POST /api/v1/auth/courier/otp/send
Authorization: Bearer <preAuthToken>

{}
```

Or body `{ "preAuthToken": "…" }` if you prefer header-less — **pick one in from-be**.

Rate limit: e.g. 1 / 60s, max 5 / hour / phone → `OTP_RATE_LIMITED`.

### 5.3 Verify OTP (completes first login)

```http
POST /api/v1/auth/courier/otp/verify
Authorization: Bearer <preAuthToken>

{
  "code": "000000"
}
```

**200**

```json
{
  "status": "authenticated",
  "accessToken": "…",
  "aud": "courier",
  "mustChangePassword": true,
  "courier": {
    "id": "cprof_…",
    "userId": "user_…",
    "displayName": "Mamadou Diallo",
    "phoneVerifiedAt": "2026-10-04T08:05:00.000Z",
    "verificationStatus": "PENDING",
    "isAvailable": false
  }
}
```

Side effects: set `phoneVerifiedAt=now()`, consume OTP, invalidate `preAuthToken`.

Errors: `OTP_INVALID`, `OTP_EXPIRED`, `OTP_MAX_ATTEMPTS`, `PRE_AUTH_EXPIRED`.

### 5.4 Change password (after first login)

```http
POST /api/v1/auth/courier/change-password
Authorization: Bearer <courier accessToken>

{
  "currentPassword": "xK9m-2pQq",
  "newPassword": "NewSecurePass1"
}
```

Clears `mustChangePassword`.  
If you already have a generic change-password for courier audience, document canonical path.

### 5.5 `GET /api/v1/courier/me` — gate fields

Must include:

```json
{
  "id": "cprof_…",
  "userId": "user_…",
  "displayName": "Mamadou Diallo",
  "phone": "+224620123456",
  "phoneVerifiedAt": "2026-10-04T08:05:00.000Z",
  "mustChangePassword": false,
  "verificationStatus": "APPROVED",
  "isAvailable": false,
  "zoneIds": ["…"],
  "vehicleType": "moto",
  "active": true
}
```

### 5.6 Availability / accept mission — server enforcement

| Action | Require |
|--------|---------|
| `PATCH /courier/me/availability` `{ isAvailable: true }` | `phoneVerifiedAt` set **and** `verificationStatus=APPROVED` **and** `active` |
| `POST /missions/:id/accept` | same |

Otherwise: `403 COURIER_NOT_VERIFIED` or `PHONE_NOT_VERIFIED` (prefer distinct codes).

### 5.7 Marketplace login collision

```http
POST /api/v1/auth/login   # consumer
```

Courier phone → `403 WRONG_AUTH_SURFACE` / `FORBIDDEN_AUDIENCE`.

Flutter marketplace Sign in **already** catches this and retries `loginCourier` with the same phone/password — then applies §5.1 branches (including OTP). **No separate “Courier space” button on buyer login.**

---

## 6. Flutter UI contract

### 6.1 Screens / navigation

| Screen | When |
|--------|------|
| Marketplace `LoginScreen` | Courier enters admin phone + password (same form as buyers) |
| Auto handoff | On `WRONG_AUTH_SURFACE` or courier login response |
| `CourierOtpScreen` (new or reuse OTP widget) | `status === phone_verification_required` |
| `CourierChangePasswordScreen` (new or reuse) | `mustChangePassword === true` after full token |
| `CourierHomeScreen` | Authenticated + password OK (+ phone verified) |

**Remove / keep hidden:** public “Courier space (demo)” CTA on buyer login (already removed). Debug long-press optional only.

### 6.2 Courier OTP screen UX

- Title: “Vérifie ton numéro” / “Verify your phone”  
- Subtitle: masked phone from API  
- 6 boxes; paste support  
- Resend with cooldown timer  
- Dev: show `000000` only in `kDebugMode` if Nest allows  
- On success → change password if needed → home  
- Back: clears preAuth; returns to Sign in  

### 6.3 Blocked states on home

| Condition | Banner / lock |
|-----------|----------------|
| `verificationStatus=PENDING` | “Compte en cours de validation par FripCash” — availability toggle disabled |
| `verificationStatus=REJECTED` | Show `reviewerNote` if present — contact support |
| `phoneVerifiedAt=null` | Should not reach home; if restore stale token, force re-login |

### 6.4 Flutter checklist

- [ ] Marketplace login → courier login retry keeps working  
- [ ] Handle `phone_verification_required` (no missions token stored as courier aud)  
- [ ] Persist only full `aud=courier` token after OTP  
- [ ] OTP verify + resend  
- [ ] Force change password gate  
- [ ] Availability / accept errors mapped to FR/EN copy  
- [ ] No courier entry on website  

---

## 7. Admin Next.js UI contract (`/admin/livreurs`)

**Prototype shipped (mock data):** `fripcash` website `app/admin/livreurs/page.tsx` — replace mock with Nest when §3 is live.

### 7.1 List page

- Banner when using mock: “Données mock — API admin couriers à venir”  
- Stats: total / actifs / OTP en attente (phone unverified) / validation ops (KYC pending)  
- Table columns: livreur (name + phone), zones, véhicule, téléphone (OTP badge), validation (KYC), compte (actif + “En ligne” if available), actions  
- Filters: search q, active, phoneVerified, verificationStatus (column header menus)  
- Primary CTA: **Créer un livreur**

### 7.2 Status chip visual system (required)

All status pills use the **same outline pattern** (not solid filled badges):

| Property | Value |
|----------|--------|
| Background | **White** |
| Text | **Tone color** |
| Border | **Tone color** |
| Width | **Hug content** (`w-fit` / `inline-flex`) — never stretch to column width |
| Shape | Pill / rounded-full |

| Tone | Use |
|------|-----|
| Green | Approuvé, Vérifié (OTP) |
| Amber | En attente (KYC), OTP en attente / Non vérifié |
| Red | Rejeté |
| Primary (brand) | Actif |
| Neutral / muted | Désactivé, Aucun |

**Do not** use solid green/red/primary filled chips for these statuses (looks heavy; “Actif” was stretching the column).

### 7.3 Create drawer / modal

| Field | UI |
|-------|-----|
| Nom complet | text * |
| Téléphone | `+224` prefix + local digits * |
| Zone | select * |
| Véhicule | select moto / voiture / vélo |
| Plaque | optional text |
| **Mot de passe** | **Informational only** — no dropdown, no manual input. Copy: *« Un mot de passe temporaire sera généré automatiquement. Tu pourras le copier une fois après la création… »* |
| Note interne | optional |
| Envoyer SMS d’invitation | checkbox (default on) |

On success: modal **“Mot de passe temporaire”** with monospace password + **Copy** + warning that OTP is at first app login. Password shown **once**.

### 7.4 Detail drawer

Read-only fiche: phone, zones, vehicle, plate, OTP status chip, KYC chip, mustChangePassword hint, available, active, created, last login, notesAdmin.

### 7.5 Row actions

- Voir le détail  
- Approuver / Rejeter… (reject requires note)  
- Activer / Désactiver  
- Réinitialiser le mot de passe → same one-time reveal dialog (server-generated)  
- Renvoyer l’invitation SMS  

### 7.6 Admin checklist

- [x] Mock UI prototype on `/admin/livreurs` (outline chips, auto password copy, create/list/actions)  
- [ ] Wire `GET/POST/PATCH` admin courier APIs (drop mock seed)  
- [ ] Idempotency-Key on create  
- [ ] Never log temporary passwords to analytics  
- [ ] Guard: admin session only  
- [ ] Keep outline status chip system when wiring live data  


---

## 8. Error cheat sheet

| `code` | HTTP | When | Client action |
|--------|------|------|---------------|
| `PHONE_IN_USE` | 409 | Phone already CONSUMER/ADMIN/COURIER | Admin: show conflict |
| `VALIDATION_ERROR` | 400 | Missing zones / weak password | Highlight fields |
| `COURIER_DISABLED` | 403 | `active=false` | “Compte désactivé — contacte FripCash” |
| `INVALID_CREDENTIALS` | 401 | Bad password | Toast |
| `WRONG_AUTH_SURFACE` | 403 | Consumer login with courier phone | Flutter retries courier login |
| `PHONE_NOT_VERIFIED` | 403 | Missions / available before OTP | Force OTP flow |
| `COURIER_NOT_VERIFIED` | 403 | KYC not APPROVED | Banner pending/rejected |
| `phone_verification_required` | 200* | Login branch B (`status` field) | OTP screen (*not an error) |
| `OTP_INVALID` | 400 | Wrong code | Shake + retry |
| `OTP_EXPIRED` | 400 | Timeout | Resend |
| `OTP_MAX_ATTEMPTS` | 429 | Too many tries | Lock + resend later |
| `OTP_RATE_LIMITED` | 429 | Resend spam | Show cooldown |
| `PRE_AUTH_EXPIRED` | 401 | preAuthToken dead | Back to Sign in |
| `PHONE_IMMUTABLE` | 400 | PATCH phone | Explain recreate |
| `REVIEWER_NOTE_REQUIRED` | 400 | Reject without note | Force note |
| `NOT_ADMIN` / `FORBIDDEN_AUDIENCE` | 403 | Wrong token | Bounce login |

---

## 9. End-to-end flows

### 9.1 Happy path — new hire

```
Admin: POST /admin/couriers { phone, zones, sendSmsInvite: true }
  → 201 + server-generated temporaryPassword (copy once in UI) + SMS invite
Courier: installs app → Sign in (same screen) with phone + temp password
  → POST /auth/courier/login
  → status=phone_verification_required + SMS OTP
Courier: enters OTP
  → POST /auth/courier/otp/verify
  → accessToken + mustChangePassword=true
Courier: changes password
Admin: reviews docs → PATCH …/verification { APPROVED }
Courier: toggles available → accepts missions
```

### 9.2 Returning courier

```
Sign in → login → status=authenticated → CourierHome
```

### 9.3 Admin disables

```
PATCH /admin/couriers/:id { active: false }
Next login → COURIER_DISABLED
```

### 9.4 Wrong number typed by admin

```
Disable old courier; create new with correct phone (v1 no phone edit)
```

---

## 10. Curl matrix (staging)

```bash
BASE=http://62.84.179.126:3010/api/v1
ADMIN_TOKEN=…
```

```bash
# Create
curl -sS -X POST "$BASE/admin/couriers" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Idempotency-Key: $(uuidgen)" \
  -d '{
    "phone": "+224620123456",
    "displayName": "Mamadou Diallo",
    "zoneIds": ["REPLACE_ZONE_ID"],
    "vehicleType": "moto",
    "sendSmsInvite": true,
    "verificationStatus": "PENDING"
  }'
```

```bash
# First login (expect phone_verification_required)
curl -sS -X POST "$BASE/auth/courier/login" \
  -H "Content-Type: application/json" \
  -d '{"phone":"+224620123456","password":"PASTE_TEMP"}'
```

```bash
# Verify OTP
curl -sS -X POST "$BASE/auth/courier/otp/verify" \
  -H "Authorization: Bearer $PRE_AUTH" \
  -H "Content-Type: application/json" \
  -d '{"code":"000000"}'
```

```bash
# List
curl -sS "$BASE/admin/couriers?phoneVerified=false" \
  -H "Authorization: Bearer $ADMIN_TOKEN"
```

---

## 11. Acceptance tests (BE)

1. Create courier → userKind/authAudience COURIER, profile row, `phoneVerifiedAt=null`, `isAvailable=false`.  
2. Duplicate phone (consumer) → `PHONE_IN_USE`.  
3. Idempotency-Key replay → same courier id, no second user.  
4. Login before OTP → `phone_verification_required`, missions 403 with preAuth.  
5. Wrong OTP 5× → `OTP_MAX_ATTEMPTS`.  
6. Correct OTP → `phoneVerifiedAt` set, full courier token.  
7. Second login → `authenticated` without OTP.  
8. `isAvailable=true` while `verificationStatus=PENDING` → `COURIER_NOT_VERIFIED`.  
9. After APPROVED + phone verified → availability OK.  
10. `active=false` → login `COURIER_DISABLED`.  
11. Consumer token on `POST /admin/couriers` → 403.  
12. Courier token on `POST /admin/couriers` → 403.  
13. Marketplace `/auth/login` with courier phone → `WRONG_AUTH_SURFACE`.  
14. Reset password → `mustChangePassword=true`, old password fails.  
15. Dev OTP `000000` only when env flag set — **off in production**.  

---

## 12. OpenAPI / docs deliverables

Please document in from-be reply:

- [ ] Request/response schemas for all §3 and §5 routes  
- [ ] Exact `status` discriminator on courier login  
- [ ] Whether OTP is auto-sent on login Branch B (`otpSent`)  
- [ ] Password policy  
- [ ] SMS provider + template ids  
- [ ] Mission gate rule (phone + APPROVED vs phone only)  
- [ ] Migration for existing seed couriers (`phoneVerifiedAt` backfill policy)  

---

## 13. Implementation phasing (suggested)

| Phase | Ship |
|-------|------|
| **A** | `POST/GET/PATCH /admin/couriers` + create password + Admin UI create/list (even without SMS) |
| **B** | Login Branch B + OTP send/verify + Flutter OTP screen |
| **C** | `mustChangePassword` + change-password gate |
| **D** | Enforce mission / availability gates + admin verification actions |
| **E** | Invite SMS + resend + reset password polish |

Flutter + Admin can parallelize against mocked Branch B once OpenAPI is frozen.

---

## 14. Explicit non-goals / anti-patterns

- ❌ “Login as courier” button on marketplace Sign in for production  
- ❌ Courier login on Next.js consumer site  
- ❌ Email OTP for livreurs  
- ❌ Using consumer register OTP purpose for courier verify  
- ❌ Returning password on GET list  
- ❌ Auto-converting an existing buyer phone into courier without explicit ops tool + consent  
- ❌ Letting unverified couriers accept missions  
- ❌ Admin create form with password dropdown / manual password entry  
- ❌ Solid filled status badges that stretch column width (use outline pills: white bg + colored text/border + `w-fit`)  

---

## 15. Summary for BE

We need a **real admin create-courier pipeline** (phone + temp password + zones) and a **first-login SMS OTP gate** on the app before the courier shell is fully unlocked. Today’s `provision-audience` on an existing user id is **not** sufficient for hiring livreurs in Conakry ops.

**Admin creates → SMS invite → app Sign in → OTP → (change password) → admin APPROVED → missions.**
