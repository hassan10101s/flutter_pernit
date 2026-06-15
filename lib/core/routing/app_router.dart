import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/bloc/login_cubit.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../di/dependency_injection.dart';
import 'routes.dart';

class AppRouter {
  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return switch (settings.name) {
      Routes.home => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const HomeScreen(),
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
