import 'package:cognito_manual2/screens/home_screen.dart';
import 'package:cognito_manual2/screens/mfa_qrcode_screen.dart';
import 'package:cognito_manual2/screens/mfa_screen.dart';
import 'package:cognito_manual2/screens/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _signUpError = false;
  String _errorMessage = '';
  
  void setError({required String errMessage}) {
    setState(() {
      _signUpError = true;
      _errorMessage = errMessage;
    }); 
  }

  Future<void> _loginButtonOnPressed(BuildContext context) async {
    final username = _usernameController.text;
    final password = _passwordController.text; 
    
    try {
      final result = await Amplify.Auth.signIn(
        username: username,
        password: password
        );
        await _handleSignInResult(context, result);
    } on AuthException catch (e) {
      // safePrint('Error signin: ${e.message}');
      setError(errMessage: e.message);
    }
  }

  Future<void> _handleSignInResult(BuildContext context, SignInResult result) async {
    final String username = _usernameController.text;

    safePrint('${result.nextStep.signInStep}');
    if(result.nextStep.signInStep == AuthSignInStep.confirmSignInWithTotpMfaCode) {
      _gotoMFAScreen(context);
    }
    else if(result.nextStep.signInStep == AuthSignInStep.done) {
      _gotoHomeScreen(context);
    }
    // MFA Code
    else if(result.nextStep.signInStep == AuthSignInStep.continueSignInWithTotpSetup) {
      final totpSetUpDetails = result.nextStep.totpSetupDetails;
      final setupUri = totpSetUpDetails?.sharedSecret;
      // typecast into String
      String qrCode = '';
      if(setupUri != null) {
        qrCode = setupUri;
      }
      safePrint('Secret Key: $qrCode');
      _gotoQRCodeScreen(context, qrCode: qrCode, username: username);
    }
  }

  void _gotoQRCodeScreen(BuildContext context, {required String qrCode, required String username}) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => QRCodeScreen(qrCode: qrCode, username: username)));
  }

  void _gotoSignUpScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SignUp(),
      ),
    );
  }

  void _gotoMFAScreen(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => MFAScreen()));
  }

  void _gotoHomeScreen(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => Home()));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Login'),
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
                decoration: InputDecoration(labelText: "Username"),
                controller: _usernameController,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    child: Text("LOG IN"),
                    onPressed: () => _loginButtonOnPressed(context),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    child: Text("Create Account"),
                    onPressed: () => _gotoSignUpScreen(context),
                  ),
                ]
              ),
              _signUpError ? Text(_errorMessage) : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
