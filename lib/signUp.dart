import 'package:flutter/material.dart';
import 'small_signUp.dart';
import 'large_signUp.dart';

class SignupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return SmallSignUp();
          } else {
            return LargeSignUp();
          }
        },
      ),
    );
  }
}
