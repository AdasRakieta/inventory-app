part of '../../ok_mobile_auth.dart';

class OkSplashScreen extends StatefulWidget {
  const OkSplashScreen({super.key});

  static const routeName = '/splash';

  @override
  State<OkSplashScreen> createState() => _OkSplashScreenState();
}

class _OkSplashScreenState extends State<OkSplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<AuthCubit>().checkUser();
      await precacheAssets();
    });
  }

  Future<void> initialize(BuildContext context) async {
    context.read<UserCubit>().getUserData();
  }

  Future<void> precacheAssets() async {
    await ImageHelper.precacheIcons(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.authStatus == AuthStatus.authenticated) {
            initialize(context);
          } else if (state.authStatus == AuthStatus.unauthenticated) {
            context.goNamed(LoginScreen.routeName);
          }
        },
        child: Scaffold(
          body: Container(
            width: MediaQuery.of(context).size.width,
            color: AppColors.darkGreen,
            child: Column(
              children: [
                const Expanded(child: SizedBox.shrink()),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Assets.icons.okLogo.image(
                        package: 'ok_mobile_common',
                        width: 100,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
