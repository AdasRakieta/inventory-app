import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:ok_mobile_data/ok_mobile_data.dart';
import 'package:retrofit/retrofit.dart';

part 'returns_api.g.dart';

@injectable
@RestApi()
abstract class ReturnsAPI {
  @factoryMethod
  factory ReturnsAPI(Dio dio) => _ReturnsAPI(dio);

  @GET('/collectionpoint/v1/manualcollections')
  Future<List<ClosedReturn>> fetchReturns(
    @Query('dateFrom') String dateFrom,
    @Query('collectionPointId') String collectionPointId,
  );

  @POST('/collectionpoint/v1/manualcollections')
  Future<ClosedReturnResponse> closeReturn(@Body() ReturnDto requestBody);
}
