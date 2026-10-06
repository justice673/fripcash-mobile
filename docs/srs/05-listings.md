# 05 — Listings (create / edit / photos)

**Backend contract:** [Listings](../from-be/listings-mobile-flutter-handoff.md) · live OpenAPI

## 5.1 Who can create
- Must have seller profile.  
- Must not be verification-`pending` or `rejected` for paths that require approval.  
- Destination and seller type set by server from profile.

## 5.2 Create listing wizard (mobile reference)
Steps:
1. **Category** — from platform catalog (seller selects; does not invent root taxonomy).  
2. **Photos** — gallery and/or camera (device OS permission prompts).  
3. **Details** — title, description, brand, size, colors, condition, stock, negotiable flag.  
4. **Price** — seller enters **net**; system shows **display** price after commission preview (server final).

Also: drafts, resume draft, edit existing, copy listing, photo tips.

## 5.3 Photos
- Min 1 photo to publish.  
- Max ~8 per listing (UI currently caps; BE may set hard limit).  
- Capture: camera; upload: gallery.  
- Backend: store media (object storage), attach URLs to listing.  
- OS permissions are client-side (already declared on iOS/Android).

## 5.4 Platform catalog (seller taxonomy)
Root categories include (aligned with app catalog): mode, shoes, electronics, beauty, baby, grocery, home, secondhand — with size schemas (clothing, shoeEu, babyAge, oneSize, tvInches, phoneStorage, none).

Admin can manage catalog structure (web admin categories).

## 5.5 Condition rules
- Particulier / seconde main: second-hand condition set allowed.  
- Boutique / proximité / enseigne: treat as **Neuf** (normalize if client sends other).

## 5.6 Listing lifecycle
| Status | Meaning |
|--------|---------|
| draft | Not public |
| active | Public (if shop allowed) |
| sold / soldOut | No longer buyable (stock 0 or marked sold) |
| rejected / flagged | Moderation |

## 5.7 Pricing fields
- `netPrice` (seller)  
- `displayPrice` / buyer price (includes platform commission logic)  
- Optional compare-at / discount UI  
- Shipping cost estimate (courier vs pickup)

## 5.8 Web vs app
Web: light create for **particulier** after upgrade. Advanced shop tools stay in app.
