# Leader App — Development Rulebook

**Project:** Leader App
**Framework:** Flutter
**Architecture:** MVP
**State Management:** BLoC
**Status:** Greenfield Project

---

# 1. Purpose

This document defines the development standards for the Leader App.

Every developer, AI coding agent, and future contributor must follow these rules when creating, modifying, or reviewing code.

The primary goals are:

* Stable code
* Clean architecture
* Maintainable code
* Consistent implementation
* Scalable project structure
* Good performance
* Easy debugging
* Minimum unnecessary complexity

---

# 2. Technology Rules

The Leader App is built using:

* Flutter
* Dart
* MVP architecture
* BLoC state management

### Mandatory

Use:

```text
Flutter
    +
MVP
    +
BLoC
```

### Not Allowed

Do not introduce another architecture or state-management approach without explicit approval.

Examples:

* Provider as the primary state-management solution
* Riverpod as the primary state-management solution
* GetX
* MobX
* Redux
* MVC
* MVVM
* Clean Architecture as a replacement for MVP

Packages may be introduced when genuinely required, but they must not change the project's core architecture.

---

# 3. Core Architecture

The application follows:

```text
MVP
+
BLoC
```

The general flow is:

```text
User Interaction
       ↓
     View
       ↓
   Presenter
       ↓
      BLoC
       ↓
   Repository
       ↓
   Data Source
       ↓
    API / Local
```

Response flow:

```text
API / Local
       ↓
   Data Source
       ↓
   Repository
       ↓
      BLoC
       ↓
   Presenter
       ↓
      View
```

The exact responsibility of each layer must remain clear.

---

# 4. Folder Structure

The project must follow this base structure:

```text
lib/
│
├── core/
│   ├── constants/
│   ├── enums/
│   ├── extensions/
│   ├── helpers/
│   ├── network/
│   ├── routes/
│   ├── theme/
│   ├── utils/
│   └── widgets/
│
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   └── remote/
│   ├── models/
│   └── repositories/
│
├── features/
│
├── app.dart
└── main.dart
```

Assets:

```text
assets/
├── images/
├── icons/
├── fonts/
└── animations/
```

Tests:

```text
test/
├── core/
├── data/
└── features/
```

---

# 5. Feature Structure

Every feature must be isolated inside:

```text
lib/features/
```

Example:

```text
features/
└── login/
    ├── model/
    ├── view/
    ├── presenter/
    └── bloc/
```

Another example:

```text
features/
└── dashboard/
    ├── model/
    ├── view/
    ├── presenter/
    └── bloc/
```

### Important

Do not create feature folders before the feature actually exists.

Do not put feature-specific files into `core/`.

---

# 6. Model Rules

Models represent data.

Models may contain:

* API response structures
* Request structures
* JSON serialization/deserialization
* Data conversion
* Model-specific helper methods when appropriate

Models must NOT contain:

* UI code
* Widget code
* Navigation logic
* BLoC logic
* Presentation logic

Example:

```text
UserModel
LoginRequest
LoginResponse
```

Use meaningful model names.

Avoid generic names such as:

```text
Data
Response
Object
Item
```

unless the context makes the name genuinely clear.

---

# 7. View Rules

The View is responsible for UI.

The View may contain:

* Widgets
* Layout
* UI styling
* User interaction
* Showing loading states
* Showing success states
* Showing error states
* Listening to BLoC states
* Triggering user actions

The View must NOT contain:

* API calls
* Repository implementation
* Business logic
* Complex data processing
* Authentication logic
* Database logic

Avoid putting large amounts of logic inside `build()`.

---

# 8. Presenter Rules

Presenter belongs to the MVP layer.

Presenter responsibilities include:

* Coordinating presentation behavior
* Preparing information required by the View
* Handling presentation-specific decisions
* Keeping View code clean

Presenter must NOT become:

* A second BLoC
* An API service
* A repository
* A storage manager

Do not duplicate BLoC business logic inside Presenter.

If a responsibility belongs to BLoC, keep it in BLoC.

---

# 9. BLoC Rules

BLoC is the application's state-management mechanism.

General flow:

```text
Event
  ↓
BLoC
  ↓
Repository
  ↓
Data Source
  ↓
BLoC
  ↓
State
```

BLoC is responsible for:

* Receiving events
* Processing state changes
* Coordinating business flows
* Calling repositories
* Emitting states

BLoC must NOT contain:

* Widget code
* BuildContext-dependent UI code
* UI layout
* Direct HTTP implementation
* Direct database implementation

