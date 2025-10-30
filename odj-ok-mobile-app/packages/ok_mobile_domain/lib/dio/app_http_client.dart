part of '../ok_mobile_domain.dart';

@singleton
class AppHttpClient {
  client_http.Client httpClient() {
    if (ProxyConfig().shouldUseProxy) {
      final ioHttpClient = HttpClient()
        ..findProxy = (Uri uri) => 'PROXY ${ProxyConfig().address};';
      return IOClient(ioHttpClient);
    } else {
      return client_http.Client();
    }
  }
}
