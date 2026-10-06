# 16 — Open questions and out of scope

## 16.1 Explicitly out of scope for BE v1 (unless product reopens)
- Free role switcher in Settings  
- Downgrade boutique → buyer from casual UI (support flow later)  
- Multi-destination picker per listing for one shop  
- Consumer-facing admin dispute screen inside the marketplace app  

## 16.2 Currently UI / mock — BE must implement for real
- Orange Money live integration  
- SMS OTP provider  
- Object storage for photos  
- Excel import parsing  
- Push provider (FCM / APNs)  
- Real escrow ledger  

## 16.3 Open product decisions (confirm with stakeholders)
1. Exact gate: is OTP required before first listing, or only before payout?  
2. Multi-seller cart → one payment / N orders — chosen model?  
3. Dispute window length after delivery?  
4. Vacation mode: hide listings vs block checkout only?  
5. Bundle discount exact rule?  
6. Optional KYC for particulier payouts — ID document or phone-only?  
7. Commission display split (Orange Money % vs FripCash %) — final legal/copy numbers?

## 16.4 How to use this pack
Send **all files** in `docs/srs/`.  
Backend may produce **one consolidated SRS.md** on their side; keep this pack as the detailed source so nothing is dropped when merging.