---

# 10. BLoC Event Rules

Events represent something that happened or an action requested by the user/application.

Examples:

```text
LoginSubmitted
LoginRetryRequested
ProfileRequested
ProfileUpdated
LogoutRequested
```

Events should be:

* Meaningful
* Specific
* Small
* Easy to understand

Avoid generic events such as:

```text
DoSomething
HandleData
Update
Process
```

unless their meaning is genuinely clear from context.

---

# 11. BLoC State Rules

States represent the current state of the feature.

Typical states may include:

```text
Initial
Loading
Success
Failure
```

Use more specific states when the feature requires them.

Do not create unnecessary states.

States must contain only the information required by the View or application flow.

---

# 12. Repository Rules

Repositories provide an abstraction between application logic and data sources.

Example:

```text
BLoC
 ↓
UserRepository
 ↓
RemoteDataSource
```

Repositories may decide:

* Which data source to use
* How data is retrieved
* How data is stored
* How data sources are coordinated

Repositories must NOT contain UI logic.

Repositories must NOT depend on Flutter widgets.

---

# 13. Data Source Rules

Remote data sources are responsible for remote operations.

```text
remote/
```

Examples:

```text
AuthRemoteDataSource
UserRemoteDataSource
PostRemoteDataSource
```

Local data sources are responsible for local operations.

```text
local/
```

Examples:

```text
AuthLocalDataSource
UserLocalDataSource
SettingsLocalDataSource
```

Do not mix UI or presentation logic into data sources.

---

# 14. Core Rules

`core/` contains functionality shared by multiple features.

Examples:

```text
core/constants/
core/enums/
core/extensions/
core/helpers/
core/network/
core/routes/
core/theme/
core/utils/
core/widgets/
```

### Important

Do not put feature-specific code inside `core`.

If something is only used by one feature, it belongs to that feature.

Only move code into `core` when it is genuinely shared.

---

# 15. Reusable Widgets

Reusable widgets used by multiple features may live in:

```text
core/widgets/
```

Feature-specific widgets must remain inside:

```text
features/<feature>/view/
```

Do not create a global widget for a component that is only used once.

Avoid creating unnecessary abstractions.

---

# 16. Naming Rules

Use clear and consistent naming.

### Files

Use:

```text
snake_case.dart
```

Examples:

```text
login_screen.dart
user_model.dart
auth_repository.dart
login_bloc.dart
login_event.dart
login_state.dart
```

### Classes

Use:

```text
PascalCase
```

Examples:

```text
LoginScreen
UserModel
AuthRepository
LoginBloc
```

### Variables

Use:

```text
camelCase
```

Examples:

```text
userName
isLoading
selectedUser
```

### Constants

Follow Dart naming conventions and keep names descriptive.

Avoid abbreviations unless they are universally understood.

---

# 17. File Responsibility

Each file should have a clear responsibility.

Avoid files containing unrelated classes.

Avoid extremely large files.

If a file becomes difficult to understand or maintain, consider splitting it by responsibility.

Do not split files unnecessarily just to make the file count larger.

---

# 18. Widget Rules

Prefer small, reusable widgets.

Avoid extremely large widget classes.

If a widget becomes complex, extract meaningful child widgets.

Use:

```dart
const
```

where possible.

Avoid unnecessary widget rebuilds.

Do not use `setState` for application state that belongs to BLoC.

Local temporary UI state may use appropriate local mechanisms when it does not belong to application state.

---

# 19. State Management Rules

BLoC is the standard application state-management solution.

Do not create multiple competing state-management patterns.

Avoid:

```text
BLoC + Provider
BLoC + Riverpod
BLoC + GetX
```

for the same responsibility.

Keep state ownership clear.

Every piece of state should have one clear owner.

---

# 20. API Rules

API implementation must remain outside the View.

Preferred flow:

```text
View
 ↓
Presenter
 ↓
BLoC
 ↓
Repository
 ↓
Remote Data Source
 ↓
API
```

Do not write API calls directly inside widgets.

Do not duplicate API logic across multiple BLoCs.

Common network configuration belongs in:

```text
core/network/
```

---

# 21. Error Handling

Errors must be handled intentionally.

Do not silently ignore exceptions.

Avoid:

```dart
catch (_) {}
```

unless there is a documented reason.

Errors should be converted into meaningful application states/messages.

The UI should receive a meaningful result instead of raw technical exceptions whenever possible.

Do not expose sensitive technical information to users.

---

