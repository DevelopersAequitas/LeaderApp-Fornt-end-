📘 FLUTTER BLOC + CLEAN ARCHITECTURE RULEBOOK (v2 — STRICT EDITION)

> This is the mandatory, non-negotiable standard for this project.
> Any code that violates a MUST/NEVER rule below is rejected on review,
> no exceptions unless explicitly overridden by the project owner in writing.

═══════════════════════════════════
0. FEATURE-FIRST MVP ARCHITECTURE (TOP PRIORITY)
═══════════════════════════════════
- Every unit of work starts as a FEATURE, not a screen and not a shared
  utility. Ask "what feature does this belong to?" before writing a single file.
- Build the MVP slice of a feature completely (one working vertical slice:
  UI → BLoC → UseCase → Repository → DataSource) before adding secondary
  screens, edge cases, or polish to that feature.
- MVP slice order per feature, strictly in this sequence:
  1. Domain entity + abstract repository + single core UseCase
  2. DataSource + RepositoryImpl (wire to real or mock API)
  3. BLoC (Initial/Loading/Success/Error states only, minimum viable events)
  4. UI (Success-state render first, then Loading/Error/Empty states)
- NEVER build secondary features, animations, or "nice to have" states
  before the MVP vertical slice of the current feature is fully wired
  end-to-end and compiling.
- Every feature lives in its own folder under `lib/features/<feature_name>/`
  with the full presentation/domain/data split — no feature code outside
  this structure, no shared "misc" or "common_screens" dumping ground.

═══════════════════════════════════
1. DIRECTORY STRUCTURE (MANDATORY)
═══════════════════════════════════
lib/features/<feature_name>/
├── presentation/
│   ├── screens/
│   ├── widgets/
│   └── bloc/
├── domain/
│   ├── entities/
│   ├── repositories/       (abstract only)
│   └── usecases/
└── data/
    ├── models/              (DTOs — fromJson/toJson only)
    ├── repositories_impl/
    └── datasources/         (remote/local)

═══════════════════════════════════
2. UI LAYER — ABSOLUTE ISOLATION FROM DATA/API (STRICT)
═══════════════════════════════════
THE UI MUST NOT KNOW:
- That an API exists.
- What the API endpoint, payload shape, or response format looks like.
- Whether data came from network, cache, or local DB.
- Anything about `Model`/DTO classes — UI only ever sees `Entity` objects
  passed inside a BLoC `State`.

❌ NEVER (zero tolerance):
- `StatefulWidget` + `setState()` for anything data- or business-related.
  (`StatefulWidget` is allowed ONLY for pure UI mechanics with no business
  meaning: `TabController`, `AnimationController`, `PageController`,
  scroll listeners, text field focus — nothing that touches app/business state.)
- Any widget importing anything from `data/` (models, datasources, repo impls).
- Any widget calling `http`, `dio`, Firebase SDKs, or any service directly.
- Business logic (calculations, validation, transformations) inside a widget.
- Screens longer than the line limits in Section 3.
- `.withOpacity()` — use `.withValues(alpha: ...)`.

✅ MUST:
- `StatelessWidget` + `flutter_bloc` (`BlocBuilder`/`BlocConsumer`/
  `BlocListener`) for 100% of business/data-driven state.
- Every screen designed for and rendering all 4 BLoC states:
  Initial, Loading, Success, Error — no screen ships with only a
  happy-path render.
- Widgets receive typed `Entity` objects only, never raw `Map`/`json`.

═══════════════════════════════════
3. FILE SIZE LIMITS (HARD CAPS — ENFORCED)
═══════════════════════════════════
| File type            | Hard limit  | Action when exceeded                     |
|-----------------------|------------|-------------------------------------------|
| Main screen file       | 200 lines  | Extract sections into `widgets/*.dart`     |
| Any widget file        | 120 lines  | Split into smaller sub-widgets             |
| BLoC file (single)     | 150 lines  | Split into separate event/state files      |
| Event/State files      | 100 lines  | Group related events/states, don't bloat   |
| UseCase file           | 40 lines   | UseCase does ONE thing — if it's longer,
|                        |            | it's doing too much, split it              |

RULE: "One Screen = Multiple Widget Files" — a main screen file should
contain ONLY: BlocProvider/BlocBuilder wiring, Scaffold shell, and calls
to extracted widgets. No raw layout trees (Column/Row nesting > 2 levels
deep) inside the main screen file itself.

