# Pernit ERP — Agent Instructions

## One-time setup

```powershell
# Flutter SDK location used by this project:
C:\flutter
```

## Run

```powershell
# Required: API_BASE_URL must be provided at build/run time
flutter run --dart-define=API_BASE_URL=https://your-api-domain.com

# Optional dart-defines
--dart-define=ENV_NAME=dev
--dart-define=WS_BASE_URL=wss://your-ws-domain.com
--dart-define=ENABLE_LOGGING=true
```

## Verify

```powershell
flutter analyze   # static analysis (no typechecker separate from analyze)
flutter test      # all tests
```

No `build_runner`, codegen, or migration steps to run. No pre-commit hooks or CI workflows configured.

## Architecture

**Clean Architecture**: `Domain -> Data -> Presentation`

- **Domain** is pure Dart (no Flutter, Dio, Drift, AppLocalizations).
- **Presentation** depends on Domain. **Data** depends on Domain. **Domain** depends on nothing.
- Cubit calls UseCase -> Repository -> RemoteDataSource -> Dio.
- Direct Dio calls from UI or Cubit are forbidden.

**State management**: Cubit-only, sealed class states with Equatable. No Freezed, GetX, Riverpod, Provider for feature state, generated Cubits/UI.

**DI**: `get_it` — all shared dependencies injected as LazySingleton or Factory. No global static service access.

## Feature structure

Each feature under `lib/features/` follows this layout:

```
feature/
  data/
    datasources/   # DioRemoteDataSource (Dio inside RemoteDataSource only)
    models/        # JSON serialization
    repos/         # RepositoryImpl
  domain/
    entities/      # Pure Dart entities
    repos/         # Abstract repository
    usecases/      # UseCase classes
    validators/    # Input validators
  presentation/
    bloc/          # Cubit + sealed state
    screens/       # UI widgets
```

## Core rules (from `skill-addnewfeature/SKILL.md`)

- Use `safeEmit()` not `emit()` directly inside Cubits.
- All API calls return `ApiResult<T>` (sealed: `ApiSuccess<T>` / `ApiFailure<T>`).
- Central `ApiErrorHandler` maps all network errors. No per-feature HTTP error mapping.
- `Failure` carries `messageKey` (not translated text). UI translates in Presentation via `AppLocalizations`.
- Tokens stored only in `FlutterSecureStorage`. Not in SharedPreferences, Drift, logs, or crash reports.
- `CancelToken` for overlapping GET requests only. Never for POST/PUT/PATCH/DELETE.
- No hard-coded API/WebSocket URLs. No production keys in dev/staging builds.
- Feature classification (Level 1-4) must happen before implementing. See SKILL.md §0.
- No duplicate code: scan existing utilities, widgets, patterns before writing anything new.
- ERP write operations use pessimistic updates only — never show success before server success.
- Cairo font from `assets/fonts/` is the app font family (700 weight loaded).

## Localization

- ARB source: `lib/core/localization/l10n/app_en.arb` and `app_ar.arb`
- Generated output: `lib/core/localization/generated/`
- Config: `l10n.yaml` (arb-dir, template-arb-file, output-dir)
- Run `flutter gen-l10n` after editing ARB files (automatic with `flutter run` since `generate: true` in pubspec.yaml).
- Supported locales: Arabic (`ar`) and English (`en`). Default locale is `ar`.

## Important constraints

- `Drift` is not yet in dependencies — listed in SKILL.md as the intended local DB but not adopted.
- No Firebase, SharedPreferences, build_runner, json_serializable, or retrofit dependencies.
- `flutter_screenutil` design size: 375x812, `minTextAdapt: false`, `splitScreenMode: true`.
- Routes defined in `lib/core/routing/routes.dart` (startup, login, home). AppRouter in `lib/core/routing/app_router.dart`.
- Main entry: `lib/main.dart` -> `configureDependencies()` -> `PernitApp()`.
- VS Code SDK path is local-only in `.vscode/settings.json`.
- No CI/CD, no pre-commit, no lint rules beyond `package:flutter_lints/flutter.yaml`.
