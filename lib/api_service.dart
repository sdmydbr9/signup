import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class ApiService {
  static const String primaryBaseUrl = 'http://api.clinicpaws.com';
  static const String fallbackBaseUrl = 'https://apis.clinicpaws.com';

  static Future<http.Response> _getWithFallback(String endpoint) async {
    try {
      final response = await http
          .get(Uri.parse('$primaryBaseUrl$endpoint'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception('Failed to load data from primary URL');
      }
    } on Exception catch (_) {
      final response = await http
          .get(Uri.parse('$fallbackBaseUrl$endpoint'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception('Failed to load data from fallback URL');
      }
    }
  }

  static Future<List<String>> fetchCountries() async {
    final response = await _getWithFallback('/countries');
    final data = json.decode(response.body);
    return List<String>.from(data['countries']);
  }

  static Future<List<String>> fetchStates(String country) async {
    final response = await _getWithFallback('/id?country=$country');
    final data = json.decode(response.body);
    final countryId = data['id'];
    final stateResponse = await _getWithFallback('/state?countryid=$countryId');
    final stateData = json.decode(stateResponse.body);
    return List<Map<String, dynamic>>.from(stateData['states'])
        .map((state) => state['name'].toString())
        .toList();
  }

  static Future<List<String>> fetchCities(String country, String state) async {
    final countryResponse = await _getWithFallback('/id?country=$country');
    final countryData = json.decode(countryResponse.body);
    final countryId = countryData['id'];
    final cityResponse =
        await _getWithFallback('/city?countryid=$countryId&state=$state');
    final cityData = json.decode(cityResponse.body);
    return List<Map<String, dynamic>>.from(cityData['cities'])
        .map((city) => city['name'].toString())
        .toList();
  }
}
