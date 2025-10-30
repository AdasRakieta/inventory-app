part of '../../ok_mobile_returns.dart';

class ClosedReturnsScreen extends StatefulWidget {
  const ClosedReturnsScreen({super.key, this.shouldClearFilters = true});

  final bool shouldClearFilters;

  static const routeName = '/closed_returns';
  static const shouldClearFiltersParam = 'clear_filters';

  @override
  State<ClosedReturnsScreen> createState() => _ClosedReturnsScreenState();
}

class _ClosedReturnsScreenState extends State<ClosedReturnsScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.shouldClearFilters) {
      context.read<ReturnsCubit>().clearStateFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    context.read<ReturnsCubit>().fetchReturns();
    final isDigital = context.read<DeviceConfigCubit>().isDigitalVoucherFlow;
    return SafeArea(
      child: Scaffold(
        appBar: GeneralAppBar(title: S.current.closed_returns_list),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: BlocBuilder<ReturnsCubit, ReturnsState>(
                    builder: (context, state) {
                      switch (isDigital) {
                        case true:
                          final returns = state.returns
                              .where(
                                (element) => DatesHelper.isTheSameDay(
                                  element.closedTime,
                                  DateTime.now(),
                                ),
                              )
                              .toList();
                          return _DigitalClosedReturnsButtons(
                            returns: returns,
                            state: state.generalState,
                          );
                        case (_):
                          final unfinishedReturns = state
                              .filteredReturnsByUnfinished(
                                DateTime.now(),
                                ClosedReturnsScreen.routeName,
                              )
                              .toList();

                          return _RegularClosedReturnsButtons(
                            unfinishedReturns: unfinishedReturns,
                            returns: state.filteredReturnsPerScreenByDay(
                              DateTime.now(),
                              ClosedReturnsScreen.routeName,
                            ),
                            generalState: state.generalState,
                            selectedStates: state.selectedStatesForScreen(
                              ClosedReturnsScreen.routeName,
                            ),
                          );
                      }
                    },
                  ),
                ),
              ),
              const AppDivider(),
              ButtonsRow(
                buttons: [
                  Expanded(
                    child: NavigationButton(
                      icon: Assets.icons.back.image(
                        package: 'ok_mobile_common',
                      ),
                      onPressed: () async {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.goNamed(MainScreen.routeName);
                        }
                      },
                      text: S.current.exit,
                    ),
                  ),
                  Expanded(
                    child: NavigationButton(
                      icon: Assets.icons.archive.image(
                        package: 'ok_mobile_common',
                        color: AppColors.green,
                      ),
                      onPressed: () {
                        context.goNamed(
                          ReturnsArchiveScreen.routeName,
                          queryParameters: {
                            ReturnsArchiveScreen.shouldClearFiltersParam:
                                'false',
                          },
                        );
                      },
                      text: S.current.returns_archive,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DigitalClosedReturnsButtons extends StatelessWidget {
  const _DigitalClosedReturnsButtons({
    required this.returns,
    required this.state,
  });

  final List<Return> returns;
  final GeneralState state;

  @override
  Widget build(BuildContext context) {
    if (returns.isEmpty && state == GeneralState.loaded) {
      return NoItemsWidget(title: S.current.no_returns_today);
    } else {
      return ButtonsColumn(
        buttons: List.generate(returns.length, (index) {
          final element = returns[index];
          return ReturnButton(
            date: element.closedTime!,
            numberOfPackages: element.numberOfPackages,
            title: element.code!,
            onPressed: () => context.pushNamed(
              ClosedReturnSummaryScreen.routeName,
              pathParameters: {
                ClosedReturnSummaryScreen.currentReturnIdParam: element.id,
                ClosedReturnSummaryScreen.shouldShowBackButtonParam: 'true',
              },
            ),
          );
        }),
      );
    }
  }
}

class _RegularClosedReturnsButtons extends StatelessWidget {
  const _RegularClosedReturnsButtons({
    required this.unfinishedReturns,
    required this.returns,
    required this.generalState,
    required this.selectedStates,
  });

  final List<Return> unfinishedReturns;
  final List<Return> returns;
  final GeneralState generalState;
  final List<ReturnState> selectedStates;

  @override
  Widget build(BuildContext context) {
    final returnsState = context.watch<ReturnsCubit>().state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (unfinishedReturns.isNotEmpty) ...[
          ButtonsColumn(
            buttons: List.generate(unfinishedReturns.length, (index) {
              final element = unfinishedReturns[index];
              final button = ReturnButton(
                date: element.closedTime!,
                state: element.state,
                numberOfPackages: element.numberOfPackages,
                title: element.code!.toUpperCase(),
                onPressed: () => context.pushNamed(
                  ClosedReturnSummaryScreen.routeName,
                  pathParameters: {
                    ClosedReturnSummaryScreen.currentReturnIdParam: element.id,
                    ClosedReturnSummaryScreen.shouldShowBackButtonParam: 'true',
                  },
                ),
              );

              return button;
            }),
          ),
          const AppDivider(),
        ],
        ReturnStateFilters(
          selectedReturnStates: returnsState.selectedStatesForScreen(
            ClosedReturnsScreen.routeName,
          ),
          onPrintedFilterChanged: (value) {
            context.read<ReturnsCubit>().changeStateFilter(
              ClosedReturnsScreen.routeName,
              ReturnState.printed,
            );
          },
          onCanceledFilterChanged: (value) {
            context.read<ReturnsCubit>().changeStateFilter(
              ClosedReturnsScreen.routeName,
              ReturnState.canceled,
            );
          },
        ),
        const SizedBox(height: 16),
        if (returns.isEmpty && generalState == GeneralState.loaded)
          NoItemsWidget(title: S.current.no_returns_today)
        else
          ButtonsColumn(
            buttons: List.generate(returns.length, (index) {
              final element = returns[index];
              return ReturnButton(
                date: element.closedTime!,
                state: element.state,
                numberOfPackages: element.numberOfPackages,
                title: element.code!,
                onPressed: () => context.pushNamed(
                  ClosedReturnSummaryScreen.routeName,
                  pathParameters: {
                    ClosedReturnSummaryScreen.currentReturnIdParam: element.id,
                    ClosedReturnSummaryScreen.shouldShowBackButtonParam: 'true',
                  },
                ),
              );
            }),
          ),
      ],
    );
  }
}
