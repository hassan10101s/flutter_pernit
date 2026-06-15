# Pernit ERP Architecture Rules - Mobile Frontend

> **META-INSTRUCTION — READ FIRST**
> You MUST follow this document strictly.
> This document is the execution contract for Pernit ERP mobile frontend.
> The goal is not to make every feature complex.
> The goal is to choose the minimum safe architecture that protects ERP data integrity.

---

## Rule Zero — No Duplication

Before writing ANY code, file, class, function, widget, Cubit, state, use case, repository, data source, mapper, validator, route, guard, helper, service, table, or test:

1. Scan the existing codebase.
2. Reuse existing utilities, widgets, patterns, services, mappers, validators, and errors.
3. Extend existing code only when necessary.
4. Never create duplicates.
5. If unsure, ASK.

Duplication in ERP creates inconsistent behavior, hidden bugs, security gaps, and data corruption risk.

---

## Rule One — Pessimistic ERP Execution

Do not assume.
Do not guess.
Do not silently invent behavior.

If a requirement affects:

```text
Inventory
Production
Lab
Quality
Purchases
Sales
Users
Permissions
Security
Business Scope
Stock movements
Financial or business-critical data
```

STOP and ask if unclear.

It is better to ask than to break an ERP system.

---

## Rule Two — Simple by Default

Every feature starts as a simple API-based feature.

Do NOT add:

```text
Local DB
Drafts
WebSocket
Streams
FCM handling
AppLifecycle subscription
Silent refresh
Complex cache orchestration
Background sync
```

unless feature classification explicitly requires it.

---

## Rule Three — Complexity Must Be Earned

Every added layer must protect one of:

```text
Data integrity
User work from loss
Offline reading
Live monitoring
Security
Performance
Business correctness
Permission safety
Business Scope correctness
```

If a layer is not clearly justified, do not add it.

---

## Rule Four — Backend Truth Wins

Local cache, drafts, WebSocket events, permissions cache, and deep links are local hints only.

The backend is the final authority for:

```text
Existence
Permissions
Validation
Prices
Units
Stock quantities
Status transitions
Allowed warehouses
Allowed production lines
Allowed branches/factories
Business rules
```

Before any write operation, the app must revalidate the current state with the backend when data may have changed.

---

# 0. Feature Classification

No feature may be implemented before classification.

---

## 0.1 Required Feature Profile

```text
Feature Name:

Business Area:
- Auth
- Users
- Inventory
- Raw Materials
- Products
- Lab
- Quality
- Production
- Purchases
- Sales
- Reports
- Settings
- Notifications
- Other

Feature Type:
- Simple CRUD
- Master Data
- Transaction
- Long Form
- Real-time Monitor
- Dashboard
- Report / Export
- Settings

Primary Architecture Level:
- Level 1 - Simple API
- Level 2 - Cached Read
- Level 3 - Long Form / Draft
- Level 4 - Real-time

Secondary Capabilities:
- Cache: Yes / No
- Draft: Yes / No
- Real-time: Yes / No
- Offline Read: Yes / No
- FCM Routing: Yes / No
- AppLifecycle Refresh: Yes / No
- Master Data Snapshot: Yes / No
- Business Scope Required: Yes / No

Offline Write:
- Always No

Expected Freshness:
- Live
- Recent
- Can be stale with warning

Search Strategy:
- Local Filter
- Remote Search
- Both

Pagination:
- Yes / No

Business Scope:
- None
- Warehouse
- Factory
- Branch
- Production Line
- Department
- Other

Criticality:
- Low
- Medium
- High
- Inventory Critical
- Production Critical
- Financial Critical
- Security Critical

Required Permissions:

Success Criteria:
1. [Expected behavior] -> verify: [test/check]
2. [Expected behavior] -> verify: [test/check]
```

---

## 0.2 Architecture Levels

### Level 1 — Simple API

Use for:

```text
Simple CRUD
Short forms
Settings
Small lists
Simple details
Screens without offline read
Screens without live updates
```

Includes:

```text
UI
Cubit
UseCase
Repository
RemoteDataSource
Dio
```

Does NOT include:

```text
Local DB
Drafts
WebSocket
AppLifecycle subscription
FCM routing
```

---

### Level 2 — Cached Read

Use for:

```text
Master Data
Units
Products
Raw Materials
Warehouses
Categories
Lab parameter definitions
Slow-changing lookup data
Offline-readable reference data
```

Includes:

```text
Level 1
Drift LocalDataSource
Cache metadata
DataFreshness state
Offline read
Visible stale-data warning
```

Does NOT include:

```text
Offline write
Drafts unless approved
WebSocket unless approved
```

---

### Level 3 — Long Form / Draft

Use for:

```text
Lab Analysis
Long receiving forms
Long production forms
Long quality inspection forms
Any form where user may close and return later
Any form where losing input is unacceptable
```

Includes:

```text
Level 1 or Level 2 as needed
Drift draft storage
Auto-save
Draft recovery dialog
Dirty field protection
Manual submit only
Master Data Snapshot when form depends on mutable master data
```

Does NOT include:

```text
Offline submit
Automatic background sync
WebSocket unless explicitly approved
```

---

### Level 4 — Real-time

Use ONLY for approved live features:

```text
Tracking / Tracks
Production Live
Active Users / Online Users
```

Includes:

```text
Initial API snapshot
WebSocketService
Typed streams
Cubit subscription
Reconnect with exponential backoff
Connection status
Duplicate/out-of-order event protection
```

Does NOT automatically include:

```text
Local DB
Drafts
Offline read
```

---

## 0.3 Decision Tree

```text
Does the screen require live updates while open?
Yes -> Level 4
No -> Continue

Can the user lose long input if the app closes?
Yes -> Level 3
No -> Continue

Must the user read data without internet?
Yes -> Level 2
No -> Continue

Is it simple CRUD / short form / simple list?
Yes -> Level 1
No -> choose the lowest safe level and explain why.
```

For hybrid features, record:

```text
Primary Level:
Secondary Capabilities:
Approved Exception Reason:
```

---

# 1. Behavior Rules

## 1.1 Think Before Coding

Before coding:

