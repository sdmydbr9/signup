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
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _verifyPasswordController =
      TextEditingController();

  List<String> countries = [];
  List<String> states = [];
  List<String> cities = [];

  bool isStateEnabled = false;
  bool isCityEnabled = false;
  bool isStateLoading = false;
  bool isCityLoading = false;
  bool _passwordVisible = false;
  bool _verifyPasswordVisible = false;

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
    _streetController.dispose();
    _firstNameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _verifyPasswordController.dispose();
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

  String? _validateRequiredField(String value) {
    if (value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  Widget buildTextField(String label, TextEditingController controller,
      {bool obscureText = false,
      TextInputType keyboardType = TextInputType.text,
      String? Function(String)? validator,
      bool enableToggle = false,
      bool isPasswordField = false,
      bool isVerifyPasswordField = false,
      IconData? icon}) {
    final theme = CupertinoTheme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 24),
              SizedBox(width: 8),
              Container(
                width: 100, // Adjust width to ensure label visibility
                child: Text(
                  label,
                  style: theme.textTheme.textStyle, // Apply text theme here
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    CupertinoTextField(
                      controller: controller,
                      placeholder: '$label',
                      obscureText: obscureText
                          ? !(isPasswordField
                              ? _passwordVisible
                              : isVerifyPasswordField
                                  ? _verifyPasswordVisible
                                  : false)
                          : false,
                      keyboardType: keyboardType,
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                    if (enableToggle)
                      Positioned(
                        right: 0,
                        child: CupertinoButton(
                          padding: EdgeInsets.all(0),
                          onPressed: () {
                            setState(() {
                              if (isPasswordField) {
                                _passwordVisible = !_passwordVisible;
                              } else if (isVerifyPasswordField) {
                                _verifyPasswordVisible =
                                    !_verifyPasswordVisible;
                              }
                            });
                          },
                          child: Icon(
                            (isPasswordField
                                    ? _passwordVisible
                                    : isVerifyPasswordField
                                        ? _verifyPasswordVisible
                                        : false)
                                ? CupertinoIcons.eye
                                : CupertinoIcons.eye_slash,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (validator != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  validator(controller.text) ?? '',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _handleSignUp() {
    // Handle sign up logic here
    final isValid = [
      _validateRequiredField(_firstNameController.text),
      _validateRequiredField(_surnameController.text),
      _validateRequiredField(_emailController.text),
      _validateRequiredField(_phoneController.text),
      _validatePassword(_passwordController.text),
      _validateReenteredPassword(_verifyPasswordController.text),
    ].every((element) => element == null);

    if (isValid) {
      // Perform sign up action
      print('Sign Up Successful');
    } else {
      print('Sign Up Failed: Please fill in all required fields');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

    return CupertinoPageScaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            backgroundColor: Colors.transparent,
            largeTitle: Text('Sign Up'),
          ),
          SliverFillRemaining(
            hasScrollBody:
                false, // Make sure the body can expand to fill the space
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  buildTextField(
                    'First Name',
                    _firstNameController,
                    validator: _validateRequiredField,
                    icon: CupertinoIcons.person,
                  ),
                  buildTextField(
                    'Surname',
                    _surnameController,
                    validator: _validateRequiredField,
                    icon: CupertinoIcons.person_2,
                  ),
                  buildTextField(
                    'Email',
                    _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateRequiredField,
                    icon: CupertinoIcons.mail,
                  ),
                  buildTextField(
                    'Phone',
                    _phoneController,
                    keyboardType: TextInputType.phone,
                    validator: _validateRequiredField,
                    icon: CupertinoIcons.phone,
                  ),
                  buildTextField(
                    'Password',
                    _passwordController,
                    obscureText: true,
                    validator: _validatePassword,
                    enableToggle: true,
                    isPasswordField: true,
                    icon: CupertinoIcons.lock,
                  ),
                  buildTextField(
                    'Verify Password',
                    _verifyPasswordController,
                    obscureText: true,
                    validator: _validateReenteredPassword,
                    enableToggle: true,
                    isVerifyPasswordField: true,
                    icon: CupertinoIcons.lock,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.globe, size: 24),
                        SizedBox(width: 8),
                        Container(
                          width: 100,
                          child: Text(
                            'Country',
                            style: theme.textTheme.textStyle,
                          ),
                        ),
                        Expanded(
                          child: CupertinoDropdown(
                            controller: _countryController,
                            items: countries,
                            onSelected: (country) {
                              _countryController.text = country;
                              _fetchStates(country);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.location, size: 24),
                        SizedBox(width: 8),
                        Container(
                          width: 100,
                          child: Text(
                            'State',
                            style: theme.textTheme.textStyle,
                          ),
                        ),
                        Expanded(
                          child: isStateLoading
                              ? Center(child: CupertinoActivityIndicator())
                              : CupertinoDropdown(
                                  controller: _stateController,
                                  items: states,
                                  enabled: isStateEnabled,
                                  onSelected: (state) {
                                    _stateController.text = state;
                                    _fetchCities(
                                        _countryController.text, state);
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.location_solid, size: 24),
                        SizedBox(width: 8),
                        Container(
                          width: 100,
                          child: Text(
                            'City',
                            style: theme.textTheme.textStyle,
                          ),
                        ),
                        Expanded(
                          child: isCityLoading
                              ? Center(child: CupertinoActivityIndicator())
                              : CupertinoDropdown(
                                  controller: _cityController,
                                  items: cities,
                                  enabled: isCityEnabled,
                                  onSelected: (city) {
                                    _cityController.text = city;
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                  buildTextField('Street', _streetController,
                      icon: CupertinoIcons.home),
                  SizedBox(height: 20), // Space before the button
                  CupertinoButton.filled(
                    child: Text('Sign Up'),
                    onPressed: _handleSignUp,
                  ),
                  SizedBox(height: 50), // Space below the button
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
