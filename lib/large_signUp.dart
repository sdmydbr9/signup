import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'cupertino_dropdown.dart';
import 'api_service.dart';

class LargeSignUp extends StatefulWidget {
  @override
  _LargeSignUpState createState() => _LargeSignUpState();
}

class _LargeSignUpState extends State<LargeSignUp> {
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  List<String> countries = [];
  List<String> states = [];
  List<String> cities = [];

  bool isStateEnabled = false;
  bool isCityEnabled = false;
  bool isStateLoading = false;
  bool isCityLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCountries();
  }

  @override
  void dispose() {
    _countryController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _fetchCountries() async {
    final fetchedCountries = await ApiService.fetchCountries();
    setState(() {
      countries = fetchedCountries;
    });
  }

  Future<void> _fetchStates(String country) async {
    setState(() {
      isStateLoading = true;
      states = [];
      isStateEnabled = false;
      _stateController.clear();
      _cityController.clear();
      isCityEnabled = false;
    });

    final fetchedStates = await ApiService.fetchStates(country);
    setState(() {
      states = fetchedStates;
      isStateEnabled = states.isNotEmpty;
      isStateLoading = false;
    });
  }

  Future<void> _fetchCities(String country, String state) async {
    setState(() {
      isCityLoading = true;
      cities = [];
      isCityEnabled = false;
      _cityController.clear();
    });

    final fetchedCities = await ApiService.fetchCities(country, state);
    setState(() {
      cities = fetchedCities;
      isCityEnabled = cities.isNotEmpty;
      isCityLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Large Sign Up'),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select a country:'),
            SizedBox(height: 8),
            CupertinoDropdown(
              controller: _countryController,
              items: countries,
              onSelected: (country) {
                _countryController.text = country;
                _fetchStates(country);
              },
            ),
            SizedBox(height: 16),
            Text('Select a state:'),
            SizedBox(height: 8),
            isStateLoading
                ? Center(child: CupertinoActivityIndicator())
                : CupertinoDropdown(
                    controller: _stateController,
                    items: states,
                    enabled: isStateEnabled,
                    onSelected: (state) {
                      _stateController.text = state;
                      _fetchCities(_countryController.text, state);
                    },
                  ),
            SizedBox(height: 16),
            Text('Select a city:'),
            SizedBox(height: 8),
            isCityLoading
                ? Center(child: CupertinoActivityIndicator())
                : CupertinoDropdown(
                    controller: _cityController,
                    items: cities,
                    enabled: isCityEnabled,
                    onSelected: (city) {
                      _cityController.text = city;
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