```text
State feature classification
State assumptions
State what will NOT be implemented
State permissions
State business scope if required
State success criteria
State verification plan
```

---

## 1.2 Simplicity First

Do NOT write:

```text
Future-proof abstractions
Generic managers
Unused services
Premature streams
Premature cache
Premature lifecycle logic
Premature background sync
```

Minimum safe code wins.

---

## 1.3 Surgical Changes

Touch only what the feature requires.

Do NOT:

```text
Refactor unrelated modules
Rename unrelated classes
Change shared behavior without reason
Modify API contracts silently
Change business scope behavior locally
```

---

## 1.4 ERP Integrity First

For:

```text
POST
PUT
PATCH
DELETE
Status transitions
Stock movements
Production confirmations
Lab approvals
Quality decisions
Business-scope-sensitive actions
```

use pessimistic updates only.

Never show success before server success.

---

# 2. Environments & Flavors

Supported environments:

```text
dev
staging
prod
```

Use flavors for:

```text
App name
Bundle/Application ID
Firebase project
App icon if needed
Native environment config
```

Use compile-time environment values for:

```text
ENV_NAME
API_BASE_URL
WS_BASE_URL
ENABLE_LOGGING
SSL_PIN_SET
CRASH_REPORTING_ENABLED
ANALYTICS_ENABLED
```

Rules:

```text
No hard-coded API URLs
No hard-coded WebSocket URLs
No production keys in dev/staging
No dev/staging API from production build
No production database shared with dev/staging
No production Firebase project in dev/staging
```

Each environment MUST use a different local database file:

```text
pernit_dev.sqlite
pernit_staging.sqlite
pernit_prod.sqlite
```

Each environment MUST have its own SSL pin set if SSL pinning is enabled.

---

# 3. Core Tech Stack

## 3.1 Platform

```text
Android
iOS
```

---

## 3.2 Architecture

Use strict Clean Architecture:

```text
Domain -> Data -> Presentation
```

Allowed dependency direction:

```text
Presentation depends on Domain
Data depends on Domain
Domain depends on nothing
```

Forbidden:

```text
Domain importing Flutter
Domain importing Dio
Domain importing Drift
Domain importing AppLocalizations
Cubit calling DataSource directly
UI calling Repository directly
```

---

## 3.3 State Management

Use:

```text
Cubit only
Dart sealed class states
Equatable
```

Forbidden:

```text
HydratedCubit
Freezed states
GetX
Riverpod
Provider for feature state
Generated Cubits
Generated States
Generated UI
```

---

## 3.4 Dependency Injection

Use:

```text
get_it
```

Rules:

```text
All shared dependencies must be injected
No global static service access
No sl<ScreenCubit>() from singleton services
Use FactoryParam only when Cubit requires runtime parameters such as entity ID
Do not pass dynamic IDs through global mutable state
```

Cubit with runtime ID:

```text
Use FactoryParam or create Cubit in route builder with explicit parameter.
Do not resolve parameterized Cubits from singletons.
```

---

## 3.5 Networking

Use:

```text
Dio inside RemoteDataSource only
AuthInterceptor
Refresh mutex
CancelToken for overlapping GET requests
Central ApiErrorHandler
```

Forbidden:

```text
Retrofit
Direct Dio calls from UI
Direct Dio calls from Cubit
Per-feature error mapping
```

---

## 3.6 Local Database

Drift is the project-wide local database engine.

Use Drift for:

```text
Master Data cache
Offline read cache
Drafts
Cache metadata
Business-scope-aware local data if required
Local lookup filtering
```

Forbidden unless this document is revised:

```text
Isar
Hive
sqflite directly
ObjectBox
JSON files as database
SharedPreferences as database
```

---

## 3.7 AppDatabase Ownership

`AppDatabase` MUST be a LazySingleton.

Rules:

```text
One AppDatabase instance for app lifetime
Never instantiate AppDatabase inside a feature
Never instantiate AppDatabase inside Cubit
Never instantiate AppDatabase inside Repository
Never instantiate AppDatabase inside LocalDataSource
Database filename must include environment
Business Scope must be represented in local schema only when the feature requires scoped local data
```

Forbidden:

```dart
class UnitsLocalDataSource {
  final db = AppDatabase(); // FORBIDDEN
}
```

Correct:

```dart
class UnitsLocalDataSource {
  final AppDatabase db;
  UnitsLocalDataSource(this.db);
}
```

---

## 3.8 Local Preferences

Use `SharedPreferences` only for primitive preferences:

```text
Theme
Language
Last selected filter
Last opened tab
Simple UI flags
```

Forbidden:

```text
Tokens
Drafts
Master data
Permissions
Transactions
Business data
```

---

## 3.9 Code Generation

Allowed:

```text
json_serializable
Drift code generation
Flutter gen-l10n
```

Forbidden:

```text
Freezed
Retrofit
Generated Cubits
Generated States
Generated UI
```

---

# 4. Observability, Crash Reporting & Logging

Production apps must be observable.

Default:

```text
Firebase Crashlytics
Firebase Analytics only for safe operational events
```

Alternative:

```text
Sentry requires explicit architecture approval.
```

Crash reports may include:

```text
Environment
App version
Build number
Screen/route name
Feature name
Failure code
Business scope type if needed
Non-sensitive debug context
```

Never log:

```text
Access token
Refresh token
Password
OTP
Full request body for ERP transactions
Sensitive customer/supplier data
Sensitive lab values unless explicitly approved
Financial values unless explicitly approved
```

Logging rules:

```text
Debug logs allowed only in dev
Verbose logs disabled in prod
Crash logs enabled in staging/prod
Errors must use sanitized context
Logs must never include secrets
```

Allowed analytics examples:

```text
screen_opened
submit_failed
draft_recovered
offline_cache_used
refresh_failed
access_denied
permission_revoked
websocket_reconnect_failed
```

Analytics must NOT expose sensitive ERP data.

---

# 5. Security & Networking

## 5.1 Token Storage

Access Token and Refresh Token MUST be stored in:

```text
FlutterSecureStorage only
```

Forbidden:

```text
SharedPreferences
Drift
Logs
Crash reports
Plain persistent memory
```

