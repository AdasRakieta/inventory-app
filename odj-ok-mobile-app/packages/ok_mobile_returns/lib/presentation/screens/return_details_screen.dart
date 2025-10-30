part of '../../ok_mobile_returns.dart';

class ReturnDetailsScreen extends StatefulWidget {
  const ReturnDetailsScreen({
    required this.backRoute,
    this.pathParameters,
    super.key,
  });

  static const routeName = '/return_details';
  static const backRouteParam = 'back_route_param';
  final String? backRoute;
  final Map<String, String>? pathParameters;

  @override
  State<ReturnDetailsScreen> createState() => _ReturnDetailsScreenState();
}

class _ReturnDetailsScreenState extends State<ReturnDetailsScreen> {
  @override
  void initState() {
    super.initState();

    context.read<BagsCubit>().fetchAllBags();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BagsCubit, BagsState>(
      builder: (context, bagsState) {
        return BlocBuilder<ReturnsCubit, ReturnsState>(
          builder: (context, state) {
            return SafeArea(
              child: Scaffold(
                appBar: GeneralAppBar(title: S.current.return_summary),
                body: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SimpleSummaryWidget(
                        title: S.current.current_return,
                        quantity: state.openedReturn.numberOfPackages,
                      ),
                      const AppDivider(),
                      const SizedBox(height: 8),
                      Text(
                        S.current.returning_packages_list,
                        style: AppTextStyle.smallBold(),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child:
                            state.openedReturn.packages.isEmpty ||
                                context.read<BagsCubit>().state.allBags.isEmpty
                            ? NoItemsWidget(
                                title: S.current.no_packeges_in_return,
                              )
                            : SingleChildScrollView(
                                child: ButtonsColumn(
                                  buttons: List.generate(
                                    state.openedReturn.packages.length,
                                    (index) {
                                      final package =
                                          state.openedReturn.packages[index];
                                      final bag = context
                                          .read<BagsCubit>()
                                          .state
                                          .allBags
                                          .firstWhereOrNull(
                                            (element) =>
                                                element.id == package.bagId,
                                          );
                                      final isEditEnabled =
                                          bag?.state == BagState.open ||
                                          (package.type?.isGlass() ?? false);

                                      return PackageDetailsCard(
                                        bagIdentifier:
                                            (isEditEnabled
                                                ? bag?.label
                                                : bag?.seal) ??
                                            '',
                                        description: package.description ?? '',
                                        quantity: package.quantity,
                                        ean: package.eanCode,
                                        backgroundColor:
                                            BagsHelper.resolveBackgroundColor(
                                              package.type,
                                            ),
                                        enableEdit: isEditEnabled,
                                        onDecrease: () {
                                          context
                                              .read<ReturnsCubit>()
                                              .decreasePackageQuantity(
                                                package.eanCode,
                                                package.bagId ?? '',
                                              );
                                          setState(() {});
                                        },

                                        onRemove: () {
                                          context
                                              .read<ReturnsCubit>()
                                              .removePackage(
                                                package.eanCode,
                                                package.bagId ?? '',
                                              );
                                          setState(() {});
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                      ),
                      const AppDivider(),
                      ButtonsRow(
                        buttons: [
                          Flexible(
                            child: NavigationButton(
                              icon: Assets.icons.back.image(
                                package: 'ok_mobile_common',
                              ),
                              onPressed: () => {
                                if (context.canPop())
                                  {context.pop()}
                                else
                                  {
                                    context.goNamed(
                                      widget.backRoute ?? MainScreen.routeName,
                                      pathParameters:
                                          widget.pathParameters ?? {},
                                    ),
                                  },
                              },
                              text: S.current.back,
                            ),
                          ),
                          if (state.openedReturn.packages.isEmpty)
                            Flexible(
                              child: NavigationButton(
                                icon: Assets.icons.exit.image(
                                  package: 'ok_mobile_common',
                                  color: AppColors.lightGreen,
                                ),
                                onPressed: () {
                                  context.read<ReturnsCubit>().rejectReturn();
                                  context.goNamed(
                                    ChooseBagTypeScreen.routeName,
                                  );
                                },
                                text: S.current.reject_return,
                              ),
                            )
                          else
                            Flexible(
                              child: IconTextButton(
                                icon: Assets.icons.scroll.image(
                                  package: 'ok_mobile_common',
                                  color: AppColors.black,
                                ),
                                onPressed: () {
                                  context.pushNamed(
                                    FinishReturnScreen.routeName,
                                  );
                                },
                                text: S.current.finish_return,
                                color: AppColors.yellow,
                                textColor: Colors.black,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
