part of '../../../ok_mobile_data.dart';

class ReturnsLocalDatasource {
  Future<String?> getData() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(CacheKeys.openReturn);
  }

  Future<void> setData(String openReturn) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(CacheKeys.openReturn, openReturn);
  }

  Future<void> removeData() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(CacheKeys.openReturn);
  }
}
