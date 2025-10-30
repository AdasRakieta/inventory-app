import 'package:flutter/material.dart';
import 'package:ok_mobile_boxes/ok_mobile_boxes.dart';

class AddBagsOpenBoxSummaryScreen extends StatelessWidget {
  const AddBagsOpenBoxSummaryScreen({super.key});

  static const routeName = '/add_bags_open_box_summary';

  @override
  Widget build(BuildContext context) {
    return const OpenBoxSummaryScreen(
      backRoute: AddBagsScreen.routeName,
      buttonsBackRoute: AddBagsOpenBoxSummaryScreen.routeName,
    );
  }
}
