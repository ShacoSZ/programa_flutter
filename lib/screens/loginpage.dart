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
  const loginpage({super.key});


  @override
  State<loginpage> createState() => _loginpageState();
}

TextEditingController emailController = TextEditingController();
TextEditingController passwordController = TextEditingController();
void _clearfields() {
  emailController.clear();
  passwordController.clear();
}
class _loginpageState extends State<loginpage> {
  final _formKey = GlobalKey<FormState>();
  bool _isloading = false;

  @override
  void initState() { 
    super.initState();
    emailController.clear();
  passwordController.clear();
  }

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
    return Stack(children:[
      Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: ListView(children:[
        const SizedBox(height: 40),
            const Image(
              image: AssetImage('assets/rs_logo_shield_cuted.jpg'),
              width: 85,
              height: 85,
            ),
        Form(
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
      )]),
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
  var url = Uri.parse('http://192.168.1.56:8000/api/v1/auth/login');
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

  Route route = PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => verificationpage(title: '2FA Verification',),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(0.0, 1.0);
      var end = Offset.zero;
      var curve = Curves.easeOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
  Navigator.push(context, route);
}
}
