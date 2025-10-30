part of '../../ok_mobile_bags.dart';

class ChangeBagSealScreen extends StatefulWidget {
  const ChangeBagSealScreen({super.key});

  static const routeName = '/change_bag_seal';

  @override
  State<ChangeBagSealScreen> createState() => _ChangeBagSealScreenState();
}

class _ChangeBagSealScreenState extends State<ChangeBagSealScreen> {
  final List<ActionReason> _reasons = [
    ActionReason.damagedSeal,
    ActionReason.unreadableSeal,
  ];

  ActionReason? selectedValue;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<BagsCubit, BagsState>(
        builder: (context, state) {
          final selectedBag = state.selectedBag;

          return Scaffold(
            appBar: GeneralAppBar(title: S.current.change_seal),
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(S.current.chosen_bag, style: AppTextStyle.smallBold()),
                  const SizedBox(height: 8),
                  ClosedBagButton(
                    bag: selectedBag!,
                    onPressed: () {
                      context.pushNamed(
                        ClosedBagDetailsScreen.routeName,
                        queryParameters: {
                          ClosedBagDetailsScreen.hideManagementOptionsParam:
                              'true',
                        },
                        pathParameters: {
                          ClosedBagDetailsScreen.selectedBagIdParam:
                              selectedBag.id!,
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  OkDropdownButton(
                    hint: S.current.choose_reason_for_seal_change,
                    reasons: _reasons,
                    onChanged: (value) {
                      setState(() {
                        selectedValue = value;
                      });
                    },
                    value: selectedValue,
                  ),
                  if (selectedValue != null) ...[
                    const AppDivider(),
                    SealScannerWidget(
                      title: S.current.scan_new_seal,
                      onScanSuccess: (newSeal) async {
                        final navigate = await context
                            .read<BagsCubit>()
                            .updateBagSeal(
                              selectedBag.id!,
                              newSeal: newSeal,
                              reason: selectedValue!,
                            );

                        if (navigate && context.mounted) {
                          context.goNamed(SealAddedDetailsScreen.routeName);
                          return true;
                        }
                        return false;
                      },
                      type: selectedBag.type,
                    ),
                  ],
                  const Spacer(),
                  NavigationButton(
                    icon: Assets.icons.back.image(package: 'ok_mobile_common'),
                    onPressed: () =>
                        context.goNamed(BagsToChangeSealListScreen.routeName),
                    text: S.current.back,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
