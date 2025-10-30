// TODO enable boxes when ready
// part of '../../../ok_mobile_bags.dart';

// class ChosenBagsToAddToBoxScreen extends StatelessWidget {
//   const ChosenBagsToAddToBoxScreen({
//     super.key,
//   });

//   static const routeName = '/chosen_bags_to_add_to_box';

//   @override
//   Widget build(BuildContext context) {
//     final segregation = context
//         .read<DeviceConfigCubit>()
//         .state
//         .collectionPointData!
//         .segregatesItems;

//     return SafeArea(
//       child: BlocBuilder<BagsCubit, BagsState>(
//         builder: (context, state) {
//           return Scaffold(
//             appBar: GeneralAppBar(
//               title: S.current.selected_bags,
//             ),
//             body: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 children: [
//                   SimpleSummaryWidget(
//                     title: S.current.summary,
//                     quantity: state.selectedBags.length,
//                   ),
//                   const AppDivider(),
//                   if (segregation) ...[
//                     PackageTypeFilters(
//                       selectedBagTypes: const [],
//                       onPetFilterChanged: (value) => context
//                           .read<BagsCubit>()
//                           .filterSelectedBags(BagType.pet, value: value!),
//                       onCanFilterChanged: (value) => context
//                           .read<BagsCubit>()
//                           .filterSelectedBags(BagType.can, value: value!),
//                     ),
//                     const SizedBox(
//                       height: 8,
//                     ),
//                   ],
//                   Expanded(
//                     child: CloseableBagButtonList(
//                       bags: state.selectedBags,
//                       onRemove: (bag) {
//                         context.read<BagsCubit>().unselectBag(bag);
//                       },
//                     ),
//                   ),
//                   const AppDivider(),
//                   IconTextButton(
//                     icon: Assets.icons.back.image(
//                       package: 'ok_mobile_common',
//                     ),
//                     onPressed: () {
//                       context.goNamed(
//                         ChooseBoxScreen.routeName,
//                         queryParameters: {
//                           ChooseBoxScreen.singleBagModeParam: 'false',
//                         },
//                       );
//                     },
//                     text: S.current.back,
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
