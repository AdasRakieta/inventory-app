part of '../../../../../ok_mobile_scanner.dart';

class PackageScannerWidget extends StatefulWidget {
  const PackageScannerWidget({this.selectedBag, super.key});

  final Bag? selectedBag;

  @override
  State<PackageScannerWidget> createState() => _PackageScannerWidgetState();
}

class _PackageScannerWidgetState extends State<PackageScannerWidget> {
  final AudioHelper _audioHelper = AudioHelper();

  Future<bool> onScan(String? result) async {
    if (result case null) return false;

    final package = context.read<MasterDataCubit>().getPackageByEan(result);
    if (package case null) {
      await _audioHelper.play();
      return false;
    }

    final isOfAllowedType = context
        .read<DeviceConfigCubit>()
        .checkIfPackageTypeIsAllowed(package.type);

    if (isOfAllowedType) {
      final navigate = context.read<ReturnsCubit>().addPackage(
        package,
        widget.selectedBag,
      );
      if (navigate) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            context.goNamed(
              ChooseBagTypeScreen.routeName,
              queryParameters: {
                ChooseBagTypeScreen.bagTypeParam: package.type!.name,
              },
            );
          }
        });
      }
      return true;
    }

    await _audioHelper.play();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BaseScannerWidget(
          onScanSuccess: onScan,
          upperTitle: S.current.scan_package_ean,
          lowerTitle: '${S.current.or_enter_ean}:',
          clearOnComplete: true,
          onInputCompleteResult: false,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      ],
    );
  }
}
