# RentFlow — Event Equipment Rental Management

> **Kalvium Work-Integrated Learning Program — Sprint 2 (Day 1)**  
> **Campus:** JECRC  
> **Squad:** 124 | **Team:** 04  

---

## 📌 Problem Statement
A regional event equipment rental company supplies sound systems, lighting, and furniture for weddings and corporate events, but bookings and dispatch schedules are coordinated through individual phone calls. During peak season, the same equipment gets committed to overlapping events, and the team finds out only when the warehouse crew begins loading.

---

## 💡 Product Description
**RentFlow** is a dedicated mobile application designed to streamline event equipment rental operations for regional rental businesses. It provides real-time visibility into inventory availability, automates double-booking and schedule conflict detection across overlapping event dates, and provides structured dispatch manifests for warehouse crews to prevent chaotic loading-dock surprises.

---

## 👥 Team & Team Charter

| Member | Primary Responsibilities (Sprint 2 Day 1) | Contact / Role |
| :--- | :--- | :--- |
| **Mayank Sharma** | • Flutter project scaffolding<br>• Layered project architecture setup<br>• Branded Day-1 application shell<br>• Git branching & PR workflow preparation | Developer / Scaffolding Lead |
| **Prateek** | • Product Requirements Document (PRD)<br>• Technical Requirements Document (TRD)<br>• App Flow & Navigation State Maps<br>• Backend Schema (Cloud Firestore)<br>• Phased Implementation Plan | System Design & Planning Lead |

### Team Working Agreement
1. **Communication & Collaboration**: Transparent task division between mobile client scaffolding (Mayank) and system design/specifications (Prateek).
2. **Branching Strategy**: All functional changes develop on dedicated feature branches (e.g., `feature/flutter-scaffold`) and merge via reviewed Pull Requests. Never commit directly to `main`.
3. **Quality Bar**: Zero analyzer errors (`flutter analyze`) and passing automated smoke tests (`flutter test`) before committing code.

---

## 📊 Sprint Status & Scope

- **Current Sprint Status**: Sprint 2 — Day 1: Foundation, Scaffolding & Planning
- **Current Scope**:
  - Flutter workspace initialization
  - Professional layered directory architecture (`core/`, `screens/`, `widgets/`, `models/`, `services/`)
  - Lightweight, branded RentFlow Day-1 application shell
  - Day-1 validation tests and clean Git workflow
  - System design and specification documents in progress by Prateek
- **Out of Scope for Day 1**:
  - Full booking workflow, equipment inventory CRUD, Firebase cloud connection, Maps integration, and calendar/conflict engine (to be implemented in subsequent days following PRD/TRD approval).

---

## 🛠️ Technology Stack & Direction

- **Mobile Client**: Flutter 3.x (Dart 3.x)
- **Design System**: Material Design 3 with custom RentFlow brand identity
- **Planned Backend**: Firebase (Cloud Firestore, Firebase Authentication, Cloud Storage)
- **Target Platforms**: Android, iOS, Windows Desktop, Web

---

## 📂 Project Structure

```text
SW2627-Flutter-DART-RentMate/
├── android/                     # Android native platform files
├── ios/                         # iOS native platform files
├── web/                         # Web platform files
├── windows/                     # Windows desktop platform files
├── test/
│   └── widget_test.dart         # Automated smoke & widget tests
├── docs/                        # Planning, specifications, and architecture
│   ├── PRD.md                   # Product Requirements Document (Prateek)
│   ├── TRD.md                   # Technical Requirements Document (Prateek)
│   ├── APP_FLOW.md              # Application Flow diagrams & screens (Prateek)
│   ├── BACKEND_SCHEMA.md        # Firestore schema & entity models (Prateek)
│   ├── IMPLEMENTATION_PLAN.md   # Sprint 2 roadmap & execution plan (Prateek)
│   └── learning/                # Local-only pedagogical notes (ignored in git)
└── lib/
    ├── core/                    # Core application foundation
    │   ├── constants/           # Centralized constants & app identity
    │   ├── routes/              # Declarative named routes table
    │   └── theme/               # Material 3 brand theme & color palettes
    ├── models/                  # Data entity models (placeholder)
    ├── screens/                 # Full-screen application views
    │   └── home_screen.dart     # Branded RentFlow Day-1 home shell
    ├── services/                # API, database, and backend services (placeholder)
    ├── widgets/                 # Reusable UI components
    │   └── info_card.dart       # Modular informational card component
    └── main.dart                # Application entry point (`runApp`)
```

---

## 📖 Local Learning Notes

Detailed learning notes designed to teach Flutter and Dart concepts (from basic syntax to widget architecture and git workflows) are organized locally in:

```text
docs/learning/
```

> **Note on Version Control:** In accordance with team repository guidelines, `docs/learning/` is ignored by Git in `.gitignore` to keep the official project repository and Pull Requests focused exclusively on project deliverables and specifications.

---

## 🚀 Getting Started & How to Run

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.24+ recommended)
- [Dart SDK](https://dart.dev/get-started) (included with Flutter)
- An IDE (VS Code or Android Studio) with Flutter extensions installed

### Run Instructions

1. **Clone the repository:**
   ```bash
   git clone https://github.com/kalviumcommunity/SW2627-Flutter-DART-RentMate.git
   cd SW2627-Flutter-DART-RentMate
   ```

2. **Fetch dependencies:**
   ```bash
   flutter pub get
   ```

3. **Verify static analysis:**
   ```bash
   flutter analyze
   ```

4. **Run automated tests:**
   ```bash
   flutter test
   ```

5. **Launch the application:**
   ```bash
   # Run on default connected device (Desktop / Chrome / Emulator)
   flutter run

   # Or explicitly choose a platform
   flutter run -d chrome
   flutter run -d windows
   ```
