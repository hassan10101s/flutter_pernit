import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/navigation_extensions.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/localization/failure_message_localizer.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/routing/routes.dart';
import '../../../../design_system/forms/pernit_text_field.dart';
import '../../../../design_system/tokens/pernit_colors.dart';
import '../../../../design_system/tokens/pernit_font_weights.dart';
import '../../../../design_system/widgets/pernit_button.dart';
import '../bloc/login_cubit.dart';
import '../bloc/login_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          context.pushReplacementNamed(Routes.home);
        }

        if (state is LoginFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                FailureMessageLocalizer.messageFor(
                  l10n,
                  state.failure.messageKey,
                ),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final failure = state is LoginFailure ? state.failure : null;
        final isSubmitting = state is LoginSubmitting;

        return Scaffold(
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _PernitMark(),
                        verticalSpace(28),
                        Text(
                          l10n.loginTitle,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: PernitColors.textStrong,
                                fontWeight: PernitFontWeights.bold,
                              ),
                        ),
                        verticalSpace(8),
                        Text(
                          l10n.loginSubtitle,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: PernitColors.textMuted,
                                height: 1.4,
                              ),
                        ),
                        verticalSpace(32),
                        PernitTextField(
                          controller: _usernameController,
                          label: l10n.usernameLabel,
                          hint: l10n.usernameHint,
                          prefixIcon: Icons.person_outline_rounded,
                          errorText: _fieldErrorText(l10n, failure, 'username'),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.usernameRequired;
                            }
                            return null;
                          },
                        ),
                        verticalSpace(16),
                        PernitTextField(
                          controller: _passwordController,
                          label: l10n.passwordLabel,
                          hint: l10n.passwordHint,
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          errorText: _fieldErrorText(l10n, failure, 'password'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.passwordRequired;
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) => _submit(context),
                        ),
                        verticalSpace(24),
                        PernitButton(
                          label: isSubmitting
                              ? l10n.loggingInButton
                              : l10n.loginButton,
                          isLoading: isSubmitting,
                          onPressed: () => _submit(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<LoginCubit>().login(
      username: _usernameController.text,
      password: _passwordController.text,
    );
  }

  String? _fieldErrorText(
    AppLocalizations l10n,
    Failure? failure,
    String fieldName,
  ) {
    final fieldErrors = failure?.fieldErrors[fieldName];
    if (fieldErrors == null || fieldErrors.isEmpty) {
      return null;
    }

    return switch (fieldErrors.first) {
      'usernameRequired' => l10n.usernameRequired,
      'passwordRequired' => l10n.passwordRequired,
      _ => FailureMessageLocalizer.messageFor(l10n, failure!.messageKey),
    };
  }
}

class _PernitMark extends StatelessWidget {
  const _PernitMark();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: PernitColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.factory_outlined,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}
