import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:local_session_timeout/local_session_timeout.dart';
import 'package:ok_mobile_admin/ok_mobile_admin.dart';
import 'package:ok_mobile_app/config/app_themes.dart';
import 'package:ok_mobile_app/services/app_system_ui_wrapper.dart';
import 'package:ok_mobile_app/services/global_overlay_service.dart';
import 'package:ok_mobile_app/services/timeout_manager.dart';
import 'package:ok_mobile_auth/ok_mobile_auth.dart';
import 'package:ok_mobile_bags/ok_mobile_bags.dart';
// import 'package:ok_mobile_boxes/ok_mobile_boxes.dart'; // TODO enable boxes when ready
import 'package:ok_mobile_common/ok_mobile_common.dart';
import 'package:ok_mobile_counting_center/ok_mobile_counting_center.dart';
import 'package:ok_mobile_pickups/ok_mobile_pickups.dart';
import 'package:ok_mobile_returns/ok_mobile_returns.dart';
import 'package:ok_mobile_translations/ok_mobile_translations.dart';

class AppWidget extends StatelessWidget {
  AppWidget({this.supportedLocales, super.key});

  final List<Locale>? supportedLocales;
  final GlobalKey<ScaffoldMessengerState> scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (context) => getIt<AuthCubit>()),
        BlocProvider<UserCubit>(create: (context) => getIt<UserCubit>()),
        BlocProvider<LocalizationCubit>(
          create: (context) => getIt<LocalizationCubit>(),
        ),
        BlocProvider<ReturnsCubit>(create: (context) => getIt<ReturnsCubit>()),
        BlocProvider<BagsCubit>(create: (context) => getIt<BagsCubit>()),
        BlocProvider<MasterDataCubit>(
          create: (context) => getIt<MasterDataCubit>(),
        ),
        BlocProvider<AdminCubit>(create: (context) => getIt<AdminCubit>()),
        // TODO enable boxes when ready
        // BlocProvider(
        //   create: (context) => getIt<BoxCubit>(),
        // ),
        BlocProvider(create: (context) => getIt<PickupsCubit>()),
        BlocProvider(create: (context) => getIt<ReceivalsCubit>()),
        BlocProvider(create: (context) => getIt<DeviceConfigCubit>()),
      ],
      child: Builder(
        builder: (context) {
          NavigationService.initRouter(
            isAuthenticated: context.select<AuthCubit, bool>(
              (cubit) =>
                  cubit.state.authStatus == AuthStatus.authenticated ||
                  cubit.state.authStatus == AuthStatus.authenticatedLoading,
            ),
            routes: [
              OkMobileAdminPackageRoutes.routes,
              OkMobileAuthPackageRoutes.routes,
              OkMobileBagsPackageRoutes.routes,
              // OkMobileBoxesPackageRoutes.routes,// TODO enable boxes when ready
              OkMobileCountingCenterPackageRoutes.routes,
              OkMobilePickupsPackageRoutes.routes,
              OkMobileReturnsPackageRoutes.routes,
            ],
            noAuthRoutes: [
              OkMobileAuthPackageRoutes.routes
                  .map((item) => item.name)
                  .toList(),
            ],
            noAuthScreenRoute: OkSplashScreen.routeName,
            termsRoute: TermsAndConditionsScreen.routeName,
            mainRoute: MainScreen.routeName,
          );
          final router = NavigationService.router;

          TimeoutManager().initialize(context);

          return SessionTimeoutManager(
            sessionStateStream:
                TimeoutManager().sessionStateStreamController.stream,
            sessionConfig: TimeoutManager().sessionConfig,
            child: GlobalLoaderOverlay(
              duration: const Duration(milliseconds: 100),
              overlayWidgetBuilder: (progress) {
                return const Center(child: GlobalLoaderSpinner());
              },
              child: BlocBuilder<LocalizationCubit, LocalizationState>(
                builder: (context, state) {
                  GlobalOverlayService.showLoader(
                    context,
                    authStatus: context.watch<AuthCubit>().state.authStatus,
                    appStates: [
                      context.watch<MasterDataCubit>().state,
                      context.watch<ReturnsCubit>().state,
                      context.watch<BagsCubit>().state,
                      context.watch<UserCubit>().state,
                      context.watch<AdminCubit>().state,
                      // context.watch<BoxCubit>().state,// TODO enable boxes when ready
                      context.watch<PickupsCubit>().state,
                      context.watch<ReceivalsCubit>().state,
                      context.watch<DeviceConfigCubit>().state,
                    ],
                  );

                  GlobalOverlayService.showSnackBar(
                    scaffoldKey,
                    authCubit: context.watch<AuthCubit>(),
                    cubits: [
                      context.watch<MasterDataCubit>(),
                      context.watch<ReturnsCubit>(),
                      context.watch<BagsCubit>(),
                      context.watch<UserCubit>(),
                      context.watch<AdminCubit>(),
                      // context.watch<BoxCubit>(),// TODO enable boxes when ready
                      context.watch<PickupsCubit>(),
                      context.watch<ReceivalsCubit>(),
                      context.watch<DeviceConfigCubit>(),
                    ],
                  );

                  return AppSystemUiWrapper(
                    child: MaterialApp.router(
                      key: ValueKey(state.currentLocale),
                      scaffoldMessengerKey: scaffoldKey,
                      debugShowCheckedModeBanner: false,
                      theme: AppThemes.appLightTheme,
                      locale: state.currentLocale,
                      localizationsDelegates: const [
                        S.delegate,
                        GlobalCupertinoLocalizations.delegate,
                        GlobalMaterialLocalizations.delegate,
                        GlobalWidgetsLocalizations.delegate,
                      ],
                      supportedLocales:
                          supportedLocales ??
                          const [
                            Locale('de', ''),
                            Locale('en', ''),
                            Locale('pl', ''),
                            Locale('uk', ''),
                          ],
                      routeInformationProvider: router.routeInformationProvider,
                      routeInformationParser: router.routeInformationParser,
                      routerDelegate: router.routerDelegate,
                      builder: (context, child) {
                        return Localizations.override(
                          context: context,
                          locale: state.currentLocale,
                          child: child,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
