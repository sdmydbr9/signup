import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'api_functions.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
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

  void _onCountryChanged(String countryName) async {
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

  void _onStateChanged(String stateName) async {
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
        middle: Text('ClinicPaws App'),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              hint: Text('Select Country'),
              value: selectedCountryName,
              onChanged: (newValue) {
                if (newValue != null) {
                  _onCountryChanged(newValue);
                }
              },
              items: countries.map((country) {
                return DropdownMenuItem<String>(
                  value: country.name,
                  child: Text(country.name),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            DropdownButton<String>(
              hint: Text('Select State'),
              value: selectedStateName,
              onChanged: (newValue) {
                if (newValue != null) {
                  _onStateChanged(newValue);
                }
              },
              items: states.map((state) {
                return DropdownMenuItem<String>(
                  value: state.name,
                  child: Text(state.name),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            DropdownButton<String>(
              hint: Text('Select City'),
              value: selectedCityName,
              onChanged: (newValue) {
                setState(() {
                  selectedCityName = newValue;
                });
                print('Selected city: $newValue');
              },
              items: cities.map((city) {
                return DropdownMenuItem<String>(
                  value: city.name,
                  child: Text(city.name),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