Screen folder pattern (mandatory once a screen has any nontrivial UI):
home_screen/
├── home_screen.dart          (scaffold + BLoC wiring ONLY, <200 lines)
└── widgets/
    ├── home_header.dart
    ├── home_chat_list.dart
    └── home_input_bar.dart

═══════════════════════════════════
4. STATE MANAGEMENT — BLOC ONLY, NO EXCEPTIONS
═══════════════════════════════════
❌ STRICTLY FORBIDDEN, project-wide:
- `setState()` for anything beyond pure UI mechanics (see Section 2 exception).
- `Provider`, `Riverpod`, `GetX`, `MobX`, `ValueNotifier` for business/app state.
- `InheritedWidget` custom state containers.
- Global mutable variables / singletons holding business state.

✅ MUST:
- `flutter_bloc` exclusively, for every feature, every screen, no exceptions.
- One BLoC per feature (or per well-scoped sub-feature) — never a
  god-BLoC shared across unrelated features.
- BLoC states are sealed/immutable classes with `Equatable` (or equivalent)
  — no mutable state objects.
- BLoC communicates EXCLUSIVELY with UseCases — never touches
  Repository implementations, DataSources, or raw API clients directly.
- No navigation logic, no `BuildContext`, no UI-specific objects stored
  or referenced inside a BLoC.

Data flow (must match exactly):
UI → Event → BLoC → UseCase → Repository (abstract) → RepositoryImpl → DataSource
UI ← State ← BLoC ← Result

═══════════════════════════════════
5. USECASE RULES
═══════════════════════════════════
- Single responsibility, single public method (commonly `call()`).
- One UseCase = one action (`SendMessage`, `GetUserDetails`) — never a
  multi-purpose UseCase with branching logic for different actions.
- The ONLY path a BLoC uses to reach a Repository.
- Must be trivially unit-testable/mockable with no Flutter/UI dependencies.

═══════════════════════════════════
6. REPOSITORY & DATASOURCE RULES
═══════════════════════════════════
- Domain layer: abstract class only (interface, zero implementation).
- Data layer: `RepositoryImpl` implements the abstract interface, delegates
  to DataSource(s).
- DataSource: raw fetch only (API/WebSocket/local DB) — returns `Model`
  (DTO), never `Entity`.
- Repository/RepositoryImpl is the ONLY place `Model → Entity` mapping happens.

Example:
```dart
// domain/repositories/chat_repository.dart
abstract class ChatRepository {
  Future<List<Message>> getMessages();
}

// data/repositories_impl/chat_repository_impl.dart
class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remote;
  ChatRepositoryImpl(this.remote);

  @override
  Future<List<Message>> getMessages() => remote.getMessages();
}
```

═══════════════════════════════════
7. MODEL VS ENTITY (STRICT SEPARATION)
═══════════════════════════════════
| Feature   | Entity (Domain)        | Model (Data)              |
|-----------|-------------------------|----------------------------|
| Purpose   | Pure business logic     | JSON parsing/persistence   |
| Location  | domain/entities         | data/models                |
| Knowledge | Knows nothing of JSON   | Knows fromJson/toJson      |

❌ NEVER use a `Model` in the UI layer.
❌ NEVER use an `Entity` inside a DataSource.

═══════════════════════════════════
8. DEPENDENCY DIRECTION (ENFORCED)
═══════════════════════════════════
ALLOWED:
UI → BLoC → UseCase → Repository (abstract) → RepositoryImpl → DataSource

FORBIDDEN (any of these = immediate rejection):
UI → Service/API ❌
UI → Repository ❌
UI → DataSource ❌
UI → Model ❌
BLoC → Repository (skipping UseCase) ❌
BLoC → DataSource ❌

═══════════════════════════════════
9. API STANDARDS
═══════════════════════════════════
- All endpoints centralized in `lib/core/constants/api_endpoints.dart`.
- `ApiEndpoints` class is the only source of endpoint strings.
- ❌ NEVER hardcode a URL/path/base URL anywhere else, including inside
  a DataSource "just for testing."

═══════════════════════════════════
10. DESIGN SYSTEM (unchanged, still mandatory)
═══════════════════════════════════
- Colors: `AppColor` / `Theme.of(context).colorScheme` only. No raw hex,
  no `Colors.red` etc. Transparency via `.withValues(alpha:)`.
- Typography: `AppTypography` / `Theme.of(context).textTheme` only,
  `.copyWith()` to