iOS note:

```text
If iOS App Groups or shared Keychain access are used, configure keychain-access-groups correctly.
If App Groups are not used, do not add unnecessary keychain sharing.
```

---

## 5.2 Refresh Mutex

Multiple 401 responses must trigger only one refresh request.

Implementation rules:

```text
Use a real async lock mechanism.
Do not use a simple boolean flag.
Refresh waiters must await the same refresh operation.
Refresh operation must have timeout.
If timeout occurs, clear refresh state and force logout.
Retry original request once only after refresh success.
```

Required flow:

```text
401 responses
-> acquire refresh lock
-> if refresh already running, await existing operation
-> refresh once
-> retry waiting requests once
-> force logout if refresh fails or times out
```

Recommended timeout:

```text
15 seconds unless backend requires a documented different value.
```

---

## 5.3 SSL Pinning

Use pinning only with an explicit pinning strategy.

Preferred:

```text
Public key pinning with primary and backup pins.
```

Allowed only with approval:

```text
Leaf certificate pinning.
```

Rules:

```text
Each environment has its own pin set.
Always include at least one backup pin.
Document pin owner, expiry, and rotation date.
Never ship a single non-rotatable pin.
```

Pin rotation policy:

```text
Add new backup pin before certificate/key rotation.
Release app containing old + new pins.
Rotate server certificate/key.
Remove old pin only after safe adoption window.
```

On pinning failure:

```text
Stop normal app flow
Clear tokens
Force logout
Show security warning
Log sanitized security event
Do not retry silently
```

---

## 5.4 Connection Check

Check internet before:

```text
Network UseCase
Write operation
Remote search
Remote refresh
Login
Token refresh
Manual draft submit
```

Do NOT check internet on every local UI tap.

---

## 5.5 Logout

Logout MUST:

```text
Clear tokens
Reset app-wide Cubits
Cancel WebSocket
Cancel subscriptions
Clear sensitive memory
Clear pending route intents if security requires
Navigate to login
Complete even if logout API fails
```

---

# 6. ApiResult, Failure & Error Mapping

Use Dart sealed classes only.

Do NOT use `dartz`, `fpdart`, or custom Either unless this document is revised.

```dart
sealed class ApiResult<T> {
  const ApiResult();
}

final class ApiSuccess<T> extends ApiResult<T> {
  final T data;
  const ApiSuccess(this.data);
}

final class ApiFailure<T> extends ApiResult<T> {
  final Failure failure;
  const ApiFailure(this.failure);
}
```

Failure contract:

```dart
enum FailureCode {
  network,
  unauthorized,
  forbidden,
  notFound,
  validation,
  server,
  cache,
  conflict,
  sslPinning,
  internetRequired,
  timeout,
  permissionRevoked,
  businessScopeForbidden,
  unknown,
}
```

```dart
class Failure extends Equatable {
  final FailureCode code;
  final String messageKey;
  final Map<String, List<String>> fieldErrors;
  final List<String> nonFieldErrors;
  final Object? details;

  const Failure({
    required this.code,
    required this.messageKey,
    this.fieldErrors = const {},
    this.nonFieldErrors = const [],
    this.details,
  });

  @override
  List<Object?> get props => [
    code,
    messageKey,
    fieldErrors,
    nonFieldErrors,
    details,
  ];
}
```

Rules:

```text
Domain returns Failure, not UI text.
Failure contains messageKey, not translated message.
UI translates messageKey in Presentation Layer.
Field-level validation errors must be attached to fields, not shown only as a toast.
Never expose raw Dio error to UI.
```

---

## 6.1 ApiErrorHandler Mapping

All network errors MUST be mapped in one central `ApiErrorHandler`.

Forbidden:

```text
Per-feature custom HTTP error mapping
Raw DioException exposed to Cubit/UI
Unknown used when a specific code exists
```

Required mapping:

```text
DioExceptionType.connectionTimeout -> FailureCode.timeout
DioExceptionType.sendTimeout -> FailureCode.timeout
DioExceptionType.receiveTimeout -> FailureCode.timeout
DioExceptionType.connectionError -> FailureCode.network
DioExceptionType.cancel -> FailureCode.network unless intentionally ignored
DioExceptionType.badCertificate -> FailureCode.sslPinning
DioExceptionType.badResponse -> map by HTTP status
DioExceptionType.unknown -> FailureCode.unknown
```

HTTP status mapping:

```text
400 -> validation
401 -> unauthorized
403 -> forbidden or businessScopeForbidden if scope-related
404 -> notFound
409 -> conflict
422 -> validation
500-599 -> server
Other status -> unknown
```

DRF validation mapping:

```text
Field keys -> Failure.fieldErrors
non_field_errors -> Failure.nonFieldErrors
detail -> Failure.nonFieldErrors or messageKey mapping
```

---

# 7. Localization & i18n

App supports Arabic and English.

Use official Flutter localization generation:

```text
gen-l10n
ARB files
AppLocalizations
```

Rules:

```text
No hard-coded user-facing strings
No translated messages inside Domain
No Locale dependency inside UseCases
No BuildContext inside Domain/Data
No backend error text displayed directly without mapping
```

Correct flow:

```text
Domain/Repository returns Failure(messageKey)
Cubit exposes Failure/messageKey
Presentation translates using AppLocalizations
```

Formatting policy:

```text
Dates, times, decimals, and quantities must be formatted in Presentation Layer.
Use locale-aware formatting.
For ERP numeric input, store and submit normalized machine values, not localized display text.
Do not allow Arabic/English bidi text to corrupt codes, IDs, batch numbers, or SKUs.
Codes and IDs should use stable LTR rendering when mixed with Arabic UI.
```

Validation messages:

```text
Domain returns validation error keys.
UI translates them.
Field-level errors appear under the correct field.
```

---

# 8. State Management & Lifecycle

## 8.1 SafeEmit

Never use `emit()` directly inside Cubits.

Use:

```dart
safeEmit(...)
```

---

## 8.2 State Structure

Every state subclass MUST override `props`.

If base state has cached data, include `super.props`.

