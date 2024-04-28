import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../Models/Role.dart';
import '../../Models/User.dart';
import '../LK/LK.dart';

class AdminPage extends StatefulWidget {
  final String token;

  AdminPage({required this.token});

  @override
  AdminPageState createState() => AdminPageState();
}

class AdminPageState extends State<AdminPage> {
  List<User> dataList = [];
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    listUsers(currentPage, context);
  }

  Future<void> listUsers(int pageNo, BuildContext context) async {
    final response = await http.get(
      Uri.parse('http://172.20.10.3:8092/user/list/$pageNo'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      List<User> users = [];
      for (var entry in jsonData.entries) {
        var key = entry.key;
        var value = entry.value;

        if (key == 'users') {
          for (var userJson in value) {
            users.add(User.fromJson(userJson));
          }
        }
        if (users.isEmpty) {
          currentPage--;
          listUsers(currentPage, context);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Пользователей больше нет!"),
            ),
          );
        }
      }
      setState(() {
        dataList = users;
      });
    }
  }

  Future<void> blockUser(int id, BuildContext context) async {
    final response = await http.put(
      Uri.parse('http://172.20.10.3:8092/user/block/$id'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );
    if (response.statusCode == 200)
    {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.body),
        ),
      );
      listUsers(currentPage, context);
    }
  }

  Future<void> inBlockUser(int id, BuildContext context) async {
    final response = await http.put(
      Uri.parse('http://172.20.10.3:8092/user/inBlock/$id'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );
    if (response.statusCode == 200)
    {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.body),
        ),
      );
      listUsers(currentPage, context);
    }
  }
  Future<void> changeRole(int id, String? role) async {
    final response = await http.put(
      Uri.parse('http://172.20.10.3:8092/user/changeRole/$id/$role'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );
    if (response.statusCode == 200)
    {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.body),
        ),
      );
      listUsers(currentPage, context);
    }
  }
  void nextPage() {
    setState(() {
      currentPage++;
      listUsers(currentPage, context);
    });
  }

  void previousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
        listUsers(currentPage, context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String? selectedRole;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Список пользователей',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey.shade900,
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => LK(token: widget.token)),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: dataList.length,
              itemBuilder: (context, index) {
                final data = dataList[index];
                return Card(
                    margin: EdgeInsets.all(8),
                    elevation: 4,
                    child: ExpansionTile(
                      title: Row(
                        children: [
                          Icon(Icons.menu, color: Colors.grey.shade900),
                          SizedBox(width: 8),
                          Text('${utf8.decode(data.username.codeUnits)}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade900)),
                        ],
                      ),
                      iconColor: Colors.grey.shade900,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Email:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text(utf8.decode(data.email.codeUnits)),
                              Divider(),
                              Text('Активность:',
                                  style:
                                  TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                data.active.toString(),
                                style: TextStyle(
                                  color: data.active.toString() == 'false' ? Colors.red : Colors.green,
                                ),
                              ),
                              Divider(),
                              Text('Роль:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                  '${data.role == Role.ROLE_MODER ? 'Модератор' : data.role == Role.ROLE_ADMIN ? 'Администратор' : data.role == Role.ROLE_USER ? 'Простой пользователь' : data.role == Role.ROLE_EMPLOYER ? 'Работодатель' : ''}'),
                              Divider(),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  blockUser(data.id, context);
                                },
                                child: Text('Заблокировать'),
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.grey.shade900),
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.white),
                                  fixedSize: MaterialStateProperty.all<Size>(Size(200, 25)),
                                ),
                              ),
                              SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  inBlockUser(data.id, context);
                                },
                                child: Text('Разблокировать'),
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.grey.shade900),
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.white),
                                    fixedSize: MaterialStateProperty.all<Size>(Size(200, 25)),
                                ),
                              ),
                              SizedBox(height: 8),
                              SizedBox(width: 20),
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                  MaterialStateProperty.all<Color>(
                                      Colors.grey.shade900),
                                  foregroundColor:
                                  MaterialStateProperty.all<Color>(
                                      Colors.white),
                                  fixedSize: MaterialStateProperty.all<Size>(Size(200, 25)),
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return StatefulBuilder(
                                        builder: (BuildContext context,
                                            StateSetter setState) {
                                          return AlertDialog(
                                            title: Text('Выберите роль:'),
                                            content: DropdownButton<String>(
                                              value: selectedRole,
                                              onChanged: (String? newValue) {
                                                setState(() {
                                                  selectedRole = newValue;
                                                });
                                              },
                                              items: <String>[
                                                'USER',
                                                'MODER',
                                                'ADMIN',
                                                'EMPLOYER'
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
                                                  changeRole(data.id, selectedRole);
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('OK', style: TextStyle(color: Colors.white)),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  );
                                },

                                child: Text('Назначить роль', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ));
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.grey.shade900),
                  onPressed: previousPage,
                ),
              ),
              SizedBox(width: 20),
              Text(
                'Страница ${currentPage + 1}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 20),
              Expanded(
                child: IconButton(
                  icon: Icon(Icons.arrow_forward, color: Colors.grey.shade900),
                  onPressed: nextPage,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
