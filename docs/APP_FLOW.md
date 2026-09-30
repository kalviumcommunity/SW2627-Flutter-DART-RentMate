# RentMate

## Application Flow Document

  Document Detail   Information
  ----------------- --------------------------------------------
  Product name      RentMate
  Repository        SW2627-Flutter-DART-RentMate
  Document          Application Flow
  Version           1.1
  Status            Draft --- aligned with supplied UI concept
  Platform          Flutter mobile application

------------------------------------------------------------------------

## 1. Purpose

This document describes the screen navigation and user journeys
represented in the supplied RentMate design. It covers the splash and
login experience, coordinator dashboard, booking list, three-step
booking flow, conflict resolution, inventory and warehouse dispatch
checklist. Returns are included as a required operational follow-on.

## 2. Primary Navigation

The main application uses a bottom navigation bar:

-   **Home:** coordinator dashboard and today's schedule.
-   **Bookings:** booking list, booking details and creation.
-   **Inventory:** equipment stock and availability.
-   **Dispatch:** upcoming dispatches and warehouse checklist.
-   **More:** profile, account options and other authorized functions.

The selected tab should have a clear visual state. Navigation should
preserve a booking draft when the user moves between the three booking
steps.

## 3. Screen Inventory

  ------------------------------------------------------------------------
                    No. Screen           Purpose          Main Actions
  --------------------- ---------------- ---------------- ----------------
                      1 Splash           Show RentMate    Continue to app
                                         identity and     
                                         restore session  

                      2 Login            Authenticate     Sign in, forgot
                                         employee         password

                      3 Dashboard        Summarize daily  View all, new
                        (Coordinator)    operations       booking, check
                                                          availability

                      4 Bookings List    Find and review  Search, filter,
                                         events           open, create

                      5 Create Booking   Capture          Next: Select
                        --- Event        event/customer   Equipment
                        Details          details          

                      6 Select Equipment Choose           Search, filter,
                                         quantities       adjust, next

                      7 Equipment        Explain a        Reduce quantity,
                        Conflict         shortage         change time,
                                                          waitlist

                      8 Booking Review   Verify details   Back, confirm
                                         and estimate     booking

                      9 Inventory        View equipment   Search, filter,
                                         stock            inspect, add if
                                                          authorized

                     10 Dispatch         Track packing    Check items,
                        Checklist        progress         mark as loaded
  ------------------------------------------------------------------------

A return workflow follows dispatch and may be reached through Returns in
the relevant navigation or booking/dispatch details.

## 4. Global Application Flow

``` mermaid
flowchart TD
    A[Launch] --> B{Session valid?}
    B -->|No| C[Login]
    B -->|Yes| D[Dashboard]
    C --> E{Credentials valid?}
    E -->|No| F[Show login error]
    F --> C
    E -->|Yes| D
    D --> G[Home]
    D --> H[Bookings]
    D --> I[Inventory]
    D --> J[Dispatch]
    D --> K[More / Profile]
    H --> L[Booking List]
    L --> M[Create Booking]
    M --> N[Event Details]
    N --> O[Select Equipment]
    O --> P{Available?}
    P -->|No| Q[Conflict]
    Q --> O
    P -->|Yes| R[Review]
    R --> S{Atomic confirmation succeeds?}
    S -->|No| Q
    S -->|Yes| T[Booking Confirmed]
    J --> U[Dispatch Checklist]
    U --> V[Mark Loaded]
    V --> W[Return Workflow]
    W --> X[Inspect and Record Return]
    X --> Y[Reconcile Inventory]
```

## 5. Detailed Screen Flows

### 5.1 Screen 1 --- Splash

**Entry:** app launch.

**Flow:** 1. Display RentMate logo and tagline, "Equipment. Events.
Effortless." 2. Restore/check the authentication session. 3. If a valid
session exists, open the dashboard. 4. Otherwise, open Login.

### 5.2 Screen 2 --- Login

**Fields and controls:** - Email. - Password with visibility toggle. -
Remember me (if session persistence behavior is implemented). - Forgot
password. - Sign In. - Google and Apple options only if those providers
are configured. - Create an account only if employee self-registration
is permitted.

**Flow:** 1. Employee enters credentials. 2. Validate required fields
and email format. 3. Submit credentials to Firebase Authentication. 4.
Show a loading state while authenticating. 5. On success, retrieve
authorized profile/role and open the appropriate landing screen. 6. On
failure, show a readable error and retain safe form input.

