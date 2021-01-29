import 'package:flutter/material.dart';
import 'package:gotrue_dart_example/components/alert_modal.dart';
import 'package:gotrue_dart_example/components/link_button.dart';
import 'package:gotrue_dart_example/components/rounded_button.dart';
import 'package:gotrue_dart_example/components/rounded_input_field.dart';
import 'package:gotrue_dart_example/constants.dart';

// ignore: must_be_immutable
class PasswordRecoverScreen extends StatelessWidget {
  var email = '';

  void _onPasswordRecoverPress(BuildContext context) async {
    final response = await gotrueClient.api.resetPasswordForEmail(email);
    if (response.error != null) {
      alertModal.show(context,
          title: 'Send password recovery failed',
          message: response.error.message);
    } else {
      alertModal.show(context,
          title: 'Password recovery email sent',
          message: 'Please check your email for further instructions.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot password'),
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
            SizedBox(
              height: 35.0,
            ),
            RoundedButton(
              text: "Send reset password instructions",
              press: () {
                _onPasswordRecoverPress(context);
              },
            ),
            SizedBox(
              height: 35.0,
            ),
            LinkButton(
                text: "Go back to sign in",
                press: () {
                  Navigator.of(context).pushReplacementNamed(SIGNIN_SCREEN);
                }),
          ],
        ),
      ),
    );
  }
}
