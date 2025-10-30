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
import 'package:ok_mobile_data/auth/datasources/remote/common_api.dart'
    as _i1007;
import 'package:ok_mobile_data/bags/datasources/remote/bags_api.dart' as _i229;
import 'package:ok_mobile_data/boxes/datasources/remote/box_api.dart' as _i409;
import 'package:ok_mobile_data/counting_center/datasources/counting_center_api.dart'
    as _i390;
import 'package:ok_mobile_data/ok_mobile_data.dart' as _i528;
import 'package:ok_mobile_data/pickups/datasources/remote/pickups_api.dart'
    as _i666;
import 'package:ok_mobile_data/returns/datasources/remote/datasources.dart'
    as _i195;
import 'package:ok_mobile_data/returns/datasources/remote/masterdata/masterdata_api.dart'
    as _i58;
import 'package:ok_mobile_data/returns/datasources/remote/returns/returns_api.dart'
    as _i798;
import 'package:ok_mobile_data/returns/datasources/remote/vouchers/vouchers_api.dart'
    as _i1011;
import 'package:ok_mobile_domain/ok_mobile_domain.dart' as _i680;

const String _dev = 'dev';
const String _offline = 'offline';
const String _prd = 'prd';
const String _tst = 'tst';
const String _uat = 'uat';

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.factory<_i528.DeviceConfigDatasource>(
      () => _i528.DeviceConfigDatasource(),
    );
    gh.factory<_i528.IOauthConfig>(
      () => _i528.DevOauthConfig(),
      registerFor: {_dev},
    );
    gh.lazySingleton<_i680.IMasterDataRepository>(
      () => _i528.OfflineMasterdataRepository(),
      registerFor: {_offline},
    );
    gh.factory<_i680.ILocalizationRepository>(
      () => _i528.LocalizationRepository(),
      registerFor: {_dev, _prd, _tst, _uat},
    );
    gh.factory<_i680.IAdminRepository>(
      () => _i528.AdminRepository(),
      registerFor: {_dev, _prd, _tst, _uat},
    );
    gh.factory<_i528.IOauthConfig>(
      () => _i528.OfflineOauthConfig(),
      registerFor: {_offline},
    );
    gh.factory<_i680.ICommonRepository>(
      () => _i528.OfflineCommonRepository(),
      registerFor: {_offline},
    );
    gh.factory<_i528.IOauthConfig>(
      () => _i528.UatOauthConfig(),
      registerFor: {_uat},
    );
    gh.factory<_i680.IPickupsRepository>(
      () => _i528.OfflinePickupsRepository(),
      registerFor: {_offline},
    );
    gh.factory<_i528.OauthClient>(
      () => _i528.OauthClient(gh<_i528.IOauthConfig>()),
    );
    gh.factory<_i680.IBoxRepository>(
      () => _i528.OfflineBoxRepository(),
      registerFor: {_offline},
    );
    gh.factory<_i1007.CommonAPI>(() => _i1007.CommonAPI(gh<_i361.Dio>()));
    gh.factory<_i229.BagsAPI>(() => _i229.BagsAPI(gh<_i361.Dio>()));
    gh.factory<_i409.BoxAPI>(() => _i409.BoxAPI(gh<_i361.Dio>()));
    gh.factory<_i390.CountingCenterAPI>(
      () => _i390.CountingCenterAPI(gh<_i361.Dio>()),
    );
    gh.factory<_i666.PickupsAPI>(() => _i666.PickupsAPI(gh<_i361.Dio>()));
    gh.factory<_i58.MasterDataAPI>(() => _i58.MasterDataAPI(gh<_i361.Dio>()));
    gh.factory<_i798.ReturnsAPI>(() => _i798.ReturnsAPI(gh<_i361.Dio>()));
    gh.factory<_i1011.VouchersApi>(() => _i1011.VouchersApi(gh<_i361.Dio>()));
    gh.factory<_i680.IAuthRepository>(
      () => _i528.OfflineAuthRepository(),
      registerFor: {_offline},
    );
    gh.factory<_i680.IReceivalsRepository>(
      () => _i528.OfflineReceivalsRepository(),
      registerFor: {_offline},
    );
    gh.factory<_i680.IBagsRepository>(
      () => _i528.OfflineBagsRepository(),
      registerFor: {_offline},
    );
    gh.factory<_i680.IReturnsRepository>(
      () => _i528.OfflineReturnsRepository(),
      registerFor: {_offline},
    );
    gh.factory<_i680.ICommonRepository>(
      () => _i528.CommonRepository(gh<_i1007.CommonAPI>()),
      registerFor: {_dev, _prd, _tst, _uat},
    );
    gh.factory<_i680.IPickupsRepository>(
      () => _i528.PickupsRepositoryImpl(gh<_i666.PickupsAPI>()),
      registerFor: {_dev, _prd, _tst, _uat},
    );
    gh.factory<_i528.IOauthConfig>(
      () => _i528.OauthConfig(),
      registerFor: {_prd},
    );
    gh.factory<_i680.IReturnsRepository>(
      () => _i528.ReturnsRepositoryImpl(
        gh<_i195.ReturnsAPI>(),
        gh<_i195.VouchersApi>(),
      ),
      registerFor: {_dev, _prd, _tst, _uat},
    );
    gh.factory<_i528.IOauthConfig>(
      () => _i528.TstOauthConfig(),
      registerFor: {_tst},
    );
    gh.factory<_i680.IBoxRepository>(
      () => _i528.BoxRepositoryImpl(gh<_i409.BoxAPI>()),
      registerFor: {_dev, _prd, _tst, _uat},
    );
    gh.factory<_i680.IMasterDataRepository>(
      () => _i528.MasterDataRepositoryImpl(gh<_i195.MasterDataAPI>()),
      registerFor: {_dev, _prd, _tst, _uat},
    );
    gh.factory<_i680.IReceivalsRepository>(
      () => _i528.ReceivalsRepositoryImpl(gh<_i390.CountingCenterAPI>()),
      registerFor: {_dev, _prd, _tst, _uat},
    );
    gh.factory<_i680.IBagsRepository>(
      () => _i528.BagsRepositoryImpl(gh<_i229.BagsAPI>()),
      registerFor: {_dev, _prd, _tst, _uat},
    );
    gh.factory<_i680.IAuthRepository>(
      () => _i528.AuthRepositoryImpl(gh<_i528.OauthClient>()),
      registerFor: {_dev, _prd, _tst, _uat},
    );
    return this;
  }
}
