# RentFlow Codebase Audit: Comprehensive Bug & Debt Register

> **Audit Date:** October 2026  
> **Repository:** `kalviumcommunity/SW2627-Flutter-DART-RentMate`  
> **Scope:** Full repository audit across all screens, services, routing, models, assets, build scripts, and configuration.  
> **Total Issues Identified:** 35 issues across 5 core categories.

---

## Executive Summary Matrix

| Category | Critical | High | Medium | Low / Debt | Total |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **1. Functional & Navigation Bugs** | 3 | 5 | 5 | 2 | **15** |
| **2. UI / UX Glitches & Layout Defects** | 0 | 4 | 5 | 1 | **10** |
| **3. Data Duplications & Inconsistencies** | 0 | 2 | 2 | 0 | **4** |
| **4. Architecture, Auth & Security** | 1 | 2 | 1 | 0 | **4** |
| **5. Repository Hygiene & Platform Debt** | 0 | 0 | 2 | 0 | **2** |
| **Total** | **4** | **13** | **15** | **3** | **35** |

---

## 1. Functional & Navigation Bugs

### BUG-01: Broken Bottom Navigation for `Dispatch` (Index 3) & `More` (Index 4)
- **Severity:** Critical
- **Location:** `lib/screens/dashboard/dashboard_screen.dart:43-83`
- **Root Cause:** The `build()` method uses a ternary checking only `_currentNavIndex == 1` (`BookingsListScreen`) and `_currentNavIndex == 2` (`InventoryScreen`). If `_currentNavIndex` is set to 3 or 4, it falls through to index 0 (`Overview`).
- **Symptom:** Tapping "Dispatch" or "More" highlights the bottom navigation icon, but the page content remains on the Overview dashboard.
- **Fix:** Either implement dedicated views for Dispatch and More or render appropriate placeholder cards with informative status messaging instead of silently displaying Overview.

### BUG-02: "Dispatch" Quick Command Chip Misrouted to Bookings List
- **Severity:** High
- **Location:** `lib/screens/dashboard/dashboard_screen.dart:643-648`
- **Root Cause:** The `Dispatch` quick command chip callback is hardcoded to `setState(() => _currentNavIndex = 1);`. Index 1 is `BookingsListScreen`, not Dispatch.
- **Symptom:** Tapping the Dispatch quick command opens the Bookings list view instead of the dispatch queue or a dispatch filter.
- **Fix:** Wire `Dispatch` to filter active dispatches (e.g., passing a tab/filter state) or to index 3 when a Dispatch screen is added.

### BUG-03: "Availability" Quick Command Chip Opens Booking Creation Wizard
- **Severity:** Medium
- **Location:** `lib/screens/dashboard/dashboard_screen.dart:650-660`
- **Root Cause:** The `Availability` quick command chip pushes `CreateBookingScreen` via `MaterialPageRoute` instead of displaying fleet availability or an equipment calendar.
- **Symptom:** User clicking "Availability" expects an inventory calendar or conflict view, but is dropped into the 3-step Create Booking wizard.
- **Fix:** Navigate to `InventoryScreen` with an availability filter or a dedicated availability calendar view.

### BUG-04: Non-Web Google OAuth Fails Silently on Mobile / Desktop
- **Severity:** High
- **Location:** `lib/core/services/auth_service.dart:51-53, 95-97`
- **Root Cause:** `redirectToGoogleSignIn()` and `checkOAuthRedirect()` immediately return `null` or do nothing when `!kIsWeb`.
- **Symptom:** On Android/iOS emulator or device, clicking "Continue with Google Workspace" spins or does nothing with zero user feedback.
- **Fix:** Provide mobile OAuth integration (via `google_sign_in` plugin already in `pubspec.yaml`) or show an explanatory feedback dialog when running on non-web platforms.

### BUG-05: Fake Apple ID Authentication Masquerade
- **Severity:** High
- **Location:** `lib/screens/login/login_screen.dart:311-319`, `lib/screens/signup/signup_screen.dart:420-428`
- **Root Cause:** "Continue with Apple ID" / "Sign up with Apple ID" buttons invoke `_handleSignIn` / `_handleSignUp`, bypassing any Apple Sign-In provider and authenticating whatever text is in the email controller.
- **Symptom:** Deceptive authentication flow that passes dummy email without contacting Apple ID services or checking credentials.
- **Fix:** Integrate `sign_in_with_apple` or clearly label as prototype/mock with a dialog informing the user that Apple ID integration is pending.