### 5.3 Screen 3 --- Dashboard (Coordinator)

**Summary cards:** - Today's Events. - Dispatch Pending. - Conflicts.

**Today's Schedule:** - Event time. - Event name and type. -
Venue/location. - Item count. - Status such as In Progress, Packing,
Ready or Pending, according to the agreed status model.

**Actions:** - View All opens the full schedule or bookings list. - New
Booking opens step 1 of the booking flow. - Check Availability opens an
availability search or booking equipment selection. - Bottom navigation
opens the corresponding module.

### 5.4 Screen 4 --- Bookings List

**Content:** - Search field for events and customers. - Filters: All,
Upcoming, Ongoing and Completed. - Event cards showing event name, event
type, date/time, venue and status. - Floating add button to create a
booking.

**Flow:** 1. Open Bookings. 2. Load authorized bookings. 3.
Search/filter the list. 4. Select a card to open booking details. 5. Use
the add action to begin a new booking.

### 5.5 Screen 5 --- Create Booking: Event Details (Step 1 of 3)

**Fields:** - Event name. - Customer name. - Phone number. - Venue. -
Event date. - Start time. - End time. - Event type: Wedding, Corporate,
Private or Other. - Optional notes.

**Flow:** 1. Open Create Booking. 2. Enter event and customer details.
3. Select date and times. 4. Choose an event type. 5. Validate required
values and time order. 6. Save the data in a booking draft. 7. Select
Next: Select Equipment.

**Validation:** - Required fields cannot be blank. - Phone number must
meet the agreed format. - Start must precede end. - If event date and
rental period differ, capture rental dates separately rather than
assuming they are identical.

### 5.6 Screen 6 --- Select Equipment (Step 2 of 3)

**Content:** - Search equipment. - Category chips: All, Sound, Lighting,
Staging, Seating and any configured categories. - Equipment name and
SKU. - Total and available quantities. - Availability badge. - Quantity
decrement/increment controls. - Selected item count and Next: Review
action.

**Flow:** 1. Load equipment and availability for the draft period. 2.
Search or filter the list. 3. Adjust the requested quantity. 4.
Recalculate or refresh availability when the date/time or quantity
changes. 5. If all requested quantities are feasible, enable Next:
Review. 6. If a shortage is detected, open the conflict state. 7.
Preserve the draft selections when moving backward or forward.

### 5.7 Screen 7 --- Equipment Conflict

**Purpose:** Explain why the current equipment request cannot be
fulfilled.

**Content:** - Clear "Not Enough Available" message. - Equipment name
and SKU. - Requested quantity. - Available quantity. - Shortage
quantity. - Relevant conflicting booking, if permitted. - Resolution
choices.

**Resolution actions:**

**Reduce quantity** 1. Return to equipment selection with the affected
item highlighted. 2. Reduce the requested quantity to a feasible amount.
3. Recheck availability.

**Change event time** 1. Return to the event details step. 2. Select
another date/time. 3. Recheck all selected equipment for the new
interval.

**Join waitlist** 1. Offer only if waitlist behavior is implemented and
approved. 2. Save the waitlist request and show a truthful
acknowledgement. 3. Do not represent a waitlisted request as a confirmed
booking.

### 5.8 Screen 8 --- Booking Review (Step 3 of 3)

**Content:** - Event details. - Customer details. - Rental/event date
and time. - Venue. - Selected equipment and quantities. - Itemized
estimated amounts, when rates are configured. - Total estimated
amount. - Availability verification indicator. - Confirm Booking button.

**Flow:** 1. Display the saved draft. 2. Allow navigation back to edit
details or equipment. 3. On confirmation, send the request to the
trusted reservation operation. 4. Revalidate inventory and reservation
conflicts atomically. 5. If successful, persist the booking and show
confirmation. 6. If stock has changed or the request fails, display the
conflict/error and keep the draft available for correction.

The UI's "Availability verified" label should reflect a successful
check. A previous screen's result alone is not enough to guarantee stock
at confirmation time.

### 5.9 Screen 9 --- Inventory

**Content:** - Search field. - Category chips. - Equipment name and
SKU. - Total quantity and available quantity. - Status badges:
Available, Limited and Out of Stock. - Add action, if the user is
authorized.

