# Pernit ERP

Pernit ERP mobile frontend built with Flutter for Android and iOS.

## Architecture

This project follows the rules in `skill-addnewfeature/SKILL.md`:

- Clean Architecture: Domain -> Data -> Presentation.
- Cubit-only state management with sealed states and Equatable.
- Dio is used only inside remote data sources.
- Tokens are stored only in FlutterSecureStorage.
- Official Flutter localization is used for Arabic and English.
- No Freezed, Retrofit, easy_localization, or generated Cubits/UI.

## Run

Provide environment values at build/run time:

```powershell
flutter run --dart-define=API_BASE_URL=https://your-api-domain.com
```

Optional values:

```powershell
--dart-define=ENV_NAME=dev
--dart-define=WS_BASE_URL=wss://your-ws-domain.com
--dart-define=ENABLE_LOGGING=true
```

## Verify

```powershell
flutter analyze
flutter test
```