### BUG-06: Form Validation Completely Bypassed in `SignUpScreen`
- **Severity:** Critical
- **Location:** `lib/screens/signup/signup_screen.dart:66, 181-332`
- **Root Cause:** None of the `RentFlowTextField` widgets inside `SignUpScreen` define `validator` functions. `_formKey.currentState?.validate() ?? true` evaluates to `true` unconditionally.
- **Symptom:** User can click "Create Account" with completely empty Full Name, Email, Password, and Confirm Password fields and is navigated directly into the dashboard.
- **Fix:** Add non-empty string and email regex validators to `RentFlowTextField` instances.

### BUG-07: Passwords Never Validated for Match on Registration
- **Severity:** High
- **Location:** `lib/screens/signup/signup_screen.dart:55-84`
- **Root Cause:** `_passwordController.text` and `_confirmPasswordController.text` are never compared before navigating to the dashboard.
- **Symptom:** User can type "password123" and "differentpass" and registration succeeds without warning.
- **Fix:** Add confirmation check `if (_passwordController.text != _confirmPasswordController.text)` with appropriate error banner/validation text.

### BUG-08: Zero-Item & Blank Booking Submission Allowed in `CreateBookingScreen`
- **Severity:** High
- **Location:** `lib/screens/bookings/create_booking_screen.dart:1155-1165`
- **Root Cause:** `onPressed` on Step 1 and Step 2 advances to Step 3 without checking if required text fields are populated or if `_totalSelectedItems > 0`.
- **Symptom:** A coordinator can confirm an empty booking with 0 equipment items, blank client name, and blank venue.
- **Fix:** Disable or validate the "Next" action on Step 1 (required fields) and Step 2 (`_totalSelectedItems > 0`).

### BUG-09: Single-Day Rental Calculation Bug (Multi-Day Duration Ignored)
- **Severity:** Critical
- **Location:** `lib/screens/bookings/create_booking_screen.dart:155-160`
- **Root Cause:** `_totalDailyRental` is computed as `sum(selectedQty * dailyRate)`. The rental duration `_endDate.difference(_startDate).inDays` is completely omitted from the formula.
- **Symptom:** A 14-day event booking charges the exact same price as a 1-day event booking.
- **Fix:** Multiply base daily rental by `math.max(1, _endDate.difference(_startDate).inDays)`.

### BUG-10: Locked & Non-Interactive Time Pickers in `CreateBookingScreen`
- **Severity:** Medium
- **Location:** `lib/screens/bookings/create_booking_screen.dart:426-452`
- **Root Cause:** The `_buildDateTimePickerTile` onTap callback only opens `showDatePicker()`. Neither `_dispatchTime` nor `_returnTime` can be edited by the user.
- **Symptom:** Dispatch time (10:00) and Return time (23:30) are permanently frozen.
- **Fix:** Add a time picker dialog trigger (`showTimePicker`) when tapping the time row or add separate date and time pickers.

### BUG-11: Hardcoded Reservation ID (`#BK-8942`) in Confirmation & Manifest
- **Severity:** Low
- **Location:** `lib/screens/bookings/create_booking_screen.dart:1202`, `lib/screens/bookings/booking_details_screen.dart:288`
- **Root Cause:** The booking ID string is hardcoded as `#BK-8942` in `_showBookingSuccessDialog` and the dispatch SnackBar.
- **Symptom:** Every new booking claims to be reservation `#BK-8942`, and checking dispatch for any booking shows a SnackBar for `#BK-8942`.
- **Fix:** Interpolate the dynamic `bookingId` or generate a random sequential ID (e.g. `BK-${DateTime.now().millisecondsSinceEpoch % 10000}`).

