import 'package:cognito_manual2/screens/confirmation_screen.dart';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

class SignUp extends StatefulWidget {
  SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();

  bool _signUpError = false;
  String _errorMessage = '';
  
  void setError({required String errMessage}) {
    setState(() {
      _signUpError = true;
      _errorMessage = errMessage;
    }); 
  }

  Future<void> _createAccountOnPressed(BuildContext context) async {
      // Convert controller to text
      final email = _emailController.text;
      final password = _passwordController.text;
      final userName = _userNameController.text;

      try {
      final result = await Amplify.Auth.signUp(

        username: userName, 
        password: password,
        options: SignUpOptions(
          userAttributes: {
             AuthUserAttributeKey.email: email
          })
      );
      if(result.nextStep.signUpStep == AuthSignUpStep.confirmSignUp) {
          _gotToEmailConfirmationScreen(context, userName);
      }
      } on AuthException  catch(e) {
          setError(errMessage: e.message);
      }
  }

  void _gotToEmailConfirmationScreen(BuildContext context, String username) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Confirmation(email: username),
      ),
    ); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign up"),
      ),
      body: Form(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "Username"),
                controller: _userNameController,
              ),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: "Email"),
                controller: _emailController,
              ),
              TextFormField(
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
                controller: _passwordController,
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  child: Text("CREATE ACCOUNT"),
                  onPressed: () => _createAccountOnPressed(context),
              ),
              _signUpError ? Text('${_errorMessage}') : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}