```dart
class InventoryError extends InventoryState {
  final Failure failure;

  const InventoryError(
    this.failure, {
    super.cachedItems,
  });

  @override
  List<Object?> get props => [...super.props, failure];
}
```

---

## 8.3 Data Freshness

UI must distinguish data origin and freshness.

Use a clear state field:

```dart
enum DataFreshness {
  fresh,
  refreshing,
  stale,
  offlineCached,
  cacheMiss,
}
```

Rules:

```text
Do not rely only on isFromCache bool when freshness matters.
Cached success must carry freshness metadata.
Cache miss must be represented clearly.
Offline cached data must show warning.
Fresh remote data may clear stale warning.
```

---

## 8.4 In-Memory Cache

Use `cachedData` only for transient screen data.

Use when:

```text
Keep old data while refreshing
Data can die with Cubit
Offline read is not required
```

Do not persist unless classification requires Drift.

---

## 8.5 AppLifecycle Subscription

Do NOT subscribe every Cubit by default.

Subscribe only when:

```text
Level 4 Real-time
Cached data must refresh on resume
Business-critical stale data may mislead user
Reconnect handling is required
```

Forbidden for:

```text
Simple settings
Short forms
One-time details
Non-critical static screens
```

---

## 8.6 Singleton to Cubit Communication

Singletons MUST NOT call screen Cubits.

Correct:

```text
Singleton exposes Stream<Event>
Factory Cubit subscribes
Cubit cancels subscription in close()
```

Use only for:

```text
WebSocket events
AppLifecycle events
Connectivity events if required
```

Notification routing intents are consumed by AppRouter/navigation layer, not Feature Cubits.

---

## 8.7 Dirty Field Protection

Dirty fields MUST NOT be overwritten by:

```text
API refresh
App resume refresh
WebSocket event
FCM-triggered navigation
Local DB reload
Permission refresh
Master Data refresh
```

---

## 8.8 CancelToken

GET:

```text
Use CancelToken for overlapping remote requests.
Cancel previous overlapping request.
Ignore outdated responses.
```

POST/PUT/PATCH/DELETE:

```text
Never use CancelToken.
Must complete or fail explicitly.
```

---

# 9. Database, Cache, Drafts & Master Data Changes

## 9.1 Drift Cache

Use Drift only for:

```text
Level 2 cached read
Level 3 drafts
Approved Level 4 offline read
Business-scope-aware cache if required
```

Cache flow:

```text
Local DB -> emit cached data with freshness
Remote API -> update Local DB
State -> emit fresh data
```

---

## 9.2 Cache Metadata

Cached tables SHOULD track:

```text
lastSyncedAt
isStale
sourceEnvironment
schemaVersion if needed
updatedAt/version from backend if available
businessScopeType if required
businessScopeId if required
```

UI must distinguish:

```text
Fresh
Refreshing
Stale
Offline cached
Cache miss
```

---

## 9.3 Cached Data Warning

When showing stale/offline data, UI MUST show:

```text
You are viewing cached data. This data may be outdated. Please refresh when internet is available.
```

Arabic:

```text
أنت تعرض بيانات محفوظة محليًا وقد تكون غير محدثة. يرجى تحديث البيانات عند توفر الإنترنت.
```

---

## 9.4 Drafts

Drafts are only for Level 3.

Rules:

```text
Auto-save periodically or on field change
Store draft in Drift
Recover/discard on screen init
Delete draft only after server success
Never submit draft automatically
Draft save can be offline
Draft submit requires internet
Draft submit must revalidate current backend state
```

---

## 9.5 Manual Draft Sync

Draft sync is manual only.

Rules:

```text
No automatic background submit
No silent upload when internet returns
User must open draft and press Submit
Submit must run validation again
Submit must require internet
```

This protects ERP data from accidental submission.

---

## 9.6 Master Data Snapshot for Level 3

If a Level 3 form depends on mutable master data, store a snapshot inside the draft.

Examples:

```text
Product price
Unit
Raw material
Warehouse
Lab parameter range
Supplier/customer selection
Formula/reference value
```

Draft snapshot SHOULD include:

```text
entityId
displayName
value used
unit used
updatedAt/version if available
lastSyncedAt
businessScopeType if required
businessScopeId if required
```

Before submit:

```text
Fetch or validate current master data.
Compare current values with draft snapshot.
If critical values changed, block silent submit.
Show user a clear warning.
Require refresh, review, or explicit confirmation based on criticality.
```

Critical changes requiring review:

```text
Price changed
Unit changed
Product/raw material disabled
Lab parameter range changed
Warehouse no longer allowed
Permission revoked
Business scope changed
```

Never overwrite dirty user input automatically.

---

## 9.7 Drift Migrations

Every Drift schema change MUST:

```text
Increase schemaVersion
Add explicit migration
Include migration test
Protect user drafts
Protect cache metadata
Protect business scope fields if used
Never drop draft tables silently
Never delete user drafts without approved destructive migration
```

Migration risk areas:

```text
Drafts
Master data cache
Cache metadata
Business-scope-aware tables
Environment-specific database files
```

---

# 10. Business Scope

This system is not treated as SaaS multi-tenant.

Use Business Scope only when the backend feature is restricted by operational area.

Examples:

```text
Warehouse
Factory
Branch
Production Line
Department
```

Rules:

```text
Do not add Business Scope to every feature by default.
Use it only when required by backend contract or business rule.
If scope is required, it must be passed explicitly in API requests according to backend contract.
If cached data is scope-specific, local queries must filter by scope.
If a user changes scope, active feature state must be cleared or refreshed.
Do not show data from a previous scope as if it belongs to the new scope.
```

Forbidden:

```text
Submitting a draft created for one warehouse under another warehouse without revalidation.
Showing cached scoped data without checking the active scope.
Using UI-selected scope without backend validation.
```

Scope access failure:

```text
403 scope-related response -> businessScopeForbidden
```

---

# 11. Fetching, Pagination & Search

## 11.1 Initial Load

Level 1:

```text
API -> emit data
```

Level 2:

```text
Drift -> emit cached/stale data
API -> update Drift
emit fresh data
```

Level 3:

```text
Check draft
Recover/discard
Load required lookup/cache data
Capture Master Data Snapshot if needed
```