### BUG-12: Newly Created Bookings are Discarded (Ephemeral Dummy State)
- **Severity:** Medium
- **Location:** `lib/screens/bookings/create_booking_screen.dart:1237-1244`
- **Root Cause:** On booking confirmation, `_showBookingSuccessDialog` simply calls `Navigator.pop(context)` twice. No state store, singleton service, or local DB saves the record.
- **Symptom:** After creating a booking, navigating to the Bookings List shows the original static 5 mock items with the newly created booking missing.
- **Fix:** Introduce a simple shared repository or notifier (`BookingRepository` / `ValueNotifier<List<BookingItem>>`) so created bookings persist during the session.

### BUG-13: Sign Out Does Not Invalidate Auth Session
- **Severity:** Medium
- **Location:** `lib/screens/dashboard/dashboard_screen.dart:141-143`
- **Root Cause:** Tapping the logout button executes `Navigator.of(context).pushReplacementNamed(AppRoutes.login)` without calling `AuthService().signOut()`.
- **Symptom:** `AuthService._currentUser` remains set in memory; navigating back to dashboard or checking auth state still treats the user as logged in.
- **Fix:** Call `AuthService().signOut()` before navigating to `AppRoutes.login`.

### BUG-14: Unhandled Crash on Unsupported Firebase Platforms (Linux / Unconfigured)
- **Severity:** Critical
- **Location:** `lib/main.dart:18-20`, `lib/firebase_options.dart:31-39`
- **Root Cause:** `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` has no exception handling. `DefaultFirebaseOptions.currentPlatform` throws `UnsupportedError` on Linux and unknown platforms.
- **Symptom:** App crashes immediately on launch on Linux or desktop environments without a user-visible fallback.
- **Fix:** Wrap `Firebase.initializeApp` in a `try/catch` block and log warnings gracefully on unsupported platforms.

### BUG-15: Missing iOS and macOS Firebase Plist Configuration
- **Severity:** High
- **Location:** `ios/Runner/GoogleService-Info.plist` (missing), `macos/Runner/GoogleService-Info.plist` (missing)
- **Root Cause:** `firebase_options.dart` configures iOS/macOS options, but the required native plist files were never placed in the respective Runner directories.
- **Symptom:** Building or running on iOS / macOS native targets will fail during Firebase initialization.
- **Fix:** Run `flutterfire configure` or provide the stub/production `GoogleService-Info.plist` files.

---

## 2. UI / UX Glitches & Layout Defects

### GLITCH-01: Nested Scaffolds and Double AppBars in Dashboard
- **Severity:** High
- **Location:** `lib/screens/dashboard/dashboard_screen.dart:43-52`, `lib/screens/bookings/bookings_list_screen.dart:125-146`, `lib/screens/inventory/inventory_screen.dart:183-186`
- **Root Cause:** `DashboardScreen` is already wrapped in a `Scaffold` (providing the bottom navigation bar). When navigating to tab 1 or tab 2, `BookingsListScreen` and `InventoryScreen` return their own internal `Scaffold` with their own `AppBar`s.
- **Symptom:** Nested scaffolds produce redundant inset calculations, unpredictable keyboard avoidance behavior, and awkward top-bar layering.
- **Fix:** Accept an `isEmbedded` parameter in `BookingsListScreen` (matching `InventoryScreen`) and omit the inner Scaffold/AppBar when embedded.

### GLITCH-02: Hardcoded Filter Chip Counts in `BookingsListScreen`
- **Severity:** Medium
- **Location:** `lib/screens/bookings/bookings_list_screen.dart:185-189`
- **Root Cause:** The filter chips pass hardcoded integer literals:
  ```dart
  _buildFilterChip('All', _bookings.length),
  _buildFilterChip('Upcoming', 4),
  _buildFilterChip('Ongoing', 0),
  _buildFilterChip('Completed', 1),
  ```
- **Symptom:** If the underlying booking list is modified or filtered, the chip numbers remain permanently 4, 0, 1.
- **Fix:** Compute counts dynamically: `_bookings.where((b) => b.status == ...).length`.

### GLITCH-03: Dead Filter Button in `BookingsListScreen` AppBar [RESOLVED]
- **Severity:** Low
- **Status:** Resolved
- **Location:** `lib/screens/bookings/bookings_list_screen.dart`
- **Root Cause:** The action button had an empty callback: `IconButton(icon: const Icon(Icons.filter_list_rounded), onPressed: () {})`.
- **Symptom:** Tapping the filter icon in the top right did nothing.
- **Fix:** Added `_showFilterBottomSheet(BuildContext context)` allowing interactive status filtering (All, Upcoming, Ongoing, Completed) with visual selection indicators.

