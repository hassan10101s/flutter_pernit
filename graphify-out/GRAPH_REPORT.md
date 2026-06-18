# Graph Report - .  (2026-06-16)

## Corpus Check
- 158 files · ~92,664 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 82 nodes · 78 edges · 25 communities (11 shown, 14 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Auth Feature - Login & Routing|Auth Feature - Login & Routing]]
- [[_COMMUNITY_App Shell & Theme Configuration|App Shell & Theme Configuration]]
- [[_COMMUNITY_Auth Domain & Dependency Injection|Auth Domain & Dependency Injection]]
- [[_COMMUNITY_Raw Material Entry Feature|Raw Material Entry Feature]]
- [[_COMMUNITY_Home Workspace Feature|Home Workspace Feature]]
- [[_COMMUNITY_Project Config & Architecture Rules|Project Config & Architecture Rules]]
- [[_COMMUNITY_Auth Networking & Token Management|Auth Networking & Token Management]]
- [[_COMMUNITY_Error Handling (ApiResultFailure)|Error Handling (ApiResult/Failure)]]
- [[_COMMUNITY_Settings Administration Feature|Settings Administration Feature]]
- [[_COMMUNITY_Production Feature|Production Feature]]
- [[_COMMUNITY_Quality Feature|Quality Feature]]
- [[_COMMUNITY_Public API Networking|Public API Networking]]
- [[_COMMUNITY_Screen Records CRUD|Screen Records CRUD]]
- [[_COMMUNITY_Community 13|Community 13]]
- [[_COMMUNITY_Community 14|Community 14]]
- [[_COMMUNITY_Community 15|Community 15]]
- [[_COMMUNITY_Community 16|Community 16]]
- [[_COMMUNITY_Community 17|Community 17]]
- [[_COMMUNITY_Community 18|Community 18]]
- [[_COMMUNITY_Community 19|Community 19]]
- [[_COMMUNITY_Community 20|Community 20]]
- [[_COMMUNITY_Community 21|Community 21]]
- [[_COMMUNITY_Community 22|Community 22]]
- [[_COMMUNITY_Community 23|Community 23]]
- [[_COMMUNITY_Community 24|Community 24]]

## God Nodes (most connected - your core abstractions)

## Surprising Connections (you probably didn't know these)
- `PernitApp` ----> `Dependency Injection`  [EXTRACTED]
   →   _Bridges community 1 → community 2_
- `PernitApp` ----> `AppRouter`  [EXTRACTED]
   →   _Bridges community 1 → community 0_
- `Dependency Injection` ----> `LoginCubit`  [EXTRACTED]
   →   _Bridges community 2 → community 0_
- `Dependency Injection` ----> `RawMaterialEntryCubit`  [EXTRACTED]
   →   _Bridges community 2 → community 3_
- `AppRouter` ----> `HomeScreen`  [EXTRACTED]
   →   _Bridges community 0 → community 4_

## Import Cycles
- None detected.

## Communities (25 total, 14 thin omitted)

### Community 0 - "Auth Feature - Login & Routing"
Cohesion: 0.24
Nodes (11): Auth Feature, AuthSession, AuthUser, LoginCredentials, LoginCubit, LoginScreen, LoginState, RouteRequirements (+3 more)

### Community 1 - "App Shell & Theme Configuration"
Cohesion: 0.25
Nodes (8): PernitApp, PernitColors, Design System, EnvConfig, FailureMessageLocalizer, PernitFontWeights, AppLocalizations, PernitTextTheme

### Community 2 - "Auth Domain & Dependency Injection"
Cohesion: 0.31
Nodes (9): AuthRemoteDataSource, AuthRepository, AuthRepositoryImpl, AuthSessionCubit, Dependency Injection, LoginUseCase, LoginValidator, Auth Tests (+1 more)

### Community 3 - "Raw Material Entry Feature"
Cohesion: 0.43
Nodes (7): RawMaterialEntryCubit, RawMaterialEntryRemoteDataSource, Raw Material Entry, RawMaterialEntryRepository, RawMaterialEntryRepositoryImpl, RawMaterialEntryScreen, Raw Material Tests

### Community 4 - "Home Workspace Feature"
Cohesion: 0.47
Nodes (6): HomeDesktopMenu, Home Feature, HomeMenuSection, HomeMobileMenu, HomeScreen, Home Tests

### Community 5 - "Project Config & Architecture Rules"
Cohesion: 0.40
Nodes (5): analysis_options.yaml, l10n.yaml, pubspec.yaml, README.md, SKILL.md Rules

### Community 6 - "Auth Networking & Token Management"
Cohesion: 0.40
Nodes (5): AuthInterceptor, RefreshMutex, SecureDioFactory, TokenManager, TokenRefreshGateway

### Community 7 - "Error Handling (ApiResult/Failure)"
Cohesion: 0.50
Nodes (4): ApiErrorHandler, ApiResult<T>, Failure, FailureCode

### Community 8 - "Settings Administration Feature"
Cohesion: 0.67
Nodes (4): Settings Feature, SettingsRecordCubits, SettingsScreen, Settings Tests

### Community 9 - "Production Feature"
Cohesion: 0.67
Nodes (3): ProductionRecordCubits, Production Feature, ProductionScreen

### Community 10 - "Quality Feature"
Cohesion: 0.67
Nodes (3): QualityRecordCubits, Quality Feature, QualityScreen

## Knowledge Gaps
- **14 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Not enough signal to generate questions. This usually means the corpus has no AMBIGUOUS edges, no bridge nodes, no INFERRED relationships, and all communities are tightly cohesive. Add more files or run with --mode deep to extract richer edges._