Level 4:

```text
API snapshot
Subscribe to WebSocket typed stream
```

---

## 11.2 Refresh

Rules:

```text
Keep current data visible
Show subtle refreshing indicator
Do not show full skeleton if data exists
Update Drift if cache enabled
Keep cached data on remote failure
Update DataFreshness accurately
```

---

## 11.3 Pagination

Rules:

```text
Fetch next page
Append new items
Filter duplicate IDs
Keep existing items on failure
Show retry for next page
Do not clear list on next page failure
```

---

## 11.4 Search Strategy

Local Filter when:

```text
Data is fully cached
Dataset is small/medium
Server permissions do not affect filtering
Server business rules are not required
```

Remote Search when:

```text
Data is large
Data is paginated
Permissions affect results
Server filtering is authoritative
Data is too large to cache fully
```

Rules:

```text
Debounce human typing by 500ms
Scanner fields process instantly
Cancel overlapping GET only for Remote Search
Do not call API unnecessarily for Local Filter
```

---

## 11.5 Sorting

Remote paginated data:

```text
Use server ordering.
Do not locally reorder partial data as complete.
```

Fully cached data:

```text
Local sort is allowed.
```

---

# 12. Clean Architecture Flow

## 12.1 Level 1

```text
UI
-> Cubit
-> UseCase
-> Repository
-> RemoteDataSource
-> Dio
```

---

## 12.2 Level 2

```text
UI
-> Cubit
-> UseCase
-> Repository
-> LocalDataSource/Drift
-> emit cached data with DataFreshness
-> RemoteDataSource/Dio
-> update Drift
-> emit fresh data
```

---

## 12.3 Level 3

```text
UI
-> Cubit
-> Draft LocalDataSource/Drift
-> Auto-save
-> Recover/discard
-> Validate current master data
-> Submit UseCase
-> RemoteDataSource
-> Delete draft after success
```

---

## 12.4 Level 4

```text
API snapshot
-> Cubit state
WebSocketService typed stream
-> Cubit validates event order/idempotency
-> Cubit updates state
-> cancel subscription in close()
```

---

## 12.5 UseCase Rules

UseCase may contain:

```text
Business validation
Internet check
Permission-aware decisions if needed
Business-scope-aware decisions if needed
Master Data revalidation before submit
Coordination between repositories
Future.wait only when justified
```

UseCase must NOT contain:

```text
Dio
Drift queries
BuildContext
Navigation
UI logic
Translated strings
```

---

## 12.6 Repository Rules

Repository Impl may:

```text
Call RemoteDataSource
Call LocalDataSource
Map exceptions to Failure
Update Drift after remote success
Return cached data when allowed
Apply business scope filters at local data access boundaries when required
```

Repository Impl must NOT:

```text
Emit Cubit states
Navigate
Show Snackbar
Own AppDatabase instance
Use BuildContext
```

---

# 13. Real-time & Notifications

## 13.1 Approved Real-time Features

Only:

```text
Tracking / Tracks
Production Live
Active Users / Online Users
```

Any new real-time feature requires explicit approval.

---

## 13.2 WebSocketService

`WebSocketService` is LazySingleton.

Must:

```text
Authenticate with JWT
Include business scope if required by backend contract
Expose typed streams
Handle reconnect internally
Keep StreamController identity stable
Hide raw socket from features
Expose connection status
Use exponential backoff with jitter
Stop aggressive retry loops
```

Must NOT:

```text
Call Cubits directly
Navigate
Mutate UI state
Create business decisions
```

---

## 13.3 WebSocket Reconnect Policy

Reconnect strategy:

```text
Use exponential backoff with jitter.
Initial delay: 1 second.
Next delays: 2s, 4s, 8s, 16s.
Maximum delay: 30 seconds.
Maximum immediate attempts before degraded state: 5.
After max attempts, enter degraded live mode.
Continue low-frequency retry only if feature remains open and user is authenticated.
```

On degraded live mode:

```text
Show clear indicator: Live connection lost.
Keep last known data visible.
Do not pretend data is live.
Offer manual refresh if API is available.
Fetch latest snapshot after reconnect.
```

---

## 13.4 WebSocket Event Idempotency

Every WebSocket event SHOULD include:

```text
eventId
entityId
eventType
sequenceNumber or serverTimestamp
businessScopeType if required
businessScopeId if required
```

Cubit rules:

```text
Ignore duplicate eventId.
Ignore older sequenceNumber for same entity.
If event order is uncertain, fetch latest API snapshot.
Do not apply event outside current business scope.
Do not overwrite dirty fields.
```

---

## 13.5 Cubit Subscriptions

Feature Cubits:

```text
Subscribe only to needed streams
Use safeEmit
Cancel subscriptions in close()
Do not reconnect raw socket manually
Do not parse raw socket payload directly
```

---

## 13.6 FCM Data Messages

Use FCM only for:

```text
Background notification
Terminated app routing
Deep-link intent
Triggering fetch after screen opens
```

FCM must NOT directly mutate feature state.

Flow:

```text
FCM
-> NotificationRouter
-> PendingRouteIntent
-> AppRouter/AuthGuard
-> Screen opens
-> Cubit fetches latest data
```

---

## 13.7 NotificationRouter

`NotificationRouter` is LazySingleton.

Responsibilities:

```text
Parse payload
Create route intent
Store pending intent if app/router not ready
Pass intent to AppRouter/navigation layer
```

Forbidden:

```text
Calling Feature Cubits
Updating feature state
Writing business data
Submitting operations
```

---

# 14. Routing, Deep Links & Permissions

## 14.1 Protected Routes

Every protected route MUST define:

```text
Route name
Required login state
Required permissions/roles
Allowed parameters
Deep link support: Yes / No
Business Scope requirement if any
```

Example:

```text
Route: /lab/results/create
Required Permission: lab_results.create
Business Scope: Warehouse if required by backend
```

---

## 14.2 Permission Guard

Permissions must be enforced at routing level.

Rules:

```text
Hiding UI buttons is not enough
AppRouter/AuthGuard must block unauthorized routes
Backend remains final authority
Do not instantiate feature Cubit if access denied
Do not call feature API if access denied
```

