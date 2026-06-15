import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/domain/entities/auth_user.dart';
import '../../features/auth/presentation/bloc/auth_session_cubit.dart';
import '../../features/auth/presentation/bloc/login_cubit.dart';
import '../../features/auth/presentation/bloc/logout_cubit.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/startup_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../di/dependency_injection.dart';
import 'routes.dart';

class AppRouter {
  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final arguments = settings.arguments;

    return switch (settings.name) {
      Routes.startup => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => BlocProvider(
          create: (_) => sl<AuthSessionCubit>(),
          child: const StartupScreen(),
        ),
      ),
      Routes.home => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) {
          if (arguments is! AuthUser) {
            return BlocProvider(
              create: (_) => sl<AuthSessionCubit>(),
              child: const StartupScreen(),
            );
          }

          return BlocProvider(
            create: (_) => sl<LogoutCubit>(),
            child: HomeScreen(user: arguments),
          );
        },
      ),
      Routes.login => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => BlocProvider(
          create: (_) => sl<LoginCubit>(),
          child: const LoginScreen(),
        ),
      ),
      _ => MaterialPageRoute<void>(
        settings: const RouteSettings(name: Routes.login),
        builder: (_) => BlocProvider(
          create: (_) => sl<LoginCubit>(),
          child: const LoginScreen(),
        ),
      ),
    };
  }
}
