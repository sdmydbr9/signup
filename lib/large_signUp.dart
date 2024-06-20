import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:signup/cupertino_typeahead.dart';

class LargeSignUp extends StatefulWidget {
  @override
  _LargeSignUpState createState() => _LargeSignUpState();
}

class _LargeSignUpState extends State<LargeSignUp> {
  final TextEditingController _controller = TextEditingController();
  final List<String> vegetables = [
    "carrot",
    "potato",
    "onion",
    "tomato",
    "cucumber",
    "broccoli",
  ];

  @override
  void initState() {
    super.initState();
    print('LargeSignUpState initialized');
  }

  @override
  void dispose() {
    _controller.dispose();
    print('LargeSignUpState disposed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('Building LargeSignUp widget');

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Large Sign Up'),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter a vegetable:'),
            SizedBox(height: 8),
            CupertinoTypeAhead(
              controller: _controller,
              suggestions: vegetables,
              onSelected: (vegetable) {
                print('Selected: $vegetable');
              },
            ),
          ],
        ),
      ),
    );
  }
}
