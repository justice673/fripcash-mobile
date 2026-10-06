# 03 — Auth and onboarding

**Backend contract:** [Auth](../from-be/auth-mobile-flutter-handoff.md) · live OpenAPI

## 3.1 Goals
Secure phone-based accounts; clear path from buyer → seller without re-registration.

## 3.2 Auth flows (required)
| Flow | Requirements |
|------|----------------|
| Register | Phone (+224), password, profile fields; optional signup role path |
| Login | Phone + password → session token |
| OTP / SMS verify | Required before trusted actions (at least before sell / payout — BE confirms exact gate) |
| Forgot / reset password | Phone → OTP → new password |
| Logout | Invalidate session |
| Change password | Authenticated |

## 3.3 Onboarding (mobile)
After first login: short slides + privacy acceptance (client can store acceptance flag server-side).

## 3.4 Become seller / upgrade (critical)

### Allowed
- Buyer → **particulier** (light: zone, address, SLA).  
- Buyer or particulier → **boutique / proximité / enseigne** (shop details; validation when required).  

### Not allowed
- Casual role switcher in Settings.  
- Silent auto-upgrade on first listing submit without completing upgrade form.  
- Changing `user.id` on upgrade (breaks history).

### After upgrade
- Purchases remain.  
- Sales / listings appear under seller profile (empty until first activity).  
- Wallet is the same account, labeled by movement type.

## 3.5 Verification lifecycle (proximité / enseigne)
| Status | Directory visible | Can publish live listings |
|--------|-------------------|---------------------------|
| pending | No | No |
| approved | Yes | Yes |
| rejected | No | No (re-apply) |

Admin approves/rejects via admin console.

## 3.6 Courier auth
Separate entry (“Espace livreur”) → courier credentials / role claim → courier shell only.

**Full detail:** [17-authentication-surfaces.md](./17-authentication-surfaces.md) (Surface D).

## 3.7 Admin auth
Separate admin login on web (`/admin-login`, email + password); staff-only routes. **Not** the same session as `/connexion` or mobile marketplace login.

**Full detail:** [17-authentication-surfaces.md](./17-authentication-surfaces.md) (Surface C).

## 3.8 Web dashboard vs mobile
Same **consumer** account/API as the mobile app. Dashboard is a thin client of Surface A/B — see authentication surfaces doc.
