part of '../../../ok_mobile_data.dart';

class AdminDatasource {
  Future<String?> getPrinter() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(CacheKeys.savedPrinterMacAddress);
  }

  Future<void> setPrinter(String printerMacAddress) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      CacheKeys.savedPrinterMacAddress,
      printerMacAddress,
    );
  }

  Future<void> removePrinter() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(CacheKeys.savedPrinterMacAddress);
  }
}
