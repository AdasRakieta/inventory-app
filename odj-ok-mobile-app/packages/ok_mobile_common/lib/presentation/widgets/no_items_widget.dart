part of '../../ok_mobile_common.dart';

class NoItemsWidget extends StatelessWidget {
  const NoItemsWidget({this.title, super.key});

  final String? title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title ?? S.current.no_open_bags,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: AppColors.black,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
