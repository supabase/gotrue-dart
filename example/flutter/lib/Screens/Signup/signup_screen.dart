import 'package:flutter/material.dart';
import 'package:gotrue_dart_example/Screens/Welcome/welcome_screen.dart';
import 'package:gotrue_dart_example/components/alert_modal.dart';
import 'package:gotrue_dart_example/components/link_button.dart';
import 'package:gotrue_dart_example/components/rounded_button.dart';
import 'package:gotrue_dart_example/components/rounded_input_field.dart';
import 'package:gotrue_dart_example/components/rounded_password_field.dart';
import 'package:gotrue_dart_example/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class SignUpScreen extends StatelessWidget {
  var email = '';
  var password = '';

  void _onSignUpPress(BuildContext context) async {
    final response = await gotrueClient.signUp(email, password);
    if (response.error != null) {
      alertModal.show(context,
          title: 'Sign up failed', message: response.error.message);
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString(PERSIST_SESSION_KEY, response.data.persistSessionString);
      final title = 'Welcome ${response.data.user.email}';
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return WelcomeScreen(title);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 25.0),
            RoundedInputField(
              hintText: "Email address",
              onChanged: (value) {
                email = value;
              },
            ),
            SizedBox(height: 25.0),
            RoundedPasswordField(
              onChanged: (value) {
                password = value;
              },
            ),
            SizedBox(
              height: 35.0,
            ),
            RoundedButton(
              text: "Sign up",
              press: () {
                _onSignUpPress(context);
              },
            ),
            SizedBox(
              height: 35.0,
            ),
            LinkButton(
                text: "Already have an Account ? Sign in",
                press: () {
                  Navigator.of(context).pushReplacementNamed(SIGNIN_SCREEN);
                }),
          ],
        ),
      ),
    );
  }
}