**Flow:** 1. Open Inventory. 2. Retrieve equipment records. 3. Search
and filter. 4. Display availability derived from the current reservation
and condition data. 5. Open item details or add/edit equipment if
permitted.

Status thresholds for "Limited" must be agreed and configured rather
than inferred from the visual design.

### 5.10 Screen 10 --- Dispatch Checklist (Warehouse)

**Content:** - Event/booking name. - Packed item count and progress
percentage. - All Items and Packed filters. - Equipment name and
required quantity. - Checkbox for packed items. - Mark as Loaded action.

**Flow:** 1. Open Dispatch and select an upcoming dispatch. 2. Load the
associated booking and required equipment. 3. Verify physical items and
quantities. 4. Mark items or quantities as packed. 5. Update the visible
progress. 6. Enable Mark as Loaded only when mandatory packing checks
pass. 7. Record the loaded status, timestamp and responsible employee.
8. Make the dispatch available to the return workflow.

If partial dispatch is permitted, the system must distinguish partially
loaded from fully loaded rather than marking all equipment as loaded
prematurely.

## 6. Return Flow

Although a dedicated return screen is not shown in the supplied
10-screen design, returns are needed to complete the rental lifecycle.

``` mermaid
flowchart TD
    A[Open Returns or Dispatch Details] --> B[Select Dispatched Booking]
    B --> C[Inspect Equipment]
    C --> D[Enter Returned Quantities]
    D --> E[Record Damage or Missing Items]
    E --> F[Save Return]
    F --> G{Return write succeeds?}
    G -->|No| H[Show error and retain form]
    H --> F
    G -->|Yes| I[Reconcile Inventory]
    I --> J{All items reconciled?}
    J -->|No| K[Partially Returned]
    J -->|Yes| L[Returned]
```

Only verified, rentable returned equipment should increase available
stock. Damaged or missing equipment must be recorded and excluded from
rentable availability as appropriate.

## 7. Navigation and State Rules

-   Keep the bottom navigation consistent across the main modules.
-   Show a clear current-tab indicator.
-   Retain the booking draft across Event Details, Select Equipment,
    Conflict and Review.
-   Warn before discarding unsaved booking changes.
-   Use loading, empty, error and success states for asynchronous
    operations.
-   Avoid duplicate submissions while a booking or dispatch action is in
    progress.
-   Revalidate availability at booking confirmation.
-   Enforce authorization in trusted data operations, not only in
    navigation.

## 8. Key Statuses

  -----------------------------------------------------------------------
  Area                                Proposed statuses
  ----------------------------------- -----------------------------------
  Booking                             Draft, Pending (if approval is
                                      used), Confirmed, Dispatched,
                                      Partially Returned, Returned,
                                      Cancelled

  Equipment                           Available, Limited, Out of Stock,
                                      Unavailable/Maintenance

  Dispatch                            Scheduled, Packing, Loaded,
                                      Cancelled

  Return                              Pending, Partially Returned,
                                      Returned
  -----------------------------------------------------------------------

The display labels may be friendlier than stored status codes. Status
transitions must be explicitly defined and validated.

## 9. Error and Empty States

-   No bookings: show an empty state and a Create Booking action if
    permitted.
-   No equipment matches: show a clear no-results message.
-   Invalid event details: identify the fields requiring correction.
-   Insufficient stock: show the exact requested, available and shortage
    quantities.
-   Confirmation conflict: keep the draft and ask the employee to revise
    it.
-   Network failure: do not claim that an operation succeeded.
-   Incomplete dispatch checklist: explain what remains before loading.
-   Failed return: preserve entered values where possible and allow
    retry.

## 10. End-to-End Journey

1.  Employee opens RentMate and signs in.
2.  Coordinator reviews today's schedule and operational summaries.
3.  Coordinator opens Bookings and starts a new booking.
4.  Coordinator enters event and customer details.
5.  Coordinator selects equipment and quantities.
6.  RentMate checks availability and presents a conflict if necessary.
7.  Coordinator resolves any shortage and reviews the booking.
8.  RentMate revalidates and confirms the reservation.
9.  Warehouse staff use the dispatch checklist to pack and load
    equipment.
10. Staff record returns, damage and missing items.
11. Inventory and booking states are reconciled.

------------------------------------------------------------------------

**Document Status:** Draft --- aligned with supplied design; validate
business rules and permissions before implementation.
