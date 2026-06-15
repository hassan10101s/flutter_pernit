import 'generated/app_localizations.dart';

class FailureMessageLocalizer {
  const FailureMessageLocalizer._();

  static String messageFor(AppLocalizations l10n, String messageKey) {
    return switch (messageKey) {
      'failureNetwork' => l10n.failureNetwork,
      'failureUnauthorized' => l10n.failureUnauthorized,
      'failureForbidden' => l10n.failureForbidden,
      'failureValidation' => l10n.failureValidation,
      'failureServer' => l10n.failureServer,
      'failureTimeout' => l10n.failureTimeout,
      'failureConfigurationMissing' => l10n.failureConfigurationMissing,
      _ => l10n.failureUnknown,
    };
  }
}
