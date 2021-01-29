import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gotrue_dart_example/Screens/Welcome/welcome_screen.dart';
import 'package:gotrue_dart_example/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => new SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  void showSignIn() {
    var _duration = new Duration(seconds: 1);
    new Timer(_duration, () {
      Navigator.of(context).pushReplacementNamed(SIGNIN_SCREEN);
    });
  }

  void showWelcome(String title) {
    var _duration = new Duration(seconds: 1);
    new Timer(_duration, () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return WelcomeScreen(title);
          },
        ),
      );
    });
  }

  void _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    bool exist = prefs.containsKey(PERSIST_SESSION_KEY);
    if (!exist) {
      return showSignIn();
    }

    String jsonStr = prefs.getString(PERSIST_SESSION_KEY);
    final response = await gotrueClient.recoverSession(jsonStr);
    if (response.error != null) {
      prefs.remove(PERSIST_SESSION_KEY);
      return showSignIn();
    }

    prefs.setString(PERSIST_SESSION_KEY, response.data.persistSessionString);
    final title = 'Welcome ${response.data.user.email}';
    showWelcome(title);
  }

  @override
  void initState() {
    super.initState();

    _restoreSession();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.white,
          child: SizedBox(
            height: 155.0,
            child: Image.asset(
              "assets/images/logo.png",
            ),
          ),
        ),
      ),
    );
  }
}
