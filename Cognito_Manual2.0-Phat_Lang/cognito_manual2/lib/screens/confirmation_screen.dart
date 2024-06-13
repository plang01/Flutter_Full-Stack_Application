import 'package:cognito_manual2/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';


class Confirmation extends StatefulWidget {
  final String email;
  Confirmation({super.key, required this.email});

  @override
  State<Confirmation> createState() => _ConfirmationState();
}

class _ConfirmationState extends State<Confirmation> {
  final TextEditingController _confirmation = TextEditingController();

  bool _signUpError = false;
  String _errorMessage = '';

  void setError({required String errMessage}) {
    setState(() {
      _signUpError = true;
      _errorMessage = errMessage;
    });
  }

  Future<void> confirmUser(BuildContext context) async {
    final confirmationCode = _confirmation.text;
    try {
      final result = await Amplify.Auth.confirmSignUp(
        username: widget.email, 
        confirmationCode: confirmationCode
      );
      if(result.nextStep.signUpStep == AuthSignUpStep.done) {
        _gotoHomePage(context);
      }
    } on AuthException catch(e) {
      setError(errMessage: e.message);
    }
  }

  void _gotoHomePage(BuildContext context) {
    Navigator.push(context,
     MaterialPageRoute(builder: (_) => Home()));
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirmation Screen'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          child: Column(
            children: [
              TextFormField(
                controller: _confirmation,
                keyboardType: TextInputType.number,
              ),
              ElevatedButton(
                onPressed: () => confirmUser(context), 
                child: Text('Confirm')
              ),
              _signUpError ? Text(_errorMessage) : SizedBox(),
            ]
          ),
        ),
      ),
    );
  }
}
