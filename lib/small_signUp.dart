import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';

class SmallSignUp extends StatefulWidget {
  @override
  _SmallSignUpState createState() => _SmallSignUpState();
}

class _SmallSignUpState extends State<SmallSignUp> {
  String? _selectedCountry;
  String? _selectedState;
  String? _selectedCity;

  List<String> _countries = [];
  List<String> _states = [];
  List<String> _cities = [];

  bool _isLoadingCountries = false;
  bool _isLoadingStates = false;
  bool _isLoadingCities = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _reenterPasswordController = TextEditingController();
  final _streetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCountries();
  }

  Future<void> _fetchCountries() async {
    setState(() {
      _isLoadingCountries = true;
    });
    try {
      List<String> countries = await ApiService.fetchCountries();
      setState(() {
        _countries = countries;
        _countries.sort();
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isLoadingCountries = false;
      });
    }
  }

  Future<void> _fetchStates(String country) async {
    setState(() {
      _isLoadingStates = true;
    });
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
    } finally {
      setState(() {
        _isLoadingStates = false;
      });
    }
  }

  Future<void> _fetchCities(String state) async {
    setState(() {
      _isLoadingCities = true;
    });
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
    } finally {
      setState(() {
        _isLoadingCities = false;
      });
    }
  }

  void _showPicker(
      BuildContext context,
      List<String> items,
      String? selectedItem,
      void Function(String) onSelectedItemChanged,
      Function onDone) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Container(
              height: 200,
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(
                  initialItem:
                      selectedItem != null ? items.indexOf(selectedItem) : 0,
                ),
                itemExtent: 32,
                onSelectedItemChanged: (index) {
                  onSelectedItemChanged(items[index]);
                },
                children: items.map((item) => Text(item)).toList(),
              ),
            ),
            CupertinoButton(
              child: Text('Done'),
              onPressed: () {
                onDone();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String labelText, Widget inputField) {
    final theme = CupertinoTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              labelText,
              style: TextStyle(
                fontSize: 16.0,
                color: theme.textTheme.textStyle.color,
              ),
            ),
          ),
          Expanded(flex: 3, child: inputField),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final backgroundColor = CupertinoColors.systemGrey5.resolveFrom(context);
    final textFieldDecoration = BoxDecoration(
      color: theme.barBackgroundColor,
      borderRadius: BorderRadius.circular(8.0),
    );
    final textFieldStyle = TextStyle(color: theme.textTheme.textStyle.color);

    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            largeTitle: Text('Sign Up'),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            _buildRow(
                              'Name',
                              CupertinoTextField(
                                controller: _nameController,
                                placeholder: 'required',
                                placeholderStyle: textFieldStyle,
                                padding: EdgeInsets.all(8.0),
                                decoration: textFieldDecoration,
                              ),
                            ),
                            Divider(indent: 16, endIndent: 0),
                            _buildRow(
                              'Email',
                              CupertinoTextField(
                                controller: _emailController,
                                placeholder: 'required',
                                placeholderStyle: textFieldStyle,
                                keyboardType: TextInputType.emailAddress,
                                padding: EdgeInsets.all(8.0),
                                decoration: textFieldDecoration,
                              ),
                            ),
                            Divider(indent: 16, endIndent: 0),
                            _buildRow(
                              'Phone',
                              CupertinoTextField(
                                controller: _phoneController,
                                placeholder: 'required',
                                placeholderStyle: textFieldStyle,
                                keyboardType: TextInputType.phone,
                                padding: EdgeInsets.all(8.0),
                                decoration: textFieldDecoration,
                              ),
                            ),
                            Divider(indent: 16, endIndent: 0),
                            _buildRow(
                              'Password',
                              CupertinoTextField(
                                controller: _passwordController,
                                placeholder: 'required',
                                placeholderStyle: textFieldStyle,
                                obscureText: true,
                                padding: EdgeInsets.all(8.0),
                                decoration: textFieldDecoration,
                              ),
                            ),
                            Divider(indent: 16, endIndent: 0),
                            _buildRow(
                              'Re-enter Password',
                              CupertinoTextField(
                                controller: _reenterPasswordController,
                                placeholder: 'required',
                                placeholderStyle: textFieldStyle,
                                obscureText: true,
                                padding: EdgeInsets.all(8.0),
                                decoration: textFieldDecoration,
                              ),
                            ),
                            Divider(indent: 16, endIndent: 0),
                            _isLoadingCountries
                                ? CupertinoActivityIndicator()
                                : _buildRow(
                                    'Country',
                                    CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      child: Text(
                                          _selectedCountry ?? 'Select Country'),
                                      onPressed: () {
                                        _showPicker(context, _countries,
                                            _selectedCountry, (newValue) {
                                          setState(() {
                                            _selectedCountry = newValue;
                                          });
                                        }, () {
                                          _fetchStates(_selectedCountry!);
                                        });
                                      },
                                    ),
                                  ),
                            Divider(indent: 16, endIndent: 0),
                            _isLoadingStates
                                ? CupertinoActivityIndicator()
                                : _buildRow(
                                    'State',
                                    CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      child: Text(
                                          _selectedState ?? 'Select State'),
                                      onPressed: _selectedCountry == null
                                          ? null
                                          : () {
                                              _showPicker(context, _states,
                                                  _selectedState, (newValue) {
                                                setState(() {
                                                  _selectedState = newValue;
                                                });
                                              }, () {
                                                _fetchCities(_selectedState!);
                                              });
                                            },
                                    ),
                                  ),
                            Divider(indent: 16, endIndent: 0),
                            _isLoadingCities
                                ? CupertinoActivityIndicator()
                                : _buildRow(
                                    'City',
                                    CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      child:
                                          Text(_selectedCity ?? 'Select City'),
                                      onPressed: _selectedState == null
                                          ? null
                                          : () {
                                              _showPicker(context, _cities,
                                                  _selectedCity, (newValue) {
                                                setState(() {
                                                  _selectedCity = newValue;
                                                });
                                              }, () {});
                                            },
                                    ),
                                  ),
                            Divider(indent: 16, endIndent: 0),
                            _buildRow(
                              'Street',
                              CupertinoTextField(
                                controller: _streetController,
                                placeholder: 'required',
                                placeholderStyle: textFieldStyle,
                                padding: EdgeInsets.all(8.0),
                                decoration: textFieldDecoration,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32.0),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                CupertinoButton.filled(
                  child: Text('Sign Up'),
                  onPressed: () {
                    // Handle sign up action
                  },
                ),
                SizedBox(height: 32.0),
                Text(
                  'Copyright ClinicPaws',
                  style: TextStyle(
                    color: theme.textTheme.textStyle.color,
                    fontSize: 14.0,
                  ),
                ),
                SizedBox(height: 50.0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
