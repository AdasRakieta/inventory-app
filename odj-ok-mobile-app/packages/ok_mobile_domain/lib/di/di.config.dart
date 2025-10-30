// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:ok_mobile_data/ok_mobile_data.dart' as _i528;
import 'package:ok_mobile_domain/ok_mobile_domain.dart' as _i680;

const String _dev = 'dev';
const String _uat = 'uat';
const String _offline = 'offline';
const String _tst = 'tst';
const String _prd = 'prd';

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerDioModule = _$RegisterDioModule();
    gh.factory<_i680.ProxyConfig>(() => _i680.ProxyConfig());
    gh.lazySingleton<_i680.AuthUsecases>(() => _i680.AuthUsecases());
    gh.factory<_i680.IDioConfig>(
      () => _i680.DevDioConfig(),
      registerFor: {_dev},
    );
    gh.factory<_i680.IDioConfig>(
      () => _i680.UatDioConfig(),
      registerFor: {_uat},
    );
    gh.factory<_i680.IDioConfig>(
      () => _i680.OfflineDioConfig(),
      registerFor: {_offline},
    );
    gh.factory<_i680.IDioConfig>(
      () => _i680.TstDioConfig(),
      registerFor: {_tst},
    );
    gh.factory<_i680.IDioConfig>(
      () => _i680.PrdDioConfig(),
      registerFor: {_prd},
    );
    gh.singleton<_i680.AppHttpClient>(() => _i680.AppHttpClient());
    gh.singleton<_i680.DeviceConfigUsecases>(
      () => _i680.DeviceConfigUsecases(gh<_i528.DeviceConfigDatasource>()),
    );
    gh.lazySingleton<_i680.PickupsUsecases>(
      () => _i680.PickupsUsecases(gh<_i680.IPickupsRepository>()),
    );
    gh.lazySingleton<_i680.BagsUsecases>(
      () => _i680.BagsUsecases(
        gh<_i680.IBagsRepository>(),
        gh<_i680.DeviceConfigUsecases>(),
      ),
    );
    gh.lazySingleton<_i680.ReturnsUsecases>(
      () => _i680.ReturnsUsecases(
        gh<_i680.IReturnsRepository>(),
        gh<_i680.DeviceConfigUsecases>(),
      ),
    );
    gh.lazySingleton<_i680.MasterDataUsecases>(
      () => _i680.MasterDataUsecases(gh<_i680.IMasterDataRepository>()),
    );
    gh.lazySingleton<_i680.AdminUsecases>(
      () => _i680.AdminUsecases(gh<_i680.IAdminRepository>()),
    );
    gh.lazySingleton<_i680.LocalizationUsecases>(
      () => _i680.LocalizationUsecases(gh<_i680.ILocalizationRepository>()),
    );
    gh.lazySingleton<_i680.ReceivalsUsecases>(
      () => _i680.ReceivalsUsecases(gh<_i680.IReceivalsRepository>()),
    );
    gh.lazySingleton<_i680.BoxUsecases>(
      () => _i680.BoxUsecases(
        gh<_i680.IBoxRepository>(),
        gh<_i680.DeviceConfigUsecases>(),
      ),
    );
    gh.factory<_i361.Dio>(() => registerDioModule.dio(gh<_i680.IDioConfig>()));
    return this;
  }
}

class _$RegisterDioModule extends _i680.RegisterDioModule {}
