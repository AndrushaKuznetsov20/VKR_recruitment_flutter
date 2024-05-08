import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:recruitment/PageScreen/Vacancy/ReadMyVacancy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Models/Resume.dart';
import '../../Models/Role.dart';
import '../../Models/User.dart';
import '../Admin/AdminPage.dart';
import '../Chat/ChatPage.dart';
import '../Employer/EmployerPage.dart';
import '../Home.dart';
import '../Moder/ModerPage.dart';
import '../Resume/ReadMyResume.dart';
import '../Resume/ReadUserResume.dart';
import '../User/UpdateUser.dart';
import '../User/UserPage.dart';

class ProfileUser extends StatefulWidget{
  final String token;
  final int id;
  final int vacancyId;
  ProfileUser({required this.token, required this.id, required this.vacancyId});

  @override
  ProfileUserstate createState() => ProfileUserstate();
}
class ProfileUserstate extends State<ProfileUser> {

  Resume? resume;
  User? user;

  Future<void> fingByUser() async
  {
    int userId = widget.id;
    final response = await http.get(
      Uri.parse('http://172.20.10.3:8092/user/findByUser/$userId'),
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

  Future<void> setStatusSelfDenial(int vacancyId, int userId,
      BuildContext buildContext) async
  {
    final response = await http.put(Uri.parse(
        'http://172.20.10.3:8092/response/setStatusSelfDenial/$userId/$vacancyId'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.body),
        ),
      );
    }
  }

  Future<void> setStatusRefusalEmployer(int vacancyId, int userId,
      BuildContext buildContext) async
  {
    final response = await http.put(Uri.parse(
        'http://172.20.10.3:8092/response/setStatusRefusalEmployer/$userId/$vacancyId'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.body),
        ),
      );
    }
  }

  Future<void> setStatusRelevant(int vacancyId, int userId,
      BuildContext buildContext) async
  {
    final response = await http.put(Uri.parse(
        'http://172.20.10.3:8092/response/setStatusRelevant/$userId/$vacancyId'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.body),
        ),
      );
    }
  }

  Future<void> setStatusInvitation(int vacancyId, int userId,
      BuildContext buildContext) async
  {
    final response = await http.put(Uri.parse(
        'http://172.20.10.3:8092/response/setStatusInvitation/$userId/$vacancyId'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.body),
        ),
      );
    }
  }

  Future<Resume?> findByUserResume(int userId, BuildContext context) async {
    final response = await http.get(
      Uri.parse('http://172.20.10.3:8092/resume/getResumeById/$userId'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      setState(() {
        resume = Resume.fromJson(jsonData);
      });
    }
    if (utf8.decode(resume!.statusResume.codeUnits) == "Не модерировано!" ||
        utf8.decode(resume!.statusResume.codeUnits) == "Заблокировано!") {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Внимание!'),
            content:
                Text('Резюме пользователя заблокировано или не модерировано!'),
            actions: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfileUser(token: widget.token, id: widget.id, vacancyId: 0)));
                },
                icon: Icon(Icons.check, color: Colors.green),
                label: Text('ОК'),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.grey.shade900),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                ),
              ),
            ],
          );
        },
      );
    }

    if (response.statusCode == 204) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Внимание!'),
            content: Text('Резюме пользователя не существует!'),
            actions: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfileUser(token: widget.token, id: widget.id, vacancyId: 0)));
                },
                icon: Icon(Icons.check, color: Colors.green),
                label: Text('ОК'),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.grey.shade900),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fingByUser();
    findByUserResume(widget.id, context);
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

  @override
  Widget build(BuildContext context) {
    String? selectedStatus;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Профиль', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey.shade900,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Home()));
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
                    child: Icon(Icons.tag_faces, color: Colors.white),
                  ),
                  title: Text('Роль: ${user?.role == Role.ROLE_MODER ? 'Модератор' : user?.role == Role.ROLE_ADMIN ? 'Администратор' : user?.role == Role.ROLE_USER ? 'Простой пользователь' : user?.role == Role.ROLE_EMPLOYER ? 'Работодатель' : ''}'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (resume != null) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ReadUserResume(
                                  token: widget.token, resume: resume!)));
                    }
                  },
                  child: Text('Просмотр резюме'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.grey.shade900),
                    foregroundColor:
                    MaterialStateProperty.all<Color>(Colors.white),
                  ),
                ),
                SizedBox(height: 12.0),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => ChatPage(token: widget.token, senderId: extractIdFromToken(widget.token), receiverId: widget.id)));
                  },
                  icon: Icon(Icons.message, color: Colors.blue),
                  label: Text('Написать пользователю'),
                  style: ButtonStyle(
                    backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.grey.shade900),
                    foregroundColor:
                    MaterialStateProperty.all<Color>(Colors.white),
                  ),
                ),
                SizedBox(height: 12.0),
                if (widget.vacancyId != 0) ...[
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.grey.shade900),
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      fixedSize: MaterialStateProperty.all<Size>(Size(200, 25)),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState) {
                              return AlertDialog(
                                title: Text('Выберите статус:'),
                                content: DropdownButton<String>(
                                  value: selectedStatus,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedStatus = newValue;
                                    });
                                  },
                                  items: <String>[
                                    'Релевантный отклик',
                                    'Кандидат приглашён',
                                    'Отказ работодателя',
                                    'Самоотказ'
                                  ].map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                                actions: <Widget>[
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey.shade900,
                                    ),
                                    onPressed: () {
                                      if (selectedStatus == 'Самоотказ') {
                                        setStatusSelfDenial(widget.vacancyId,
                                            widget.id, context);
                                        Navigator.of(context).pop();
                                      }
                                      if (selectedStatus ==
                                          'Отказ работодателя') {
                                        setStatusRefusalEmployer(
                                            widget.vacancyId,
                                            widget.id,
                                            context);
                                        Navigator.of(context).pop();
                                      }
                                      if (selectedStatus ==
                                          'Релевантный отклик') {
                                        setStatusRelevant(widget.vacancyId,
                                            widget.id, context);
                                        Navigator.of(context).pop();
                                      }
                                      if (selectedStatus ==
                                          'Кандидат приглашён') {
                                        setStatusInvitation(widget.vacancyId,
                                            widget.id, context);
                                        Navigator.of(context).pop();
                                      }
                                    },
                                    child: Text('OK',
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                    child: Text('Обработать отклик',
                        style: TextStyle(color: Colors.white)),
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