# 22. Loading State

Every asynchronous operation must have a clear loading strategy.

Example:

```text
Initial
   ↓
Loading
   ↓
Success
```

or:

```text
Initial
   ↓
Loading
   ↓
Failure
```

Avoid duplicated loading indicators.

Avoid triggering the same API operation repeatedly without reason.

---

# 23. Memory Management

Prevent memory leaks.

Always properly dispose:

* Animation controllers
* Text editing controllers
* Scroll controllers
* Focus nodes
* Stream subscriptions
* Timers
* Other disposable resources

BLoCs/Cubits and other lifecycle-managed objects must be closed/disposed according to their ownership.

Do not create resources repeatedly inside `build()`.

---

# 24. Performance

Performance must be considered during implementation.

Rules:

* Avoid unnecessary rebuilds.
* Use `const` where appropriate.
* Keep BLoC state changes targeted.
* Avoid expensive operations inside `build()`.
* Avoid unnecessary API requests.
* Avoid unnecessary object creation.
* Optimize large lists.
* Do not perform heavy computation on the UI thread unnecessarily.

Do not optimize prematurely.

Measure or identify an actual problem before introducing complicated optimization.

---

# 25. Navigation

Navigation must be centralized and consistent.

Application-level routes belong in:

```text
core/routes/
```

Do not scatter route names throughout the application.

Avoid hard-coded navigation logic in many unrelated files.

Feature-specific navigation decisions should remain understandable and testable.

---

# 26. Constants

Shared constants belong in:

```text
core/constants/
```

Do not duplicate the same constant throughout the project.

Examples:

```text
AppConstants
ApiConstants
AssetConstants
```

Only create a constant when it genuinely improves maintainability.

Do not convert every literal into a constant unnecessarily.

---

# 27. Theme

Application-wide visual configuration belongs in:

```text
core/theme/
```

Keep common design decisions centralized.

Examples:

```text
AppTheme
AppColors
AppTextStyles
```

Do not duplicate global styling definitions across every screen.

Feature-specific styling may remain within the feature when appropriate.

---

# 28. Assets

Assets must follow:

```text
assets/
├── images/
├── icons/
├── fonts/
└── animations/
```

Use meaningful filenames.

Avoid:

```text
image1.png
image2.png
new.png
final.png
final2.png
```

Prefer:

```text
profile_placeholder.png
app_logo.png
empty_state.png
```

---

# 29. Dependency Rules

Do not add a package unless it is actually required.

Before adding a dependency:

1. Check whether Flutter/Dart already provides the functionality.
2. Check whether the package is actively maintained.
3. Check whether it solves a real project requirement.
4. Check whether it introduces unnecessary complexity.
5. Ensure it does not conflict with the project architecture.

Never add a package merely because it is popular.

---

# 30. Code Duplication

Avoid duplicated logic.

If the same logic appears repeatedly:

1. Determine whether it is genuinely common.
2. Identify the correct layer.
3. Extract it only when appropriate.

Do not create a generic helper simply because two lines look similar.

Reuse should improve clarity, not reduce it.

---

# 31. Security

Never commit sensitive information.

Do not hard-code:

* API secrets
* Passwords
* Private tokens
* Private keys
* Signing credentials

Sensitive configuration must be handled through an appropriate secure configuration mechanism.

Never log sensitive information.

---

# 32. Logging

Logs must be useful.

Do not leave unnecessary debug logs in production code.

Never log:

* Passwords
* Access tokens
* Private keys
* Sensitive personal information

Use structured and meaningful logs when debugging.

---

# 33. Testing

Tests should follow:

```text
test/
├── core/
├── data/
└── features/
```

When tests are added, keep them close to the corresponding responsibility.

Prioritize testing:

* BLoC behavior
* Repository behavior
* Data transformation
* Important business flows
* Critical UI behavior

Do not write tests simply to increase coverage numbers.

---

# 34. Static Analysis

The project must use Dart/Flutter static analysis.

Before completing a feature:

```text
flutter analyze
```

must be checked.

Do not suppress warnings without understanding why they exist.

Do not use analyzer ignores as a shortcut.

---

# 35. Formatting

Use standard Dart formatting.

Run:

```text
dart format .
```

before finalizing significant changes.

Code should remain consistently formatted.

---

# 36. Build Validation

Before declaring a major implementation complete:

```text
flutter analyze
```

must pass without unresolved errors.

When appropriate, also verify that the application builds successfully.

Never claim a feature is complete without validating the relevant code.

