import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter_application/pages/input_box.dart';

class ConfirmationScreen extends StatefulWidget {
  final String email;

  const ConfirmationScreen({super.key, required this.email});

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  final TextEditingController confirmationCodeController = TextEditingController();

  bool confirmationError = false;
  String errorMessage = '';

  void setError(String errMessage) {
    setState(() {
      confirmationError = true;
      errorMessage = errMessage;
    });
  }

  Future<void> confirmButton(BuildContext context) async {
    final String confirmationCode = confirmationCodeController.text;

    try {
      final result = await Amplify.Auth.confirmSignUp(
          username: widget.email,
          confirmationCode: confirmationCode
      );

      handleConfirmationResult(context, result);
    } on AuthException catch (e) {
      setError(e.toString());
    }
  }

  Future<void> handleConfirmationResult(BuildContext context, SignUpResult result) async {
    if (result.nextStep.signUpStep == AuthSignUpStep.done) {
      gotoHomePage(context);
    }
  }

  void gotoHomePage(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => TextBox()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Confimation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          child: Column(
            children: [
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Confirmation Code'),
                controller: confirmationCodeController,
              ),
              ElevatedButton(
                  onPressed: () {
                    confirmButton(context);
                  },
                  child: Text('Confirm'),
              ),
              confirmationError ? Text(errorMessage) : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
