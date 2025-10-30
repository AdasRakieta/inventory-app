import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:ok_mobile_data/ok_mobile_data.dart';
import 'package:retrofit/retrofit.dart';

part 'counting_center_api.g.dart';

@RestApi()
@injectable
abstract class CountingCenterAPI {
  @factoryMethod
  factory CountingCenterAPI(Dio dio) => _CountingCenterAPI(dio);

  @GET('/countingcenter/v1/pickups/released')
  Future<PlannedReceivalsResponseBody> getPlannedReceivals(
    @Query('countingCenterId') String countingCenterId,
  );

  @GET('/countingcenter/v1/bags')
  Future<Bag> validateBag(
    @Query('seal') String seal,
    @Query('countingCenterId') String countingCenterId,
  );

  @GET('/countingcenter/v1/pickups/received')
  Future<CollectedReceivalsResponseBody> getCollectedReceivals(
    @Query('countingCenterId') String countingCenterId,
  );

  @GET('/countingcenter/v1/pickups/{pickupId}')
  Future<Pickup> getReceivalData(@Path('pickupId') String id);

  @POST('/countingcenter/v1/receivings')
  Future<HttpResponse<String>> confirmReceival(@Body() Receival receival);
}
