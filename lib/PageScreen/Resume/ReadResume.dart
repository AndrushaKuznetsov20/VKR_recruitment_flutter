import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Models/Resume.dart';
import '../Home.dart';
import '../LK/LK.dart';
import 'package:intl/intl.dart';

import 'CreateResume.dart';

class ReadResume extends StatefulWidget{
  final String token;
  final Resume? resume;
  ReadResume({required this.token, required this.resume});

  @override
  ReadResumestate createState() => ReadResumestate();
}
class ReadResumestate extends State<ReadResume> {

  // Resume? resume;
  DateFormat dateFormat = DateFormat('dd.MM.yyyy');

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id');
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Ваше резюме', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey.shade900,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => LK(token: widget.token)));
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              // Navigator.push(context,MaterialPageRoute(builder: (context) => UpdateUser(token: widget.token, username: user!.username, email: user!.email, password: user!.password)));
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
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text('ФИО: ${utf8.decode(widget.resume!.fullName.codeUnits)}'),
                ),
                Divider(),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.black,
                    child: Icon(Icons.calendar_today, color: Colors.white),
                  ),
                  title: Text('Дата рождения: ${dateFormat.format(widget.resume!.birthDate)}'),
                ),
                Divider(),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.black,
                    child: Icon(Icons.location_city, color: Colors.white),
                  ),
                  title: Text('Город: ${utf8.decode(widget.resume!.city.codeUnits)}'),
                ),
                Divider(),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.black,
                    child: Icon(Icons.work, color: Colors.white),
                  ),
                  title: Text('Навыки: ${utf8.decode(widget.resume!.skills.codeUnits)}'),
                ),
                Divider(),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.black,
                    child: Icon(Icons.school, color: Colors.white),
                  ),
                  title: Text('Образование: ${utf8.decode(widget.resume!.education.codeUnits)}'),
                ),
                Divider(),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.black,
                    child: Icon(Icons.info, color: Colors.white),
                  ),
                  title: Text('Другая информация: ${utf8.decode(widget.resume!.otherInfo.codeUnits)}'),
                ),
                Divider(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}