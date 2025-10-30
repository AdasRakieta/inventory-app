import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

class AppBlocObserver extends BlocObserver {
  //* Uncomment this if needed more debugging
  // @override
  // void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
  //   super.onChange(bloc, change);
  //   log('AppBlocObserver onChange(${bloc.runtimeType}, $change)');
  // }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('AppBlocObserver onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }

  //* Uncomment this if needed more debugging
  // @override
  // void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
  //   super.onEvent(bloc, event);
  //   log('AppBlocObserver onEvent(${bloc.runtimeType} $event)');
  // }

  //* Uncomment this if needed more debugging
  // @override
  // void onTransition(Bloc bloc, Transition transition) {
  //   super.onTransition(bloc, transition);
  //   log('AppBlocObserver onTransition(${bloc.runtimeType} $transition)');
  // }
}
