import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/navigation_extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../design_system/tokens/pernit_colors.dart';
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
    return BlocListener<AuthSessionCubit, AuthSessionState>(
      listener: (context, state) {
        switch (state) {
          case AuthSessionAuthenticated(session: final session):
            context.pushNamedAndRemoveAll(
              Routes.home,
              arguments: session.user,
            );
          case AuthSessionUnauthenticated():
            context.pushNamedAndRemoveAll(Routes.login);
          case AuthSessionInitial() || AuthSessionChecking():
            break;
        }
      },
      child: const Scaffold(
        backgroundColor: PernitColors.background,
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      ),
    );
  }
}
