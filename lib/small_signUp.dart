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

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _reenterPasswordController = TextEditingController();
  final _streetController = TextEditingController();

  String? _passwordError;
  String? _reenterPasswordError;

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

  Widget _buildRow(String labelText, Widget inputField, Icon icon) {
    final theme = CupertinoTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon.icon, color: CupertinoColors.systemGrey),
          SizedBox(width: 8),
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

  String? _validatePassword(String value) {
    if (value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8 || value.length > 16) {
      return 'Password must be 8-16 characters long';
    }
    if (!RegExp(r'(?=.*?[A-Z])').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'(?=.*?[a-z])').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'(?=.*?[0-9])').hasMatch(value)) {
      return 'Password must contain at least one digit';
    }
    if (!RegExp(r'(?=.*?[#?!@$%^&*-])').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  String? _validateReenteredPassword(String value) {
    if (value.isEmpty) {
      return 'Re-entering password is required';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
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
    final placeholderStyle = textFieldStyle.copyWith(
      color: CupertinoColors.systemGrey2.resolveFrom(context),
    );

    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            backgroundColor: Colors.transparent,
            largeTitle: Text('Sign Up'),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
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
                                  placeholderStyle: placeholderStyle,
                                  textAlign: TextAlign.center,
                                  padding: EdgeInsets.all(8.0),
                                  decoration: textFieldDecoration,
                                  clearButtonMode:
                                      OverlayVisibilityMode.editing,
                                ),
                                Icon(CupertinoIcons.person),
                              ),
                              Divider(indent: 16, endIndent: 0),
                              _buildRow(
                                'Email',
                                CupertinoTextField(
                                  controller: _emailController,
                                  placeholder: 'required',
                                  placeholderStyle: placeholderStyle,
                                  keyboardType: TextInputType.emailAddress,
                                  textAlign: TextAlign.center,
                                  padding: EdgeInsets.all(8.0),
                                  decoration: textFieldDecoration,
                                  clearButtonMode:
                                      OverlayVisibilityMode.editing,
                                ),
                                Icon(CupertinoIcons.mail),
                              ),
                              Divider(indent: 16, endIndent: 0),
                              _buildRow(
                                'Phone',
                                CupertinoTextField(
                                  controller: _phoneController,
                                  placeholder: 'required',
                                  placeholderStyle: placeholderStyle,
                                  keyboardType: TextInputType.phone,
                                  textAlign: TextAlign.center,
                                  padding: EdgeInsets.all(8.0),
                                  decoration: textFieldDecoration,
                                  clearButtonMode:
                                      OverlayVisibilityMode.editing,
                                ),
                                Icon(CupertinoIcons.phone),
                              ),
                              Divider(indent: 16, endIndent: 0),
                              _buildRow(
                                'Password',
                                Column(
                                  children: [
                                    CupertinoTextField(
                                      controller: _passwordController,
                                      placeholder: 'required',
                                      placeholderStyle: placeholderStyle,
                                      obscureText: true,
                                      textAlign: TextAlign.center,
                                      padding: EdgeInsets.all(8.0),
                                      decoration: textFieldDecoration,
                                      clearButtonMode:
                                          OverlayVisibilityMode.editing,
                                      onChanged: (value) {
                                        setState(() {
                                          _passwordError =
                                              _validatePassword(value);
                                        });
                                      },
                                    ),
                                    if (_passwordError != null)
                                      Text(
                                        _passwordError!,
                                        style: TextStyle(
                                          color: CupertinoColors.destructiveRed,
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                                Icon(CupertinoIcons.lock),
                              ),
                              Divider(indent: 16, endIndent: 0),
                              _buildRow(
                                'Re-enter Password',
                                Column(
                                  children: [
                                    CupertinoTextField(
                                      controller: _reenterPasswordController,
                                      placeholder: 'required',
                                      placeholderStyle: placeholderStyle,
                                      obscureText: true,
                                      textAlign: TextAlign.center,
                                      padding: EdgeInsets.all(8.0),
                                      decoration: textFieldDecoration,
                                      clearButtonMode:
                                          OverlayVisibilityMode.editing,
                                      onChanged: (value) {
                                        setState(() {
                                          _reenterPasswordError =
                                              _validateReenteredPassword(value);
                                        });
                                      },
                                    ),
                                    if (_reenterPasswordError != null)
                                      Text(
                                        _reenterPasswordError!,
                                        style: TextStyle(
                                          color: CupertinoColors.destructiveRed,
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                                Icon(CupertinoIcons.lock),
                              ),
                              Divider(indent: 16, endIndent: 0),
                              _isLoadingCountries
                                  ? CupertinoActivityIndicator()
                                  : _buildRow(
                                      'Country',
                                      CupertinoButton(
                                        padding: EdgeInsets.zero,
                                        child: Text(_selectedCountry ??
                                            'Select Country'),
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
                                      Icon(CupertinoIcons.globe),
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
                                      Icon(CupertinoIcons.map),
                                    ),
                              Divider(indent: 16, endIndent: 0),
                              _isLoadingCities
                                  ? CupertinoActivityIndicator()
                                  : _buildRow(
                                      'City',
                                      CupertinoButton(
                                        padding: EdgeInsets.zero,
                                        child: Text(
                                            _selectedCity ?? 'Select City'),
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
                                      Icon(CupertinoIcons.location),
                                    ),
                              Divider(indent: 16, endIndent: 0),
                              _buildRow(
                                'Street',
                                CupertinoTextField(
                                  controller: _streetController,
                                  placeholder: 'optional',
                                  placeholderStyle: placeholderStyle,
                                  textAlign: TextAlign.center,
                                  padding: EdgeInsets.all(8.0),
                                  decoration: textFieldDecoration,
                                  clearButtonMode:
                                      OverlayVisibilityMode.editing,
                                ),
                                Icon(CupertinoIcons.home),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 32.0),
                      ],
                    ),
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
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _reenterPasswordError = _validateReenteredPassword(
                            _reenterPasswordController.text);
                      });
                      if (_passwordController.text !=
                          _reenterPasswordController.text) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CupertinoAlertDialog(
                              title: Text("Error"),
                              content: Text("Passwords do not match"),
                              actions: <Widget>[
                                CupertinoDialogAction(
                                  child: Text("OK"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                        return;
                      }

                      // Handle sign up action
                    }
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
