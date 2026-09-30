# RentMate
## Product Requirements Document (PRD)

| Document Detail | Information |
|---|---|
| Product Name | RentMate |
| Document | Product Requirements Document |
| Version | 1.0 |
| Status | Draft — Pending Approval |
| Platform | Android Mobile Application |
| Frontend | Flutter and Dart |
| Backend | Firebase |
| Database | Cloud Firestore |

---

## 1. Product Overview

RentMate is a mobile application designed for event equipment rental companies to manage equipment inventory, event bookings, availability, dispatch schedules and returns from a centralized platform.

The application aims to reduce booking conflicts, minimize manual coordination and help employees manage rental operations efficiently.

## 2. Problem Statement

A regional event equipment rental company supplies sound systems, lighting and furniture for weddings and corporate events. Currently, bookings and dispatch schedules are coordinated through individual phone calls.

During peak seasons, the same equipment may be committed to multiple overlapping events. These conflicts are often discovered only when warehouse employees begin loading equipment, resulting in delays, confusion and operational difficulties.

RentMate addresses this problem by providing a centralized mobile application that allows employees to manage bookings, check equipment availability and coordinate dispatch and returns.

## 3. Product Vision

To provide a centralized and reliable mobile platform that helps event equipment rental companies manage their inventory and booking operations while minimizing equipment conflicts.

## 4. Target Users

### 4.1 Administrator (`admin`)
- Manage equipment inventory.
- Manage employee accounts and roles.
- View all bookings and dispatch schedules.
- Monitor rental operations.

### 4.2 Booking Coordinator / Employee (`coordinator`)
- Create and manage event bookings.
- Check equipment availability.
- View booking details.
- Update or cancel authorized bookings.

### 4.3 Warehouse Employee (`warehouse`)
- View upcoming dispatch schedules.
- Verify equipment before dispatch.
- Record dispatched equipment.
- Record returned, damaged or missing equipment.

These roles are aligned with the backend schema role permissions (`admin`, `coordinator`, `warehouse`).

## 5. Product Goals

1. Prevent equipment overbooking.
2. Centralize inventory and booking information.
3. Provide equipment availability before booking confirmation.
4. Simplify dispatch and return management.
5. Reduce manual coordination between booking and warehouse employees.
6. Provide accurate booking and equipment status information.

## 6. Scope of the Product

### 6.1 In Scope (MVP)

- Employee authentication.
- Role-based access.
- Equipment inventory management.
- Equipment availability checking.
- Event booking creation and management.
- Booking conflict prevention.
- Dispatch scheduling and tracking.
- Equipment return management.
- Dashboard with operational summaries.
- Booking status tracking.

### 6.2 Out of Scope (Initial Version)

- Customer-facing online booking.
- Online payment integration.
- AI-based demand forecasting.
- Automated delivery route optimization.
- Multi-warehouse management.
- Customer mobile accounts.

These features may be considered for future releases.

## 7. Functional Requirements

### FR-01: Employee Authentication

- Employees can log in using their registered credentials.
- The application authenticates users through Firebase Authentication.
- Employees can log out securely.
- Access to restricted features depends on assigned roles.

### FR-02: Dashboard

- Display total equipment.
- Display upcoming bookings.
- Display pending dispatches.
- Display pending returns.
- Provide navigation to the main application modules.
- Display relevant operational information.

### FR-03: Equipment Management

- Authorized employees can add equipment.
- Authorized employees can edit equipment details.
- Employees can view equipment inventory.
- Each equipment record contains a name, category, total quantity and condition.
- Equipment that is damaged or under maintenance must not be treated as rentable stock.

### FR-04: Booking Management

- Employees can create an event booking.
- Employees can enter customer details and event information.
- Employees can select rental start and end dates.
- Employees can select equipment and required quantities.
- Employees can view existing bookings.
- Authorized employees can edit or cancel bookings.

### FR-05: Equipment Availability

- The system checks equipment availability for the entire rental period.
- The system considers existing reservations that overlap the requested period.
- The system calculates the available quantity for each equipment type.
- The system prevents confirmation when the requested quantity exceeds available stock.
- Availability must be revalidated during booking confirmation.

### FR-06: Dispatch Management

- Employees can view upcoming dispatches.
- Employees can view the equipment associated with a booking.
- Authorized warehouse employees can record dispatches.
- The application tracks dispatch status and time.

