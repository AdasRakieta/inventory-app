part of '../../ok_mobile_auth.dart';

class InAppAuthScreen extends StatefulWidget {
  const InAppAuthScreen({super.key});

  static const routeName = '/in_app_auth';

  @override
  State<InAppAuthScreen> createState() => _InAppAuthScreenState();
}

class _InAppAuthScreenState extends State<InAppAuthScreen> {
  bool _isLoading = true;
  late final Uri authorizationUri;

  @override
  void initState() {
    super.initState();
    authorizationUri = context.read<AuthCubit>().getAuthenticationUri(
      languageCode: context
          .read<LocalizationCubit>()
          .state
          .currentLocale
          .languageCode,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(authorizationUri.toString()),
            ),
            initialSettings: InAppWebViewSettings(transparentBackground: true),
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              final uri = navigationAction.request.url;
              if (uri != null && uri.toString().startsWith('msauth://')) {
                context.pop(uri.toString());
                return NavigationActionPolicy.CANCEL;
              }
              return NavigationActionPolicy.ALLOW;
            },
            onLoadStop: (controller, url) => setState(() => _isLoading = false),
            onReceivedError: (_, _, _) => context.pop(),
          ),

          if (_isLoading) const Center(child: GlobalLoaderSpinner()),
        ],
      ),
    ),
  );
}
