import 'package:flutter/material.dart';
import 'package:gotrue_dart_example/Screens/PasswordRecover/password_recover.dart';
import 'package:gotrue_dart_example/Screens/Signin/signin_screen.dart';
import 'package:gotrue_dart_example/Screens/Signup/signup_screen.dart';
import 'package:gotrue_dart_example/Screens/splash_screen.dart';
import 'package:gotrue_dart_example/constants.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gotrue Demo',
      home: SplashScreen(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: <String, WidgetBuilder>{
        SPLASH_SCREEN: (BuildContext context) => SplashScreen(),
        SIGNIN_SCREEN: (BuildContext context) => SignInScreen(),
        SIGNUP_SCREEN: (BuildContext context) => SignUpScreen(),
        PASSWORDRECOVER_SCREEN: (BuildContext context) =>
            PasswordRecoverScreen(),
      },
    );
  }
}
