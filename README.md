# 🎪 RentMate / RentFlow Operations Cockpit

<div align="center">

[![Flutter](https://img.shields.io/badge/Flutter-3.24+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.4+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Cloud_Firestore-Authoritative_Transactions-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![Tests](https://img.shields.io/badge/Automated_Tests-46%2F46_Passing-brightgreen?logo=checkmarx&logoColor=white)](test/)
[![Analysis](https://img.shields.io/badge/Static_Analysis-0_Issues-success?logo=dart&logoColor=white)](analysis_options.yaml)
[![Platforms](https://img.shields.io/badge/Platforms-Android_%7C_iOS_%7C_Web_%7C_Linux_%7C_Windows-blue)](#-cross-platform-support)
[![Architecture](https://img.shields.io/badge/Design_System-Industrial_Atelier-B85D19)](#-design-system--ui-philosophy)

**A mission-critical event equipment rental operations system built with Flutter and Cloud Firestore.**  
*Eliminating double-bookings, automating multi-day capacity allocation, and coordinating warehouse dispatch manifests in real time.*

[Live Web Demo](http://localhost:8080) • [Architecture Guide](docs/TRD.md) • [Product Requirements](docs/PRD.md) • [Mock UX](docs/MOCK_UX.md) • [Test Suite](test/)

</div>

---

## 📌 Problem Statement & Real-World Context

Regional event equipment rental companies supply sound systems, intelligent lighting, LED video walls, generators, and staging for high-stakes weddings and corporate summits. Historically, reservations and dispatch schedules are coordinated across phone calls, spreadsheets, and whiteboard rosters.

During peak seasons:
- The **same physical equipment gets promised to multiple overlapping events**.
- Warehouse crews discover equipment shortages **only at the loading dock** while loading trucks.
- Damaged returns are inadvertently counted as rentable stock, triggering cascading cancellations.

**RentMate** solves this operational chaos with an **authoritative distributed reservation transaction engine**, real-time inventory reconciliation, and interactive manifest checklists for warehouse staff.

---

## ✨ Core Features & Workflows

### 1. 🛡️ Authoritative Distributed Reservation Engine
- **Deterministic Allocation Documents**: Every reservation writes to daily allocation records (`allocations/{sku}_{yyyy-MM-dd}`) inside a single Cloud Firestore transaction.
- **Strict All-or-Nothing Guarantee**: If 9 out of 10 line items are available across a 4-day festival, but 1 amplifier is overcommitted on day 3, the entire transaction rolls back atomically. Zero partial reservations.
- **Maintenance Quarantine**: Rentable capacity is strictly calculated as $Capacity_{rentable} = \text{Total Stock} - \text{Maintenance Stock}$. Broken or in-bench equipment is excluded from rental availability.

### 2. ⚡ Dynamic Conflict Detection & Remediation Sheet
When requested equipment exceeds capacity, RentMate catches `AvailabilityConflictException` without clearing user input and presents the **Booking Conflict Resolution Sheet**:
- **Auto-Reduce to Max Available**: Instantly caps quantity to the exact physical capacity.
- **Change Rental Window**: Directs user back to Step 1 date selection.
- **Join Waitlist / Cross-Rental**: Logs external vendor cross-hire requirements.

### 3. 📋 3-Step Booking Wizard with Multi-Day Dynamic Pricing
- **Step 1 (Event Details)**: Captures client info, venue, and start/end dates with strict validation.
- **Step 2 (Equipment Manifest)**: Dynamic catalog search and category filtering with auto-calculated duration scaling:
  $$\text{Total Cost} = \sum (\text{Qty} \times \text{Daily Rate}) \times \text{Rental Days}$$
- **Step 3 (Review & Idempotent Confirmation)**: Presents financial breakdown and disables double-clicks with progress spinners.

### 4. 🚚 Warehouse Dispatch Manifest & Packing Checklist
- Interactive packing checklist tracking serialized equipment into flight cases and trucks.
- Progress bar (`0%` $\to$ `100%`) synchronizes in real time to `packedSkus` in Firestore.
- Vehicle departure action persists permanent audit logs to `dispatches/{bookingId}` and transitions booking status to `DISPATCHED`.

### 5. 📥 Atomic Return Intake & Inventory Reconciler
- Restocks returned units back to rentable inventory using stable operation IDs (`RET-{bookingId}`).
- Segregates broken or missing gear directly into `maintenanceQuantity` with repair notes.
- Prevents double-counting and inventory corruption across network retries.

### 6. 🔒 Fail-Closed Security & Role-Based Access Control (RBAC)
- **Coordinator (`coordinator`)**: Full booking creation, calendar rescheduling, and catalog management.
- **Warehouse (`warehouse`)**: Land directly on Dispatch Queues; restricted field updates (`status`, `packedSkus`, `updatedAt`).
- **Admin (`admin`)**: Fleet management, user access control, and master auditing.

---

## 🏛️ System Architecture

```
┌────────────────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER (Flutter UI)                     │
│  • Dashboard Overview  • 3-Step Booking Wizard  • Dispatch Dock Screen  │
│  • Booking Conflict Sheet  • Return Intake Sheet  • Inventory Catalog  │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
┌───────────────────────────────────▼────────────────────────────────────┐
│                   APPLICATION & SERVICE LAYER                          │
│  • AvailabilityService (Concurrency Control, Distributed Allocations)  │
│  • BookingRepository   (Real-Time Streams, Offline Resilience Fallback)│
│  • InventoryRepository (Fleet Aggregates, Atomic Return Batches)       │
│  • AuthService         (Fail-Closed Role Resolution & Token Auth)      │
│  • SeedService         (Zero-Latency Cloud & In-Memory Seeding)        │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
┌───────────────────────────────────▼────────────────────────────────────┐
│                    DATABASE & CLOUD PERSISTENCE                        │
│  • Cloud Firestore (/equipment, /bookings, /allocations, /dispatches)  │
│  • Least-Privilege Firestore Security Rules (firestore.rules)          │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 📂 Project Directory Structure

```text
SW2627-Flutter-DART-RentMate/
├── .github/                      # GitHub Actions CI/CD workflows
├── android/                      # Native Android configuration
├── ios/                          # Native iOS configuration
├── web/                          # Web platform support
├── linux/                        # Native Linux Desktop platform
├── macos/                        # Native macOS Desktop platform
├── windows/                      # Native Windows Desktop platform
├── docs/                         # Formal engineering specifications
│   ├── PRD.md                    # Product Requirements Document
│   ├── TRD.md                    # Technical Requirements Document
│   ├── MOCK_UX.md                # 3.8 Mock UX Wireframe & Journey Spec
│   ├── APP_FLOW.md               # Navigation & Screen State Flow Map
│   ├── BACKEND_SCHEMA.md         # Firestore Collections & Index Schema
│   ├── IMPLEMENTATION_PLAN.md    # Phased Engineering Roadmap
│   └── BUG_REGISTER.md           # Repository Audit & Bug Debt Log
├── firestore.rules               # Production fail-closed Firestore security rules
├── pubspec.yaml                  # Project manifest, dependencies, and assets
├── test/                         # Comprehensive automated test suites (46 tests)
│   ├── distributed_reservation_and_persistence_test.dart
│   ├── availability_and_lifecycle_test.dart
│   ├── create_booking_test.dart
│   ├── dispatch_and_returns_test.dart
│   ├── day1_bugfixes_test.dart
│   └── widget_test.dart
└── lib/                          # Modular production source code
    ├── main.dart                 # Application entry point & initialization
    ├── firebase_options.dart     # Firebase multi-platform configuration
    ├── core/
    │   ├── constants/            # Fleet categories, operational defaults
    │   ├── models/               # Domain entities (EquipmentItem, BookingItem, UserModel)
    │   ├── routes/               # Declarative routing table
    │   ├── services/             # Core business engines (Availability, Seed, Auth)
    │   └── theme/                # Industrial Atelier design system
    ├── screens/
    │   ├── bookings/             # Booking list, wizard, conflict sheet, details
    │   ├── dashboard/            # Operational cockpit & KPI monitoring
    │   ├── dispatch/             # Dock queues, manifest checklists, returns
    │   ├── inventory/            # Fleet browser, category filters, conditions
    │   ├── login/                # Role-aware authentication view
    │   └── signup/               # Fail-closed employee registration
    └── widgets/                  # Reusable branded UI components
```

---

## 🎨 Design System: "Industrial Atelier"

RentMate employs a purpose-built **Industrial Atelier** visual language engineered for high-visibility warehouse docks and outdoor staging environments:

| Token | Hex | Role |
| :--- | :--- | :--- |
| **Burnt Copper** | `#B85D19` | Primary brand accent, commitment buttons, active tabs |
| **Ink Black** | `#1C1B1F` | High-contrast typography and dominant structural frames |
| **Bone / Sand** | `#F9F8F6` | Eye-strain reducing background surfaces |
| **Muted Slate** | `#6B7280` | Secondary metadata and rack bay coordinates |
| **Forest Sage** | `#2E7D32` | Available rentable capacity indicators |
| **Crimson Rust** | `#C62828` | Conflict alerts, damage quarantine, cancellations |

---

## 🚀 Getting Started & Execution

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.24+ recommended)
- [Dart SDK](https://dart.dev/get-started) (bundled with Flutter)
- Chrome or modern browser (Web) or Android Studio / Emulator (Mobile)

### 1. Installation & Dependencies
```bash
git clone https://github.com/kalviumcommunity/SW2627-Flutter-DART-RentMate.git
cd SW2627-Flutter-DART-RentMate
flutter pub get
```

### 2. Run the Application

```bash
# Run on Chrome / Web (Port 8080)
flutter run -d chrome --web-port 8080

# Run on Linux Desktop
flutter run -d linux

# Run on Android Emulator / Physical Device
flutter run -d android
```

### 3. Build Production Releases
```bash
# Build optimized release Web bundle
flutter build web --release

# Build standalone Android APK
flutter build apk --release
```

---

## 🧪 Automated Testing & Verification

RentMate maintains strict quality gates with **46 passing automated tests** covering distributed transactions, availability mathematics, and warehouse returns:

```bash
# Run static code analysis (0 warnings)
flutter analyze --no-pub

# Execute all test suites
flutter test
```

### Verified Test Suites:
1. `test/distributed_reservation_and_persistence_test.dart` (11 tests: Competing concurrent reservations, all-or-nothing multi-SKU checks, maintenance capacity deductions, return idempotency, persistent checklists, fail-closed RBAC, and data seeder).
2. `test/availability_and_lifecycle_test.dart` (6 tests: Date interval collision detection, cancellation capacity release, rescheduling collision avoidance).
3. `test/dispatch_and_returns_test.dart` (5 tests: 3-queue dispatch view, packing checklist progress, return reconciliation).
4. `test/create_booking_test.dart` (Step field validation, item selection, duration pricing).
5. `test/day1_bugfixes_test.dart` (Duration scaling, sign out, navigation).
6. `test/widget_test.dart` (Application bootstrap, routing, authentication flows).

---

## 👥 Team & Governance

- **Mayank Sharma** ([@MayankSharma-2812](https://github.com/MayankSharma-2812)) — *Lead Flutter & Concurrency Engineer*
- **Prateek Verma** ([@Prateekverma11](https://github.com/Prateekverma11)) — *System Architecture & QA Reviewer*
- **Campus**: JECRC University  
- **Squad**: 124 | **Team**: 04  
- **Institution**: Kalvium Work-Integrated Learning Program  

---

<div align="center">
  <sub>Built with engineering rigor for regional event operations. Clean architecture, zero double-bookings.</sub>
</div>
