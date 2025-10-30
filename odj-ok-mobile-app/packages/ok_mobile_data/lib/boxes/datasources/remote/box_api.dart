import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:ok_mobile_data/ok_mobile_data.dart';
import 'package:retrofit/retrofit.dart';

part 'box_api.g.dart';

@injectable
@RestApi()
abstract class BoxAPI {
  @factoryMethod
  factory BoxAPI(Dio dio) => _BoxAPI(dio);

  @POST('/collectionpoint/v1/boxes')
  Future<String> openBox(@Body() BoxMetadata boxEntity);

  @GET('/collectionpoint/v1/boxes/open')
  Future<List<Box>> fetchOpenBoxes(
    @Query('CollectionPointId') String collectionPointId,
  );

  @GET('/collectionpoint/v1/boxes/closed')
  Future<List<Box>> fetchClosedBoxes(
    @Query('CollectionPointId') String collectionPointId,
  );

  @PATCH('/collectionpoint/v1/boxes/{id}/label')
  Future<void> changeBoxLabel(
    @Path('id') String boxId,
    @Body() Map<String, dynamic> body,
  );

  @PATCH('/collectionpoint/v1/boxes/{id}/bags')
  Future<void> addBagsToBox(
    @Path('id') String boxId,
    @Body() Map<String, dynamic> body,
  );

  @PATCH('/collectionpoint/v1/boxes/{boxId}/bags/{bagId}')
  Future<void> removeBagFromBox(
    @Path('boxId') String boxId,
    @Path('bagId') String bagId,
  );

  @PATCH('/collectionpoint/v1/boxes/closed')
  Future<void> closeBoxes(@Body() Map<String, dynamic> body);
}
