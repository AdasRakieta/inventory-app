part of '../ok_mobile_common.dart';

class NavigationService {
  NavigationService._();

  static final NavigationService _instance = NavigationService._();

  static NavigationService get instance => _instance;

  static GoRouter get router => _router;

  static late GoRouter _router;

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static late final List<String?> _noAuthScreens;
  static late final List<RouteBase> _routes;

  static bool _initialized = false;

  static void initRouter({
    required bool isAuthenticated,
    required String? termsRoute,
    required String? mainRoute,
    required List<List<RouteBase>> routes,
    List<List<String?>>? noAuthRoutes,
    String? noAuthScreenRoute,
  }) {
    if (!_initialized) {
      _noAuthScreens = noAuthRoutes == null
          ? <String>[]
          : noAuthRoutes.expand((items) => items).toList();

      _routes = routes.expand((items) => items).toList();
    }
    _initialized = true;

    _router = _createRouter(
      isAuthenticated: isAuthenticated,
      noAuthScreenRoute: noAuthScreenRoute,
      termsRoute: termsRoute,
      mainRoute: mainRoute,
    );
  }

  static FutureOr<String?> redirect(
    BuildContext context,
    GoRouterState state, {
    required bool isAuthenticated,
    required String? noAuthScreenRoute,
    required String? termsRoute,
    required String? mainRoute,
  }) {
    final user = getIt<AuthUsecases>().userNotifier.value;
    final goingToTerms = state.matchedLocation == termsRoute;

    if (!isAuthenticated || user == null) {
      if (_noAuthScreens.contains(state.matchedLocation)) {
        return null;
      }

      return noAuthScreenRoute;
    }

    if (!user.hasAcceptedTerms && !goingToTerms) {
      return termsRoute;
    }

    if (user.hasAcceptedTerms && goingToTerms) {
      return mainRoute;
    }

    return null;
  }

  static List<RouteBase> getRoutes() => List<RouteBase>.from(_routes);

  static GoRouter _createRouter({
    required bool isAuthenticated,
    required String? noAuthScreenRoute,
    required String? termsRoute,
    required String? mainRoute,
  }) {
    final authUsecases = getIt<AuthUsecases>();

    return GoRouter(
      navigatorKey: rootNavigatorKey,
      observers: [AppRouteObserver()],
      routes: getRoutes(),
      refreshListenable: authUsecases.userNotifier,
      redirect: (context, state) {
        return redirect(
          context,
          state,
          isAuthenticated: isAuthenticated,
          noAuthScreenRoute: noAuthScreenRoute,
          termsRoute: termsRoute,
          mainRoute: mainRoute,
        );
      },
    );
  }
}

class AppRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    LoggerService().trackTrace(
      'navigate',
      message: 'user navigation',
      severity: Severity.verbose,
      properties: {
        'route': route.settings.name ?? 'unknown',
        'previousRoute': previousRoute?.settings.name ?? 'unknown',
      },
    );
  }
}
