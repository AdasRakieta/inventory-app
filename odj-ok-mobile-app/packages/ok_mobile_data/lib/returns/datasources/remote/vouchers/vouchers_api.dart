import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:ok_mobile_data/ok_mobile_data.dart';
import 'package:retrofit/retrofit.dart';

part 'vouchers_api.g.dart';

@injectable
@RestApi()
abstract class VouchersApi {
  @factoryMethod
  factory VouchersApi(Dio dio) => _VouchersApi(dio);

  @POST('/collectionpoint/v1/vouchers/{id}/audit')
  Future<String> createVoucherAuditEntry(
    @Path('id') String voucherId,
    @Body() VoucherAuditRequest requestBody,
  );
}
