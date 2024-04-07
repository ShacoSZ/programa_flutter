import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:programa_flutter/screens/anothermain.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:programa_flutter/screens/loginpage.dart';
import 'package:flutter/services.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reporsoft Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromRGBO(39, 64, 91, 0.612)),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor:  Color.fromRGBO(39, 64, 91, 0.612),
        ),
      ),
      home: const _checkconnectionpage(), 
      //const loginpage(title: 'Login Page'),
    );
  }
}


class _checkconnectionpage extends StatefulWidget {
  const _checkconnectionpage({super.key});


  @override
  State<_checkconnectionpage> createState() => _checkconnectionState();
}

class _checkconnectionState extends State<_checkconnectionpage> {
  Future<bool> _checkconnection() async {
 var url = Uri.parse('http://192.168.100.201:8000/api/v1/check-net');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    print('Connected');
    return true;
  } else {
    print('Not Connected');
    return false;
  }
}

Future<bool> _checkconnectionWithTimeOut() async {
  try {
    return await _checkconnection().timeout(const Duration(seconds: 10));
  } on TimeoutException {
    return false;
  }
}

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reporsoft Verification'),
      ),
      body: FutureBuilder<bool>(
        future: _checkconnectionWithTimeOut(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Mientras se espera la respuesta de la API, puedes mostrar un indicador de carga
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            // En caso de error, muestra un mensaje de error
            return const Center(
              child: Text('Error connecting data'),
            );
          } else if (snapshot.data == true) {
            // Si la llamada a la API es exitosa, navega a la siguiente pantalla
            return loginpage();
          } else {
            // Si la llamada a la API falla, muestra un pop-up con un mensaje
            return AlertDialog(
              title: Text('Error'),
              content: Text('It is not possible to connect through the API'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                  child: Text('Close'),
                ),
              ],
            );
          }
        },
      ),
    );
  
}
}