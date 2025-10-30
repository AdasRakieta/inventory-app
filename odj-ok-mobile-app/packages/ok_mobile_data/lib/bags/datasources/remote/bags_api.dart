import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:ok_mobile_data/ok_mobile_data.dart';
import 'package:retrofit/retrofit.dart';

part 'bags_api.g.dart';

@injectable
@RestApi()
abstract class BagsAPI {
  @factoryMethod
  factory BagsAPI(Dio dio) => _BagsAPI(dio);

  @POST('/collectionpoint/v1/bags')
  Future<String> openNewBag(@Body() BagMetadata bag);

  @GET('/collectionpoint/v1/bags/open')
  Future<List<Bag>> fetchOpenBags(
    @Query('collectionPointId') String collectionPointId,
  );

  @GET('/collectionpoint/v1/bags/closed')
  Future<List<Bag>> fetchClosedBags(
    @Query('collectionPointId') String collectionPointId,
  );

  @PATCH('/collectionpoint/v1/bags/{id}')
  Future<void> changeBag(
    @Path('id') String bagId,
    @Body() Map<String, dynamic> body,
  );

  @POST('/collectionpoint/v1/bags/{id}/close')
  Future<void> closeAndSealBag(
    @Path('id') String bagId,
    @Body() Map<String, dynamic> body,
  );
}