### GLITCH-04: Static Hardcoded Date in Dashboard Header
- **Severity:** Medium
- **Location:** `lib/screens/dashboard/dashboard_screen.dart:121`
- **Root Cause:** Header string contains static text `'Operations Cockpit • Squad 124 • Mon, 30 Sep'`.
- **Symptom:** App shows Monday, 30 Sep regardless of the actual date.
- **Fix:** Use formatted `DateTime.now()` (e.g. `intl` package or a lightweight date helper).

### GLITCH-05: Hardcoded Wedding Manifest Rendered for All Bookings in `BookingDetailsScreen`
- **Severity:** High
- **Location:** `lib/screens/bookings/booking_details_screen.dart:114, 224-228`
- **Root Cause:** `_buildManifestItem()` is called 5 times with hardcoded wedding equipment (JBL, Sharpy, P3.91 LED, Box Truss, Shure mic) regardless of event type or passed parameters. Category badge is hardcoded to `'WEDDING RECEPTION'`.
- **Symptom:** Opening a Corporate conference or Fashion Gala still shows the same 5 wedding items with a "WEDDING RECEPTION" tag.
- **Fix:** Accept an optional item list `List<EquipmentItem>? items` or select manifest items matching the event's category/id.

### GLITCH-06: Hardcoded Status Timeline Tracker in `BookingDetailsScreen`
- **Severity:** Medium
- **Location:** `lib/screens/bookings/booking_details_screen.dart:347-357`
- **Root Cause:** Steps are hardcoded:
  ```dart
  _buildTimelineStep('Confirmed', true, true),
  _buildTimelineLine(true),
  _buildTimelineStep('Packing', true, true),
  _buildTimelineLine(true),
  _buildTimelineStep('Ready', true, true),
  _buildTimelineLine(false),
  _buildTimelineStep('Dispatched', false, false),
  ```
- **Symptom:** Even if the booking status is `CONFIRMED` (initial state) or `COMPLETED`, the timeline always claims Packing and Ready are done and Dispatched is pending.
- **Fix:** Dynamically determine step completion by comparing against the current `status` enum/string.

### GLITCH-07: Dummy "Remember Me" Checkbox on `LoginScreen`
- **Severity:** Medium
- **Location:** `lib/screens/login/login_screen.dart:203-214`
- **Root Cause:** `_rememberMe` toggles a local state variable that is never persisted to disk or `SharedPreferences`.
- **Symptom:** Checking "Remember me" has zero effect; reloading the app resets the checkbox.
- **Fix:** Persist boolean preference using `shared_preferences` or remove the checkbox if not yet supported.

### GLITCH-08: Dummy "Forgot Password" Action on `LoginScreen`
- **Severity:** Low
- **Location:** `lib/screens/login/login_screen.dart:228-236`
- **Root Cause:** Tapping "Forgot password?" only displays a generic SnackBar without validating the email or sending a reset request.
- **Symptom:** User receives a notification that a reset link will be sent to the administrator, but nothing actually happens.
- **Fix:** Hook up to Firebase Auth's `sendPasswordResetEmail` or provide a proper modal explaining the admin escalation path.

### GLITCH-09: Non-Functional Scanner & Intake Actions in `InventoryScreen`
- **Severity:** Medium
- **Location:** `lib/screens/inventory/inventory_screen.dart:368-374, 905-950`
- **Root Cause:** "Scan Flight Case", "SCAN", and "ADD EQUIPMENT" only display snackbars (`Camera barcode scanner launched`, `New Asset Intake dialog opened`).
- **Symptom:** The core actions in the sticky bottom dock are dummy placeholders with no input dialog or camera feed.
- **Fix:** Provide a modal bottom sheet for adding equipment or disable/hide buttons with a "Coming Soon" chip.

