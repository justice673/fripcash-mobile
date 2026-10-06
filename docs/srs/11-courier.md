# 11 — Courier (livreur)

**Backend contract:** [Courier](../from-be/courier-mobile-flutter-handoff.md) · live OpenAPI

## 11.1 Scope
Separate mobile shell for couriers — not the marketplace sell tab.

## 11.2 Onboarding / profile
- Courier account (role `livreur`)  
- Profile: zone, vehicle, plate, verification docs (admin can review)  
- Availability toggle (available / unavailable for new missions)

## 11.3 Missions
- List open missions in courier zone when status ready for courier pickup.  
- Accept mission → `courierAssigned`.  
- Progress: collected → inTransit → delivered.  
- Optional: transfer to another courier in same zone.

## 11.4 Earnings
- Delivery fee per completed mission credited to courier wallet.  
- History + simple earnings charts (client).  
- Withdraw via Orange Money (same wallet rails as sellers, labeled).

## 11.5 Admin
- Livreurs CRUD / verification, assignment monitoring.
