import 'package:injectable/injectable.dart';
import 'package:ok_mobile_auth/di/di.config.dart';
import 'package:ok_mobile_common/ok_mobile_common.dart';

@InjectableInit()
void configureDependencies({required String env}) {
  getIt.init(environment: env);
}
