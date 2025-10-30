part of '../../ok_mobile_domain.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({required AuthUsecases authUseCases})
    : _authUseCases = authUseCases;

  final AuthUsecases _authUseCases;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers.addAll({
      'Authorization': 'Bearer ${_authUseCases.tokenData.accessToken}',
      'Accept-Encoding': 'gzip',
    });
    super.onRequest(options, handler);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final dio = Dio();
      await _authUseCases.refreshToken();
      err.requestOptions.headers['Authorization'] =
          'Bearer ${_authUseCases.tokenData.accessToken}';

      return handler.resolve(await dio.fetch(err.requestOptions));
    }
    super.onError(err, handler);
  }
}
