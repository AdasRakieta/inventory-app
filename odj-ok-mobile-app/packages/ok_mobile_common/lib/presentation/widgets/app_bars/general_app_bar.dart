part of '../../../ok_mobile_common.dart';

class GeneralAppBar extends BaseAppBar {
  GeneralAppBar({
    this.onLeadingPressed,
    super.title,
    super.key,
    super.showSettings,
    super.isColectionPointNumberVisible,
    super.blockReturnToHome = false,
  }) : super(
         leading: Builder(
           builder: (context) {
             return GestureDetector(
               onTap: () {
                 if (onLeadingPressed != null) {
                   onLeadingPressed();
                 }
                 if (blockReturnToHome) {
                   return;
                 }
                 context.goNamed('/');
               },
               child: Padding(
                 padding: const EdgeInsets.only(left: 20),
                 child: Assets.icons.okLogo.image(
                   package: 'ok_mobile_common',
                   color: AppColors.green,
                 ),
               ),
             );
           },
         ),
       );

  final VoidCallback? onLeadingPressed;
}
