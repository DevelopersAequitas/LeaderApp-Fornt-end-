# Leader App

A clean, scalable, production-ready Flutter application built using **MVP (Model-View-Presenter) Architecture** and **BLoC State Management**.

---

## 1. Project Directory Structure

The project code is structured to enforce strong separation of concerns:

```text
lib/
├── core/            # Functionality shared across multiple features
│   ├── constants/   # Application-wide constants
│   ├── enums/       # Shared enums
│   ├── extensions/  # Dart/Flutter extension methods
│   ├── helpers/     # Reusable utility classes and functions
│   ├── network/     # Network client configuration and infrastructure
│   ├── routes/      # Application routing and navigation settings
│   ├── theme/       # App styling & theme configuration
│   ├── utils/       # Generic utilities
│   └── widgets/     # Reusable global UI widgets (no feature-specific widgets)
│
├── data/            # Centralized Data Layer
│   ├── datasources/ # API and local storage communication
│   │   ├── local/   # Local databases, key-value stores
│   │   └── remote/  # REST/GraphQL API connections
│   ├── models/      # Plain data structures and serialization (JSON parsing)
│   └── repositories/# Domain/data repositories coordinating local/remote sources
│
├── features/        # Feature modules (initially empty)
│
├── app.dart         # Global configuration (MaterialApp, themes, routing)
└── main.dart        # Main entry point for application initialization
```

---

## 2. Architecture & Design Principles

### MVP (Model-View-Presenter)

* **Model**: Represents raw data, request, and response models. It contains serialization/parsing logic but is strictly free from UI and presentation state.
* **View**: Consists of Flutter widgets and page layouts. It is responsible for rendering states produced by the BLoC and delegating user input. It must contain zero business logic.
* **Presenter**: Bridges the View with application/BLoC states and prepares formatted data for the View. It coordinates view requirements without duplicate state tracking.

### BLoC (Business Logic Component)

We use **BLoC** as our state-management system to capture user interactions (Events) and output application states (States).

**Data & Event Flow:**
```text
User Action (UI) ➔ BLoC Event ➔ BLoC ➔ Repository ➔ Data Source ➔ Repository ➔ BLoC State ➔ View (UI)
```

Common state patterns to follow:
* `Initial`: Pre-interaction state.
* `Loading`: Asynchronous operations in progress.
* `Success`: Operation finished with updated data.
* `Failure`: Operation failed, containing an error message.

---

## 3. Rules for Adding Features

Each feature under the `lib/features/` directory must contain the following structure:

```text
lib/features/feature_name/
├── model/       # Feature-specific models & DTOs
├── view/        # Feature UI components, pages, widgets
├── presenter/   # Presenter mediating BLoC events and layout
└── bloc/        # BLoC, Event, and State implementations
```

* **No direct API calls from BLoC**: BLoC components must always fetch data through Repositories from the `data` layer.
* **No feature-specific widgets in `core`**: Global widgets must go to `lib/core/widgets/`, but feature-specific widgets remain local to the feature folder.
* **No mutable global state**: Keep state changes confined to BLoCs and dependency-injected services.
