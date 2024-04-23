import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:recruitment/PageScreen/ModerPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'AdminPage.dart';
import 'Home.dart';
import 'Register.dart';
import 'UserPage.dart';

class Login extends StatefulWidget {
  @override
  LoginState createState() => LoginState();
}
class LoginState extends State<Login>
{
  bool _isObscure = true;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Авторизация', style: TextStyle(color: Colors.white)),
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
                prefixIcon: Icon(Icons.email, color: Colors.black),
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
              obscureText: _isObscure,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock, color: Colors.black),
                labelText: 'Введите пароль',
                labelStyle: TextStyle(color: Colors.black),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                suffixIcon: IconButton(
                  icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off),
                  color: Colors.black,
                  onPressed: () {
                    setState(() {
                      _isObscure = !_isObscure;
                    });
                  },
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
                backgroundColor: MaterialStateProperty.all<Color>(Colors.grey.shade900),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
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

    final url = Uri.parse('http://192.168.0.186:8092/auth/sign-in');
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

      int id = extractIdFromToken(token);

      Future<void> saveUserId(int id) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('id', id);
      }
      saveUserId(id);

        if (role == 'ROLE_USER')
        {
          Navigator.push(context,MaterialPageRoute(builder: (context) => UserPage(token: token)));
        }
        if (role == 'ROLE_EMPLOYER')
        {
          Navigator.push(context,MaterialPageRoute(builder: (context) => Home()));
        }
        if (role == 'ROLE_MODER')
        {
          Navigator.push(context,MaterialPageRoute(builder: (context) => ModerPage(token: token)));
        }
        if (role == 'ROLE_ADMIN')
        {
          Navigator.push(context,MaterialPageRoute(builder: (context) => AdminPage(token: token)));
        }
    }

    if(response.statusCode == 423)
      {
        showDialog(
          context: context,
          builder: (context) =>
              AlertDialog(
                title: Text('Ошибка!'),
                content: Text('Ваш аккаунт заблокирован ! Пожалуйста, создайте новый аккаунт.'),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('ОК'),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.grey.shade900),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context,MaterialPageRoute(builder: (context) => Register()));
                    },
                    child: Text('Создать аккаунт'),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.grey.shade900),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    ),
                  ),
                ],
              ),
        );
      }

    if(response.statusCode == 404)
      {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Ошибка!'),
            content: Text('У Вас есть аккаунт ? Если да, то проверьте правильность введённых данных!',style: TextStyle(color: Colors.black),),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('ОК'),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.grey.shade900),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context,MaterialPageRoute(builder: (context) => Register()));
                },
                child: Text('Создать аккаунт'),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.grey.shade900),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                ),
              ),
            ],
          ),
        );
      }

    if(response.statusCode == 400)
      {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.body),
          ),
        );
      }
  }

  String extractRoleFromToken(String token)
  {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    String role = decodedToken['role'];
    return role;
  }

  int extractIdFromToken(String token)
  {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    int id = decodedToken['id'];
    return id;
  }

}