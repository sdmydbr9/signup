import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://api.clinicpaws.com';

  static Future<List<String>> fetchCountries() async {
    final response = await http.get(Uri.parse('$baseUrl/countries'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<String>.from(data['countries']);
    } else {
      throw Exception('Failed to load countries');
    }
  }

  static Future<List<String>> fetchStates(String country) async {
    final response = await http.get(Uri.parse('$baseUrl/id?country=$country'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final countryId = data['id'];
      final stateResponse =
          await http.get(Uri.parse('$baseUrl/state?countryid=$countryId'));
      if (stateResponse.statusCode == 200) {
        final stateData = json.decode(stateResponse.body);
        return List<Map<String, dynamic>>.from(stateData['states'])
            .map((state) => state['name'].toString())
            .toList();
      } else {
        throw Exception('Failed to load states');
      }
    } else {
      throw Exception('Failed to load country ID');
    }
  }

  static Future<List<String>> fetchCities(String country, String state) async {
    final countryResponse =
        await http.get(Uri.parse('$baseUrl/id?country=$country'));
    if (countryResponse.statusCode == 200) {
      final countryData = json.decode(countryResponse.body);
      final countryId = countryData['id'];
      final cityResponse = await http
          .get(Uri.parse('$baseUrl/city?countryid=$countryId&state=$state'));
      if (cityResponse.statusCode == 200) {
        final cityData = json.decode(cityResponse.body);
        return List<Map<String, dynamic>>.from(cityData['cities'])
            .map((city) => city['name'].toString())
            .toList();
      } else {
        throw Exception('Failed to load cities');
      }
    } else {
      throw Exception('Failed to load country ID');
    }
  }
}
