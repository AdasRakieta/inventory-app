import 'dart:developer';

import 'package:dio/dio.dart';

class LoggingInterceptor extends InterceptorsWrapper {
  LoggingInterceptor()
    : super(
        onRequest: (options, handler) {
          log('Request: [${options.method}] ${options.uri}');
          log('Headers: ${options.headers}');
          log('Query Parameters: ${options.queryParameters}');
          log('Data: ${options.data}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          log(
            'Response: [${response.statusCode}] ${response.requestOptions.uri}',
          );
          log('Data: ${response.data}');
          handler.next(response);
        },
        onError: (DioException e, handler) {
          log('Error: [${e.response?.statusCode}] ${e.message}');
          if (e.response != null) {
            log('Error Data: ${e.response?.data}');
          }
          handler.next(e);
        },
      );
}
