
class Country {
  final String name;
  final String capital;
  final int population;
  final String? border; 

  Country({
    required this.name,
    required this.capital,
    required this.population,
    this.border,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    // Parsing data dari API
    return Country(
      name: json['name']['common'] ?? 'N/A',
      capital: (json['capital'] as List<dynamic>?)?.first ?? 'N/A',
      population: json['population'] ?? 0,
      border: (json['borders'] as List<dynamic>?)?.first,
    );
  }

  @override
  String toString() {
    return 'Country(name: $name, capital: $capital, population: $population, firstBorder: $border)';
  }
}