### GLITCH-10: Hardcoded Shortage Event in `BookingConflictSheet`
- **Severity:** Medium
- **Location:** `lib/screens/bookings/booking_conflict_sheet.dart:28, 40`
- **Root Cause:** `conflictingEvent` defaults to `'Apex Tech Annual Summit (BK-4091)'` whenever omitted.
- **Symptom:** Any equipment shortage across any category (microphones, trusses, power generators) claims to conflict with Apex Tech Annual Summit.
- **Fix:** Make `conflictingEvent` required or display a generic shortage message when no specific colliding booking is provided.

---

## 3. Data Duplications & Inconsistencies

### DUP-01: Three Conflicting Equipment Category Taxonomies
- **Severity:** High
- **Locations:**
  1. `lib/core/constants/app_constants.dart:31-35`: `['Sound Systems', 'Stage Lighting', 'Event Furniture']`
  2. `lib/screens/inventory/inventory_screen.dart:34-41`: `['All', 'Lighting', 'Audio', 'Video & LED', 'Rigging', 'Power & Control']`
  3. `lib/screens/bookings/create_booking_screen.dart:559`: `['All', 'Sound', 'Lighting', 'Visuals', 'Staging', 'Power']`
- **Root Cause:** Three separate files defined their own category lists without a shared domain enum or constant.
- **Symptom:** Filtering in Inventory does not match the categories in Booking Creation, and neither matches `AppConstants`.
- **Fix:** Consolidate all categories into a single enum or constant list in `lib/core/constants/app_constants.dart` and reference it everywhere.

### DUP-02: Massive Mathematical Discrepancy Between Inventory Cards and Roster
- **Severity:** High
- **Location:** `lib/screens/inventory/inventory_screen.dart:43-134, 420-456`
- **Root Cause:** The top metric cards hardcode numbers (`Total: 148, On Stage: 94, Available: 46, Service: 08`), but the actual equipment roster in the same file has:
  - Total items: 128
  - Deployed: 39
  - Available: 88
  - Maintenance: 1
- **Symptom:** Summing the cards gives 148, but scrolling through the list reveals completely different totals. Filtering categories also leaves the 148 card unchanged.
- **Fix:** Calculate the card totals dynamically from `_inventoryItems`:
  ```dart
  int get totalAssets => _inventoryItems.fold(0, (sum, i) => sum + (i['total'] as int));
  ```

### DUP-03: Duplicated Equipment Models Across Screens
- **Severity:** Medium
- **Locations:**
  - `lib/screens/inventory/inventory_screen.dart`: uses untyped `Map<String, dynamic>`
  - `lib/screens/bookings/create_booking_screen.dart`: uses `class EquipmentCatalogItem`
  - `lib/screens/bookings/booking_details_screen.dart`: uses raw method arguments
- **Root Cause:** Lack of a shared `EquipmentItem` domain model in `lib/core/models/`.
- **Symptom:** SKUs, equipment names, and daily rates are re-declared in multiple files with slight differences (e.g. `AU-K2-LARR` in inventory vs `SND-JBL-VRX932` in booking).
- **Fix:** Create `lib/core/models/equipment_item.dart` and share it across Inventory, Booking Wizard, and Booking Details.

### DUP-04: Manifest Sum vs Grand Total Mismatch in `BookingDetailsScreen`
- **Severity:** Medium
- **Location:** `lib/screens/bookings/booking_details_screen.dart:224-228, 270`
- **Root Cause:** The 5 hardcoded items total: `(4 * 1500) + (6 * 850) + (8 * 1200) + (4 * 600) + (2 * 950) = ₹25,000`. The default grand total shown right below it is `₹48,500`.
- **Symptom:** Obvious mathematical discrepancy on the screen between itemized manifest sum and total estimate.
- **Fix:** Compute the manifest total directly from item rates and display fees (logistics/deposit) transparently.

---

## 4. Architecture, Auth & Security

### SEC-01: Hardcoded Google OAuth Web Client ID in Source
- **Severity:** Medium
- **Location:** `lib/core/services/auth_service.dart:41-44`
- **Root Cause:** A Google Client ID is hardcoded as a fallback string:
  ```dart
  static const String activeClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '656620374032-2eq1mrnteosmb4gukgl90cp4pmpq73vu.apps.googleusercontent.com',
  );
  ```
- **Symptom:** OAuth client credentials are baked into public repository source control.
- **Fix:** Require passing via `--dart-define=GOOGLE_WEB_CLIENT_ID=...` or load from a non-committed environment configuration.

