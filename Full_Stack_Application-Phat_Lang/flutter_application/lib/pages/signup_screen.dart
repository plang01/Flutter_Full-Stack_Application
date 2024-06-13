import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter_application/pages/email_confirmation_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool signupError = false;
  String errorMessage = '';

  void setError(String errMessage) {
    setState(() {
      signupError = true;
      errorMessage = errMessage;
    });
  }

  Future<void> signupButton(BuildContext context) async {
    final String email = emailController.text;
    // final String username = usernameController.text;
    final String password = passwordController.text;

    try {
      final result = await Amplify.Auth.signUp(
          username: email,
          password: password,
          options: SignUpOptions(
            userAttributes: {
              AuthUserAttributeKey.email : email
            })
      );

      await handleSignupResult(context, email, result);
    } on AuthException catch(e) {
      setError(e.toString());
    }
  }

  Future<void> handleSignupResult(BuildContext context, String username, SignUpResult result) async {
    if (result.nextStep.signUpStep == AuthSignUpStep.confirmSignUp) {
      gotoEmailConfirmationScreen(context, username);
    }
  }

  void gotoEmailConfirmationScreen(BuildContext context, String username) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ConfirmationScreen(email: username)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
        backgroundColor: Colors.blue,
      ),
      body: Form(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Username'),
                controller: usernameController,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                controller: emailController,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                keyboardType: TextInputType.visiblePassword,
                controller: passwordController,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () {
                    signupButton(context);
                  },
                  child: Text('Create Account')
              ),
              signupError ? Text(errorMessage) : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
