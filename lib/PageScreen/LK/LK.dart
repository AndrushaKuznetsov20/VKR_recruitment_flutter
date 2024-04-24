import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Models/Role.dart';
import '../../Models/User.dart';
import '../Admin/AdminPage.dart';
import '../Employer/EmployerPage.dart';
import '../Home.dart';
import '../Moder/ModerPage.dart';
import '../User/UpdateUser.dart';
import '../User/UserPage.dart';

class LK extends StatefulWidget{
  final String token;
  LK({required this.token});

  @override
  LKstate createState() => LKstate();
}
class LKstate extends State<LK> {

  User? user;

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id');
  }

  Future<void> fingByUser() async
  {
    int? userId = await getUserId();
    final response = await http.get(Uri.parse('http://192.168.0.186:8092/user/findByUser/$userId'),
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

  String extractRoleFromToken(String token)
  {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    String role = decodedToken['role'];
    return role;
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
            String role = extractRoleFromToken(widget.token);

            if (role == 'ROLE_MODER')
            {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ModerPage(token: widget.token)));
            }
            else if (role == 'ROLE_ADMIN') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AdminPage(token: widget.token)));
            } else if (role == 'ROLE_EMPLOYER'){
              Navigator.push(context, MaterialPageRoute(builder: (context) => EmployerPage(token: widget.token)));
            }
            else if (role == 'ROLE_USER'){
              Navigator.push(context, MaterialPageRoute(builder: (context) => UserPage(token: widget.token)));
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.push(context,MaterialPageRoute(builder: (context) => UpdateUser(token: widget.token, username: user!.username, email: user!.email, password: user!.password)));
            },
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () {
              Navigator.push(context,MaterialPageRoute(builder: (context) => Home()));
            },
          ),
        ],
      ),
      body: Center(
        child: Card(
          margin: EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.black,
                    child: Icon(Icons.token_outlined, color: Colors.white),
                  ),
                  title: Text('Личный идентификатор: ${user?.id}'),
                ),
                Divider(),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.black,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text('Логин: ${user?.username}'),
                ),
                Divider(),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.black,
                    child: Icon(Icons.email, color: Colors.white),
                  ),
                  title: Text('Email: ${user?.email}'),
                ),
                Divider(),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.black,
                    child: Icon(Icons.tag_faces, color: Colors.white),
                  ),
                  title: Text('Роль: ${user?.role == Role.ROLE_MODER ? 'Модератор' : user?.role == Role.ROLE_ADMIN ? 'Администратор' : user?.role == Role.ROLE_USER ? 'Простой пользователь' : user?.role == Role.ROLE_EMPLOYER ? 'Работодатель' : ''}'),
                ),
                if (user != null && user?.role == Role.ROLE_EMPLOYER) ...[
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // createResume(context);
                    },
                    child: Text('Мои вакансии'),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.grey.shade900),
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}