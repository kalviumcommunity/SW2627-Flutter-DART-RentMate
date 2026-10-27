# RentMate Mock UX Specification: Design the Experience Before You Build It

**Module Reference:** 3.8 Mock UX: Design the Experience Before You Build It  
**Project:** RentMate (RentFlow Event Equipment Operations)  
**Target Users:** Event Booking Coordinators (`coordinator`), Warehouse Operations Staff (`warehouse`), System Administrators (`admin`)  
**Core Business Problem:** Event equipment rental companies coordinate bookings through manual calls. Overlapping event reservations cause double-bookings discovered only during truck loading.

---

## 1. End-to-End Navigation & Screen Flow Diagram

```
[Login / Role Selector]
         │
         ├─── (Role: Coordinator / Admin) ──────────────────┐
         │                                                  ▼
         │                                       ┌─────────────────────────┐
         │                                       │ SCREEN 1: Operations    │◄───────────┐
         │                                       │ Dashboard (Monitor)     │            │
         │                                       └───────────┬─────────────┘            │
         │                                                   │                          │
         │                        ┌──────────────────────────┴────────────────────────┐ │
         │                        ▼                                                   ▼ │
         │             ┌─────────────────────────┐                         ┌─────────────────────────┐
         │             │ SCREEN 2: 3-Step        │                         │ SCREEN 3: Equipment     │
         │             │ Booking Wizard          │                         │ Catalog & Calendar      │
         │             └──────────┬──────────────┘                         └─────────────────────────┘
         │                        │
         │                        ▼
         │             [Conflict Check Engine]
         │             ├── No Conflict ──► [CONFIRMED] ─────────────────────────────────┤
         │             └── Shortage ─────► [SCREEN 2E: Conflict Resolution Sheet]       │
         │                                                                              │
         └─── (Role: Warehouse) ────────────────────────────────────────────────────────┤
                                                                                        ▼
                                                                           ┌─────────────────────────┐
                                                                           │ SCREEN 4: Dispatch &    │
                                                                           │ Returns Dock            │
                                                                           └──────────┬──────────────┘
                                                                                      │
                                                           ┌──────────────────────────┴──────────────┐
                                                           ▼                                         ▼
                                                ┌─────────────────────┐                   ┌─────────────────────┐
                                                │ SCREEN 4A: Packing  │                   │ SCREEN 4B: Return   │
                                                │ Manifest Checklist  │                   │ Intake Sheet        │
                                                └─────────────────────┘                   └─────────────────────┘
```

---

## 2. Low-Fidelity Wireframes & Layout Architecture

### Screen 1: Coordinator Operations Dashboard (`/dashboard`)
*User Mode: **Monitor** (5-second health check) & **Explore***

```
┌───────────────────────────────────────────────────────────────────────────┐
│ [LOGO] RentMate Operations         [Mon, 27 Oct]       [Mayank (Coord) ▾] │
├───────────────────────────────────────────────────────────────────────────┤
│ [KPI 1: 148 Units Total] [KPI 2: 12 Active] [KPI 3: 02 Conflicts] [KPI 4] │
│ · Fleet in warehouse     · In rental cycle  · Action required   · Rev/Day │
├───────────────────────────────────────────────────────────────────────────┤
│ QUICK COMMANDS:  [+ New Booking (Primary CTA)]  [🔍 Search SKU]  [📅 Cal] │
├───────────────────────────────────────────────────────────────────────────┤
│ LIVE DISPATCH TIMELINE (Next 24h)              [Filter: All Categories ▾] │
│ ───────────────────────────────────────────────────────────────────────── │
│ • 14:00 | BK-8942 · Sharma Royal Wedding    · 24 Units · [READY]          │
│ • 18:30 | BK-8941 · TechCorp Global Summit  · 42 Units · [PACKING 50%]    │
│ • 21:00 | BK-8930 · Saffron Heritage Sangeet· 28 Units · [DISPATCHED]     │
├───────────────────────────────────────────────────────────────────────────┤
│ [DOCK NAV: 📊 Overview (Active) | 📋 Bookings | 📦 Inventory | 🚚 Dispatch]│
└───────────────────────────────────────────────────────────────────────────┘
```

---

### Screen 2: 3-Step Booking Wizard (`/bookings/new`)
*User Mode: **Filter** & **Investigate***

```
┌───────────────────────────────────────────────────────────────────────────┐
│ ◄ Back to Overview          CREATE EVENT BOOKING             Step 2 of 3  │
├───────────────────────────────────────────────────────────────────────────┤
│ [Step 1: Event Info ✓] ─── [Step 2: Equipment (Active)] ─── [Step 3: Review]│
├───────────────────────────────────────────────────────────────────────────┤
│ RENTAL WINDOW: 28 Oct 2026 — 30 Oct 2026 (3 Days Duration)    [Change 📅] │
├───────────────────────────────────────────────────────────────────────────┤
│ [Filter: Audio ▾] [Filter: Lighting ▾] [Search Equipment SKU / Name.....] │
├───────────────────────────────────────────────────────────────────────────┤
│ [AU-K2-LARR] L-Acoustics K2 Line Array Module         Available: 12 Units │
│ Rate: ₹3,000/day · Dual 12" Neodymium               [- 2 +]  Sub: ₹18,000 │
├───────────────────────────────────────────────────────────────────────────┤
│ [LT-PNT-700] Robe Robin Pointe Moving Beam            Available: 08 Units │
│ Rate: ₹1,800/day · 280W Lamp, DMX 24ch              [- 4 +]  Sub: ₹21,600 │
├───────────────────────────────────────────────────────────────────────────┤
│ SUMMARY: 6 Items Selected (2 SKUs) · 3 Days Duration   TOTAL: ₹39,600     │
│ [Cancel Draft]                                 [Next: Review & Confirm ►] │
└───────────────────────────────────────────────────────────────────────────┘
```

