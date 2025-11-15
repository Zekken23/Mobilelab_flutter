import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class LoggingInterceptor extends Interceptor {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 100,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.i(
        '🚀 REQUEST[${options.method}] => PATH: ${options.baseUrl}${options.path}');
    _logger.d('Query: ${options.queryParameters}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.i(
      '✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
    );
    // _logger.d('Data: ${response.data}'); // Uncomment untuk melihat data lengkap
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e(
      '❌ DIO ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
      error: err,
    );
    super.onError(err, handler);
  }
}