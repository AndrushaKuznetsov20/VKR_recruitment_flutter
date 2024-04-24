import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Home.dart';

class Register extends StatefulWidget {
  @override
  RegisterState createState() => RegisterState();
}
class RegisterState extends State<Register> {
  bool _isObscure = true;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Регистрация', style: TextStyle(color: Colors.white),),
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
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Введите имя',
                prefixIcon: Icon(Icons.person, color: Colors.black),
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
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Введите электронную почту',
                prefixIcon: Icon(Icons.email, color: Colors.black),
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
                labelText: 'Введите пароль',
                prefixIcon: Icon(Icons.lock, color: Colors.black),
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
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                register(context);
              },
              child: Text('Зарегистрироваться'),
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

  Future<void> register(BuildContext context) async{
    String username = usernameController.text;
    String email = emailController.text;
    String password = passwordController.text;

    final url = Uri.parse('http://192.168.0.186:8092/auth/sign-up');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'username': username,
      'email': email,
      'password': password
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200)
    {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.body),
        ),
      );
      Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
    }
    if(response.statusCode == 403)
      {
        showDialog(
          context: context,
          builder: (context) =>
              AlertDialog(
                title: Text('Ошибка!'),
                content: Text('Пользователь с таким email уже существует!'),
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
                ],
              ),
        );
      }

    if(response.statusCode == 409)
    {
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: Text('Ошибка!'),
              content: Text('Пользователь с таким именем уже существует!'),
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
}