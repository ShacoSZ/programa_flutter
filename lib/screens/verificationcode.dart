import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
  TextEditingController verificationcodecontroller = TextEditingController();  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  controller: verificationcodecontroller,
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
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        
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
            ],
          ),
        ),
      ),
    );
  }
}