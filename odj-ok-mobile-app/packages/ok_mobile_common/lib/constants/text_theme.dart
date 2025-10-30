part of '../ok_mobile_common.dart';

class AppTextStyle {
  static const String oswald = 'Oswald';
  static const String openSans = 'OpenSans';

  static TextStyle h0({Color? color}) => TextStyle(
    fontFamily: oswald,
    fontSize: 40,
    height: 1.2,
    fontWeight: FontWeight.w400,
    color: color ?? AppColors.black,
  );

  static TextStyle h1({Color? color}) => TextStyle(
    fontFamily: oswald,
    fontSize: 32,
    height: 1.25,
    fontWeight: FontWeight.w400,
    color: color ?? AppColors.black,
  );

  static TextStyle h2({Color? color}) => TextStyle(
    fontFamily: oswald,
    fontSize: 24,
    height: 1.33,
    fontWeight: FontWeight.w400,
    color: color ?? AppColors.black,
  );

  static TextStyle h3({Color? color}) => TextStyle(
    fontFamily: oswald,
    fontSize: 20,
    height: 1.2,
    fontWeight: FontWeight.w400,
    color: color ?? AppColors.black,
  );

  static TextStyle h4({Color? color}) => TextStyle(
    fontFamily: openSans,
    fontSize: 20,
    height: 1.2,
    fontWeight: FontWeight.w700,
    color: color ?? AppColors.black,
  );

  static TextStyle h5({Color? color}) => TextStyle(
    fontFamily: openSans,
    fontSize: 16,
    height: 1.38,
    fontWeight: FontWeight.w700,
    color: color ?? AppColors.black,
  );

  static TextStyle p({Color? color}) => TextStyle(
    fontFamily: openSans,
    fontSize: 14, // In Figma 13
    height: 1.23,
    fontWeight: FontWeight.w400,
    color: color ?? AppColors.black,
  );

  static TextStyle pBold({Color? color}) => TextStyle(
    fontFamily: openSans,
    fontSize: 14, // In Figma 13
    height: 1.23,
    fontWeight: FontWeight.w700,
    color: color ?? AppColors.black,
  );

  static TextStyle pItalic({Color? color}) => TextStyle(
    fontFamily: openSans,
    fontSize: 13,
    height: 1.23,
    fontStyle: FontStyle.italic,
    color: color ?? AppColors.black,
  );

  static TextStyle large({Color? color}) => TextStyle(
    fontFamily: openSans,
    fontSize: 18,
    height: 1.22,
    fontWeight: FontWeight.w400,
    color: color ?? AppColors.black,
  );

  static TextStyle small({Color? color}) => TextStyle(
    fontFamily: openSans,
    fontSize: 12, // In Figma 11
    height: 1.09,
    fontWeight: FontWeight.w400,
    color: color ?? AppColors.black,
  );

  static TextStyle smallBold({Color? color}) => TextStyle(
    fontFamily: openSans, // In Figma 11
    fontSize: 12,
    height: 1.09,
    fontWeight: FontWeight.w700,
    color: color ?? AppColors.black,
  );

  static TextStyle smallItalic({Color? color}) => TextStyle(
    fontFamily: openSans,
    fontSize: 12, // In Figma 11
    height: 1.09,
    fontStyle: FontStyle.italic,
    color: color ?? AppColors.black,
  );

  static TextStyle micro({Color? color}) => TextStyle(
    fontFamily: openSans,
    fontSize: 10, // In Figma 9
    height: 1,
    fontWeight: FontWeight.w400,
    color: color ?? AppColors.black,
  );

  static TextStyle microBold({Color? color}) => TextStyle(
    fontFamily: openSans,
    fontSize: 10, // In Figma 9
    height: 1,
    fontWeight: FontWeight.w700,
    color: color ?? AppColors.black,
  );

  static TextStyle microBoldDownsized({Color? color}) => TextStyle(
    fontFamily: openSans,
    fontSize: 9, // In Figma 8
    height: 1.09,
    fontWeight: FontWeight.w700,
    color: color ?? AppColors.lightGreen,
  );
}