---

### Screen 2E & Screen 4B: Edge & Operational States

```
SCREEN 2E: Shortage Conflict Sheet (Error State)
┌─────────────────────────────────────────────────────────┐
│ ⚠️ EQUIPMENT AVAILABILITY CONFLICT                      │
│ Requested rental overlaps with "TechCorp Summit (BK-8941)"│
├─────────────────────────────────────────────────────────┤
│ Item: Powersoft X8 Touring Amplifier (AU-PWR-X8)        │
│ · Requested: 3 Units  · Available on Oct 28: 2 Units     │
│ · Shortage: 1 Unit Over Capacity (Total: 6, Maint: 1)   │
├─────────────────────────────────────────────────────────┤
│ RECOMMENDED RESOLUTIONS:                                │
│ [ ⚡ Auto-Reduce to 2 Units (Max Available) ]            │
│ [ 📅 Change Rental Dates (Step 1) ]                      │
│ [ 📝 Log Cross-Rental / Waitlist Request ]               │
└─────────────────────────────────────────────────────────┘

SCREEN 4B: Return Intake & Reconciliation (Warehouse)
┌─────────────────────────────────────────────────────────┐
│ 📥 RETURN RECONCILIATION: BK-8930 (Saffron Sangeet)     │
├─────────────────────────────────────────────────────────┤
│ JBL VRX932LA (4 units dispatched)                       │
│ (●) 4 Good Condition (Restock)    ( ) Report Damaged    │
├─────────────────────────────────────────────────────────┤
│ Sharpy 230W Beam (8 units dispatched)                   │
│ [ Good: 7 Units ]  [ Damaged / Maint: 1 Unit ]          │
│ Notes: "Cracked lens cover during venue load-out"       │
├─────────────────────────────────────────────────────────┤
│ [Cancel]                     [ Reconcile & Restock Fleet ]│
└─────────────────────────────────────────────────────────┘
```

---

## 3. Screen Purpose & UX Component Justifications

1. **Screen 1 (Operations Dashboard):** Serves the *Monitor* mode. Places 4 high-level KPI cards (Total Fleet, Active Bookings, Critical Shortages, Revenue) **above the fold** so coordinators evaluate fleet strain in under 5 seconds without scrolling (PRD: US-09).
2. **Screen 2 (3-Step Booking Wizard):** Breaks high-friction data entry into linear progressive disclosures:
   - **Step 1 (Event Metadata & Rental Dates):** Captures venue, dates, and client requirements with strict field validation.
   - **Step 2 (Equipment Manifest):** Real-time inventory calculation scales item rates by total event days:
     $$\text{Total} = \sum (\text{Qty} \times \text{Daily Rate}) \times \text{Duration}$$
   - **Step 3 (Authoritative Review):** Shows single-button commitment with idempotency locks against double-clicks (PRD: US-03, US-04).
3. **Screen 3 (Inventory & Calendar Catalog):** Serves *Compare* and *Explore* modes. Shows total vs rentable capacity ($Total - Maintenance$) so damaged units are never committed.
4. **Screen 4 (Dispatch & Loading Dock):** Designed specifically for warehouse personnel with high-contrast, touch-friendly checkboxes (Screen 4A) to verify serialized cases into transport trucks (PRD: US-06, US-07).

---

## 4. Design Reasoning & PRD Alignment

- **Above-The-Fold Information Hierarchy:** Coordinators manage up to 30 events simultaneously; putting unresolved equipment shortages directly beneath top KPI cards prevents discovery during warehouse loading.
- **Persistent Bottom Dock Navigation:** Supports non-linear switching across Overview, Bookings, Fleet Inventory, and Dispatch Dock in 1 click.
- **Fail-Closed Role-Based Landing:** Warehouse staff land directly on the Dispatch Queue (`Tab 3`) rather than financial KPIs, streamlining operational throughput (PRD: US-06).

---

## 5. Edge State Design (Empty & Error States)

1. **Empty Filter State:** If a search matches 0 equipment items, the UI displays an empty illustration: *"No equipment matching 'Mixer' — Clear filters or check Maintenance bench"*, with an instant **"Reset Filters"** pill.
2. **Deterministic Conflict State (Screen 2E):** If concurrent bookings claim final stock, the UI prevents silent failure. Form inputs are preserved, and an actionable modal offers 1-click remediation (Auto-reduce, Reschedule, or Vendor sub-rental) rather than a dead-end error code (PRD: US-05).
3. **Idempotent Return Reconciliation (Screen 4B):** Allows partial damage reporting; good units immediately return to available stock, while broken units quarantine to maintenance with timestamped audit logs (PRD: US-08).
