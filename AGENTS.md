# Pernit ERP — Agent Instructions

## One-time setup

- Flutter SDK lives at `C:\flutter` (also pinned in `.vscode/settings.json`).
- `flutter pub get` to restore dependencies. No `build_runner`, codegen, or migrations exist.

## Run

`API_BASE_URL` has no default and is **required** at build/run time (empty if omitted):

```powershell
flutter run --dart-define=API_BASE_URL=https://your-api-domain.com
```

Optional `--dart-define`s (see `lib/core/config/env_config.dart`): `ENV_NAME` (default `dev`), `WS_BASE_URL`, `ENABLE_LOGGING` (default `true`).

## Verify

```powershell
flutter analyze   # static analysis + types (no separate typecheck step)
flutter test      # all tests
```

Run a single test file: `flutter test test/features/auth/`. Tests mirror `lib/` under `test/core/` and `test/features/`. No pre-commit hooks or CI configured.

## Authoritative architecture contract

`skill-addnewfeature/SKILL.md` is the **binding** architecture contract (feature classification, layer rules, security, testing). Read the relevant sections before adding or changing features. The notes below are the highest-signal shortcuts and reconciliation points; when they conflict with SKILL.md on intent, SKILL.md wins — except where this file flags something as *not yet adopted*.

### Critical trap: Drift / codegen not yet adopted

SKILL.md describes `Drift`, `json_serializable`, `build_runner`, and per-environment `.sqlite` files as the intended local-DB stack. **None of this is in `pubspec.yaml` yet.** Do NOT run `build_runner`, do NOT add `drift`/`json_serializable` imports, do NOT assume a local DB exists. Models are hand-written JSON serialization. Treat every "Level 2/3/4" feature that needs persistence as blocked until Drift is adopted — ask the user.

Also absent (despite SKILL.md mentioning them): Crashlytics, Analytics, FCM token registration endpoint, SharedPreferences, SSL pinning. The app now uses `firebase_core` + `firebase_messaging` for background/terminated push, plus `flutter_local_notifications` + `NotificationWebSocketService` for foreground delivery.

## Architecture

**Clean Architecture**, strict dependency direction: `Presentation -> Domain`, `Data -> Domain`, `Domain -> nothing`.

- **Domain** is pure Dart: no Flutter, Dio, Drift, or `AppLocalizations`.
- Flow: `UI -> Cubit -> UseCase -> Repository -> RemoteDataSource -> Dio`. Direct Dio calls from UI or Cubit are forbidden.
- **State**: Cubit-only with Dart `sealed` states + `Equatable`. No Freezed, GetX, Riverpod, Provider, or generated Cubits/UI.
- **DI**: `get_it`. The instance is named **`sl`** (`lib/core/di/dependency_injection.dart`). Shared infra = `LazySingleton`; screen Cubits = `Factory` (or `FactoryParam`/route factory when a runtime ID is needed). No global static service access. Register new dependencies in `configureDependencies()`.

### Non-negotiable conventions (enforced across the codebase)

- Use **`safeEmit()`** (from `lib/core/bloc/safe_cubit.dart`), never `emit()`, inside Cubits.
- All API calls return `ApiResult<T>` (`lib/core/errors/api_result.dart`): sealed `ApiSuccess<T>` / `ApiFailure<T>`.
- All network errors map through one central **`ApiErrorHandler`** (`lib/core/errors/api_error_handler.dart`). No per-feature HTTP error mapping; never expose raw `DioException` to Cubit/UI.
- `Failure` carries a **`messageKey`** (not translated text). UI translates via `AppLocalizations`. Never put translated strings in Domain/Data.
- Tokens live **only** in `FlutterSecureStorage` — never SharedPreferences, Drift, logs, or crash reports.
- `CancelToken` for overlapping **GET** only. Never for POST/PUT/PATCH/DELETE.
- ERP writes are **pessimistic** — never show success before server success. Block offline writes.
- No hard-coded API/WS URLs (use `EnvConfig`). No production keys in dev/staging.
- No duplicate code: scan `lib/core/`, `lib/design_system/`, and existing features before writing anything new (SKILL.md Rule Zero).
- Feature classification (Level 1-4, SKILL.md §0) must happen before implementing any feature.

## Feature structure

Each feature under `lib/features/` follows:

```
feature/
  data/
    datasources/   # Dio lives inside RemoteDataSource only
    models/        # hand-written JSON (de)serialization + toEntity mappers
    mappers/
    repos/         # RepositoryImpl
  domain/
    entities/      # pure Dart
    repos/         # abstract repository
    usecases/
    validators/
  presentation/
    bloc/          # Cubit + sealed state
    screens/
    widgets/
```

Existing features: `auth`, `home`, `notifications`, `orders`, `production`, `quality` (hub: raw‑material + production sub‑features), `raw_material_entry`, `screen_records`, `settings`.

### Sub‑feature: Quality hub

`/quality` shows a hub with two cards. Each card navigates to a separate sub‑feature:

