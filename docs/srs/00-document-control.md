# 00 — Document control

## Document purpose
This SRS pack defines **what FripCash must do** so backend, mobile, and web stay aligned. It is requirements-oriented (behaviour + business rules), not UI pixel specs.

## Systems in scope
| System | Tech (current) | Users |
|--------|----------------|--------|
| Mobile marketplace app | Flutter | Buyers, sellers (particulier / boutique / proximité / enseigne) |
| Mobile courier shell | Flutter (same repo, separate shell) | Livreurs |
| Public website + light account dashboard | Next.js | Buyers + light sell (particulier) |
| Admin console | Next.js `/admin` | Staff / admin |

## Out of this pack
- Exact NestJS / DB schema (BE designs from these rules)
- Marketing copy polish
- Store listing assets

## Source of truth priority
1. This `docs/srs/` pack  
2. Implemented Flutter + web UI (when a gap appears, update SRS — do not silently invent BE behaviour)

## Versioning
| Version | Date | Notes |
|---------|------|--------|
| 0.1 | 2026-09-12 | Initial detailed multi-file SRS from product + UI |

## Languages
- Product UI: French primary, English secondary (Flutter i18n).  
- This SRS: English for engineering clarity; French labels preserved where they are product terms.
