part of '../../ok_mobile_returns.dart';

class ReturnsArchiveScreen extends StatefulWidget {
  const ReturnsArchiveScreen({super.key, this.shouldClearFilters = true});

  final bool shouldClearFilters;

  static const routeName = '/returns_archive';
  static const shouldClearFiltersParam = 'should_clear_filters';

  @override
  State<ReturnsArchiveScreen> createState() => _ReturnsArchiveScreenState();
}

class _ReturnsArchiveScreenState extends State<ReturnsArchiveScreen> {
  DateTime _selectedDate = DateTime.now().subtract(const Duration(days: 1));

  @override
  void initState() {
    super.initState();
    if (widget.shouldClearFilters) {
      context.read<ReturnsCubit>().clearStateFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    final returnsState = context.watch<ReturnsCubit>().state;

    final selectedReturns = returnsState.filteredReturnsPerScreenByDay(
      _selectedDate,
      ReturnsArchiveScreen.routeName,
    );

    final isDigital = context.read<DeviceConfigCubit>().isDigitalVoucherFlow;
    return SafeArea(
      child: Scaffold(
        appBar: GeneralAppBar(title: S.current.closed_returns_archive),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              SizedBox(
                height: 40,
                child: ListView.builder(
                  itemCount: 7,
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final itemDate = DateTime.now().subtract(
                      Duration(days: index + 1),
                    );
                    final isSelected = DatesHelper.isTheSameDay(
                      _selectedDate,
                      itemDate,
                    );
                    return Container(
                      margin: EdgeInsets.only(
                        left: index == 6 ? 20 : 8.0,
                        right: index == 0 ? 20 : 0,
                      ),
                      child: ActionChip(
                        visualDensity: VisualDensity.compact,
                        backgroundColor: isSelected
                            ? AppColors.lightGreen
                            : AppColors.grey,
                        padding: EdgeInsets.zero,
                        labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                        side: BorderSide.none,
                        label: Text(
                          DatesHelper.formatDateTimeOneLineOnlyDate(itemDate),
                        ),
                        labelStyle: isSelected
                            ? AppTextStyle.pBold()
                            : AppTextStyle.p(),
                        onPressed: () {
                          setState(() {
                            _selectedDate = itemDate;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              const AppDivider(horizontalPadding: 20),
              if (!isDigital)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      ReturnStateFilters(
                        selectedReturnStates: returnsState
                            .selectedStatesForScreen(
                              ReturnsArchiveScreen.routeName,
                            ),
                        onPrintedFilterChanged: (value) {
                          context.read<ReturnsCubit>().changeStateFilter(
                            ReturnsArchiveScreen.routeName,
                            ReturnState.printed,
                          );
                        },
                        onCanceledFilterChanged: (value) {
                          context.read<ReturnsCubit>().changeStateFilter(
                            ReturnsArchiveScreen.routeName,
                            ReturnState.canceled,
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        if (selectedReturns.isEmpty)
                          NoItemsWidget(
                            title: S.current.no_returns_selected_date,
                          )
                        else
                          ButtonsColumn(
                            buttons: List.generate(selectedReturns.length, (
                              index,
                            ) {
                              final element = selectedReturns[index];
                              return ReturnButton(
                                date: element.closedTime!,
                                state: isDigital ? null : element.state,
                                numberOfPackages: element.numberOfPackages,
                                title: element.code!,
                                onPressed: () => context.pushNamed(
                                  ArchiveClosedReturnSummaryScreen.routeName,
                                  pathParameters: {
                                    ArchiveClosedReturnSummaryScreen
                                            .currentReturnIdParam:
                                        element.id,
                                  },
                                ),
                              );
                            }),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const AppDivider(),
                    NavigationButton(
                      icon: Assets.icons.back.image(
                        package: 'ok_mobile_common',
                      ),
                      onPressed: () => context.goNamed(
                        ClosedReturnsScreen.routeName,
                        queryParameters: {
                          ClosedReturnsScreen.shouldClearFiltersParam: 'false',
                        },
                      ),
                      text: S.current.back,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
