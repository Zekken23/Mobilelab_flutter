import 'package:demo3bismillah/app/data/models/country_model.dart';

abstract class ApiServiceInterface {
  // Method untuk mengambil data negara berdasarkan nama
  Future<Country> fetchCountryByName(String name);

  // Method untuk mengambil data negara berdasarkan kode (untuk chained request)
  Future<Country> fetchCountryByCode(String code);

  // Method versi callback (untuk eksperimen)
  void fetchCountryByNameCallback(
    String name,
    void Function(Country) onSuccess,
    void Function(String) onError,
  );

  void fetchCountryByCodeCallback(
    String code,
    void Function(Country) onSuccess,
    void Function(String) onError,
  );
}