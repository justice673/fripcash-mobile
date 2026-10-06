# 13 — Notifications

## 13.1 Channels
- In-app notification center (app + web dashboard)  
- Push notifications (mobile) — opt-in via OS + in-app settings toggle  
- SMS for OTP (and optionally critical order alerts)

## 13.2 Event triggers (minimum)
| Event | Recipients |
|-------|------------|
| OTP / auth codes | User |
| Offer received / accepted / refused | Buyer or seller |
| Order status changes | Buyer, seller, courier as relevant |
| Escrow held / released | Buyer, seller |
| Dispute opened / resolved | Parties + admin ops |
| Shop validation approved / rejected | Seller |
| New chat message | Other participant |

## 13.3 Requirements
- Persist notifications; mark read.  
- Localized FR/EN bodies.  
- Respect user notification preferences where applicable.
