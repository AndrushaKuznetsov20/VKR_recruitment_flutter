import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:recruitment/PageScreen/LK/ProfileUser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Models/Resume.dart';
import '../Home.dart';
import '../LK/LK.dart';
import 'package:intl/intl.dart';

import 'UpdateResume.dart';

class ReadUserResume extends StatefulWidget{
  final String token;
  final Resume resume;
  ReadUserResume({required this.token, required this.resume});

  @override
  ReadUserResumestate createState() => ReadUserResumestate();
}
class ReadUserResumestate extends State<ReadUserResume> {

  DateFormat dateFormat = DateFormat('dd.MM.yyyy');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Резюме', style: TextStyle(color: Colors.white)),
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
              Navigator.push(context,MaterialPageRoute(builder: (context) => Home()));
            },
          ),
        ],
      ),
      body: Center(
        child: Card(
          margin: EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: SingleChildScrollView(
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
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ФИО:',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(utf8.decode(widget.resume.fullName.codeUnits)),
                        ],
                      ),
                    ),
                    Divider(),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.black,
                        child: Icon(Icons.calendar_today, color: Colors.white),
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Дата рождения:',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(dateFormat.format(widget.resume.birthDate)),
                        ],
                      ),
                    ),
                    Divider(),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.black,
                        child: Icon(Icons.calendar_today, color: Colors.white),
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Возраст:',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(widget.resume.age.toString()),
                        ],
                      ),
                    ),
                    Divider(),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.black,
                        child: Icon(Icons.location_city, color: Colors.white),
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Город:',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(utf8.decode(widget.resume.city.codeUnits)),
                        ],
                      ),
                    ),
                    Divider(),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.black,
                        child: Icon(Icons.work, color: Colors.white),
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Навыки:',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(utf8.decode(widget.resume.skills.codeUnits)),
                        ],
                      ),
                    ),
                    Divider(),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.black,
                        child: Icon(Icons.school, color: Colors.white),
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Образование:',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(utf8.decode(widget.resume.education.codeUnits)),
                        ],
                      ),
                    ),
                    Divider(),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.black,
                        child: Icon(Icons.info, color: Colors.white),
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Другая информация:',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(utf8.decode(widget.resume.otherInfo.codeUnits)),
                        ],
                      ),
                    ),
                    Divider(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}