# Technical Requirements Document (TRD) — RentFlow

**Project:** RentFlow — Event Equipment Rental Management Application  
**Team:** Squad 124 | Team 04 | JECRC  
**Author:** Prateek  
**Status:** In Progress (Sprint 2 Planning Phase)

---

## 1. System Architecture Overview
RentFlow is built using **Flutter** for cross-platform mobile delivery with **Firebase** as the backend cloud provider.

- **Frontend Client**: Flutter (Dart 3)
- **Cloud Backend**: Firebase (Firestore, Firebase Auth, Cloud Storage)
- **Architecture Pattern**: Layered Feature Architecture (Core, Screens, Widgets, Models, Services)

## 2. Core Technical Constraints
- Real-time conflict checks to prevent concurrent double-booking of physical assets.
- Offline-first caching or graceful degrade for warehouse floor connectivity.
- Role-based permissions for managers vs. warehouse loaders.

*(Detailed architecture diagrams, component specifications, and tech stack details are being authored by Prateek).*