Unauthorized flow:

```text
Route requested
-> AuthGuard checks permissions
-> If denied: show Access Denied
```

---

## 14.3 Permission Revoked Mid-session

If backend returns 403 after screen is already open:

```text
Do not treat it as a normal snackbar only.
Re-sync permissions.
Disable forbidden actions immediately.
If screen itself is no longer allowed, navigate to Access Denied.
If only one action is forbidden, keep screen open and show translated action-level error.
Clear or invalidate stale permission cache.
```

Use:

```text
FailureCode.permissionRevoked
```

when permission was previously believed valid but backend denies it.

---

## 14.4 Auth Guard

If user is unauthenticated:

```text
Store pending route intent
Navigate to login
After login success:
  Check permissions
  Check business scope if required
  Continue if allowed
  Show Access Denied if not allowed
```

If token is expired:

```text
Try refresh through AuthInterceptor.
If refresh succeeds -> continue.
If refresh fails -> store intent -> login -> resume if allowed.
```

---

## 14.5 Deep Link Safety

Deep links must:

```text
Validate route parameters
Check authentication
Check permissions
Check business scope if required
Fetch latest data after screen opens
Handle 404 as notFound
Never trust deep link data as source of truth
```

If entity is deleted or inaccessible:

```text
404 -> show Not Found screen/message
403 -> show Access Denied or scope/permission message
```

---

# 15. UI & Input Rules

## 15.1 Pessimistic Updates

For writes:

```text
Disable submit
Send request
Wait for server success
Update UI after success
Keep input on failure
Show translated error
Attach field errors to fields
```

---

## 15.2 Offline Write

Offline execution is forbidden.

Message:

```text
Internet connection is required to save this operation.
```

Arabic:

```text
يلزم الاتصال بالإنترنت لحفظ هذه العملية.
```

For Level 3:

```text
You can save this data as a draft and submit it later.
```

Arabic:

```text
يمكنك حفظ البيانات كمسودة وإرسالها لاحقًا.
```

---

## 15.3 Offline Read

Allowed only for cached features.

Must show stale warning.

If no cache and no internet:

```text
ErrorState
Full-screen error
Retry button
DataFreshness.cacheMiss
```

---

## 15.4 Loading

Skeletonizer only when:

```text
Initial loading
No cachedData
No visible data
```

Refresh uses current data + subtle indicator.

---

## 15.5 Validation

Validation exists in:

```text
UI for immediate feedback
Domain for business correctness
Backend as final authority
```

Never rely on UI validation only.

---

## 15.6 Confirmation

Required for:

```text
Delete
Cancel
Confirm receiving
Confirm quality decision
Confirm production step
Confirm sales/purchase status transition
Any irreversible or stock-impacting action
Submitting draft after master data changed
```

---

## 15.7 Input Formatters

Use:

```text
digitsOnly for integers
decimal formatter for decimals
uppercase formatter for codes if required
scanner fields without typing debounce
```

---

## 15.8 Design System

Use Design System for:

```text
Colors
Status badges
Buttons
Forms
Dialogs
Text styles
Spacing
Error widgets
Freshness warnings
Permission errors
Connection indicators
```

No random feature-specific colors.

---

# 16. Project Structure

```text
lib/
  main.dart

  app/
    app.dart
    lifecycle/
      app_lifecycle_service.dart

  core/
    config/
      app_environment.dart
      env_config.dart
      flavor_config.dart

    di/
      dependency_injection.dart

    database/
      app_database.dart
      database_connection.dart
      tables/
        master_data/
        drafts/
        cache/
      daos/
        master_data/
        drafts/
        cache/
      migrations/

    network/
      secure_dio_factory.dart
      api_constants.dart
      connection_checker.dart
      websocket/
        ws_client.dart
        ws_service.dart
        ws_events.dart
        ws_connection_status.dart

    errors/
      api_result.dart
      failure.dart
      failure_code.dart
      api_error_model.dart
      api_error_handler.dart
      field_error_mapper.dart

    routing/
      app_router.dart
      routes.dart
      auth_guard.dart
      permission_guard.dart
      pending_route_intent.dart

    auth/
      token_manager.dart
      auth_interceptor.dart
      auth_service.dart
      refresh_mutex.dart

    business_scope/
      business_scope.dart
      business_scope_service.dart
      business_scope_guard.dart

    security/
      security_service.dart
      security_config.dart
      ssl_pinning_config.dart

    observability/
      crash_reporter.dart
      app_logger.dart
      analytics_service.dart

    notifications/
      fcm_service.dart
      notification_router.dart
      notification_payload.dart

    localization/
      l10n/

    theming/
    helpers/
    mixins/
    utils/

  design_system/
    tokens/
    widgets/
    forms/
    feedback/
    dialogs/
    status_indicators/

  features/
    feature_name/
      data/
        datasources/
        models/
        mappers/
        repos/
      domain/
        entities/
        repos/
        usecases/
        validators/
      presentation/
        bloc/
        screens/
        widgets/
```

---

# 17. Dependency Injection Ownership

Register:

```text
AppEnvironment -> LazySingleton
EnvConfig -> LazySingleton
Dio -> LazySingleton
AppDatabase -> LazySingleton
TokenManager -> LazySingleton
AuthInterceptor -> LazySingleton
RefreshMutex -> LazySingleton
ConnectionChecker -> LazySingleton
AppRouter/RouterConfig -> LazySingleton
AuthGuard -> LazySingleton
PermissionGuard -> LazySingleton
BusinessScopeService -> LazySingleton if required
BusinessScopeGuard -> LazySingleton if required
WebSocketService -> LazySingleton
FCMService -> LazySingleton
NotificationRouter -> LazySingleton
CrashReporter -> LazySingleton
AppLogger -> LazySingleton
AnalyticsService -> LazySingleton
AppLifecycleService -> LazySingleton
Repositories -> LazySingleton
UseCases -> LazySingleton unless stateful
RemoteDataSources -> LazySingleton
LocalDataSources -> LazySingleton
Screen Cubits -> Factory
Parameterized Screen Cubits -> FactoryParam or explicit route factory
```

