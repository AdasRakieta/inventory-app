// TODO enable boxes when ready
// part of '../../../ok_mobile_bags.dart';

// class ChooseBoxScreen extends StatelessWidget {
//   const ChooseBoxScreen({
//     required this.singleBagMode,
//     super.key,
//   });

//   final bool singleBagMode;
//   static const routeName = '/choose_box';
//   static const singleBagModeParam = 'single_bag_mode';

//   Future<void> _fetchData(BuildContext context) async {
//     context.read<BoxCubit>().clearSelectedBox();
//     await context.read<BoxCubit>().fetchOpenBoxes();
//   }

//   Future<bool> _onBoxSelected(BuildContext context, Box box) async {
//     context.read<BoxCubit>().selectBox(box);
//     final navigate = await context.read<BoxCubit>().addBagsToBox(
//           bags: singleBagMode
//               ? [context.read<BagsCubit>().state.selectedBag]
//               : context.read<BagsCubit>().state.bagsToShow,
//         );
//     if (context.mounted && navigate) {
//       context.read<BagsCubit>().clearBagsToAddToBox();
//       context.read<BagsCubit>().clearSelectedBags();
//       context.goNamed(
//         OpenBoxSummaryScreen.routeName,
//         queryParameters: {
//           OpenBoxSummaryScreen.backRouteParam: ChooseBoxScreen.routeName,
//         },
//       );
//       return true;
//     }
//     return false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     _fetchData(context);
//     final selectedBags = singleBagMode
//         ? [context.read<BagsCubit>().state.selectedBag]
//         : context.read<BagsCubit>().state.selectedBags;
//     return SafeArea(
//       child: Scaffold(
//         appBar: GeneralAppBar(
//           title: S.current.add_to_box,
//         ),
//         body: BlocBuilder<BoxCubit, BoxState>(
//           builder: (context, state) {
//             return Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   if (selectedBags.length == 1)
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           S.current.chosen_bag,
//                           style:
// Theme.of(context).textTheme.bodySmall!.copyWith(
//                                     color: AppColors.black,
//                                     fontWeight: FontWeight.w700,
//                                   ),
//                         ),
//                         const SizedBox(height: 4),
//                         ClosedBagSummaryCard(
//                           bag: selectedBags.first,
//                           considerSeal: true,
//                         ),
//                       ],
//                     )
//                   else
//                     SummaryWidget(
//                       numberToShow: selectedBags.length,
//                       title: S.current.selected_bags,
//                       onPressed: () {
//                         context.goNamed(ChosenBagsToAddToBoxScreen.routeName);
//                       },
//                       enabled: selectedBags.isNotEmpty,
//                     ),
//                   const AppDivider(),
//                   BoxScannerWidget(
//                     upperTitle: S.current.scan_box_label_or_pick_from_list,
//                     onScanSuccess: (value) async {
//                       final box =
//                           context.read<BoxCubit>().checkIfOpenBoxExists(value);
//                       if (box != null) {
//                         return _onBoxSelected(context, box);
//                       }
//                       return false;
//                     },
//                   ),
//                   const AppDivider(),
//                   Expanded(
//                     child: state.openBoxes.isEmpty &&
//                             state.generalState == GeneralState.loaded
//                         ? NoItemsWidget(
//                             title: S.current.no_boxes_to_display,
//                           )
//                         : SingleChildScrollView(
//                             child: ButtonsColumn(
//                               buttons: List.generate(
//                                 state.openBoxes.length,
//                                 (index) {
//                                   final box = state.openBoxes[index];

// ignore_for_file: lines_longer_than_80_chars disabled boxes

//                                   return ChooseOpenItemButton(
//                                     title: box.label,
//                                     numberToShow: box.bags.length,
//                                     color: AppColors.darkGreen,
//                                     isSelected: box.id == state.selectedBox.id,
//                                     onCheckPressed: () {
//                                       _onBoxSelected(context, box);
//                                     },
//                                     onDetailsPressed: () {
//                                       context
//                                           .read<BoxCubit>()
//                                           .selectBox(box, showSnackBar: false);
//                                       context.goNamed(
//                                         OpenBoxSummaryScreen.routeName,
//                                         queryParameters: {
//                                           OpenBoxSummaryScreen.backRouteParam:
//                                               ChooseBoxScreen.routeName,
//                                         },
//                                       );
//                                     },
//                                   );
//                                 },
//                               ),
//                             ),
//                           ),
//                   ),
//                   Column(
//                     children: [
//                       const AppDivider(),
//                       IconTextButton(
//                         icon: Assets.icons.back.image(
//                           package: 'ok_mobile_common',
//                         ),
//                         onPressed: () {
//                           context.goNamed(
//                             BagsToAddToBoxListScreen.routeName,
//                           );
//                         },
//                         text: S.current.back,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
