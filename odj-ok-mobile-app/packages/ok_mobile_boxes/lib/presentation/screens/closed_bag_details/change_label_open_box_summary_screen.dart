import 'package:flutter/material.dart';
import 'package:ok_mobile_boxes/ok_mobile_boxes.dart';

class ChangeLabelOpenBoxSummaryScreen extends StatelessWidget {
  const ChangeLabelOpenBoxSummaryScreen({super.key});

  static const routeName = '/change_label_open_box_summary';

  @override
  Widget build(BuildContext context) {
    return const OpenBoxSummaryScreen(
      backRoute: ChangeBoxLabelScreen.routeName,
      buttonsBackRoute: ChangeLabelOpenBoxSummaryScreen.routeName,
    );
  }
}
