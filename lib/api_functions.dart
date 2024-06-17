import 'dart:convert';
import 'package:http/http.dart' as http;

class Country {
  final String name;

  Country({required this.name});

  factory Country.fromJson(String name) {
    return Country(
      name: name,
    );
  }
}

class AppState {
  final String name;

  AppState({required this.name});

  factory AppState.fromJson(String name) {
    return AppState(
      name: name,
    );
  }
}

class City {
  final String name;

  City({required this.name});

  factory City.fromJson(String name) {
    return City(
      name: name,
    );
  }
}

class ApiService {
  static const String baseUrl = 'http://api.clinicpaws.com';

  Future<List<Country>> fetchCountries() async {
    final response = await http.get(Uri.parse('$baseUrl/countries'));
    _debugRequest(response);
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((name) => Country.fromJson(name)).toList();
    } else {
      throw Exception('Failed to load countries');
    }
  }

  Future<String> fetchCountryId(String countryName) async {
    final response = await http.get(Uri.parse('$baseUrl/id/$countryName'));
    _debugRequest(response);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load country ID');
    }
  }

  Future<List<AppState>> fetchStates(String countryId) async {
    final response = await http.get(Uri.parse('$baseUrl/$countryId/states'));
    _debugRequest(response);
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((name) => AppState.fromJson(name)).toList();
    } else {
      throw Exception('Failed to load states');
    }
  }

  Future<List<City>> fetchCities(String countryId, String stateName) async {
    final response =
        await http.get(Uri.parse('$baseUrl/$countryId/$stateName/city'));
    _debugRequest(response);
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((name) => City.fromJson(name)).toList();
    } else {
      throw Exception('Failed to load cities');
    }
  }

  void _debugRequest(http.Response response) {
    print('Request URL: ${response.request!.url}');
    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
  }
}