### FR-07: Equipment Returns

- Employees can view pending returns.
- Employees can record returned quantities.
- Employees can report damaged or missing equipment.
- Only physically returned and rentable equipment becomes available again.

### FR-08: Booking Status

The application will support the following statuses:

- Draft / Pending (`draft`)
- Confirmed (`confirmed`)
- Dispatched (`dispatched`)
- Partially Returned (`partially_returned`)
- Returned (`returned`)
- Cancelled (`cancelled`)

Status transitions must follow the agreed booking and dispatch rules.

## 8. Non-functional Requirements

### 8.1 Usability
- The application should have a simple and consistent interface.
- Forms should provide clear validation messages.
- Employees should be able to navigate between the main modules easily.

### 8.2 Performance
- Common screens should load promptly under normal network conditions.
- Database queries should retrieve only the information required by each screen.

### 8.3 Security
- Firebase Authentication must verify employee identities.
- Firestore Security Rules must restrict unauthorized access.
- Role assignments must not be modifiable by ordinary employees.
- Sensitive operations must be authorized.

### 8.4 Reliability
- Booking confirmation must prevent over-reservation.
- Failed operations must provide clear feedback.
- Important inventory changes must be handled consistently.

### 8.5 Maintainability
- The Flutter application should use modular code.
- Business logic and UI code should be separated.
- Shared UI components should be reusable.

## 9. Business Rules

1. The rental start date cannot be after the rental end date.
2. Equipment quantities must be positive integers.
3. Cancelled bookings must not consume reserved inventory.
4. Overlapping reservations must be considered when calculating availability.
5. A booking cannot be confirmed if sufficient equipment is unavailable.
6. Simultaneous booking requests must be handled atomically.
7. Equipment that has been dispatched cannot be treated as available.
8. Damaged or missing equipment must be excluded from rentable inventory as appropriate.
9. A booking can only move between valid statuses.
10. Equipment is released back into rentable stock only after its return is verified.

## 10. User Stories

| ID | User Story |
|---|---|
| US-01 | As an employee, I want to log in so that I can securely access the application. |
| US-02 | As an administrator, I want to manage equipment so that inventory remains accurate. |
| US-03 | As a booking employee, I want to check availability so that I do not overbook equipment. |
| US-04 | As a booking employee, I want to create bookings so that events can reserve equipment. |
| US-05 | As a booking employee, I want to view bookings so that I can track event reservations. |
| US-06 | As a warehouse employee, I want to view dispatch schedules so that I can prepare equipment. |
| US-07 | As a warehouse employee, I want to record dispatches so that equipment movements are tracked. |
| US-08 | As a warehouse employee, I want to record returns so that inventory can be updated accurately. |
| US-09 | As an administrator, I want to view a dashboard so that I can monitor rental operations. |

## 11. Acceptance Criteria

- Employees can log in with valid credentials.
- Invalid credentials produce an appropriate error message.
- Authorized users can manage equipment.
- Employees can create valid bookings.
- The application checks the requested rental period for availability.
- The application rejects bookings that exceed available stock.
- Simultaneous booking requests cannot over-reserve inventory.
- Authorized employees can record dispatches and returns.
- The application displays accurate booking statuses.
- Unauthorized users cannot perform restricted operations.

## 12. Success Criteria

The MVP will be considered functionally complete when:

- All agreed MVP features work.
- Booking conflicts are prevented in tested scenarios.
- Inventory changes are reflected correctly.
- Dispatch and return workflows are functional.
- Authentication and authorization tests pass.
- The application runs on the agreed Android test devices.

## 13. Assumptions and Open Questions

- Is customer booking performed exclusively by employees?
- Does every booking require administrator approval?
- Can equipment be dispatched before the event date?
- How should partial dispatches be handled?
- How should partially returned equipment affect availability?
- Does the company have multiple warehouses?
- Should employees be allowed to edit confirmed bookings?

These questions must be resolved before the final implementation.

## 14. Future Enhancements

- Push notifications.
- Advanced booking search and filters.
- Equipment maintenance scheduling.
- Rental reports and analytics.
- Customer-facing booking portal.
- Multiple warehouse support.
- Online payment integration.

---

**Document Status:** Draft — Pending Mentor Approval