import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter_application/pages/landing_screen.dart';
import 'amplifyconfiguration.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';



Future<void> _configureAmplify() async {
  try {
    await Amplify.addPlugin(AmplifyAuthCognito());
    await Amplify.configure(amplifyconfig);
    safePrint('Successfully configured');
  } on Exception catch (e) {
    safePrint('Error configuring Amplify: $e');
  }
}

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await _configureAmplify();
    runApp(const MyApp());
  } on AmplifyException catch (e) {
    runApp(Text('Error configuring Amplify: ${e.message}'));
  }

  // runApp(const MaterialApp(
  //   home: MyApp(),
  // ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // return TextBox();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LandingPage(),
    );

    // return Authenticator(
    //   // signUpForm: SignUpForm.custom(fields: [
    //   //   SignUpFormField.username(),
    //   //   SignUpFormField.email(),
    //   //   SignUpFormField.password(),
    //   //   SignUpFormField.passwordConfirmation(),
    //   //   SignUpFormField.birthdate(required: true),
    //   // ]),
    //   child: MaterialApp(
    //
    //     builder: Authenticator.builder(),
    //     home: const Scaffold(
    //       body: Center(
    //         child: Column(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: [
    //             SignOutButton(),
    //           ],
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}

