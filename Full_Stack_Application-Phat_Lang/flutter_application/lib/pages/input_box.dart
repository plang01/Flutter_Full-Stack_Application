import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/pages/landing_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';

class TextBox extends StatefulWidget {
  TextBox({super.key});
  @override
  State<TextBox> createState() => _TextBoxState();
}

class _TextBoxState extends State<TextBox> {
  Future<void> signoutButton (BuildContext context) async {
    try {
      final result = await Amplify.Auth.signOut();

      handleSignoutResult(context, result);
    } on CognitoFailedSignOut catch (e) {
      safePrint('Error with signing out: ${e.exception.message}');
    }
  }

  Future<void> handleSignoutResult(BuildContext context, SignOutResult result) async {
    if (result is CognitoCompleteSignOut) {
      gotoLandingScreen(context);
    }
  }

  void gotoLandingScreen(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => LandingPage()));
  }

  @override
  void initState() {
    super.initState();
    getRequest();
  }


  TextEditingController inputName = TextEditingController();
  String result = '';
  String url = 'localhost:3000';
  List<String> nameList = [];
  
  // Create a custom widget to display the name the card
  Widget nameTemplate(name) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  @override
   void dispose() { 
    inputName.dispose(); 
    super.dispose(); 
  } 

    //GET request function 
    Future<void> getRequest() async {
      nameList = [];
      final response = await http.get(Uri.http(url, '/accounts'));
      if (response.statusCode == 200) {
        final data = jsonDecode((response.body));
        setState(() {
          for( var item in data) {
            if (item.containsKey('username')) {
              nameList.add(item['username']);
            }
        }
        });
        debugPrint('$nameList');
      } else {
        throw Exception("Failed");
      }
    }

  //POST request function
  Future<void> postRequest() async{
    String input = inputName.text;
    try{
      final response = await http.post(
          Uri.http(url, '/accounts'),
          body : {'username': input},
        );
      if (response.statusCode == 201 || response.statusCode == 200) {
        debugPrint(response.body);
      }
      else {
        throw Exception('Failed to post data!');
      }

      await getRequest();

    }

    catch (e) {
      setState(() {
        result = 'Error: $e';
      });
      debugPrint(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
        appBar: AppBar(
          title: const Text('Home Page'),
          backgroundColor: Colors.blue,
          actions: [
            IconButton(
              onPressed: () {
                signoutButton(context);
              },
              icon: Icon(Icons.logout),
              tooltip: 'Log Out',
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            const SizedBox(height: 20),
            TextField(
              controller: inputName,
              decoration: const InputDecoration(
                labelText: 'Input Name',
              ) ,

            ),
            SizedBox(height:20),
            ElevatedButton(
              onPressed: () async {
                await postRequest();
              }, 
              child: Text('Submit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
              ),
            ),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: () async {
                // debugPrint(inputName.text);
                await getRequest();
              },
              child: Text('List All'),
            ),
             SizedBox(height: 20),
            Column(
              
              children: nameList.map((name) => nameTemplate(name)).toList(),
            ),
          ],
        ),
      );
  }
}
