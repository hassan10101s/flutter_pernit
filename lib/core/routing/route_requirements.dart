import 'routes.dart';

class RouteRequirement {
  final String routeName;
  final bool requiresLogin;
  final List<String> requiredPermissions;
  final String? businessScope;

  const RouteRequirement({
    required this.routeName,
    required this.requiresLogin,
    this.requiredPermissions = const [],
    this.businessScope,
  });
}

const routeRequirements = <String, RouteRequirement>{
  Routes.login: RouteRequirement(routeName: Routes.login, requiresLogin: false),
  Routes.home: RouteRequirement(routeName: Routes.home, requiresLogin: true),
};
