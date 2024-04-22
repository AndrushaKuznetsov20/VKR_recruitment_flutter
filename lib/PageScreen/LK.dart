import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Models/Role.dart';
import '../Models/User.dart';
import 'ModerPage.dart';

class LK extends StatefulWidget{
  final String token;
  LK({required this.token});

  @override
  LKstate createState() => LKstate();
}
class LKstate extends State<LK> {

  User? user;
  Future<void> fingByUser() async
  {
    final response = await http.get(Uri.parse('http://localhost:8092/user/findByUser'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },);
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      setState(() {
        user = User.fromJson(jsonData);
      });
    }
    else {
      throw Exception('Ошибка загрузки пользователя!');
    }
  }

  @override
  void initState() {
    super.initState();
    fingByUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Личный кабинет', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey.shade900,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ModerPage(token: widget.token)));
          },
        ),
      ),
      body: Center(
        child: Card(
          margin: EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text('Личный идентификатор: ${user?.id}'),
                ),
                Divider(),
                ListTile(
                  title: Text('Имя: ${user?.username}'),
                ),
                Divider(),
                ListTile(
                  title: Text('Email: ${user?.email}'),
                ),
                Divider(),
                ListTile(
                  title: Text('Роль: ${user?.role == Role.ROLE_MODER ? 'Модератор' : user?.role == Role.ROLE_ADMIN ? 'Администратор' : user?.role == Role.ROLE_USER ? 'Простой пользователь' : user?.role == Role.ROLE_EMPLOYER ? 'Работодатель' : ''}'),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Text('Редактировать профиль'),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.grey.shade900),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Text('Выйти с аккаунта'),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.grey.shade900),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}