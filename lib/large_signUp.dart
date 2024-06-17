import 'package:flutter/material.dart';
import 'api_service.dart';

class LargeSignUp extends StatefulWidget {
  @override
  _LargeSignUpState createState() => _LargeSignUpState();
}

class _LargeSignUpState extends State<LargeSignUp> {
  String? _selectedCountry;
  String? _selectedState;
  String? _selectedCity;

  List<String> _countries = [];
  List<String> _states = [];
  List<String> _cities = [];

  @override
  void initState() {
    super.initState();
    _fetchCountries();
  }

  Future<void> _fetchCountries() async {
    try {
      List<String> countries = await ApiService.fetchCountries();
      setState(() {
        _countries = countries;
        _countries.sort();
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _fetchStates(String country) async {
    try {
      List<String> states = await ApiService.fetchStates(country);
      setState(() {
        _states = states;
        _states.sort();
        _selectedState = null;
        _cities = [];
        _selectedCity = null;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _fetchCities(String state) async {
    try {
      List<String> cities =
          await ApiService.fetchCities(_selectedCountry!, state);
      setState(() {
        _cities = cities;
        _cities.sort();
        _selectedCity = null;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          DropdownButton<String>(
            hint: Text('Select Country'),
            value: _selectedCountry,
            onChanged: (newValue) {
              setState(() {
                _selectedCountry = newValue;
                _fetchStates(newValue!);
              });
            },
            items: _countries.map((country) {
              return DropdownMenuItem<String>(
                child: Text(country),
                value: country,
              );
            }).toList(),
          ),
          SizedBox(height: 16.0),
          DropdownButton<String>(
            hint: Text('Select State'),
            value: _selectedState,
            onChanged: _selectedCountry == null
                ? null
                : (newValue) {
                    setState(() {
                      _selectedState = newValue;
                      _fetchCities(newValue!);
                    });
                  },
            items: _states.map((state) {
              return DropdownMenuItem<String>(
                child: Text(state),
                value: state,
              );
            }).toList(),
          ),
          SizedBox(height: 16.0),
          DropdownButton<String>(
            hint: Text('Select City'),
            value: _selectedCity,
            onChanged: _selectedState == null
                ? null
                : (newValue) {
                    setState(() {
                      _selectedCity = newValue;
                    });
                  },
            items: _cities.map((city) {
              return DropdownMenuItem<String>(
                child: Text(city),
                value: city,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
