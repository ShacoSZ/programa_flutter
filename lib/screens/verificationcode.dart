import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart';
import 'package:programa_flutter/main.dart';
import 'package:programa_flutter/screens/loginpage.dart';
import 'package:programa_flutter/screens/anothermain.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class verificationpage extends StatefulWidget {
  const verificationpage({super.key, required this.title});

   final String title;

  @override
  State<verificationpage> createState() => _verificationpageState();
}

class _verificationpageState extends State<verificationpage> {
  final _formKey = GlobalKey<FormState>();
  bool _isloading = false;
  bool _isdisabled = false;
  String? User3FACode;
  TextEditingController verificationcodecontroller = TextEditingController();  
  TextEditingController threefacodecontroller = TextEditingController();
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
        leading: IconButton(
          icon: const Icon(Icons.logout_sharp),
          onPressed: () async {
            _initLoading();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    var url = Uri.parse('http://192.168.1.56:8000/api/v1/auth/logout');
    if (token != null)
    {
      var headers = {'Authorization': 'Bearer $token'};
      var response = await http.post(url,headers: headers);
    if (response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('token');
      _endLoading();      
      Navigator.pop(context);
    } else {
      print(response.statusCode);
      print(response.reasonPhrase);
      _endLoading();
    }
    }
          }),
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
                  controller: verificationcodecontroller,
                  enabled: !_isdisabled,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "2FA Code"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your 2FA Code';
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
                    onPressed: _isdisabled? null : () {
                      if (_formKey.currentState!.validate()) {
                        _verify(verificationcodecontroller.text, context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill input')),
                        );
                      }
                    },
                    child: const Text('Verify'),
                  ),
                ),
              ),
              User3FACode == null ? Container() : 
              Column(
                children:[
                  Text('3FA Code: $User3FACode'),
                  SizedBox(height: 15,),
                ElevatedButton(
                  onPressed: () {
                    _copyToClipboard(User3FACode!);
                  },
                  child: const Text('Copy 3FA Code'),
                ),
                ]
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

  void _verify(String verificationcode, BuildContext context) async {
    _initLoading();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    var url = Uri.parse('http://192.168.1.56:8000/api/v1/auth/verify-code');
    if (token != null)
    {
      var headers = {'Authorization': 'Bearer $token'};
      var response = await http.post(url,headers: headers, body: {'code2FA': verificationcode});
    if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        User3FACode = jsonResponse['data']['code3FA'];
        print(User3FACode);
        setState(() {
          User3FACode = jsonResponse['data']['code3FA'];
          _isdisabled = true;
        });
      _endLoading();      
    } else {
      print(response.statusCode);
      print(response.reasonPhrase);
      _endLoading();
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invalid 2FA Code')),
    );
    }
    }
  }

}
void _copyToClipboard(String text) {
  Clipboard.setData(ClipboardData(text: text));
  Fluttertoast.showToast(
      msg: "Copied to Clipboard",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0);
}
