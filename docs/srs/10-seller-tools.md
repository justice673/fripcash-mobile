# 10 — Seller tools

**Backend contract:** [Seller dashboard KPIs](../from-be/seller-dashboard-mobile-flutter-handoff.md) · [Seller settings / Excel](../from-be/seller-settings-mobile-flutter-handoff.md) · [Listings tools](../from-be/listings-mobile-flutter-handoff.md)

## 10.1 Seller dashboard (“Ma boutique”)
Available when seller profile exists:
- Balance / escrow summary  
- Tabs / queues: boutique overview, to prepare, shipped, sold  
- Quick actions: new listing, my listings, offers  
- Settings entry, share shop

## 10.2 Excel import
- **Allowed for:** boutique standard, proximité, enseigne  
- **Not for:** particulier  
- Upload catalogue file (template `catalogue_boutique.xlsx` in product).  
- BE: validate rows, create listings in batch, return errors per line.

## 10.3 Product library
- **Proximité only**  
- Reusable product templates for faster listing.

## 10.4 Vacation mode
- Seller sets date range; selling paused (listings hidden or non-purchasable — BE chooses; document).  

## 10.5 Bundle discount
- Toggle / rule for multi-item discount (product exists in UI; confirm business rule with stakeholders).

## 10.6 Badges (product/gamification)
Examples: first sale, fast shipper, top rated, eco seller — compute server-side if kept.

## 10.7 Web
Thin: list/create particulier listings; advanced tools → app.
