import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert';

import '../Home.dart';
import '../LK/LK.dart';

class UpdateUser extends StatefulWidget {
  final String token;
  final String username;
  final String email;
  final String number;
  final String password;
  UpdateUser({required this.token,required this.username,required this.email, required this.number, required this.password});

  @override
  UpdateUserState createState() => UpdateUserState();
}
class UpdateUserState extends State<UpdateUser>
{
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController numberController;


  Future<void> updateDataUser(BuildContext context) async
  {
    String username = usernameController.text;
    String email = emailController.text;
    String number = numberController.text;

    final url = Uri.parse('http://172.20.10.3:8092/user/update');
    final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer ${widget.token}'};
    final body = jsonEncode({
      'username': username,
      'email': email,
      'number': number,
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
    numberController = TextEditingController(text: widget.number);
  }

  int extractIdFromToken(String token)
  {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    int id = decodedToken['id'];
    return id;
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Внимание! После обновления данных\nнеобходимо перезайти в аккаунт!',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              SizedBox(height: 12),
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
                maxLines: null,
              ),
              SizedBox(height: 12),
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
                maxLines: null,
              ),
              SizedBox(height: 24.0),
              TextField(
                controller: numberController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.phone, color: Colors.black),
                  labelText: 'Введите новый номер телефона',
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                cursorColor: Colors.black,
                style: TextStyle(color: Colors.black),
                maxLines: null,
              ),
              SizedBox(height: 24.0),
              ElevatedButton.icon(
                onPressed: () {
                  updateDataUser(context);
                },
                icon: Icon(Icons.refresh),
                label: Text('Обновить данные'),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.grey.shade900),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}