- **Raw‑material quality** (`/quality/raw-materials`, renamed `RawMaterialQualityScreen`) — 3‑tab screen: sampling, analysis, quality decision. Uses `RawMaterialQualityCubit`. No changes from original `QualityScreen`.
- **Production quality** (`/quality/production`, `ProductionQualityScreen`) — full Clean‑Architecture feature:
  - 3 tabs: Samples (list + create), Results (list + create), Quality Decisions (read‑only list only).
  - Domain entities exactly match `PernitAPI.yaml`: `ProductionLabSample` (no `sampleNumber`/`notes`; has `productionOrderCode`, `quantityTaken`), `ProductionLabResult` (field is `value` not `measuredValue`, no `notes`; has `sampleNo` read‑only), `ProductionQualityCheck` (field is `comments` not `notes`; has `receivedProductId`, `productionOrderCode`).
  - Create payloads follow API exactly: `createSample` sends only `production_order` + optional `quantity_taken`; `createResult` sends only `sample`, `parameter`, `value`.
  - **No manual ID inputs** — create sample selects production orders via searchable `PernitLookupAutocompleteField<int>`; create result selects samples from loaded list and analysis parameters via searchable dropdown.
  - Status values are localized through 7 ARB keys (`prodQualityStatusPending/Completed/Invalid/Accepted/Rejected/Release/Quarantine`).
  - 5 use cases: `LoadProductionLabSamples`, `CreateProductionLabSample`, `LoadProductionLabResults`, `CreateProductionLabResult`, `LoadProductionQualityChecks`.
  - Data source: `DioProductionQualityRemoteDataSource` with cancel tokens, paginated parsing, `fetchAnalysisParameters` and `fetchProductionOrders`.
  - Cubit: `ProductionQualityCubit` + `ProductionQualityState` (sealed with loading/loaded/creating/error sub‑states, holds all 3 tab lists + pagination). Accepts `quantityTaken` for create sample, `value` for create result.

### Design‑system: PernitLookupAutocompleteField

`lib/design_system/forms/pernit_lookup_autocomplete_field.dart` — generic `<T>` search‑as‑you‑type field with 400ms debounce, results list (label + subtitle), loading spinner, error + retry, and empty state. Used by production‑quality create bottom sheets.

### WebSocket: idempotent connect

`NotificationWebSocketService.connect()` is now idempotent (no‑op if `connecting`/`connected`). Stores `StreamSubscription` and cancels it in `disconnect()`/`dispose()`. Forces `wss://` in production. No token leaks in logs.

### PDF: Arabic font validation

`InventoryPdfExporter.generateReport` detects Arabic Unicode range (0x0600–0x06FF) in labels/rows. If Arabic content found and `fontData == null`, throws `Exception('Arabic PDF export requires a font...')` instead of producing garbled output. The font‑less Arabic PDF test asserts this exception and prints no Helvetica warnings.

Shared UI primitives live in `lib/design_system/` (tokens, widgets, forms, feedback, dialogs, status indicators) — prefer these over feature-specific colors/widgets.

## Localization

- ARB source: `lib/core/localization/l10n/app_en.arb` (template) and `app_ar.arb`. Config in `l10n.yaml`.
- Generated output: `lib/core/localization/generated/app_localizations.dart` — run `flutter gen-l10n` after editing ARB (auto-runs with `flutter run`/`build` since `generate: true`).
- Supported locales: Arabic (`ar`, **default**) and English (`en`). `PernitApp` hard-codes `locale: Locale('ar')`.
- No hard-coded user-facing strings. Codes/IDs/SKUs must render stable LTR even in Arabic UI.

## Key wiring

- Entry: `lib/main.dart` -> `Firebase.initializeApp()` -> `configureDependencies()` -> init `LocalNotificationService` -> `NotificationEventListener` (WS→system) -> `FirebaseMessaging.onBackgroundMessage` + `onMessageOpenedApp` -> `runApp(PernitApp())`.
- `lib/app/app.dart`: `ScreenUtilInit` design size **375x812**, `minTextAdapt: false`, `splitScreenMode: true`. Text scaling is forced off app-wide (`TextScaler.noScaling`). Font family is **Cairo** (only 700 weight loaded — see `pubspec.yaml`). Uses `navigatorKey` (`lib/core/routing/navigator_key.dart`) for context-free FCM tap navigation.
- Routes in `lib/core/routing/routes.dart`: `startup`, `login`, `home`, `raw-material-entry`, `inventory`, `quality` (with sub‑routes `/quality/raw-materials`, `/quality/production`), `production`, `settings`, `notifications`. `AppRouter` (`LazySingleton`) generates routes via `onGenerateRoute`.
- Backend contract reference: `PernitAPI.yaml` (OpenAPI 3.0.3, ~25k lines) at repo root — consult it for endpoint/shape questions instead of guessing.

### Notification delivery

| App state | Delivery path |
|---|---|
| **Foreground** | WebSocket → `NotificationWebSocketService.events` (broadcast) → `NotificationEventListener` (system notif) + `NotificationBadgeWidget` (badge) + `NotificationCubit` (live list, scoped to `/notifications` route) |
| **Background / Terminated** | FCM → `firebaseMessagingBackgroundHandler` (separate isolate) → `flutter_local_notifications` shows system notification. User taps → `onMessageOpenedApp` fires → `NotificationRouter` stores intent → `navigatorKey` pushes `/notifications`. |
| **FCM token reg** | No backend endpoint yet. Backend must supply one to enable server-to-device push. |

## Constraints worth remembering

- `flutter_lints` (`package:flutter_lints/flutter.yaml`) is the only lint set; no custom rules.
- No CI/CD, no pre-commit hooks.
- VS Code SDK path in `.vscode/settings.json` is local-only.
