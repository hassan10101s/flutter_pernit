import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/extensions/navigation_extensions.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/routing/routes.dart';
import '../../../../design_system/tokens/pernit_colors.dart';
import '../../../../design_system/tokens/pernit_font_weights.dart';
import '../bloc/auth_session_cubit.dart';
import '../bloc/auth_session_state.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthSessionCubit>().checkSession();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<AuthSessionCubit, AuthSessionState>(
      listener: (context, state) {
        switch (state) {
          case AuthSessionAuthenticated(session: final session):
            context.pushNamedAndRemoveAll(Routes.home, arguments: session.user);
          case AuthSessionUnauthenticated():
            context.pushNamedAndRemoveAll(Routes.login);
          case AuthSessionInitial() || AuthSessionChecking():
            break;
        }
      },
      child: Scaffold(
        backgroundColor: PernitColors.background,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(28.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 68.r,
                    height: 68.r,
                    decoration: BoxDecoration(
                      color: PernitColors.surface,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: PernitColors.border),
                    ),
                    child: Icon(
                      Icons.verified_user_outlined,
                      color: PernitColors.primary,
                      size: 34.r,
                    ),
                  ),
                  verticalSpace(18),
                  Text(
                    l10n.appTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: PernitColors.textStrong,
                      fontWeight: PernitFontWeights.bold,
                    ),
                  ),
                  verticalSpace(20),
                  SizedBox(
                    width: 144.w,
                    child: const LinearProgressIndicator(minHeight: 3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
