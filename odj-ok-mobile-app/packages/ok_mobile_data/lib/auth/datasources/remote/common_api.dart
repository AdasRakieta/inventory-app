import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:ok_mobile_common/ok_mobile_common.dart';
import 'package:ok_mobile_data/ok_mobile_data.dart';
import 'package:ok_mobile_domain/ok_mobile_domain.dart';
import 'package:retrofit/retrofit.dart';

part 'common_api.g.dart';

@injectable
@RestApi()
abstract class CommonAPI {
  @factoryMethod
  factory CommonAPI(Dio dio) = _CommonAPI;

  @GET('/common/v1/currentuser')
  Future<ContractorUser> getCurrentUser();

  @POST('/common/v1/currentuser/acceptterms')
  Future<void> acceptTermsAndConditions();

  @GET('/common/v1/contractors')
  Future<ContractorData> getContractorByCode(
    @Query('contractorCode') String contractorCode,
  );

  @GET('/common/v1/contractors/{id}/collectionpoints')
  Future<CollectionPointData> getCollectionPointByCode(
    @Path('id') String contractorId,
    @Query('collectionPointCode') String collectionPointCode,
  );

  @GET('/common/v1/configuration')
  Future<RemoteConfiguration> getRemoteConfiguration(
    @Header('If-Modified-Since') String lastModifiedDate,
  );

  @GET('/common/v1/mobiledevices/{imei}')
  Future<MobileDeviceConfig> getDeviceConfigurationByImei(
    @Path('imei') String imei,
  );

  @GET('/common/v1/contractors/{id}/logo')
  @DioResponseType(ResponseType.bytes)
  Future<HttpResponse<List<int>>> downloadLogoBytes(
    @Path('id') String contractorId,
    @Header('If-Modified-Since') String? lastModifiedDate,
  );
}
