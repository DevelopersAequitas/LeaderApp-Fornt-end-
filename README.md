# Peers Unity — Leader App (Frontend)

> **Confidential & Proprietary** — Internal Developer Onboarding & Architecture Documentation.  
> **Package ID / Application ID:** `com.unity.leadersapp`  
> **Primary Domain:** `https://peersglobal.com`  
> **Tech Stack:** Flutter 3.x, Dart 3.x, MVP Architecture, BLoC State Management, Material Design 3 (MD3), Shorebird OTA Code-Push.

---

## 📑 Table of Contents
1. [Overview & Role Hierarchy](#1-overview--role-hierarchy)
2. [Architecture Overview (MVP + BLoC)](#2-architecture-overview-mvp--bloc)
3. [Project Directory Structure](#3-project-directory-structure)
4. [Core Features & Modules](#4-core-features--modules)
5. [Getting Started & Local Setup](#5-getting-started--local-setup)
6. [API Architecture & Dynamic Capabilities](#6-api-architecture--dynamic-capabilities)
7. [App Lifecycle, Updates & Maintenance Gate](#7-app-lifecycle-updates--maintenance-gate)
8. [OTA Code-Push (Shorebird)](#8-ota-code-push-shorebird)
9. [Developer Guidelines & Coding Constraints](#9-developer-guidelines--coding-constraints)

---

## 1. Overview & Role Hierarchy

**Peers Unity Leader App** is an executive operations and analytics platform tailored for leaders across circles, districts, industries, and central administration.

The application dynamically adapts navigation tabs, dashboards, action buttons, and analytical scopes based on the authenticated leader's active role:

| Leadership Role | Code Identifier | Description & Scope |
| :--- | :--- | :--- |
| **Super Admin** | `superAdmin` | Central administrative access; role matrix management, global circulars, and system overrides. |
| **Country Director** | `countryDirector` | National oversight; regional analytics, directorate circulars, and financial tracking. |
| **District Executive Director** | `districtExecDirector` | District-wide operations, circle reviews, and leadership coordination. |
| **Industry Director** | `industryDirector` | Industry vertical governance and cross-circle classifications. |
| **Circle Director** | `circleDirector` | Single circle executive oversight, attendance audits, and growth metrics. |
| **Circle Founder** | `circleFounder` | Founding leadership, peer onboarding, and circle development. |
| **Circle Chair (Business Growth)** | `chairBusinessGrowth` | Business deals tracking, peer referral exchange, and 1-on-1 P2P meetings. |
| **Circle Chair (Peer Experience)** | `chairPeerExperience` | Peer engagement, milestone celebrations, and onboarding satisfaction. |
| **Circle Chair (Operations & Tech)** | `chairOperationsTech` | Meeting coordination, attendance logging, and technology enablement. |

---

## 2. Architecture Overview (MVP + BLoC)

The codebase strictly enforces **MVP (Model-View-Presenter)** decoupled with **BLoC (Business Logic Component)** state management:

```text
┌──────────────┐          ┌────────────────┐          ┌───────────────────┐
│     View     │ ◄──────► │   Presenter    │ ◄──────► │       BLoC        │
│ (Flutter UI) │          │ (UI Mediator)  │          │ (State & Events)  │
└──────────────┘          └────────────────┘          └─────────┬─────────┘
                                                                │
                                                      ┌─────────▼─────────┐
                                                      │    Repository     │
                                                      └─────────┬─────────┘
                                                                │
                                                      ┌─────────▼─────────┐
                                                      │ Remote Datasource │
                                                      │   (ApiClient)     │
                                                      └───────────────────┘
```

* **Model (`model/`)**: Plain Data Transfer Objects (DTOs) with immutable JSON serialization. Free from presentation state.
* **View (`view/`)**: Pure UI rendering (MD3). Listens to BLoC states via `BlocBuilder` / `BlocListener` and delegates user interactions. Contains **zero direct business logic**.
* **Presenter (`presenter/`)**: Implements feature contract interfaces, coordinating actions between the View and BLoC.
* **BLoC (`bloc/`)**: Manages events and produces immutable state transitions using `flutter_bloc`.

---

## 3. Project Directory Structure

```text
lib/
├── app.dart                   # Global MaterialApp, MD3 theme setup, and route observer
├── main.dart                  # Application initialization (Storage, Services, Startup)
│
├── core/                      # Shared global infrastructure
│   ├── constants/             # API endpoints, assets, storage keys, style tokens
│   ├── enums/                 # User roles, transaction statuses, meeting types
│   ├── helpers/               # SessionManager, TokenStorage, Currency & Date formatters
│   ├── models/                # Shared cross-feature models (AppConfig, Permissions)
│   ├── network/               # Dio ApiClient, interceptors, error translation
│   ├── routes/                # Centralized route definitions (AppRoutes)
│   ├── services/              # AppConfigService, Native In-App Updates, Audio/Video helpers
│   ├── storage/               # Encrypted SharedPreferences & Hive cache engines
│   ├── theme/                 # AppColors, Typography, MD3 ColorScheme
│   └── widgets/               # Reusable atomic UI components (CustomAppBar, Buttons, Avatars)
│
├── data/                      # Centralized Data & API Communication Layer
│   └── datasources/
│       ├── local/             # Offline cache storage
│       └── remote/            # HTTP endpoints (Peers, Teams, Finance, Reports, Matrix)
│
└── features/                  # Independent functional modules (MVP + BLoC)
    ├── auth/                  # Phone OTP Authentication & Session onboarding
    ├── circulars/             # Role-targeted notices & broadcast publishing
    ├── dashboard/             # Executive analytics, metrics & top impact leaders
    ├── finance/               # Dues ledger, offline payment receipt recording
    ├── maintenance/           # System maintenance mode & admin bypass gate
    ├── peer_profile/          # Peer details, privacy masking, P2P logs & intro video player
    ├── peers/                 # Peer roster, celebrations (birthdays/anniversaries)
    ├── profile/               # Active leader account, dynamic capabilities & sign out
    ├── reports/               # Attendance audits, trend graphs, PDF/Excel export
    ├── role_management/       # Super Admin dynamic role-capability matrix control
    ├── splash/                # Startup animations & version/maintenance check
    └── teams/                 # Circles directory, sub-industries & classifications
```

---

## 4. Core Features & Modules

### 📊 1. Executive Dashboard (`features/dashboard`)
* Real-time metrics: Active Peers, P2P Meetings, Closed Deals Value, and Coins Distributed.
* Dynamic timeframe filters: `this_week`, `this_month`, `last_month`, `ytd`, `all_time`.
* Leaderboard showcasing Top Impacters.

### 👥 2. Peers & Celebrations (`features/peers` & `features/peer_profile`)
* Verified peer roster with search, filter, and circle sorting.
* Peer detail profile with privacy-first contact masking (`hide_phone`, `hide_email`).
* Built-in HLS/MP4 **Video Player** for peer introduction videos.
* 1-on-1 P2P Meeting logger with date and discussion notes.
* Peer celebrations bar for milestone and birthday wishes.

### 🏛️ 3. Teams & Circles (`features/teams` & `features/circle_details`)
* Circle health diagnostics and meeting schedule tracker.
* Deep-dive circle details with peer groupings by sub-industries.

### 📢 4. Role-Targeted Circulars (`features/circulars`)
* Live broadcast feed filtered automatically by the backend based on the active role.
* Direct publishing modal for Super Admins and Directorate executives (`POST /api/v1/circulars/publish`).

### 💼 5. Financial Analytics & Ledger (`features/finance`)
* Circle fee collections, revenue summaries, and outstanding dues.
* Offline fee payment entry supporting Cash, UPI, Cheque, and Bank Transfers.

### 📈 6. Reports & Analytics (`features/reports`)
* Attendance rate charts and weekly performance audits.
* Export engine producing downloadable PDF / Excel summary reports.

### 🔐 7. Role & Capabilities Matrix (`features/role_management`)
* Interactive dynamic matrix for Super Admins to toggle capabilities per role in real time.
* Custom role creation and instant permission synchronization.

---

## 5. Getting Started & Local Setup

### Prerequisites
* **Flutter SDK**: `3.27.x` or higher (Channel stable)
* **Dart SDK**: `3.6.x` or higher
* **Java Development Kit (JDK)**: 17
* **Android Studio / Xcode** for platform-specific builds

### Clone & Installation
```bash
# 1. Clone the repository
git clone git@github.com:DevelopersAequitas/LeaderApp-Fornt-end-.git
cd LeaderApp-Fornt-end-

# 2. Install dependencies
flutter pub get

# 3. Verify static code analysis
dart analyze lib/

# 4. Run on a connected device / emulator
flutter run
```

---

## 6. API Architecture & Dynamic Capabilities

### API Base URLs
* **Production**: `https://peersglobal.com/api/v1`
* **Development**: `https://dev.peersunity.com/api/v1`
* **Localhost**: `http://127.0.0.1:8000/api/v1`

### Dynamic Capability Guard
Do not hardcode role strings inside UI buttons. Use `SessionManager().permissions` or the dynamic capability checker:

```dart
// Check specific permission grant
if (SessionManager().permissions.canAccessFinanceTab) {
  // Show Finance Module
}

if (SessionManager().permissions.canAddEditPeer) {
  // Show Edit Peer Profile button
}
```

---

## 7. App Lifecycle, Updates & Maintenance Gate

On application launch ([SplashView](file:///d:/office%20project/LeaderApp-Fornt-end-/lib/features/splash/view/splash_view.dart)), the app calls `GET /api/v1/system/app-config`:

1. **Maintenance Mode (`is_maintenance_mode: true`)**:
   - Redirects to [MaintenanceView](file:///d:/office%20project/LeaderApp-Fornt-end-/lib/features/maintenance/view/maintenance_view.dart).
   - Super Admins and roles in `allowed_bypass_roles` can bypass the maintenance gate.
2. **Force Update (`current_app_version < min_required_version`)**:
   - Android: Triggers native Google Play `InAppUpdate.performImmediateUpdate()`.
   - iOS: Launches the App Store page.
3. **Optional Update (`current_app_version < latest_version`)**:
   - Android: Initiates background `InAppUpdate.startFlexibleUpdate()`.

---

## 8. OTA Code-Push (Shorebird)

This project is configured with **Shorebird** for over-the-air (OTA) updates without waiting for app store review:

```bash
# Check Shorebird status
shorebird doctor

# Build a new release for Android (Google Play AAB)
shorebird release android

# Build a new release for iOS
shorebird release ios-framework-alpha

# Push a live patch (OTA fix) to users immediately
shorebird patch android
shorebird patch ios
```

---

## 9. Developer Guidelines & Coding Constraints

### ⚠️ Critical Vocabulary Rule
> **STRICT TERMINOLOGY CONSTRAINT:**  
> Never use the words **`member` / `members`** or **`network` / `networking`** anywhere in user-facing UI, documentation, strings, or logs.  
> * Use **Peer / Peers / Leaders / Circle Participants / Executives** instead of member(s).  
> * Use **Circle Ecosystem / Collaboration / Community / P2P Connections** instead of network(ing).

### 🎨 Material Design 3 (MD3) Standards
* Follow soft, rounded MD3 card layouts (`BorderRadius.circular(16)` or `24`).
* Avatars must always be **circular** (`BoxShape.circle` / `ClipOval`).
* Bottom sheets must feature top rounded corners (`24dp`), center drag handle, and contextual pastel accents.

### 🧹 Clean Code & Verification
Before pushing changes to git, ensure static analysis is completely error and warning free:
```bash
dart analyze lib/
```
