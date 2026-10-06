# 15 — Platforms: web vs app (same API)

## 15.1 Principle
**One API**, different UI depth. Do not invent parallel “web-only listing” domain models.

## 15.2 Mobile app (Flutter)
Full product:
- All signup / upgrade paths  
- Full sell wizard, seller dashboard, Excel, library  
- Courier shell  
- Offers, chat, wallet, vacation, bundles  

## 15.3 Public website + dashboard (Next.js)
- Marketing / browse  
- Auth (light)  
- Account dashboard: profile, orders (achats + ventes when seller), favorites, messages, notifications, wallet view  
- **Sell:** particulier upgrade + light listing  
- Boutique / proximité / enseigne / livreur → **CTA to mobile app**

## 15.4 Admin (Next.js)
Ops only — see admin SRS.

## 15.5 Capability snapshot
`GET /me` should return seller capabilities so **all clients** gate UI the same way (createListing, excelImport, productLibrary, sellerDashboard, verificationStatus).
