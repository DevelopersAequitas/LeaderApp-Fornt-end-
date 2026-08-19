# Project-Scoped Rules for Leader App

All agents working on the Leader App codebase MUST adhere to the following rules:

1. **Framework & Architecture**: Always use Flutter, MVP (Model-View-Presenter), and BLoC (State Management).
2. **Directory Structure**: Put new features in `lib/features/feature_name/` containing subfolders: `model/`, `view/`, `presenter/`, `bloc/`. Do not put feature-specific items in `lib/core/`.
3. **Dependencies**: Do not add new packages unless explicitly requested. The only approved state management library is `flutter_bloc`.
4. **Clean Code**: Follow the constraints defined in [RULEBOOK.md](file:///d:/Office%20Project/leaderapp/RULEBOOK.md) regarding naming, error handling, performance, and disposal of controllers.
5. **Role-Based UI & Functionality**: The application is role-based (e.g. Circle Chair, Circle Founder, Country Director, Super Admin). Visual appearance, navigation, layout structures, and capabilities must be dynamically customized and managed based on the active user role.

