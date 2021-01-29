import 'package:flutter/material.dart';
import 'package:gotrue_client/gotrue_client.dart';
import 'package:gotrue_dart_example/Screens/Signin/signin_screen.dart';
import 'package:gotrue_dart_example/components/alert_modal.dart';
import 'package:gotrue_dart_example/components/rounded_button.dart';
import 'package:gotrue_dart_example/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeScreen extends StatefulWidget {
  final String _appBarTitle;

  WelcomeScreen(this._appBarTitle, {Key key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState(_appBarTitle);
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final String _appBarTitle;
  User user;

  _WelcomeScreenState(this._appBarTitle);

  @override
  void initState() {
    super.initState();

    setState(() {
      final clientUser = gotrueClient.user();
      if (clientUser != null) user = clientUser;
    });
  }

  void _onSignOutPress(BuildContext context) async {
    final response = await gotrueClient.signOut();
    if (response.error == null) {
      alertModal.show(context,
          title: 'Sign out failed', message: response.error.message);
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove(PERSIST_SESSION_KEY);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return SignInScreen();
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this._appBarTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 25.0),
            Text(
              user?.toJson().toString() ?? 'Loading user...',
            ),
            SizedBox(
              height: 35.0,
            ),
            RoundedButton(
              text: "Sign out",
              press: () {
                _onSignOutPress(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
