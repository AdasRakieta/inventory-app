import 'package:injectable/injectable.dart';
import 'package:ok_mobile_common/ok_mobile_common.dart';
import 'package:ok_mobile_domain/di/di.config.dart';

@InjectableInit()
void configureDependencies({required String env}) {
  getIt.init(environment: env);
}
