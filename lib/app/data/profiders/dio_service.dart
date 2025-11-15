import 'package:dio/dio.dart';
import 'package:demo3bismillah/app/data/models/country_model.dart';
import 'package:demo3bismillah/app/data/services/api_service_interface.dart';
import 'package:demo3bismillah/utils/logging_interceptor.dart';

class DioService implements ApiServiceInterface {
  late final Dio _dio;
  final String _baseUrl = 'https://restcountries.com/v3.1';

  DioService() {
    _dio = Dio(BaseOptions(baseUrl: _baseUrl));
    // Menambahkan interceptor untuk logging otomatis 
    _dio.interceptors.add(LoggingInterceptor());
  }

  @override
  Future<Country> fetchCountryByName(String name) async {
    try {
      final response = await _dio.get('/name/$name');
      final data = response.data as List;
      return Country.fromJson(data.first);
    } catch (e) {
      // Dio otomatis melempar DioException, ditangkap oleh interceptor 
      throw Exception('Failed to fetch data: $e');
    }
  }

  @override
  Future<Country> fetchCountryByCode(String code) async {
    try {
      final response = await _dio.get('/alpha/$code');
      final data = response.data as List;
      return Country.fromJson(data.first);
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }

  // --- Versi Callback (Untuk Eksperimen 3) ---

  @override
  void fetchCountryByNameCallback(
    String name,
    void Function(Country) onSuccess,
    void Function(String) onError,
  ) {
    _dio.get('/name/$name').then((response) {
      final data = response.data as List;
      onSuccess(Country.fromJson(data.first));
    }).catchError((e) {
      onError(e.toString());
    });
  }

  @override
  void fetchCountryByCodeCallback(
    String code,
    void Function(Country) onSuccess,
    void Function(String) onError,
  ) {
    _dio.get('/alpha/$code').then((response) {
      final data = response.data as List;
      onSuccess(Country.fromJson(data.first));
    }).catchError((e) {
      onError(e.toString());
    });
  }
}