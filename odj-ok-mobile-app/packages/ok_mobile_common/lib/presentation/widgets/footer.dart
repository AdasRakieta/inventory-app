part of '../../ok_mobile_common.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.black,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Operator Kaucyjny ${DateTime.now().year}'),
            FutureBuilder(
              future: Future<PackageInfo>(PackageInfo.fromPlatform),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(snapshot.data!.version);
                }
                return const Text('-');
              },
            ),
          ],
        ),
      ),
    );
  }
}
