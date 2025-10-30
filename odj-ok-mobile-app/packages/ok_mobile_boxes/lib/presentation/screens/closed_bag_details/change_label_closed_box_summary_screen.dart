import 'package:flutter/material.dart';
import 'package:ok_mobile_boxes/ok_mobile_boxes.dart';

class ChangeLabelClosedBoxSummaryScreen extends StatelessWidget {
  const ChangeLabelClosedBoxSummaryScreen({super.key});

  static const routeName = '/change_label_closed_box_summary';

  @override
  Widget build(BuildContext context) {
    return const ClosedBoxSummaryScreen(
      backRoute: ChangeBoxLabelScreen.routeName,
      buttonsBackRoute: ChangeLabelClosedBoxSummaryScreen.routeName,
    );
  }
}
