# Installed third-party skills (project level, untracked)

Source: https://github.com/flutter/agent-plugins (official Flutter org, BSD-3-Clause), commit ff6d472ee66dbed566c4500edee460c94fde0a02, fetched 2026-11-24.
Taken: only `skills/<name>/SKILL.md` for the 9 skills below (markdown only, reviewed before install: no scripts, no hooks, no network calls beyond `flutter pub add/get`).
NOT taken: the repo's `hooks.json`, `rules/`, `.agents/` (agents/hooks execute or steer behaviour).
Skills: flutter-fix-layout-issues, flutter-build-responsive-layout, flutter-apply-architecture-best-practices, flutter-setup-localization, flutter-add-widget-test, flutter-add-integration-test, dart-add-unit-test, dart-run-static-analysis, dart-resolve-package-conflicts.
Project rules override these skills: no invented languages (localization examples use es), no dependency or pubspec.lock changes without approval, no restructuring of the existing feature architecture.
