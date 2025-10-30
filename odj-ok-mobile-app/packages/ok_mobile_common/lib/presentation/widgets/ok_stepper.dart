part of '../../ok_mobile_common.dart';

class OkStepper extends StatelessWidget {
  const OkStepper({
    required this.statusHistory,
    required this.collectionPointName,
    required this.countingCenterName,
    super.key,
  });

  final List<StatusHistoryItem> statusHistory;
  final String collectionPointName;
  final String countingCenterName;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Column(
            children: List.generate(statusHistory.length, (index) {
              final statusItem = statusHistory[index];
              return Column(
                children: [
                  if (index != 0) _generateLine(statusItem.status),
                  _generateCircle(statusItem.status),
                ],
              );
            }),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...[
                for (final item in statusHistory)
                  SizedBox(
                    height: 78,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.status.localizedName,
                              style: Theme.of(context).textTheme.titleSmall!
                                  .copyWith(color: _resolveColor(item.status)),
                            ),
                            Text(
                              _getSubtitle(item),
                              style: Theme.of(context).textTheme.bodyMedium!
                                  .copyWith(color: AppColors.black),
                            ),
                          ],
                        ),
                        Text(
                          item.dateModified == null
                              ? ''
                              : DatesHelper.formatDateTimeOneLine(
                                  item.dateModified!,
                                ),
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(
                                color: AppColors.black,
                                fontStyle: FontStyle.italic,
                              ),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _getSubtitle(StatusHistoryItem item) {
    if (item.status == PickupStatus.futureReceived) {
      return '';
    }
    return item.status == PickupStatus.released
        ? collectionPointName
        : countingCenterName;
  }

  ColoredBox _generateLine(PickupStatus status) {
    return ColoredBox(
      color: _resolveColor(status),
      child: const SizedBox(width: 1, height: 62),
    );
  }

  Container _generateCircle(PickupStatus status) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      height: 12,
      width: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _resolveColor(status),
      ),
    );
  }

  Color _resolveColor(PickupStatus status) {
    switch (status) {
      case PickupStatus.partiallyReceived:
        return AppColors.yellow;
      case PickupStatus.received:
      case PickupStatus.released:
        return AppColors.green;
      case PickupStatus.futureReceived:
        return AppColors.darkGrey;
    }
  }
}
