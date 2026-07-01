import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/domain/entities/auth_user.dart';
import '../../features/auth/presentation/bloc/auth_session_cubit.dart';
import '../../features/auth/presentation/bloc/login_cubit.dart';
import '../../features/auth/presentation/bloc/logout_cubit.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/startup_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/notifications/presentation/bloc/notification_cubit.dart';
import '../../features/notifications/presentation/screens/notification_screen.dart';
import '../../features/production/presentation/screens/production_screen.dart';
import '../../features/quality/presentation/screens/production_quality_screen.dart';
import '../../features/quality/presentation/screens/quality_screen.dart';
import '../../features/quality/presentation/screens/raw_material_quality_screen.dart';
import '../../features/raw_material_entry/presentation/screens/raw_material_entry_screen.dart';
import '../../features/raw_material_entry/presentation/screens/raw_material_inventory_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../di/dependency_injection.dart';
import 'auth_guard.dart';
import 'route_requirements.dart';
import 'routes.dart';

class AppRouter {
  final _guard = AuthGuard();

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final arguments = settings.arguments;
    final requirement = routeRequirements[settings.name];
    if (requirement != null) {
      final redirect = _guard.guard(requirement);
      if (redirect != null) {
        return MaterialPageRoute<void>(
          settings: const RouteSettings(name: Routes.login),
          builder: (_) => BlocProvider(
            create: (_) => sl<LoginCubit>(),
            child: const LoginScreen(),
          ),
        );
      }
    }

    return switch (settings.name) {
      Routes.startup => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => BlocProvider.value(
          value: sl<AuthSessionCubit>(),
          child: const StartupScreen(),
        ),
      ),
      Routes.home => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) {
          if (arguments is! AuthUser) {
            return BlocProvider.value(
              value: sl<AuthSessionCubit>(),
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
      Routes.rawMaterialEntry => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const RawMaterialEntryScreen(),
      ),
      Routes.inventory => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const RawMaterialInventoryScreen(),
      ),
      Routes.quality => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const QualityScreen(),
      ),
      Routes.rawMaterialQuality => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const RawMaterialQualityScreen(),
      ),
      Routes.productionQuality => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const ProductionQualityScreen(),
      ),
      Routes.production => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const ProductionScreen(),
      ),
      Routes.settings => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const SettingsScreen(),
      ),
      Routes.notifications => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => BlocProvider(
          create: (_) => sl<NotificationCubit>(),
          child: const NotificationScreen(),
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
