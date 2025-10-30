part of '../ok_mobile_common.dart';

class SnackBarHelper {
  const SnackBarHelper._();

  static void showFailureSnackBar(
    GlobalKey<ScaffoldMessengerState> scaffoldKey,
    Failure failure,
  ) {
    scaffoldKey.currentState!.clearSnackBars();
    scaffoldKey.currentState!.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (failure.severity == FailureSeverity.error)
              Assets.icons.alert.image(package: 'ok_mobile_common', height: 16)
            else
              Assets.icons.warning.image(
                package: 'ok_mobile_common',
                height: 16,
              ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                style: const TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.w700,
                ),
                failure.message ?? S.current.generic_error_message,
              ),
            ),
          ],
        ),
        backgroundColor: failure.severity == FailureSeverity.error
            ? AppColors.powderRed
            : AppColors.sandYellow,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 98),
        padding: const EdgeInsets.all(16),
        dismissDirection: DismissDirection.horizontal,
        duration: const Duration(seconds: 8),
      ),
    );
  }

  static void showSuccessSnackBar(
    GlobalKey<ScaffoldMessengerState> scaffoldKey,
    Success success,
  ) {
    scaffoldKey.currentState!.clearSnackBars();
    scaffoldKey.currentState!.showSnackBar(
      SnackBar(
        content: SizedBox(
          height: 48,
          child: Row(
            children: [
              Assets.icons.apply.image(package: 'ok_mobile_common', height: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  style: const TextStyle(
                    color: AppColors.green,
                    fontWeight: FontWeight.w700,
                  ),
                  success.message ?? 'BRAK WIADOMOŚCI SUKCESU',
                ),
              ),
            ],
          ),
        ),
        backgroundColor: AppColors.lightGreen,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 98),
        padding: const EdgeInsets.all(16),
        dismissDirection: DismissDirection.horizontal,
        duration: const Duration(seconds: 8),
      ),
    );
  }

  static SnackBar successSnackBarWidget({required String message}) {
    return SnackBar(
      content: Row(
        children: [
          Assets.icons.apply.image(package: 'ok_mobile_common', height: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              style: const TextStyle(
                color: AppColors.green,
                fontWeight: FontWeight.w700,
              ),
              message,
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.lightGreen,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 98),
      padding: const EdgeInsets.all(16),
      dismissDirection: DismissDirection.horizontal,
      duration: const Duration(seconds: 8),
    );
  }
}
