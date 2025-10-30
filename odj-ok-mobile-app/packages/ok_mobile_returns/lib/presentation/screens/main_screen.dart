part of '../../ok_mobile_returns.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  static const routeName = '/';

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    init(context);
  }

  Future<void> init(BuildContext context) async {
    final user = context.read<UserCubit>().state.user;

    if (context.mounted) {
      await context.read<DeviceConfigCubit>().getDeviceConfig(
        isSupportUser: user?.isSupportUser ?? false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizationState = context.watch<LocalizationCubit>().state;
    final user = context.watch<UserCubit>().state.user;
    final deviceConfigState = context.watch<DeviceConfigCubit>().state;
    final deviceConfig = deviceConfigState.deviceConfig;
    final contractorData = deviceConfigState.contractorData;
    final error = deviceConfigState.deviceConfigError;
    final collectedPackagingTypeEnum = context
        .read<DeviceConfigCubit>()
        .state
        .collectionPointData
        ?.collectedPackagingType;

    return SafeArea(
      child: Scaffold(
        appBar: MainAppBar(
          identity: user?.identity ?? '',
          initialLanguage: localizationState.currentLocale,
          onLanguageChange: (locale) {
            context.read<LocalizationCubit>().changeLocale(locale);
          },
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            switch ((
              deviceConfigState.state,
              user,
              deviceConfig,
              error,
              contractorData,
            )) {
              (GeneralState.loading, _, _, _, _) => const Expanded(
                child: SizedBox.shrink(),
              ),

              (_, final currentUser?, _, _, _) when currentUser.isSupportUser =>
                const AdminHealthcheckScreen(),

              (GeneralState.loaded, _, final config?, _, _)
                  when config.isInvalid =>
                const MainScreenErrorCard(
                  failure: Failure(
                    type: FailureType.general,
                    severity: FailureSeverity.error,
                  ),
                ),

              (GeneralState.loaded, _, null, _, _) => const MainScreenErrorCard(
                failure: Failure(
                  type: FailureType.general,
                  severity: FailureSeverity.error,
                ),
              ),

              (_, _, _, final currentError?, _) => MainScreenErrorCard(
                failure: currentError,
              ),

              (_, final currentUser?, final config?, _, final contractorData)
                  when _isMisconfiguredUser(
                    currentUser,
                    config,
                    contractorData,
                    collectedPackagingTypeEnum,
                  ) =>
                const MainScreenErrorCard(
                  failure: Failure(
                    type: FailureType.wrongUserConfiguration,
                    severity: FailureSeverity.error,
                  ),
                ),

              (GeneralState.loaded, final currentUser?, _, _, _)
                  when currentUser.isStoreUser =>
                const CollectionPointMainScreen(),

              (GeneralState.loaded, final currentUser?, _, _, _)
                  when currentUser.isCountingCenterUser =>
                const CountingCenterMainScreen(),

              _ => const MainScreenErrorCard(
                failure: Failure(
                  type: FailureType.noAccess,
                  severity: FailureSeverity.error,
                ),
              ),
            },
            const Footer(),
          ],
        ),
      ),
    );
  }

  bool _isMisconfiguredUser(
    ContractorUser? user,
    DeviceConfig? config,
    ContractorData? contractorData,
    CollectedPackagingTypeEnum? collectedPackagingTypeEnum,
  ) {
    return switch ((collectedPackagingTypeEnum, user, config, contractorData)) {
      (CollectedPackagingTypeEnum.none, final ContractorUser user, _, _)
          when user.isStoreUser =>
        true,

      (_, final ContractorUser user, _, final ContractorData data)
          when data.voucherDisplayType == VoucherDisplayType.none &&
              user.isStoreUser =>
        true,

      (_, final ContractorUser user, final DeviceConfig config, _)
          when user.isStoreUser && !config.isCollectionPoint =>
        true,

      (_, final ContractorUser user, final DeviceConfig config, _)
          when user.isCountingCenterUser && config.isCollectionPoint =>
        true,

      _ => false,
    };
  }
}
