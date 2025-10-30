part of '../../ok_mobile_common.dart';

class GlobalLoaderSpinner extends StatefulWidget {
  const GlobalLoaderSpinner({super.key});

  @override
  State<GlobalLoaderSpinner> createState() => _GlobalLoaderSpinnerState();
}

class _GlobalLoaderSpinnerState extends State<GlobalLoaderSpinner>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  )..repeat();

  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOutBack,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RotationTransition(
          turns: _animation,
          child: Assets.icons.loader.image(
            package: 'ok_mobile_common',
            width: 50,
          ),
        ),
      ],
    );
  }
}
