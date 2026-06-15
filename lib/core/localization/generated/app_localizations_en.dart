// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Pernit ERP';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle =>
      'Sign in to continue to the Pernit ERP workspace.';

  @override
  String get usernameLabel => 'Username';

  @override
  String get usernameHint => 'Enter your username';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get loginButton => 'Log in';

  @override
  String get loggingInButton => 'Signing in';

  @override
  String get usernameRequired => 'Username is required.';

  @override
  String get passwordRequired => 'Password is required.';

  @override
  String get failureNetwork => 'Check your internet connection and try again.';

  @override
  String get failureUnauthorized => 'The username or password is incorrect.';

  @override
  String get failureForbidden =>
      'You do not have permission to access this area.';

  @override
  String get failureValidation => 'Please review the highlighted fields.';

  @override
  String get failureServer => 'The server could not complete the request.';

  @override
  String get failureTimeout => 'The request took too long. Please try again.';

  @override
  String get failureConfigurationMissing =>
      'The API URL is not configured for this build.';

  @override
  String get failureUnknown => 'Something went wrong. Please try again.';

  @override
  String get homeTitle => 'Home';

  @override
  String get homeEmptyTitle => 'Pernit ERP';

  @override
  String get homeEmptySubtitle => 'The workspace is ready for the next module.';
}