Rules:

```text
LocalDataSource receives shared AppDatabase
RemoteDataSource receives shared Dio
Screen Cubits are never LazySingleton
AppDatabase is never created inside features
Parameterized Cubits must receive IDs explicitly
BusinessScope services are added only when backend/business rules require them
```

---

# 18. Edge Cases

## 18.1 Empty Cache + Offline

```text
Show full-screen error
Show Retry
Set DataFreshness.cacheMiss
Do not show empty success
```

---

## 18.2 First Page Failure

```text
Cache exists -> show cache + warning
No cache -> full-screen error + Retry
```

---

## 18.3 Next Page Failure

```text
Keep existing items
Stop loading more
Show Retry
Do not clear list
```

---

## 18.4 Concurrent GET

```text
Cancel previous request
Ignore outdated response
Emit only latest valid response
```

---

## 18.5 Real-time Reconnect Failure

```text
Do not recreate StreamController
Keep current UI state
Enter degraded live mode after max attempts
Show connection indicator
Offer manual refresh
Fetch latest snapshot after reconnect
```

---

## 18.6 Not Found

When backend returns 404:

```text
Use FailureCode.notFound
For deep links, show Not Found screen/message
For lists, remove or mark missing item only after confirmed by backend
Do not map 404 to unknown
```

---

## 18.7 Permission Revoked

When backend returns 403 after earlier access:

```text
Re-sync permissions
Disable forbidden actions
Navigate to Access Denied if route is no longer allowed
Do not retry endlessly
```

---

## 18.8 Business Scope Changed

When active Business Scope changes:

```text
Clear or refresh active scoped screens
Do not reuse old scoped cached state as fresh data
Revalidate drafts before submit
Show warning if draft was created under a different scope
```

---

## 18.9 Error Message Safety

Never show raw stack trace or raw backend error.

Show:

```text
Translated message
Field-level messages if available
Retry if possible
Support/debug code if available
```

---

# 19. Testing Strategy

No feature is complete without tests.

---

## 19.1 Test Pyramid

Priority:

```text
Unit Tests
Cubit Tests
Widget Tests
Integration Tests
Golden Tests only for stable design system
```

---

## 19.2 Required Tests by Layer

Domain:

```text
Entities
UseCases
Validators
Business rules
Boundary values
Internet-required write checks
Master Data change validation
Business-scope validation if needed
```

Data Models:

```text
fromJson
toJson
toEntity
Enum mapping
Nullable fields
Date/decimal parsing
```

RemoteDataSource:

```text
Endpoint
Method
Headers
Business scope if required
Query params
Request body
Response parsing
Error handling
```

LocalDataSource:

```text
Use in-memory Drift DB
Insert
Update
Delete
Read
Local filter
Business scope filter if required
Cache metadata
Draft save/recover/delete
```

Repository:

```text
Remote success
Remote failure
Local fallback
Cache update
Offline read
Offline write blocked
Failure mapping
Business scope filtering if required
Master Data snapshot validation
```

Cubit:

```text
Initial state
Loading
Success
Error
Refresh
Submit
Double submit prevention
Cached data preservation
DataFreshness transitions
safeEmit behavior
CancelToken behavior
Field error display
Dirty field protection
```

Widget:

```text
Skeleton loading
Error + Retry
Cached warning
Offline warning
Draft recovery dialog
Master Data changed dialog
Validation messages
Submit disabled while loading
Access Denied
Not Found
Connection degraded indicator
```

Integration:

```text
Login
Token refresh
Logout
Business scope switch if supported
Offline cached read
Lab draft recovery
Lab submit after reconnect
Lab submit after master data changed
Inventory pagination/search
Production Live snapshot + stream update
WebSocket reconnect degraded mode
Active Users live update
Notification/deep link routing
Permission-denied route
Permission revoked mid-session
404 deep link
```

Security:

```text
Tokens not logged
401 refresh mutex
Refresh timeout logout
Refresh failure logout
SSL pinning failure blocks app
Logout clears sensitive state
Route guard blocks unauthorized access
Business scope guard blocks unauthorized scoped access if used
```

Migration:

```text
Schema migration succeeds
Drafts preserved
Cache metadata preserved
Business scope columns preserved if used
No unintended destructive migration
```

Environment:

```text
Dev/Staging/Prod config loads correctly
Wrong production URL is not used in dev
Database filename differs per environment
SSL pin set differs per environment
```

Localization:

```text
No hard-coded user-facing strings
Failure messageKey translated in UI
Field errors translated/displayed correctly
Arabic/English render correctly
Codes remain readable in Arabic UI
```

Observability:

```text
Crash reporter receives sanitized errors
Tokens are never included
Prod disables verbose logs
```

Real-time:

```text
Duplicate event ignored
Out-of-order event ignored or triggers snapshot refresh
Reconnect uses backoff
Degraded mode shown after max attempts
Subscription cancelled on close
```

---

## 19.3 Minimum Tests by Feature Level

Level 1:

```text
UseCase
RemoteDataSource
Repository
Cubit
Critical Widget tests
```

Level 2:

```text
Level 1 tests
Drift LocalDataSource
Cache metadata
DataFreshness
Offline read
Local/remote search strategy
Business scope cache filter if applicable
```

Level 3:

```text
Level 1/2 as needed
Draft save
Draft recovery
Draft discard
Offline submit blocked
Successful submit deletes draft
Failed submit keeps draft
Dirty field protection
Master Data snapshot change detection
Manual submit only
Business scope mismatch warning if applicable
```

Level 4:

```text
Initial API snapshot
WebSocket event handling
Reconnect backoff
Degraded mode
Duplicate/out-of-order event handling
Subscription cancellation
Live state update
No dirty field overwrite
```

---

## 19.4 Test Rules Before Merge

Before merge:

```text
flutter analyze passes with no warnings
flutter test passes
Required tests exist for feature level
Generated files are up to date
No skipped tests without written reason
No hard-coded user-facing strings
No direct AppDatabase instantiation
No unauthorized WebSocket usage
No missing route permission
No missing Business Scope guard if required
No sensitive logging
```

Bug fixes MUST include regression tests.

---

