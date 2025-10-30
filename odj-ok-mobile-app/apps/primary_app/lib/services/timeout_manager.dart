import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_session_timeout/local_session_timeout.dart';
import 'package:ok_mobile_auth/ok_mobile_auth.dart';

class TimeoutManager {
  factory TimeoutManager() {
    return _instance;
  }

  TimeoutManager._internal();

  static final TimeoutManager _instance = TimeoutManager._internal();

  late SessionConfig sessionConfig;
  late StreamSubscription<SessionTimeoutState> sessionSubscription;
  late BuildContext internalContext;
  late AppLifecycleListener appLifecycleListener;
  StreamController<SessionState> sessionStateStreamController =
      StreamController<SessionState>();
  bool isInitialized = false;
  bool isForeground = true;

  void initialize(BuildContext context) {
    internalContext = context;

    if (isInitialized) return;

    sessionStateStreamController.onListen = () {
      sessionStateStreamController.sink.add(SessionState.startListening);
    };

    sessionConfig = SessionConfig(
      invalidateSessionForAppLostFocus: const Duration(minutes: 5),
      invalidateSessionForUserInactivity: const Duration(minutes: 5),
    );

    sessionSubscription = sessionConfig.stream.listen((
      SessionTimeoutState timeoutEvent,
    ) {
      _handleInactivity();
    });

    appLifecycleListener = AppLifecycleListener(
      onShow: () {
        isForeground = true;
      },
      onResume: () {
        isForeground = true;
      },
      onHide: () {
        isForeground = false;
      },
      onPause: () {
        isForeground = false;
      },
    );

    isInitialized = true;
  }

  Future<void> _handleInactivity() async {
    if (isForeground) {
      if (internalContext.read<AuthCubit>().state.authStatus ==
          AuthStatus.authenticated) {
        final shouldLogout = await internalContext.read<AuthCubit>().signOut();
        if (internalContext.mounted && shouldLogout) {
          await LogoutHelper.onLogoutCleanup(internalContext);
          await sessionSubscription.cancel();
          appLifecycleListener.dispose();
          isInitialized = false;
        }
        sessionStateStreamController.sink.add(SessionState.startListening);
      }
    }
  }
}
