import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/Role.dart';
import '../Models/User.dart';
import 'Home.dart';
import 'ModerPage.dart';
import 'UpdateUser.dart';

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

  // void showEditProfileDialog(BuildContext context) {
  //   TextEditingController nameController = TextEditingController(text: user?.username);
  //   TextEditingController emailController = TextEditingController(text: user?.email);
  //   TextEditingController passwordController = TextEditingController(text: user?.password);
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   'Редактирование профиля',
  //                   style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
  //                 ),
  //                 SizedBox(height: 5),
  //                 Text(
  //                   'Внимание! После успешного\nобновления данных\nнеобходимо перезайти в аккаунт !',
  //                   style: TextStyle(fontSize: 10, color: Colors.grey),
  //                 ),
  //               ],
  //             ),
  //             IconButton(
  //               icon: Icon(Icons.arrow_back),
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               },
  //             ),
  //           ],
  //         ),
  //         content: SingleChildScrollView(
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               TextFormField(
  //                 controller: nameController,
  //                 cursorColor: Colors.black,
  //                 style: TextStyle(color: Colors.black, fontSize: 14),
  //                 decoration: InputDecoration(
  //                   prefixIcon: Icon(Icons.person, color: Colors.black),
  //                   labelText: 'Имя:',
  //                   labelStyle: TextStyle(color: Colors.black, fontSize: 14),
  //                   focusedBorder: OutlineInputBorder(
  //                     borderSide: BorderSide(color: Colors.black),
  //                   ),
  //                   contentPadding: EdgeInsets.symmetric(vertical: 10),
  //                   hintStyle: TextStyle(fontSize: 14),
  //                 ),
  //                 maxLines: null,
  //                 textAlign: TextAlign.start,
  //               ),
  //
  //               SizedBox(height: 10),
  //               TextFormField(
  //                 controller: emailController,
  //                 cursorColor: Colors.black,
  //                 style: TextStyle(color: Colors.black, fontSize: 14),
  //                 decoration: InputDecoration(
  //                   prefixIcon: Icon(Icons.email, color: Colors.black),
  //                   labelText: 'Email:',
  //                   labelStyle: TextStyle(color: Colors.black, fontSize: 14),
  //                   focusedBorder: OutlineInputBorder(
  //                     borderSide: BorderSide(color: Colors.black),
  //                   ),
  //                   contentPadding: EdgeInsets.symmetric(vertical: 10),
  //                   hintStyle: TextStyle(fontSize: 14),
  //                 ),
  //                 maxLines: null,
  //                 textAlign: TextAlign.start,
  //               ),
  //               SizedBox(height: 10),
  //               TextFormField(
  //                 controller: passwordController,
  //                 cursorColor: Colors.black,
  //                 style: TextStyle(color: Colors.black, fontSize: 14),
  //                 decoration: InputDecoration(
  //                   prefixIcon: Icon(Icons.lock, color: Colors.black),
  //                   labelText: 'Пароль:',
  //                   labelStyle: TextStyle(color: Colors.black, fontSize: 14),
  //                   focusedBorder: OutlineInputBorder(
  //                     borderSide: BorderSide(color: Colors.black),
  //                   ),
  //                   contentPadding: EdgeInsets.symmetric(vertical: 10),
  //                   hintStyle: TextStyle(fontSize: 14),
  //                 ),
  //                 maxLines: null,
  //                 textAlign: TextAlign.start,
  //               ),
  //             ],
  //           ),
  //         ),
  //         actions: [
  //           ElevatedButton(
  //             onPressed: () {
  //               updateDataUser(context, nameController, emailController, passwordController);
  //             },
  //             child: Text('Обновить данные'),
  //             style: ButtonStyle(
  //               backgroundColor: MaterialStateProperty.all<Color>(Colors.grey.shade900),
  //               foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

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
                SizedBox(height: 20),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context,MaterialPageRoute(builder: (context) => UpdateUser(token: widget.token, username: user!.username, email: user!.email, password: user!.password)));
                    },
                    child: Text('Редактировать профиль'),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.grey.shade900),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context,MaterialPageRoute(builder: (context) => Home()));
                    },
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