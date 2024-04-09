import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert';

import 'Home.dart';
import 'Register.dart';

class Login extends StatelessWidget
{
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        title: Text('Авторизация',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.grey.shade900,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Введите логин',
                labelStyle: TextStyle(color: Colors.black),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
              cursorColor: Colors.black,
              style: TextStyle(color: Colors.black),
            ),

            SizedBox(height: 12.0),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Введите пароль',
                labelStyle: TextStyle(color: Colors.black),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
              cursorColor: Colors.black,
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {
                login(context);
              },
              child: Text('Войти'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.grey.shade900),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> login(BuildContext context) async
  {
    String username = usernameController.text;
    String password = passwordController.text;

    final url = Uri.parse('http://localhost:8092/auth/sign-in');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'username': username,
      'password': password,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200)
    {
      Map<String, dynamic> responseBody = jsonDecode(response.body);
      String token = responseBody['token'];

      String role = extractRoleFromToken(token);

      if (role == 'ROLE_EMPLOYER')
      {

      }
    }
  }

  String extractRoleFromToken(String token)
  {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    String role = decodedToken['role'];
    return role;
  }

}