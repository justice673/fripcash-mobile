# 04 — Discovery and catalog

**Backend contract:** [Listings / catalog](../from-be/listings-mobile-flutter-handoff.md) · live OpenAPI

## 4.1 Home universes (listing destinations)
Every live listing belongs to exactly one destination, derived from seller profile:

| Destination | Who | Notes |
|-------------|-----|--------|
| `secondeMain` | Particulier | Second-hand conditions allowed |
| `articlesNeufs` | Boutique standard | Condition normalized to Neuf |
| `quartierBoutiques` | Proximité (approved) | Neuf; quartier perimeter |
| `enseignes` | Enseigne (approved) | Neuf; no offers / demander |

Client grouping (UX): “Mode” (seconde main + articles neufs) and “Courses” (quartier + enseignes) — presentation only; API still stores destination.

## 4.2 Delivery perimeter
| Value | Typical for |
|-------|-------------|
| `monQuartier` | commerce local / proximité |
| `touteLaVille` | boutique standard, enseigne |

Fixed by signup/upgrade path (not freely edited per listing in v1).

## 4.3 Zones
Configurable geographic zones (admin). Mock baseline: Zone 1 / Zone 2 Conakry quartiers. Users and couriers are associated with a zone for discovery and logistics.

## 4.4 Browse / search requirements
- Category navigation (platform catalog — see listings SRS).  
- Filters: price (GNF), condition, gender / category-specific filters.  
- Shop / seller discovery carousels.  
- Enseigne category filters (grocery, appliances, lighting, home, mode, etc.).  
- Only **approved** proximité/enseigne shops appear in public directories.

## 4.5 Product detail (buyer view)
- Images, title, price (display), condition, size, stock, seller card.  
- Actions: favorite, share, add to cart, make offer (if allowed), message (if allowed).  
- Enseigne: hide offer / demander.
