import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:recruitment/PageScreen/ResonseToResume/ReadMyResponsesToResume.dart';
import 'package:recruitment/PageScreen/Response/ReadMyResponses.dart';
import 'package:recruitment/PageScreen/Vacancy/ReadMyVacancy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Models/Resume.dart';
import '../../Models/Role.dart';
import '../../Models/User.dart';
import '../Admin/AdminPage.dart';
import '../Employer/EmployerPage.dart';
import '../Home.dart';
import '../Moder/ModerPage.dart';
import '../Resume/CreateResume.dart';
import '../Resume/ReadMyResume.dart';
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
  Resume? resume;

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id');
  }

  Future<void> fingByUser() async
  {
    int? userId = await getUserId();
    final response = await http.get(Uri.parse('http://172.20.10.3:8092/user/findByUser/$userId'),
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
    findByUserResume();
  }

  String extractRoleFromToken(String token)
  {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    String role = decodedToken['role'];
    return role;
  }

  Future<Resume?> findByUserResume() async
  {
    final response = await http.get(
      Uri.parse('http://172.20.10.3:8092/resume/myResume'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },);
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      setState(() {
        resume = Resume.fromJson(jsonData);
      });
    }
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
                  title: Text('Логин: ${utf8.decode(user?.username.codeUnits ?? [])}'),
                ),
                Divider(),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.black,
                    child: Icon(Icons.email, color: Colors.white),
                  ),
                  title: Text('Email: ${utf8.decode(user?.email.codeUnits ?? [])}'),
                ),
                Divider(),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.black,
                    child: Icon(Icons.phone, color: Colors.white),
                  ),
                  title: Text('Номер телефона: ${utf8.decode(user?.number.codeUnits ?? [])}'),
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
                      Navigator.push(context,MaterialPageRoute(builder: (context) => ReadMyVacancy(token: widget.token)));
                    },
                    child: Text('Мои вакансии'),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.grey.shade900),
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(height: 12.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context,MaterialPageRoute(builder: (context) => ReadMyResponsesToResume(token: widget.token)));
                    },
                    child: Text('Перейти в избранное'),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.grey.shade900),
                      foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                    ),
                  ),
                ],
                if (user != null && user?.role == Role.ROLE_USER) ...[
                  ElevatedButton(
                    onPressed: () async{
                      if (resume != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReadResume(token: widget.token, resume: resume),
                          ),
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Ошибка!'),
                            content: Text('У вас нет резюме, хотите его создать ?'),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              CreateResume(token: widget.token)));
                                },
                                child: Text('Создать'),
                                style: ButtonStyle(
                                  backgroundColor:
                                  MaterialStateProperty.all<Color>(Colors.grey.shade900),
                                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(
                                width: 12.0,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('Нет'),
                                style: ButtonStyle(
                                  backgroundColor:
                                  MaterialStateProperty.all<Color>(Colors.grey.shade900),
                                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    child: Text('Ваше резюме'),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.grey.shade900),
                      foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(height: 12.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context,MaterialPageRoute(builder: (context) => ReadMyResponses(token: widget.token)));
                    },
                    child: Text('Перейти в избранное'),
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