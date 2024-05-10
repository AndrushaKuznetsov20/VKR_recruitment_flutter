import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../Models/Resume.dart';
import '../LK/LK.dart';
import '../LK/ProfileUser.dart';
import 'EmployerPage.dart';

class EmployerResume extends StatefulWidget {
  final String token;

  EmployerResume({required this.token});

  @override
  EmployerResumeState createState() => EmployerResumeState();
}

class EmployerResumeState extends State<EmployerResume> {
  List<Resume> dataList = [];
  int currentPage = 0;

  DateFormat dateFormat = DateFormat('dd.MM.yyyy');

  @override
  void initState() {
    super.initState();
    listResumeSetStatusOk(currentPage, context);
  }

  Future<void> listResumeSetStatusOk(int pageNo, BuildContext context) async {
    final response = await http.get(
      Uri.parse(
          'http://172.20.10.3:8092/resume/listResumeStatusOk/$pageNo'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      List<Resume> resumes = [];
      for (var entry in jsonData.entries) {
        var key = entry.key;
        var value = entry.value;

        if (key == 'resumes') {
          for (var resumesJson in value) {
            resumes.add(Resume.fromJson(resumesJson));
          }
        }
        if (resumes.isEmpty) {
          currentPage--;
          listResumeSetStatusOk(currentPage, context);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Резюме больше нет!"),
            ),
          );
        }
      }
      setState(() {
        dataList = resumes;
      });
    }
  }

  Future<void> createResponseToResume(int resumeId, BuildContext context) async {
    final response = await http.post(
      Uri.parse('http://172.20.10.3:8092/responseToResume/create/$resumeId'),
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
  }

  void nextPage() {
    setState(() {
      currentPage++;
      listResumeSetStatusOk(currentPage, context);
    });
  }

  void previousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
        listResumeSetStatusOk(currentPage, context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Актуальные резюме',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey.shade900,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EmployerPage(token: widget.token)));
          },
        ),
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
                          Text('${utf8.decode(data.fullName.codeUnits)}',
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
                              Text('Дата рождения:',
                                  style:
                                  TextStyle(fontWeight: FontWeight.bold)),
                              Text(dateFormat.format(data.birthDate)),
                              Divider(),
                              Text('Возраст:',
                                  style:
                                  TextStyle(fontWeight: FontWeight.bold)),
                              Text(data.age.toString()),
                              Divider(),
                              Text('Город:',
                                  style:
                                  TextStyle(fontWeight: FontWeight.bold)),
                              Text(utf8.decode(data.city.codeUnits)),
                              Divider(),
                              Text('Навыки:',
                                  style:
                                  TextStyle(fontWeight: FontWeight.bold)),
                              Text(utf8.decode(data.skills.codeUnits)),
                              Divider(),
                              Text('Образование:',
                                  style:
                                  TextStyle(fontWeight: FontWeight.bold)),
                              Text(utf8.decode(data.education.codeUnits)),
                              Divider(),
                              Text('Другая информация:',
                                  style:
                                  TextStyle(fontWeight: FontWeight.bold)),
                              Text(utf8.decode(data.otherInfo.codeUnits)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.account_circle,
                                    color: Colors.black),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ProfileUser(token: widget.token, id: data.user.id, vacancyId: 0)),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.thumb_up,
                                    color: Colors.black),
                                onPressed: () {
                                  createResponseToResume(data.id, context);
                                },
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