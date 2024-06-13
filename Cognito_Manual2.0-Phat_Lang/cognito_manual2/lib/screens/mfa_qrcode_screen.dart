import 'package:amplify_core/amplify_core.dart';
import 'package:cognito_manual2/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
class QRCodeScreen extends StatefulWidget {
  final String qrCode;
  final String username;
  QRCodeScreen({super.key, required this.qrCode, required this.username});

  @override
  State<QRCodeScreen> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  TextEditingController _mfaCode = TextEditingController();

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
        title: Text('QR Code'),
      ),
       body: Padding(
          padding: EdgeInsets.all(20),
          child:Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                QrImageView(
                  data: 'otpauth://totp/AWS-Cognito:${widget.username}?secret=${widget.qrCode}&issuer=AWS-Cognito',
                  version: QrVersions.auto,
                  size: 200.0,
                ),
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