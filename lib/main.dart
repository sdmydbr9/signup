import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(SignupApp());

class SignupApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'ClinicPaws Signup',
      theme: CupertinoThemeData(
        primaryColor: CupertinoColors.systemBlue,
      ),
      home: Signup(),
    );
  }
}

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

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final ApiService apiService = ApiService();

  List<Country> countries = [];
  List<AppState> states = [];
  List<City> cities = [];

  String? selectedCountryName;
  String? selectedStateName;
  String? selectedCityName;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  void _loadCountries() async {
    try {
      final countriesList = await apiService.fetchCountries();
      setState(() {
        countries = countriesList;
      });
    } catch (e) {
      print('Error fetching countries: $e');
    }
  }

  void _onCountryChanged(String? countryName) async {
    if (countryName == null) return;
    setState(() {
      selectedCountryName = countryName;
      selectedStateName = null;
      selectedCityName = null;
      states.clear();
      cities.clear();
    });
    try {
      final countryId = await apiService.fetchCountryId(countryName);
      final statesList = await apiService.fetchStates(countryId);
      setState(() {
        states = statesList;
      });
    } catch (e) {
      print('Error fetching states: $e');
    }
  }

  void _onStateChanged(String? stateName) async {
    if (stateName == null) return;
    setState(() {
      selectedStateName = stateName;
      selectedCityName = null;
      cities.clear();
    });
    if (selectedCountryName != null) {
      try {
        final countryId = await apiService.fetchCountryId(selectedCountryName!);
        final citiesList = await apiService.fetchCities(countryId, stateName);
        setState(() {
          cities = citiesList;
        });
      } catch (e) {
        print('Error fetching cities: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('ClinicPaws Signup'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _showCountryPicker(context),
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: CupertinoColors.systemGrey,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    selectedCountryName ?? 'Select Country',
                    style: TextStyle(color: CupertinoColors.black),
                  ),
                ),
              ),
              SizedBox(height: 20),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: selectedCountryName != null
                    ? () => _showStatePicker(context)
                    : null,
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: selectedCountryName != null
                          ? CupertinoColors.systemGrey
                          : CupertinoColors.systemGrey4,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    selectedStateName ?? 'Select State',
                    style: TextStyle(color: CupertinoColors.black),
                  ),
                ),
              ),
              SizedBox(height: 20),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: selectedStateName != null
                    ? () => _showCityPicker(context)
                    : null,
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: selectedStateName != null
                          ? CupertinoColors.systemGrey
                          : CupertinoColors.systemGrey4,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    selectedCityName ?? 'Select City',
                    style: TextStyle(color: CupertinoColors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCountryPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          color: CupertinoColors.white,
          child: Column(
            children: [
              Container(
                height: 200,
                child: CupertinoPicker(
                  itemExtent: 32.0,
                  onSelectedItemChanged: (int index) {
                    if (index < countries.length) {
                      _onCountryChanged(countries[index].name);
                    }
                  },
                  children:
                      countries.map((country) => Text(country.name)).toList(),
                ),
              ),
              CupertinoButton(
                child: Text('Done'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showStatePicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          color: CupertinoColors.white,
          child: Column(
            children: [
              Container(
                height: 200,
                child: CupertinoPicker(
                  itemExtent: 32.0,
                  onSelectedItemChanged: (int index) {
                    if (index < states.length) {
                      _onStateChanged(states[index].name);
                    }
                  },
                  children: states.map((state) => Text(state.name)).toList(),
                ),
              ),
              CupertinoButton(
                child: Text('Done'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCityPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          color: CupertinoColors.white,
          child: Column(
            children: [
              Container(
                height: 200,
                child: CupertinoPicker(
                  itemExtent: 32.0,
                  onSelectedItemChanged: (int index) {
                    if (index < cities.length) {
                      setState(() {
                        selectedCityName = cities[index].name;
                      });
                    }
                  },
                  children: cities.map((city) => Text(city.name)).toList(),
                ),
              ),
              CupertinoButton(
                child: Text('Done'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
