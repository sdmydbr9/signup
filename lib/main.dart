import 'package:flutter/cupertino.dart';
import 'signUp.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Country, State, City Selector',
      initialRoute: '/',
      routes: {
        '/': (context) => SignupScreen(),
      },
      builder: (context, child) {
        final brightness = MediaQuery.of(context).platformBrightness;
        final isDarkMode = brightness == Brightness.dark;

        return CupertinoTheme(
          data: CupertinoThemeData(
            brightness: brightness,
            primaryColor: CupertinoDynamicColor.withBrightness(
              color: CupertinoColors.black,
              darkColor: CupertinoColors.white,
            ),
            barBackgroundColor: CupertinoDynamicColor.withBrightness(
              color: CupertinoColors.systemGrey6,
              darkColor: CupertinoColors.black,
            ),
            scaffoldBackgroundColor: CupertinoDynamicColor.withBrightness(
              color: CupertinoColors.white,
              darkColor: CupertinoColors.black,
            ),
            textTheme: CupertinoTextThemeData(
              primaryColor: CupertinoDynamicColor.withBrightness(
                color: CupertinoColors.black,
                darkColor: CupertinoColors.white,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