---

# 37. Changes to Existing Code

Before modifying existing code:

1. Understand its purpose.
2. Check its dependencies.
3. Check where it is used.
4. Preserve existing behavior unless a change is explicitly required.
5. Avoid unrelated refactoring.

Do not rewrite working code simply because another style looks different.

---

# 38. New Feature Process

Every new feature should follow this process:

```text
Requirement
    ↓
Understand existing architecture
    ↓
Create feature structure
    ↓
Create Model
    ↓
Create Data Source if required
    ↓
Create Repository
    ↓
Create BLoC
    ↓
Create Presenter
    ↓
Create View
    ↓
Connect dependencies
    ↓
Test
    ↓
Analyze
    ↓
Validate
```

Do not skip architectural responsibilities.

Do not create unnecessary layers when a feature does not require them.

---

# 39. AI / Antigravity Rules

Any AI coding agent working on Leader App must follow this rulebook.

Before modifying code:

1. Inspect the relevant existing files.
2. Understand the current architecture.
3. Identify dependencies.
4. Make the smallest appropriate change.
5. Follow MVP + BLoC.
6. Avoid unrelated changes.
7. Validate the implementation.

The AI must NOT:

* Rewrite the entire project unnecessarily.
* Introduce another architecture.
* Introduce another state-management solution.
* Add unnecessary packages.
* Create fake implementations without being asked.
* Modify unrelated features.
* Delete working code without justification.
* Hide analyzer errors.
* Create unnecessary abstractions.

---

# 40. Minimal Change Principle

When fixing a bug or implementing a requirement:

> Make the smallest change that correctly solves the problem.

Do not refactor unrelated code during a bug fix.

If a larger architectural problem is discovered, report it separately rather than silently changing unrelated parts.

---

# 41. Before Adding New Code

Always ask:

```text
Does this already exist?

Can it be reused?

Which layer owns this responsibility?

Is this feature-specific or shared?

Does this introduce unnecessary complexity?

Does this follow MVP + BLoC?
```

If the answer is unclear, inspect the existing project before creating new code.

---

# 42. Definition of Done

A feature is considered complete only when:

* Requirements are implemented.
* MVP responsibilities are respected.
* BLoC responsibilities are respected.
* No unnecessary dependencies were added.
* No unnecessary duplicate logic exists.
* Error handling is implemented.
* Loading states are handled.
* Resources are properly disposed.
* Code is formatted.
* Static analysis has been checked.
* Relevant tests have been added where required.
* The application builds successfully when applicable.
* No unrelated files were unnecessarily modified.

---

# 43. Golden Rule

The most important rule of the Leader App:

> **Do not write code just to make the feature work. Write code that will remain understandable, stable, maintainable, and scalable when the application becomes large.**

Every implementation must prioritize:

```text
Correctness
    ↓
Stability
    ↓
Maintainability
    ↓
Performance
    ↓
Simplicity
```

The goal is not to create the most complicated architecture.

The goal is to create the **simplest architecture that reliably solves the actual requirement**.

---

# 44. Rulebook Changes

This rulebook is the project's source of truth.

Do not change architectural rules casually.

If a new requirement suggests changing:

* Architecture
* State management
* Folder structure
* Dependency strategy
* Data flow

the change must be discussed and agreed upon before implementation.

---

# 45. Role-Based UI & Functionality Management

The Leader App is a role-based application (e.g. Circle Chair, Circle Founder, Country Director, Super Admin). Visual appearance, navigation, layout structures, and capabilities must be dynamically customized and managed based on the active user role.

Rules:
*   **Role-Wise Views**: Different roles may require entirely different UI dashboards, menu options, or layouts.
*   **Dynamic Functionality**: Feature access, read/write permissions, and data operations must be checked against the active user's role.
*   **Encapsulation**: Keep role-wise logic cleanly separated. Use polymorphic widgets, conditional builds, or distinct view components where UI differences are significant, keeping the underlying business logic (BLoC) unified yet role-aware.

---

# Final Project Standard

Leader App must remain:

```text
Flutter
   │
   ├── MVP Architecture
   │
   ├── BLoC State Management
   │
   ├── Feature-Based Structure
   │
   ├── Clean Data Separation
   │
   ├── Reusable Core Components
   │
   ├── Strong Error Handling
   │
   ├── Performance Conscious
   │
   ├── Testable
   │
   └── Maintainable
```

**This rulebook must be followed for all future Leader App development unless the project architecture is intentionally changed and documented.**
