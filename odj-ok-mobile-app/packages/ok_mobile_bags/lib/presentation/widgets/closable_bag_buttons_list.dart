part of '../../ok_mobile_bags.dart';

class ClosableBagButtonList extends StatelessWidget {
  const ClosableBagButtonList({
    required this.bags,
    required this.onRemove,
    super.key,
  });

  final List<Bag> bags;
  final void Function(Bag) onRemove;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ButtonsColumn(
        buttons: List.generate(bags.length, (index) {
          final selectedBag = bags[index];
          return CloseableBagButton(
            key: ValueKey(selectedBag.id),
            onRemove: () {
              onRemove(selectedBag);
            },
            onPressed: () {
              context.pushNamed(
                ClosedBagDetailsScreen.routeName,
                queryParameters: {
                  ClosedBagDetailsScreen.hideManagementOptionsParam: 'true',
                },
                pathParameters: {
                  ClosedBagDetailsScreen.selectedBagIdParam: selectedBag.id!,
                },
              );
            },
            bag: selectedBag,
          );
        }),
      ),
    );
  }
}
