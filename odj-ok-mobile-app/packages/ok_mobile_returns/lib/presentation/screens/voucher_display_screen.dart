part of '../../ok_mobile_returns.dart';

class VoucherDisplayScreen extends StatelessWidget {
  const VoucherDisplayScreen({
    required this.selectedReturnId,
    super.key,
    this.isFirstTimeDisplayed = false,
  });

  static const routeName = '/voucher_display';
  static const selectedReturnIdParam = 'selected_return_id';
  static const isFirstTimeDisplayedParam = 'is_first_time_displayed';

  final String selectedReturnId;
  final bool isFirstTimeDisplayed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<ReturnsCubit, ReturnsState>(
        builder: (context, state) {
          final selectedReturn = state.returns.firstWhereOrNull(
            (element) => element.id == selectedReturnId,
          );

          final voucherDisplayDate = DatesHelper.formatDateTimeOneLine(
            selectedReturn?.closedTime ?? DateTime.now(),
          );

          final packageNumber = ReturnsHelper.getNumberOfAllPPackagesInReturn(
            selectedReturn,
          );

          final depositValue = ReturnsHelper.formatDepositValue(
            selectedReturn?.packages.first.deposit ?? 0,
          );

          final totalDepositValue = ReturnsHelper.formatDepositValue(
            selectedReturn?.voucher?.depositValue ?? 0,
          );

          return Scaffold(
            appBar: GeneralAppBar(
              title:
                  '${S.current.return_text} '
                  '${selectedReturn?.code}',
            ),
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.current.security_deposit_voucher.toUpperCase(),
                          style: AppTextStyle.h5(),
                        ),
                        Text(
                          '${S.current.voucher_generation_date}: '
                          '$voucherDisplayDate',
                          style: AppTextStyle.small(),
                        ),
                        Text(
                          '${S.current.expiration_date}: '
                          '${AppConstants.voucherValidityDays} '
                          '${S.current.days}',
                          style: AppTextStyle.small(),
                        ),
                        const AppDivider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(S.current.glass, style: AppTextStyle.p()),
                            Text(
                              '$packageNumber x '
                              '$depositValue',
                              style: AppTextStyle.p(),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(S.current.pln_sum, style: AppTextStyle.h5()),
                            Text(totalDepositValue, style: AppTextStyle.h5()),
                          ],
                        ),
                        const AppDivider(),
                        BarcodeWidget(
                          barcode: Barcode.code128(),
                          data: selectedReturn?.voucher?.code ?? '',
                          height: 100,
                          style: AppTextStyle.small(),
                        ),
                      ],
                    ),
                  ),
                  const AppDivider(),
                  if (isFirstTimeDisplayed)
                    ButtonsRow(
                      buttons: [
                        Flexible(
                          child: NavigationButton(
                            icon: Assets.icons.back.image(
                              package: 'ok_mobile_common',
                            ),
                            onPressed: () =>
                                context.goNamed(MainScreen.routeName),
                            text: S.current.exit,
                          ),
                        ),
                        Flexible(
                          child: NavigationButton(
                            icon: Assets.icons.scroll.image(
                              package: 'ok_mobile_common',
                              color: AppColors.green,
                            ),
                            onPressed: () {
                              context.goNamed(ClosedReturnsScreen.routeName);
                            },
                            text: S.current.closed_returns,
                          ),
                        ),
                      ],
                    )
                  else
                    NavigationButton(
                      icon: Assets.icons.back.image(
                        package: 'ok_mobile_common',
                      ),
                      onPressed: () => context.pop(),
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
