import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cognito_manual2/screens/home_screen.dart';
import 'package:flutter/material.dart';

class MFAScreen extends StatefulWidget {
  const MFAScreen({super.key});

  @override
  State<MFAScreen> createState() => _MFAScreenState();
}

class _MFAScreenState extends State<MFAScreen> {
  final _mfaCode = TextEditingController();
  bool _signUpError = false;
  String _errorMessage = '';

  void setError({required String errMessage}) {
    setState(() {
      _signUpError = true;
      _errorMessage = errMessage;
    });
  }

  Future<void> confirmMFACode(BuildContext context) async {
    String mfaCode = _mfaCode.text;
    try {
      final result = await Amplify.Auth.confirmSignIn(
        confirmationValue: mfaCode
      );
      if(result.isSignedIn) {
        _gotoHomePage(context);
      }
    } on AuthException catch (e) {
      setError(errMessage: e.message);
    }
  }

  void _gotoHomePage(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => Home()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MFA Code'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            children: [
              TextFormField(
                 controller: _mfaCode,
                  keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => confirmMFACode(context), 
                child: Text('Enter Code'),
              ),
              SizedBox(height: 20),
              _signUpError ? Text('${_errorMessage}') : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}

