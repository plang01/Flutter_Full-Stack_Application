import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter_application/pages/input_box.dart';
import 'package:flutter_application/pages/signup_screen.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool signUpError = false;
  String errorMessage = '';

  void setError({required String errMessage}) {
    setState(() {
      signUpError = true;
      errorMessage = errMessage;
    });
  }

  Future<void> loginButton(BuildContext context) async {
    final username = usernameController.text;
    final password = passwordController.text;
    print('Username: $username');
    print('Password: $password');

    // User still signed in if the application is refresh, therefore call signOut before attempting to sign in
    try {
      await Amplify.Auth.signOut();
    } on AuthException catch (e) {
      print('Error Signing Out');
    }

    try {
      final result = await Amplify.Auth.signIn(
          username: username,
          password: password,
      );
      await handleSignInResult(context, result);
    } on AuthException catch (e) {
      setError(errMessage: e.toString());
    }
  }

  void initState() {
    usernameController.text = 'plang1286@gmail.com';
    passwordController.text = 'Plang-128612';
  }

  void signupButton() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => SignupScreen()));
  }

  Future<void> handleSignInResult(BuildContext context, SignInResult result) async {
    final String username = usernameController.text;

    print('Next Step ${result.nextStep.signInStep}');

    if(result.nextStep.signInStep == AuthSignInStep.done) {
      AuthUser user = await Amplify.Auth.getCurrentUser();
      // CognitoAuthSession session = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
      // String idToken = (session as CognitoAuthSession).userPoolTokensResult!.idToken!;
      // var idToken = session.userPoolTokensResult.value as String;

      // Map<String, dynamic> decodedToken = JwtDecoder.decode(idToken);
      // List<dynamic> groups = decodedToken['cognito:groups'];

     var u = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
     var idToken = u.userPoolTokensResult.value;
     var stringToken = idToken.idToken.groups;
     // Map<String, dynamic> decodedToken = JwtDecoder.decode(u.userPoolTokensResult);
       // options: CognitoSessionOptions(getAWSCredentials: true),
     print(stringToken);



      // if (groups.contains('admin')) {
      //   print('Wow');
      // }
      // else if (groups.contains('client')) {
      //   print('Wow Indeed');
      // }
      // else {
      //   print('Bruh');
      // }

      gotoHomeScreen(context);
    }
  }

  void gotoHomeScreen(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => TextBox()));
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Landing Page'),
        centerTitle: true,
      ),
      body: Form(
        child: Padding(
          padding: const EdgeInsets.all(50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: 'Username'),
                controller: usernameController,
              ),
              TextFormField(
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                controller: passwordController,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        loginButton(context);
                      },
                      child: Text('Log In')
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                      onPressed: () {
                        signupButton();
                      },
                      child: Text('Sign Up')
                  ),
                ],
              ),
              signUpError ? Text(errorMessage) : SizedBox(),
            ],
          ),
        )
      ),
    );
  }
}

