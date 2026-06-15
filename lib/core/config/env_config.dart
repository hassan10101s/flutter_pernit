class EnvConfig {
  static const EnvConfig instance = EnvConfig._();

  const EnvConfig._();

  String get environmentName =>
      const String.fromEnvironment('ENV_NAME', defaultValue: 'dev');

  String get apiBaseUrl => const String.fromEnvironment('API_BASE_URL');

  String get wsBaseUrl => const String.fromEnvironment('WS_BASE_URL');

  bool get enableLogging =>
      const bool.fromEnvironment('ENABLE_LOGGING', defaultValue: true);

  bool get hasApiBaseUrl => apiBaseUrl.trim().isNotEmpty;
}
