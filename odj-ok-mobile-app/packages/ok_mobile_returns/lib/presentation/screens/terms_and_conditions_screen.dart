// Change to use terms and condtions from API
// ignore_for_file: lines_longer_than_80_chars

part of '../../ok_mobile_returns.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({super.key});

  static const routeName = '/terms_and_condtions_route';

  @override
  State<TermsAndConditionsScreen> createState() =>
      _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: GeneralAppBar(
          title: S.of(context).accept_terms,
          showSettings: false,
          isColectionPointNumberVisible: false,
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 8,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        S.of(context).terms_and_conditions_title,
                        style: AppTextStyle.h3(color: AppColors.green),
                      ),
                      const SizedBox(height: 24),
                      _buildParagraph(
                        text: S.of(context).terms_and_condition_paragraph_1,
                        style: AppTextStyle.smallBold(),
                      ),

                      ...getTermsAndConditionsContent(
                        context,
                      ).map((text) => _buildParagraph(text: text)),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const AppDivider(
                      padding: EdgeInsets.only(bottom: 8),
                      height: 0,
                    ),
                    CenteredTextButton(
                      onPressed: () =>
                          context.read<UserCubit>().acceptTermsAndConditions(),
                      text: S.of(context).accept_terms_and_conditions,
                      color: AppColors.yellow,
                      textColor: AppColors.black,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParagraph({
    required String text,
    TextStyle? style,
    double spacing = 8,
  }) => Padding(
    padding: EdgeInsets.only(bottom: spacing),
    child: Text(text, style: style ?? AppTextStyle.small()),
  );

  List<String> getTermsAndConditionsContent(BuildContext context) => [
    S.of(context).terms_and_conditions_part_1,
    S.of(context).terms_and_conditions_part_2,
    S.of(context).terms_and_conditions_part_3,
    S.of(context).terms_and_conditions_part_4,
    S.of(context).terms_and_conditions_part_5,
    S.of(context).terms_and_conditions_part_6,
    S.of(context).terms_and_conditions_part_7,
  ];
}
