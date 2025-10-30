part of '../../ok_mobile_counting_center.dart';

class ReceivalUneditableOverviewScreen extends StatelessWidget {
  const ReceivalUneditableOverviewScreen({super.key});

  static const routeName = '/receival_uneditable_overview';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReceivalsCubit, ReceivalsState>(
      builder: (context, state) {
        return UneditableOverviewScreen(
          title: '${S.current.receival} ${state.selectedReceival?.code}',
          selectedPickup: state.selectedReceival!,
          summaryTitle: S.current.receival_summary,
          onPressed: (bag) {
            context.pushNamed(
              CCClosedBagDetailsScreen.routeName,
              queryParameters: {
                CCClosedBagDetailsScreen.hideManagementOptionsParam: 'true',
              },
              pathParameters: {
                CCClosedBagDetailsScreen.selectedBagIdParam: bag.id!,
              },
            );
          },
        );
      },
    );
  }
}
