# Listings & destinations — FE handoff (index)

**Status:** Shipped on API (Nest)

Send these to the right team:

| Team | Doc |
|------|-----|
| **Flutter** | [listings-mobile-flutter-handoff.md](./listings-mobile-flutter-handoff.md) |
| **Next.js** | [listings-web-nextjs-handoff.md](./listings-web-nextjs-handoff.md) |

Shared pricing detail (net → display, admin commissions): [listing-pricing-fe-handoff.md](./listing-pricing-fe-handoff.md).

---

## What changed (one screen)

1. **Destination is server-owned** — do **not** send `destination` on create/update.
2. **Categories are shared** — do **not** filter sell Step 1 by `Category.destination` (optional browse hint only; often `null`).
3. **Public PDP/list hide net & commission** — buyers only see `displayPriceGnf`.
4. **Seller inventory** — `GET /api/v1/me/listings` includes net + commission.
5. **Lifecycle** — `publish` / `hide` / `price` / `stock` / `copy` (copy → **new** draft).
6. **Condition codes** — `conditionCode`; shops forced to Neuf-family.
7. **Taxonomy + rates** — sell cats from `GET /catalog/categories`; wizard sizes/colors from `GET /catalog/listing-taxonomy`; `GET /platform/commission-rates`.
8. **Excel** — `POST /me/seller/tools/excel-import` with `rows[]`.
9. **Product library publish** — proximité only.

Endpoint catalogue: [endpoint-index.md](./endpoint-index.md).
