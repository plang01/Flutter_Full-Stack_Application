import 'package:cognito_manual2/screens/home_screen.dart';
import 'package:cognito_manual2/screens/test_login.dart';
import 'package:flutter/material.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'amplifyconfiguration.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await _configureAmplify();
    runApp(const MyApp());
  } on AmplifyException catch (e) {
    runApp(Text("Error configuring Amplify: ${e.message}"));
  }
}


Future<void> _configureAmplify() async {
  try {
    await Amplify.addPlugin(AmplifyAuthCognito());
    await Amplify.configure(amplifyconfig);
    safePrint('Successfully configured');
  } on Exception catch (e) {
    safePrint('Error configuring Amplify: $e');
  }
}


// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: LoginScreen()
//       // home: Home()
//     );
//   }
// }





class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {

    return Authenticator(
      // signUpForm: SignUpForm.custom(fields: [
      //   SignUpFormField.username(),
      //   SignUpFormField.email(),
      //   SignUpFormField.password(),
      //   SignUpFormField.passwordConfirmation(),
      //   SignUpFormField.birthdate(required: true),
      // ]),
      child: MaterialApp(

        builder: Authenticator.builder(),
        home: const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SignOutButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
