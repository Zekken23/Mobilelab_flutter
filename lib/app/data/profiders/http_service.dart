import 'dart:convert';
import 'dart:developer' as dev; 
import 'package:http/http.dart' as http;
import 'package:demo3bismillah/app/data/models/country_model.dart';
import 'package:demo3bismillah/app/data/services/api_service_interface.dart';

class HttpService implements ApiServiceInterface {
  final String _baseUrl = 'https://restcountries.com/v3.1';

  @override
  Future<Country> fetchCountryByName(String name) async {
    final url = Uri.parse('$_baseUrl/name/$name');
    dev.log('🚀 HTTP REQUEST: $url', name: 'HttpService');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        dev.log('✅ HTTP RESPONSE[200]', name: 'HttpService');
        final data = json.decode(response.body) as List;
        return Country.fromJson(data.first);
      } else {
        // Penanganan error manual 
        dev.log('❌ HTTP ERROR[${response.statusCode}]: ${response.body}',
            name: 'HttpService');
        throw Exception('Failed to load country. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      // Penanganan error manual (cth: timeout, no internet)
      dev.log('❌ HTTP CATCH ERROR: $e', name: 'HttpService');
      throw Exception('Failed to fetch data: $e');
    }
  }

  @override
  Future<Country> fetchCountryByCode(String code) async {
    final url = Uri.parse('$_baseUrl/alpha/$code');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return Country.fromJson(data.first);
    } else {
      throw Exception('Failed to load country by code');
    }
  }

  // --- Versi Callback (Tidak umum digunakan dengan http modern) ---

  @override
  void fetchCountryByNameCallback(
    String name,
    void Function(Country) onSuccess,
    void Function(String) onError,
  ) {
    // Ini hanya simulasi, karena 'http' tidak native callback-based
    fetchCountryByName(name).then(onSuccess).catchError((e) {
      onError(e.toString());
    });
  }

  @override
  void fetchCountryByCodeCallback(
    String code,
    void Function(Country) onSuccess,
    void Function(String) onError,
  ) {
    fetchCountryByCode(code).then(onSuccess).catchError((e) {
      onError(e.toString());
    });
  }
}