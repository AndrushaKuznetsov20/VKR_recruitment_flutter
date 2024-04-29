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
import 'UpdateResume.dart';

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

  Future<void> deleteResume(int resumeId, BuildContext context) async {
    final response = await http.delete(
      Uri.parse(
          'http://172.20.10.3:8092/resume/delete/$resumeId'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.body),
        ),
      );
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => LK(token: widget.token)));
  }

  void showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Удалить резюме?'),
          content: Text('Вы действительно хотите удалить это резюме?'),
          actions: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.not_interested, color: Colors.red),
              label: Text('Нет'),
              style: ButtonStyle(
                backgroundColor:
                MaterialStateProperty.all<Color>(Colors.grey.shade900),
                foregroundColor:
                MaterialStateProperty.all<Color>(Colors.white),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                deleteResume(widget.resume!.id, context);
              },
              icon: Icon(Icons.check, color: Colors.green),
              label: Text('Да'),
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
            icon: Icon(Icons.delete_forever, color: Colors.white),
            onPressed: () {
              showDeleteConfirmationDialog(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: () {
               Navigator.push(context,MaterialPageRoute(builder: (context) => UpdateResume(token: widget.token, id: widget.resume!.id, fullName: widget.resume!.fullName, birthDate: widget.resume!.birthDate, city: widget.resume!.city, skills: widget.resume!.skills, education: widget.resume!.education, otherInfo: widget.resume!.otherInfo)));
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
                          Text(utf8.decode(widget.resume!.fullName.codeUnits)),
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
                          Text(dateFormat.format(widget.resume!.birthDate)),
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
                          Text(widget.resume!.age.toString()),
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
                          Text(utf8.decode(widget.resume!.city.codeUnits)),
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
                          Text(utf8.decode(widget.resume!.skills.codeUnits)),
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
                          Text(utf8.decode(widget.resume!.education.codeUnits)),
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
                          Text(utf8.decode(widget.resume!.otherInfo.codeUnits)),
                        ],
                      ),
                    ),
                    Divider(),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.black,
                        child: Icon(
                          utf8.decode(widget.resume!.statusResume.codeUnits) ==
                                  'Заблокировано!'
                              ? Icons.block
                              : utf8.decode(widget
                                          .resume!.statusResume.codeUnits) ==
                                      'Опубликовано!'
                                  ? Icons.check_circle
                                  : Icons.drafts,
                          color: Colors.white,
                        ),
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Статус резюме:',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            utf8.decode(widget.resume!.statusResume.codeUnits),
                            style: TextStyle(
                              color: utf8.decode(widget
                                          .resume!.statusResume.codeUnits) ==
                                      'Заблокировано!'
                                  ? Colors.red
                                  : utf8.decode(widget.resume!.statusResume
                                              .codeUnits) ==
                                          'Опубликовано!'
                                      ? Colors.green
                                      : Colors.black,
                            ),
                          ),
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