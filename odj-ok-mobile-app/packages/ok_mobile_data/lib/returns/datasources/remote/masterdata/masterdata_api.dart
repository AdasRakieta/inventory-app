import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:ok_mobile_data/ok_mobile_data.dart';
import 'package:retrofit/retrofit.dart';

part 'masterdata_api.g.dart';

@injectable
@RestApi()
abstract class MasterDataAPI {
  @factoryMethod
  factory MasterDataAPI(Dio dio) => _MasterDataAPI(dio);

  @GET('/common/v1/packages')
  Future<List<MasterdataItem>> getMasterData(
    @Header('If-Modified-Since') String lastModifiedDate,
  );
}
