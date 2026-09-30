# Backend Schema Design — RentFlow

**Project:** RentFlow — Event Equipment Rental Management Application  
**Team:** Squad 124 | Team 04 | JECRC  
**Author:** Prateek  
**Status:** In Progress (Sprint 2 Planning Phase)

---

## 1. Planned Collections (Cloud Firestore)
- `users`: User profiles and organizational roles (`admin`, `coordinator`, `warehouse`).
- `equipment`: Inventory items (item ID, name, category, total quantity, status, serial/asset tags).
- `bookings`: Reservations (event date range, client info, list of reserved equipment items with quantities, reservation status).
- `dispatches`: Warehouse manifests (booking ID, scheduled dispatch timestamp, loaded checklist, return verification).

*(Detailed entity definitions, validation rules, and indexes are being authored by Prateek).*
