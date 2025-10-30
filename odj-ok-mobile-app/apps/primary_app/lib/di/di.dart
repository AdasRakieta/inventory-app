import 'package:injectable/injectable.dart';
import 'package:ok_mobile_admin/di/di.dart' as admin_di;
import 'package:ok_mobile_app/di/di.config.dart';
import 'package:ok_mobile_auth/di/di.dart' as auth_di;
import 'package:ok_mobile_bags/di/di.dart' as bags_di;
// import 'package:ok_mobile_boxes/di/di.dart' as boxes_di;// TODO enable boxes when ready
import 'package:ok_mobile_common/di/di.dart' as common_di;
import 'package:ok_mobile_common/ok_mobile_common.dart';
import 'package:ok_mobile_counting_center/di/di.dart' as counting_center_di;
import 'package:ok_mobile_data/di/di.dart' as data_di;
import 'package:ok_mobile_domain/di/di.dart' as domain_di;
import 'package:ok_mobile_pickups/di/di.dart' as pickups_di;
import 'package:ok_mobile_returns/di/di.dart' as returns_di;
import 'package:ok_mobile_translations/di/di.dart' as translations_di;

@InjectableInit()
void configureDependencies({required String env}) =>
    getIt.init(environment: env);

void configureAllPackagesDependencies({required String env}) {
  common_di.configureDependencies(env: env);
  auth_di.configureDependencies(env: env);
  data_di.configureDependencies(env: env);
  domain_di.configureDependencies(env: env);
  returns_di.configureDependencies(env: env);
  translations_di.configureDependencies(env: env);
  bags_di.configureDependencies(env: env);
  admin_di.configureDependencies(env: env);
  // boxes_di.configureDependencies(env: env);// TODO enable boxes when ready
  pickups_di.configureDependencies(env: env);
  counting_center_di.configureDependencies(env: env);

  configureDependencies(env: env);
}
