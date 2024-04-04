import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:programa_flutter/screens/anothermain.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:programa_flutter/screens/verificationcode.dart';

class loginpage extends StatefulWidget {
  const loginpage({super.key, required this.title});

   final String title;

  @override
  State<loginpage> createState() => _loginpageState();
}

class _loginpageState extends State<loginpage> {
  final _formKey = GlobalKey<FormState>();
  bool _isloading = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

void _initLoading() {
    setState(() {
      _isloading = true;
    });
  }

  void _endLoading() {
    setState(() {
      _isloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children:[Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "Email"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "Password"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                      _login(emailController.text, passwordController.text, context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill input')),
                        );
                      }
                    },
                    child: const Text('Login'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
      Visibility(
          visible: _isloading,
          child: Container(
            color: Colors.black54,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )),]);
  }

void _login(String _email, String _password, BuildContext context) async {
  _initLoading();
  var url = Uri.parse('http://192.168.100.201:8000/api/v1/auth/login');
  Map<String, String> data = {'email': _email, 'password': _password};
  final response = await http.post(url, body: data);
  if (response.statusCode == 200) {
    print(response.body);
    var jsonResponse = json.decode(response.body);
    String UserToken = jsonResponse['data']['token'];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('token', UserToken);
    print(UserToken);
    _go_to_2FA_verification(context);
    _endLoading();
  } else {
    _endLoading();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invalid email or password')),
    );
  }
}

void _go_to_2FA_verification(BuildContext context){
  Navigator.push(context,MaterialPageRoute(builder: (context) => verificationpage(title: '2FA Verification',)),);
}
}
