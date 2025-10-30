import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:ok_mobile_bags/ok_mobile_bags.dart';
// import 'package:ok_mobile_boxes/ok_mobile_boxes.dart';// TODO enable boxes when ready
import 'package:ok_mobile_common/ok_mobile_common.dart';
import 'package:ok_mobile_counting_center/ok_mobile_counting_center.dart';
import 'package:ok_mobile_data/ok_mobile_data.dart';
import 'package:ok_mobile_datawedge_scanner/scanwedge.dart';
import 'package:ok_mobile_domain/ok_mobile_domain.dart';
import 'package:ok_mobile_returns/ok_mobile_returns.dart';
import 'package:ok_mobile_translations/ok_mobile_translations.dart';
import 'package:permission_handler/permission_handler.dart';

part 'package:ok_mobile_scanner/presentation/widgets/bag_scanner_widget.dart';
part 'package:ok_mobile_scanner/presentation/widgets/base_scanner_widget.dart';
part 'package:ok_mobile_scanner/presentation/widgets/box_scanner_widget.dart';
part 'package:ok_mobile_scanner/presentation/widgets/camera_scanner_overlay.dart';
part 'package:ok_mobile_scanner/presentation/widgets/camera_scanner_wrapper.dart';
part 'package:ok_mobile_scanner/presentation/widgets/cc_seal_scanner_widget.dart';
part 'package:ok_mobile_scanner/presentation/widgets/choose_bag_scanner_widget.dart';
part 'package:ok_mobile_scanner/presentation/widgets/code_text_field.dart';
part 'package:ok_mobile_scanner/presentation/widgets/double_scanner_code_text_field.dart';
part 'package:ok_mobile_scanner/presentation/widgets/double_scanner_widget.dart';
part 'package:ok_mobile_scanner/presentation/widgets/package_scanner_widget.dart';
part 'package:ok_mobile_scanner/presentation/widgets/printer_scanner_widget.dart';
part 'package:ok_mobile_scanner/presentation/widgets/seal_scanner_widget.dart';
part 'package:ok_mobile_scanner/presentation/widgets/search_bag_scanner_widget.dart';
part 'package:ok_mobile_scanner/services/scan_manager.dart';