# 20. AI Code Generation Pipeline

Follow this exact order.

---

## Step 0 — Classify

```text
Feature Name
Primary Level
Secondary Capabilities
Permissions
Business Scope if required
Search Strategy
Offline Read
Offline Write
Master Data Snapshot Required
Required Tests
```

Ask if unclear.

---

## Step 1 — Domain

Create:

```text
Entity
Repository Interface
UseCase
Validator if needed
```

Rules:

```text
Equatable
No Flutter
No Dio
No Drift
No translated strings
No BuildContext
```

---

## Step 2 — Data

Create:

```text
Model
Mapper
RemoteDataSource
LocalDataSource only if needed
Drift table only if needed
Repository Impl
```

---

## Step 3 — Presentation Logic

Create:

```text
Sealed State
Cubit
```

Rules:

```text
Use safeEmit
Use cachedData only if useful
Use DataFreshness when cache exists
Use AppLifecycle only if classified
Use WebSocket only if approved
Use Draft only if Level 3
Protect dirty fields
Cancel subscriptions in close()
```

---

## Step 4 — UI

Create:

```text
Screen
Widgets
Skeleton/loading states
Error states
Cached warning
Draft recovery
Master Data changed warning
Validation
Field errors
Confirmation
Access Denied
Not Found
Connection degraded indicator
```

---

## Step 5 — Routing

Add:

```text
Route
Required permissions
Business Scope requirement if needed
Auth guard
Permission guard
Deep link handling if needed
Pending intent support if needed
```

---

## Step 6 — DI

Register according to ownership rules.

Never instantiate shared infrastructure inside features.

---

## Step 7 — Tests

Add required tests for classification level.

---

## Step 8 — Verify

Run:

```text
flutter analyze
flutter test
build_runner if generated files changed
```

Check Definition of Done.

---

# 21. Pernit Feature Decisions

## 21.1 Real-time Features

Approved only:

```text
Tracking / Tracks
Production Live
Active Users / Online Users
```

---

## 21.2 Lab Analysis

```text
Primary Level: Level 3
Draft: Yes
Real-time: No
Offline Draft Save: Yes
Offline Submit: No
Cache: Lookup/master data only
Master Data Snapshot: Yes when using lab parameters, raw materials, products, units, or ranges
Business Scope: Warehouse/Factory only if backend requires it
```

Required:

```text
Auto-save
Recover/discard
UI + Domain validation
Manual submit
Master Data revalidation before submit
Delete draft after success
```

---

## 21.3 Units / Slow Master Data

```text
Primary Level: Level 2
Offline Read: Yes
Real-time: No
Draft: No
Search: Local Filter if fully cached
Business Scope: No unless backend requires scope-specific units
```

Required:

```text
Drift cache
DataFreshness
Stale warning
Remote refresh
No WebSocket
```

---

## 21.4 Inventory

```text
Primary Level: Level 1 or Level 2 by screen
Real-time: No by default
Offline Write: No
Search: Remote for large/paginated data
Business Scope: Warehouse if backend requires warehouse-specific inventory
```

Required:

```text
Pagination
Server filters for large data
Pessimistic writes
Confirmation for critical actions
Route permissions
Business Scope validation if applicable
```

---

## 21.5 Sales / Purchases

```text
Primary Level: Level 1 by default
Level 2 if offline read required
Level 3 if long draft form exists
Real-time: No by default
Offline Write: No
```

---

## 21.6 Production Live

```text
Primary Level: Level 4
Real-time: Yes
Cache: No unless approved
Draft: No unless approved
Business Scope: Production Line or Factory if backend requires it
```

Required:

```text
Initial snapshot
Typed WebSocket events
Reconnect backoff
Degraded mode
Connection indicator
Duplicate/out-of-order event handling
```

---

## 21.7 Active Users

```text
Primary Level: Level 4
Real-time: Yes
Cache: No
Draft: No
Business Scope: No unless backend filters users by department/branch
```

---

# 22. Definition of Done

A feature is complete only when all applicable items are true:

```text
Feature classified
Lowest safe architecture level used
Secondary capabilities documented
No duplicate code
No unnecessary Local DB
No unnecessary WebSocket
No unnecessary AppLifecycle subscription
Drift used only through shared AppDatabase
AppDatabase registered as LazySingleton
LocalDataSource injected with AppDatabase
RemoteDataSource injected with Dio
Environment config used, no hard-coded URLs
Correct database filename per environment
SSL pin set configured per environment if pinning enabled
No hard-coded user-facing strings
Failure uses messageKey
FailureCode is specific, not unknown when avoidable
ApiErrorHandler mapping used
Field-level errors mapped to fields
UI translates messages
Route permissions declared
AuthGuard/PermissionGuard applied
Business Scope handled only if required
Business Scope guard applied if required
Scoped cache/draft filtering implemented if required
Deep link behavior handled if applicable
404 handled as notFound
403 mid-session handled as permission/scope issue
Offline write blocked
Offline read warning shown when needed
DataFreshness represented when cache exists
Draft recovery implemented if Level 3
Draft submit is manual only
Master Data Snapshot used when Level 3 depends on mutable master data
Master Data changes reviewed before submit
Drift migration added if schema changed
Migration test added if schema changed
Real-time subscription cancelled if Level 4
WebSocket reconnect uses backoff
Degraded mode shown after reconnect failure
Duplicate/out-of-order events handled if Level 4
NotificationRouter does not call Cubits
Dirty fields protected
Pessimistic submit implemented
Validation exists in UI and Domain
Errors mapped safely
Crash/logging sanitized
No tokens or sensitive data logged
Required tests added
Regression test added for bug fix
flutter analyze passes with no warnings
flutter test passes
Generated files are up to date
```

---

# ULTIMATE RULE

Every changed line must trace directly to:

```text
User request
Backend contract
ERP data integrity
Approved feature classification
Security requirement
Permission requirement
Business Scope requirement
Environment requirement
Testing requirement
```

If a layer is not justified, do not add it.

Simple is the default.
Complexity is earned.
Backend truth wins.
Data integrity is non-negotiable.
Permissions protect the route.
Business Scope is used only when required.
Tests complete the feature.
