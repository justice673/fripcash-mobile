# 14 — Non-functional requirements

## 14.1 Localization
- Flutter: French + English (ARB).  
- Web admin: French-first.  
- API error codes should be stable; clients localize messages.

## 14.2 Security
- Token-based auth; HTTPS only.  
- Password hashing (server).  
- Authorization on every seller/admin/courier endpoint.  
- PII protection (phone, address, docs).  
- Rate-limit OTP and login.

## 14.3 Device permissions (mobile client — already declared)
- Camera + photo library for listing photos (and chat images).  
- iOS usage strings / Android runtime permissions.  
- Not a BE concern except storing uploaded files securely.

## 14.4 Performance / scale (targets for BE to refine)
- Listing feed pagination.  
- Image CDN / object storage.  
- Idempotent payment webhooks.

## 14.5 Reliability
- Payment webhook reconciliation.  
- Order status transitions as a state machine (reject illegal jumps).

## 14.6 Observability
- Structured logs, admin audit trail for money and validation actions.
