// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:ok_mobile_common/ok_mobile_common.dart' as _i431;
import 'package:ok_mobile_domain/ok_mobile_domain.dart' as _i680;

const String _uat = 'uat';
const String _dev = 'dev';
const String _offline = 'offline';
const String _prd = 'prd';
const String _tst = 'tst';

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.singleton<_i431.AppConfigProvider>(() => _i431.AppConfigProvider.new());
    gh.singleton<_i431.PermissionService>(() => _i431.PermissionService());
    gh.factory<_i431.ILoggerConfig>(
      () => _i431.UatLoggerConfig(),
      registerFor: {_uat},
    );
    gh.factory<_i431.ILoggerConfig>(
      () => _i431.DevLoggerConfig(),
      registerFor: {_dev},
    );
    gh.factory<_i431.ILoggerConfig>(
      () => _i431.OfflineLoggerConfig(),
      registerFor: {_offline},
    );
    gh.factory<_i431.DeviceConfigCubit>(
      () => _i431.DeviceConfigCubit(gh<_i680.DeviceConfigUsecases>()),
    );
    gh.factory<_i431.ILoggerConfig>(
      () => _i431.PrdLoggerConfig(),
      registerFor: {_prd},
    );
    gh.factory<_i431.ILoggerConfig>(
      () => _i431.TstLoggerConfig(),
      registerFor: {_tst},
    );
    return this;
  }
}
