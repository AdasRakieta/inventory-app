part of '../../ok_mobile_returns.dart';

class PackagesSummaryList extends StatelessWidget {
  const PackagesSummaryList({
    required this.returnElement,
    required this.upperTitle,
    required this.closeDate,
    this.voucherDisplayType,
    super.key,
  });

  final Return returnElement;
  final String upperTitle;
  final DateTime closeDate;
  final VoucherDisplayType? voucherDisplayType;

  @override
  Widget build(BuildContext context) {
    final packages = ReturnsHelper.aggregatePackagesFromDifferentBags(
      returnElement.packages,
    );
    final totalDeposit = packages.fold<double>(
      0,
      (previous, current) => previous + (current.deposit * current.quantity),
    );

    return Card(
      elevation: 0,
      color: AppColors.white,
      margin: EdgeInsets.zero,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ReturnButton(
            state: voucherDisplayType == VoucherDisplayType.digital
                ? null
                : returnElement.state,
            numberOfPackages: returnElement.numberOfPackages,
            title: upperTitle,
            date: closeDate,
          ),
          Builder(
            builder: (context) {
              final packagesByType = <BagType, List<Package>>{};
              final packagesWithoutType = <Package>[];

              for (final package in packages) {
                final packageData = context
                    .read<MasterDataCubit>()
                    .getPackageByEan(package.eanCode, showErrorMessage: false);
                if (packageData == null) continue;

                final packageFilled = package.copyWith(
                  description: packageData.description,
                  type: packageData.type,
                );

                if (packageFilled.type == null) {
                  packagesWithoutType.add(packageFilled);
                } else {
                  packagesByType[packageFilled.type!] = [
                    ...?packagesByType[packageFilled.type],
                    packageFilled,
                  ];
                }
              }

              final groupedSections = packagesByType.entries
                  .map((entry) => _PackageTypeSection(packages: entry.value))
                  .toList();

              final individualSections = packagesWithoutType
                  .map((pkg) => _PackageTypeSection(packages: [pkg]))
                  .toList();

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [...individualSections, ...groupedSections],
                ),
              );
            },
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.black,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.current.pln_return_sum,
                  style: AppTextStyle.pBold(color: AppColors.white),
                ),
                Text(
                  totalDeposit.toStringAsFixed(2).replaceAll('.', ','),
                  style: AppTextStyle.h4(color: AppColors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PackageTypeSection extends StatelessWidget {
  _PackageTypeSection({required this.packages})
    : packagesType = packages.first.type,
      totalDeposit = packages
          .map((e) => e.deposit * e.quantity)
          .fold(0, (previousValue, element) => previousValue + element),
      totalQuantity = packages.fold(
        0,
        (previousValue, element) => previousValue + element.quantity,
      );

  final List<Package> packages;
  final BagType? packagesType;
  final double totalDeposit;
  final int totalQuantity;

  @override
  Widget build(BuildContext context) {
    final hasType = packagesType != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasType)
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 4,
            ),
            child: Row(
              children: [
                Text(
                  '$totalQuantity x ${packagesType!.localisedName}',
                  style: AppTextStyle.pBold(),
                ),
                const Spacer(),
                Text(
                  totalDeposit.toStringAsFixed(2).replaceAll('.', ','),
                  style: AppTextStyle.p(),
                ),
              ],
            ),
          ),

        if (hasType) const AppDivider(verticalPadding: 0),

        ...packages.map(
          (package) => Padding(
            padding: hasType
                ? const EdgeInsets.symmetric(horizontal: 16, vertical: 4)
                : const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: 4,
                  ),
            child: Row(
              children: [
                Text(
                  '${package.quantity} x ${package.description}',
                  style: AppTextStyle.pItalic(),
                ),
                const Spacer(),
                if (!hasType)
                  Text(
                    package.deposit.toStringAsFixed(2).replaceAll('.', ','),
                    style: AppTextStyle.p(),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
