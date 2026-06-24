import '../../features/auth/presentation/bloc/auth_session_cubit.dart';
import '../../features/auth/presentation/bloc/auth_session_state.dart';
import '../di/dependency_injection.dart';
import 'route_requirements.dart';
import 'routes.dart';

class AuthGuard {
  String? guard(RouteRequirement requirement) {
    if (!requirement.requiresLogin) {
      return null;
    }

    final cubit = sl<AuthSessionCubit>();
    final state = cubit.state;
    if (state is AuthSessionAuthenticated) {
      return null;
    }

    return Routes.login;
  }
}
