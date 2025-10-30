import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:ok_mobile_data/ok_mobile_data.dart';
import 'package:retrofit/retrofit.dart';

part 'pickups_api.g.dart';

@injectable
@RestApi()
abstract class PickupsAPI {
  @factoryMethod
  factory PickupsAPI(Dio dio) => _PickupsAPI(dio);

  @POST('/collectionpoint/v1/pickups')
  Future<String> addPickup(@Body() PickupMetadata pickupEntity);

  @GET('/collectionpoint/v1/pickups')
  Future<List<Pickup>> getPickups(
    @Query('collectionPointId') String collectionPointId,
  );

  @GET('/collectionpoint/v1/pickups/{pickupId}')
  Future<Pickup> getPickupData(@Path('pickupId') String id);
}
