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
  Routes.startup: RouteRequirement(
    routeName: Routes.startup,
    requiresLogin: false,
  ),
  Routes.login: RouteRequirement(routeName: Routes.login, requiresLogin: false),
  Routes.home: RouteRequirement(routeName: Routes.home, requiresLogin: true),
  Routes.rawMaterialEntry: RouteRequirement(
    routeName: Routes.rawMaterialEntry,
    requiresLogin: true,
  ),
  Routes.inventory: RouteRequirement(
    routeName: Routes.inventory,
    requiresLogin: true,
  ),
  Routes.quality: RouteRequirement(
    routeName: Routes.quality,
    requiresLogin: true,
  ),
  Routes.production: RouteRequirement(
    routeName: Routes.production,
    requiresLogin: true,
  ),
  Routes.settings: RouteRequirement(
    routeName: Routes.settings,
    requiresLogin: true,
  ),
  Routes.notifications: RouteRequirement(
    routeName: Routes.notifications,
    requiresLogin: true,
  ),
};
