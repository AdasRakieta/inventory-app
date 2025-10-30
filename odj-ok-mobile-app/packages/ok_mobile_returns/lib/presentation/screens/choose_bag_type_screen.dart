part of '../../ok_mobile_returns.dart';

class ChooseBagTypeScreen extends StatelessWidget {
  const ChooseBagTypeScreen({
    required this.bagType,
    this.clearLastPackage = true,
    super.key,
  });

  static const routeName = '/choose_bag_type';
  static const bagTypeParam = 'bag_type';
  static const clearLastPackageParam = 'clear_last_package';

  final BagType? bagType;
  final bool clearLastPackage;

  @override
  Widget build(BuildContext context) {
    final hasSegregation =
        context
            .read<DeviceConfigCubit>()
            .state
            .collectionPointData
            ?.segregatesItems ??
        false;
    return SafeArea(
      child: BlocBuilder<ReturnsCubit, ReturnsState>(
        builder: (context, state) {
          return Scaffold(
            appBar: GeneralAppBar(title: S.current.bag_choice),
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      children: switch ((hasSegregation, bagType)) {
                        (false, _) ||
                        (_, BagType.mix) => [_buildMixButtons(context)],
                        (_, BagType.plastic) => [_buildPlasticButtons(context)],
                        (_, BagType.can) => [_buildCanButtons(context)],
                        (_, BagType.glass) => [const SizedBox.shrink()],
                        (_, null) => [
                          _buildPlasticButtons(context),
                          const AppDivider(),
                          _buildCanButtons(context),
                        ],
                      },
                    ),
                  ),
                  const AppDivider(),
                  NavigationButton(
                    icon: Assets.icons.back.image(package: 'ok_mobile_common'),
                    onPressed: () {
                      if (clearLastPackage) {
                        context.read<ReturnsCubit>().clearMostRecentPackage();
                      }
                      context.goNamed(PackageScannerScreen.routeName);
                    },
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

  Widget _buildPlasticButtons(BuildContext context) {
    return ButtonsColumn(
      buttons: [
        IconTextButton(
          fontSize: 13,
          icon: Assets.icons.add.image(package: 'ok_mobile_common'),
          onPressed: () {
            context.goNamed(
              BagScannerScreen.routeName,
              pathParameters: {
                BagScannerScreen.typeParam: BagType.plastic.name,
              },
              queryParameters: {
                clearLastPackageParam: clearLastPackage.toString(),
              },
            );
          },
          text: S.current.open_new_bag_plastic,
          color: AppColors.green,
        ),
        IconTextButton(
          fontSize: 13,
          icon: Assets.icons.bagOpen.image(
            package: 'ok_mobile_common',
            color: AppColors.lightGreen,
          ),
          onPressed: () {
            context.goNamed(
              SelectOpenBagScreen.routeName,
              queryParameters: {
                SelectOpenBagScreen.typeParam: BagType.plastic.name,
                SelectOpenBagScreen.backRouteParam:
                    ChooseBagTypeScreen.routeName,
                clearLastPackageParam: clearLastPackage.toString(),
              },
            );
          },
          text: S.current.choose_open_bag_plastic,
          color: AppColors.green,
        ),
      ],
    );
  }

  Widget _buildCanButtons(BuildContext context) {
    return ButtonsColumn(
      buttons: [
        IconTextButton(
          fontSize: 13,
          icon: Assets.icons.add.image(package: 'ok_mobile_common'),
          onPressed: () {
            context.goNamed(
              BagScannerScreen.routeName,
              pathParameters: {BagScannerScreen.typeParam: BagType.can.name},
              queryParameters: {
                clearLastPackageParam: clearLastPackage.toString(),
              },
            );
          },
          text: S.current.open_new_bag_CAN,
          color: AppColors.black,
        ),
        IconTextButton(
          fontSize: 13,
          icon: Assets.icons.bagOpen.image(
            package: 'ok_mobile_common',
            color: AppColors.lightGreen,
          ),
          onPressed: () {
            context.goNamed(
              SelectOpenBagScreen.routeName,
              queryParameters: {
                SelectOpenBagScreen.typeParam: BagType.can.name,
                clearLastPackageParam: clearLastPackage.toString(),
              },
            );
          },
          text: S.current.choose_open_bag_CAN,
          color: AppColors.black,
        ),
      ],
    );
  }

  Widget _buildMixButtons(BuildContext context) {
    return ButtonsColumn(
      buttons: [
        IconTextButton(
          fontSize: 13,
          icon: Assets.icons.add.image(package: 'ok_mobile_common'),
          onPressed: () {
            context.goNamed(
              BagScannerScreen.routeName,
              pathParameters: {BagScannerScreen.typeParam: BagType.mix.name},
              queryParameters: {
                clearLastPackageParam: clearLastPackage.toString(),
              },
            );
          },
          text: S.current.open_new_bag,
          color: AppColors.black,
        ),
        IconTextButton(
          fontSize: 13,
          icon: Assets.icons.bagOpen.image(
            package: 'ok_mobile_common',
            color: AppColors.lightGreen,
          ),
          onPressed: () {
            context.goNamed(
              SelectOpenBagScreen.routeName,
              queryParameters: {
                SelectOpenBagScreen.typeParam: BagType.mix.name,
                SelectOpenBagScreen.backRouteParam:
                    ChooseBagTypeScreen.routeName,
                clearLastPackageParam: clearLastPackage.toString(),
              },
            );
          },
          text: S.current.choose_open_bag,
          color: AppColors.black,
        ),
      ],
    );
  }
}