### SEC-02: Deprecated `dart:html` Import Incompatible with Modern WebAssembly (WASM)
- **Severity:** High
- **Location:** `lib/core/services/web_auth_web.dart:2`
- **Root Cause:** `import 'dart:html' as html;` is used for window navigation and history state replacement.
- **Symptom:** `dart:html` is deprecated in Dart 3 and prevents compilation when targeting Flutter WebAssembly (`flutter build web --wasm`).
- **Fix:** Migrate to `package:web` (`import 'package:web/web.dart' as web;`) for future-proof web platform interoperability.

### ARCH-01: Unused Heavy Dependencies in `pubspec.yaml`
- **Severity:** High
- **Location:** `pubspec.yaml:39-41`
- **Root Cause:** `firebase_auth: ^6.7.0`, `firebase_storage: ^13.6.0`, and `google_sign_in: ^6.2.2` are added to dependencies, but not a single file in `lib/` imports them.
- **Symptom:** Increases APK/IPA bundle size, slows down Gradle/CocoaPods build times, and pulls in unused native background services.
- **Fix:** Either implement real authentication/storage using these SDKs or remove them until ready to integrate.

### ARCH-02: Bypassed Centralized Named Routing
- **Severity:** Medium
- **Location:** `lib/core/routes/app_routes.dart:23-31`, `lib/screens/dashboard/dashboard_screen.dart:627-630`
- **Root Cause:** `AppRoutes` registers routes (`/booking-details`, `/create-booking`), but screens bypass them by pushing raw `MaterialPageRoute(builder: (context) => const CreateBookingScreen())`.
- **Symptom:** Breaks deep linking, makes argument passing non-standard, and causes named route definitions to bitrot.
- **Fix:** Use `Navigator.pushNamed(context, AppRoutes.createBooking)` and pass arguments through `settings.arguments`.

---

## 5. Repository Hygiene & Platform Debt

### HYG-01: Tracked Root Scratch File `scratch_server.js`
- **Severity:** Medium
- **Location:** `scratch_server.js` (at repo root)
- **Root Cause:** A raw Node.js script used for local static serving was committed directly to the git root without documentation or gitignoring.
- **Symptom:** Repository clutter, unneeded non-Flutter artifacts in project root.
- **Fix:** Delete from git tracking and add `scratch_server*.js` to `.gitignore`.

### HYG-02: Tracked Platform Generated Registrant Files Creating Continuous Merge Conflicts
- **Severity:** Medium
- **Location:** `macos/Flutter/GeneratedPluginRegistrant.swift`, `windows/flutter/generated_plugin_registrant.cc`, `windows/flutter/generated_plugins.cmake`
- **Root Cause:** Machine-generated platform registrants were committed to git instead of being regenerated locally by Flutter tools.
- **Symptom:** Every `git pull`, merge, or plugin upgrade produces dirty working tree files and merge conflicts.
- **Fix:** Add them to `.gitignore` or clean working directory using `git checkout -- <file>`.

---

## Recommended Action Plan (Senior Dev Priority)

1. **Phase 1: Fix Core Functional Bugs (Immediate)**
   - Fix navigation fallback in `DashboardScreen` so Dispatch and More tabs don't redirect to Overview (BUG-01, BUG-02, BUG-03).
   - Fix multi-day rental duration calculation in `CreateBookingScreen` (BUG-09).
   - Add input and password-match validation in `SignUpScreen` (BUG-06, BUG-07).
   - Prevent zero-item booking confirmation (BUG-08).

2. **Phase 2: Fix Data Inconsistencies & Duplications**
   - Unify equipment categories into `AppConstants` (DUP-01).
   - Connect `InventoryScreen` top metric cards to the actual roster items (DUP-02).
   - Create a shared `EquipmentItem` model (DUP-03).

3. **Phase 3: Clean Up Scaffolds & Repository**
   - Eliminate nested Scaffold in `BookingsListScreen` and `InventoryScreen` (GLITCH-01).
   - Remove unused dependencies (`firebase_storage`, etc.) or connect them to real services (ARCH-01).
   - Delete `scratch_server.js` from git tracking (HYG-01).
