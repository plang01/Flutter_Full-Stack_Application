import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cognito_manual2/screens/test_login.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  Future<void> signOut(BuildContext context) async {
    try {
      final result = await Amplify.Auth.signOut();
      if (result is CognitoCompleteSignOut) {
        _gotoLogInScreen(context);
      }
    } on CognitoFailedSignOut catch (e) {
      safePrint('Error with signing out: ${e.exception.message}');
    }
  }

  void _gotoLogInScreen(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
            onPressed: () => signOut(context),
            child: Text('Sign Out'), 
          ),
        ),
    );
  }
}



