import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'Home.dart';
import 'LK.dart';

class UpdateUser extends StatefulWidget {
  final String token;
  final String username;
  final String email;
  final String password;
  UpdateUser({required this.token,required this.username,required this.email,required this.password});

  @override
  UpdateUserState createState() => UpdateUserState();
}
class UpdateUserState extends State<UpdateUser>
{
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;


  Future<void> updateDataUser(BuildContext context) async
  {
    String username = usernameController.text;
    String email = emailController.text;
    String password = passwordController.text;

    final url = Uri.parse('http://192.168.0.186:8092/user/update');
    final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer ${widget.token}'};
    final body = jsonEncode({
      'username': username,
      'email': email,
      'password': password,
    });

    final response = await http.put(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.body),
        ),
      );
      Navigator.push(context,MaterialPageRoute(builder: (context) => Home()));
    }
    else {
      if(response.statusCode == 400)
      {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.body),
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController(text: widget.username);
    emailController = TextEditingController(text: widget.email);
    passwordController = TextEditingController(text: widget.password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Редактирование профиля', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey.shade900,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(context,MaterialPageRoute(builder: (context) => LK(token: widget.token)));
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black), // Цвет рамки
                borderRadius: BorderRadius.circular(8.0), // Закругленные углы рамки
              ),
              padding: EdgeInsets.all(16.0), // Отступы внутри контейнера
              child: Text(
                'Внимание! После обновления данных\nнеобходимо перезайти в аккаунт!',
                style: TextStyle(color: Colors.black),
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person, color: Colors.black),
                labelText: 'Введите новый логин',
                labelStyle: TextStyle(color: Colors.black),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
              cursorColor: Colors.black,
              style: TextStyle(color: Colors.black),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.email, color: Colors.black),
                labelText: 'Введите новый email:',
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
                prefixIcon: Icon(Icons.lock, color: Colors.black),
                labelText: 'Введите новый пароль',
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
                updateDataUser(context);
              },
              child: Text('Обновить данные'),
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
}